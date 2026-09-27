---
aliases: [UART验证, UART checklist]
tags: [Protocol, UART, Verification]
created: 2026-09-27
updated: 2026-09-27
---

# 01-UART验证要点

> [!abstract] 用途
> UART IP（含 FIFO、流控、可选 RS-485/RS-232）验证清单。协议见 [[03-Protocol/UART/00-UART]]。

---

## 1. 帧格式

```text
空闲高 → START(0) → D0..D7 (或 5-9bit) → [PARITY] → STOP(1)
```

| 参数 | 常见取值 | 验证 |
|------|----------|------|
| 波特率 | 9600..3M | 误差 <2% |
| 数据位 | 5/6/7/8 | 边界 |
| 校验 | none/odd/even | 注入错校验 |
| 停止位 | 1/2 | 2 停止位 |
| 流控 | none/RTS-CTS/XON-XOFF | 背压 |

---

## 2. 用例矩阵

| # | 类别 | 用例 |
|---|------|------|
| U1 | 收发 | TX→RX 自环、对端 |
| U2 | 配置 | 波特率/数据位/校验/停止位 |
| U3 | 边界 | 0x00、0xFF、0x55/0xAA（翻转） |
| U4 | 错误 | 帧错、校验错、break、溢出 |
| U5 | FIFO | 满/空、触发水位、DMA |
| U6 | 流控 | CTS 拉低暂停 TX |
| U7 | 中断 | rx/tx done、line status |
| U8 | 波特率偏差 | ±2% 双端 |
| U9 | 复位 | 传输中复位 |
| U10 | 多字节 | back-to-back 帧无空闲 |

---

## 3. 采样与同步

```text
异步时钟域：用 16x 过采样，多数表决取中点
检查：start 毛刺不应触发；sampling 点在 bit 中心
```

```systemverilog
// 简化采样模型
always @(posedge baud_clk) begin
  if (rx_sync == 1'b0 && state == IDLE) begin
    repeat (HALF_BIT) @(posedge baud_clk);
    for (int i = 0; i < data_bits; i++) begin
      data[i] = rx_sync;
      repeat (BIT_CLKS) @(posedge baud_clk);
    end
  end
end
```

---

## 4. Scoreboard

| 项 | 比对 |
|----|------|
| 帧载荷 | byte / word 顺序 |
| 校验位 | 计算 parity |
| 错误注入 | 期望 `frame_err/parity_err/overrun` |
| 时序 | 帧间隔、break 长度 |

---

## 5. SVA / 检查器

```systemverilog
// 空闲高、start 后保持 N 拍低
a_break: assert property (
  @(posedge clk) (rx == 0) throughout (BREAK_TIME) |-> break_irq
);
// 校验
```

实用：用 **bench checker** 解帧报错，SVA 只抓握手与复位。

---

## 6. 覆盖

```systemverilog
cp_wlen : coverpoint wlen;
cp_par  : coverpoint parity_mode;
cp_stop : coverpoint stop_bits;
cp_err  : coverpoint {frame_err, par_err, ovre};
x_cfg   : cross cp_wlen, cp_par, cp_stop;
cp_gap  : coverpoint inter_frame_gap { bins tight={[1:2]}; bins normal={[3:10]}; }
```

---

## 7. 常见 bug

| 症状 | 原因 |
|------|------|
| 高波特率偶错 | 采样点偏、时钟误差 |
| 连续字节粘包 | 帧间隔未检测 |
| FIFO 丢字 | 触发水位/读延迟 |
| break 不识别 | 阈值时间错误 |

---

## 相关

- [[03-Protocol/UART/00-UART]]
- [[03-Protocol/I2C/01-I2C验证要点]]
- [[05-Verification/17-中断DMA存储验证]]

---

*更新: 2026-09-27*
