# Obsidian Knowledge Base

个人知识库，IC 验证技术学习与工作记录。

## 目录结构

| 目录 | 内容 |
|------|------|
| `00-工作台` | 工作台与仪表盘 (18篇) |
| `00-索引` | 索引与导航 (3篇) |
| `01-SV语法` | SystemVerilog (6篇) |
| `02-UVM` | UVM 验证方法学 (13篇) |
| `03-Protocol` | 协议规范 (10篇) |
| `04-Tools` | EDA 工具指南 (10篇) |
| `05-Verification` | 验证方法学 (16篇) |
| `07-Scripts` | 脚本与自动化 (7篇) |
| `08-Projects` | 验证项目实战 (9篇) |
| `09-Issues` | 问题追踪 (5篇) |
| `10-Notes` | 学习笔记 (8篇) |

## 使用工具

- **Obsidian** — 知识管理与笔记
- **Git** — 版本控制

## 同步方式

### 方式一：自动同步（推荐）

已安装 **Obsidian Git** 插件，配置如下：

- 打开 Obsidian 时自动从 GitHub 拉取最新内容
- 每 3 分钟（300 秒）自动备份并推送到 GitHub
- 你只需专注于写笔记，同步全自动完成

### 方式二：手动同步（终端）

如果习惯手动控制，打开终端（`Win+R` → 输入 `powershell` → 回车），依次执行：

**开始工作前拉取最新：**
```powershell
cd D:\obsdian\knowledge-base
git pull
```

**编辑笔记后推送到 GitHub：**
```powershell
git add .
git commit -m "描述本次修改的内容"
git push
```

验证是否推送成功：终端输出最后一行应为 `main -> main`。

### 方式三：Obsidian 命令面板

在 Obsidian 中按 `Ctrl+P`，输入 `Git` 查看所有可用命令，选择执行即可。

> **注意**：如果搜不到 Git 相关命令，请检查设置 → 社区插件 → 确保 **Git** 插件已启用。

## 查看文档

阅读文档时请使用 **阅读模式**（`Ctrl+E` 切换），以获得更好的排版和 Mermaid 图表显示效果。编辑模式用于修改内容。

