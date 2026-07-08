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
| `i2c_master_model.v` | ❌ 不需要 | I2C Master 协议（SPI 无对应物） |
| `i2c_sensor_model.v` | `spi_sensor_model.sv` | SPI Slave 时序模型，角色等价 |
| `i2c_slv_reg.v` | 已合入 `main_mem_model.v` | Slave 寄存器访问逻辑 |
| `apb_master_model.v` | `cpu_model.sv` | APB 寄存器访问，功能等价 |
| `crc8_8bit_model.v` | 内嵌在 `soc_model.sv` | CRC-8 计算 |
| `pmb_*` 全套 | ❌ 不需要 | PMBus 协议栈，SPI 不涉及 |
| `main_mem_model.v` | ✅ 已拆分 | 独立 memory 模型 |
| `run_cmd` | ❌ 缺少 | 命令行启动脚本 |
| `filelist_ss11/ss12` | ❌ 单文件列表 | 多项目文件列表 |

---

## PMBus 相关组件说明

参见 `pmb_*` 全套模块详解：
- 这些是 **I2C 物理层之上的 PMBus 协议实现**
- 在 SerDes 芯片中 PMBus 用于电源管理遥测（电压/电流/温度监控）
- **SPI 验证不需要这些**，因为 SPI 物理层完全不同（四线单向驱动，无仲裁/地址/SDA 双向）
- 唯一值得参考的是 `pmb_fifo.v`（硬件 FIFO 结构），如果后续 SPI 需要硬件 FIFO 队列

---

## 实测结论：DUT 的 I2C Slave = 普通 I2C (非 PMBus)

检查 DUT (`i2cs` / `i2cs_sla_wrp`) 接口后确认：

| 特征 | PMBus 特征 | DUT i2cs | 结论 |
|------|-----------|----------|------|
| PEC 信号 | 有 `pec` / `pec_calc` | ❌ 无 | 非 PMBus |
| 命令码 | 有 `cmd_code` | ❌ 无 | 非 PMBus |
| 字节流 | 地址→命令码→块长→数据→PEC | ✅ 地址→16bit寄存器地址→数据 | 普通 I2C |
| 寄存器地址 | — | `o_reg_adr_std[15:0]` | **16-bit 地址** |

**因此 SPI_IT 的 I2C master 不需要 PMBus 栈**，仅需支持：
- 标准 I2C 写: `START + ADDR+W + REG_HI + REG_LO + DATA + STOP`
- 标准 I2C 读: `START + ADDR+W + REG_HI + REG_LO + RESTART + ADDR+R + DATA + NACK + STOP`

I2C_IT 中只需拿 `i2c_master_model.v` 即可，pmb_* 全部不需要。

## SPI_IT 下一步可补充项

1. **`run_cmd`** — 参考 I2C_IT 的 run_cmd，写 SPI 的仿真启动脚本
2. **`filelist_ss12` 风格** — 多项目 filelist
3. **`top/` 占位** — 与 I2C_IT 保持一致，预留空目录
