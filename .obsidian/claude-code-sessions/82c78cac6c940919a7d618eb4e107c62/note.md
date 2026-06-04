SPI Slave 验证文档

---

# **1. 验证概述**

## **1.1 文档目的**

本文档针对 SPI Slave 模块的 UVM 验证平台，详细描述验证环境架构、测试点规划、测试用例设计等内容，为验证工作的执行和回归提供参考依据。

## **1.2 验证方法学**

本验证平台采用 UVM（Universal Verification Methodology） 方法学，基于 SystemVerilog 语言实现。验证策略如下：

· 激励生成：通过 UVM Sequence 机制生成各类 SPI 事务激励，覆盖正常操作和异常场景

· 协议检查：Monitor 实时采样接口信号，进行协议合规性检查和 CRC 校验

· 功能覆盖：通过 Covergroup 量化验证覆盖率，确保所有功能点被充分验证

· 断言验证：在 Monitor 中嵌入 SVA 并发断言，对 FSM 状态转换、错误处理等关键行为进行实时检查

## **1.3 验证目标**

|   |   |
|---|---|
|**目标**|**说明**|
|功能正确性|验证 SPI Slave 在所有 SPI 模式下正确处理写命令、读命令和读数据命令|
|协议合规性|验证帧格式、CRC-8 校验、CS 时序等符合协议规范|
|错误处理|验证 CRC 错误、超时错误、无效地址等异常场景下的行为|
|边界条件|验证最小/最大 payload、边界地址等极端情况|
|状态机覆盖|验证 FSM 全部 8 个状态及所有合法状态转换路径|
|覆盖率达标|功能覆盖率达到 100%，代码覆盖率达到目标值|

## **1.4 验证环境结构**

┌─────────────────────────────────────────────────────────────┐  
│                    spi_base_test (测试层)                     │  
│    ├── spi_config ─── config_db ──> 所有组件                  │  
│    └── spi_env (环境层)                                       │  
│         ├── spi_agent (代理层)                                │  
│         │    ├── uvm_sequencer#(spi_transaction)  (排序器)    │  
│         │    ├── spi_driver  <── vif.DRV          (驱动器)    │  
│         │    └── spi_monitor <── vif.MON ──> ap   (监测器)    │  
│         └── spi_coverage    <── ap (analysis_export) (覆盖率) │  
├─────────────────────────────────────────────────────────────┤  
│                    tb_top (顶层测试平台)                       │  
│    ├── spi_slave_intf (接口)                                  │  
│    ├── ips_lib_asyc_fifo (RX 异步 FIFO)                      │  
│    ├── spi_slave_wrapper -> spi_slave (DUT)                   │  
│    └── config_db 桥接: spi_config -> 接口信号                  │  
└─────────────────────────────────────────────────────────────┘

---

# **2. 待测设计概述**

## **2.1 DUT 模块说明**

待测设计（DUT）为 spi_slave 模块，由 spi_slave_wrapper 封装实例化。该模块实现了一个 SPI 从设备接口，支持与外部 SPI 主设备进行串行通信，并通过异步 FIFO 与片上 SOC 进行数据交互。

## **2.2 DUT 端口列表**

### **2.2.1 SPI 总线信号**

|   |   |   |   |
|---|---|---|---|
|**信号名**|**方向**|**位宽**|**说明**|
|spi_clk|input|1|SPI 时钟域|
|spi_rst_n|input|1|低电平有效复位|
|clk_100mhz|input|1|100MHz 系统时钟|
|rst_100mhz|input|1|系统复位（高电平有效）|
|spi_sck|input|1|SPI 串行时钟（来自主设备）|
|spi_cs|input|1|SPI 片选信号|
|spi_mosi|input|1|SPI 主出从入数据线|
|spi_miso|output|1|SPI 主入从出数据线|

### **2.2.2 异步 FIFO TX 接口（DUT → SOC）**

|   |   |   |   |
|---|---|---|---|
|**信号名**|**方向**|**位宽**|**说明**|
|asyc_fifo_tx_n_empty|output|1|TX FIFO 非空标志|
|asyc_fifo_tx_rd_en|input|1|TX FIFO 读使能|
|asyc_fifo_tx_rdata|output|10|TX FIFO 读数据|

### **2.2.3 异步 FIFO RX 接口（SOC → DUT）**

|   |   |   |   |
|---|---|---|---|
|**信号名**|**方向**|**位宽**|**说明**|
|asyc_fifo_rx_wr_en|input|1|RX FIFO 写使能|
|asyc_fifo_rx_n_full|output|1|RX FIFO 非满标志|
|asyc_fifo_rx_wdata|input|8|RX FIFO 写数据|
|asyc_fifo_rx_n_empty|output|1|RX FIFO 非空标志|
|asyc_fifo_rx_rd_en|input|1|RX FIFO 读使能（DUT 侧）|
|asyc_fifo_rx_rdata|output|8|RX FIFO 读数据|

### **2.2.4 配置寄存器**

|   |   |   |   |
|---|---|---|---|
|**信号名**|**方向**|**位宽**|**说明**|
|spi_slv_en_reg|input|1|从设备使能|
|spi_cpol_reg|input|1|时钟极性|
|spi_cpha_reg|input|1|时钟相位|
|spi_cs_act_pol_reg|input|1|CS 有效极性|
|spis_ext_data_len_ins_reg|input|1|扩展数据长度模式|
|spis_dummy_ins_reg|input|8|Dummy 字节数|
|spis_state_ack_tout_step_reg|input|2|超时步长|
|spis_state_ack_thrs_reg|input|8|超时阈值|

### **2.2.5 状态输出**

|   |   |   |   |
|---|---|---|---|
|**信号名**|**方向**|**位宽**|**说明**|
|spis_state_code|output|3|FSM 状态编码（S0-S7）|
|spis_state_code_vld|output|1|状态码有效标志|
|spis_fail_state_data|output|64|失败状态数据（8×8 bit）|

### **2.2.6 错误输出**

|   |   |   |
|---|---|---|
|**信号名**|**方向**|**说明**|
|loc_rw_err|output|LOC/RW 错误|
|wait_read_data_cmd_flag_0_err|output|等待读数据标志 0 错误|
|wait_read_data_cmd_flag_1_err|output|等待读数据标志 1 错误|
|read_data_cmd_mp_head_mis_err|output|读数据命令 MP 头部不匹配错误|
|cmd_crc8_err|output|CRC-8 校验错误|
|wr_cmd_rcd_err|output|写命令 RCD 错误|
|rd_cmd_rcd_err|output|读命令 RCD 错误|
|spis_state_ack_tout_err|output|状态确认超时错误|

## **2.3 FSM 状态定义**

DUT 内部状态机包含 8 个状态，3-bit 编码：

|   |   |   |
|---|---|---|
|**编码**|**状态名**|**说明**|
|S0 (000)|IDLE|空闲状态，等待 CS 有效|
|S1 (001)|WRITE_CMD|处理写命令|
|S2 (010)|WAIT_WRITE_CONFIRM|等待 SOC 写确认|
|S3 (011)|READ_CMD|处理读命令|
|S4 (100)|WAIT_READ_CONFIRM|等待 SOC 读确认|
|S5 (101)|READ_SUCCESS|读操作成功|
|S6 (110)|READ_FAIL|读操作失败|
|S7 (111)|READ_DATA_CMD|处理读数据命令|

## **2.4 SPI 协议帧格式**

### **2.4.1 帧结构**

|   |   |
|---|---|
|**命令类型**|**帧内容**|
|WR_CMD (01)|cmd_byte + addr_l + ctrl_h + ctrl_l + payload[N] + crc_cmd|
|RD_CMD (10, rd_en=0)|cmd_byte + addr_l + ctrl_h + ctrl_l + crc_cmd|
|RD_CMD (10, rd_en=1)|cmd_byte + addr_l + ctrl_h + ctrl_l + payload[rd_length] + crc_cmd|
|RD_DATA_CMD (11)|cmd_byte + addr_l + ctrl_h + ctrl_l + crc_cmd + dummy[M] + data[N] + crc_data|

### **2.4.2 字段说明**

· cmd_byte：{1'b1, DST_ADDR[1:0]=01, cmd[1:0], DST_PORT[2:0]=010}，8 bit

· addr_l：目标地址，8 bit

· ctrl_h：{rd_en, 1'b0, rd_length[6:0]}，8 bit

· ctrl_l：data_len[7:0]，8 bit

· CRC-8：多项式 0x2F，初始值 0xFF，输入取反，输出取反

### **2.4.3 SPI 模式**

|   |   |   |   |
|---|---|---|---|
|**模式**|**CPOL**|**CPHA**|**说明**|
|Mode 0|0|0|空闲低电平，第一个边沿采样|
|Mode 1|0|1|空闲低电平，第二个边沿采样|
|Mode 2|1|0|空闲高电平，第一个边沿采样|
|Mode 3|1|1|空闲高电平，第二个边沿采样|

---

# **3. 验证环境组件详解**

## **3.1 顶层测试平台（tb_top）**

顶层模块 tb_top 负责：

1. 时钟生成：生成 SPI 时钟（约 333MHz）和 100MHz 系统时钟

2. 复位管理：产生复位信号并管理复位时序

3. 接口实例化：实例化 spi_slave_intf 接口

4. DUT 实例化：实例化 RX 异步 FIFO 和 DUT wrapper

5. 配置桥接：从 UVM config_db 读取 spi_config 对象，将其字段映射到接口信号线

6. UVM 启动：通过 run_test() 启动 UVM 验证平台

7. 超时控制：设置 10ms 仿真超时

## **3.2 接口（spi_slave_intf）**

接口定义了所有 SPI 总线信号、配置寄存器信号、FIFO 信号和 DUT 输出信号，并包含：

· 驱动时钟块（drv_cb）：用于 Driver 驱动信号的时序控制

· 监测时钟块（mon_cb）：用于 Monitor 采样信号的时序控制

· Modport DRV：Driver 侧端口视图

· Modport MON：Monitor 侧端口视图

## **3.3 配置对象（spi_config）**

spi_config 继承自 uvm_object，包含两类配置：

### **3.3.1 DUT 寄存器配置**

|   |   |   |   |
|---|---|---|---|
|**字段**|**类型**|**默认值**|**说明**|
|cpol|bit|随机|时钟极性|
|cpha|bit|随机|时钟相位|
|cs_act_pol|bit|0|CS 有效极性|
|ext_data_len|bit|随机|扩展数据长度模式|
|dummy_ins|bit[7:0]|0|Dummy 字节数|
|slv_en|bit|1|从设备使能|
|tout_step|bit[1:0]|随机|超时步长|
|tout_thrs|bit[7:0]|随机|超时阈值|

### **3.3.2 测试流程参数**

|   |   |   |
|---|---|---|
|**字段**|**类型**|**说明**|
|num_txns|int|事务数量|
|sck_period_ns|real|SPI 时钟周期（ns）|

支持通过 plusarg 进行参数覆盖。

## **3.4 事务项（spi_transaction）**

spi_transaction 继承自 uvm_sequence_item，建模一个完整的 SPI 命令帧。

### **3.4.1 主要字段**

|   |   |   |
|---|---|---|
|**字段**|**类型**|**说明**|
|cmd|bit[1:0]|命令类型：WR_CMD=01, RD_CMD=10, RD_DATA_CMD=11|
|addr_l|bit[7:0]|目标地址|
|rd_en|bit|读使能标志|
|rd_length|bit[6:0]|读取长度|
|data_len|bit[7:0]|数据长度|
|payload_data|bit[7:0][]|payload 数据数组|
|inject_crc_err|bit|CRC 错误注入标志|
|early_cs_deassert|bit|提前 CS 撤销标志|
|mst_cmd|bit|主设备命令：MST_SUCCESS / MST_FAIL|
|mst_resp_data|bit[7:0][]|主设备响应数据|
|resp_data|bit[7:0][]|响应数据|

### **3.4.2 约束条件**

· payload 大小根据命令类型约束

· 错误注入分布：CRC 错误 5%，提前 CS 撤销 5%，主设备失败 20%

### **3.4.3 关键方法**

· cal_crc8() / calc_crc8()：CRC-8 计算

· build_queue()：构建帧数据队列

· get_frame_len()：计算帧长度

## **3.5 序列（Sequences）**

|   |   |   |
|---|---|---|
|**序列类名**|**说明**|**激励内容**|
|spi_base_seq|基础序列类|空实现，作为父类|
|spi_mixed_seq|混合序列|生成 N 个随机类型的事务|
|spi_write_seq|写序列|生成 N 个写命令（WR_CMD）事务|
|spi_read_seq|读序列|生成 N 个读命令（RD_CMD）事务|
|spi_read_data_seq|读数据序列|生成 N 个读数据命令（RD_DATA_CMD）事务|
|spi_err_inject_seq|错误注入序列|故意注入错误：3 个 CRC 错误 + 3 个无效地址 + 3 个提前 CS 撤销|
|spi_boundary_seq|边界序列|边界条件：最小 payload（1 byte）、最大 payload（64 bytes）、零地址、最大地址（0xFF）|
|spi_b2b_seq|背靠背序列|连续写事务，无帧间间隔|

## **3.6 驱动器（spi_driver）**

spi_driver 继承自 uvm_driver#(spi_transaction)，承担双重角色：

### **3.6.1 SPI 主设备角色**

· 生成 SPI 时钟（可配置周期和极性）

· 驱动 CS 和 MOSI 信号

· 采样 MISO 信号

· 支持全部 4 种 SPI 模式（CPOL/CPHA 组合）

### **3.6.2 SOC 主机角色**

· 每个 SPI 帧完成后，向 RX FIFO 写入主设备响应（确认或确认+失败数据）

· 从 TX FIFO 读取数据

### **3.6.3 内部状态机**

Driver 包含 8 个内部状态：

|   |   |
|---|---|
|**状态**|**说明**|
|IDLE|空闲等待|
|CS_ACTIVE|CS 有效|
|HEADER|发送帧头（4 字节）|
|PAYLOAD|发送 payload 数据|
|CRC|发送 CRC 校验字节|
|CS_DEASSERT|CS 撤销|
|MST_RX_CMD|主设备接收命令|
|MST_RX_DATA|主设备接收数据|

### **3.6.4 驱动流程**

1. 从 Sequencer 获取事务项

2. 根据配置生成 SPI 时钟

3. 驱动 CS 有效

4. 逐 bit 发送帧头（cmd_byte + addr_l + ctrl_h + ctrl_l）

5. 逐 bit 发送 payload（如有）

6. 逐 bit 发送 CRC

7. 对 RD_DATA_CMD：发送 dummy 字节，然后接收数据字节和 CRC

8. 驱动 CS 撤销

9. 向 RX FIFO 写入主设备响应

10. 复位信号状态

## **3.7 监测器（spi_monitor）**

spi_monitor 继承自 uvm_mymonitor，是验证平台的核心检查组件，包含 635 行代码，运行 6 个并行检查任务。

### **3.7.1 帧收集任务（collect_spi_frames）**

· 检测 CS 上升沿/下降沿

· 逐 bit 采样 MOSI/MISO 数据

· 验证首字节（loc=1, rw!=00）

· 帧结束时进行 CRC-8 校验

· 验证帧结构（header + payload + CRC 长度一致性）

· 解析字节为 spi_transaction 并发送到分析端口

### **3.7.2 FSM 状态转换检查（check_fsm_transitions）**

· 跟踪 spis_state_code 变化

· 验证所有 FSM 状态转换是否符合合法状态图（13 条合法转换路径）

### **3.7.3 错误标志检查（check_error_flags）**

· 监测 7 个错误输出信号

· 记录每个错误事件

· 验证 CRC 错误后 FSM 在 20 个周期内返回 IDLE

· 验证超时错误后 FSM 在 10 个周期内返回 IDLE

· 检查 CRC 错误和超时错误的互斥性

### **3.7.4 计数器检查（check_counters）**

· 周期精确的计数器检查（预留接口）

### **3.7.5 FIFO 接口检查（check_fifo_interfaces）**

· 监测 RX FIFO 满状态

### **3.7.6 信号完整性检查（check_signal_integrity）**

· 检查 state_code_vld 信号无 X/Z

· 检查 state_code 在有效时无 X/Z

· 检查错误输出信号无 X/Z

· 检查活跃帧期间 MISO 信号无 X/Z

### **3.7.7 SVA 并发断言（A1-A13）**

|   |   |
|---|---|
|**断言ID**|**检查内容**|
|A1|复位后 FSM 进入 IDLE 状态|
|A2|IDLE 状态下不发生超时|
|A3|状态码有效范围（0-7）|
|A4|state_code_vld 信号无 X/Z|
|A5|错误输出信号无 X/Z|
|A6|合法 FSM 状态转换|
|A7|CRC 错误强制返回 IDLE|
|A8|超时错误强制返回 IDLE|
|A9|单步 FSM 跳转|
|A10|vld=0 时状态码稳定|
|A11|CRC 错误与超时错误互斥|
|A12|帧期间 CS 保持有效|
|A13|复位期间信号初始化|

### **3.7.8 监测器内部覆盖组（cg_mon）**

· 覆盖全部 8 个 FSM 状态

· 覆盖所有错误标志

· CPOL × CPHA 交叉覆盖

### **3.7.9 仿真结束统计报告**

在仿真结束时输出：帧计数、各错误计数、覆盖率百分比。

## **3.8 覆盖率收集器（spi_coverage）**

spi_coverage 继承自 uvm_subscriber#(spi_transaction)，通过分析端口连接到 Monitor，包含 3 个覆盖组：

### **3.8.1 命令覆盖组（cg_cmd）**

|   |   |
|---|---|
|**覆盖点**|**覆盖项**|
|cmd_type|WR_CMD, RD_CMD, RD_DATA_CMD|
|crc_err|0, 1|
|spi_mode|CPOL × CPHA（4 bins）|
|cmd × mode|命令类型与 SPI 模式交叉|
|cmd × error|命令类型与错误注入交叉|

### **3.8.2 Payload 长度覆盖组（cg_payload_len）**

|   |   |   |
|---|---|---|
|**区间**|**范围**|**说明**|
|min|1 byte|最小 payload|
|short|2-8 bytes|短 payload|
|medium|9-32 bytes|中等 payload|
|long|33-63 bytes|长 payload|
|max|64 bytes|最大 payload|

### **3.8.3 地址覆盖组（cg_addr）**

|   |   |
|---|---|
|**区间**|**范围**|
|low|0-127|
|high|128-255|

## **3.9 代理（spi_agent）**

spi_agent 继承自 uvm_agent，包含：

· spi_driver：驱动器

· spi_monitor：监测器

· uvm_sequencer#(spi_transaction)：排序器

在 ACTIVE 模式下创建 Driver 并连接 Sequencer 到 Driver 的 seq_item_port；始终创建 Monitor。

## **3.10 环境（spi_env）**

spi_env 继承自 uvm_env，包含：

· spi_agent：代理

· spi_coverage：覆盖率收集器

连接 Monitor 的分析端口到覆盖率收集器的 analysis_export。

注意：本验证平台没有独立的 Scoreboard，所有检查均在 Monitor 内部通过断言和即时检查完成。

---

# **4. 测试点与需求**

## **4.1 测试点矩阵**

|   |   |   |   |
|---|---|---|---|
|**编号**|**测试点**|**优先级**|**覆盖测试**|
|TP-01|写命令基本功能|P0|smoke, all_modes, wr_rd|
|TP-02|读命令基本功能（无数据）|P0|all_modes, wr_rd|
|TP-03|读命令基本功能（有数据）|P0|all_modes, wr_rd|
|TP-04|读数据命令基本功能|P0|all_modes|
|TP-05|CRC-8 校验正确性|P0|smoke, all_modes|
|TP-06|CRC 错误检测与处理|P0|err|
|TP-07|超时错误检测与处理|P1|err|
|TP-08|无效地址处理|P1|err|
|TP-09|提前 CS 撤销处理|P1|err|
|TP-10|SPI Mode 0（CPOL=0, CPHA=0）|P0|all_modes|
|TP-11|SPI Mode 1（CPOL=0, CPHA=1）|P0|all_modes|
|TP-12|SPI Mode 2（CPOL=1, CPHA=0）|P0|all_modes|
|TP-13|SPI Mode 3（CPOL=1, CPHA=1）|P0|all_modes|
|TP-14|最小 payload（1 byte）|P1|boundary|
|TP-15|最大 payload（64 bytes）|P1|boundary|
|TP-16|零地址|P2|boundary|
|TP-17|最大地址（0xFF）|P2|boundary|
|TP-18|背靠背连续传输|P1|b2b|
|TP-19|FSM 状态全覆盖|P0|regression|
|TP-20|FSM 合法状态转换全覆盖|P0|regression|
|TP-21|CRC 错误后 FSM 返回 IDLE|P0|err|
|TP-22|超时错误后 FSM 返回 IDLE|P0|err|
|TP-23|CRC 与超时错误互斥|P1|err|
|TP-24|信号完整性（无 X/Z）|P1|all|
|TP-25|RX FIFO 满状态处理|P2|b2b|
|TP-26|主设备成功响应|P0|smoke, wr_rd|
|TP-27|主设备失败响应|P1|all_modes|

## **4.2 覆盖率目标**

|   |   |   |
|---|---|---|
|**覆盖率类型**|**目标**|**说明**|
|FSM 状态覆盖率|100%|全部 8 个状态均被访问|
|SPI 模式覆盖率|100%|全部 4 种 CPOL/CPHA 组合|
|错误标志覆盖率|100%|每个错误标志至少触发一次|
|命令类型覆盖率|100%|Write、Read、ReadData 命令|
|FIFO 覆盖率|100%|TX/RX FIFO 读写均被验证|
|边界覆盖率|100%|字节数限制、数据长度边界|
|Payload 长度覆盖率|100%|5 个区间（min/short/medium/long/max）|
|地址覆盖率|100%|低地址和高地址区间|

## **4.3 SVA 断言检查清单**

|   |   |   |
|---|---|---|
|**ID**|**断言描述**|**检查内容**|
|A1|复位后状态检查|复位释放后 FSM 进入 IDLE|
|A2|IDLE 超时检查|IDLE 状态下不发生超时错误|
|A3|状态码范围检查|状态码在合法范围 0-7 内|
|A4|有效信号 X/Z 检查|state_code_vld 无 X/Z|
|A5|错误信号 X/Z 检查|所有错误输出无 X/Z|
|A6|FSM 转换合法性|状态转换符合定义的状态图|
|A7|CRC 错误强制 IDLE|CRC 错误后强制返回 IDLE|
|A8|超时错误强制 IDLE|超时错误后强制返回 IDLE|
|A9|单步跳转检查|FSM 每次只跳转一个状态|
|A10|状态稳定检查|vld=0 时状态码保持稳定|
|A11|错误互斥检查|CRC 错误和超时错误不同时发生|
|A12|CS 保持检查|帧传输期间 CS 保持有效|
|A13|复位初始化检查|复位期间信号正确初始化|

---

# **5. 测试用例详细说明**

## **5.1 测试用例总览**

|   |   |   |   |
|---|---|---|---|
|**测试名称**|**测试类**|**使用序列**|**说明**|
|spi_smoke_test|spi_smoke_test|spi_write_seq ×5|基础写操作冒烟测试|
|spi_all_modes_test|spi_all_modes_test|spi_mixed_seq ×10|全 SPI 模式混合命令测试|
|spi_err_test|spi_err_test|spi_write_seq ×3 + spi_err_inject_seq|错误注入测试|
|spi_wr_rd_test|spi_wr_rd_test|spi_write_seq ×3 + spi_read_seq ×3|写后读测试|
|spi_boundary_test|spi_boundary_test|spi_boundary_seq|边界条件测试|
|spi_b2b_test|spi_b2b_test|spi_b2b_seq ×10|背靠背传输测试|
|spi_regression_test|spi_regression_test|spi_write_seq ×10 + spi_read_seq ×10 + spi_err_inject_seq + spi_boundary_seq|完整回归测试|

## **5.2 spi_smoke_test（冒烟测试）**

目的：验证基本的写操作功能，确认验证环境搭建正确。

测试流程：

1. 创建 spi_config，使用默认配置（slv_en=1, cs_act_pol=0）

2. 执行 spi_write_seq，生成 5 个写命令事务

3. 每个事务包含随机 payload（1-64 bytes）

4. 验证 DUT 正确接收数据并写入 RX FIFO

预期结果：

· 所有 5 个写事务成功完成

· 无 CRC 错误

· Monitor 无 uvm_error 报告

· FSM 正常经历 IDLE → WRITE_CMD → WAIT_WRITE_CONFIRM → IDLE 转换

覆盖测试点：TP-01, TP-05, TP-10, TP-24, TP-26

---

## **5.3 spi_all_modes_test（全模式测试）**

目的：验证 DUT 在所有 4 种 SPI 模式下正确处理各种命令类型。

测试流程：

1. 创建 spi_config，随机化 CPOL 和 CPHA

2. 执行 spi_mixed_seq，生成 10 个随机类型事务

3. 事务类型随机选择：WR_CMD、RD_CMD、RD_DATA_CMD

4. 每次仿真覆盖不同的 SPI 模式组合

预期结果：

· 所有事务在对应 SPI 模式下正确完成

· MISO 数据采样正确

· CRC 校验通过

· FSM 状态转换正确

覆盖测试点：TP-01 ~ TP-05, TP-10 ~ TP-13, TP-24, TP-26

---

## **5.4 spi_err_test（错误注入测试）**

目的：验证 DUT 对各类错误的检测和处理能力。

测试流程：

1. 先执行 spi_write_seq ×3 作为热身，确保 DUT 正常工作

2. 执行 spi_err_inject_seq，注入以下错误：

|   |   |   |
|---|---|---|
|**错误类型**|**数量**|**注入方式**|
|CRC 错误|3|将 CRC 字节按位取反|
|无效地址|3|设置 addr_l = 0x00|
|提前 CS 撤销|3|在 payload 传输中途撤销 CS|

预期结果：

· CRC 错误：DUT 检测到 cmd_crc8_err，FSM 在 20 个周期内返回 IDLE

· 无效地址：DUT 检测到 loc_rw_err

· 提前 CS 撤销：DUT 检测到相应错误标志

· 热身阶段无错误

· CRC 错误与超时错误不同时发生

覆盖测试点：TP-06, TP-08, TP-09, TP-21, TP-23, TP-24

---

## **5.5 spi_wr_rd_test（写后读测试）**

目的：验证写操作后读操作的正确性，模拟实际使用场景。

测试流程：

1. 执行 spi_write_seq ×3，写入数据到 DUT

2. 执行 spi_read_seq ×3，从 DUT 读取数据

3. 验证读写操作的独立性和正确性

预期结果：

· 写事务成功完成，数据写入 RX FIFO

· 读事务成功完成，数据从 TX FIFO 读出

· FSM 正确经历写路径和读路径的状态转换

· 读写操作之间无干扰

覆盖测试点：TP-01, TP-02, TP-03, TP-05, TP-26

---

## **5.6 spi_boundary_test（边界测试）**

目的：验证 DUT 在边界条件下的行为。

测试流程：

执行 spi_boundary_seq，覆盖以下边界场景：

|   |   |   |
|---|---|---|
|**场景**|**参数**|**说明**|
|最小 payload|data_len = 1|1 字节 payload|
|最大 payload|data_len = 64|64 字节 payload|
|零地址|addr_l = 0x00|地址下界|
|最大地址|addr_l = 0xFF|地址上界|

预期结果：

· 所有边界事务正确完成

· 帧长度计算正确

· CRC 校验正确

· 无溢出或截断

覆盖测试点：TP-14, TP-15, TP-16, TP-17

---

## **5.7 spi_b2b_test（背靠背测试）**

目的：验证连续无间隔传输的可靠性。

测试流程：

1. 执行 spi_b2b_seq ×10

2. 每个序列生成连续的写命令，帧间无任何延迟

3. CS 撤销后立即进行下一次 CS 有效

预期结果：

· 所有背靠背事务正确完成

· DUT 能够正确处理连续传输

· FIFO 状态正确更新

· 无数据丢失或覆盖

覆盖测试点：TP-18, TP-25

---

## **5.8 spi_regression_test（回归测试）**

目的：全面回归验证，覆盖所有功能点。

测试流程：

分 4 个阶段执行：

|   |   |   |   |
|---|---|---|---|
|**阶段**|**序列**|**数量**|**说明**|
|1|spi_write_seq|10|写操作验证|
|2|spi_read_seq|10|读操作验证|
|3|spi_err_inject_seq|1|错误注入验证|
|4|spi_boundary_seq|1|边界条件验证|

预期结果：

· 所有阶段通过

· 覆盖率达标（见 4.2 节覆盖率目标）

· 无 uvm_error 报告

· SVA 断言全部通过

覆盖测试点：全部测试点 TP-01 ~ TP-27

---

# **6. 仿真运行指南**

## **6.1 环境要求**

· 仿真器：Xcelium / VCS / Questa

· SystemVerilog 支持

· UVM 1.2 库

## **6.2 运行命令**

### **Xcelium**

# 编译  
make comp  
  
# 运行指定测试  
make sim TEST=spi_smoke_test SEED=random  
  
# 运行回归测试  
make sim TEST=spi_regression_test SEED=random  
  
# 查看波形  
make waves

### **VCS**

# 编译  
make comp SIM=vcs  
  
# 运行  
make sim SIM=vcs TEST=spi_smoke_test SEED=random

### **Questa**

# 编译  
make comp SIM=questa  
  
# 运行  
make sim SIM=questa TEST=spi_smoke_test SEED=random

## **6.3 Plusarg 参数**

|   |   |   |
|---|---|---|
|**参数**|**说明**|**示例**|
|+UVM_TESTNAME|指定测试名|+UVM_TESTNAME=spi_smoke_test|
|+UVM_VERBOSITY|日志级别|+UVM_VERBOSITY=UVM_HIGH|
|+num_txns|事务数量|+num_txns=100|
|+sck_period_ns|SPI 时钟周期|+sck_period_ns=3.0|

---

# **7. 附录**

## **7.1 文件清单**

|   |   |
|---|---|
|**文件路径**|**说明**|
|spi_slave_pkg.svh|UVM 包头文件，包含所有组件|
|spi_slave_intf.sv|SPI 总线接口定义|
|test_plan.md|测试计划文档|
|Makefile|仿真构建脚本|
|filelist.f|编译文件列表|
|seq_item/spi_config.sv|配置对象|
|seq_item/spi_transaction.sv|事务项|
|sequences/spi_sequences.sv|所有序列类|
|driver/spi_driver.sv|驱动器|
|monitor/spi_monitor.sv|监测器|
|coverage/spi_coverage.sv|覆盖率收集器|
|agent/spi_agent.sv|代理|
|env/spi_env.sv|环境|
|test/spi_tests.sv|测试类|
|top/tb_top.sv|顶层测试平台|
|rtl_models/*.sv|DUT 子模块行为模型|

## **7.2 修订记录**

|   |   |   |
|---|---|---|
|**版本**|**日期**|**修改内容**|
|V1.0|-|初始版本|