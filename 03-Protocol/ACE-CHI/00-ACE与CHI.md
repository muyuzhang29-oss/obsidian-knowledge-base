---
aliases: [ACE, CHI, AMBA ACE, Coherency, CCI]
tags: [Protocol, ACE, CHI, AMBA, 一致性]
created: 2026-09-27
updated: 2026-09-27
---

# 00-ACE与CHI一致性协议

> [!abstract] 概述
> - **ACE**（AXI Coherency Extensions）：AXI + snoop/响应，多核 CPU 缓存一致性
> - **CHI**（Coherent Hub Interface）：新一代分层包协议，高带宽互连
>
> 与 [[03-Protocol/AXI/00-AXI|AXI]] 的差别：增加 **缓存行状态、侦听（snoop）、一致性响应**。

---

## 1. 为什么需要一致性

```text
Core0 缓存有 X=1，Core1 内存/缓存 X=0
→ 读写不一致
→ 需要 snoop + 状态机（MOESI/MESI）
```

| 状态 | 含义（MESI） |
|------|----------------|
| M | Modified，独占脏 |
| E | Exclusive，独占净 |
| S | Shared |
| I | Invalid |

---

## 2. ACE 与 AXI 关系

```text
ACE = AXI5 通道 + 额外:
  ARUSER / AWUSER  (acaddr, snoop 类型)
  RRESP / BRESP 扩展 (PassDirty, IsShared, WasUnique...)
  Snoop 通道: AC / CR / CD / RACK / WACK
```

```mermaid
%%{init: {'theme':'neutral','themeVariables':{
  'primaryColor':'#fffaf3','primaryTextColor':'#4a2c22','primaryBorderColor':'#ead7c6',
  'lineColor':'#8a6a58','secondaryColor':'#f3e2d4','tertiaryColor':'#fffaf3',
  'background':'#fffdf9','mainBkg':'#fffaf3','nodeBorder':'#ead7c6',
  'clusterBkg':'#fff7ed','clusterBorder':'#e2cbb8','edgeLabelBackground':'#f3e2d4',
  'fontFamily':'-apple-system,PingFang SC,Microsoft YaHei,sans-serif'
}}}%%
graph LR
  M[Master CPU] -- AXI/ACE --> C[Coherent Interconnect CCI/CCN]
  C -- Snoop AC/CR --> M
  C -- ACE --> S[Slave / Memory]
```

### 通道扩展（ACE）

| 通道 | 作用 |
|------|------|
| AC | Snoop address 发到 master |
| CR | Snoop response（IsShared/PassDirty） |
| CD | Snoop data |
| RACK / WACK | 响应 ack |

---

## 3. 读/写/侦听类型（ACE，节选）

| 类型 | 含义 |
|------|------|
| ReadOnce / ReadClean | 读不改状态 / 只要 clean |
| ReadShared / ReadUnique | 要共享 / 独占 |
| WriteBack / WriteClean / WriteUnique | 回写/清/独占写 |
| CleanInvalid / MakeInvalid | 清/作废缓存行 |
| Snoop: ReadOnce / CleanInvalid | 侦听命令 |

---

## 4. CHI 简介

| 概念 | 说明 |
|------|------|
| Flit / Packet | 三层：REQ/RSP/DAT/SNP |
| Home Node | 目录/内存控制器 |
| Slave / RN-F | 请求节点（CPU）、完整请求节点 |
| SF.HN | Snoop Filter |

```text
RN (CPU) --CHI--> Home Node --CHI--> SN (memory)
                  │
                  └── SNP snoop 回 RN
```

> [!tip] 学习路径
> 先掌握 **ACE + MESI**，再看 CHI 通道与事务类型；CHI 条目极多，验证按 **事务矩阵 + 目录命中/未命中** 拆。

---

## 5. 验证要点（一致性）

| # | 检查 |
|---|------|
| C1 | 同行读写后状态迁移合法（MESI） |
| C2 | dirty 回写到内存 |
| C3 | snoop 命中/不命中响应 |
| C4 | 多核并发同行（race） |
| C5 | 原子：原子 RMW |
| C6 | 非缓存访问（Device / Non-cacheable） |
| C7 | 互斥：exclusive cache line |
| C8 | 目录溢出、snoop filter 满 |
| C9 | 部分更新 / 合并写 |
| C10 | 错误响应与重试 |

### 覆盖点示例

```systemverilog
cp_state   : coverpoint cache_state;
cp_cmd     : coverpoint ace_cmd;
x_cmd_state: cross cp_cmd, cp_state;
cp_snoop   : coverpoint snoop_hit;
cp_id      : coverpoint cpu_id;
x_cpu_row  : cross cp_id, row_id; // 多核同行
```

---

## 6. Scoreboard / 模型

```text
模型：每个 cache line 的 {state, tag, dirty, owner}
行为：ReadShared → 可能 snoop 别核 → 组数据
比对：数据字、状态、是否 writeback
```

可用 **RMW 序列** 配合 [[02-UVM/13-虚拟Sequence]] 多核激励。

---

## 7. 常见 bug

| 症状 | 原因 |
|------|------|
| 多核读旧数据 | snoop 漏发/延迟 |
| 内存脏数据丢 | PassDirty 处理错 |
| 死锁 | snoop 与 request 资源互锁 |
| 性能掉 | 目录误判、过度 invalid |

---

## 8. 与 VIP

- Arm **CCI / CCN / CMN** 验证常用官方 VIP
- 自研互联：必须建 **缓存行状态模型**
- 从 AXI VIP 升级：加 snoop monitor + 状态机

---

## 相关

- [[03-Protocol/AXI/00-AXI]]
- [[03-Protocol/AXI/01-AXI事务与突发]]
- [[03-Protocol/AXI/03-AXI互联与仲裁进阶]]
- [[05-Verification/16-参考模型与Scoreboard]]

---

*更新: 2026-09-27*
