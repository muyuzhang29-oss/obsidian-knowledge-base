---
tags:
  - Tools
  - QuestaSim
  - 仿真
  - ModelSim
  - Mentor
  - 核心
aliases: [QuestaSim, ModelSim, Questa]
created: 2026-06-02
---

# QuestaSim

## 1. 概述

QuestaSim 是 Siemens EDA（原 Mentor Graphics）推出的功能验证仿真器，是 ModelSim 的升级版本。它支持 VHDL、Verilog、SystemVerilog 和 SystemC 的混合仿真，广泛应用于数字集成电路设计验证。

### 主要特点

| 特点 | 说明 |
|------|------|
| 多语言支持 | VHDL、Verilog、SystemVerilog、SystemC、PSL |
| 高性能仿真 | 优化的仿真引擎，支持增量编译 |
| 断言支持 | SVA (SystemVerilog Assertions) 完整支持 |
| 覆盖率 | 代码覆盖率 + 功能覆盖率 |
| 调试功能 | 强大的波形查看器、断点调试 |
| 脚本化 | Tcl 脚本控制，支持批处理模式 |
| DPI-C | 支持 SystemVerilog DPI 接口 |
| UPF/CPF | 低功耗仿真支持 |

> [!note] QuestaSim vs ModelSim
> QuestaSim 在 ModelSim 基础上增加了：SVA 断言验证、SystemVerilog 验证特性（class、randomize、coverage）、高级调试功能。如果项目使用 UVM 或需要功能覆盖率，应使用 QuestaSim。

---

## 2. 安装与许可证

### 许可证变量

```powershell
# 环境变量设置
$env:LM_LICENSE_FILE = "1717@license_server"
# 或
$env:LICENSE_FILE = "1717@license_server"
$env:QUESTASIM_HOME = "C:\questasim64_2023.4"
$env:PATH += ";$env:QUESTASIM_HOME\win64"
```

### 验证安装

```powershell
vsim -version
# 输出类似: Questa Sim-64 vsim 2023.4 ...
```

---

## 3. 编译和仿真流程

### 标准流程

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  vlib   │───>│  vlog   │───>│  vsim   │───>│   run   │
│ 建库    │    │ 编译    │    │ 加载    │    │ 运行    │
└─────────┘    └─────────┘    └─────────┘    └─────────┘
```

### 完整示例（命令行）

```powershell
# Step 1: 创建工作库
vlib work

# Step 2: 编译源文件
vlog -work work +acc +cover=bcest -f filelist.f

# Step 3: 启动仿真
vsim -lib work -c -coverage top_tb -do "run -all; quit -f"

# 或 GUI 模式
vsim -lib work -coverage top_tb
```

### 完整示例（Tcl 脚本）

```tcl
# sim_run.do
if {[file exists work]} {
    vdel -lib work -all
}
vlib work

# 编译设计文件
vlog -work work +acc=rnbpt \
    ../rtl/top.sv \
    ../rtl/sub_module.sv \
    ../tb/top_tb.sv

# 编译时开启覆盖率
vlog -work work +acc +cover=bcest ../rtl/*.sv

# 加载仿真，设置覆盖率
vsim -lib work -coverage -voptargs="+acc" top_tb

# 添加波形
add wave -r /*

# 运行仿真
run -all
```

---

## 4. 常用命令

### 4.1 库管理

| 命令 | 说明 | 示例 |
|------|------|------|
| `vlib` | 创建库 | `vlib work` |
| `vdel` | 删除库/单元 | `vdel -lib work -all` |
| `vmap` | 映射库 | `vmap work ./work` |
| `vdir` | 列出库内容 | `vdir -lib work` |

```powershell
# 创建和映射库
vlib mylib
vmap mylib ./mylib

# 删除库
vdel -lib work -all

# 列出库中编译的模块
vdir -lib work -short
```

### 4.2 编译命令

| 命令 | 语言 | 说明 |
|------|------|------|
| `vlog` | Verilog/SystemVerilog | 编译 Verilog 和 SV 文件 |
| `vcom` | VHDL | 编译 VHDL 文件 |
| `sccom` | SystemC | 编译 SystemC 文件 |
| `vopt` | - | 优化设计单元 |

```powershell
# Verilog 编译
vlog -work work +acc +define+DEBUG=top_tb \
    -timescale "1ns/1ps" \
    ../rtl/*.sv ../tb/*.sv

# 带文件列表编译
vlog -work work +acc -f filelist.f

# VHDL 编译
vcom -work work -2008 ../rtl/my_vhdl_entity.vhd

# 混合语言编译（VHDL 先编译，Verilog 后编译）
vcom -work work -2008 ../rtl/vhdl_part.vhd
vlog -work work ../rtl/verilog_part.sv

# 优化（可选，提高仿真性能）
vopt +acc=top_tb -o top_tb_opt top_tb work.glbl
```

### 4.3 编译常用选项

```
+acc           启用完整访问（调试需要）
+cover=bcest   启用覆盖率（b=branch, c=condition, e=expression, s=statement, t=toggle）
+define+MACRO  定义宏
-f filelist.f  指定文件列表
-timescale     设置时间精度
-sv            强制 SystemVerilog 解析
-L <lib>       指定搜索库
-incdir <dir>  指定 include 目录
```

### 4.4 仿真命令

```powershell
# 命令行仿真（无 GUI）
vsim -c -lib work top_tb -do "run -all; quit -f"

# GUI 仿真
vsim -lib work top_tb

# 带覆盖率
vsim -lib work -coverage top_tb

# 指定 seed（随机验证）
vsim -lib work top_tb +ntb_random_seed=12345

# 指定波形文件
vsim -lib work -wlf wave.wlf top_tb

# 恢复之前的仿真
vsim -view wave.wlf
```

### 4.5 仿真运行命令（在 vsim 内）

```tcl
# 基本运行
run                        # 运行到结束
run 100                    # 运行 100 个时间单位
run 1000ns                 # 运行 1000ns
run -all                   # 运行到 $finish
run -continue              # 继续运行

# 控制
stop                       # 停止仿真
restart                    # 重新开始
quit -f                    # 退出（-f 不询问确认）

# 断点
break -r /top_tb/u_dut/*   # 在 DUT 信号变化时断点
when -label done {finish == 1} {stop -freeze}
```

### 4.6 波形命令

```tcl
# 添加信号到波形
add wave /top_tb/clk
add wave /top_tb/rst_n
add wave -radix hex /top_tb/data_bus
add wave -r /top_tb/u_dut/*       # 递归添加

# 波形格式
configure wave -signalnamewidth 200
configure wave -timelineunits ns

# 保存波形配置
write format wave -window .main_pane.wave.interior.cs.body.pw.wf wave.do

# 保存波形数据
dataset save wave.wlf
```

---

## 5. GUI 界面介绍

### 主窗口布局

```
┌──────────────────────────────────────────────────────────┐
│  菜单栏: File | Edit | View | Simulate | Tools | Window  │
├──────────────────────────────────────────────────────────┤
│  工具栏: Compile | Simulate | Run | Break | Step         │
├──────────┬───────────────────────────────────────────────┤
│          │                                               │
│  Library │         Source / Wave / List Window            │
│  Window  │                                               │
│          │                                               │
│  (左侧)  │         (主工作区域)                             │
│          │                                               │
├──────────┴───────────────────────────────────────────────┤
│  Transcript（命令行/日志输出）                              │
└──────────────────────────────────────────────────────────┘
```

### 关键窗口

| 窗口 | 用途 | 打开方式 |
|------|------|----------|
| Library | 查看编译库 | View > Library |
| Objects | 查看信号/变量 | View > Objects |
| Wave | 波形查看 | View > Wave |
| Source | 源代码查看 | View > Source |
| List | 信号列表 | View > List |
| Processes | 进程树 | View > Processes |
| Locals | 局部变量 | View > Locals |
| Dataflow | 数据流图 | View > Dataflow |
| Assertions | 断言浏览器 | View > Assertions |

### 常用快捷键

| 快捷键 | 功能 |
|--------|------|
| `F9` | Run |
| `Ctrl+F5` | Restart |
| `F5` | Continue |
| `F10` | Step Over |
| `F11` | Step Into |
| `Shift+F11` | Step Out |
| `Ctrl+W` | 添加选中信号到波形 |
| `Ctrl+Shift+W` | 添加选中信号到 List |

---

## 6. 波形查看和调试

### 波形窗口操作

```tcl
# 信号分组
add wave -divider "Clock and Reset"
add wave /top_tb/clk
add wave /top_tb/rst_n

add wave -divider "DUT Ports"
add wave -radix hex /top_tb/u_dut/data_in
add wave -radix hex /top_tb/u_dut/data_out

add wave -divider "Internal"
add wave -r /top_tb/u_dut/u_fsm/*

# 显示基数
add wave -radix bin /top_tb/signal   # 二进制
add wave -radix hex /top_tb/signal   # 十六进制
add wave -radix dec /top_tb/signal   # 十进制
add wave -radix unsigned /top_tb/signal  # 无符号
add wave -radix ascii /top_tb/signal     # ASCII
```

### 常用调试操作

```tcl
# 查看信号值变化历史
# 在 Wave 窗口中点击信号即可查看

# 搜索信号值变化
# Edit > Find > Search for signal value

# 追踪信号驱动
# 右键信号 > Drivers (查看谁驱动了该信号)

# 追踪信号负载
# 右键信号 > Loads (查看谁读取了该信号)

# 源代码断点
# 在 Source 窗口行号处点击设置断点
bp /top_tb/u_dut/fsm_module.sv 42   # 命令行设置断点

# 条件断点
when {/top_tb/data == 8'hFF} {
    echo "Data is 0xFF!"
    stop
}
```

### 数据流调试

```tcl
# 打开数据流窗口
# View > Dataflow

# 追踪信号路径
# 在 Dataflow 窗口中选择信号，右键 > Trace
```

---

## 7. 代码覆盖率收集

### 启用覆盖率

```powershell
# 编译阶段：启用覆盖率收集
vlog -work work +acc +cover=bcest ../rtl/*.sv

# 仿真阶段：加载覆盖率
vsim -lib work -coverage top_tb

# 命令行模式：收集并导出
vsim -c -lib work -coverage -do "run -all; coverage save -assert -cvg -codeAll coverage.ucdb; quit -f"
```

### 覆盖率类型

| 类型 | 标志 | 说明 |
|------|------|------|
| Statement | `s` | 语句覆盖率 |
| Branch | `b` | 分支覆盖率 |
| Condition | `c` | 条件覆盖率 |
| Expression | `e` | 表达式覆盖率 |
| Toggle | `t` | 翻转覆盖率 |
| FSM | `f` | 状态机覆盖率 |

```tcl
# 在仿真中查看覆盖率
# View > Coverage Report

# 保存覆盖率数据库
coverage save -codeAll coverage.ucdb

# 生成覆盖率报告
vcover report -html -output cov_report coverage.ucdb

# 合并多次仿真覆盖率
vcover merge merged.ucdb run1.ucdb run2.ucdb run3.ucdb

# 增量覆盖率
coverage save -test test_name coverage.ucdb
```

### 覆盖率排除

```tcl
# 创建排除文件 exclude.el
# 排除不可达路径
coverage exclude -du fsm_module -line 45
coverage exclude -du fsm_module -toggle out_signal[7]
```

---

## 8. 功能覆盖率

### SystemVerilog 覆盖组编写

```verilog
// 在 testbench 中定义覆盖组
class my_transaction;
    rand bit [7:0] data;
    rand bit [3:0] addr;
    rand bit       wr_en;

    constraint c_reasonable {
        data inside {[0:255]};
        addr inside {[0:15]};
    }
endclass

covergroup cg_bus @(posedge clk);
    // 翻转覆盖率
    cp_data: coverpoint data {
        bins low  = {[0:63]};
        bins mid  = {[64:191]};
        bins high = {[192:255]};
    }

    cp_addr: coverpoint addr {
        bins zero = {0};
        bins range[4] = {[1:14]};
        bins max = {15};
    }

    cp_wr_en: coverpoint wr_en;

    // 交叉覆盖率
    cx_data_addr: cross cp_data, cp_addr;
endgroup
```

### 功能覆盖率命令

```tcl
# 查看功能覆盖率
# View > Functional Coverage

# 保存功能覆盖率
coverage save -cvg functional_cov.ucdb

# 合并代码覆盖率和功能覆盖率
vcover merge total.ucdb code.ucdb func.ucdb
```

---

## 9. 常用脚本

### 9.1 基础仿真脚本 `sim.do`

```tcl
#!/usr/bin/env tclsh
# sim.do - 基础仿真脚本

# 清理旧库
if {[file exists work]} {
    vdel -lib work -all
}
vlib work

# 编译
vlog -work work +acc +cover=bcest +define+SIM \
    -timescale "1ns/1ps" \
    -f filelist.f

# 仿真
vsim -lib work -coverage top_tb

# 添加波形
add wave -divider "CLK/RST"
add wave /top_tb/clk
add wave /top_tb/rst_n
add wave -divider "DUT"
add wave -r /top_tb/u_dut/*

# 运行
run -all
```

### 9.2 回归测试脚本 `regression.tcl`

```tcl
#!/usr/bin/env tclsh
# regression.tcl - 回归测试

set test_list {test_basic test_random test_stress test_corner}

foreach test $test_list {
    puts "======== Running: $test ========"
    vsim -lib work -c -coverage +ntb_random_seed=random \
        -do "run -all; coverage save -codeAll cov_${test}.ucdb; quit -f" \
        top_tb +UVM_TESTNAME=$test
}

# 合并覆盖率
vcover merge merged.ucdb cov_*.ucdb
vcover report -html -output regression_cov merged.ucdb
puts "======== Regression Done ========"
```

### 9.3 文件列表 `filelist.f`

```
// filelist.f - 编译文件列表
+incdir+../rtl
+incdir+../tb

../rtl/top.sv
../rtl/fsm_module.sv
../rtl/datapath.sv
../rtl/pkg_defs.sv

../tb/top_tb.sv
../tb/scoreboard.sv
../tb/sequences.sv
```

### 9.4 批处理运行

```powershell
# 命令行批处理（不启动 GUI）
vsim -c -lib work top_tb -do "do sim.do; quit -f"

# 后台运行
Start-Process -NoNewWindow vsim -ArgumentList "-c -lib work top_tb -do `"run -all; quit -f`""

# 指定日志文件
vsim -c -lib work top_tb -l sim.log -do "run -all; quit -f"
```

### 9.5 UVM 仿真脚本

```tcl
# uvm_sim.do
if {[file exists work]} {
    vdel -lib work -all
}
vlib work

# 编译（注意 UVM 库路径）
vlog -work work +acc +cover=bcest \
    -timescale "1ns/1ps" \
    +incdir+$env(UVM_HOME)/src \
    $env(UVM_HOME)/src/uvm_pkg.sv \
    -f filelist.f

# 仿真（UVM 选项）
vsim -lib work -coverage \
    +UVM_NO_RELNOTES \
    +UVM_VERBOSITY=UVM_MEDIUM \
    +UVM_TESTNAME=test_basic \
    top_tb

add wave -r /top_tb/*
run -all
```

---

## 10. 与 VCS/xrun 的对比

| 特性 | QuestaSim | VCS | xrun (Cadence) |
|------|-----------|-----|----------------|
| 厂商 | Siemens EDA | Synopsys | Cadence |
| 编译速度 | 中等 | 快 | 中等 |
| 仿真速度 | 中等 | 快 | 快 |
| SystemVerilog 支持 | 优秀 | 优秀 | 优秀 |
| UVM 支持 | 原生 | 原生 | 原生 |
| 断言支持 | SVA | SVA | SVA |
| 代码覆盖率 | 支持 | 支持 | 支持 |
| 功能覆盖率 | 支持 | 支持 | 支持 |
| GUI 调试 | 优秀（自带） | 需 DVE/Verdi | 需 SimVision |
| 增量编译 | 支持 | 不完全 | 支持 |
| 混合语言 | VHDL/Verilog/SV/SC | VHDL/Verilog/SV | VHDL/Verilog/SV/SC |
| 许可证 | 较贵 | 贵 | 贵 |

### 关键差异

```tcl
# ========== QuestaSim 特有 ==========

# 1. 增量编译（只编译修改的文件）
vlog -work work -incr ../rtl/modified_file.sv

# 2. 内置 GUI（无需额外工具）
# 启动 vsim 自带波形查看器

# 3. 录制仿真（可回放）
vsim -lib work -record top_tb

# ========== VCS 对比 ==========

# VCS 编译命令
# vcs -full64 -sverilog -debug_access+all top_tb.sv

# QuestaSim 等效
# vlog +acc -sv top_tb.sv

# ========== xrun 对比 ==========

# xrun 编译+仿真一步到位
# xrun -uvm -coverage all top_tb.sv

# QuestaSim 需要分步
# vlog +acc top_tb.sv
# vsim -coverage top_tb
```

---

## 11. 常见问题及解决

### Q1: 编译报错 "Cannot find design unit"

```powershell
# 原因：库路径错误或未编译依赖
# 解决：检查库映射
vmap -list
# 确保依赖库已编译
vlog -work work -L mylib ../rtl/top.sv
```

### Q2: 仿真速度慢

```tcl
# 解决方案：

# 1. 使用 vopt 优化
vopt +acc=top_tb -o top_tb_opt top_tb

# 2. 减少波形记录
log -r /top_tb/u_dut/*  # 仅记录 DUT 内部
# 而非
# add wave -r /*        # 记录所有

# 3. 命令行模式比 GUI 快
vsim -c -lib work top_tb -do "run -all; quit -f"

# 4. 关闭不必要的覆盖率
# vlog 中去掉 +cover 选项
```

### Q3: 覆盖率数据显示为 0

```powershell
# 原因：编译时未启用覆盖率
# 解决：重新编译时添加覆盖率选项
vlog -work work +acc +cover=bcest ../rtl/*.sv

# 确保仿真时也加载覆盖率
vsim -lib work -coverage top_tb
```

### Q4: 波形中信号显示 "x" 或 "z"

```tcl
# 检查：
# 1. 信号是否被正确初始化
# 2. 时钟是否正常工作
# 3. 复位是否正确释放

# 调试方法：
# 在 Source 窗口设置断点，单步执行
# 使用 Dataflow 追踪信号
```

### Q5: 许可证错误

```powershell
# 错误信息: "License checkout failed"
# 解决：
# 1. 检查许可证服务器
$env:LM_LICENSE_FILE = "1717@license_server"

# 2. 检查许可证可用
lmutil lmstat -a

# 3. 检查端口
Test-NetConnection -ComputerName license_server -Port 1717
```

### Q6: DPI-C 链接错误

```powershell
# 编译 DPI-C 代码
vlog -work work -sv ../rtl/top.sv ../dpi/my_c_code.c

# 或使用共享库
vlog -work work -sv ../rtl/top.sv
vsim -lib work -sv_lib my_c_lib top_tb
```

### Q7: SystemVerilog 语法不支持

```powershell
# 确保使用 -sv 标志
vlog -sv -work work ../rtl/design.sv

# 或确保文件扩展名为 .sv
# QuestaSim 会自动识别 .sv 文件为 SystemVerilog
```

### Q8: 仿真中断/死锁

```tcl
# 设置超时防止死锁
run 10ms
if {[examine -radix unsigned /top_tb/state] == "IDLE"} {
    echo "WARNING: Simulation timeout!"
}
run -all
```

---

## 12. 相关链接

### 官方资源

- Siemens EDA 官网: https://eda.sw.siemens.com/
- QuestaSim 用户指南: https://docs.sw.siemens.com/en-US/product/852980862
- Verification Academy: https://verificationacademy.com/

### 学习资料

- UVM 官方库: https://github.com/accellera/uvm
- SystemVerilog IEEE 标准: IEEE 1800-2017
- QuestaSim Tcl 参考: 查看安装目录下 `docs/` 文件夹

### 相关笔记

- [[02-UVM/08-源代码研究|UVM 源码研究]] - UVM 验证方法学
- [[04-Tools/05-VCS/00-VCS|VCS 仿真]] - VCS 仿真器使用
- [[04-Tools/xrun/00-xrun|xrun 仿真]] - Cadence xrun 仿真器

---

## 附录: 命令速查表

### 编译

```powershell
vlib work                              # 创建库
vlog +acc -f filelist.f                # 编译 SV
vcom -2008 file.vhd                    # 编译 VHDL
vopt +acc -o opt top                   # 优化
```

### 仿真

```powershell
vsim -lib work top_tb                  # GUI 仿真
vsim -c -lib work top_tb -do "run -all; quit -f"  # 命令行仿真
vsim -lib work -coverage top_tb        # 带覆盖率仿真
```

### 运行控制（vsim 内）

```tcl
run                    # 运行
run 100ns              # 运行指定时间
run -all               # 运行到结束
restart                # 重启
stop                   # 停止
quit -f                # 退出
```

### 波形

```tcl
add wave /signal       # 添加信号
add wave -r /module/*  # 递归添加
add wave -radix hex /signal  # 设置基数
configure wave -timelineunits ns
```

### 覆盖率

```powershell
vlog +cover=bcest ...                  # 编译时启用覆盖率
vsim -coverage ...                     # 仿真时启用
coverage save codeAll coverage.ucdb    # 保存覆盖率
vcover report -html cov_report cov.ucdb  # 生成报告
vcover merge merged.ucdb *.ucdb        # 合并覆盖率
```

---

> [!tip] 实用技巧
> 1. 使用 `vlog -incr` 增量编译，只重新编译修改的文件
> 2. 使用 `-c` 选项在命令行运行，比 GUI 更快
> 3. 使用 `add wave -r` 递归添加信号，避免手动逐个添加
> 4. 使用 `-coverage` 和 `+cover=bcest` 配合收集完整覆盖率
> 5. 使用 Tcl 脚本自动化仿真流程，提高效率

---

#EDA #Verification #Simulation #QuestaSim #Mentor

