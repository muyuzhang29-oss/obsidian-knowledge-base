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

## Git 同步操作

每次开始工作前先拉取最新，结束后推送修改：

```bash
git pull           # 从 GitHub 同步到本地
# ... 编辑笔记 ...
git add .          # 暂存所有更改
git commit -m "描述修改内容"   # 提交
git push           # 推送到 GitHub
```

或在 Obsidian 中按 `Ctrl+P` 搜索 `Git` 查看所有命令（已配置开机自动拉取、定时自动备份）。
