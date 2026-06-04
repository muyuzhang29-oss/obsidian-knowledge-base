---
tags: [Protocol, SPI, 串行外设]
---

# SPI 协议

> Serial Peripheral Interface - 高速全双工同步总线

## 📋 协议概述

SPI（Serial Peripheral Interface）总线是主要应用于嵌入式系统内部通信的串行同步传输总线协议。通常为四线制的SPI总线支持全双工通信。

SPI最初由Motorola在2000年提出，Motorola所定义的SPI标准为业界广泛引用，但**业界没有统一的SPI标准**，不同半导体公司的实施细节可能有所不同，这些区别体现在寄存器设置、信号定义、数据格式等。具体应用需要参考特定器件手册。

### 核心特性
- **主从架构**：一个主设备（Master），多个从设备（Slave）
- **全双工同步传输**：MOSI和MISO同时传输数据
- **四线制**：SCLK、MOSI、MISO、SS（部分应用可缩减到三线）
- **高速传输**：速度可达几十MHz甚至100MHz以上
- **无内置寻址机制**：通过片选信号（SS/CS）选择从设备
- **时钟控制通信**：主设备通过对SCLK时钟线的控制完成对通讯的控制
- **支持暂停**：当没有时钟跳变时，从设备不采集或传送数据

### 数据收发机制
- 只有一侧（Master）产生时钟信号
- Master必须**事先知道**Slave何时需要返回数据以及返回多少数据（与异步串口不同）
- SPI通常用于与具有**特定命令结构**的传感器通信
- 全双工模式下，可在发送新请求的同时接收上一次请求的响应

---

## 🔌 信号定义

| 信号 | 全称 | 方向 | 说明 |
|------|------|------|------|
| SCLK | Serial Clock | Master→All | 串行时钟信号，由主设备产生 |
| MOSI | Master Output Slave In | Master→Slave | 主发从收数据线 |
| MISO | Master Input Slave Out | Slave→Master | 从发主收数据线 |
| SS/CS | Slave Select / Chip Select | Master→Slave | 片选信号，低电平有效 |

### 注意事项
- **方向定义**：MISO方向为从设备到主设备，其余三个信号均为主设备到从设备
- **高阻态要求**：未被选中从设备的MISO必须表现为**高阻状态（Hi-Z）**，以避免数据传输错误
- **双向模式**：单个数据管脚可支持双向模式，主设备的MOSI和从设备的MISO作为双向IO
- **模式错误检测**：如果设置SS作为从设备的片选信号，则它不能用于多设备应用的模式错误检测

---

## 🔗 硬件连接

### 一主一从连接

```
┌────────┐                    ┌────────┐
│ Master │                    │ Slave  │
│        │  SCLK ───────────→ │ SCLK   │
│        │  MOSI ───────────→ │ MOSI   │
│        │  MISO  ←────────── │ MISO   │
│        │  SS   ───────────→ │ SS     │
└────────┘                    └────────┘
```

### 一主多从：独立片选模式

每个从设备都需要单独的片选信号，主设备每次只能选择其中一个从设备进行通信。

```
                    ┌─────────┐
         ┌────────→│ SS      │  Slave 1
         │         │ MISO    │←────────┐
         │ SCLK ───┤         │         │
         │ MOSI ───┤         │         │ MISO (复用)
Master   │         └─────────┘         │
         │         ┌─────────┐         │
         ├────────→│ SS      │  Slave 2│
         │         │ MISO    │←────────┘
         │ SCLK ───┤         │
         │ MOSI ───┤         │
         │         └─────────┘
```

**关键要点**：
- 如果片选信号过多，可使用**译码器**产生所有的片选信号
- 同时拉低多个SS会导致MISO线数据冲突（乱码）
- 所有从设备的SCK、MOSI、MISO都是连在一起的

### 一主多从：菊花链模式 (Daisy Chain)

数据信号经过主从设备所有的移位寄存器构成闭环。

```
Master ──MOSI──→ [Slave1] ──SO→SI──→ [Slave2] ──SO→SI──→ [Slave3]
  SCLK ────────────────────────────────────────────────────────
  SS   ────────────────────────────────────────────────────────
  MISO ←─────────────────────────────────────────────────────── (可选)
```

**关键要点**：
- 片选和时钟同时接到所有从设备
- 主设备需发送**足够长的数据**以确保数据送达到所有从设备
- 第一个数据需（移位）到达菊花链中**最后一个从设备**
- 常用于仅需主设备发送数据而不需要接收返回数据的场合（如LED驱动器）
- 如需接收返回数据，需连接主设备的MISO形成闭环
- 发送足够多的接收指令以确保数据（移位）送达主设备

---

## ⚙️ 工作模式

SPI通信有4种不同的工作模式，不同的从设备在出厂时配置的模式通常是**固定不可改变**的。通信双方必须工作在**同一模式**下。

模式通过**CPOL（时钟极性）**和**CPHA（时钟相位）**配置：

### 时钟极性 CPOL (Clock Polarity)

配置SCLK空闲时的电平状态：

| CPOL | 空闲电平 | 有效状态 |
|------|----------|----------|
| 0 | 低电平 (0V) | SCLK处于高电平时有效 |
| 1 | 高电平 (3.3V) | SCLK处于低电平时有效 |

### 时钟相位 CPHA (Clock Phase)

配置数据采样发生在第几个边沿：

| CPHA | 采样边沿 | 发送边沿 |
|------|----------|----------|
| 0 | 第1个边沿 | 第2个边沿 |
| 1 | 第2个边沿 | 第1个边沿 |

### 四种模式详解

| 模式     | CPOL | CPHA | 空闲电平 | 采样边沿 | 发送边沿 | 常用度     |
| ------ | ---- | ---- | ---- | ---- | ---- | ------- |
| Mode 0 | 0    | 0    | 低    | 上升沿  | 下降沿  | ⭐⭐⭐ 最常用 |
| Mode 1 | 0    | 1    | 低    | 下降沿  | 上升沿  |         |
| Mode 2 | 1    | 0    | 高    | 下降沿  | 上升沿  |         |
| Mode 3 | 1    | 1    | 高    | 上升沿  | 下降沿  | ⭐⭐ 常用   |

### 模式时序图

```
Mode 0 (CPOL=0, CPHA=0) - 最常用:

  SCLK ──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐
         └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──
         ↑采样  ↑发送  ↑采样  ↑发送

  MOSI ──X─ D7 ──X─ D6 ──X─ D5 ──X─ D4 ──X─ D3 ...
         (数据在下降沿输出，上升沿被采样)

Mode 3 (CPOL=1, CPHA=1) - 常用:

  SCLK ──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐
         └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──┘  └──
               ↑采样  ↑发送  ↑采样  ↑发送

  MOSI ──X─ D7 ──X─ D6 ──X─ D5 ──X─ D4 ──X─ D3 ...
```

### 数据传输细节
- 数据在SCK**有效前半个时钟周期**输出
- CS信号有效后，从机**立即输出**第一位数据（即使SCK还没有起效）
- 第一个字节的最后一位被采样后，随后的SCK下降沿即输出第二个字节的第一位
- SPI通信**没有专门的通信周期、起始信号、结束信号**，只能通过控制时钟线状态

---

## 📊 数据传输

### 移位寄存器机制

SPI内部实际上是两个简单的**移位寄存器**进行数据交换：

```
┌─────────────────────────────────────────┐
│              Master                     │
│  ┌──────────┐         ┌──────────┐     │
│  │ SSPBUF   │←───────→│ SSPSR    │     │
│  │ (缓冲)   │         │ (移位)   │     │
│  └──────────┘         └────┬─────┘     │
│                            │ MOSI/MISO │
└────────────────────────────┼───────────┘
                             │
┌────────────────────────────┼───────────┐
│              Slave         │           │
│  ┌──────────┐         ┌───▼─────┐     │
│  │ SSPBUF   │←───────→│ SSPSR   │     │
│  │ (缓冲)   │         │ (移位)  │     │
│  └──────────┘         └─────────┘     │
└───────────────────────────────────────┘
```

- **SSPSR**：SPI内部移位寄存器，根据SCLK控制数据移入移出
- **SSPBUF**：数据缓冲寄存器（Tx-Data/Rx-Data register）
- **数据交换**：每个时钟周期，Master与Slave之间交换一位数据，实际都是SPI内部移位寄存器从SSPBUF里面拷贝的
- 可通过往SSPBUF对应的寄存器里读写数据，间接操控SPI内部的SSPSR

### 单字节传输时序

```
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┐
│ Bit7│ Bit6│ Bit5│ Bit4│ Bit3│ Bit2│ Bit1│ Bit0│  MSB→LSB
└─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┘
 MOSI: Master ──────────────────────────────→ Slave
 MISO: Master ←────────────────────────────── Slave
 SS:   ─────┐                                ┌──────
            └────────────────────────────────┘
 SCLK: ────┐  ┌─┐  ┌─┐  ┌─┐  ┌─┐  ┌─┐  ┌─┐  └
           └──┘  └──┘  └──┘  └──┘  └──┘  └──┘
```

### 虚拟数据 (Dummy Bytes)
- 由于Master始终生成时钟信号，即使只进行单向传输，也必须发送数据
- 读数据时，Master需要发送**任意值**（dummy byte）以在SCLK总线上产生时钟
- 从机SPI**不会自己产生**时钟信号

### 全双工传输

```verilog
// SPI全双工：同时发送和接收
always @(posedge sclk) begin
    if (cs_n == 0) begin
        rx_data <= {rx_data[6:0], mosi};  // 接收移位
        mosi_reg <= tx_data[7-cnt];       // 发送移位
    end
end
```

---

## 💡 优缺点分析

### 优点
- **高速传输**：最高可达几十MHz甚至100MHz以上（远高于I2C的400kHz）
- **全双工**：MOSI和MISO可同时传输数据，效率高
- **Push-Pull驱动**：相比Open Drain信号完整性更好，支持高速应用
- **协议简单**：无复杂从机地址机制，主机直接通过SS线控制
- **字长灵活**：不限于8位，可根据应用特点灵活选择消息字长
- **硬件简单**：从机不需要唯一地址（与I2C不同），不需要精密时钟振荡器（与UART不同），不需要收发器（与CAN不同）
- **无需上拉电阻**：相比I2C和SMbus节省上拉电阻
- **无需仲裁机制**：相比I2C和SMbus不需要总线仲裁
- **支持暂停**：主设备可通过延缓时钟边缘降低传输速度

### 缺点
- **引脚占用多**：至少需要4根线（I2C只需2根）
- **无寻址机制**：只能靠设备片选（chip select）选择不同从设备
- **无应答机制**：没有ACK信号，主机不知道从机是否收到数据（需额外设计CRC校验）
- **无数据流控制**：主设备只能通过延缓时钟边缘降低传输速度
- **无数据校验机制**：协议本身没有定义
- **抗干扰差**：高速信号易受噪声影响，传输距离短（相比RS232/RS422/RS485/CAN）
- **仅支持单主控**：典型应用只支持单Master
- **不支持热插拔**
- **中断支持有限**：只能通过额外信号线或Periodic Polling实现
- **标准不统一**：没有统一的国际组织维护，变种多，不利于不同厂商设备的互操作性

---

## 📱 典型应用场景

SPI以其简单高效应用于绝大多数SoC系统上，这些SoC通常同时支持作为主模式或从模式（二选一）。

| 应用领域 | 具体设备 |
|----------|----------|
| 存储器 | Flash (W25Q64)、EEPROM、SD卡、MMC卡 |
| 传感器 | 温度传感器、压力传感器、加速度计、陀螺仪 |
| 显示设备 | LCD驱动器、OLED控制器 |
| 控制设备 | 音频编解码器、RTC时钟 |
| 外设扩展 | ADC、DAC、GPIO扩展器 |
| 通信设备 | USB控制器、以太网控制器 |
| FPGA配置 | 高速配置（初始化）板上设备 |

### SPI vs JTAG (FPGA配置场景)
| 特性 | SPI | JTAG |
|------|-----|------|
| 定位 | 高速配置/数据传输 | IO扫描和检测 |
| 速度 | 高速 | 相对低速 |
| 时钟控制 | 简单 | 支持改变占空比以满足建立/保持时间 |
| 准确度 | 一般 | 高准确度 |

---

## 💻 软件实现

### C语言位操作示例 (Mode 0)

```c
/**
 * 同时在SPI上发送和接收一个字节
 * 假设极性和相位均为0 (CPOL=0, CPHA=0)：
 * - 在SCLK的上升沿捕获输入数据
 * - 输出数据在SCLK的下降沿传播
 *
 * @param byte_out 要发送的字节
 * @return 接收的字节
 */
uint8_t SPI_transfer_byte(uint8_t byte_out)
{
    uint8_t byte_in = 0;
    uint8_t bit;

    for (bit = 0x80; bit; bit >>= 1) {
        /* Shift-out a bit to the MOSI line */
        write_MOSI((byte_out & bit) ? HIGH : LOW);

        /* Delay for at least the peer's setup time */
        delay(SPI_SCLK_LOW_TIME);

        /* Pull the clock line high - 上升沿采样 */
        write_SCLK(HIGH);

        /* Shift-in a bit from the MISO line */
        if (read_MISO() == HIGH)
            byte_in |= bit;

        /* Delay for at least the peer's hold time */
        delay(SPI_SCLK_HIGH_TIME);

        /* Pull the clock line low - 下降沿输出 */
        write_SCLK(LOW);
    }

    return byte_in;
}
```

### 读寄存器示例

```c
/**
 * 读计量参数 - 下降沿发送和读取数据
 * 先发送8位地址，再读取24位数据
 */
uint32_t SPI_Read_Reg(uint8_t addr)
{
    uint8_t i;
    uint32_t temp = 0;

    addr &= 0x7F;  // 清除写位
    HIGH_CS();
    SPI_Delay();
    LOW_CS();
    SPI_Delay();

    LOW_CLK();
    // 发送8位地址
    for (i = 0; i < 8; i++) {
        SPI_Delay();
        HIGH_CLK();
        if (addr & 0x80)
            HIGH_DIN();
        else
            LOW_DIN();
        addr <<= 1;
        LOW_CLK();
    }

    SPI_Delay();
    // 读取24位数据
    for (i = 0; i < 24; i++) {
        SPI_Delay();
        temp <<= 1;
        HIGH_CLK();
        SPI_Delay();
        if (PIN_DOUT)
            temp |= 0x01;
        LOW_CLK();
    }

    SPI_Delay();
    HIGH_CS();
    SPI_Delay();
    HIGH_CLK();

    return temp;
}
```

### 写寄存器示例

```c
/**
 * 写寄存器参数 - 下降沿发送
 * 先发送8位地址数据，再发送24位数据
 */
void SPI_Write_Reg(uint8_t addr, uint32_t temp)
{
    uint8_t i;

    addr |= 0x80;  // 设置写位
    HIGH_CS();
    SPI_Delay();
    LOW_CS();
    SPI_Delay();

    LOW_CLK();
    // 发送8位地址
    for (i = 0; i < 8; i++) {
        SPI_Delay();
        HIGH_CLK();
        if (addr & 0x80)
            HIGH_DIN();
        else
            LOW_DIN();
        addr <<= 1;
        LOW_CLK();
    }

    // 发送24位数据
    for (i = 0; i < 24; i++) {
        SPI_Delay();
        HIGH_CLK();
        SPI_Delay();
        if (temp & 0x800000)
            HIGH_DIN();
        else
            LOW_DIN();
        temp <<= 1;
        LOW_CLK();
    }

    SPI_Delay();
    HIGH_CS();
    SPI_Delay();
    HIGH_CLK();
}
```

---

## ⚡ QSPI协议 (Quad SPI)

### 特点
- 4根数据线同时传输，带宽是标准SPI的4倍
- 通常使用FIFO/SRAM进行数据传输
- 因成本考虑，一般只能半双工

### 与标准SPI对比
| 特性 | SPI | QSPI |
|------|-----|------|
| 数据线 | 2 (MOSI+MISO) | 4 (IO0-IO3) |
| 传输模式 | 全双工 | 半双工 |
| 带宽 | 1x | 4x |
| 引脚数 | 4 | 6 |

---

## 📊 协议对比

| 特性 | SPI | I2C | UART |
|------|-----|-----|------|
| 线数 | 4 | 2 | 2 |
| 传输模式 | 全双工 | 半双工 | 全双工 |
| 同步方式 | 同步(SCLK) | 同步(SCL) | 异步 |
| 速度 | 几十MHz | 400kHz/3.4MHz | 几Mbps |
| 寻址 | 无(SS片选) | 7/10位地址 | 无 |
| 应答机制 | 无 | ACK | 无 |
| 多主机 | 不支持 | 支持 | 不支持 |
| 距离 | 短(板级) | 短(板级) | 中等 |
| 热插拔 | 不支持 | 不支持 | 不支持 |

---

## 🔧 UVM验证模型

### SPI Transaction

```systemverilog
class spi_transaction extends uvm_sequence_item;
    typedef enum {SPI_MODE_0, SPI_MODE_1, SPI_MODE_2, SPI_MODE_3} spi_mode_e;

    rand spi_mode_e mode;
    rand bit [7:0] tx_data[];
    rand bit [7:0] rx_data[];
    rand int cs_delay;          // 片选延迟

    `uvm_object_utils_begin(spi_transaction)
        `uvm_field_enum(spi_mode_e, mode, UVM_ALL_ON)
        `uvm_field_array_int(tx_data, UVM_ALL_ON)
        `uvm_field_array_int(rx_data, UVM_ALL_ON)
    `uvm_object_utils_end
endclass
```

### SPI Interface

```systemverilog
interface spi_if (
    input logic clk,
    input logic rst_n,
    input logic cs_n,
    input logic sclk,
    input logic mosi,
    output logic miso
);

    clocking cb @(posedge clk);
        input mosi;
        output miso;
    endclocking

    // SPI协议信号
    property sclk_idle_low;
        @(negedge sclk) disable iff (cs_n);
        1'b0 |-> 1'b0;
    endproperty
endinterface
```

### SPI Scoreboard

```systemverilog
class spi_scoreboard extends uvm_scoreboard;
    uvm_analysis_export #(spi_transaction) expected_export;
    uvm_analysis_export #(spi_transaction) actual_export;

    typedef uvm_tlm_analysis_fifo #(spi_transaction) fifo_t;
    fifo_t expected_fifo;
    fifo_t actual_fifo;

    function void build_phase(uvm_phase phase);
        expected_fifo = new("expected_fifo", this);
        actual_fifo = new("actual_fifo", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        spi_transaction exp_tr, act_tr;
        forever begin
            expected_fifo.get(exp_tr);
            actual_fifo.get(act_tr);

            // 比较数据
            if (exp_tr.rx_data == act_tr.rx_data)
                `uvm_info("PASS", "Data match", UVM_LOW)
            else
                `uvm_error("FAIL", $sformatf(
                    "Data mismatch: expected=%h, actual=%h",
                    exp_tr.rx_data, act_tr.rx_data))
        end
    endtask
endclass
```

---

## ✅ 验证要点

### 基础功能
- [ ] 四种模式测试 (Mode 0~3)
- [ ] 数据正确性 (MSB/LSB优先)
- [ ] 全双工传输验证
- [ ] 多从机切换
- [ ] 菊花链模式
- [ ] 虚拟数据传输 (Dummy Bytes)
- [ ] 双向模式

### 时序验证
- [ ] CPOL/CPHA配置正确性
- [ ] 建立/保持时间
- [ ] 片选时序 (CS到SCLK延时)
- [ ] 数据有效窗口
- [ ] 字节间衔接
- [ ] CS有效后从机立即输出第一位

### 边界条件
- [ ] 单字节传输
- [ ] 长数据流
- [ ] 片选切换间隔
- [ ] 连续传输
- [ ] QSPI半双工模式
- [ ] 任意字长传输 (非8位)

### 错误注入
- [ ] CPOL/CPHA模式不匹配
- [ ] 片选冲突 (多从机同时选中)
- [ ] MISO总线冲突
- [ ] SCLK频率超限
- [ ] 超时检测

---

## 🔗 相关链接

- [[03-Protocol/00-协议索引|协议索引]] - 返回协议索引
- [[03-Protocol/I2C/00-I2C|I2C]] - I2C 总线协议
- [[03-Protocol/AXI/00-AXI|AXI]] - AXI 总线协议
- [[03-Protocol/UART/00-UART|UART]] - UART 协议
- [[08-Projects/01-SPI验证/00-项目概述|SPI 验证项目]] - SPI 验证实战项目
- [[00-总索引]] - 返回总索引

---

## 📚 参考资料

- http://www.wangdali.net/spi/
- https://learn.sparkfun.com/tutorials/serial-peripheral-interface-spi
- https://en.wikipedia.org/wiki/Serial_Peripheral_Interface

---

tags: #Protocol #SPI #Interface
