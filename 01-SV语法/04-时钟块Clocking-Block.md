---
tags: [SV, SystemVerilog, 验证, 时序]
created: 2026-04-17
updated: 2026-06-02
---

# 时钟块 Clocking Block

> SystemVerilog 中用于解决信号采样和驱动时序问题的关键机制

---

## 一、为什么需要 Clocking Block

**问题：** 在验证环境中，信号的建立时间（setup）和保持时间（hold）会影响采样准确性。

```
         ┌─────────────────────────────────┐
         │         DUT 输出信号             │
         │                                  │
    ─────┘                                  └─────────
              ↑                    ↑
         setup 不够            hold 不够
         采到旧值              采到毛刺
```

**解决方案：** Clocking Block 在时钟边沿前后自动添加偏移（skew），确保采样和驱动在正确的时间点。

---

## 二、基本语法

### 2.1 定义

```systemverilog
interface spi_if(input logic clk);

    logic cs_n, sclk, mosi, miso;

    // 输入 clocking block（monitor 采样用）
    clocking mon_cb @(posedge clk);
        default input #1step output #0;  // 输入在时钟边沿前采样
        input  cs_n, sclk, mosi, miso;
    endclocking

    // 输出 clocking block（driver 驱动用）
    clocking drv_cb @(posedge clk);
        default input #0 output #1step;  // 输出在时钟边沿后驱动
        output cs_n, sclk, mosi;
        input  miso;
    endclocking

endinterface
```

### 2.2 Skew 参数

| 参数 | 含义 | 典型值 |
|------|------|--------|
| `input #N` | 在时钟边沿前 N 个时间单位采样 | `#1step`, `#1`, `#0` |
| `output #N` | 在时钟边沿后 N 个时间单位驱动 | `#0`, `#1step`, `#1` |

**常用 skew 组合：**

```systemverilog
// 保守采样（推荐）
clocking cb @(posedge clk);
    default input #1step output #0;
endclocking

// 零偏移
clocking cb @(posedge clk);
    default input #0 output #0;
endclocking

// 明确偏移
clocking cb @(posedge clk);
    default input #1 output #1;
endclocking
```

---

## 三、采样与驱动行为

### 3.1 采样（input）

```systemverilog
// 通过 clocking block 采样
@(posedge clk);                    // 等待时钟边沿
data = vif.mon_cb.cmd_data_o;      // 采样值（带 skew）
```

**采样时机：** 时钟边沿 - skew

```
                    时钟边沿
                       ↓
    ──────────────────┐
    skew              │
    ←──→              │
    采样点            │
       ↓              │
    ───┘              └──────────────
```

### 3.2 驱动（output）

```systemverilog
// 通过 clocking block 驱动
vif.drv_cb.cs_n <= 1'b0;           // 驱动值（带 skew）
@(posedge clk);                    // 等待时钟边沿
```

**驱动时机：** 时钟边沿 + skew

```
                    时钟边沿
                       ↓
                       └──────────────
                       │
                       │  skew
                       │  ←──→
                       │     驱动点
                       │        ↓
                       └────────┘
```

---

## 四、关键规则

### 4.1 不要混用 clocking block 和直接信号访问

**错误写法：**
```systemverilog
// ❌ 混用 mon_cb 和直接时钟等待
forever begin
    trans.data = vif.mon_cb.data;   // 用 mon_cb 采样
    @(posedge vif.clk);              // 等实际时钟沿
    if (vif.mon_cb.vld == 0) break; // 用 mon_cb 判断
end
```

**问题：** `mon_cb` 的 skew 和 `@(posedge vif.clk)` 不一致，导致采样时序错位。

**正确写法：**
```systemverilog
// ✅ 统一用 clocking block
forever begin
    trans.data = vif.mon_cb.data;   // 用 mon_cb 采样
    @(vif.mon_cb);                   // 用 mon_cb 等待
    if (vif.mon_cb.vld == 0) break; // 用 mon_cb 判断
end
```

### 4.2 不要在 clocking block 事件后立即采样

**错误写法：**
```systemverilog
// ❌ 等待后立即采样（可能采到旧值）
@(posedge clk);
data = vif.signal;  // signal 可能还没更新
```

**正确写法：**
```systemverilog
// ✅ 用 clocking block 采样
@(vif.mon_cb);
data = vif.mon_cb.signal;  // 保证采样时序正确
```

### 4.3 理解 `@(vif.mon_cb)` vs `@(posedge vif.clk)`

| 写法 | 含义 | 采样点 |
|------|------|--------|
| `@(vif.mon_cb)` | 等待 clocking block 事件 | 时钟边沿 - skew |
| `@(posedge vif.clk)` | 等待实际时钟边沿 | 时钟边沿 |

**区别：** `@(vif.mon_cb)` 会自动应用 skew，`@(posedge vif.clk)` 不会。

---

## 五、常见陷阱

### 5.1 多采一个无效数据

**场景：** monitor 采样时，永远多采一个 0x00。

**原因：** 混用 `mon_cb` 和 `@(posedge vif.clk_lf)`，导致在 vld=0 时仍然采样。

**解决：** 统一用 `@(vif.mon_cb)` 等待。

```systemverilog
// ✅ 正确写法
forever begin
    @(vif.mon_cb);                          // 先等待
    if (vif.mon_cb.cmd_data_vld_o == 1'b0) // 再判断
        break;
    trans.cmd_o.push_back(vif.mon_cb.cmd_data_o);  // 最后采样
end
```

### 5.2 采样到毛刺

**场景：** 信号在时钟边沿附近有毛刺，被采样到。

**原因：** skew 设置不当，采样点落在毛刺区域。

**解决：** 使用 `#1step` skew，在时钟边沿前一个时间步采样。

```systemverilog
clocking cb @(posedge clk);
    default input #1step;  // 在时钟边沿前采样，避免毛刺
endclocking
```

### 5.3 驱动时序冲突

**场景：** driver 和 DUT 同时驱动同一信号。

**原因：** driver 使用 `@(posedge clk)` 驱动，但 DUT 也在时钟边沿驱动。

**解决：** 使用 `output #1` skew，在时钟边沿后驱动。

```systemverilog
clocking drv_cb @(posedge clk);
    default output #1;  // 在时钟边沿后驱动，避免冲突
endclocking
```

---

## 六、最佳实践

### 6.1 Monitor 采样模式

```systemverilog
// 推荐模式：先等待，再判断，最后采样
forever begin
    @(vif.mon_cb);                                    // 1. 等待时钟块事件
    if (vif.mon_cb.cmd_data_vld_o == 1'b1) begin     // 2. 判断有效
        trans.data = vif.mon_cb.cmd_data_o;           // 3. 采样数据
    end
end
```

### 6.2 Driver 驱动模式

```systemverilog
// 推荐模式：先赋值，再等待
vif.drv_cb.cs_n <= 1'b0;   // 1. 赋值（在当前 skew 时间点驱动）
@(vif.drv_cb);               // 2. 等待下一个时钟块事件
vif.drv_cb.mosi <= data;    // 3. 继续驱动
```

### 6.3 Skew 选择建议

| 场景 | 推荐 skew | 原因 |
|------|-----------|------|
| Monitor 采样 | `input #1step` | 在时钟边沿前采样，避免毛刺 |
| Driver 驱动 | `output #0` 或 `output #1` | 在时钟边沿后驱动，避免冲突 |
| 调试/观察 | `input #0` | 直接观察时钟边沿的值 |

---

## 七、完整示例

```systemverilog
interface spi_if(input logic clk, input logic rst_n);

    logic cs_n, sclk, mosi, miso;
    logic cmd_data_vld_o;
    logic [7:0] cmd_data_o;

    // Monitor clocking block
    clocking mon_cb @(posedge clk);
        default input #1step output #0;
        input  cs_n, sclk, mosi, miso;
        input  cmd_data_vld_o, cmd_data_o;
    endclocking

    // Driver clocking block
    clocking drv_cb @(posedge clk);
        default input #0 output #1;
        output cs_n, sclk, mosi;
        input  miso;
    endclocking

    // Modport
    modport MON(clocking mon_cb, input clk, rst_n);
    modport DRV(clocking drv_cb, input clk, rst_n);

endinterface

// Monitor 使用示例
class spi_monitor extends uvm_monitor;
    virtual spi_if vif;

    task run_phase(uvm_phase phase);
        forever begin
            @(vif.mon_cb);  // 统一用 mon_cb 等待
            if (vif.mon_cb.cmd_data_vld_o) begin
                // 采样数据
            end
        end
    endtask
endclass
```

## 相关链接

- [[01-SV语法/03-寄存器与锁存器|寄存器与锁存器]] - 寄存器与锁存器的区别
- [[01-SV语法/05-SVA断言|SVA 断言]] - SystemVerilog 断言
- [[01-SV语法/00-入门|SystemVerilog 入门]] - SystemVerilog 基础
- [[00-总索引]] - 返回总索引
