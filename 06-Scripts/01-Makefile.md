---
tags: [Script, Makefile, 构建, 工具]
created: 2026-04-17
updated: 2026-07-07
---

# Makefile — 仿真构建脚本

tags: #Makefile #构建 #自动化

## 项目实际 Makefile

实际项目的 Xcelium 编译/仿真 Makefile 见 [[06-Scripts/06-仿真环境脚本]]，含：
- `code/spi_it/sim/Makefile` — SPI 验证环境
- `code/spi_it/sim/wave.tcl` — 波形 dump 脚本

## UVM 仿真 Makefile 模板

### Questa 模板

```makefile
SIM_TOOL    = vsim
VLOG        = vlog
VOPT        = vopt

comp:
	$(VLOG) -sv -work work +incdir+$(INC_DIR) $(RTL_FILES)
	$(VLOG) -sv -work work +incdir+$(INC_DIR) $(TB_FILES)

elab:
	$(VOPT) -work work $(TOP_MODULE) -o $(TOP_MODULE)_opt

sim:
	$(VSIM) -c work.$(TOP_MODULE)_opt \
		-uvmhome=$(UVM_HOME) \
		+UVM_TESTNAME=$(TEST)
```

### VCS 模板

```makefile
VCS = vcs

COMP_OPTIONS = -sverilog -ntb_opts uvm-1.2 \
               -timescale=1ns/1ps \
               -debug_access+all -l compile.log

comp:
	$(VCS) $(COMP_OPTIONS) -f filelist.f -o simv

sim:
	./simv +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(UVM_VERBOSITY) \
	       +ntb_random_seed=$(SEED) -l sim.log
```

### Xcelium 模板

```makefile
XRUN = xrun

comp:
	$(XRUN) -64bit -sv -access +rwc \
		-uvmhome CDNS-1.2 \
		-f filelist.f \
		-top tb_top -elaborate

sim:
	$(XRUN) -64bit -r tb_top \
		+UVM_TESTNAME=$(TEST) \
		-svseed $(SEED) -l sim.log
```

## 通用 target 速查

| target | 功能 |
|--------|------|
| `make compile` | 编译全部源文件 |
| `make run TEST=xxx` | 跑测试用例 |
| `make clean` | 清理编译产物 |
| `make debug` | 打开波形查看器 |

## 相关链接

- [[06-Scripts/07-Makefile通用模板]] — 带完整中文注释的通用模板（推荐）
- [[06-Scripts/06-仿真环境脚本]] — 项目实际 Makefile + wave.tcl 说明
- [[06-Scripts/00-脚本索引]] — 返回脚本索引
