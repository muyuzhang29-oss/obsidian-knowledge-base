---
tags: [Script, Makefile, 构建, 工具]
created: 2026-04-17
updated: 2026-06-02
---

# 00-Makefile

tags: #Makefile #构建 #自动化

## Makefile 基础

Makefile 是 Unix/Linux 系统的构建工具，用于自动化编译、测试和验证流程。

## 基本语法

```makefile
# 注释
# 变量定义
VAR = value

# 目标: 依赖
target: dependencies
    command1
    command2

# 伪目标
.PHONY: clean all

# 常用变量
$@   # 目标文件
$<   # 第一个依赖
$^   # 所有依赖
$?   # 所有比目标新的依赖
```

## 变量

### 定义和赋值

```makefile
# 简单赋值 (立即展开)
VAR := value

# 递归赋值 (延迟展开)
VAR = value

# 条件赋值
VAR ?= default_value

# 追加
VAR += additional_value
```

### 自动变量

```makefile
# 示例
target: a.o b.o
    gcc $^ -o $@    # gcc a.o b.o -o target
```

### 常用变量

```makefile
# 工具链
CC = gcc
CXX = g++
VLOG = vlog
VSIM = vsim

# 标志
CFLAGS = -Wall -g
LDFLAGS = -lm
```

## 规则

### 模式规则

```makefile
# 编译 .c 到 .o
%.o: %.c
    $(CC) $(CFLAGS) -c $< -o $@
```

### 静态模式规则

```makefile
OBJS = main.o utils.o
$(OBJS): %.o: %.c
    $(CC) $(CFLAGS) -c $< -o $@
```

### 隐含规则

```makefile
# 自动推导
main.o: main.c main.h utils.h
# make 自动使用: $(CC) $(CFLAGS) -c main.c -o main.o
```

## UVM 仿真 Makefile

### 基础模板

```makefile
# ============== Configuration ==============
PROJECT      = tb_project
TOP_MODULE   = tb_top
SIM_TOOL     ?= vsim
SIM_HOME     ?= /path/to/simulator

# Source files
RTL_DIR      = ../rtl
TB_DIR       = ../tb
VERIF_DIR    = ../verif
INC_DIRS     = -y $(RTL_DIR) -y $(TB_DIR) -y $(VERIF_DIR)

# Compile options
COMPILE_OPTS = -sv -suppress 12345
ELAB_OPTS    = -timescale 1ns/1ps

# Simulation options
SIM_OPTS     = -c -coverage -fsmkeys yes
UVM_VERBOSITY = UVM_MEDIUM
SEED         ?= random

# Coverage
COV_DIR      = coverage
COV_OPTS     = -coverage -coverfile=$(COV_DIR)/cov.ocdb

# ============== Targets ==============
.PHONY: all compile simulate clean run view

all: compile simulate

# Compile
compile:
	@mkdir -p work $(COV_DIR)
	$(SIM_TOOL) -c -do "\
		compile $(COMPILE_OPTS) \
		$(INC_DIRS) \
		$(addprefix +incdir+, $(INC_DIRS)) \
		$(wildcard $(RTL_DIR)/*.sv) \
		$(wildcard $(TB_DIR)/*.sv) \
		$(UVM_HOME)/src/uvm.sv \
		; dofile compile.tcl; quit -f"

# Elaborate
elaborate:
	$(SIM_TOOL) -c $(ELAB_OPTS) \
		-uvmhome $(UVM_HOME) \
		work.$(TOP_MODULE) \
		-coverage -coverfile=$(COV_DIR)/cov.ocdb

# Simulate
simulate: compile elaborate
	$(SIM_TOOL) -c $(SIM_OPTS) \
		-gui work.$(TOP_MODULE) \
		-uvmhome $(UVM_HOME) \
		+UVM_TESTNAME=$(TEST) \
		+UVM_VERBOSITY=$(UVM_VERBOSITY) \
		+ntb_random_seed=$(SEED) \
		-coverage -coverfile=$(COV_DIR)/cov.ocdb

# Run with seeds
run: compile elaborate
	$(SIM_TOOL) -c $(SIM_OPTS) \
		-work work \
		-uvmhome $(UVM_HOME) \
		+UVM_TESTNAME=$(TEST) \
		+UVM_VERBOSITY=$(UVM_VERBOSITY) \
		+ntb_random_seed=$(SEED)

# Quick run
quick:
	$(VSIM) -c -do "do $(TB_DIR)/run.do" work.$(TOP_MODULE)

# ============== Regression ==============
REGRESSION_TESTS = test_basic test_rand test_corner test_stress

regress:
	@for test in $(REGRESSION_TESTS); do \
		echo "Running $$test..."; \
		$(MAKE) TEST=$$test run; \
	done

regress_parallel:
	@$(foreach test,$(REGRESSION_TESTS),$(MAKE) TEST=$(test) run &)

# ============== Coverage ==============
cov_report: $(COV_DIR)/cov.ocdb
	vcover report -detail $(COV_DIR)/cov.ocdb

$(COV_DIR)/cov.ocdb: $(COV_DIR)
	vcover merge $(wildcard $(COV_DIR)/*.vdb) -outfile $@

# ============== Clean ==============
clean:
	rm -rf work *.wlf *.log *.db
	rm -rf $(COV_DIR)
	rm -rf transcript
```

### Questa/VCS Makefile

```makefile
# ============== Questa ==============
SIM_TOOL    = vsim
VLOG        = vlog
VOPT        = vopt
VMAP        = vmap

Questa_OPTIONS = -timescale 1ns/1ps -suppress 2586

comp:
	$(VLOG) $(Questa_OPTIONS) -work work \
		+incdir+$(INC_DIR) \
		$(RTL_FILES)
	$(VLOG) $(Questa_OPTIONS) -work work \
		+incdir+$(INC_DIR) \
		$(TB_FILES)

elab:
	$(VOPT) -work work $(TOP_MODULE) -o $(TOP_MODULE)_opt

sim:
	$(VSIM) -c work.$(TOP_MODULE)_opt \
		-uvmhome=$(UVM_HOME) \
		+UVM_TESTNAME=$(TEST)

# ============== VCS ==============
VCS = vcs
URG = urg

VCS_OPTIONS = -sverilog -ntb_opts uvm-1.2 \
              -timescale=1ns/1ps \
              -debug_access+all \
              -l compile.log

comp_vcs:
	$(VCS) $(VCS_OPTIONS) \
		-f filelist.f \
		-o simv

sim_vcs:
	./simv +UVM_TESTNAME=$(TEST) \
	       +UVM_VERBOSITY=$(UVM_VERBOSITY) \
	       +ntb_random_seed=$(SEED) \
	       -l sim.log
```

### 完整验证环境 Makefile

```makefile
# ============== Variables ==============
export PROJECT   = chip_verification
export WORK_DIR  = work
export RTL_DIR   = ../rtl
export TB_DIR    = ../tb
export COV_DIR   = coverage

UVM_HOME    = $(QUESTA_HOME)/verif_src/uvm-1.2
UVM_DEFINES = -DUVM_OBJECTION_TRACE

SIMULATOR   ?= vsim
TEST        ?= base_test
SEED        ?= $$(date +%s)
RUN_TIME    ?= 1ms

# Coverage options
ENABLE_COV  ?= 1
COV_TYPES   = line branch cond fsm toggle

# ============== Help ==============
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make compile          - Compile design and testbench"
	@echo "  make run TEST=test    - Run specific test"
	@echo "  make regress          - Run regression suite"
	@echo "  make view             - Open Verdi/DVE for waveform"
	@echo "  make clean            - Clean work directory"

# ============== Compilation ==============
RTL_SOURCES = $(wildcard $(RTL_DIR)/*.sv) \
              $(wildcard $(RTL_DIR)/*.v)
TB_SOURCES  = $(wildcard $(TB_DIR)/*.sv) \
              $(wildcard $(TB_DIR)/*.svh)

.PHONY: compile
compile: $(WORK_DIR)
	@echo "Compiling RTL..."
	$(SIMULATOR) -c -do "compile.tcl"

compile.tcl:
	@echo "vlog -sv -work work \\" > compile.tcl
	@echo "  -timescale 1ns/1ps \\" >> compile.tcl
	@echo "  -uvmhome $(UVM_HOME) \\" >> compile.tcl
	@echo "  $(RTL_SOURCES) \\" >> compile.tcl
	@echo "  $(TB_SOURCES)" >> compile.tcl

$(WORK_DIR):
	mkdir -p $(WORK_DIR) $(COV_DIR)

# ============== Simulation ==============
.PHONY: run
run: compile
	$(SIMULATOR) -c \
		-work $(WORK_DIR) \
		-uvmhome $(UVM_HOME) \
		+UVM_TESTNAME=$(TEST) \
		+UVM_VERBOSITY=UVM_MEDIUM \
		+ntb_random_seed=$(SEED) \
		+UVM_OBJECTION_TRACE \
		-do "run -all; quit -f"

# ============== Regression ==============
define run_test
	@echo "Running $(1)..."
	@$(MAKE) TEST=$(1) run > logs/$(1).log 2>&1 || echo "FAILED: $(1)" >> regress_results.txt
endef

TESTS = basic_test random_test corner_test stress_test

.PHONY: regress
regress: compile
	@mkdir -p logs
	@echo "" > regress_results.txt
	$(foreach test,$(TESTS),$(call run_test,$(test)))
	@echo "Regression complete. Results:"
	@cat regress_results.txt

# ============== Coverage ==============
.PHONY: coverage
coverage: compile
	$(SIMULATOR) -c \
		-work $(WORK_DIR) \
		-uvmhome $(UVM_HOME) \
		+UVM_TESTNAME=$(TEST) \
		-coverage \
		-coverfile=$(COV_DIR)/$(TEST).dat

cov_merge:
	vcover merge \
		$(COV_DIR)/*.dat \
		-outfile $(COV_DIR)/merged.dat

cov_report:
	vcover report -detail -cvg \
		$(COV_DIR)/merged.dat \
		> $(COV_DIR)/report.txt

# ============== Clean ==============
.PHONY: clean
clean:
	rm -rf $(WORK_DIR) $(COV_DIR) *.log *.wlf transcript
	rm -f compile.tcl work/_vmake mcr_x*.log

# ============== Utilities ==============
.PHONY: kill
kill:
	@pkill -f vsim || true

.PHONY: wave
wave:
	@ Verdi command: verdi -sv \
		-f $(RTL_DIR)/filelist.f \
		-f $(TB_DIR)/filelist.f \
		-uvmhome $(UVM_HOME) \
		-ntb_opts uvm-1.2 &
```

## 常用技巧

### 条件判断

```makefile
# 判断变量是否定义
ifdef DEBUG
    CFLAGS += -g -O0
else
    CFLAGS += -O2
endif

# 判断文件是否存在
ifeq ($(wildcard $(CONFIG_FILE)),)
    $(error CONFIG_FILE not found)
endif
```

### 函数

```makefile
# 替换后缀
$(SRCS:.c=.o)      # a.c b.c -> a.o b.o

# 过滤
$(filter %.sv,$(FILES))  # 只保留 .sv 文件

# 遍历
$(foreach var,list,expr)

# 模式替换
$(patsubst pattern,replacement,text)
```

### 调试

```makefile
# 打印变量
$(info $(VAR))

# 打印警告
$(warning message)

# 打印错误
$(error message)
```

## 相关链接

- [[00-Python脚本]] - Python 脚本
- [[01-Log解析]] - 日志解析
- [[00-总索引]] - 返回总索引

---

*创建时间: 2026-04-17*
*更新时间: 2026-04-17*
