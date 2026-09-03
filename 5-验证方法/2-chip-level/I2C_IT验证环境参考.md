# I2C_IT 验证环境参考

> Chip-Level I2C 集成测试环境结构，作为 SPI_IT 的参考对照。

---

## 目录结构

```
blocks/i2c_it/
├── model/
│   └── i2c_model/                  ← PMBus over I2C 完整模型
│       ├── apb_master_model.v       CPU APB 寄存器访问模型
│       ├── i2c_master_model.v        I2C Master 行为模型
│       ├── i2c_master_model_fpga.v   I2C Master (FPGA 适配版)
│       ├── i2c_slave/
│       │   ├── i2c_sensor_model.v    I2C Slave 时序模型（对应 spi_sensor_model）
│       │   └── i2c_slv_reg.v         Slave 内部寄存器（已合入 main_mem_model）
│       ├── crc8_8bit_model.v         CRC-8 校验模型（soc_model 内嵌了同样功能）
│       ├── pec.v                     PEC (Packet Error Checking) 计算
│       ├── pmb_top.v                 PMBus 顶层
│       ├── pmb_master_top.v          PMBus Master 顶层
│       ├── pmb_master_top_nopec.v    PMBus Master (无 PEC)
│       ├── pmb_master_logic.v        Master 核心 FSM
│       ├── pmb_master_filter.v       Master 毛刺滤波
│       ├── pmb_master_clock_gate.v   Master 时钟门控
│       ├── pmb_slave_top.v           PMBus Slave 顶层
│       ├── pmb_slave_async.v         Slave 异步/CDC 处理
│       ├── pmb_slave_filt.v          Slave 毛刺滤波
│       ├── pmb_scl_sync.v            SCL 时钟同步
│       ├── pmb_rst_sync.v           复位同步器
│       ├── pmb_sync.v               通用同步器
│       ├── pmb_pinmux.v             I2C/PMBus 管脚复用
│       ├── pmb_fifo.v               发送/接收 FIFO
│       ├── pmb_and2.v               与门（Die-to-Die 连接）
│       ├── pmb_mux2.v               MUX
│       ├── pmb_dft_se.v             DFT scan enable
│       ├── pmbus_reg.sv             PMBus 寄存器定义
│       ├── pmbus_reg_bak.sv         PMBus 影子寄存器
│       ├── rtl.f                    标准编译文件列表
│       └── rtl_fpga.f               FPGA 编译文件列表
├── memory/
│   └── main_mem_model.v             独立的行为级存储器模型 ← SPI_IT 已照此拆分
├── sim/
│   ├── dump_waveform.tcl            波形转储配置
│   ├── Makefile                     编译运行脚本
│   └── run_cmd                      命令行启动脚本 ← SPI_IT 缺少
├── tb/
│   ├── filelist                     文件列表
│   ├── filelist_ss11                SS11 项目文件列表
│   ├── filelist_ss12                SS12 项目文件列表 ← SPI_IT 只有单文件列表
│   ├── i2c_task.sv                  测试任务封装（对应 spi_task.sv）
│   ├── tb.sv                        测试平台顶层（对应 tb_spi.sv）
│   ├── tb_define.v                  宏定义
│   └── tb_include.sv                通用 include
├── test/
│   └── base_test.sv                 基础测试用例
└── top/                             空目录（预留 Chip Top Wrapper）
```

---

## 与 SPI_IT 的映射关系

| I2C_IT 组件 | SPI_IT 组件 | 说明 |
|------------|------------|------|
| `i2c_master_model.v` | ✅ 从 I2C_IT 复制 | I2C Master 模型，通过 APB 配置 PMBus 栈驱动 I2C |
| `apb_master_model.v` | ✅ 从 I2C_IT 复制 | `i2c_master_model.v` 内 `include` 的 APB 驱动 |
| `pmb_*` 全套 | ✅ 从 I2C_IT 复制 | PMBus 协议栈，作为 master 的依赖（DUT 本身走普通 I2C） |
| `pmbus_reg.sv` | ✅ 从 I2C_IT 复制 | PMBus 寄存器定义 |
| i2c_sensor_model.v | `spi_sensor_model.sv` | SPI Slave 时序模型，角色等价 |
| `i2c_slv_reg.v` | 已合入 `main_mem_model.v` | Slave 寄存器访问逻辑 |
| `apb_master_model.v` | `cpu_model.sv` | APB 寄存器访问，功能等价 |
| `crc8_8bit_model.v` | 内嵌在 `soc_model.sv` | CRC-8 计算 |
| `main_mem_model.v` | ✅ 已拆分 | 独立 memory 模型 |
| `run_cmd` | ❌ 缺少 | 命令行启动脚本 |
| `filelist_ss11/ss12` | ❌ 单文件列表 | 多项目文件列表 |

---

## 关键决策记录

### 2026-07-08: I2C Master 方案选择

**问题**：SPI_IT 需要通过 I2C 配置 DUT 寄存器，用什么 I2C master 模型？

**方案对比**：

| 方案 | 优点 | 缺点 |
|------|------|------|
| A: 自研轻量 master | 60 行，无依赖，`i2c_wr_reg16` 一行配寄存器 | 不是"黄金"环境，DUT I2C 协议变复杂要重写 |
| B: I2C_IT 现成 master | 已验证，APB 配置 PMBus 栈，灵活度高 | 依赖 `pmb_*` 和 `apb_master_model.v`，测试用例写 4~6 行 APB 配一个寄存器 |

**结论**：选 B（用 I2C_IT 现成的）。

**理由**：  
- I2C_IT 的 master 已经是团队验证过的
- DUT 内部有多个 I2C host，后续可能用到 I2C_IT 的多 host 框架
- 自研轻量模型缺少 RX FIFO 读路径（读任务需要 I2C_IT 的 `rx_host` 定义）

**当前状态**：
- `tb_spi.sv` 实例化 `i2c_master_model` 为 `u_ext_i2c_mst`
- `spi_task.sv` 定义了 `ext_apb_wr` / `ext_i2c_init` / `ext_i2c_wr_sub` / `ext_i2c_wr_reg16`
- `ext_i2c_rd_reg16` 待实现（需 I2C_IT 的读任务定义）
- `i2c_master_model.sv`（轻量版）和 `i2c_slv_model.sv` 保留但未在 filelist 中启用

---

## 实测结论：DUT 的 I2C Slave = 普通 I2C (非 PMBus)

检查 DUT (`i2cs` / `i2cs_sla_wrp`) 接口后确认：

| 特征 | PMBus 特征 | DUT i2cs | 结论 |
|------|-----------|----------|------|
| PEC 信号 | 有 `pec` / `pec_calc` | ❌ 无 | 非 PMBus |
| 命令码 | 有 `cmd_code` | ❌ 无 | 非 PMBus |
| 字节流 | 地址→命令码→块长→数据→PEC | ✅ 地址→16bit寄存器地址→数据 | 普通 I2C |
| 寄存器地址 | — | `o_reg_adr_std[15:0]` | **16-bit 地址** |

**注意**：DUT 的 I2C Slave 模块 (`i2cs`) 是普通 I2C 协议，但配置路径使用的 **I2C Master 模型来自 I2C_IT**，其内部通过 `pmb_top`（PMBus 协议栈）+ APB 接口控制。这是 master 侧的实现选择，与 DUT 侧的协议无关。

对应关系：
```
测试用例 (spi_task.sv) ──APB write──→ i2c_master_model (I2C_IT)
    ↓ pmb_top 内部状态机
    ↓ SDA/SCL (普通 I2C)
DUT i2cs (普通 I2C, 16-bit reg addr)
```

## SPI_IT 下一步可补充项

1. **`run_cmd`** — 参考 I2C_IT 的 run_cmd，写 SPI 的仿真启动脚本
2. **`filelist_ss12` 风格** — 多项目 filelist
3. **`top/` 占位** — 与 I2C_IT 保持一致，预留空目录
