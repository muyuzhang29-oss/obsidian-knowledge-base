---
tags: [Protocol, APB, AMBA, 并行总线]
---

# APB 协议

> Advanced Peripheral Bus - 简单、低功耗的外设总线

## 协议概述

APB是AMBA协议中最简单的总线，用于连接低速外设。

### 特性
- 简单协议，无需仲裁
- 两周期握手
- 低功耗设计
- 无突发传输

---

## 信号定义

### 基本信号

| 信号 | 方向 | 说明 |
|------|------|------|
| PCLK | Input | 时钟 |
| PRESETn | Input | 复位（低有效）|
| PADDR | Input | 地址 |
| PSEL | Input | 选择信号 |
| PENABLE | Input | 使能 |
| PWRITE | Input | 写（1）/读（0）|
| PWDATA | Input | 写数据 |
| PRDATA | Output | 读数据 |
| PREADY | Output | 就绪（APB3+）|
| PSLVERR | Output | 错误响应（APB3+）|

---

## 传输时序

### APB2（基本传输）

```
PCLK     ───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐
              └───┘   └───┘   └───┘   └───┘

PSEL     ────┐   ╔═════════════════════════════╗───
              └───┘                             └───

PENABLE                  ┌─────────────────────┐───
                         │                     │
                         └─────────────────────┘

PADDR    ────────A──────────────────────────────
             地址

PWDATA   ────────D──────────────────────────────
             数据
```

### 时序说明

1. **IDLE**: 总线空闲
2. **SETUP**: PSEL=1, PENABLE=0, 发送地址和控制
3. **ACCESS**: PSEL=1, PENABLE=1, 数据传输

---

## APB3 新增特性

### 等待状态

```verilog
// APB3: PREADY允许插入等待周期
always @(posedge PCLK) begin
    if (!PRESETn)
        state <= IDLE;
    else
        case (state)
            IDLE: if (PSEL) state <= SETUP;
            SETUP: state <= ACCESS;
            ACCESS: if (PREADY) state <= IDLE;
        endcase
end
```

### 错误响应

```verilog
// PSLVERR: 从机报告错误
assign PSLVERR = (state == ERROR);
```

---

## UVM验证模型

### APB Transaction

```verilog
class apb_transaction extends uvm_sequence_item;
    rand bit [31:0] addr;
    rand bit [31:0] data;
    rand bit write;
    bit error;

    `uvm_object_utils_begin(apb_transaction)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(write, UVM_ALL_ON)
    `uvm_object_utils_end
endclass
```

### APB Driver

```verilog
class apb_driver extends uvm_driver #(apb_transaction);
    virtual apb_if vif;

    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            drive_transfer(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_transfer(apb_transaction req);
        @(posedge vif.presetn);
        vif.psel    <= 1'b1;
        vif.paddr   <= req.addr;
        vif.pwrite  <= req.write;
        vif.pwdata  <= req.data;
        @(posedge vif.pclk);
        vif.penable <= 1'b1;
        @(posedge vif.pclk);
        if (!req.write)
            req.data = vif.prdata;
        @(posedge vif.pclk);
        vif.psel    <= 1'b0;
        vif.penable <= 1'b0;
    endtask
endclass
```

---

## 与AXI对比

| 特性 | APB | AXI |
|------|-----|-----|
| 突发传输 | 无 | 支持 |
| 等待周期 | 支持 | 支持 |
| 独立通道 | 否 | 是 |
| 带宽 | 低 | 高 |
| 复杂度 | 低 | 高 |

---

## 使用场景

- **适合**: 简单外设(UART, GPIO, Timer)
- **不适合**: 高带宽需求(DDR, Ethernet)

---

tags: #Protocol #APB #AMBA #核心

## 相关链接

- [[03-Protocol/00-协议索引|协议索引]] - 返回协议索引
- [[03-Protocol/AXI/00-AXI|AXI]] - AXI 协议
- [[02-UVM/00-入门|UVM 入门]] - UVM 验证方法学
- [[00-总索引]] - 返回总索引
