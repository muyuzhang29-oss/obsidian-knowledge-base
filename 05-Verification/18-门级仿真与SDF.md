---
aliases: [门级仿真, GLS, SDF反标, Gate-level Simulation]
tags: [Verification, GLS, SDF, 核心, Signoff]
created: 2026-09-27
updated: 2026-09-27
---

# 18-门级仿真与SDF反标

> [!abstract] 为什么要做 GLS
> RTL 仿真是 0/1/X 理想；**综合后网表 + SDF 时序**才能暴露：
> 复位释放竞态、时钟门控、多周期、同步器、以及 **RTL 与网表行为不一致**。

---

## 1. 流程

```text
RTL 回归通过
  → 综合 (DC/Genus) 产生 netlist + SDF
  → (可选) 形式等价 LEC
  → GLS: netlist + SDF + 同一 TB + 测试
  → 看时序违规、X 传播、复位/GLCG
  → 签核清单
```

| 阶段 | 输入 | 目标 |
|------|------|------|
| RTL sim | RTL | 功能 |
| LEC | RTL vs netlist | 等价 |
| **GLS** | netlist + SDF | 时序/结构 |
| Power | netlist + SAIF | 功耗 |

---

## 2. 网表仿真要求

```text
✓ 同一 testbench / sequence（尽量）
✓ 路径改为 netlist 层次（RAL backdoor 要改）
✓ 禁止 TB 依赖 RTL 内部层次（用 interface/DPI 兼容）
✓ 定义 UNIT_DELAY / SDF 反标
✓ 处理 tri / x / pull
```

### `uvm_hdl` 路径

```systemverilog
// RTL
"tb.dut.u_regs.ctrl"
// netlist 综合后可能变成
"tb.dut/U_regs/ctrl_reg" // 视工具命名
```

> [!warning] 
> RAL 后门、force/deposit 在网表 **失效或路径变**。优先 frontdoor；后门在 GLS 阶段用 `define GLS` 切换。

---

## 3. SDF 反标

```systemverilog
// TB 顶层
initial begin
  $sdf_annotate("chip_final.sdf", tb.dut);
end
```

| SDF 内容 | 含义 |
|----------|------|
| (CELL ...) | 单元延迟 |
| IOPATH | 输入→输出 |
| SETUPHOLD | 时序检查 |
| INTERCONNECT | 线负载 |

反标后：仿真器对路径施加 delay，**非零保持**可能抓到 hold 违例。

---

## 4. GLS 专有现象

### 4.1 X 传播

```text
未初始化寄存器 → X → 逻辑污染
RTL 里 if(x) 走 else；门级更真实
```

处理：**复位完备**、`initial` 不依赖、关键路径显式复位。

### 4.2 时钟门控

```verilog
// RTL
always @(posedge clk) if (en) q <= d;
// 门级：ICG 单元
// en 变化时机影响门控毛刺
```

验证：en 毛刺、低功耗开关。

### 4.3 多周期 / 伪路径

综合插入 delay 后 RTL 单周期过、门级失败 → 设计约束（SDC）与功能对齐。

---

## 5. 回归策略

| 级别 | 内容 |
|------|------|
| 冒烟 | 冒烟用例 + 复位 + 基本读写 |
| 子集 | 协议/中断/DMA 核心 |
| 全量 | 可选（耗时） |
| 定向 | GLS 失败 bug 对应用例钉住 |

**不必全跑 RTL 全量**：选 **复位、时钟切换、门控、跨模块握手** 等对时序敏感项。

---

## 6. 检查清单

- [ ] 网表与 RTL 仿真波形关键信号等价
- [ ] SDF 反标后无 timing violation（或已知例外）
- [ ] 复位序列（异步复位释放）
- [ ] 时钟切换 / 门控使能
- [ ] 中断、FIFO、跨时钟（CDC）边界
- [ ] X 清理：关键状态无 X
- [ ] RAL 后门路径更新或禁用
- [ ] coverage 仅参考（工具对网表统计不同）

---

## 7. 常见失败与调法

| 现象 | 排查 |
|------|------|
| GLS 才挂 | 路径延迟、约束、复位 |
| 有 X | 复位/初始化、未驱动线 |
| 后门失败 | 层次改名 |
| 极慢 | 关闭 SDF 检查、用 `+sdfverbose` 看 |

```text
vcs -debug_access+all netlist.v tb.sv
  +vcs+lic+wait -negdelay +sdfverbose
  +define+GLS
```

---

## 8. 与形式化

| 手段 | 用途 |
|------|------|
| LEC | 等价，替代大部分 GLS |
| GLS + SDF | 真实时序、I/O 时序 |
| Formal | 端口协议、状态机 |

签核通常 **LEC + 冒烟 GLS + SDC 检查**。

---

## 相关

- [[05-Verification/06-时序分析基础]]
- [[05-Verification/08-时钟门控-PLL与物理验证]]
- [[05-Verification/03-CDC验证]]
- [[05-Verification/19-UPF低功耗仿真]]

---

*更新: 2026-09-27*
