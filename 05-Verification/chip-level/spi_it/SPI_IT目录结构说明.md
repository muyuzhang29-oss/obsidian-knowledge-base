# SPI_IT 目录结构说明

> SPI Integration Test 环境，适配 SS12 的 SPI 控制器 (`spi_wrp`) 验证。
> 架构参考 I2C_IT，I2C 配置路径复用 I2C_IT 的 master model (PMBus + APB)。

---

## 目录树

```
spi_it/                          ← SPI Integration Test 根目录
├── model/                       ← 行为级模型
│   ├── memory/
│   │   └── main_mem_model.v     ← 128KB 行为级存储器
│   ├── soc_model.sv             ← SOC 行为模型（FIFO 接口 + SPI 帧封装 + CRC 计算）
│   ├── spi_sensor_model.sv      ← SPI Slave 时序模型（外部 SPI 传感器行为）
│   ├── i2c_master_model.sv      ← [备用] 60 行轻量 I2C Master（当前未启用）
│   ├── i2c_slv_model.sv         ← [备用] I2C Slave 占位（DUT RTL 已含，未启用）
│   ├── cpu_model.sv             ← [占位] CPU APB 模型（后续 standalone 用）
│   ├── i2c_master_model.v       ← [工作机] 来自 I2C_IT，含 PMBus 栈
│   ├── apb_master_model.v       ← [工作机] i2c_master_model.v 内 `include
│   ├── pmb_top.v                ← [工作机] PMBus 协议栈顶层
│   ├── pmb_*.v                  ← [工作机] PMBus 子模块（FIFO/FSM/滤波/同步等）
│   ├── pmbus_reg.sv             ← [工作机] PMBus 寄存器定义
│   └── std_*.v                  ← [工作机] 标准单元（仿真用空壳）
│
├── tb/                          ← 测试平台
│   ├── tb_spi.sv                ← 顶层 module：时钟/复位生成 + 模型例化 + DUT 例化
│   ├── tb_define.v              ← `timescale 定义
│   ├── tb_include.sv            ← 统一文件 `include（引用 test/ 下用例）
│   ├── spi_task.sv              ← 核心任务库（I2C 配置 + SPI 帧操作）
│   ├── filelist_spi             ← 编译文件列表
│   └── top/                     ← [预留] Chip Top Wrapper，与 I2C_IT 一致
│
├── test/                        ← 测试用例
│   └── base_test.sv             ← 基础测试（program）：I2C init → SPI init → loopback
│
└── sim/                         ← 仿真运行
    ├── Makefile                 ← 编译运行脚本
    └── wave.tcl                 ← 波形配置
```

---

## 各文件详细说明

### `model/` — 行为级模型

| 文件 | 来源 | 作用 |
|------|------|------|
| `memory/main_mem_model.v` | 自研，从 `spi_sensor_model.sv` 拆分 | 128K×8bit 行为级存储器，供 SPI sensor 和外部使用 |
| `soc_model.sv` | 自研 | SOC 行为模型：FIFO 收发 (`fifo_put`/`fifo_get`) + SPI 帧组帧 (`spi_frame_write`/`spi_frame_read_with_data`/`spi_frame_recv`) + 可配置 CRC-8/CRC-16 追加 (`crc_append`) |
| `spi_sensor_model.sv` | 自研，对标 I2C_IT 的 `i2c_sensor_model.v` | SPI Slave 时序模型，根据 CPOL/CPHA 在 SCLK 边沿采样/驱动，内部挂 `main_mem_model` |
| `i2c_master_model.sv` | 自研轻量版 | **备用** 60 行无依赖 I2C Master，保留但 filelist 未启用 |
| `i2c_slv_model.sv` | 自研 | **备用** I2C Slave 占位，保留但 filelist 未启用（DUT RTL 含真实 I2C Slave） |
| `cpu_model.sv` | 自研 | **占位** CPU APB 模型文件 |

以下文件需从 I2C_IT 项目复制（工作机操作）：

| 文件 | 作用 |
|------|------|
| `i2c_master_model.v` | I2C Master 行为模型，内 `include "apb_master_model.v"`，内部例化 `pmb_top` 产生 I2C 时序 |
| `apb_master_model.v` | APB Master 时序生成，定义 `apb_wr`/`apb_rd` 任务 |
| `pmb_top.v` | PMBus 协议栈顶层，内部例化 master FSM / slave FSM / FIFO / 时钟生成 |
| `pmb_master_logic.v` | PMBus Master 核心状态机 |
| `pmb_master_filter.v` | 毛刺滤波 |
| `pmb_master_clock_gate.v` | 时钟门控 |
| `pmb_slave_top.v` / `pmb_slave_async.v` / `pmb_slave_filt.v` | PMBus Slave 模块（本例未用，但为顶层依赖） |
| `pmb_scl_sync.v` / `pmb_rst_sync.v` / `pmb_sync.v` | 同步器/CDC |
| `pmb_pinmux.v` | 管脚复用 |
| `pmb_fifo.v` | 发送/接收 FIFO |
| `pmb_and2.v` / `pmb_mux2.v` | 门级单元（Die-to-Die 连接） |
| `pmb_dft_se.v` | DFT scan enable |
| `pmbus_reg.sv` | PMBus 寄存器地址映射 |
| `pmbus_reg_bak.sv` | PMBus 影子寄存器 |
| `std_icg_test.v` / `std_an2.v` / `std_mux2.v` | 标准单元仿真模型 |

### `tb/` — 测试平台

| 文件 | 作用 |
|------|------|
| `tb_spi.sv` | 顶层 module：生成 3 个时钟 (`clk_spi`=333MHz, `clk_lf`, `clk_reg`=25MHz) + 复位，例化 `u_ext_i2c_mst`(I2C_IT master), `u_soc`, `u_sensor`, `u_ss12`(DUT) |
| `tb_define.v` | `` `timescale 1ns / 1ps `` |
| `tb_include.sv` | `` `include "../test/base_test.sv" `` — 编译时自动加载测试用例 |
| `spi_task.sv` | 核心任务库：`ext_apb_wr`→APB 驱动 / `ext_i2c_init`→I2C master 初始化 / `ext_i2c_wr_sub`→推一字节 / `ext_i2c_wr_reg16`→I2C 写 16-bit 地址 / `ext_i2c_rd_reg16`→TODO / `spi_init`→配 SPI 内部寄存器 / `spi_master_write/read`→SPI 帧操作 / `spi_check_timeout_err`→读超时计数 / `spi_set_crc_mode`→CRC 模式 |
| `filelist_spi` | 编译文件列表，按 model → DUT RTL → TB → test 分组 |

### `test/` — 测试用例

| 文件 | 作用 |
|------|------|
| `base_test.sv` | 基础测试用例（`program`）：Phase1 I2C master init → Phase2 SPI 内部寄存器配置 → Phase3 SPI loopback 收发验证 |

### `sim/` — 仿真运行

| 文件 | 作用 |
|------|------|
| `Makefile` | 编译运行脚本（调用 VCS/Xcelium/Modelsim） |
| `wave.tcl` | 波形转储配置 |

---

## 信号流

### 配置路径
```
base_test.sv
  └─ spi_task.sv: ext_i2c_init / ext_i2c_wr_reg16
       └─ ext_apb_wr  ──APB──→  u_ext_i2c_mst (i2c_master_model)
                                 └─ pmb_top ──I2C──→ u_ss12 (DUT i2cs)
                                                       └─ SPI 内部寄存器
```

### SPI 数据路径
```
u_soc (soc_model)
  └─ spi_frame_write ──fifo_put──→ u_ss12 (SOC FIFO IN)
                                     └─ spi_wrp ──SPI──→ u_sensor (spi_sensor_model)
                                                            └─ main_mem_model
  u_soc (soc_model)
  └─ spi_frame_recv ←──fifo_get── u_ss12 (SOC FIFO OUT)
```

---

## 与 I2C_IT 结构对比

| 功能 | I2C_IT | SPI_IT |
|------|--------|--------|
| 顶层 TB | `tb/tb.sv` | `tb/tb_spi.sv` |
| 任务封装 | `tb/i2c_task.sv` | `tb/spi_task.sv` |
| I2C Master | `model/i2c_model/i2c_master_model.v` | `model/i2c_master_model.v`(复制) |
| APB 驱动 | `model/i2c_model/apb_master_model.v` | `model/apb_master_model.v`(复制) |
| PMBus 栈 | `model/i2c_model/pmb_*` | `model/pmb_*`(复制) |
| Sensor 模型 | `model/i2c_model/i2c_slave/i2c_sensor_model.v` | `model/spi_sensor_model.sv` |
| Memory 模型 | `memory/main_mem_model.v` | `model/memory/main_mem_model.v` |
| CRC 模型 | `model/i2c_model/crc8_8bit_model.v` | 内嵌 `soc_model.sv` |
| 文件列表 | `tb/filelist` / `filelist_ss11` / `filelist_ss12` | `tb/filelist_spi` |
| 测试用例 | `test/base_test.sv` | `test/base_test.sv` |
| 编译脚本 | `sim/Makefile` + `sim/run_cmd` | `sim/Makefile`（缺 `run_cmd`） |
| 波形 | `sim/dump_waveform.tcl` | `sim/wave.tcl` |
| Chip Top | `top/` | `tb/top/`(预留) |

---

## 遗留项

| # | 事项 | 原因 |
|---|------|------|
| 1 | `ext_i2c_rd_reg16` 未实现 | 需要 I2C_IT 的读任务定义（RX FIFO 寄存器地址和读取流程） |
| 2 | `i2c_master_model.v` + `pmb_*` 未在仓库中 | 文件来自 I2C_IT，需在工作机上复制 |
| 3 | `tb/top/` 空目录 | Chip Top Wrapper，后续 DUT 集成时使用 |
| 4 | `sim/run_cmd` 缺少 | 参考 I2C_IT 的 run_cmd 创建 |
