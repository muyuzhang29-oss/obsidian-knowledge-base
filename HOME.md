---
cssclass: dashboard
banner_y: 0.3
banner_lock: true
created: 2026-04-01
updated: 2026-05-13
tags:
  - home
  - dashboard
  - 索引
aliases:
  - 主页
  - 首页
  - Dashboard
---

# 🏠 数字验证工程师知识库

> [!quote] 💡
> **芯片验证** · **UVM方法学** · **协议规范** · **持续精进**

> [!example] 🚀 快速入口
> [[00-工作台/00-主页|🏠 工作台仪表盘]] · [[00-工作台/01-今日任务|📋 今日任务]] · [[00-工作台/02-学习进度|📈 学习进度]] · [[00-索引/00-总索引|📑 总索引]]

---

## 📊 知识库概览

> [!info] 📈 数据统计
> | 指标 | 数值 | 说明 |
> |------|------|------|
> | 📝 总笔记数 | 33+ | Markdown 文件总数 |
> | 📁 分类数 | 11 | 一级文件夹数量 |

---

## 🎯 快速导航

> [!example] 🔬 UVM 验证方法学
> ```
> SV基础 → UVM入门 → Phase机制 → config_db → Sequence机制 → 环境搭建 → 源码研究
> ```

> [!example] 🔌 协议规范学习
> ```
> APB(简单) → AXI(复杂) → I2C/SPI/UART(外设)
> ```

---

### 📂 知识分类

> [!note] 📝 **SystemVerilog** (3篇)
> 01-SV语法/00-入门 · 01-SV语法/01-数据类型 · 01-SV语法/02-类

> [!note] 🔬 **UVM** (5篇)
> 02-UVM/00-入门 · 02-UVM/01-Phase机制 · 02-UVM/02-config_db · 02-UVM/03-Sequence机制 · 02-UVM/04-组件

> [!note] 🔌 **协议规范** (5种协议)
> AXI · APB · I2C · SPI · UART

> [!note] 🔧 **工具链** (4种工具)
> Linux · GVim · xrun · imc

> [!note] ✅ **验证方法** (3篇)
> 00-验证计划 · 01-覆盖率 · 02-FMEA-FuSa

> [!note] 🏗️ **环境搭建** (1篇)
> 00-环境搭建

> [!note] 📜 **脚本工具** (3篇)
> 00-Makefile · 00-Python · 01-Log解析

> [!note] 📚 **UVM源码** (4篇)
> UVM源代码研究 · Factory机制 · Component与Root · TestBench启动

---

## 📈 最近更新

> [!tip] 📅 最近更新的文档
> ```dataview
> TABLE
>   file.folder AS "分类",
>   file.mtime AS "更新时间"
> FROM ""
> WHERE file.mtime >= date(today) - dur(7 days) AND file.name != this.file.name
> SORT file.mtime DESC
> LIMIT 15
> ```

---

## 📚 推荐阅读

> [!info] 📖 核心文档
> ```dataview
> TABLE
>   file.folder AS "分类",
>   file.tags AS "标签"
> FROM ""
> WHERE contains(file.tags, "#核心")
> SORT file.mtime DESC
> LIMIT 10
> ```

---

## ⏰ 待办事项

> [!todo] 📋 待办
> ```dataview
> TASK
> WHERE !completed AND contains(tags, "#today")
> SORT created DESC
> ```

---

## 🔍 快捷操作

| 操作 | 快捷键 | 说明 |
|------|--------|------|
| 快速切换 | `Ctrl+O` | 快速打开文件 |
| 命令面板 | `Ctrl+P` | 执行命令 |
| 全局搜索 | `Ctrl+Shift+F` | 搜索内容 |
| 打开图谱 | `Ctrl+G` | 查看关系图谱 |
| 刷新视图 | `Ctrl+R` | 刷新 Dataview |

---

*最后更新: `=dateformat(date(now), "yyyy-MM-dd HH:mm")`*