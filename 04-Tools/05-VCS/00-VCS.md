---
tags:
  - Tools
  - VCS
  - 仿真
  - Synopsys
  - 核心
aliases: [VCS编译器, VCS仿真器]
created: 2026-06-02
---

# VCS (Verilog Compiled Simulator)

## 1. 概述

VCS 是 Synopsys 公司开发的高性能 Verilog/SystemVerilog 仿真器，是业界最广泛使用的仿真工具之一。

### 主要特点

| 特性 | 说明 |
|------|------|
| 编译型仿真 | 先编译后执行，运行速度快 |
| 语言支持 | Verilog, SystemVerilog, VHDL (混合语言) |
| 调试功能 | 支持 UCLI, DVE, Verdi 等调试器 |
| 高性能 | 多核并行仿真 (SimFlex) |
| PLI/VPI | 支持 C/C++ 接口扩展 |
| 覆盖率 | 代码覆盖率、功能覆盖率收集 |

### 工作流程

```
源代码 (.v/.sv)
      ↓
    vcs 编译
      ↓
   可执行文件 (simv)
      ↓
    ./simv 运行
      ↓
   仿真结果 (波形/日志)
```

---

## 2. 编译选项

### 基础编译选项

| 选项 | 说明 |
|------|------|
| `-full64` | 64位模式编译（推荐始终使用） |
| `-sverilog` | 启用 SystemVerilog 支持 |
| `-timescale=1ns/1ps` | 设置默认时间单位/精度 |
| `-o <name>` | 指定输出可执行文件名 |
| `-l <file>` | 编译日志输出文件 |
| `-f <filelist>` | 读取文件列表 |
| `-v <lib>` | 指定库文件 |
| `-y <dir>` | 指定库目录 |
| `+incdir+<dir>` | 指定 include 文件搜索目录 |
| `+define+<macro>` | 定义预处理宏 |

### 语言与标准选项

```bash
# SystemVerilog 2012 标准
vcs -sverilog -ntb_opts uvm-1.2

# 启用 Assertions
vcs -assert svaext

# 启用覆盖率
vcs -cm line+cond+fsm+tgl+branch
```

### NTB (Native Testbench) 选项

| 选项 | 说明 |
|------|------|
| `-ntb_opts uvm` | 启用 UVM 支持 |
| `-ntb_opts uvm-1.2` | 指定 UVM 版本 |
| `-ntb_opts dtm` | 启用 DPI 导入任务方法 |
| `-ntb_opts config_file` | 指定配置文件 |

---

## 3. 仿真运行选项

### 运行时控制

| 选项 | 说明 |
|------|------|
| `+vcs+flush+all` | 实时刷新输出缓冲区 |
| `+vcs+finish+<n>` | 仿真 n 个时间单位后结束 |
| `+ntb+random+seed+<n>` | 设置随机种子 |
| `+vcs+learn+pli` | 学习 PLI 调用优化性能 |
| `+vpdbufsize+<n>` | 设置 VPD 波形缓冲区大小 |

### 波形转储

```bash
# VPD 格式 (Synopsys 专有)
+vpdfile+<filename>

# FSDB 格式 (Verdi)
+fsdbfile+<filename>

# 设置转储深度
+vcdplusdepth+<n>
```

### 仿真时间控制

```bash
# 运行 1000 个时间单位
./simv +vcs+finish+1000

# 运行到 $finish
./simv

# 设置最大仿真时间
./simv +vcs+maxdelays
```

---

## 4. 常用命令行示例

### 基本编译

```bash
# 简单编译
vcs -full64 -sverilog top.sv

# 使用文件列表
vcs -full64 -sverilog -f filelist.f

# 指定输出名称和日志
vcs -full64 -sverilog -o simv_test -l compile.log top.sv
```

### UVM 编译

```bash
vcs -full64 -sverilog \
    -ntb_opts uvm-1.2 \
    +incdir+../sv \
    +define+UVM_NO_DEPRECATED \
    -cm line+cond+fsm \
    -l compile.log \
    -f filelist.f
```

### 运行仿真

```bash
# 基本运行
./simv +vcs+flush+all -l sim.log

# 带波形转储
./simv +vcs+flush+all +vpdfile+wave.vpd -l sim.log

# 带覆盖率收集
./simv +vcs+flush+all -cm line+cond+fsm -cm_dir ./cov -l sim.log

# 带随机种子
./simv +ntb+random+seed=12345 +vcs+flush+all -l sim.log
```

### 调试模式运行

```bash
# 启用 UCLI 调试
./simv -ucli -l sim.log

# 启用 DVE 调试
./simv -gui -l sim.log
```

---

## 5. 编译脚本模板

### Makefile 模板

```makefile
# VCS 编译运行 Makefile

# 工具路径
VCS = vcs
VERDI = verdi

# 编译选项
VCS_OPTS = -full64 -sverilog \
           -ntb_opts uvm-1.2 \
           -timescale=1ns/1ps \
           -debug_access+all \
           -kdb

# 覆盖率选项
COV_OPTS = -cm line+cond+fsm+tgl+branch \
           -cm_dir ./cov \
           -cm_name test_name

# 源文件
FILELIST = -f filelist.f
TOP = top_tb

# 编译目标
compile:
	$(VCS) $(VCS_OPTS) $(COV_OPTS) \
	-l compile.log \
	-o simv \
	$(FILELIST) \
	$(TOP)

# 运行仿真
sim: compile
	./simv \
	+vpdfile+wave.vpd \
	+vcs+flush+all \
	$(COV_OPTS) \
	-l sim.log

# 调试运行
debug: compile
	./simv -ucli -do debug.tcl -l sim.log

# 查看波形
wave:
	$(VERDI) -ssf wave.fsdb &

# 清理
clean:
	rm -rf csrc simv simv.daidir *.log *.vpd \
	*.key *.vpd novas* verdi* DVEfiles \
	.ucli* *.hvp

.PHONY: compile sim debug wave clean
```

### Shell 脚本模板

```bash
#!/bin/bash
# run_vcs.sh - VCS 编译运行脚本

set -e

# 配置
TOP="top_tb"
FILELIST="filelist.f"
OUTPUT="simv"
LOG_DIR="./log"
COV_DIR="./cov"

# 创建目录
mkdir -p $LOG_DIR $COV_DIR

# 编译函数
compile() {
    echo "=== Compiling ==="
    vcs -full64 -sverilog \
        -ntb_opts uvm-1.2 \
        -timescale=1ns/1ps \
        -debug_access+all \
        -kdb \
        -cm line+cond+fsm+tgl+branch \
        -cm_dir $COV_DIR \
        -l ${LOG_DIR}/compile.log \
        -o $OUTPUT \
        -f $FILELIST \
        $TOP
}

# 运行函数
run() {
    echo "=== Running Simulation ==="
    ./$OUTPUT \
        +vcs+flush+all \
        +vpdfile+wave.vpd \
        -cm line+cond+fsm+tgl+branch \
        -cm_dir $COV_DIR \
        -l ${LOG_DIR}/sim.log
}

# 主流程
case "$1" in
    compile)
        compile
        ;;
    run)
        run
        ;;
    all)
        compile
        run
        ;;
    *)
        echo "Usage: $0 {compile|run|all}"
        exit 1
        ;;
esac
```

---

## 6. 调试选项

### 编译时调试选项

| 选项 | 说明 |
|------|------|
| `-debug_access+all` | 启用完整调试访问 |
| `-debug_access+write` | 启用写访问（用于 VPI） |
| `-debug_access+read` | 启用读访问 |
| `-kdb` | 生成 KDB 数据库（用于 Verdi） |
| `-linedebug` | 启用行级调试信息 |
| `-sdl` | 启用 SystemVerilog 断言调试 |
| `-debug_pp` | 启用后处理调试 |

### UCLI 调试命令

```bash
# 启动 UCLI
./simv -ucli

# UCLI 常用命令
ucli% run                    # 运行仿真
ucli% stop -time 1000       # 在时间 1000 停止
ucli% stop -posedge clk     # 在时钟上升沿停止
ucli% stop -module top      # 在模块入口停止
ucli% show value a          # 显示信号值
ucli% force a 1             # 强制信号值
ucli% list                  # 列出源代码
ucli% step                  # 单步执行
ucli% bp list               # 列出断点
```

### Verdi 调试

```bash
# 编译时生成 KDB
vcs -full64 -sverilog -kdb -debug_access+all -f filelist.f

# 启动 Verdi
verdi -ssf wave.fsdb -dbdir simv.daidir/kdb &

# 或者从仿真启动 Verdi
./simv -gui=verdi
```

### 波形转储控制

```verilog
// SystemVerilog 中控制波形转储
initial begin
    $vcdpluson;              // 开始转储所有信号
    $vcdpluson(0, top_tb);   // 转储指定层次
    $vcdplusoff;             // 停止转储
end

// FSDB 转储 (Verdi)
initial begin
    $fsdbDumpfile("wave.fsdb");
    $fsdbDumpvars(0, top_tb);
end
```

---

## 7. 性能优化技巧

### 编译优化

| 选项 | 说明 |
|------|------|
| `-O2` 或 `-O3` | 启用编译器优化 |
| `-j <n>` | 多核编译（如 `-j 8`） |
| `-partcomp` | 分区编译，增量编译更快 |
| `-Mdir=<dir>` | 指定编译缓存目录 |
| `-Mupdate` | 增量编译（只重新编译修改的文件） |
| `-notice` | 显示详细编译信息 |

### 运行时优化

| 选项 | 说明 |
|------|------|
| `-simprofile` | 收集仿真性能数据 |
| `-simprofile time` | 时间性能分析 |
| `-simprofile mem` | 内存使用分析 |
| `+vcs+flush+log` | 只刷新日志（比 flush+all 快） |
| `-no_notifier` | 禁用时序检查通知（谨慎使用） |
| `+notimingcheck` | 禁用时序检查（加速但可能掩盖问题） |

### 并行仿真 (SimFlex)

```bash
# 启用多核仿真
vcs -full64 -sverilog -simprofile -simprofile=task ...

# 运行时指定核数
./simv -simprofile -simprofile_args="-num_threads 4"
```

### 内存优化

```bash
# 减少内存使用
vcs -full64 -sverilog +vcs+initreg+random  # 随机初始化寄存器
./simv +vcs+initmem+random                  # 随机初始化存储器
```

### 增量编译技巧

```bash
# 首次完整编译
vcs -full64 -sverilog -Mdir=csrc -Mupdate -f filelist.f

# 后续只编译修改的文件
vcs -full64 -sverilog -Mdir=csrc -Mupdate -f filelist.f
```

---

## 8. 常见问题及解决

### 问题1：编译错误 "Unsupported SystemVerilog construct"

```
** Error: Unsupported SystemVerilog construct ...
```

**解决：**
```bash
# 确保启用 SVERILOG
vcs -full64 -sverilog ...

# 或者使用更新的版本支持
vcs -full64 -sverilog -ntb_opts uvm-1.2 ...
```

### 问题2：UVM 组件找不到

```
** Error: Class 'uvm_component' not found
```

**解决：**
```bash
# 启用 UVM 支持
vcs -full64 -sverilog -ntb_opts uvm

# 或指定 UVM 版本
vcs -full64 -sverilog -ntb_opts uvm-1.2

# 确保 UVM_HOME 设置正确
export UVM_HOME=/path/to/uvm
```

### 问题3：仿真运行时 "Too many objects"

```
** Fatal: Too many objects ...
```

**解决：**
```bash
# 增加对象限制
./simv +vcs+object+limit+5000000

# 或者优化设计减少对象数量
```

### 问题4：波形文件过大

**解决：**
```bash
# 限制转储深度
+vcdplusdepth+5

# 使用 FSDB 压缩
+fsdbfile+wave.fsdb +fsdb+dumpoff

# 只转储需要的信号
$fsdbDumpvars(0, top_tb.u_dut);
```

### 问题5：覆盖率数据不完整

**解决：**
```bash
# 确保覆盖率选项一致
# 编译时
vcs -cm line+cond+fsm+tgl+branch -cm_dir ./cov ...

# 运行时也要带
./simv -cm line+cond+fsm+tgl+branch -cm_dir ./cov ...

# 合并覆盖率
urg -dir ./cov/test1 -dir ./cov/test2 -report merged_cov
```

### 问题6：PLI/VPI 调用失败

```
** Error: PLI routine not found
```

**解决：**
```bash
# 确保编译时链接了 PLI
vcs -full64 -sverilog -debug_access+all -P pli.tab ...

# 检查 pli.tab 文件格式
# 启用 PLI 学习
./simv +vcs+learn+pli
```

### 问题7：时序违例警告

```
** Warning: Setup time violation ...
```

**解决：**
```bash
# 检查设计时序
# 如果是测试环境可以禁用（谨慎）
./simv +notimingcheck

# 或者只禁用特定检查
./simv +no_tchk_msg
```

---

## 9. VCS vs Xcelium (xrun) 对比

| 特性 | VCS | Xcelium (xrun) |
|------|-----|----------------|
| 厂商 | Synopsys | Cadence |
| 编译方式 | 两步法 (vcs + simv) | 单步 (xrun) |
| SystemVerilog | 优秀 | 优秀 |
| UVM 支持 | `-ntb_opts uvm` | 内置支持 |
| 调试工具 | DVE, Verdi | SimVision, Verdi |
| 波形格式 | VPD, FSDB | SHM, FSDB, VCD |
| 性能 | 非常快 | 非常快 |
| 覆盖率 | `-cm` 选项 | `-cov_*` 选项 |
| 增量编译 | `-Mupdate` | 自动增量 |
| 许可证 | 高端 | 高端 |

### 命令对比

| 功能 | VCS | Xcelium |
|------|-----|---------|
| 编译 | `vcs -full64 -sverilog top.sv` | `xrun -64bit top.sv` |
| 运行 | `./simv` | `xrun -R` |
| 波形 | `+vpdfile+wave.vpd` | `-SHM wave.shm` |
| 覆盖率 | `-cm line+cond` | `-cov_line -cov_cond` |
| 调试 | `./simv -gui` | `xrun -gui` |

### 选择建议

- **选择 VCS：**
  - 已有 Synopsys 工具链
  - 团队熟悉 VCS 流程
  - 需要与 PrimeTime 等工具集成
  - 项目历史使用 VCS

- **选择 Xcelium：**
  - 已有 Cadence 工具链
  - 需要单步编译运行
  - 与 Cadence 验证套件集成
  - 项目历史使用 Xcelium

---

## 10. 实用技巧

### 快速检查语法

```bash
# 只编译不链接（快速语法检查）
vcs -full64 -sverilog -elab_no_run -f filelist.f
```

### 批量运行测试

```bash
# run_tests.sh
#!/bin/bash
TESTS="test1 test2 test3"
for test in $TESTS; do
    echo "Running $test..."
    ./simv +UVM_TESTNAME=$test \
           +vcs+flush+all \
           -cm line+cond \
           -cm_dir ./cov/$test \
           -l ./log/${test}.log
done
```

### 覆盖率合并

```bash
# 合并多个测试的覆盖率
urg -dir ./cov/test1.vdb \
    -dir ./cov/test2.vdb \
    -dir ./cov/test3.vdb \
    -report merged_coverage \
    -format both
```

### 使用 TCL 脚本控制仿真

```tcl
# run.tcl
run 1000           ;# 运行 1000 时间单位
stop -time 5000    ;# 在 5000 时停止
show value top.clk ;# 显示信号值
force top.rst 0    ;# 强制信号
run                ;# 继续运行
quit               ;# 退出
```

```bash
./simv -ucli -do run.tcl
```

---

## 11. 环境变量

| 变量 | 说明 |
|------|------|
| `VCS_HOME` | VCS 安装路径 |
| `VCS_ARCH_OVERRIDE` | 覆盖目标架构 |
| `VCS_TARGET_ARCH` | 指定目标架构 |
| `SNPSLMD_LICENSE_FILE` | 许可证服务器 |
| `UVM_HOME` | UVM 库路径 |
| `VERDI_HOME` | Verdi 安装路径 |
| `NOVAS_HOME` | Novas (旧版 Verdi) 路径 |

---

## 12. 相关链接

### 官方资源

- Synopsys VCS 官方文档: [Solvenet](https://solvnet.synopsys.com)
- VCS 用户指南: 随工具安装在 `$VCS_HOME/doc/`
- UVM 官方库: [Accellera UVM](https://www.accellera.org/downloads/standards/uvm)

### 本地文档

```bash
# 查看 VCS 文档
ls $VCS_HOME/doc/

# 常用文档
# vcs.pdf - VCS 用户指南
# vcscomp.pdf - 编译选项参考
# vcssim.pdf - 仿真选项参考
# vcsug.pdf - 快速入门
```

### 相关笔记

- [[04-Tools/06-Verdi/00-Verdi|Verdi 调试工具]] - Verdi 波形调试
- [[11-UVM源码学习/UVM源代码研究|UVM 源码研究]] - UVM 验证方法学
- [[03-Protocol/AXI/00-AXI|AXI 协议]] - AXI 协议（验证常用）

### 常用文件模板

- [[07-Scripts/00-Makefile|Makefile]] - Makefile 模板
- [[07-Scripts/00-Python脚本|Python脚本]] - 运行脚本模板

---

## 快速参考卡片

```bash
# === 一行命令 ===

# 编译并运行
vcs -full64 -sverilog -f fl.f top && ./simv +vcs+flush+all

# 编译带覆盖率
vcs -full64 -sverilog -cm line+cond+fsm -cm_dir cov -f fl.f top

# 运行带波形
./simv +vpdfile+wave.vpd +vcs+flush+all -l sim.log

# 查看波形
verdi -ssf wave.fsdb &

# 合并覆盖率
urg -dir cov/*.vdb -report merged_cov
```

---

> [!tip] 提示
> 始终使用 `-full64` 选项，现代设计都是 64 位的。
> 使用 `-sverilog` 启用 SystemVerilog 支持，即使只写 Verilog。

> [!warning] 注意
> 仿真运行时的选项必须与编译时一致（如覆盖率选项），否则会报错或数据不完整。
