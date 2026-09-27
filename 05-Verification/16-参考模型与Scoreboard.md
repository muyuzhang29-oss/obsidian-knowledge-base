---
aliases: [参考模型, Reference Model, Golden Model, Scoreboard设计]
tags: [Verification, Scoreboard, ReferenceModel, 核心]
created: 2026-09-27
updated: 2026-09-27
---

# 16-参考模型与Scoreboard设计

> [!abstract] 一句话
> **Reference Model（黄金模型）** 算「应该是什么」；**Scoreboard** 负责「DUT 出来了什么」与期望比对，并输出 pass/fail。

---

## 1. 三层职责

```text
Stimulus → DUT → Monitor ─┐
                │        │  actual
                └→ RefModel → expected
                          │
                     Scoreboard (compare)
                          ↓
                       pass / fail
```

| 组件 | 职责 | 不做什么 |
|------|------|----------|
| Monitor | 无侵入采事务 | 不驱动 |
| RefModel | 按规格算期望 | 不绑死某 DUT 端口 |
| Scoreboard | 存、比、报 | 不算协议细节（交给 model） |
| Coverage | 记是否见过 | 不判断对错 |

---

## 2. Reference Model 写法

### 2.1 事务级（UVM，推荐）

```systemverilog
class spi_ref_model extends uvm_component;
  `uvm_component_utils(spi_ref_model)

  uvm_tlm_analysis_fifo #(spi_trans) act_in;  // from monitor
  uvm_analysis_port     #(spi_trans) exp_out; // to scoreboard

  function void write_input(spi_trans tr);
    spi_trans exp = spi_trans::type_id::create("exp");
    exp.addr = tr.addr;
    exp.data = golden(tr); // 规格：例如移位/校验
    exp_out.write(exp);
  endfunction
endclass
```

### 2.2 C / 脚本黄金模型

```text
SV monitor → DPI/文件 → C model → 期望数据 → 回传 SV scoreboard
```

- 优点：与架构组共用 C，一致性高
- 代价：接口、数据打包、线程安全

---

## 3. Scoreboard 模式

| 模式 | 说明 | 适用 |
|------|------|------|
| **In-order** | FIFO 顺序比对 | 无乱序接口 |
| **Out-of-order** | 带 tag/id 匹配 | AXI、网络 |
| **Stream** | 连续比特流比对 | 串行、JTAG |
| **State-based** | 周期采样内部状态 | 寄存器/FSM |
| **Property** | SVA 断言当 oracle | 协议时序 |

```systemverilog
class io_scoreboard extends uvm_scoreboard;
  uvm_tlm_analysis_fifo #(spi_trans) exp_fifo;
  uvm_tlm_analysis_fifo #(spi_trans) act_fifo;

  task run_phase(uvm_phase phase);
    spi_trans exp, act;
    forever begin
      exp_fifo.get(exp);
      act_fifo.get(act);
      if (!exp.compare(act))
        `uvm_error("SB", $sformatf("MISMATCH exp=%s act=%s", exp.sprint(), act.sprint()))
      else
        `uvm_info("SB", "MATCH", UVM_HIGH)
    end
  endtask
endclass
```

---

## 4. 比对策略

> [!tip] compare 三要点
> 1. **自定义 `do_compare`**：忽略 X、reserved、时间戳
> 2. **容错**：延迟匹配（允许 N cycle），但要限次数
> 3. **采样对齐**：同一时钟沿 / 同一 phase 采样

```systemverilog
virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  spi_trans t;
  if (!$cast(t, rhs)) return 0;
  if (this.addr !== t.addr) return 0;
  if (this.data !== t.data && !$isunknown(t.data)) return 0;
  return 1;
endfunction
```

---

## 5. 与 UVM Analysis Port

```text
monitor.ap ──┬→ scoreboard.act_fifo
             ├→ coverage.sub
             └→ logger

ref_model.exp_out ──→ scoreboard.exp_fifo
```

- 参考 [[06-UVM-Template/13-Analysis-Port数据流]] 与 [[06-UVM-Template/14-analysis_imp多端口陷阱]]
- 多个 port 写同一 imp 要用 `analysis_imp_decl` 或 FIFO

---

## 6. 端到端数据流检查清单

- [ ] 同一事务 **id/addr** 能在 exp/act 对齐
- [ ] 溢出/欠载、错误注入有 **负例期望**
- [ ] 复位后 FIFO 清空、scoreboard 状态清零
- [ ] 超时：N 拍未完成比对要报 error
- [ ] 统计 match/mismatch/ratio，与覆盖率对照

---

## 7. 何时用 SVA 代替 Scoreboard

| 用 SVA | 用 Scoreboard |
|--------|----------------|
| 协议时序（VALID/READY） | 数据载荷正确 |
| 属性（最多 16 outstanding） | 多级流水结果 |
| 突发间断/复位恢复 | 与 C model 长流比对 |

---

## 相关笔记

- [[06-UVM-Template/06-reference_model]]
- [[06-UVM-Template/07-scoreboard]]
- [[06-UVM-Template/05-monitor]]
- [[02-UVM/12-寄存器模型RAL]]
- [[05-Verification/15-代码覆盖率目标与收敛]]

---

*更新: 2026-09-27*
