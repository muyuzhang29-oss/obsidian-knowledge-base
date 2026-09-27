---
aliases: [APB验证, APB checklist]
tags: [Protocol, APB, Verification, AMBA]
created: 2026-09-27
updated: 2026-09-27
---

# 01-APB验证要点

> [!abstract] 用途
> APB bridge / slave 验证清单。协议见 [[03-Protocol/APB/00-APB]]，常与 [[03-Protocol/AHB/00-AHB|AHB]]、[[03-Protocol/AXI/00-AXI|AXI]] 做系统级配置通路。

---

## 1. 两阶段握手（必记）

```text
SETUP:   PSEL=1, PENABLE=0   （1 拍）
ACCESS:  PSEL=1, PENABLE=1   （PREADY=1 时结束）
```

| 信号 | 说明 |
|------|------|
| PSEL | 片选（decode） |
| PENABLE | 第二拍 |
| PWRITE | 1 写 0 读 |
| PADDR / PWDATA / PRDATA | 地址/写/读 |
| PREADY | 从设备 wait |
| PSLVERR | 错误（0=OK） |
| PPROT / PSTRB | 保护 / 写选通（可选） |

> [!tip] 稳定规则
> PSEL、PADDR、PWRITE、PWDATA 在 SETUP→ACCESS **必须保持**；PREADY 可拉长 ACCESS。

---

## 2. 用例矩阵

| # | 类别 | 用例 |
|---|------|------|
| P1 | 基本 | 单次读/写，无 wait |
| P2 | wait | PREADY 插 0/1/N 拍 |
| P3 | 连续 | back-to-back 不回 SETUP（非法） |
| P4 | 译码 | 合法/非法地址 → PSLVERR |
| P5 | 字节 | PSTRB 部分写 |
| P6 | 保护 | PPROT 组合 |
| P7 | 复位 | ACCESS 中复位 |
| P8 | 并发 | 多 slave 选择、互斥 |

---

## 3. 正确时序（读）

```text
clk     _|‾|_|‾|_|‾|_|‾|_
PSEL    ___/‾‾‾‾‾‾‾\______
PENABLE ______/‾‾‾\________
PADDR   ====A==============
PREADY  _______/‾\_________
PRDATA  _______D___________
```

PREADY=0 时 PENABLE 保持，PADDR 不变。

---

## 4. 检查点

```text
✓ SETUP 只有一拍（不得 PENABLE 与 PSEL 同时首拍拉起又跳回）
✓ ACCESS 期间 PADDR/PWRITE 不变
✓ 写：PWDATA 在 ACCESS 有效
✓ 读：PRDATA 在 PREADY=1 同拍有效
✓ PSLVERR 仅在 ACCESS+PREADY 有效
✓ 解码错误也有完整握手
```

### SVA

```systemverilog
property p_stable_addr;
  @(posedge clk) disable iff (!rst_n)
  (psel && penable && !pready) |=> $stable(paddr) && $stable(pwrite);
endproperty
a_stable: assert property (p_stable_addr);

property p_setup_one;
  @(posedge clk) disable iff (!rst_n)
  psel && !penable |=> penable; // 下一拍必须进 ACCESS
endproperty
```

---

## 5. 覆盖

```systemverilog
cp_rnw    : coverpoint pwrite;
cp_wait   : coverpoint wait_cnt { bins w0={0}; bins w1={1}; bins wN={[2:7]}; }
cp_slverr : coverpoint pslverr;
cp_addr   : coverpoint paddr[11:0];
x_rnw_wait : cross cp_rnw, cp_wait;
```

---

## 6. 常见 bug

| 症状 | 原因 |
|------|------|
| 第二次读到旧数据 | ACCESS 拍未采样、发新太快 |
| 偶发 PSLVERR | 译码或 wait 提前结束 |
| 写覆盖 | PSTRB 未正确处理 |
| 与 AHB 桥失败 | HREADY/PREADY 映射错 |

---

## 相关

- [[03-Protocol/APB/00-APB]]
- [[03-Protocol/AHB/00-AHB]]
- [[02-UVM/12-寄存器模型RAL]]
- [[05-Verification/16-参考模型与Scoreboard]]

---

*更新: 2026-09-27*
