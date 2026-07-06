# I2C 协议

> Inter-Integrated Circuit - 双线串行总线

## 📋 协议概述

### 特性
- 两根信号线：SCL(时钟)、SDA(数据)
- 主从架构，支持多主多从
- 开漏输出，需要上拉电阻
- 速度：标准模式(100KHz)、快速模式(400KHz)、高速模式(3.4MHz)

---

## 🔌 信号定义

| 信号 | 方向 | 说明 |
|------|------|------|
| SCL | Master→All | 串行时钟 |
| SDA | Bidirectional | 串行数据 |
| SCL | Slave Input | 从机接收时钟 |

### 电路结构

#### 开漏输出 + 上拉电阻

```
         VCC (3.3V/5V)
            │
       ┌────┴────┐
       │   Rpu   │  上拉电阻 (4.7KΩ~10KΩ)
       └────┬────┘
            │
     ┌──────┼──────┐
     │             │
  ┌──┴──┐      ┌──┴──┐    SDA/SCL
  │ MOS │      │ MOS │     └─→ 设备IO
  │     │      │     │
  └─┬──┘      └──┬──┘
    │             │
    └──────┬─────┘
           │
         GND
```

- **开漏/开集极输出**: 输出级MOSFET/晶体管只驱动低电平，高电平由上拉电阻提供
- **线与逻辑**: 多个设备可同时输出低电平，实现"线与"仲裁
- **上拉电阻选择**:
  - 速度快→小电阻(如4.7KΩ)
  - 功耗低→大电阻(如10KΩ)
  - 总线电容400pF以内

#### 基本结构图 (多主多从)

```
    ┌─────────┐     ┌─────────┐     ┌─────────┐
    │ Master1 │     │ Master2 │     │  MasterN  │
    │   MCU   │     │   MCU   │     │    GPU    │
    └────┬────┘     └────┬────┘     └────┬────┘
         │               │               │
         │  SCL  ════════╪═══════════════╪══════
         │  SDA  ════════╪═══════════════╪══════
         │               │               │
    ┌────┴────┐    ┌────┴────┐    ┌────┴────┐
    │ Slave1  │    │ Slave2  │    │ SlaveN   │
    │  EEPROM │    │  Sensor │    │   RTC    │
    └─────────┘    └─────────┘    └─────────┘
```

- **主设备(Master)**: 发起通信、产生时钟SCL
- **从设备(Slave)**: 响应主设备、被寻址
- **地址唯一性**: 所有从设备必须有唯一地址
- **总线竞争**: 多主设备时通过仲裁决定主控权

---

## 📊 传输格式

### 基本结构

```
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬────┬─────┐
│START│ 7位地址 │ R/W │ ACK │ 8位数据 │ ACK │ 8位数据 │ ACK │STOP│
└─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴────┴─────┘
```

### 地址格式

```
┌──────────────────────────────────────┐
│  7位设备地址   │ R/W │               │
│  [6:1] [0]    │     │               │
│  芯片地址  方向 │               │
└──────────────────────────────────────┘
```

---

## ⏱️ 时序图

### 写操作

```
SDA  ───┐    ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐    ┌──
         └──┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ ┌──┘

SCL  ─────┐  ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌──
          └──┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └──┘

        START  A6  A5  A4  A3  A2  A1  A0  W  ACK
```

### 读操作

```
SDA  ───┐    ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐    ┌──
         └──┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ ┌──┘

SCL  ─────┐  ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌──
          └──┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └──┘

        START  A6  A5  A4  A3  A2  A1  A0  R  ACK
```

---

## 📝 UVM验证模型

### I2C Transaction

```systemverilog
class i2c_transaction extends uvm_sequence_item;
    typedef enum {WRITE, READ} rw_e;

    rand rw_e read_write;
    rand bit [6:0] addr;
    rand bit [7:0] data[];
    int delay_cycles;

    `uvm_object_utils_begin(i2c_transaction)
        `uvm_field_enum(rw_e, read_write, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_array_int(data, UVM_ALL_ON)
    `uvm_object_utils_end

    constraint data_size_c {
        data.size() inside {[1:256]};
    }
endclass
```

### I2C Driver

```systemverilog
class i2c_driver extends uvm_driver #(i2c_transaction);
    virtual i2c_if vif;

    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_transaction(i2c_transaction tr);
        vif.sda_drive(1'b1);
        vif.scl_drive(1'b1);

        // START
        @(posedge vif.scl);
        vif.sda_drive(1'b0);
        @(negedge vif.scl);

        // Address + R/W
        drive_byte({tr.addr, tr.read_write});

        // ACK
        drive_ack();

        // Data
        foreach (tr.data[i]) begin
            drive_byte(tr.data[i]);
            drive_ack();
        end

        // STOP
        @(negedge vif.scl);
        vif.sda_drive(1'b0);
        @(posedge vif.scl);
        vif.sda_drive(1'b1);
    endtask

    task drive_byte(bit [7:0] data);
        for (int i = 7; i >= 0; i--) begin
            @(negedge vif.scl);
            vif.sda_drive(data[i]);
        end
    endtask
endclass
```

---

## ✅ 验证要点

### 1. 基础功能
- [ ] START/STOP条件
- [ ] 地址识别
- [ ] 读写切换
- [ ] ACK/NACK响应

### 2. 数据传输
- [ ] 单字节读写
- [ ] 多字节连续读写
- [ ] 寄存器读写

### 3. 边界条件
- [ ] 从机不应答
- [ ] 总线仲裁
- [ ] 时钟 stretching
- [ ] 重复START

### 4. 异常场景
- [ ] 总线忙检测
- [ ] 超时处理
- [ ] 错误恢复

---

## 🔗 相关协议

- [[../AXI/00-AXI]] - AXI总线协议
- [[00-SPI]] - SPI协议
- [[00-UART]] - UART协议

---

tags: #Protocol #I2C #Interface
related: [[00-总索引]], [[../AXI/00-AXI]], [[00-SPI]]
