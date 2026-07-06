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

---

## 📊 知识库概览

> [!info] 📈 数据统计
> 
> | 指标 | 数值 | 说明 |
> |------|------|------|
> | 📝 总笔记数 | `=length(dv.pages("").where(p => p.file.extension == "md"))` | Markdown 文件总数 |
> | 📁 分类数 | `=length(dv.pages("").where(p => p.file.folder.split("/").length == 1 && p.file.folder != ""))` | 一级文件夹数量 |
> | 🏷️ 标签数 | `=length(dv.pages("").flatMap(p => p.file.tags))` | 所有标签总数 |
> | 🔗 链接数 | `=length(dv.pages("").flatMap(p => p.file.inlinks))` | 双向链接总数 |

---

## 🎯 快速导航

### 📚 核心学习路径

> [!example]- 🔬 UVM 验证方法学
> 
> ```mermaid
> graph LR
>     A[SV 基础] --> B[UVM 入门]
>     B --> C[Phase 机制]
>     C --> D[config_db]
>     D --> E[Sequence 机制]
>     E --> F[环境搭建]
>     F --> G[源码研究]
>     
>     style A fill:#fce7f3,stroke:#ec4899,color:#9d174d
>     style B fill:#dbeafe,stroke:#3b82f6,color:#1e40af
>     style C fill:#dbeafe,stroke:#3b82f6,color:#1e40af
>     style D fill:#dbeafe,stroke:#3b82f6,color:#1e40af
>     style E fill:#dbeafe,stroke:#3b82f6,color:#1e40af
>     style F fill:#dcfce7,stroke:#22c55e,color:#166534
>     style G fill:#93c5fd,stroke:#2563eb,color:#1e3a8a
> ```
> 
> **进度**: 6/7 完成

> [!example]- 🔌 协议规范学习
> 
> ```mermaid
> graph LR
>     A[APB 简单] --> B[AXI 复杂]
>     B --> C[I2C]
>     B --> D[SPI]
>     B --> E[UART]
>     
>     style A fill:#bae6fd,stroke:#0369a1,color:#0c4a6e
>     style B fill:#e9d5ff,stroke:#7c3aed,color:#6d28d9
>     style C fill:#fef3c7,stroke:#d97706,color:#92400e
>     style D fill:#dcfce7,stroke:#16a34a,color:#166534
>     style E fill:#fee2e2,stroke:#dc2626,color:#991b1b
> ```
> 
> **进度**: 5/5 完成

---

### 📂 知识分类

> [!note]- 📝 **SystemVerilog** - 硬件描述语言
> 
> | 文档 | 标签 | 更新时间 |
> |------|------|----------|
> | `=link("01-SV语法/00-入门")` | #SV #入门 | `=dv.pages("01-SV语法/00-入门").file.mtime` |
> | `=link("01-SV语法/01-数据类型")` | #SV #数据类型 | `=dv.pages("01-SV语法/01-数据类型").file.mtime` |
> | `=link("01-SV语法/02-类")` | #SV #OOP | `=dv.pages("01-SV语法/02-类").file.mtime` |
> 
> **总计**: 3 篇

> [!note]- 🔬 **UVM** - 验证方法学
> 
> | 文档 | 标签 | 更新时间 |
> |------|------|----------|
> | `=link("02-UVM/00-入门")` | #UVM #入门 | `=dv.pages("02-UVM/00-入门").file.mtime` |
> | `=link("02-UVM/01-Phase机制")` | #UVM #核心 | `=dv.pages("02-UVM/01-Phase机制").file.mtime` |
> | `=link("02-UVM/02-config_db")` | #UVM #核心 | `=dv.pages("02-UVM/02-config_db").file.mtime` |
> | `=link("02-UVM/03-Sequence机制")` | #UVM #核心 | `=dv.pages("02-UVM/03-Sequence机制").file.mtime` |
> | `=link("02-UVM/04-组件")` | #UVM #组件 | `=dv.pages("02-UVM/04-组件").file.mtime` |
> 
> **总计**: 5 篇

> [!note]- 🔌 **协议规范** - 总线接口
> 
> | 协议 | 文档 | 标签 |
> |------|------|------|
> | ⚡ AXI | `=link("03-Protocol/AXI/00-AXI")` | #Protocol #AXI |
> | 🔗 APB | `=link("03-Protocol/APB/00-APB")` | #Protocol #APB |
> | 📡 I2C | `=link("03-Protocol/I2C/00-I2C")` | #Protocol #I2C |
> | 🔄 SPI | `=link("03-Protocol/SPI/00-SPI")` | #Protocol #SPI |
> | 📨 UART | `=link("03-Protocol/UART/00-UART")` | #Protocol #UART |
> 
> **总计**: 5 种协议

> [!note]- 🔧 **工具链** - 开发环境
> 
> | 工具 | 文档 | 说明 |
> |------|------|------|
> | 🐧 Linux | `=link("04-Tools/Linux/00-常用命令")` | 常用命令 |
> | 📝 GVim | `=link("04-Tools/GVim/00-快捷键")` | 快捷键 |
> | 🖥️ xrun | `=link("04-Tools/xrun/00-xrun")` | Cadence 仿真器 |
> | 📊 imc | `=link("04-Tools/imc/00-imc")` | 覆盖率分析 |
> 
> **总计**: 4 种工具

> [!note]- ✅ **验证方法** - 实践指南
> 
> | 文档 | 标签 | 说明 |
> |------|------|------|
> | `=link("05-Verification/00-验证计划")` | #Verification #计划 | 验证计划编写 |
> | `=link("05-Verification/01-覆盖率")` | #Verification #Coverage | 覆盖率驱动验证 |
> | `=link("05-Verification/02-FMEA-FuSa")` | #Verification #Safety | 功能安全 |
> 
> **总计**: 3 篇

> [!note]- 🏗️ **环境搭建** - 配置指南
> 
> | 文档 | 标签 | 说明 |
> |------|------|------|
> | `=link("06-Environment/00-环境搭建")` | #Environment #Setup | 完整环境搭建 |
> 
> **总计**: 1 篇

> [!note]- 📜 **脚本工具** - 自动化
> 
> | 文档 | 标签 | 说明 |
> |------|------|------|
> | `=link("07-Scripts/00-Makefile")` | #Script #Makefile | Makefile 编写 |
> | `=link("07-Scripts/00-Python")` | #Script #Python | Python 脚本 |
> | `=link("07-Scripts/01-Log解析")` | #Script #Log | 日志分析 |
> 
> **总计**: 3 篇

> [!note]- 📚 **UVM 源码** - 深入研究
> 
> | 文档 | 标签 | 说明 |
> |------|------|------|
> | `=link("11-UVM源码学习/UVM源代码研究")` | #UVM #源码 | 源码研究 |
> | `=link("11-UVM源码学习/UVM-uvm中的factory机制")` | #UVM #Factory | 工厂机制 |
> | `=link("11-UVM源码学习/UVM-uvm_component与uvm_root")` | #UVM #Component | 组件层次 |
> | `=link("11-UVM源码学习/UVM-从run_test浅谈TestBench启动")` | #UVM #TestBench | 启动流程 |
> 
> **总计**: 4 篇

---

## 📈 最近更新

> [!tip] 📅 最近 7 天更新
> 
> ```dataview
> TABLE
>   file.folder AS "分类",
>   file.mtime AS "更新时间",
>   choice(contains(file.tags, "#核心"), "⭐", "") AS "重要"
> FROM ""
> WHERE file.mtime >= date(today) - dur(7 days) AND file.name != this.file.name
> SORT file.mtime DESC
> LIMIT 15
> ```

---

## 🏷️ 标签云

> [!abstract] 🏷️ 常用标签
> 
> | 标签 | 数量 | 说明 |
> |------|------|------|
> | `#UVM` | `=length(dv.pages("#UVM"))` | UVM 相关 |
> | `#SV` | `=length(dv.pages("#SV"))` | SystemVerilog |
> | `#Protocol` | `=length(dv.pages("#Protocol"))` | 协议规范 |
> | `#核心` | `=length(dv.pages("#核心"))` | 核心概念 |
> | `#入门` | `=length(dv.pages("#入门"))` | 入门教程 |
> | `#Verification` | `=length(dv.pages("#Verification"))` | 验证方法 |
> | `#Script` | `=length(dv.pages("#Script"))` | 脚本工具 |
> | `#Tool` | `=length(dv.pages("#Tool"))` | 工具使用 |

---

## ⏰ 待办事项

> [!todo] 📋 今日任务
> 
> ```tasks
> not done
> due on or before today
> short mode
> ```

> [!todo] 📅 本周任务
> 
> ```tasks
> not done
> due on or before {{date:YYYY-MM-DD}}+7
> short mode
> ```

---

## 📚 学习进度

> [!success] 🎯 学习目标追踪
> 
> | 目标 | 进度 | 状态 |
> |------|------|------|
> | SV 语法掌握 | 3/3 | ✅ 完成 |
> | UVM 核心机制 | 5/5 | ✅ 完成 |
> | 协议学习 | 5/5 | ✅ 完成 |
> | 工具掌握 | 4/4 | ✅ 完成 |
> | 验证方法 | 3/3 | ✅ 完成 |
> | UVM 源码研究 | 4/4 | ✅ 完成 |
> | 项目实战 | 0/3 | ⏳ 进行中 |
> | 问题总结 | 0/10 | ⏳ 进行中 |

---

## 🔍 快速搜索

> [!question] 🔎 常用搜索
> 
> | 搜索内容 | 搜索命令 |
> |----------|----------|
> | UVM 相关 | `tag:#UVM` |
> | SV 语法 | `tag:#SV` |
> | 协议文档 | `tag:#Protocol` |
> | 核心概念 | `tag:#核心` |
> | 最近更新 | `file.mtime >= date(today) - dur(7 days)` |
> | 待办任务 | `tag:#todo` |

---

## 📊 知识图谱

> [!note] 🕸️ 关系图谱
> 
> 点击下方按钮打开交互式关系图谱：
> 
> ```button
> name 打开关系图谱
> action command:graph:open
> color blue
> ```

---

## ⚙️ 快捷操作

> [!warning] 🛠️ 常用操作
> 
> | 操作 | 快捷键 | 说明 |
> |------|--------|------|
> | 快速切换 | `Ctrl+O` | 快速打开文件 |
> | 命令面板 | `Ctrl+P` | 执行命令 |
> | 全局搜索 | `Ctrl+Shift+F` | 搜索内容 |
> | 打开图谱 | `Ctrl+G` | 查看关系图谱 |
> | 刷新视图 | `Ctrl+R` | 刷新 Dataview |

---

## 📝 快速记录

> [!tip] ✍️ 快速创建
> 
> ```button
> name 新建笔记
> action templater-obsidian:Templater
> color green
> ```
> 
> ```button
> name 新建日记
> action daily-notes:打开/创建今天的日记
> color purple
> ```
> 
> ```button
> name 新建任务
> action obsidian-tasks-plugin:创建任务
> color orange
> ```

---

## 📚 推荐阅读

> [!info] 📖 精选文章
> 
> ```dataview
> TABLE
>   file.folder AS "分类",
>   file.tags AS "标签"
> FROM ""
> WHERE contains(file.tags, "#核心") OR contains(file.tags, "#重要")
> SORT file.mtime DESC
> LIMIT 5
> ```

---

## 🎓 学习资源

> [!abstract] 🔗 外部资源
> 
> | 资源 | 链接 | 说明 |
> |------|------|------|
> | UVM 官方文档 | [Accellera](https://www.accellera.org/) | UVM 标准 |
> | SystemVerilog | [IEEE 1800](https://standards.ieee.org/ieee/1800/7386/) | SV 标准 |
> | Verification Academy | [VerificationAcademy](https://www.verificationacademy.com/) | 学习平台 |
> | ChipVerify | [ChipVerify](https://www.chipverify.com/) | 验证教程 |

---

*最后更新: `=dateformat(date(now), "yyyy-MM-dd HH:mm")`*