---
aliases: [索引, Index, 目录, 总目录]
tags: [索引, 核心]
created: 2026-04-01
updated: 2026-05-13
---

# 📑 数字验证工程师知识库索引

> [!abstract] 📖 快速定位
> [[00-工作台/00-主页|🏠 工作台]] · [[00-工作台/01-今日任务|📋 今日任务]] · [[00-工作台/02-学习进度|📈 学习进度]] · 按 `Ctrl+R` 刷新 Dataview

---

## 📊 内容总览

### 📈 统计概览

| 指标 | 数值 | 说明 |
|------|------|------|
| 📝 总笔记数 | `=length(link("").file.inlinks)` | Markdown 文件总数（近似） |
| 📁 分类数 | 11 | 一级文件夹数量 |
| 🏷️ 标签数 | 42+ | 不重复标签数 |

### 📂 目录结构

```dataview
TABLE
  length(file.children) as "文件数",
  choice(length(file.children) > 0, "📁 文件夹", "📄 单文件") as "类型"
FROM "00-索引"
WHERE file.name != "00-总索引" AND file.name != "00-总索引-新"
SORT file.name
```

---

## 🎯 核心文档

> [!tip] ⭐ 必读文档

### 📝 基础入门
- `=link("01-SV语法/00-入门")` — #SV #入门
- `=link("02-UVM/00-入门")` — #UVM #入门
- `=link("06-Environment/00-环境搭建")` — #UVM #实践

### 🔬 核心机制
- `=link("02-UVM/01-Phase机制")` — #UVM #核心
- `=link("02-UVM/02-config_db")` — #UVM #核心
- `=link("02-UVM/03-Sequence机制")` — #UVM #核心

### 🔌 协议规范
- `=link("03-Protocol/AXI/00-AXI")` — #Protocol #AXI #核心
- `=link("03-Protocol/APB/00-APB")` — #Protocol #APB
- `=link("03-Protocol/I2C/00-I2C")` — #Protocol #I2C

### 💡 重要概念
- `=link("10-Notes/时隙-TimeSlot")` — #时序 #FIFO #核心
- `=link("10-Notes/数字寄存器")` — #寄存器 #核心
- `=link("05-Verification/01-覆盖率")` — #Verification #Coverage

---

## 🏷️ 按标签索引

### #UVM - 验证方法学

```dataview
TABLE file.folder AS "分类"
FROM "02-UVM" OR "11-UVM源码学习"
SORT file.name
```

### #SV - SystemVerilog

```dataview
TABLE file.folder AS "分类"
FROM "01-SV语法"
SORT file.name
```

### #Protocol - 协议规范

```dataview
TABLE file.folder AS "分类"
FROM "03-Protocol"
SORT file.name
```

### #Verification - 验证方法

```dataview
TABLE file.folder AS "分类"
FROM "05-Verification"
SORT file.name
```

### #Tool - 工具使用

```dataview
TABLE file.folder AS "分类"
FROM "04-Tools"
SORT file.name
```

### #Script - 脚本工具

```dataview
TABLE file.folder AS "分类"
FROM "07-Scripts"
SORT file.name
```

---

## 📁 按目录索引

### 📝 01-SV语法

```dataview
TABLE file.tags AS "标签"
FROM "01-SV语法"
SORT file.name
```

### 🔬 02-UVM

```dataview
TABLE file.tags AS "标签"
FROM "02-UVM"
SORT file.name
```

### 🔌 03-Protocol

```dataview
TABLE file.tags AS "标签"
FROM "03-Protocol"
SORT file.name
```

### 🔧 04-Tools

```dataview
TABLE file.tags AS "标签"
FROM "04-Tools"
SORT file.name
```

### ✅ 05-Verification

```dataview
TABLE file.tags AS "标签"
FROM "05-Verification"
SORT file.name
```

### 🏗️ 06-Environment

```dataview
TABLE file.tags AS "标签"
FROM "06-Environment"
SORT file.name
```

### 📜 07-Scripts

```dataview
TABLE file.tags AS "标签"
FROM "07-Scripts"
SORT file.name
```

### 📒 10-Notes

```dataview
TABLE file.tags AS "标签"
FROM "10-Notes"
SORT file.name
```

### 📚 11-UVM源码学习

```dataview
TABLE file.tags AS "标签"
FROM "11-UVM源码学习"
SORT file.name
```

---

## 📂 目录树

```
knowledge-base/
├── 00-工作台/        🏠 工作台与仪表盘
├── 00-索引/          📑 索引目录
├── 01-SV语法/        💎 SystemVerilog 语法与特性
│   ├── 00-入门.md
│   ├── 01-数据类型.md
│   └── 02-类.md
├── 02-UVM/           🔬 UVM 验证方法学
│   ├── 00-入门.md
│   ├── 01-Phase机制.md
│   ├── 02-config_db.md
│   ├── 03-Sequence机制.md
│   └── 04-组件.md
├── 03-Protocol/      🔌 协议规范
│   ├── AXI/         ⚡ AXI 总线
│   ├── APB/         🔗 APB 总线
│   ├── I2C/         📡 I2C 总线
│   ├── SPI/         🔄 SPI 总线
│   └── UART/        📨 UART 总线
├── 04-Tools/         🔧 工具指令
│   ├── Linux/       🐧 Linux 命令
│   ├── GVim/        📝 GVim 编辑器
│   ├── xrun/        🖥️ Cadence 仿真器
│   └── imc/         📊 覆盖率分析
├── 05-Verification/  ✅ 验证方法学
│   ├── 00-验证计划.md
│   ├── 01-覆盖率.md
│   └── 02-FMEA-FuSa.md
├── 06-Environment/   🏗️ 环境搭建
│   └── 00-环境搭建.md
├── 07-Scripts/       📜 脚本
│   ├── 00-Makefile.md
│   ├── 00-Python.md
│   └── 01-Log解析.md
├── 08-Projects/      🚀 项目
├── 09-Issues/        ⚠️ 问题
├── 10-Notes/         📒 笔记
│   ├── 时隙-TimeSlot.md
│   └── 数字寄存器.md
├── 11-UVM源码学习/   📚 UVM 源码深入研究
│   ├── UVM-从run_test浅谈TestBench启动.md
│   ├── UVM-uvm_component与uvm_root.md
│   ├── UVM-uvm中的factory机制.md
│   └── UVM源代码研究.md
├── 12-Life/          🏠 生活管理
│   ├── 01-日常规划/ 📋 每日计划
│   ├── 02-账本/     💰 收支管理
│   ├── 03-健康/     💪 健康追踪
│   ├── 04-阅读/     📖 阅读清单
│   └── 05-目标/     🎯 目标管理
└── 13-Archive/       🗄️ 归档
```

---

## 📈 学习路径

> [!example] 🔬 UVM 学习路径
> 1. `=link("01-SV语法/00-入门")` - SV 基础入门
> 2. `=link("02-UVM/00-入门")` - UVM 基础入门
> 3. `=link("02-UVM/01-Phase机制")` - Phase 机制
> 4. `=link("02-UVM/02-config_db")` - config_db 机制
> 5. `=link("02-UVM/03-Sequence机制")` - Sequence 机制
> 6. `=link("06-Environment/00-环境搭建")` - 环境搭建
> 7. `=link("11-UVM源码学习/UVM源代码研究")` - UVM 源码研究

> [!example] 🔌 协议学习路径
> 8. `=link("03-Protocol/APB/00-APB")` - APB（简单）
> 9. `=link("03-Protocol/AXI/00-AXI")` - AXI（复杂）
> 10. `=link("03-Protocol/I2C/00-I2C")` - I2C（外设）
> 11. `=link("03-Protocol/SPI/00-SPI")` - SPI（外设）
> 12. `=link("03-Protocol/UART/00-UART")` - UART（外设）

> [!example] 🔧 工具掌握
> 13. `=link("04-Tools/Linux/00-常用命令")` - Linux 基础
> 14. `=link("04-Tools/GVim/00-快捷键")` - GVim 编辑器
> 15. `=link("07-Scripts/00-Python")` - Python 脚本
> 16. `=link("07-Scripts/00-Makefile")` - Makefile 构建

> [!example] ✅ 验证方法学
> 17. `=link("05-Verification/00-验证计划")` - 验证计划
> 18. `=link("05-Verification/01-覆盖率")` - 覆盖率
> 19. `=link("05-Verification/02-FMEA-FuSa")` - FMEA/FuSa
> 20. `=link("06-Environment/00-环境搭建")` - 环境搭建

---

## 📊 更新记录

> [!info] 📅 最近更新
> ```dataview
> TABLE
>   file.folder AS "分类",
>   file.mtime AS "更新时间"
> FROM ""
> WHERE file.name != this.file.name
> SORT file.mtime DESC
> LIMIT 10
> ```

---

*最后更新: `=dateformat(date(now), "yyyy-MM-dd HH:mm")`*