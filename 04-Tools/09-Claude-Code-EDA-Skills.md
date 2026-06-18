---
tags:
  - tool
  - eda
  - claude
aliases:
  - EDA仿真技能
  - Claude Code EDA
---

# 🛠️ Claude Code EDA 仿真技能

> [!abstract] 概述
> 本文档记录了 Claude Code 中配置的 EDA 仿真技能，用于自动化运行 Cadence xrun 仿真和查看 SimVision 波形。

---

## 🖥️ 环境概览

> [!info] 系统配置
> | 组件 | 说明 |
> |------|------|
> | **WSL 发行版** | AlmaLinux-8 |
> | **WSL 用户** | muyuEDA / 密码: 1220 |
> | **EDA 工具** | Cadence Xcelium 23.09 |
> | **工具路径** | `/opt/eda/cadence/XCELUMMAIN2309/tools/bin/` |
> | **X11 显示** | VcXsrv (Windows) + WSLg (备用) |
> | **tmux 会话** | muyu (在 AlmaLinux-8 内) |

---

## 🎯 Skill 1: alma-tmux

> [!note] 用途
> 控制 AlmaLinux-8 内部的 tmux 会话，省去 `powershell → wsl → tmux` 的层层嵌套。

### 触发方式

提到以下关键词时自动触发：
- `alma`、`muyuEDA`、`muyu session`
- 想在 AlmaLinux 里执行命令

### 命令模板

> [!example]- 发送命令
> ```bash
> powershell.exe -Command "wsl -d AlmaLinux-8 -u muyuEDA -- tmux send-keys -t muyu '<命令>' Enter"
> ```

> [!example]- 捕获输出
> ```bash
> # 完整输出
> powershell.exe -Command "wsl -d AlmaLinux-8 -u muyuEDA -- bash -c 'tmux capture-pane -t muyu -p -S -'"
>
> # 最后 N 行
> powershell.exe -Command "wsl -d AlmaLinux-8 -u muyuEDA -- bash -c 'tmux capture-pane -t muyu -p -S - | tail -20'"
> ```

> [!example]- 特殊按键
> ```bash
> # Ctrl+C
> powershell.exe -Command "wsl -d AlmaLinux-8 -u muyuEDA -- tmux send-keys -t muyu C-c"
>
> # Escape
> powershell.exe -Command "wsl -d AlmaLinux-8 -u muyuEDA -- tmux send-keys -t muyu Escape"
> ```

### 使用示例

```
我：在 alma 里运行 htop
我：看看 muyu session 的输出
我：在 AlmaLinux 里装个包
```

---

## 🎯 Skill 2: eda-sim

> [!note] 用途
> 自动化 EDA 仿真流程，包括运行 xrun 仿真和查看 SimVision 波形。

### 触发方式

提到以下关键词时自动触发：
- `xrun`、`simvision`、`simulate`、`run test`
- `waveform`、`UVM`、`DUT verification`
- `仿真`、`跑测试`、`看波形`

### 前置条件

> [!warning] 启动前检查
> 1. VcXsrv 必须在 Windows 上运行
> 2. AlmaLinux-8 的 tmux 会话 muyu 必须存在
> 3. DISPLAY 环境变量必须设置为 `localhost:0`

### 启动 VcXsrv

```powershell
# 在 PowerShell 中执行
Start-Process 'C:\Program Files (x86)\VcXsrv\vcxsrv.exe' -ArgumentList ':0 -multiwindow -ac -nowgl -listen tcp'
```

### 设置显示

```bash
export DISPLAY=localhost:0
```

### 运行仿真

> [!example]- 基本 UVM 仿真
> ```bash
> cd /home/muyuEDA/<项目目录>
> xrun <top.sv> -uvm -access +r -gui
> ```

> [!example]- 完整示例
> ```bash
> xrun \
>   +incdir+./sv \
>   +incdir+./tb \
>   -uvm \
>   -access +r \
>   -gui \
>   -sv_seed random \
>   tb_top.sv
> ```

### 常用 xrun 选项

| 选项 | 说明 |
|------|------|
| `-uvm` | 启用 UVM |
| `-access +r` | 读权限，用于波形转储 |
| `-gui` | 打开 SimVision GUI |
| `-sv_seed <value>` | 设置随机种子 |
| `-sv_lib <library>` | 加载 DPI 库 |
| `-incdir <dir>` | 包含目录 |
| `-define <macro>` | 定义宏 |
| `-timescale <scale>` | 设置时间单位 |
| `-exit` | 仿真结束后退出 |
| `+UVM_TESTNAME=<name>` | 指定 UVM test |

### 查看波形

> [!example]- 独立打开 SimVision
> ```bash
> export DISPLAY=localhost:0
> simvision -64 /path/to/wave.vcd &
> ```

> [!example]- SHM 数据库
> ```bash
> simvision -64 /path/to/shm_dir &
> ```

### 回归测试

```bash
for TEST in test1 test2 test3; do
  xrun tb_top.sv -uvm -access +r -sv_seed random +UVM_TESTNAME=$TEST -exit
done
```

---

## 📂 文件路径映射

| Windows 路径 | WSL 路径 |
|-------------|---------|
| `C:\Users\MI\` | `/mnt/c/Users/MI/` |
| `D:\` | `/mnt/d/` |
| `E:\` | `/mnt/e/` |
| WSL 主目录 | `/home/muyuEDA/` |

> [!tip] 提示
> Windows 路径在 WSL 中直接通过 `/mnt/` 访问，无需复制文件。

---

## ❓ 常见问题

> [!failure]- SimVision 空白或卡顿
> ```powershell
> # 检查 VcXsrv 是否运行
> Get-Process vcxsrv
>
> # 如果没有运行，启动它
> Start-Process 'C:\Program Files (x86)\VcXsrv\vcxsrv.exe' -ArgumentList ':0 -multiwindow -ac -nowgl -listen tcp'
> ```
>
> 然后在 WSL 中：
> ```bash
> export DISPLAY=localhost:0
> ```

> [!failure]- VcXsrv 连接失败
> 1. 确认防火墙已放行 VcXsrv
> 2. 以管理员身份运行 PowerShell，执行：
> ```powershell
> New-NetFirewallRule -DisplayName "VcXsrv" -Direction Inbound -Program "C:\Program Files (x86)\VcXsrv\vcxsrv.exe" -Action Allow
> ```

> [!failure]- xrun 编译错误
> - 检查 include 路径：`+incdir+./sv`
> - 确认 UVM 库可用（Xcelium 自带）
> - 设置时间单位：`-timescale 1ns/1ps`

> [!failure]- 权限问题
> ```bash
> chmod +x <script>
> ls -la <file>  # 检查文件权限
> ```

---

## 💾 存储空间

| 分区 | 总容量 | 可用 | 说明 |
|------|--------|------|------|
| WSL 根目录 | 1007G | 607G | 存放 EDA 工具和项目 |
| E:\ | 932G | 89G | WSL 虚拟磁盘存放位置，需注意空间 |

---

## 🚀 快速参考

> [!done] 在 Claude Code 中的常用指令
> ```
> "在 alma 里运行 xrun tb_top.sv -uvm -gui"   → 自动执行仿真
> "看看波形"                                     → 自动打开 SimVision
> "在 AlmaLinux 里跑一下测试"                    → 自动触发 eda-sim skill
> ```

---

*最后更新：2026-05-15*
