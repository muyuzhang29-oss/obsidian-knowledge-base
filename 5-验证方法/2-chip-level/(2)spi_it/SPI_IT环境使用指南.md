# SPI_IT 环境使用指南

> SPI Integration Test — 基于 SS12 SPI 控制器的集成测试环境

---

## 1. 环境准备

### 1.1 依赖组件

| 组件 | 来源 | 用途 |
|------|------|------|
| I2C Master 模型 | 从 I2C_IT 复制 `i2c_master_model.v` + `apb_master_model.v` + `pmb_*` + `pmbus_reg.sv` + `std_*` | 通过 I2C 配置 DUT 寄存器 |
| DUT RTL | DE 提供 `SS12_CHP.v` + `SS11_CHP.v` + 子模块 | 待测设计 |
| EDA 工具 | Xcelium (IUS) / VCS / Modelsim | 编译 + 仿真 |

### 1.2 文件复制（工作机上操作）

```bash
# 从 I2C_IT 项目复制 I2C Master 模型
cp <I2C_IT>/model/i2c_model/i2c_master_model.v    SPI_IT/model/
cp <I2C_IT>/model/i2c_model/apb_master_model.v    SPI_IT/model/
cp <I2C_IT>/model/i2c_model/pmb_top.v             SPI_IT/model/
cp <I2C_IT>/model/i2c_model/pmb_master_top.v       SPI_IT/model/
cp <I2C_IT>/model/i2c_model/pmb_master_logic.v     SPI_IT/model/
cp <I2C_IT>/model/i2c_model/pmb_master_filter.v    SPI_IT/model/
cp <I2C_IT>/model/i2c_model/pmb_master_clock_gate.v SPI_IT/model/
cp <I2C_IT>/model/i2c_model/pmb_slave_top.v        SPI_IT/model/
cp <I2C_IT>/model/i2c_model/pmb_slave_async.v      SPI_IT/model/
cp <I2C_IT>/model/i2c_model/pmb_slave_filt.v       SPI_IT/model/
cp <I2C_IT>/model/i2c_model/pmb_scl_sync.v         SPI_IT/model/
cp <I2C_IT>/model/i2c_model/pmb_rst_sync.v         SPI_IT/model/
cp <I2C_IT>/model/i2c_model/pmb_sync.v             SPI_IT/model/
cp <I2C_IT>/model/i2c_model/pmb_pinmux.v           SPI_IT/model/
cp <I2C_IT>/model/i2c_model/pmb_fifo.v             SPI_IT/model/
cp <I2C_IT>/model/i2c_model/pmb_and2.v             SPI_IT/model/
cp <I2C_IT>/model/i2c_model/pmb_mux2.v             SPI_IT/model/
cp <I2C_IT>/model/i2c_model/pmb_dft_se.v           SPI_IT/model/
cp <I2C_IT>/model/i2c_model/pmbus_reg.sv           SPI_IT/model/
cp <I2C_IT>/model/i2c_model/pmbus_reg_bak.sv       SPI_IT/model/
cp <I2C_IT>/model/i2c_model/std_icg_test.v         SPI_IT/model/
cp <I2C_IT>/model/i2c_model/std_an2.v              SPI_IT/model/
cp <I2C_IT>/model/i2c_model/std_mux2.v             SPI_IT/model/
```

复制完成后，取消 `filelist_spi` 中第 1 节（I2C_IT Master Model）的注释。

### 1.3 DUT RTL 路径配置

将 DUT RTL 文件添加到 `filelist_spi` 第 3 节。

需要确认 SS12 顶层端口名（例：`SS12_CHP` 的 I2C/SPI 端口声明），更新 `tb_spi.sv` 中 `u_ss12` 的例化。

---

## 2. 编译

### 2.1 文件列表 (`filelist_spi`)

编译顺序：
```
1. I2C_IT Master Model     ← 先编译依赖
2. SPI_IT 模型              ← 行为模型
3. DUT RTL                 ← 设计代码
4. TB + 测试用例            ← 最后编译
```

### 2.2 编译命令

**Xcelium (xrun)** — I2C_IT 环境使用的工具：

```bash
# 编译 + 链接
cd SPI_IT/sim
xrun -64bit -mess -sv -access +rwc \
     -f ../tb/filelist_spi \
     -top tb_spi \
     -l compile.log \
     -elaborate
```

**VCS**:

```bash
cd SPI_IT/sim
vcs -full64 -sverilog -debug_access+all \
    -f ../tb/filelist_spi \
    -top tb_spi \
    -l compile.log
```

**Modelsim/Questa**:

```bash
cd SPI_IT/sim
vlib work
vlog -sv -f ../tb/filelist_spi
vsim -c tb_spi
```

---

## 3. 仿真

### 3.1 运行测试

```bash
# Xcelium
cd <SIM_DIR>
xrun -64bit -r tb_spi -svseed random -l sim.log

# VCS
./simv -l sim.log

# 指定 seed（复现随机场景）
xrun -64bit -r tb_spi -svseed 12345 -l sim.log
```

### 3.2 波形查看

转储波形由 `sim/wave.tcl` 控制：

```tcl
# wave.tcl 示例（Xcelium）
database -open waves -shm -into waves/ tb_spi
probe -create tb_spi -depth all -all -waveform -database waves
run
exit
```

使用波形：

```bash
# Xcelium: 仿真时加载 wave.tcl
xrun -64bit -r tb_spi -input ../sim/wave.tcl -l sim.log

# 查看波形
simvision waves/
```

---

## 4. 测试流程详解

### 4.1 标准执行顺序

```
base_test.sv
│
├── Phase 1: I2C Master 初始化 (ext_i2c_init)
│   └── 通过 APB 写 PMBus 寄存器 (0x010/0x014/0x020/0x018/0x040/0x044/0x048)
│       └── i2c_master_model 内部生成 SCL/SDA 时序
│
├── Phase 2: SPI 控制器配置 (spi_init)
│   └── ext_i2c_wr_reg16(I2C_SLV_ADDR, SPI_REG_BASE+0x00~0x13, data)
│       └── APB 写 TX FIFO (0x00c) → PMBus 状态机 → SCL/SDA → DUT i2cs
│           ├── [START + 0x30+W + 0x00 + 0x00 + CFG0 + STOP]  ← SPIS_CFG0
│           ├── [START + 0x30+W + 0x00 + 0x01 + CFG1 + STOP]  ← SPIS_CFG1
│           ├── [START + 0x30+W + 0x00 + 0x02 + CFG2 + STOP]  ← SPIS_CFG2
│           ├── [START + 0x30+W + 0x00 + 0x10 + CFG0 + STOP]  ← SPIM_CFG0
│           ├── [START + 0x30+W + 0x00 + 0x11 + SCK_LOW+STOP]  ← SPIM_CFG1
│           ├── [START + 0x30+W + 0x00 + 0x12 + SCK_HIGH+STOP] ← SPIM_CFG2
│           └── [START + 0x30+W + 0x00 + 0x13 + SS_DLY+STOP]  ← SPIM_CFG3
│
└── Phase 3: SPI Loopback 测试 (test_spi_loopback)
    ├── spi_master_write (port0, dev_addr=0x1_0000, data[8])
    │   └── soc_model.spi_frame_write → SOC FIFO → DUT spi_wrp → SCLK/MOSI/CS → spi_sensor_model
    ├── spi_master_read (port0, dev_addr=0x1_0000, len=8)
    │   └── soc_model.spi_frame_read_with_data → SOC FIFO → DUT spi_wrp → SCLK/CS → spi_sensor_model
    │   └── soc_model.spi_frame_recv ← spi_wrp → SOC FIFO
    └── 逐字节比对 tx_data vs rx_data
```

### 4.2 数据封装格式

**SPI 帧格式**（由 `soc_model.sv` 的 `spi_frame_write` / `spi_frame_read_with_data` 组帧）：

```
写帧: [HEADER(8)] [ADDR_H(8)] [ADDR_M(8)] [ADDR_L(8)] [CTRL(8)] [LEN(8)] [DATA0..N(8)] [CRC(8/16)]
读帧: [HEADER(8)] [ADDR_H(8)] [ADDR_M(8)] [ADDR_L(8)] [CTRL(8)] [LEN(8)] [CRC(8/16)]
```

| 字段 | 说明 |
|------|------|
| HEADER[7:0] | bit7=1(帧类型), bit6=0(写)/1(读), bit5:3=port, bit2:0=0 |
| ADDR_H/M/L | 17-bit 目标设备地址 (bit16:9 / bit8:1 / bit0+7'b0) |
| CTRL | `{1'b0, rd_len[6:0]}` (读帧) 或 `{1'b0, 7'b0}` (写帧) |
| LEN | 数据长度 |
| DATA | 待写数据（写帧独有） |
| CRC | CRC-8 (poly 0x07) 或 CRC-16 (poly 0x8005)，由 top 寄存器控制 |

---

## 5. 编写新测试

### 5.1 新建测试文件

```systemverilog
// test/spi_my_test.sv
`include "tb_define.v"
`include "tb_include.sv"

program spi_my_test;

  initial begin
    #300;

    // === Setup ===
    ext_i2c_init;
    spi_init(.cpol(0), .cpha(0), .sck_low(8'd100),
             .sck_high(8'd100), .ss_dly(8'd10));

    // === 你自己的测试逻辑 ===
    // ...
    $display("%10t: === Test done ===", $time);
    #1000;
    $finish;
  end

endprogram
```

### 5.2 切换测试用例

修改 `tb/tb_include.sv` 中的 include 路径：

```systemverilog
// tb/tb_include.sv
`include "../test/spi_my_test.sv"   // ← 改为你的 test 文件
```

### 5.3 可用的辅助任务

| 任务 | 定义位置 | 用途 |
|------|---------|------|
| `ext_i2c_init` | `spi_task.sv` | I2C Master 初始化 |
| `ext_i2c_wr_reg16(addr, data)` | `spi_task.sv` | I2C 写 16-bit 寄存器地址 |
| `ext_i2c_rd_reg16(addr, data)` | `spi_task.sv` | I2C 读 16-bit 寄存器地址（TODO） |
| `spi_init(cpol, cpha, sck_low, sck_high, ss_dly)` | `spi_task.sv` | SPI 控制器初始化 |
| `spi_master_write(port, addr, data, len)` | `spi_task.sv` | SPI Master 写传感器 |
| `spi_master_read(port, addr, rd_len, data_len, rx)` | `spi_task.sv` | SPI Master 读传感器 |
| `spi_check_timeout_err(cnt_s, cnt_m)` | `spi_task.sv` | 读超时错误计数器 |
| `spi_set_crc_mode(use_crc16)` | `spi_task.sv` | 设置 CRC 模式 |
| `set_crc_mode(mode)` | `soc_model.sv` | soc_model 内部 CRC 模式 |

---

## 6. 调试技巧

### 6.1 日志搜索关键字

```bash
# 搜索 I2C 事务
grep "EXT_I2C" sim.log

# 搜索错误
grep -i "error\|mismatch\|failure" sim.log

# 搜索 CRC
grep -i "crc" sim.log
```

### 6.2 波形观察信号

| 信号 | 路径 | 说明 |
|------|------|------|
| I2C SCL | `tb_spi.i2c_scl` | I2C 时钟 |
| I2C SDA | `tb_spi.i2c_sda` | I2C 数据 |
| SPI SCLK | `tb_spi.sclk` | SPI 时钟 |
| SPI MOSI | `tb_spi.mosi` | SPI 主出从入 |
| SPI MISO | `tb_spi.miso` | SPI 主入从出 |
| SPI CS | `tb_spi.cs_n` | SPI 片选 |
| SOC TX | `tb_spi.soc_tx_*` | SOC FIFO 发送 |
| SOC RX | `tb_spi.soc_rx_*` | SOC FIFO 接收 |
| PMBus int st | `tb_spi.u_ext_i2c_mst.pmbus_int_st` | PMBus 中断状态 |

### 6.3 常见问题

| 问题 | 可能原因 | 检查 |
|------|---------|------|
| I2C 无响应 | Slave 地址不匹配 | `I2C_SLV_ADDR` 定义 vs DUT `i_native_dev` |
| SPI 帧超时 | CRC 不匹配 | DUT CRC 模式 vs `spi_set_crc_mode` |
| 数据全 0 | memory 未初始化 | `main_mem_model` init 循环 |
| 编译报 `apb_wr` 未定义 | I2C_IT 文件未复制 | 检查 `filelist_spi` 第 1 节 |
| PMBus 状态机卡住 | PMBus 寄存器值不对 | 检查 `ext_i2c_init` 的 7 个 APB 写入值 |
| SPI loopback 读不到数据 | SOC FIFO recv 时机不对 | `spi_frame_recv` 中 `fifo_get` 是否在正确时机 |

---

## 7. 测试用例模板

```systemverilog
// test/spi_my_custom_test.sv
`include "tb_define.v"
`include "tb_include.sv"

program spi_my_custom_test;

  initial begin
    #300;

    ext_i2c_init;

    // Example：配置 SPI 为 CPOL=1, CPHA=1
    spi_init(.cpol(1), .cpha(1), .sck_low(8'd50),
             .sck_high(8'd50), .ss_dly(8'd5));

    // Example：读取 SPI 超时状态
    check_timeout;

    #1000;
    $finish;
  end

  task check_timeout;
    reg [7:0] spis_cnt, spim_cnt;
    spi_check_timeout_err(spis_cnt, spim_cnt);
    $display("SPIS timeout=%0d, SPIM timeout=%0d", spis_cnt, spim_cnt);
    if (spis_cnt || spim_cnt)
      $error("Timeout error detected!");
  endtask

  // 添加更多自定义 task ...

endprogram
```

---

## 8. 遗留项

| # | 事项 | 截止条件 |
|---|------|---------|
| 1 | 从 I2C_IT 复制 master model 文件 | 工作机上操作 |
| 2 | `ext_i2c_rd_reg16` 实现 | 需要 I2C_IT 读任务定义 |
| 3 | DUT 顶层端口验证 | 检查 SS12_CHP 的 I2C/SPI 端口声明 |
| 4 | `sim/run_cmd` 创建 | 参考 I2C_IT 的 run_cmd |
