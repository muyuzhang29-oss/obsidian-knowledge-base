---
tags: [Protocol, UART, 串行外设]
---

# UART 协议

> Universal Asynchronous Receiver/Transmitter - 异步串行通信

## 📋 协议概述

### 特性
- 两根信号线：TX(发送)、RX(接收)
- 异步传输，无需时钟线
- 起始位+数据位+校验位+停止位
- 常用波特率：9600/115200/921600

---

## 🔌 信号定义

| 信号 | 方向 | 说明 |
|------|------|------|
| TX | Output | 发送数据 |
| RX | Input | 接收数据 |
| RTS | Output | 请求发送(可选) |
| CTS | Input | 清除发送(可选) |

---

## 📊 数据帧格式

### 标准帧结构

```
┌──────┬────────┬─────┬──────┬──────┐
│START │  Data  │ Parity│ STOP │ STOP │
│ (1b) │ (5-9b) │(opt)│ (1b) │(opt) │
└──────┴────────┴─────┴──────┴──────┘
   0      D0-D8    P/E    1     1
```

### 常用配置

| 参数 | 常用值 | 说明 |
|------|--------|------|
| 波特率 | 9600,115200 | 比特/秒 |
| 数据位 | 8 | 典型值 |
| 停止位 | 1/2 | 停止位宽度 |
| 校验位 | None/Odd/Even | 校验方式 |
| 流控 | None/RTS/CTS | 硬件流控 |

---

## ⏱️ 时序图

### 发送时序

```
        1    2    3    4    5    6    7    8
TX  ──┐ ──┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┐ ──
     │ │D0│D1│D2│D3│D4│D5│D6│D7│P│ │ │
     └─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┘ └─

     ───空闲───START─┤数据─┤P─┤STOP─空闲
```

### 接收采样

```verilog
// 接收状态机
IDLE:    if (!uart_rx) state <= START;
START:   if (baud_tick) state <= DATA;
DATA:    if (bit_cnt==7 && baud_tick) state <= PARITY;
PARITY:  if (baud_tick) state <= STOP;
STOP:    if (baud_tick) state <= IDLE;
```

---

## 📝 UVM验证模型

### UART Transaction

```systemverilog
class uart_transaction extends uvm_sequence_item;
    typedef enum {NONE, ODD, EVEN} parity_e;

    rand bit [7:0] data;
    rand parity_e parity_type;
    rand int baud_rate;

    `uvm_object_utils_begin(uart_transaction)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_enum(parity_e, parity_tpe, UVM_ALL_ON)
    `uvm_object_utils_end

    function bit calculate_parity();
        case (parity_type)
            NONE: return 0;
            ODD: return ^data;    // 奇校验
            EVEN: return ~^data;  // 偶校验
        endcase
    endfunction
endclass
```

### UART Monitor

```systemverilog
class uart_monitor extends uvm_monitor;
    virtual uart_if vif;
    uvm_analysis_port #(uart_transaction) ap;

    typedef enum {IDLE, START, DATA, PARITY, STOP} state_e;
    state_e state;

    function void build_phase(uvm_phase phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual uart_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "vif not found")
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] rx_data;
        bit parity_bit;

        forever begin
            @(posedge vif.clock);
            case (state)
                IDLE: begin
                    if (!vif.rx) begin  // 检测起始位
                        state <= START;
                        `uvm_info("MON", "Start bit detected", UVM_LOW)
                    end
                end

                START: begin
                    @(posedge vif.clock);
                    if (vif.rx == 0) begin
                        state <= DATA;
                        rx_data = 0;
                    end else
                        state <= IDLE;
                end

                DATA: begin
                    for (int i = 0; i < 8; i++) begin
                        @(posedge vif.clock);
                        rx_data[i] = vif.rx;
                    end
                    state <= PARITY;
                end

                PARITY: begin
                    @(posedge vif.clock);
                    parity_bit = vif.rx;
                    state <= STOP;
                end

                STOP: begin
                    @(posedge vif.clock);
                    if (vif.rx == 1) begin  // 停止位
                        uart_transaction tr;
                        tr = uart_transaction::type_id::create("tr");
                        tr.data = rx_data;
                        ap.write(tr);
                        `uvm_info("MON", $sformatf("Received: 0x%h", rx_data), UVM_LOW)
                    end
                    state <= IDLE;
                end
            endcase
        end
    endtask
endclass
```

### UART Scoreboard

```systemverilog
class uart_scoreboard extends uvm_scoreboard;
    uvm_analysis_export #(uart_transaction) tx_export;
    uvm_analysis_export #(uart_transaction) rx_export;

    uvm_tlm_analysis_fifo #(uart_transaction) expected_fifo;
    uvm_tlm_analysis_fifo #(uart_transaction) actual_fifo;

    function void check_phase(uvm_phase phase);
        if (expected_fifo.used() != 0)
            `uvm_error("SB", "Unexpected transactions in expected FIFO");
        if (actual_fifo.used() != 0)
            `uvm_error("SB", "Unexpected transactions in actual FIFO");
    endfunction
endclass
```

---

## ✅ 验证要点

### 基础功能
- [ ] 正确接收字节
- [ ] 起始位检测
- [ ] 停止位验证
- [ ] 波特率精度

### 校验功能
- [ ] 奇偶校验正确
- [ ] 校验错误检测
- [ ] 无校验模式

### 边界条件
- [ ] 连续字节接收
- [ ] 中间空闲
- [ ] 波特率切换
- [ ] 数据完整性

### 异常场景
- [ ] 帧错误
- [ ] 校验错误
- [ ] FIFO溢出
- [ ] 超时检测

---

## 🔧 常用脚本

### Python Uart 模拟

```python
import serial
import time

class UartComm:
    def __init__(self, port, baudrate=115200):
        self.ser = serial.Serial(port, baudrate, timeout=1)

    def send(self, data):
        self.ser.write(bytes([data]))
        time.sleep(0.01)

    def receive(self, num_bytes=1):
        return self.ser.read(num_bytes)

    def close(self):
        self.ser.close()

# 使用
uart = UartComm('COM3', 115200)
uart.send(0x55)
response = uart.receive()
uart.close()
```

---

## 🔗 相关链接

- [[03-Protocol/00-协议索引|协议索引]] - 返回协议索引
- [[03-Protocol/I2C/00-I2C|I2C]] - I2C 总线协议
- [[03-Protocol/SPI/00-SPI|SPI]] - SPI 协议
- [[00-总索引]] - 返回总索引

---

tags: #Protocol #UART #Async
