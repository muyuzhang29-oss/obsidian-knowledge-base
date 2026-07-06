---
tags: [Script, Makefile, 鏋勫缓, 宸ュ叿]
created: 2026-04-17
updated: 2026-06-02
---

# 00-Makefile

tags: #Makefile #鏋勫缓 #鑷姩鍖?

## Makefile 鍩虹

Makefile 鏄?Unix/Linux 绯荤粺鐨勬瀯寤哄伐鍏凤紝鐢ㄤ簬鑷姩鍖栫紪璇戙€佹祴璇曞拰楠岃瘉娴佺▼銆?

## 鍩烘湰璇硶

```makefile
# 娉ㄩ噴
# 鍙橀噺瀹氫箟
VAR = value

# 鐩爣: 渚濊禆
target: dependencies
    command1
    command2

# 浼洰鏍?
.PHONY: clean all

# 甯哥敤鍙橀噺
$@   # 鐩爣鏂囦欢
$<   # 绗竴涓緷璧?
$^   # 鎵€鏈変緷璧?
$?   # 鎵€鏈夋瘮鐩爣鏂扮殑渚濊禆
```

## 鍙橀噺

### 瀹氫箟鍜岃祴鍊?

```makefile
# 绠€鍗曡祴鍊?(绔嬪嵆灞曞紑)
VAR := value

# 閫掑綊璧嬪€?(寤惰繜灞曞紑)
VAR = value

# 鏉′欢璧嬪€?
VAR ?= default_value

# 杩藉姞
VAR += additional_value
```

### 鑷姩鍙橀噺

```makefile
# 绀轰緥
target: a.o b.o
    gcc $^ -o $@    # gcc a.o b.o -o target
```

### 甯哥敤鍙橀噺

```makefile
# 宸ュ叿閾?
CC = gcc
CXX = g++
VLOG = vlog
VSIM = vsim

# 鏍囧織
CFLAGS = -Wall -g
LDFLAGS = -lm
```

## 瑙勫垯

### 妯″紡瑙勫垯

```makefile
# 缂栬瘧 .c 鍒?.o
%.o: %.c
    $(CC) $(CFLAGS) -c $< -o $@
```

### 闈欐€佹ā寮忚鍒?

```makefile
OBJS = main.o utils.o
$(OBJS): %.o: %.c
    $(CC) $(CFLAGS) -c $< -o $@
```

### 闅愬惈瑙勫垯

```makefile
# 鑷姩鎺ㄥ
main.o: main.c main.h utils.h
# make 鑷姩浣跨敤: $(CC) $(CFLAGS) -c main.c -o main.o
```

## UVM 浠跨湡 Makefile

### 鍩虹妯℃澘

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

### 瀹屾暣楠岃瘉鐜 Makefile

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

## 甯哥敤鎶€宸?

### 鏉′欢鍒ゆ柇

```makefile
# 鍒ゆ柇鍙橀噺鏄惁瀹氫箟
ifdef DEBUG
    CFLAGS += -g -O0
else
    CFLAGS += -O2
endif

# 鍒ゆ柇鏂囦欢鏄惁瀛樺湪
ifeq ($(wildcard $(CONFIG_FILE)),)
    $(error CONFIG_FILE not found)
endif
```

### 鍑芥暟

```makefile
# 鏇挎崲鍚庣紑
$(SRCS:.c=.o)      # a.c b.c -> a.o b.o

# 杩囨护
$(filter %.sv,$(FILES))  # 鍙繚鐣?.sv 鏂囦欢

# 閬嶅巻
$(foreach var,list,expr)

# 妯″紡鏇挎崲
$(patsubst pattern,replacement,text)
```

### 璋冭瘯

```makefile
# 鎵撳嵃鍙橀噺
$(info $(VAR))

# 鎵撳嵃璀﹀憡
$(warning message)

# 鎵撳嵃閿欒
$(error message)
```

## 鐩稿叧閾炬帴

- [[00-Python鑴氭湰]] - Python 鑴氭湰
- [[01-Log瑙ｆ瀽]] - 鏃ュ織瑙ｆ瀽
- [[00-鎬荤储寮昡] - 杩斿洖鎬荤储寮?

---

*鍒涘缓鏃堕棿: 2026-04-17*
*鏇存柊鏃堕棿: 2026-04-17*

