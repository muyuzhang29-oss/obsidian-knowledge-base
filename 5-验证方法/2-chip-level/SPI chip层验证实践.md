# SPI Chip 层验证实践

## 背景

之前只验证过模块级别的 SPI Slave/Master（测试用例直接拉 mosi/miso/sclk/cs 引脚），现在要验证芯片集成的 SPI 控制器，验证方式完全不同。

## 核心区别：Block-Level vs Chip-Level

| 对比项 | Block-Level | Chip-Level |
|--------|-------------|------------|
| DUT | SPI Slave/Master 纯协议模块 | 带寄存器接口的完整控制器 |
| 驱动方式 | 测试用例直接拼 SPI 时序 | 测试用例配寄存器，DUT 自行产生时序 |
| 外部设备 | 不需要 | 需要外设 chip 模型 |

## 全链路 DUT 结构

```
发送方向:
SOC ──▶ WRP(Slave) ──▶ ROUTE ──▶ PAL ──────────────────▶ WRP(Master) ──▶ SENSOR
                                    │
                          ┌─────────┼─────────┐
                          │ spis    │ mp_gen  │ spim    │
                          │ _parse  │         │ _parse  │
                          └─────────┴─────────┘

回复方向:
SOC ◀── WRP(Slave) ◀── ROUTE ◀── PAL ◀── WRP(Master) ◀── SENSOR
```

DUT = 整条链路，包含：
- **WRP(Slave)** — SPI 从机部分
- **ROUTE** — 片内路由
- **PAL** — 协议抽象层（spis_parse → mp_gen → spim_parse）
- **WRP(Master)** — SPI 主机部分

Testbench 需要模拟的是两端：
- **SOC 侧** — 发送帧到 WRP(Slave) 内部 FIFO 接口
- **SENSOR 侧** — 连接到 SPI 引脚的外部设备模型

## DUT 结构（仅 spi_wrp 视图）

`spi_wrp` — 一个同时包含 SPI Slave 和 SPI Master 的封装层。

**关键理解：spi_wrp 有两层接口，不能搞混。**

### 1. 配置接口（reg 接口）— 配 spi_wrp 自己

```
CPU ──→ reg_addr[5:0]     这些是 spi_wrp 自己的内部配置寄存器
        reg_wren           比如：使能 SPI、选 Master/Slave 模式、
        reg_wr_data[7:0]   配波特率、配 pinmux、查状态等
        reg_rden
        reg_rd_data[7:0] ◀──
```

**这不是发给远端设备的 SPI 指令内容**，只是告诉 spi_wrp "你怎么工作"。

### 2. 数据通路 — 真正的 SPI 数据流

```
SPI Master 发数据:
  CPU 把数据写入 spi_wrp 的发送 FIFO (通过 reg 接口)
  → spi_wrp 自动产生 SPI 时序 (sclk/mosi/cs)
  → 数据从 SPI 引脚发出去

SPI Slave 收数据:
  外部主设备发 SPI 时序到 spi_wrp 的引脚
  → spi_wrp 接收
  → 数据进入接收 FIFO
  → SPIS_PSR 解析命令
  → CPU 通过 reg 接口读出来
```

### 完整结构图

```
┌─ CPU 行为模型 ──────────────────────────────────────────┐
│  cpu_wr_reg(addr, data)    ← 配 spi_wrp 的工作参数       │
│  cpu_rd_reg(addr, data)    ← 读 spi_wrp 的状态/监控信息  │
└──────────────────────┬──────────────────────────────────┘
                       │ reg_wren/rden/addr/wr_data/rd_data
                       ▼
┌───────────────── spi_wrp (DUT) ─────────────────────────┐
│                                                          │
│  ┌──── 配置寄存器 (只配工作参数) ────┐                    │
│  │ SPIS_CFG0(0x00): CPOL/CPHA/CS极  │                    │
│  │ SPIS_CFG1(0x01): 内部超时阈值    │                    │
│  │ SPIS_CFG2(0x02): 超时步长+使能   │    ← 这些只配     │
│  │ ...                             │      spi_wrp 的    │
│  │ SPIM_CFG0(0x10): CPOL/CPHA/SS极 │      工作参数      │
│  │ SPIM_CFG1(0x11): SCK低电平周期   │                    │
│  │ SPIM_CFG2(0x12): SCK高电平周期   │                    │
│  │ ...                             │                    │
│  └─────────────────────────────────┘                    │
│                                                          │
│  ┌──── 数据通路（不走 reg 接口） ─────┐                  │
│  │                                   │                  │
│  │  Master 发数据:                    │                  │
│  │  SPIM_PSR → FIFO → spi_wrp       │                  │
│  │            (spim_cmd_di_vld/rdy)  │                  │
│  │            → 自动产生 SPI 时序     │                  │
│  │                                   │                  │
│  │  Slave 收数据:                     │                  │
│  │  SPI 引脚 → spi_wrp → FIFO       │                  │
│  │            → SPIS_PSR             │                  │
│  │            (spis_cmd_do_vld/rdy)  │                  │
│  └────────────────┬─────────────────┘                  │
└───────────────────┼────────────────────────────────────┘
                    │ sclk mosi miso cs
                    ▼
┌───── SPI 外部设备模型 (chip model) ─────────────────────┐
│  连接到 SPI 引脚，模拟外部 SPI 设备                       │
└─────────────────────────────────────────────────────────┘
```

### 关键理解

- reg 接口**只配 spi_wrp 的工作参数**（时钟极性、波特率、超时等）
- 实际 SPI 数据**不走 reg 接口**，走 **FIFO 通路**（SPIM_PSR / SPIS_PSR）
- 测试用例验证的是：配好参数后，SPI 引脚能否正确收发数据

## 实际测试架构

### Master 模式测试

```
CPU 模型 ──配 SPIM_CFGx──▶ spi_wrp
FIFO 驱动 ──cmd──▶ SPIM_PSR ──▶ spi_wrp ──SPI时序──▶ SPI 外设模型
                    ◀──ack──                           (检查引脚时序)
```

1. 通过 reg 接口配 SPIM_CFG0~CFG3（CPOL/CPHA/波特率/延时）
2. 通过 `spim_cmd_di` 接口送 SPI Master 命令（由 SPIM_PSR 模块消费）
3. 观察 SPI 引脚波形是否符合配置的时序参数
4. 外设模型收到数据后回传 miso 响应
5. 检查 `spim_ack_do` 接口输出是否正确

### Slave 模式测试

```
CPU 模型 ──配 SPIS_CFGx──▶ spi_wrp
SPI主设备模型 ──SPI时序──▶ spi_wrp ──▶ SPIS_PSR ──cmd──▶ 检查FIFO输出
                   (BFM驱动)            ◀──ack──
```

1. 通过 reg 接口配 SPIS_CFG0~CFG4（CPOL/CPHA/超时等）
2. SPI BFM 向 spi_wrp 引脚发送 SPI 时序
3. 数据经 spi_wrp 传到 SPIS_PSR，从 `spis_cmd_do` 接口输出
4. 通过 `spis_ack_di` 接口回送响应
5. 检查数据是否正确

## 现有 I2C 验证环境分析

I2C 环境已经是 chip 级验证，结构可以直接照搬：

```
blocks/
├── i2c_it/                  ← 已有
│   ├── model/i2c_model/     APB总线模型 + I2C外设模型
│   ├── rtl/pmb_top/         I2C控制器RTL
│   ├── tb/                  filelist, tb.sv, i2c_task.sv
│   └── test/base_test.sv
│
└── spi_it/                  ← 新建，照搬命名结构
    ├── model/spi_model/     CPU reg接口模型 + SPI外设模型
    ├── rtl/spi_wrp/         spi_wrp + SPIS_PSR + SPIM_PSR
    ├── tb/                  filelist_spi, tb_spi.sv, spi_task.sv
    └── test/base_test.sv
```

## I2C → SPI 逐模块改动

| I2C 环境 | SPI 环境 | 改动说明 |
|----------|----------|----------|
| `rtl/pmb_top.v` 等 | `spi_wrp.v` + SPIS_PSR + SPIM_PSR | 替换 DUT，接口不同 |
| `apb_master_model.v` | CPU reg 接口模型 | APB → 自定义 reg_wren/rden/addr 接口 |
| `i2c_sensor_model.v` | SPI 外设 chip 模型 | I2C scl/sda 时序 → SPI sclk/mosi/miso 时序 |
| `i2c_slave_reg.v` | SPI 外设寄存器模型 | 保留思路，寄存器内容按 SPI 外设重写 |
| `i2c_task.sv` | `spi_task.sv` | 配置寄存器不同，封装 CPU reg 读写任务 |
| `tb.sv` | `tb_spi.sv` | 顶层例化不同 |
| `base_test.sv` | 类似 | 配 SPI 寄存器 |

## Chip 层验证需要准备的 6 样东西

1. **spi_wrp.v + SPIS_PSR + SPIM_PSR**（DE 提供）
2. **寄存器描述文档** — 64 个寄存器的地址映射表（DE 提供）
3. **CPU 行为模型** — 模拟 CPU 读写 spi_wrp 的**内部配置寄存器**（DV 写，约几十行）
4. **SPI 外部设备模型** — 连接到 SPI 引脚，模拟外部 SPI 芯片行为（DV 写）
5. **TB 顶层** — 例化 DUT + 模型，连线（DV 写）
6. **测试用例** — 通过 reg 接口配 spi_wrp → 启动传输 → 检查结果（DV 写）

## DV vs DE 分工

- **DE 提供**：RTL 代码（spi_wrp + 子模块）、寄存器描述文档
- **DV 准备**：CPU 行为模型、外设模型、TB 顶层、测试用例

## SPI 时序核心概念

SPI 与 I2C 的关键不同点：

| | I2C | SPI |
|--|-----|-----|
| 信号 | scl + sda（双向开漏） | sclk + mosi + miso + cs_n（单向） |
| 设备选择 | 7/10bit 地址 | 片选 cs_n |
| 握手 | ACK/NACK | 无握手 |
| 速度 | 标准/快速/高速 | 可配波特率 |

SPI 四种模式由 CPOL（时钟极性）和 CPHA（时钟相位）决定。

## 寄存器表（实际，来自 DE）

### SPIS Slave 寄存器 (0x00~0x08)

| 地址 | 名字 | 类型 | 功能 |
|------|------|------|------|
| 0x00 | SPIS_CFG0 | R/W | CPOL, CPHA, CS 极性 |
| 0x01 | SPIS_CFG1 | R/W | 内部超时阈值 |
| 0x02 | SPIS_CFG2 | R/W | 超时步长 + 超时使能 |
| 0x03 | SPIS_CFG3 | R/W | 外部超时阈值 |
| 0x04 | SPIS_CFG4 | R/W | 外部超时步长 + 使能 |
| 0x05 | SPIS_CFG5 | W1P | 超时错误计数清零 |
| 0x06 | SPIS_MNT0 | RO | 内部 FSM 状态监控 |
| 0x07 | SPIS_MNT1 | RO | 外部 FSM 状态监控 |
| 0x08 | SPIS_MNT2 | RO | 超时错误计数 |

### SPIM Master 寄存器 (0x10~0x19)

| 地址 | 名字 | 类型 | 功能 |
|------|------|------|------|
| 0x10 | SPIM_CFG0 | R/W | CPOL, CPHA, SS 极性, 全SCK采样, 远程地址使能 |
| 0x11 | SPIM_CFG1 | R/W | SCK 低电平周期 (333MHz 时钟数) |
| 0x12 | SPIM_CFG2 | R/W | SCK 高电平周期 |
| 0x13 | SPIM_CFG3 | R/W | SS 与 SCK 间延时 |
| 0x14 | SPIM_CFG4 | R/W | 内部超时阈值 |
| 0x15 | SPIM_CFG5 | R/W | 超时步长 + 使能 |
| 0x16 | SPIM_CFG6 | W1P | 超时错误计数清零 |
| 0x17 | SPIM_MNT0 | RO | 内部 FSM 状态监控 |
| 0x18 | SPIM_MNT1 | RO | 外部 FSM 状态监控 |
| 0x19 | SPIM_MNT2 | RO | 超时错误计数 |

### 关键观察

- 寄存器都是**配置参数**和**监控状态**，没有数据收发寄存器
- SPI 的实际数据通过 **FIFO 接口**（SPIS_PSR / SPIM_PSR）传输
- 验证时需要结合 SPIS_PSR / SPIM_PSR 的 FIFO 接口一起测

## SPI 帧格式（FIFO 中传输的数据）

这是 SPIM_PSR / SPIS_PSR 理解的 SPI 帧协议。当 spi_wrp 作为 Master 时，SoC 核心通过 FIFO 把帧发给 SPIM_PSR；作为 Slave 时，收到的数据从 SPIS_PSR 通过 FIFO 送出。

### 帧结构：CMD → ADDR → Control → [Data] → CRC

### 1. 写命令（Control Wr）

| 字段段 | 内容 | 位宽 |
|--------|------|------|
| CMD | loc_addr(1) + rw=0(1) + dst_port(3) | 8bit？ |
| ADDR | 设备地址 | 17bit |
| Control_wr | rd_en=0(1) + rd_len=0(7) + data_len(8) | 16bit |
| Data_wr | 写入数据 | 可变，由 data_len 决定 |
| CRC_wr | CRC8 | 8bit |

### 2. 读命令（不带数据返回 Control Rd）

| 字段段 | 内容 | 位宽 |
|--------|------|------|
| CMD | loc_addr(1) + rw=1(1) + dst_port(3) | 8bit？ |
| ADDR | 设备地址 | 17bit |
| Control_rd | rd_en(1) + rd_len(7) + data_len(8) | 16bit |
| CRC_rd | CRC8 | 8bit |

只有命令，不携带数据，DUT 不返回数据。

### 3. 读命令（带数据返回）

| 字段段 | 内容 | 位宽 |
|--------|------|------|
| CMD | loc_addr(1) + rw=1(1) + dst_port(3) | 8bit？ |
| ADDR | 设备地址 | 17bit |
| Control_rd | rd_en(1) + rd_len(7) + data_len(8) | 16bit |
| Data_rd | 回读的数据 | 可变 |
| CRC_rd | CRC8 | 8bit |

读命令发出后，外部 SPI 设备返回数据，通过 miso 回传。

### 4. 纯读数据帧（RD_DATA_CMD）

| 字段段 | 内容 | 说明 |
|--------|------|------|
| CMD | 固定命令头 | 复用读命令标识 |
| ADDR | 复用前一条 RD_CMD 的地址 | 地址继承 |
| Control_rd | rd_en + rd_len + data_len | 参数与前一条 RD_CMD 一致 |
| CRC_cmd | 前半段命令 CRC | 命令部分校验 |
| Dummy | 填充字节 | 对齐位宽 |
| Data_rd | 回读数据 | 真正要读的数据 |
| CRC_data | 数据 CRC | 数据段单独校验 |

关键：地址、长度必须和前一条 RD_CMD 完全一致。

### Control 子字段定义

- `rd_en[1bit]`：读使能，写命令固定为 0
- `rd_len[7bit]`：单次读突发长度
- `data_len[8bit]`：整个载荷数据字节长度

## 验证实现：trans → FIFO

之前 block-level 验证 SPI 时你定义过 `trans`：
```
trans = {cmd, addr, data}
  → 手动拉 SPI 引脚直接发
```

现在 chip 级：

```
你的 trans = {cmd=写, addr=0x12345, data={0xA5, 0xB6}}
  → 打包成 FIFO 帧格式 → 从 spim_cmd_di 接口塞给 SPIM_PSR
  → SPIM_PSR 解析 → spi_wrp 自动在引脚上产生 SPI 时序
```

### Testbench FIFO 驱动实现

```verilog
// 例：发一条写命令
task spi_master_write(input [16:0] addr, input [7:0] data[], input [7:0] data_len);
  reg [7:0] crc;
  // 1. 发 CMD: loc_addr=1, rw=0(写), dst_port=010
  fifo_put(8'b101_010);  // 假设CMD为8bit
  // 2. 发 ADDR: 17bit 地址，按SPI字节序分2~3字节发出
  fifo_put(addr[16:9]);  // 高8bit
  fifo_put(addr[8:1]);   // 中8bit
  fifo_put({addr[0], 7'b0}); // 低1bit+填充
  // 3. 发 Control_wr: rd_en=0 + rd_len=0 + data_len
  fifo_put({1'b0, 7'd0}); // rd_en + rd_len
  fifo_put(data_len);      // data_len
  // 4. 发 Data
  for (int i = 0; i < data_len; i++) begin
    fifo_put(data[i]);
  end
  // 5. 发 CRC8（计算略）
  crc = calc_crc8(...);
  fifo_put(crc);
endtask

// FIFO 写操作（valid/ready 握手）
task fifo_put(input [7:0] dat);
  spim_cmd_di_dat = dat;
  spim_cmd_di_vld = 1;
  while (!spim_cmd_di_rdy) @(posedge clk);
  @(posedge clk);
  spim_cmd_di_vld = 0;
endtask
```

### 和之前 block-level trans 的关系

**内容一样，入口变了：**

```
之前：trans.cmd → 手动拉 mosi 逐位发出
现在：trans.cmd → 打包成帧 → 塞 FIFO → SPIM_PSR 解析 → spi_wrp 自动拉 mosi

之前：trans.addr → 手动拉 mosi 逐位发出
现在：trans.addr → 打包进帧 → 同上

之前：trans.data → 手动拉 mosi 逐位发出  
现在：trans.data → 打包进帧 → 同上
```

你之前 slave 验证的 trans 定义可以直接复用，只是驱动方式从"手动拉引脚"改成"塞 FIFO"。

---

## cpu_model.sv — CPU reg 接口读写

```verilog
module cpu_model (
  input  wire        clk_reg,
  input  wire        rst_reg_n,
  output reg  [5:0]  reg_addr,
  output reg  [7:0]  reg_wr_data,
  output reg         reg_wren,
  output reg         reg_rden,
  input  wire [7:0]  reg_rd_data
);

  task cpu_wr_reg(input [5:0] addr, input [7:0] data);
    @(posedge clk_reg);
    reg_addr   = addr;
    reg_wr_data = data;
    reg_wren   = 1;
    @(posedge clk_reg);
    reg_wren   = 0;
    reg_addr   = 6'h0;
    reg_wr_data = 8'h0;
  endtask

  task cpu_rd_reg(input [5:0] addr, output [7:0] data);
    @(posedge clk_reg);
    reg_addr   = addr;
    reg_rden   = 1;
    @(posedge clk_reg);
    data       = reg_rd_data;
    reg_rden   = 0;
    reg_addr   = 6'h0;
  endtask

endmodule
```

## soc_model.sv — SOC 帧打包 + FIFO 驱动

```verilog
module soc_model (
  input  wire        clk,
  input  wire        rst_n,
  output reg  [7:0]  soc_tx_dat,
  output reg         soc_tx_vld,
  input  wire        soc_tx_rdy,
  input  wire [7:0]  soc_rx_dat,
  input  wire        soc_rx_vld,
  output reg         soc_rx_rdy
);

  task fifo_put(input [7:0] dat);
    soc_tx_dat = dat; soc_tx_vld = 1;
    while (!soc_tx_rdy) @(posedge clk);
    @(posedge clk); soc_tx_vld = 0;
  endtask

  task fifo_get(output [7:0] dat);
    soc_rx_rdy = 1;
    while (!soc_rx_vld) @(posedge clk);
    dat = soc_rx_dat; @(posedge clk); soc_rx_rdy = 0;
  endtask

  task spi_frame_write(input [4:0] dst_port, input [16:0] addr,
                       input [7:0] data[], input [7:0] len);
    reg [7:0] fifo_data[$]; fifo_data = {};
    fifo_data.push_back({1'b1, 1'b0, dst_port[2:0], 3'b0});
    fifo_data.push_back(addr[16:9]); fifo_data.push_back(addr[8:1]);
    fifo_data.push_back({addr[0], 7'b0});
    fifo_data.push_back({1'b0, 7'b0}); fifo_data.push_back(len);
    for (int i = 0; i < len; i++) fifo_data.push_back(data[i]);
    fifo_data.push_back(calc_crc8(fifo_data));
    foreach (fifo_data[i]) fifo_put(fifo_data[i]);
  endtask

  task spi_frame_read_no_data(input [4:0] dst_port, input [16:0] addr,
                              input [6:0] rd_len, input [7:0] data_len);
    reg [7:0] fifo_data[$]; fifo_data = {};
    fifo_data.push_back({1'b1, 1'b1, dst_port[2:0], 3'b0});
    fifo_data.push_back(addr[16:9]); fifo_data.push_back(addr[8:1]);
    fifo_data.push_back({addr[0], 7'b0});
    fifo_data.push_back({1'b1, rd_len}); fifo_data.push_back(data_len);
    fifo_data.push_back(calc_crc8(fifo_data));
    foreach (fifo_data[i]) fifo_put(fifo_data[i]);
  endtask

  task spi_frame_read_with_data(input [4:0] dst_port, input [16:0] addr,
                                input [6:0] rd_len, input [7:0] data_len,
                                input [7:0] data[]);
    reg [7:0] fifo_data[$]; fifo_data = {};
    fifo_data.push_back({1'b1, 1'b1, dst_port[2:0], 3'b0});
    fifo_data.push_back(addr[16:9]); fifo_data.push_back(addr[8:1]);
    fifo_data.push_back({addr[0], 7'b0});
    fifo_data.push_back({1'b1, rd_len}); fifo_data.push_back(data_len);
    for (int i = 0; i < data_len; i++) fifo_data.push_back(data[i]);
    fifo_data.push_back(calc_crc8(fifo_data));
    foreach (fifo_data[i]) fifo_put(fifo_data[i]);
  endtask

  task spi_frame_recv(output [7:0] rx_buf[], input [7:0] exp_len);
    rx_buf = new[exp_len];
    for (int i = 0; i < exp_len; i++) fifo_get(rx_buf[i]);
  endtask

  function [7:0] calc_crc8(reg [7:0] data[$]);
    reg [7:0] crc = 8'h00;
    foreach (data[i]) crc = crc ^ data[i];
    return crc;
  endfunction

endmodule
```

## spi_sensor_model.sv — SPI 外设引脚级模型

```verilog
module spi_sensor_model (
  input  wire        clk, rst_n,
  input  wire        sclk, mosi, cs_n,
  output reg         miso,
  input  wire        cpol, cpha,
  input  [7:0]      reg_wr_data,
  input             reg_wr_en,
  input  [16:0]     reg_wr_addr
);

  reg [7:0] mem[0:131071];
  integer i;
  initial begin
    for (i = 0; i < 131072; i++) mem[i] = 8'h00;
  end
  always @(posedge clk) begin
    if (reg_wr_en) mem[reg_wr_addr] <= reg_wr_data;
  end

  reg sclk_d1, sclk_d2, cs_n_d1, cs_n_d2;
  wire sclk_pos = sclk_d1 & ~sclk_d2;
  wire sclk_neg = ~sclk_d1 & sclk_d2;
  wire cs_start = cs_n_d1 & ~cs_n_d2;
  wire cs_end   = ~cs_n_d1 & cs_n_d2;
  always @(posedge clk) begin
    sclk_d1 <= sclk; sclk_d2 <= sclk_d1;
    cs_n_d1 <= cs_n; cs_n_d2 <= cs_n_d1;
  end

  wire sample_edge = (cpha == 0) ? sclk_pos : sclk_neg;
  wire drive_edge  = (cpha == 0) ? sclk_neg : sclk_pos;
  reg [3:0] bit_cnt;
  reg [7:0] shift_reg;

  always @(posedge clk) begin
    if (!rst_n) begin
      bit_cnt <= 0; shift_reg <= 0; miso <= 0;
    end else if (cs_start) begin
      bit_cnt <= 0; shift_reg <= 0;
    end else if (cs_end) begin
      bit_cnt <= 0;
    end else if (!cs_n) begin
      if (sample_edge) begin shift_reg <= {shift_reg[6:0], mosi}; bit_cnt <= bit_cnt + 1; end
      if (drive_edge) miso <= mem[{bit_cnt, 3'b0}][0];
    end
  end

endmodule
```

## tb_spi.sv — TB 顶层

```verilog
`include "tb_define.v"
`include "tb_include.sv"

module tb_spi;
  reg clk_spi, clk_lf, clk_reg, rst_n;
  initial clk_spi = 0; always #1.5 clk_spi = ~clk_spi;
  initial clk_lf  = 0; always #5   clk_lf  = ~clk_lf;
  initial clk_reg = 0; always #20  clk_reg = ~clk_reg;
  initial begin rst_n = 0; #100 rst_n = 1; end

  wire [5:0] reg_addr;
  wire [7:0] reg_wr_data, reg_rd_data;
  wire reg_wren, reg_rden;
  wire sclk, mosi, miso, cs_n;
  wire [7:0] soc_tx_dat, soc_rx_dat;
  wire soc_tx_vld, soc_tx_rdy, soc_rx_vld, soc_rx_rdy;

  cpu_model u_cpu (.*);
  soc_model u_soc (.clk(clk_spi), .rst_n(rst_n),
    .soc_tx_dat(soc_tx_dat), .soc_tx_vld(soc_tx_vld),
    .soc_tx_rdy(soc_tx_rdy), .soc_rx_dat(soc_rx_dat),
    .soc_rx_vld(soc_rx_vld), .soc_rx_rdy(soc_rx_rdy));

  // DUT: spi_wrp + ROUTE + PAL（DE 提供，占位）
  // spi_wrp u_dut ( ... );

  spi_sensor_model u_sensor (.clk(clk_spi), .rst_n(rst_n),
    .sclk(sclk), .mosi(mosi), .cs_n(cs_n), .miso(miso),
    .cpol(1'b0), .cpha(1'b0),
    .reg_wr_data(8'h00), .reg_wr_en(1'b0), .reg_wr_addr(17'h0));

  initial begin #200; @(posedge rst_n); #100; end
endmodule
```

## spi_task.sv — 高层 task 封装

```verilog
task spi_init(input cpol, cpha, input [7:0] sck_low, sck_high, ss_dly);
  cpu_wr_reg(6'h00, {3'b0, 1'b0, cpha, cpol});
  cpu_wr_reg(6'h01, 8'h01);   cpu_wr_reg(6'h02, 8'b0000_0100);
  cpu_wr_reg(6'h10, {cpol, cpha, 4'b0, 1'b0});
  cpu_wr_reg(6'h11, sck_low); cpu_wr_reg(6'h12, sck_high);
  cpu_wr_reg(6'h13, ss_dly);
endtask

task spi_master_write(input [4:0] dst_port, input [16:0] dev_addr,
                      input [7:0] wr_data[], input [7:0] len);
  spi_frame_write(dst_port, dev_addr, wr_data, len);
endtask

task spi_master_read(input [4:0] dst_port, input [16:0] dev_addr,
                     input [6:0] rd_len, input [7:0] data_len,
                     output [7:0] rd_data[]);
  spi_frame_read_with_data(dst_port, dev_addr, rd_len, data_len, {});
  spi_frame_recv(rd_data, data_len);
endtask

task spi_check_timeout_err(output [7:0] spis_cnt, output [7:0] spim_cnt);
  cpu_rd_reg(6'h08, spis_cnt); cpu_rd_reg(6'h19, spim_cnt);
endtask
```

## base_test.sv — 基础测试用例

```verilog
module base_test;
  initial begin
    #200; @(posedge u_tb.rst_n); #100;
    $display("[TEST] SPI Master Write: SOC -> SENSOR");
    spi_init(.cpol(0), .cpha(0), .sck_low(5), .sck_high(5), .ss_dly(2));
    reg [7:0] wdata[]; wdata = new[4];
    wdata = '{8'hA5, 8'h5A, 8'hFF, 8'h00};
    spi_master_write(5'b00010, 17'h1A2B3, wdata, 8'd4);
    #1000;
    $display("[TEST] SPI Master Read: SOC <- SENSOR");
    reg [7:0] rdata[];
    spi_master_read(5'b00010, 17'h1A2B3, 7'd4, 8'd4, rdata);
    for (int i = 0; i < 4; i++) $display("  rdata[%0d] = 0x%02h", i, rdata[i]);
    reg [7:0] spis_err, spim_err;
    spi_check_timeout_err(spis_err, spim_err);
    if (spis_err || spim_err)
      $display("[FAIL] Timeout err SPIS=%0d SPIM=%0d", spis_err, spim_err);
    else $display("[PASS] No timeout error");
    #500; $finish;
  end
endmodule
```

## sim/wave.tcl — 波形 dump 脚本

```tcl
if { [info exists ::env(DUMP_DELTA_EVENT)] } {
    database -open waves -shm -into waves -default -event
} else {
    database -open waves -shm -into waves -default
}
probe -database waves -create $env(TOP) -all -depth all
for {set i 0} {$i < 4} {incr i} {
    probe -database waves -create tb.u_SS01_CHP${i} -all -depth all
}
probe -database waves -create tb.u_SS02_CHP -all -depth all
probe -database waves -create tb.u_SS02_CHP.u_ss02_wop.u_ss02_cor -all -depth all
probe -database waves -create tb.u_SS02_CHP.u_ss02_wop.u_ss02_cor.u_video_pipe -all -depth all
probe -database waves -create tb.u_SS02_CHP.u_ss02_wop.u_ss02_cor.u_ppi_ctrl_top -all -depth all
for {set i 0} {$i < 4} {incr i} {
    probe -database waves -create tb.u_SS01_CHP${i}.u_ss01_wop.u_ss01_cor -all -depth all
}
foreach inst {0 1 2 3} {
    set base "tb.u_SS02_CHP.u_ss02_wop.u_ss02_cor.subsystem_cor_inst[${inst}].u_subsystem_cor"
    probe -database waves -create ${base}.u_sep2csi -all -depth all
    probe -database waves -create ${base}.u_cs12_packet_parse_top_scd -all -depth all
}
```

### 运行逻辑

`probe` 是 Questa/Modelsim 的命令，作用是**选择哪些信号记录到波形文件**：

- `-database waves` — 写入名为 waves 的波形数据库
- `-create` — 创建 probe 点
- `-all -depth all` — 该层级下所有信号都记录
- `$env(TOP)` — 从环境变量读取顶层模块名（在 run.tcl 或 makefile 里设置）

### 使用方法

```tcl
# 方式 1：在仿真器里手动执行
source wave.tcl
run -all

# 方式 2：在 run.tcl 中自动 source
# do wave.tcl

# 方式 3：在 makefile 里传参
# vsim -c tb_spi -do "source wave.tcl; run -all"
```

### 精简说明

原始脚本大量重复（SS01_CHP0~3 各一行、subsystem_cor_inst[0~3] 各 2 行），用 `for` 和 `foreach` 替代。需要添加新的 probe 点只需在脚本末尾加一行。

---

## filelist_spi — 编译文件列表

```
../model/spi_sensor_model.sv
../model/cpu_model.sv
../model/soc_model.sv
// DUT RTL（DE 提供）
// ../rtl/spi_wrp.v ../rtl/SPIS_PSR.v ../rtl/SPIM_PSR.v ../rtl/ROUTE.v ../rtl/PAL.v
tb_define.v tb_include.sv tb_spi.sv spi_task.sv
../test/base_test.sv
```
