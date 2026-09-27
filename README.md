---
tags: [说明, 知识库维护]
created: 2026-04-01
updated: 2026-09-27
---

# Obsidian Knowledge Base

个人知识库，IC 验证技术学习与工作记录。

## 目录结构

| 目录 | 内容 | 篇数 |
|------|------|------|
| `00-工作台` | 主页、任务、进度、总索引、技能树、学习路径 | 6 |
| `01-SV语法` | SystemVerilog | 6 |
| `02-UVM` | UVM 验证方法学 | 13 |
| `03-Protocol` | 协议规范 | 11 |
| `04-Tools` | EDA 工具指南 | 10 |
| `05-Verification` | 验证方法 | 15 |
| `06-UVM-Template` | UVM 环境模板 | 15 |
| `07-Scripts` | 脚本与自动化 | 6 |
| `08-Projects` | 验证项目实战 | 10 |
| `09-Issues` | 问题追踪 | 5 |
| `10-数字设计` | 数字电路基础 | 8 |
| `11-Vault维护` | 审计与健康检查 | 3 |

合计 **110** 篇核心笔记（不含 `.obsidian` / `.git` / `.claude`）。

入口：[[00-工作台/00-主页]]。

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

```powershell
cd D:\obsdian\knowledge-base
git pull
```

编辑笔记后推送：

```powershell
git add .
git commit -m "描述本次修改的内容"
git push
```

### 方式三：Obsidian 命令面板

在 Obsidian 中按 `Ctrl+P`，输入 `Git` 查看所有可用命令。

## 查看文档

阅读时请使用 **阅读模式**（`Ctrl+E` 切换），以获得更好的排版和 Mermaid 图表显示效果。




