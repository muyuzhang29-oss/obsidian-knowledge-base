---
tags: [UVM, Verification, 模板, Driver, 时序, 陷阱]
created: 2026-04-17
updated: 2026-06-02
---

# Driver 握手时序陷阱

> Driver 握手信号（vld/rdy）的采样与驱动时序问题总结

---

## 一、握手协议回顾

标准 vld/rdy 握手规则：

```
时钟上升沿同时采样 vld_i 和 rdy_o：
  - vld_i == 1 && rdy_o == 1 → 传输完成
  - 其他情况 → 等待
```

---

## 二、错误模式

### 2.1 错误：`@(posedge clk iff rdy)`

```systemverilog
// ❌ 错误写法
@(posedge vif.clk_lf iff vif.cmd_data_rdy_o == 1'b1);
vif.drv_cb.cmd_data_vld_i <= 1'b1;
```

**问题：**
- `iff` 在时钟沿检查 `rdy_o`，但 `rdy_o` 是寄存器输出，比时钟沿晚 ~0.01ns 更新
- 时钟沿时刻 `rdy_o` 还是旧值，`iff` 判断不准
- 第一拍数据丢失：`vld_i` 在 `rdy_o` 拉高后的第二拍才生效

### 2.2 错误：先等 rdy 再拉 vld

```systemverilog
// ❌ 错误写法：先等 rdy，再拉 vld
wait (vif.cmd_data_rdy_o == 1'b1);
@(posedge vif.clk);
vif.drv_cb.cmd_data_vld_i <= 1'b1;
```

**问题：**
- 等到 `rdy_o=1` 后再拉 `vld_i`，中间浪费一拍
- DUT 在下一拍可能已经拉低 `rdy_o`（缓冲区满）
- 连续传输时每笔数据间隔两拍，效率低

### 2.3 错误：混用 `drv_cb` 和直接信号

```systemverilog
// ❌ 错误写法
@(posedge vif.clk);                    // 等实际时钟沿
vif.drv_cb.cmd_data_vld_i <= 1'b1;    // 用 drv_cb 驱动
```

**问题：**
- `@(posedge clk)` 和 `@(vif.drv_cb)` 的时序不一致
- `drv_cb` 有 output skew，直接等时钟沿没有
- 导致驱动时序错位

### 2.4 错误：拉低 vld 后多等一拍

```systemverilog
// ❌ 不必要的等待
vif.drv_cb.cmd_data_vld_i <= 1'b0;
@(vif.drv_cb);  // 多余的一拍
```

**问题：**
- 连续传输时每笔数据后多一个空拍
- 降低吞吐量
- 只在 burst 结束后需要拉低 `vld_i`

---

## 三、正确模式

### 3.1 标准 do...while 握手

```systemverilog
// ✅ 正确写法
virtual task drive_bytes(input bit[9:0] data_i, input bit[3:0] state);
    vif.drv_cb.cmd_data_vld_i <= 1'b1;      // 1. 先拉高 vld
    vif.drv_cb.drv_state_i <= state;          // 2. 驱动数据
    do begin
        @(vif.drv_cb);                        // 3. 等待时钟沿
    end while (vif.drv_cb.cmd_data_rdy_o == 1'b0);  // 4. 检查 rdy
endtask
```

**为什么正确：**
- `vld_i` 提前拉高，DUT 在任何时钟沿都能看到 `vld=1`
- `do...while` 先等时钟沿再检查 `rdy_o`，保证采样到稳定值
- 连续传输时没有空拍，效率最高

### 3.2 连续 Burst 传输

```systemverilog
// ✅ 连续传输多个数据
foreach (payload[i]) begin
    drive_bytes(payload[i], state);  // vld 保持高，连续握手
end
// burst 结束后拉低 vld
vif.drv_cb.cmd_data_vld_i <= 1'b0;
```

**关键点：**
- 中间不需要拉低 `vld_i`
- 只在整个 burst 结束后才拉低
- DUT 通过 `rdy_o` 控制反压

---

## 四、时序图对比

### 4.1 错误模式（每笔数据 2 拍）

```
clk     ─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─
          │ │ │ │ │ │ │ │ │ │
rdy_o   ──────┘ └─────┘ └─────
vld_i   ──┘ └───┘ └───┘ └─────
data    ──X===X───X===X───X===X
          ↑   ↑   ↑   ↑
          等  发  等  发     ← 每笔数据需要2拍
```

### 4.2 正确模式（每笔数据 1 拍）

```
clk     ─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─
          │ │ │ │ │ │ │ │ │ │
rdy_o   ──────┘ └─────┘ └─────
vld_i   ──────────────────────  ← 保持高
data    ──X===X===X===X===X===
            ↑   ↑   ↑   ↑
            发  发  发  发     ← 每笔数据1拍
```

---

## 五、rdy_o 寄存器输出问题

### 5.1 问题描述

DUT 的 `rdy_o` 如果是寄存器输出，存在 0.01ns 延迟：

```
clk 上升沿 → DUT 内部判断缓冲区满 → 0.01ns 后 rdy_o 拉低
```

这导致 driver 在时钟沿看到的 `rdy_o` 是旧值，以为 DUT 可以接收，但实际上 DUT 已经满了。

### 5.2 解决方案

| 方案 | 说明 | 推荐 |
|------|------|------|
| DUT `rdy_o` 改组合逻辑 | 根本解决 | ✅ 最优 |
| DUT 提前预判满状态 | 不改接口 | ✅ 次优 |
| driver 多等一拍确认 | 不改 DUT | ⚠️ 降低效率 |

**DUT 侧正确实现：**

```systemverilog
// ✅ rdy_o 用组合逻辑
assign cmd_data_rdy_o = (buf_count < MAX_DEPTH);
```

---

## 六、最佳实践总结

| 规则 | 说明 |
|------|------|
| 统一用 `vif.drv_cb` | 不要混用 `drv_cb` 和直接信号 |
| 用 `@(vif.drv_cb)` 等待 | 不要用 `@(posedge clk)` |
| `do...while` 握手 | 先拉 vld，再等 rdy |
| 不要多加空拍 | 连续传输时 vld 保持高 |
| burst 结束再拉低 vld | 中间不要断开 |
| `rdy_o` 应为组合逻辑 | 寄存器输出会导致时序问题 |

---

*创建时间: 2026-06-01*
