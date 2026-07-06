---
aliases: [索引, Index, 目录]
tags: [索引]
---

# 知识库索引

> [!abstract] 快速定位
> 本索引使用 **Dataview** 自动生成，添加新文件后按 `Ctrl+R` 刷新即可更新。

---

## 内容总览

### 目录结构

```dataview
TABLE
length(file.children) as "文件数",
choice(length(file.children) > 0, "📁 文件夹", "📄 单文件") as "类型"
FROM "00-索引"
WHERE file.name != "00-总索引" AND file.name != "00-总索引-新"
SORT file.name
```

**总计**: ``=`length(list("01-SV语法", "02-UVM", "03-Protocol", "04-Tools", "05-Verification", "06-Environment", "07-Scripts", "10-Notes", "11-UVM源码学习"))` `` 个分类

### 文件统计

```dataview
TABLE length(rows) as "文件数"
FROM ""
WHERE file.extension = "md"
GROUP BY file.folder
SORT file.folder
```

---

## 核心文档

> [!tip] 必读文档
> 以下文档是整个知识体系的核心，建议优先掌握。

### 基础入门

| 文档 | 标签 | 说明 |
|------|------|------|
| [[00-入门]] | #SV #入门 | SystemVerilog 基础入门 |
| [[00-入门]] | #UVM #入门 | UVM 验证方法学入门 |
| [[00-环境搭建]] | #UVM #实践 | 完整验证环境搭建 |

### 核心机制

| 文档 | 标签 | 说明 |
|------|------|------|
| [[01-Phase机制]] | #UVM #核心 | Phase 执行顺序与机制 |
| [[02-config_db]] | #UVM #核心 | 配置传递机制 |
| [[03-Sequence机制]] | #UVM #核心 | Sequence 机制与使用 |

### 协议规范

| 文档 | 标签 | 说明 |
|------|------|------|
| [[00-AXI]] | #Protocol #AXI #核心 | AXI 总线协议详解 |
| [[00-APB]] | #Protocol #APB | APB 总线协议 |
| [[00-I2C]] | #Protocol #I2C | I2C 总线协议 |

### 重要概念

| 文档 | 标签 | 说明 |
|------|------|------|
| [[时隙-TimeSlot]] | #时序 #FIFO #核心 | 时隙原理与异步 FIFO |
| [[数字寄存器]] | #寄存器 #核心 | 寄存器字段命名规范 |
| [[01-覆盖率]] | #Verification #Coverage | 覆盖率驱动验证 |

---

## 按标签索引

### #UVM

```dataview
LIST
FROM "02-UVM"
SORT file.name
```

### #SV

```dataview
LIST
FROM "01-SV语法"
SORT file.name
```

### #Protocol

```dataview
LIST
FROM "03-Protocol"
SORT file.name
```

### #Tools

```dataview
LIST
FROM "04-Tools"
SORT file.name
```

### #Verification

```dataview
LIST
FROM "05-Verification"
SORT file.name
```

### #Scripts

```dataview
LIST
FROM "07-Scripts"
SORT file.name
```

### #UVM源码学习

```dataview
LIST
FROM "11-UVM源码学习"
SORT file.name
```

### #Notes

```dataview
LIST
FROM "10-Notes"
SORT file.name
```

---

## 目录树

```
knowledge-base/
├── 00-索引/          # 本文档
├── 01-SV语法/        # SystemVerilog 语法与特性
│   ├── 00-入门.md
│   ├── 01-数据类型.md
│   └── 02-类.md
├── 02-UVM/           # UVM 验证方法学
│   ├── 00-入门.md
│   ├── 01-Phase机制.md
│   ├── 02-config_db.md
│   ├── 03-Sequence机制.md
│   └── 04-组件.md
├── 03-Protocol/      # 协议规范
│   ├── AXI/
│   ├── APB/
│   ├── I2C/
│   ├── SPI/
│   └── UART/
├── 04-Tools/         # 工具指令
│   ├── Linux/
│   ├── GVim/
│   ├── xrun/         # Cadence 仿真器
│   └── imc/          # 覆盖率分析
├── 05-Verification/   # 验证方法学
│   ├── 00-验证计划.md
│   ├── 01-覆盖率.md
│   └── 02-FMEA-FuSa.md
├── 06-Environment/   # 环境搭建
│   └── 00-环境搭建.md
├── 07-Scripts/       # 脚本
│   ├── 00-Makefile.md
│   ├── 00-Python.md
│   └── 01-Log解析.md
├── 08-Projects/      # 项目（待填充）
├── 09-Issues/        # 问题（待填充）
├── 10-Notes/         # 笔记
│   ├── 时隙-TimeSlot.md
│   └── 数字寄存器.md
└── 11-UVM源码学习/   # UVM 源码深入研究
    ├── UVM-从run_test浅谈TestBench启动.md
    ├── UVM-uvm_component与uvm_root.md
    ├── UVM-uvm中的factory机制.md
    └── UVM源代码研究.md
```

---

## 学习路径

> [!example] UVM 学习路径
> ```
> SV 入门 → UVM 入门 → Phase 机制 → config_db → Sequence → 环境搭建 → UVM 源码深入研究
> ```

> [!example] 协议学习路径
> ```
> APB（简单）→ AXI（复杂）→ I2C / SPI / UART（外设）
> ```

> [!example] 工具掌握
> ```
> Linux 基础 → GVim → Python 脚本 → Makefile
> ```

> [!example] 验证方法学
> ```
> 验证计划 → 覆盖率 → FMEA/FuSa → 环境搭建
> ```

---

## 脚本工具

| 脚本 | 功能 | 使用方法 |
|------|------|----------|
| `auto-classify.ps1` | 自动分类与标签 | `.\auto-classify.ps1 -AutoTag` |
| `random-review.ps1` | 随机复习 | `.\random-review.ps1 -Count 5` |
| `search-knowledgebase.ps1` | 搜索知识库 | `.\search-knowledgebase.ps1 -Query "关键词"` |
| `sync-onedrive.ps1` | 同步到OneDrive | `.\sync-onedrive.ps1 -Action sync` |

---

*最后更新: `=dateformat(date(now), "yyyy-MM-dd")`*