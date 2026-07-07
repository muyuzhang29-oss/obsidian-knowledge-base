---
tags: [Script, Makefile, 模板, Xcelium]
created: 2026-07-07
updated: 2026-07-07
---

# Makefile 通用模板（Xcelium 仿真）

> 基于实际项目 Makefile 提炼的通用模板，带完整中文注释，替换变量即可套用任何验证环境。

## 完整模板

```makefile
# ============================================================================
# Makefile — Xcelium UVM 验证环境编译/仿真/回归
#
# 使用方法:
#   make compile                    — 编译全部源文件
#   make simulate TEST=base_test    — 运行测试用例
#   make simulate TEST=xxx DUMP=1   — 运行并 dump 波形
#   make simulate TEST=xxx COV=1    — 运行并收集覆盖率
#   make regress                    — 回归测试
#   make debug                      — 打开波形
#   make clean                      — 清理
#
# 依赖脚本:
#   wave.tcl             — 波形 dump 控制（同目录）
#   regression.pl        — 回归管理脚本（同目录，可选）
#   regression.cfg       — 回归配置文件（同目录，可选）
# ============================================================================


# ======================== 一、用户配置区 ========================
# 【✦】每次新建项目时，只需修改这里的变量

# --- 项目基本信息 ---
PROJECT         ?= my_project          # 【✦】项目名称
TOP_MODULE      ?= my_top             # 【✦】顶层 RTL 模块名（覆盖率 + vlib 用）
TB_TOP          ?= tb_top              # 【✦】Testbench 顶层模块名
TB_FILELIST     ?= filelist.f          # 【✦】文件列表路径

# --- 目录路径 ---
RTL_DIR         ?= ../rtl
TB_DIR          ?= ../tb
MODEL_DIR       ?= ../model
TEST_DIR_SRC    ?= ../test
SIM_DIR_BASE    ?= ./sim

# --- 仿真选项 ---
TEST            ?= base_test           # 【✦】默认测试用例名
SEED            ?= random              # 随机种子 (random | 12345 | fixed)
UVM_VERBOSITY   ?= UVM_MEDIUM          # UVM 打印级别
MCL             ?= 1                   # 多核并行线程数

# --- 开关选项 ---
DUMP            ?= 0                   # 波形 dump 开关: 0=关, 1=开
COV             ?= 0                   # 覆盖率开关: 0=关, 1=开
SDF             ?= none                # SDF 反标: none=功能仿真, bc=最佳, wc=最差
VIP             ?= 0                   # VIP 开关: 0=纯 RTL, 1=含 VIP
NOVIP           ?= 1                   # 无 VIP 模式: 1=屏蔽 VIP 逻辑

# --- 用户自定义 +define 宏 ---
# 用法:
#   make compile USER_DEFINES="+define+ENABLE_FEATURE_X +define+DEBUG_MODE"
# 也可在 filelist 中用 `+define+XXX` 统一管理
USER_DEFINES    ?=


# ======================== 二、自动推导变量 ========================
# 不需要手动修改

MODE            ?= base_fun
USER            := $(shell whoami)
SIM_DIR         := $(SIM_DIR_BASE)/$(MODE)
TIMESTAMP       := $(shell date +%Y%m%d_%H%M%S)

# 检查仿真器
ifeq ($(shell which xrun 2>/dev/null),)
    $(error "xrun not found. Source Xcelium environment (e.g. source xcelium/23.09/setup.sh)")
endif


# ======================== 三、编译选项 ========================
# 【详解】
# xrun 的编译选项可以分为 5 大类，下面逐类说明。

# ── 3.1 基础编译选项 ──
# -sv          : 启用 SystemVerilog
# -access +rwc : 开放读/写/连接权限（波形 dump / SDF 反标需要）
# -mess        : 显示详细编译信息
# -l compile.log: 编译日志输出到文件
BASE_COMP_OPTS = -sv -access +rwc -mess -l compile.log

# ── 3.2 UVM 编译选项 ──
# Xcelium 支持多个 UVM 版本:
#   CDNS-1.2    — 最新 UVM 1.2（推荐）
#   CDNS-1.1d   — 兼容老项目
#   CDNS-1.2-ML — Multi-Language 模式（混 SystemC 用）
#   CDNS-1.1d-ML
#
# +define+UVM_NO_DEPRECATED: 屏蔽已废弃的 UVM 方法警告
IUS_UVM_COMP_OPTS = -uvmhome CDNS-1.2 -define UVM_NO_DEPRECATED

# ── 3.3 用户自定义 +define 宏 ──
# 【详解】
# +define 是 Verilog/SystemVerilog 的条件编译机制:
#   `ifdef MY_MACRO       — 如果定义了 MY_MACRO
#   `ifndef MY_MACRO      — 如果没有定义 MY_MACRO
#   `elsif / `else / `endif
#
# 典型用途:
#   +define+SIM            — 仿真模式（屏蔽综合/DFT 逻辑）
#   +define+NO_CDN_PHY_VIP — 跳过 VIP 编译（加速纯 RTL 仿真）
#   +define+UVM_NO_DEPRECATED — 屏蔽 UVM 废弃 API 警告
#   +define+WAVES_DUMP     — 使能波形 dump 相关代码
#   +define+CLOCK_PERIOD_10 — 定义时钟周期（给 clock_gen 模块）
#   +define+USE_DEBUG_MON  — 使能调试 monitor
#
# 定义方式有三种:
#   1. 命令行: make compile USER_DEFINES="+define+SIM +define+DEBUG"
#   2. filelist: +define+SIM 写在 .f 文件中
#   3. 代码内: `define SIM 写在某个头文件中
ifneq ($(strip $(USER_DEFINES)),)
    IUS_UVM_COMP_OPTS += $(USER_DEFINES)
endif

# ── 3.4 覆盖率编译选项 ──
# 【详解】
# -coverage all  : 收集所有类型（line + branch + cond + toggle + functional）
# -covdut MODULE : 只收集指定模块的覆盖率（排除 VIP / BFMs）
# coverage b:t:e:f: 细分类型: branch, toggle, expression, functional
ifeq ($(COV),1)
    COV_COMP_OPTS = -coverage all -covdut $(TOP_MODULE)
    COV_COMP_OPTS += -coverage b:t:e:f
endif

# ── 3.5 SDF 反标选项 ──
# 【详解】
# SDF (Standard Delay Format) 反标用于门级仿真:
#   none — 功能仿真，不反标，用 +nospecify 跳过 specify 块
#   bc   — Best Case，最快延迟
#   wc   — Worst Case，最慢延迟
# 门级仿真还需要: -v 库文件、-sdf_verbose、-negdelay、-nodelays
ifeq ($(SDF),none)
    SDF_COMP_OPTS = -nospecify +define+FUNCTIONAL
else ifeq ($(SDF),bc)
    SDF_COMP_OPTS = -define SDF_SIM -define BEST_CASE \
                    -sdf_verbose -nodelays -negdelay -neg_tchk
else
    SDF_COMP_OPTS = -define SDF_SIM -define WORST_CASE \
                    -sdf_verbose -nodelays -negdelay -neg_tchk
endif

# ── 3.6 VIP 编译选项 ──
# 【详解】
# VIP (Verification IP) 是第三方提供的总线/协议模型:
#   Denali/Memory VIP    — DDR/LPDDR 控制器验证
#   Denali MIPI CSI-2    — MIPI CSI-2 摄像头接口 VIP
#   CDN VIP              — Cadence 官方 VIP 库
#
# VIP 通常需要:
#   1. 设置 DENALI / CDN_VIP_ROOT 环境变量
#   2. incdir 指向 VIP 头文件目录
#   3. 编译 VIP 源文件 (.sv)
#   4. 链接 VIP 共享库 (-sv_lib xxx.so)
#   5. +define+DENALI_UVM 等 VIP 专用宏
#
# 以下是 Denali MIPI CSI-2 VIP 示例（按实际 VIP 替换）:
# VIP_DPHY_INTF_DIR  = $(DENALI)/ddvapi/sv
# VIP_CS12_EXAMPLES  = $(DENALI)/ddvapi/sv/uvm/csi12/examples
# VIP_COMP_OPTS = \
#     -define DENALI_UVM -define DENALI_SV_NC \
#     -loadpl1 $(DENALI)/lib/viputil.so:cdnVIP:export \
#     incdir $(DENALI)/ddvapi/sv \
#     $(DENALI)/ddvapi/sv/denaliMem.sv \
#     incdir $(VIP_DPHY_INTF_DIR) \
#     $(VIP_DPHY_INTF_DIR)/cdn_miphy_acd_dphy_ddn_active_interface.sv \
#     ...
#
# 屏蔽 VIP 逻辑（纯 RTL 仿真加速）:
#   make compile NOVIP=1
#   对应 RTL 代码中: `ifdef NO_CDN_PHY_VIP ... `endif
ifeq ($(VIP),1)
    # 在此添加 VIP 编译选项
    # VIP_COMP_OPTS = ...
endif

# ── 3.7 最终编译选项合并 ──
COMP_OPTS = $(BASE_COMP_OPTS) $(IUS_UVM_COMP_OPTS) \
            $(COV_COMP_OPTS) $(SDF_COMP_OPTS) $(VIP_COMP_OPTS)

# 库扩展名
IUS_LIBEXT = -libext .vlib

# SDF 专用 SDF 文件路径
SDF_FILE ?=


# ======================== 四、仿真选项 ========================

UVM_SIM_OPTS = +UVM_VERBOSITY=$(UVM_VERBOSITY) \
               +UVM_TESTNAME=$(TEST) \
               +UVM_NO_RELNOTES \
               +UVM_MAX_QUIT_COUNT=10,YES

# ── 波形 dump 选项 ──
# 【详解】
# 通过 -input 传入 wave.tcl 脚本，在仿真开始前执行 probe 命令。
# wave.tcl 中可以用 $env(DUMP_START_TIME) 控制 dump 起始时间:
#
#   wave.tcl 内容示例:
#     database -open waves -shm -into waves -default
#     probe -database waves -create tb -all -depth all
#     if { [info exists ::env(DUMP_START_TIME)] } {
#         probe -database waves -create -start $$env(DUMP_START_TIME) tb -all
#     }
#
# 变量 DUMPTIME 控制从什么时刻开始 dump（默认 0ns，即从头开始）:
#   make simulate TEST=xxx DUMP=1 DUMPTIME=100us  ← 从 100us 开始记录
DUMPTIME ?= 0ns
export DUMP_START_TIME = $(DUMPTIME)

ifeq ($(DUMP),1)
    DUMP_WAVEFORM_OPTS = -input wave.tcl
endif

# ── 覆盖率仿真选项 ──
ifeq ($(COV),1)
    COV_SIM_OPTS = -covoverwrite -covtest $(TEST)_$(SEED)
endif

# ── VIP 仿真选项 ──
# VIP 运行时可能需要加载共享库
# LOAD_SV_LIB += -sv_lib $(SIM_DIR)/vip_lib/64bit/libcdnvipcuvm.so
LOAD_SV_LIB =

# ── 最终仿真选项合并 ──
SIM_OPTS = $(UVM_SIM_OPTS) \
           $(DUMP_WAVEFORM_OPTS) \
           $(COV_SIM_OPTS) \
           $(LOAD_SV_LIB)


# ======================== 五、目录管理 ========================

pre_comp:
	@echo "=== [PRE_COMP] Setting up ==="
	@mkdir -p $(SIM_DIR)
	@cp -f ./Makefile $(SIM_DIR)/
	@cp -f $(TB_FILELIST) $(SIM_DIR)/
	@echo "  SIM_DIR: $(SIM_DIR)"

pre_sim:
	@echo "=== [PRE_SIM] Setting up ==="
	@mkdir -p $(SIM_DIR)/$(TEST)
ifeq ($(DUMP),1)
	@cp wave.tcl $(SIM_DIR)/$(TEST)/
endif
	@echo "  TEST_DIR: $(SIM_DIR)/$(TEST)"


# ======================== 六、编译目标 ========================

.PHONY: all compile simulate clean help debug regress

all: compile simulate

# 【详解】xrun 编译流程:
#   xrun 是前端命令，它会自动调用 xmvlog（编译）→ xmvelab（链接）
#   1. 先读 filelist，编译所有 .sv/.v 文件到 INCA_libs
#   2. 再按 -top 指定的顶层链接成仿真快照
#   3. -elaborate 表示编译后立即链接
#
# 常用变体:
#   make compile COV=1                         ← 带覆盖率编译
#   make compile USER_DEFINES="+define+DEBUG"  ← 带自定义宏
#   make compile SDF=wc                         ← 门级仿真编译
compile: pre_comp
	@echo "=== [COMPILE] Start ==="
	cd $(SIM_DIR) && xrun -64bit -processor 8 \
		-mtdump -mccodegen -mccores 8 \
		$(COMP_OPTS) \
		$(IUS_LIBEXT) \
		-f $(TB_FILELIST) \
		-top $(TB_TOP) \
		-elaborate
	@echo "=== [COMPILE] Done ==="


# ======================== 七、仿真目标 ========================

# 【详解】xrun -r 运行仿真:
#   -r tb_top      : 链接已编译好的 tb_top 快照
#   -svseed $(SEED): 设置随机种子（random=自动，数字=固定）
#   -mcl $(MCL)    : 多核并行仿真
#   -xlibdirpath   : 指定已编译库目录
#   +UVM_TESTNAME  : 指定 UVM 测试用例
#
# 常用变体:
#   make simulate TEST=base_test                ← 跑默认测试
#   make simulate TEST=test_write DUMP=1        ← 跑测试 + dump 波形
#   make simulate TEST=test_corner SEED=42      ← 指定种子
#   make simulate TEST=test_stress COV=1        ← 跑测试 + 收集覆盖率
simulate: pre_sim
	@echo "=== [SIMULATE] TEST=$(TEST) SEED=$(SEED) DUMP=$(DUMP) COV=$(COV) ==="
	cd $(SIM_DIR)/$(TEST) && xrun -64bit \
		-mcl $(MCL) -mtdump -mccodegen -mccores $(MCL) \
		-r $(TB_TOP) \
		-xlibdirpath $(SIM_DIR) \
		-nocopyright \
		-l sim_$(TIMESTAMP).log \
		-svseed $(SEED) \
		$(SIM_OPTS) \
		&& touch DONE
	@echo "=== [SIMULATE] Done ==="


# ======================== 八、回归测试 ========================
# 【详解】回归测试有两种方式:
#
#   方式 A: Makefile 内建回归（适用于小项目，用例少）
#   方式 B: 用独立的 regression.pl 回归管理脚本（推荐，功能更强）
#
# 方式 B 的优势:
#   - 通过 regression.cfg 配置文件管理测试，无需改 Makefile
#   - 支持并行仿真，自动管理 seed
#   - 支持本地运行(Linux后台)和集群提交(bsub/LSF)
#   - 自动监控仿真进度，超时自动 kill
#   - 通过/失败统计 + 覆盖率合并
#
# regression.cfg 配置示例:
#   [csr] CompileOption: TB_FILELIST=filelist_spi COMP_OPTS='-define MY_PROJECT'
#   tests: base_test      test_mode: func    rpt_time: 3
#   tests: test_write     test_mode: func    rpt_time: 5   sim_options: +cfg=write
#   tests: test_read      test_mode: func    rpt_time: 5   sim_options: +cfg=read
#   tests: test_stress    test_mode: stress  rpt_time: 2
#
# rpt_time: 3 表示同一个用例跑 3 遍，每次不同 seed。
#
# 使用方式 B:
#   perl ../sim/regression.pl -r regression.cfg --local_sim on --cov on

# 方式 A: 简单 for 循环回归（适用于 10 个以内用例）
TESTS ?= base_test test_write test_read

regress: compile
	@echo "=== [REGRESS] Serial mode ==="
	@mkdir -p $(SIM_DIR)/regress_logs
	@rm -f $(SIM_DIR)/regress_logs/RESULT.txt
	@for test in $(TESTS); do \
		echo "Running $$test..."; \
		$(MAKE) simulate TEST=$$test \
			> $(SIM_DIR)/regress_logs/$${test}.log 2>&1 \
			&& echo "PASS: $$test" >> $(SIM_DIR)/regress_logs/RESULT.txt \
			|| echo "FAIL: $$test" >> $(SIM_DIR)/regress_logs/RESULT.txt; \
	done; \
	echo ""; \
	echo "=== Results ==="; \
	cat $(SIM_DIR)/regress_logs/RESULT.txt

# 方式 A 并行版
regress_parallel: compile
	@echo "=== [REGRESS] Parallel mode ==="
	@mkdir -p $(SIM_DIR)/regress_logs
	@$(foreach test,$(TESTS), \
		$(MAKE) simulate TEST=$(test) \
			> $(SIM_DIR)/regress_logs/$(test).log 2>&1 &)


# ======================== 九、覆盖率 ========================

cov: compile
	$(MAKE) simulate COV=1

cov_merge:
	vcover merge $(SIM_DIR)/$(TEST)/cov_work/*.dat \
		-outfile $(SIM_DIR)/merged_cov

cov_report: cov_merge
	vcover report -detail -cvg $(SIM_DIR)/merged_cov \
		> $(SIM_DIR)/cov_report.txt

cov_view:
	imc -64bit -load $(SIM_DIR)/merged_cov &


# ======================== 十、调试与查看 ========================

debug:
	simvision -64bit $(SIM_DIR)/$(TEST)/waves &


# ======================== 十一、清理 ========================

clean:
	rm -rf $(SIM_DIR_BASE) INCA_libs/ xcelium.d/ waves/ *.log *.err transcript


# ======================== 十二、+define 速查表 ========================
# 【详解】常用的 +define 及其用途:
#
#   仿真控制:
#     +define+SIM                 — 仿真模式（屏蔽综合/DFT 逻辑）
#     +define+FUNCTIONAL          — 功能仿真（配合 SDF 使用）
#     +define+SDF_SIM             — 门级 SDF 仿真
#     +define+WAVES_DUMP          — 使能波形 dump 代码段
#
#   UVM:
#     +define+UVM_NO_DEPRECATED   — 屏蔽 UVM 废弃 API 警告
#     +define+UVM_OBJECTION_TRACE — 打印 objection 上抛/下拉
#     +define+UVM_CM_MAX_DATA     — UVM 比较器最大数据宽度
#
#   VIP:
#     +define+DENALI_UVM          — 使能 Denali VIP UVM 支持
#     +define+DENALI_SV_NC        — Denali VIP Xcelium 模式
#     +define+NO_CDN_PHY_VIP      — 跳过 CDN PHY VIP（纯 RTL）
#
#   调试:
#     +define+ASSERT_ON           — 使能断言
#     +define+COVERAGE_ON         — 使能覆盖组
#     +define+DEBUG_MON           — 使能调试 monitor
#     +define+PRINT_TRANS         — 打印事务级信息
#
#   设计特性:
#     +define+CLOCK_PERIOD_10     — 定义时钟周期
#     +define+ENABLE_FIFO_BYPASS  — 使能 FIFO 旁路
#     +define+DISABLE_POWER_DOWN  — 屏蔽低功耗逻辑


# ======================== 十三、帮助 ========================

help:
	@echo "============================================"
	@echo " Makefile — Xcelium UVM 验证环境"
	@echo " 项目: $(PROJECT)"
	@echo "============================================"
	@echo ""
	@echo "【编译】"
	@echo "  make compile                           编译"
	@echo "  make compile COV=1                     编译（带覆盖率）"
	@echo "  make compile USER_DEFINES=\"+define+XXX\"  编译（带宏）"
	@echo ""
	@echo "【仿真】"
	@echo "  make simulate TEST=base_test           跑测试"
	@echo "  make simulate TEST=xxx DUMP=1          跑测试 + dump 波形"
	@echo "  make simulate TEST=xxx COV=1           跑测试 + 收集覆盖率"
	@echo "  make simulate TEST=xxx SEED=42         指定随机种子"
	@echo ""
	@echo "【回归】"
	@echo "  make regress                          简单串行回归"
	@echo "  perl regression.pl -r regress.cfg      完整回归管理"
	@echo ""
	@echo "【调试】"
	@echo "  make debug                            打开 Simvision"
	@echo "  make clean                            清理"
	@echo ""
	@echo "【变量说明】"
	@echo "  TEST=$(TEST)       SEED=$(SEED)"
	@echo "  DUMP=$(DUMP)       COV=$(COV)"
	@echo "  SDF=$(SDF)         VIP=$(VIP)"
	@echo "============================================"
```

## 变量速查表

| 变量 | 默认值 | 说明 | 必改 |
|------|--------|------|------|
| `PROJECT` | my_project | 项目名 | ✅ |
| `TOP_MODULE` | my_top | 顶层 RTL 模块 | ✅ |
| `TB_TOP` | tb_top | TB 顶层 | ✅ |
| `TB_FILELIST` | filelist.f | 文件列表 | ✅ |
| `TEST` | base_test | 默认测试 | ✅ |
| `SEED` | random | 随机种子 | |
| `DUMP` | 0 | 波形开关 | |
| `COV` | 0 | 覆盖率开关 | |
| `SDF` | none | SDF 反标 | |
| `VIP` | 0 | VIP 开关 | |
| `USER_DEFINES` | 空 | 自定义宏 | |
| `DUMPTIME` | 0ns | 波形起始时刻 | |
| `MCL` | 1 | 多核线程 | |

## 相关链接

- [[06-Scripts/06-仿真环境脚本]] — 实际项目 Makefile + wave.tcl
- [[06-Scripts/04-Perl回归脚本]] — Perl 回归管理脚本详解
- [[06-Scripts/01-Makefile]] — UVM 仿真模板速查
- [[06-Scripts/00-脚本索引]] — 返回脚本索引
