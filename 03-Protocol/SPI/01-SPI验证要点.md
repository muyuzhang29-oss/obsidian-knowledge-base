---
aliases: [SPI验证, SPI checklist]
tags: [Protocol, SPI, Verification, 核心]
created: 2026-09-27
updated: 2026-09-27
---

# 01-SPI验证要点

> [!abstract] 用途
> SPI slave/master 验证的用例矩阵与检查清单，配合 [[03-Protocol/SPI/00-SPI]] 协议说明与 [[08-Projects/01-SPI验证/00-项目概述|SPI 项目]]。

---

## 1. 四种模式（CPOL × CPHA）

| 模式 | CPOL | CPHA | 采样边 |
|------|------|------|--------|
| 0 | 0 | 0 | 第一沿采样（上升） |
| 1 | 0 | 1 | 第二沿采样 |
| 2 | 1 | 0 | 第一沿（下降） |
| 3 | 1 | 1 | 第二沿 |

> [!warning] 模式 0/3 最易混
> 时钟空闲电平 + 采样沿必须与 DUT 配置一致；激励里建议 `randc` 扫 4 种。

---

## 2. 帧格式参数

| 参数 | 范围 | 检查 |
|------|------|------|
| 字长 | 4/8/12/16/24/32 | 边界 1 与 max |
| MSB/LSB first | 位序 | 对照手册 |
| 帧间隔 | CS 高电平时间 | 最小 t_css |
| CS 片选 | 早/晚拉 | setup/hold |
| 双向 | 3-wire / 4-wire | 方向切换 |

---

## 3. 用例矩阵

| # | 类别 | 用例 |
|---|------|------|
| S1 | 模式 | CPOL/CPHA 四种 |
| S2 | 字长 | 边界与典型 |
| S3 | 连续帧 | back-to-back，CS 保持/拉高再下 |
| S4 | 读写 | write / read / write-read |
| S5 | 注入 | 超时、多收/少收一拍 |
| S6 | 中断 | RX 完成、FIFO 满/空 |
| S7 | FIFO | 水位阈值、溢出保护 |
| S8 | 配置中途改 | 改 mode/字长后下一帧生效 |
| S9 | 复位 | 传输中复位 |
| S10 | 时钟 | 分频边角、极慢/快 SCK |

---

## 4. 关键检查

```text
✓ MOSI/MISO 数据与 golden 移位结果一致
✓ 位序（MSB/LSB）
✓ 帧长度正好 N bits
✓ CS setup/hold（相对 SCK 边）
✓ 状态/中断寄存器 W1C
✓ FIFO 读指针
✓ 模式切换后无残留位
```

### 移位参考模型（MSB first）

```systemverilog
function bit [31:0] golden_shift(bit [31:0] din, int bits, bit msb_first);
  if (msb_first) return din >> (32-bits);
  else           return din;
endfunction
```

---

## 5. SVA 断言

```systemverilog
// CS 拉低期间 SCK 允许翻转；CS 高时无有效采样
a_cs_idle: assert property (@(posedge sck) cs |-> 1'b1);
// 字长：CS 周期内 SCK 计数
property p_bitcnt;
  @(posedge sck) disable iff (cs)
  1;
endproperty
```

更常见用 **事务级 monitor** 数 bit，SVA 只抓协议稳定：

```systemverilog
a_mosi_stable: assert property (@(posedge sck) !$isunknown(mosi));
```

---

## 6. 覆盖

```systemverilog
cp_cpol  : coverpoint cfg.cpol;
cp_cpha  : coverpoint cfg.cpha;
cp_bits  : coverpoint cfg.bits { bins t[] = {4,8,16,32}; }
x_mode   : cross cp_cpol, cp_cpha;
x_mode_bits : cross x_mode, cp_bits;
cp_fifo_level : coverpoint fifo_lvl;
```

---

## 7. 常见 bug 列表

| 症状 | 可能原因 |
|------|----------|
| 数据错半位 | 采样沿/CPHA 错 |
| 连续帧错位 | CS 未真正分帧 |
| 只第一帧对 | 移位寄存器未复位 |
| FIFO 偶错 | 水位/满标志迟一拍 |
| 中断丢 | W1C 与硬件置位同拍 |

---

## 相关

- [[03-Protocol/SPI/00-SPI]]
- [[08-Projects/01-SPI验证/03-测试用例]]
- [[08-Projects/01-SPI验证/04-覆盖率模型]]
- [[05-Verification/16-参考模型与Scoreboard]]

---

*更新: 2026-09-27*
