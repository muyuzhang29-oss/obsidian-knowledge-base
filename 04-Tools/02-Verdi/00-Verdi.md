---
tags: [Tools, Verdi, 波形, 调试, Synopsys, 核心]
---

# Verdi 波形调试笔记

## 1. Verdi 概述和特点

Verdi 是 Synopsys 公司开发的专业级调试工具，广泛用于数字IC设计的波形查看和源码调试。

### 核心特点

- **高性能波形查看**：支持 FSDB、VCD、SHM 等多种波形格式
- **源码级调试**：支持 RTL 源码与波形的双向关联
- **智能追踪**：Driver/Load 追踪功能快速定位信号驱动关系
- **Transaction 级调试**：支持 UVM Transaction 的可视化分析
- **覆盖率集成**：与 VCS 覆盖率数据无缝集成
- **脚本自动化**：支持 TCL 脚本实现自动化调试流程

### 支持的波形格式

| 格式 | 说明 | 特点 |
|------|------|------|
| FSDB | Fast Signal Database | 最常用，压缩率高，Verdi 原生格式 |
| VCD | Value Change Dump | 标准格式，兼容性好 |
| SHM | Cadence 格式 | 用于 Cadence 工具链 |
| VPD | VCS PlusDump | VCS 默认格式 |

---

## 2. 启动和加载波形

### 2.1 命令行启动

```bash
# 基本启动
verdi &

# 加载设计库
verdi -dbdir simv.daidir &

# 加载 FSDB 波形
verdi -ssf waveform.fsdb &

# 加载设计和波形
verdi -dbdir simv.daidir -ssf waveform.fsdb &

# 指定 top 模块
verdi -top worklib.top_module:sv -ssf waveform.fsdb &

# 加载 Verilog 源码
verdi -sv -f filelist.f -ssf waveform.fsdb &
```

### 2.2 VCS 联合启动

```bash
# VCS 编译时生成 FSDB
vcs -full64 -sverilog -debug_access+all -kdb -lca source.sv

# 仿真时生成 FSDB
./simv +fsdb+dumpfile+waveform.fsdb

# 启动 Verdi 加载波形
verdi -dbdir simv.daidir -ssf waveform.fsdb &
```

### 2.3 图形界面加载

1. 启动 Verdi 后，选择 `File` -> `Open`
2. 选择波形文件（.fsdb/.vcd）
3. 在 Signal Browser 中选择要查看的模块
4. 双击信号添加到波形窗口

---

## 3. 常用快捷键

### 3.1 波形导航

| 快捷键 | 功能 |
|--------|------|
| `Ctrl + F` | 搜索信号 |
| `n` / `N` | 跳转到下一个/上一个变化沿 |
| `←` / `→` | 左右移动时间轴 |
| `Shift + ←` / `Shift + →` | 大步移动时间轴 |
| `Home` / `End` | 跳转到波形起始/结束位置 |
| `Ctrl + 鼠标滚轮` | 水平缩放 |
| `Shift + 鼠标滚轮` | 垂直缩放 |
| `z` | 框选放大 |
| `u` | 撤销缩放 |

### 3.2 信号操作

| 快捷键 | 功能 |
|--------|------|
| `g` | 信号分组 |
| `Ctrl + g` | 取消分组 |
| `Ctrl + 鼠标左键` | 多选信号 |
| `Delete` | 删除选中信号 |
| `Ctrl + a` | 全选信号 |
| `Ctrl + d` | 复制信号 |

### 3.3 标记和书签

| 快捷键 | 功能 |
|--------|------|
| `m` | 在当前位置添加标记 |
| `M` | 添加带注释的标记 |
| `Ctrl + m` | 管理所有标记 |
| `F2` | 跳转到下一个标记 |
| `Shift + F2` | 跳转到上一个标记 |

### 3.4 视图控制

| 快捷键 | 功能 |
|--------|------|
| `Ctrl + t` | 打开 Transaction 视图 |
| `Ctrl + s` | 打开源码窗口 |
| `Ctrl + w` | 打开波形窗口 |
| `Ctrl + b` | 打开断点窗口 |
| `F5` | 刷新波形 |

---

## 4. 信号添加和分组

### 4.1 信号添加方法

#### 方法一：从 Signal Browser 添加

1. 在左侧 Signal Browser 面板展开模块层次
2. 选中目标信号
3. 双击或拖拽到波形窗口

#### 方法二：使用信号搜索

1. 按 `Ctrl + F` 打开搜索框
2. 输入信号名称（支持通配符 `*` 和 `?`）
3. 点击搜索结果中的信号

#### 方法三：从源码添加

1. 在源码窗口中找到目标信号
2. 右键选择 `Add to Waveform`
3. 或直接拖拽信号名到波形窗口

#### 方法四：通过 TCL 命令添加

```tcl
# 添加单个信号
verdiSetSignalAdd -name "top.dut.clk"

# 添加总线信号
verdiSetBusAdd -name "top.dut.data[7:0]"

# 添加模块所有信号
verdiSetModuleAdd -name "top.dut"
```

### 4.2 信号分组

#### 创建分组

1. 选中多个信号（`Ctrl + 鼠标左键`）
2. 右键选择 `Group` -> `Create Group`
3. 输入分组名称

#### 分组操作

```tcl
# 创建分组
verdiGroupCreate -name "Control Signals" -signals {top.clk top.rst top.en}

# 展开/折叠分组
verdiGroupExpand -name "Control Signals"
verdiGroupCollapse -name "Control Signals"

# 删除分组
verdiGroupDelete -name "Control Signals"
```

#### 信号排序

- `Ctrl + ↑` / `Ctrl + ↓`：上下移动选中信号
- 右键菜单 -> `Sort` -> 按名称/层次排序

---

## 5. 断点设置方法

### 5.1 源码断点

#### 设置断点

1. 在源码窗口中，点击行号左侧的灰色区域
2. 出现红色圆点表示断点已设置
3. 或使用快捷键 `F9` 切换断点

#### 断点属性设置

1. 双击断点打开属性窗口
2. 可设置：
   - **Condition**：条件表达式
   - **Hit Count**：命中次数
   - **Action**：触发动作

#### TCL 命令设置断点

```tcl
# 设置简单断点
verdiSetBreakpoint -file "source.sv" -line 42

# 设置条件断点
verdiSetBreakpoint -file "source.sv" -line 42 -condition "data == 8'hFF"

# 设置信号值断点
verdiSetBreakpoint -signal "top.dut.state" -value "IDLE"

# 删除断点
verdiDeleteBreakpoint -file "source.sv" -line 42

# 禁用/启用断点
verdiDisableBreakpoint -file "source.sv" -line 42
verdiEnableBreakpoint -file "source.sv" -line 42
```

### 5.2 信号断点

1. 在波形窗口中右键点击信号
2. 选择 `Set Breakpoint`
3. 设置触发条件：
   - 上升沿 `posedge`
   - 下降沿 `negedge`
   - 特定值变化
   - 值范围

### 5.3 断点管理

- 打开断点窗口：`View` -> `Breakpoints`
- 可以批量启用/禁用/删除断点
- 支持断点导入导出

---

## 6. 源码级调试

### 6.1 源码与波形同步

#### 打开源码窗口

1. 菜单 `View` -> `Source Code`
2. 或快捷键 `Ctrl + s`

#### 同步操作

- **波形到源码**：在波形中选中时间点，右键 `Show Source`
- **源码到波形**：在源码中选中信号，右键 `Show in Waveform`
- **双向同步**：开启 `Sync Mode` 自动同步

### 6.2 源码调试功能

#### 代码高亮

- 当前仿真时间点的执行行高亮显示
- 变化信号用不同颜色标记

#### 变量查看

1. 在源码中悬停变量显示当前值
2. 右键变量选择 `Add to Watch`
3. 在 Watch 窗口实时监控变量变化

### 6.3 源码导航

```tcl
# 跳转到源码位置
verdiSourceGoto -file "source.sv" -line 100

# 搜索源码
verdiSourceSearch -pattern "always_ff" -direction forward

# 查找信号定义
verdiFindDefinition -signal "data_reg"

# 查找信号使用
verdiFindUsage -signal "data_reg"
```

---

## 7. 追踪功能（Driver/Load 追踪）

### 7.1 Driver 追踪

Driver 追踪用于查找信号的驱动源。

#### 操作步骤

1. 在波形窗口中选中目标信号
2. 右键选择 `Trace` -> `Trace Driver`
3. 或使用快捷键 `Ctrl + Shift + D`
4. 弹出追踪结果窗口，显示所有驱动该信号的语句

#### 追踪结果分析

- **绿色箭头**：当前活跃的驱动
- **红色箭头**：不活跃的驱动
- **蓝色箭头**：条件驱动（多驱动情况）

#### TCL 命令

```tcl
# 追踪信号驱动
verdiTraceDriver -signal "top.dut.data"

# 追踪到源码位置
verdiTraceDriver -signal "top.dut.data" -toSource

# 追踪多驱动信号
verdiTraceDriver -signal "top.dut.data" -showAllDrivers
```

### 7.2 Load 追踪

Load 追踪用于查找信号被哪些逻辑消费。

#### 操作步骤

1. 选中目标信号
2. 右键选择 `Trace` -> `Trace Load`
3. 或使用快捷键 `Ctrl + Shift + L`
4. 查看信号的所有负载

#### 应用场景

- 查找信号扇出
- 定位信号影响范围
- 分析关键路径

### 7.3 综合追踪

```tcl
# 同时追踪 Driver 和 Load
verdiTraceBoth -signal "top.dut.data"

# 追踪并生成报告
verdiTraceReport -signal "top.dut.data" -output trace_report.txt

# 追踪整个路径
verdiTracePath -from "top.dut.input" -to "top.dut.output"
```

---

## 8. 覆盖率查看

### 8.1 加载覆盖率数据

```bash
# 启动 Verdi 时加载覆盖率
verdi -cov -covdir coverage.vdb &

# 或在 Verdi 中加载
# File -> Load Coverage Database
```

### 8.2 覆盖率类型

#### 代码覆盖率

- **Line Coverage**：行覆盖率
- **Condition Coverage**：条件覆盖率
- **FSM Coverage**：状态机覆盖率
- **Toggle Coverage**：翻转覆盖率

#### 功能覆盖率

- **Covergroup**：覆盖组
- **Coverpoint**：覆盖点
- **Cross Coverage**：交叉覆盖

### 8.3 覆盖率查看操作

1. 打开覆盖率窗口：`View` -> `Coverage`
2. 左侧显示覆盖率层次结构
3. 右键模块选择：
   - `Show Source`：查看源码覆盖情况
   - `Show Details`：查看详细覆盖率数据
   - `Generate Report`：生成覆盖率报告

#### TCL 命令

```tcl
# 加载覆盖率数据库
verdiCovLoad -dir "coverage.vdb"

# 查看覆盖率摘要
verdiCovSummary

# 导出覆盖率报告
verdiCovReport -output coverage_report.html -format html

# 过滤覆盖率数据
verdiCovFilter -type line -threshold 80
```

### 8.4 覆盖率与波形关联

- 在覆盖率窗口双击未覆盖的代码行
- 自动跳转到波形对应时间点
- 分析未覆盖原因

---

## 9. 脚本自动化

### 9.1 TCL 脚本基础

#### 启动 TCL 控制台

- 菜单 `Tools` -> `TCL Console`
- 或快捷键 `Ctrl + Shift + T`

#### 基本 TCL 命令

```tcl
# 打开波形
verdiOpenWaveform -file "waveform.fsdb"

# 设置时间范围
verdiSetTimeRange -start 0 -end 1000ns

# 添加信号
verdiSignalAdd -name "top.clk"

# 保存波形配置
verdiSaveWaveformConfig -file "waveform.cfg"

# 加载波形配置
verdiLoadWaveformConfig -file "waveform.cfg"
```

### 9.2 自动化脚本示例

#### 批量添加信号

```tcl
#!/usr/bin/tclsh
# add_signals.tcl

set signal_list {
    "top.dut.clk"
    "top.dut.rst_n"
    "top.dut.data_in[7:0]"
    "top.dut.data_out[7:0]"
    "top.dut.state"
    "top.dut.next_state"
}

verdiOpenWaveform -file "waveform.fsdb"

foreach sig $signal_list {
    verdiSignalAdd -name $sig
    puts "Added signal: $sig"
}

verdiZoomFull
puts "All signals added successfully"
```

#### 自动化调试流程

```tcl
#!/usr/bin/tclsh
# auto_debug.tcl

# 打开设计和波形
verdiOpenDesign -dbdir "simv.daidir"
verdiOpenWaveform -file "waveform.fsdb"

# 添加关键信号
verdiSignalAdd -name "top.dut.clk"
verdiSignalAdd -name "top.dut.error_flag"

# 设置断点
verdiSetBreakpoint -file "error_handler.sv" -line 42 \
    -condition "error_flag == 1"

# 设置信号断点
verdiSetSignalBreakpoint -signal "top.dut.error_flag" \
    -value 1 -action "verdiTakeSnapshot"

# 启动追踪
verdiTraceDriver -signal "top.dut.error_flag"

# 保存配置
verdiSaveSession -file "debug_session.rc"

puts "Debug setup completed"
```

### 9.3 批处理模式

```bash
# 非交互模式运行 TCL 脚本
verdi -batch -tcl auto_debug.tcl

# 生成报告后退出
verdi -batch -tcl generate_report.tcl -exit
```

### 9.4 脚本调试技巧

```tcl
# 启用 TCL 调试
verdiDebug -enable

# 设置断点
debugger_break

# 查看变量
puts "Current time: [verdiGetCurrentTime]"

# 错误处理
if {[catch {verdiSignalAdd -name "invalid.signal"} result]} {
    puts "Error: $result"
}
```

---

## 10. 常见问题及解决

### 10.1 波形加载问题

#### 问题：FSDB 文件加载失败

**症状**：提示 "Invalid FSDB file" 或加载无反应

**解决方案**：
```bash
# 检查文件完整性
ls -lh waveform.fsdb

# 使用 nWave 检查文件
nWave -ssf waveform.fsdb

# 重新生成 FSDB
# 在 testbench 中添加 $fsdbDumpfile("waveform.fsdb")
# $fsdbDumpvars(0, top);
```

#### 问题：波形显示不完整

**症状**：部分时间段波形缺失

**解决方案**：
1. 检查仿真时间范围
2. 确认 `$fsdbDumpvars` 的层次设置
3. 使用 `verdiZoomFull` 查看完整波形

### 10.2 源码显示问题

#### 问题：源码与波形不同步

**症状**：点击波形无法跳转到对应源码

**解决方案**：
1. 重新加载设计库：`File` -> `Reload Design`
2. 检查源码路径设置：`Tools` -> `Options` -> `Source Code`
3. 确保编译时生成了调试信息（`-debug_access+all`）

#### 问题：源码显示乱码

**症状**：中文注释或特殊字符显示异常

**解决方案**：
1. 设置正确的字符编码：`Tools` -> `Options` -> `Encoding`
2. 转换源码文件编码为 UTF-8

### 10.3 性能问题

#### 问题：大波形文件加载缓慢

**解决方案**：
```bash
# 使用波形分割
verdi -ssf part1.fsdb -ssf part2.fsdb &

# 使用时间范围加载
verdi -ssf waveform.fsdb -time "0ns" "1000ns" &

# 增加内存限制
verdi -ssf waveform.fsdb -maxmem 4096 &
```

#### 问题：追踪功能响应慢

**解决方案**：
1. 限制追踪深度：`Tools` -> `Options` -> `Trace` -> `Max Depth`
2. 使用局部追踪而非全路径追踪
3. 关闭不必要的信号窗口

### 10.4 许可证问题

#### 问题：License 获取失败

**解决方案**：
```bash
# 检查许可证服务器
lmstat -a

# 设置许可证文件
export SNPSLMD_LICENSE_FILE=27000@license_server

# 或使用端口@主机格式
export LM_LICENSE_FILE=1717@license_server
```

### 10.5 快捷键不响应

**解决方案**：
1. 检查输入法是否切换到英文模式
2. 重置快捷键配置：`Tools` -> `Options` -> `Key Bindings` -> `Reset`
3. 检查是否有其他软件占用快捷键

---

## 11. 相关链接

### 官方资源

- [Synopsys Verdi 官方文档](https://www.synopsys.com/verification/debug.html)
- [Verdi 快速入门指南](https://solvnet.synopsys.com)
- [Synopsys TCL 手册](https://www.synopsys.com)

### 学习资源

- Verdi 使用技巧（Synopsys SolvNet）
- 数字IC验证调试方法论
- UVM调试最佳实践

### 相关工具

| 工具 | 用途 |
|------|------|
| VCS | 仿真编译器 |
| nWave | 独立波形查看器 |
| UCLI | 统一命令行接口 |
| DVE | 图形化调试环境（旧版） |

### 本笔记相关

- [[04-Tools/05-VCS/00-VCS|VCS 编译仿真]]
- [[04-Tools/07-QuestaSim/00-QuestaSim|QuestaSim 使用]]
- [[03-Protocol/00-协议索引|协议验证]]

---

## 12. 附录：Verdi 环境配置

### 环境变量设置

```bash
# ~/.bashrc 或 ~/.cshrc
export VERDI_HOME=/path/to/verdi
export PATH=$VERDI_HOME/bin:$PATH

# 指定 FSDB 库路径
export LD_LIBRARY_PATH=$VERDI_HOME/share/PLI/lib:$LD_LIBRARY_PATH

# 设置默认配置
export VERDI_DEFAULT_CONFIG=$HOME/.verdi_config
```

### VCS 联合配置

```bash
# 编译选项
vcs -full64 -sverilog -debug_access+all -kdb -lca source.sv

# 仿真选项
./simv +fsdb+dumpfile+waveform.fsdb +fsdb+dumpvars
```

### 配置文件示例

```tcl
# ~/.verdi_config
set verdi_config(source_code_path) "./src"
set verdi_config(waveform_default_format) "fsdb"
set verdi_config(trace_max_depth) 10
set verdi_config(auto_sync) true
```

---

*Last Updated: 2026-06-02*
