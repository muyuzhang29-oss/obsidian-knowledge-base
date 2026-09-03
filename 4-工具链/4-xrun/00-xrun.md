---
tags: [Tools, xrun, 仿真]
---

# 00-xrun

> Intel FPGA Verification Suite - 仿真器

## 概述

xrun 是 Intel FPGA Verification Suite (IFV) 中的统一仿真命令，整合了编译、elaboration 和仿真流程。

## 基本语法

```bash
xrun [options] <files>
```

## 常用选项

### 编译选项

| 选项 | 说明 |
|------|------|
| `-f <file>` | 读取 filelist |
| `-incdir <dir>` | 包含目录 |
| `-define <macro>` | 定义宏 |
| `-sv` | 启用 SystemVerilog |
| `-uvm` | 启用 UVM (等同 -uvmhome) |
| `-uvmhome <path>` | UVM 库路径 |
| `-uvmversion 1.2` | 指定 UVM 版本 |
| `-timescale <ts>` | 时间刻度 |
| `-compile` | 仅编译 |

### 仿真选项

| 选项 | 说明 |
|------|------|
| `-R` | 运行仿真 |
| `-seed <seed>` | 随机种子 |
| `-input <file>` | 输入命令文件 |
| `-do "<cmd>"` | 执行命令 |
| `-gui` | 启动图形界面 |
| `-access +rwc` | 信号访问权限 |

### 覆盖率选项

| 选项 | 说明 |
|------|------|
| `-coverage` | 启用覆盖率 |
| `-coverage all` | 所有覆盖率类型 |
| `-coverage bcestf` | 行/分支/条件/FSM/切换 |
| `-covfile <file>` | 覆盖率配置文件 |
| `-linedebug` | 行级调试 |

### 输出选项

| 选项 | 说明 |
|------|------|
| `-l <logfile>` | 日志文件 |
| `-xmlibdirpath <dir>` | 编译库目录 |
| `-errormax <n>` | 最大错误数 |
| `-quiet` | 静默模式 |
| `-verbose` | 详细输出 |

---

## 常用命令

### 基本编译运行

```bash
# 编译并运行
xrun design.sv tb_top.sv -R

# 编译 UVM
xrun -sv -uvm design.sv tb.sv -R

# 指定种子运行
xrun design.sv tb.sv -R -seed 12345
```

### UVM 仿真

```bash
# 完整 UVM 仿真
xrun \
    -sv \
    -uvm \
    -uvmhome CDNA \
    -f filelist.f \
    -timescale 1ns/1ps \
    -seed random \
    -l sim.log \
    -R

# 指定 UVM 测试
xrun -sv -uvm -f filelist.f -R \
    +UVM_TESTNAME=my_test \
    +UVM_VERBOSITY=UVM_MEDIUM
```

### 覆盖率仿真

```bash
# 启用所有覆盖率
xrun -sv -uvm -f filelist.f \
    -coverage all \
    -covfile coverage.cfg \
    -linedebug \
    -R

# 指定覆盖率类型
xrun -sv -uvm -f filelist.f \
    -coverage bcesft \
    -seed random \
    -R
```

---

## 完整 Makefile 示例

```makefile
# ============== Configuration ==============
PROJECT      = tb_project
TOP_MODULE   = tb_top
XRUN_HOME    = $(QUESTA_HOME)

# Source files
RTL_DIR      = ../rtl
TB_DIR       = ../tb
INC_DIRS     = -incdir $(RTL_DIR) -incdir $(TB_DIR)

# UVM settings
UVM_HOME     = $(XRUN_HOME)/verif_src/uvm_1.2
UVM_DEFINES  = -uvmhome $(UVM_HOME)

# Coverage
COV_DIR      = coverage
COV_TYPES    = bcesft
COV_FILE     = $(COV_DIR)/coverage.cfg

# Simulation
SEED         ?= random
TEST_NAME    ?= base_test
VERBOSITY    ?= UVM_MEDIUM
TIMEOUT      ?= 1000ms

# ============== Targets ==============
.PHONY: all compile run clean regress

all: compile run

# Compile
compile:
	@mkdir -p work $(COV_DIR)
	xrun \
		-translate_off \
		-sv \
		$(UVM_DEFINES) \
		-f filelist.f \
		$(INC_DIRS) \
		-timescale 1ns/1ps \
		-coverage $(COV_TYPES) \
		-covfile $(COV_FILE) \
		-l compile.log \
		-errormax 20 \
		-nowarn UVMPCDC \
		-seed $(SEED)

# Run
run: compile
	xrun \
		-R \
		-l sim.log \
		-seed $(SEED) \
		+UVM_TESTNAME=$(TEST_NAME) \
		+UVM_VERBOSITY=$(VERBOSITY) \
		+UVM_OBJECTION_TRACE \
		+ntb_random_seed=$(SEED)

# Quick run (compile + run)
quick:
	xrun -sv $(UVM_DEFINES) -f filelist.f -R \
		-seed $(SEED) \
		+UVM_TESTNAME=$(TEST_NAME) \
		+UVM_VERBOSITY=$(VERBOSITY)

# ============== Regression ==============
TESTS = base_test random_test corner_test stress_test

regress:
	@mkdir -p logs
	@for test in $(TESTS); do \
		echo "Running $$test..."; \
		$(MAKE) TEST_NAME=$$test run > logs/$$test.log 2>&1; \
	done

# ============== Coverage ==============
cov_merge:
	imc -merge -out merged -input $(COV_DIR)/test_*.ucdb

cov_report:
	imc -code -detail -html -execRep merged &

# ============== Clean ==============
clean:
	rm -rf work INCA_libs *.log *.wlf *.jou
	rm -rf $(COV_DIR)

# ============== Debug ==============
debug:
	xrun -sv $(UVM_DEFINES) -f filelist.f -gui \
		+UVM_TESTNAME=$(TEST_NAME)
```

---

## Filelist 格式

```bash
# filelist.f
+incdir+../rtl/include
+incdir+../tb

# RTL files
../rtl/axi_if.sv
../rtl/dut.sv

# Testbench files
../tb/tb_top.sv
../tb/env.sv
../tb/test.sv

# UVM
$(UVM_HOME)/src/uvm.sv
```

---

## UVM 配置

### 环境变量

```bash
export UVM_HOME=$QUESTA_HOME/verif_src/uvm_1.2
export PATH=$QUESTA_HOME/bin:$PATH
```

### 常用 + 加命令行选项

```bash
+UVM_TESTNAME=my_test              # 指定测试用例
+UVM_VERBOSITY=UVM_MEDIUM          # UVM 冗余度
+UVM_OBJECTION_TRACE              # objection 追踪
+UVM_PHASE_TRACE                  # phase 追踪
+UVM_MAX_QUIT_COUNT=5             # 最大退出计数
+ntb_random_seed=12345            # 随机种子
```

---

## 常见问题

### 1. UVM 版本不匹配

```bash
# 解决方案：指定正确的 UVM 路径
xrun -sv -uvmhome CDNA -f filelist.f -R
# 或
xrun -sv -uvm -uvmhome $QUESTA_HOME/verif_src/uvm_1.2 -f filelist.f -R
```

### 2. 覆盖率文件不存在

```bash
# 确保目录存在且有写入权限
mkdir -p coverage
xrun -coverage all -covfile coverage.cfg -f filelist.f -R
```

### 3. 仿真超时

```bash
# 增加超时时间
xrun -R +UVM_TESTNAME=long_test +timeout=10000
```

---

## 相关链接

- [[00-imc]] - 覆盖率分析工具
- [[00-常用命令]] - Linux 命令
- [[00-Makefile]] - Makefile 模板
- [[00-总索引]] - 返回总索引

---

*创建时间: 2026-04-17*
*更新时间: 2026-04-17*
