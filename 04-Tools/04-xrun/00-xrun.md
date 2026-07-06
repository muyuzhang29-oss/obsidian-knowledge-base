---
tags: [Tools, xrun, 浠跨湡]
---

# 00-xrun

> Intel FPGA Verification Suite - 浠跨湡鍣?
## 姒傝堪

xrun 鏄?Intel FPGA Verification Suite (IFV) 涓殑缁熶竴浠跨湡鍛戒护锛屾暣鍚堜簡缂栬瘧銆乪laboration 鍜屼豢鐪熸祦绋嬨€?
## 鍩烘湰璇硶

```bash
xrun [options] <files>
```

## 甯哥敤閫夐」

### 缂栬瘧閫夐」

| 閫夐」 | 璇存槑 |
|------|------|
| `-f <file>` | 璇诲彇 filelist |
| `-incdir <dir>` | 鍖呭惈鐩綍 |
| `-define <macro>` | 瀹氫箟瀹?|
| `-sv` | 鍚敤 SystemVerilog |
| `-uvm` | 鍚敤 UVM (绛夊悓 -uvmhome) |
| `-uvmhome <path>` | UVM 搴撹矾寰?|
| `-uvmversion 1.2` | 鎸囧畾 UVM 鐗堟湰 |
| `-timescale <ts>` | 鏃堕棿鍒诲害 |
| `-compile` | 浠呯紪璇?|

### 浠跨湡閫夐」

| 閫夐」 | 璇存槑 |
|------|------|
| `-R` | 杩愯浠跨湡 |
| `-seed <seed>` | 闅忔満绉嶅瓙 |
| `-input <file>` | 杈撳叆鍛戒护鏂囦欢 |
| `-do "<cmd>"` | 鎵ц鍛戒护 |
| `-gui` | 鍚姩鍥惧舰鐣岄潰 |
| `-access +rwc` | 淇″彿璁块棶鏉冮檺 |

### 瑕嗙洊鐜囬€夐」

| 閫夐」 | 璇存槑 |
|------|------|
| `-coverage` | 鍚敤瑕嗙洊鐜?|
| `-coverage all` | 鎵€鏈夎鐩栫巼绫诲瀷 |
| `-coverage bcestf` | 琛?鍒嗘敮/鏉′欢/FSM/鍒囨崲 |
| `-covfile <file>` | 瑕嗙洊鐜囬厤缃枃浠?|
| `-linedebug` | 琛岀骇璋冭瘯 |

### 杈撳嚭閫夐」

| 閫夐」 | 璇存槑 |
|------|------|
| `-l <logfile>` | 鏃ュ織鏂囦欢 |
| `-xmlibdirpath <dir>` | 缂栬瘧搴撶洰褰?|
| `-errormax <n>` | 鏈€澶ч敊璇暟 |
| `-quiet` | 闈欓粯妯″紡 |
| `-verbose` | 璇︾粏杈撳嚭 |

---

## 甯哥敤鍛戒护

### 鍩烘湰缂栬瘧杩愯

```bash
# 缂栬瘧骞惰繍琛?xrun design.sv tb_top.sv -R

# 缂栬瘧 UVM
xrun -sv -uvm design.sv tb.sv -R

# 鎸囧畾绉嶅瓙杩愯
xrun design.sv tb.sv -R -seed 12345
```

### UVM 浠跨湡

```bash
# 瀹屾暣 UVM 浠跨湡
xrun \
    -sv \
    -uvm \
    -uvmhome CDNA \
    -f filelist.f \
    -timescale 1ns/1ps \
    -seed random \
    -l sim.log \
    -R

# 鎸囧畾 UVM 娴嬭瘯
xrun -sv -uvm -f filelist.f -R \
    +UVM_TESTNAME=my_test \
    +UVM_VERBOSITY=UVM_MEDIUM
```

### 瑕嗙洊鐜囦豢鐪?
```bash
# 鍚敤鎵€鏈夎鐩栫巼
xrun -sv -uvm -f filelist.f \
    -coverage all \
    -covfile coverage.cfg \
    -linedebug \
    -R

# 鎸囧畾瑕嗙洊鐜囩被鍨?xrun -sv -uvm -f filelist.f \
    -coverage bcesft \
    -seed random \
    -R
```

---

## 瀹屾暣 Makefile 绀轰緥

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

## Filelist 鏍煎紡

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

## UVM 閰嶇疆

### 鐜鍙橀噺

```bash
export UVM_HOME=$QUESTA_HOME/verif_src/uvm_1.2
export PATH=$QUESTA_HOME/bin:$PATH
```

### 甯哥敤 + 鍔犲懡浠よ閫夐」

```bash
+UVM_TESTNAME=my_test              # 鎸囧畾娴嬭瘯鐢ㄤ緥
+UVM_VERBOSITY=UVM_MEDIUM          # UVM 鍐椾綑搴?+UVM_OBJECTION_TRACE              # objection 杩借釜
+UVM_PHASE_TRACE                  # phase 杩借釜
+UVM_MAX_QUIT_COUNT=5             # 鏈€澶ч€€鍑鸿鏁?+ntb_random_seed=12345            # 闅忔満绉嶅瓙
```

---

## 甯歌闂

### 1. UVM 鐗堟湰涓嶅尮閰?
```bash
# 瑙ｅ喅鏂规锛氭寚瀹氭纭殑 UVM 璺緞
xrun -sv -uvmhome CDNA -f filelist.f -R
# 鎴?xrun -sv -uvm -uvmhome $QUESTA_HOME/verif_src/uvm_1.2 -f filelist.f -R
```

### 2. 瑕嗙洊鐜囨枃浠朵笉瀛樺湪

```bash
# 纭繚鐩綍瀛樺湪涓旀湁鍐欏叆鏉冮檺
mkdir -p coverage
xrun -coverage all -covfile coverage.cfg -f filelist.f -R
```

### 3. 浠跨湡瓒呮椂

```bash
# 澧炲姞瓒呮椂鏃堕棿
xrun -R +UVM_TESTNAME=long_test +timeout=10000
```

---

## 鐩稿叧閾炬帴

- [[00-imc]] - 瑕嗙洊鐜囧垎鏋愬伐鍏?- [[00-甯哥敤鍛戒护]] - Linux 鍛戒护
- [[00-Makefile]] - Makefile 妯℃澘
- [[00-鎬荤储寮昡] - 杩斿洖鎬荤储寮?
---

*鍒涘缓鏃堕棿: 2026-04-17*
*鏇存柊鏃堕棿: 2026-04-17*

