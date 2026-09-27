---
aliases: [AXI互联, AXI Interconnect, AXI仲裁, AXI QoS, Crossbar]
tags: [Protocol, AXI, Interconnect, 核心]
created: 2026-09-27
updated: 2026-09-27
---

# 03-AXI互联与仲裁进阶

> [!abstract] 适用
> 多 master ↔ 多 slave 的 **crossbar / NoC** 验证：地址译码、仲裁、outstanding、QoS、错误透传。
> 前置：[[03-Protocol/AXI/01-AXI事务与突发]] · [[03-Protocol/AXI/02-AXI验证要点]]

---

## 1. 互联拓扑

```text
Master0 ──┐
Master1 ──┼──▶ Interconnect ──▶ Slave0 (mem)
Master2 ──┘         │
                    └──▶ Slave1 (bridge → APB)
```

| 角色 | 验证重点 |
|------|----------|
| Master | 激励、ID、outstanding |
| Interconnect | 译码、仲裁、ID 管理、响应复用 |
| Slave | 响应、延迟、错误 |

---

## 2. 地址译码

```text
Slave0: 0x0000_0000 - 0x0000_FFFF
Slave1: 0x1000_0000 - 0x1000_0FFF
Default: 0xFFFF_FFFF → DECERR
```

| 检查 | 期望 |
|------|------|
| 命中区间边界 | 正确 slave |
| 越界/空洞 | DECERR |
| 重叠区间 | 优先级策略（设计约定） |

```systemverilog
function int decode(input bit [31:0] addr);
  if (addr inside {[32'h0000_0000:32'h0000_FFFF]}) return 0;
  if (addr inside {[32'h1000_0000:32'h1000_0FFF]}) return 1;
  return -1;
endfunction
```

---

## 3. 仲裁策略

| 策略 | 说明 | 验证 |
|------|------|------|
| Fixed priority | 低号始终优先 | 饥饿 |
| Round-robin | 轮转 | 公平性统计 |
| QoS-based | AxQOS 高优先 | 高/低 QoS 吞吐 |
| 先来先服务 | 队列 | 深度边界 |

```systemverilog
// 轮转公平：每 master 命中次数差 < 阈值
if (max_cnt - min_cnt > FAIR_DELTA)
  `uvm_error("FAIR", "round-robin starvation")
```

### 锁定 vs 未锁定

- `AxLOCK`（AXI4 exclusive）：命中行独占
- locked 传输：仲裁期不得切 master（易造饥饿，要限时）

---

## 4. ID 管理（互联最容易藏 bug）

```text
Master 发 AWID=x
Interconnect 可能改写为内部 ID
返回 BID 时必须映射回原 x
```

| 检查 | 内容 |
|------|------|
| ID 映射 | master 视角 ID 不变 |
| 同 ID 保序 | 跨 slave 同 ID 顺序 |
| 不同 ID 乱序 | 允许但 scoreboard 要能重组 |
| ID 翻译冲突 | 多 master 同 ID 到同 slave |

> [!warning]
> 互联把 4 个 master 的 ID=0 压到同一 slave 时，必须 **扩展 ID 位**，否则响应会串。

---

## 5. Outstanding 与背压

| 参数 | 含义 |
|------|------|
| Max ID slots | 同时在途不同 ID |
| Max transactions | 总 outstanding |
| Write merging | 连续写是否合并 |

```text
压力：Master 连发 32 笔不同 ID
检查：slave 未完成时不乱序回错误 slave；无死锁（W 与 B 通道）
```

死锁经典：**写数据 W 等 AW、AW 又因 slave 不接**——用 checker 超时报警。

---

## 6. 响应汇总

| 现象 | 处理 |
|------|------|
| 一 master 打多 slave | 各 slave 独立响应 |
| DECERR | 由互联生成（地址空洞） |
| SLVERR | 从 slave 透传 |
| 多 beat 读部分错 | RRESP 每拍可能不同，最后一拍为准或任一错（设计定义） |

---

## 7. QoS 与分区

```text
AxQOS[3:0]：数值大 → 高优先（AMBA 约定，实现可反转，要对照手册）
AxREGION：slave 内部分区
AxPROT：secure/non-secure 必须在互联强制隔离
```

**Secure 突破** 是安全验证红线：non-secure master 不得读到 secure slave。

---

## 8. 用例矩阵（互联）

| # | 用例 |
|---|------|
| X1 | 单 master 单 slave 基线 |
| X2 | 多 master 抢一 slave（RR / QoS） |
| X3 | 一 master 同时打多 slave |
| X4 | 译码错误 DECERR |
| X5 | 乱序：不同 ID 返回换序 |
| X6 | 同 ID 跨 slave 保序 |
| X7 | exclusive 跨 slave |
| X8 | 复位 / 中途掉电 |
| X9 | 死锁压力：最大 outstanding |
| X10 | secure/non-secure 交叉 |

---

## 9. 覆盖

```systemverilog
cp_master : coverpoint master_id;
cp_slave  : coverpoint slave_sel;
cp_qos    : coverpoint qos;
x_ms      : cross cp_master, cp_slave;
x_qos_resp: cross cp_qos, resp;
```

统计 **仲裁计数、最长等待拍数、带宽利用率**。

---

## 10. 性能指标

| 指标 | 度量 |
|------|------|
| 延迟 | AR→R 第一拍 / AW→B |
| 吞吐 | 有效字节/拍 |
| 公平性 | 各 master 服务次数方差 |
| 空泡 | 总线 idle 拍占比 |

---

## 相关

- [[03-Protocol/AXI/02-AXI验证要点]]
- [[02-UVM/13-虚拟Sequence]]
- [[05-Verification/05-SoC验证方法论]]

---

*更新: 2026-09-27*
