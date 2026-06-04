---
tags: [Tools, Claude, AI, 知识库, Skill]
created: 2026-05-21
updated: 2026-06-02
---

# Claude Code 知识库 Skill

> 用自然语言把对话内容存入 Obsidian 知识库

tags: #Tool #Claude #知识库

---

## 触发方式

在 Claude Code 对话中说以下任意关键词即可触发：

| 触发词 | 示例 |
|--------|------|
| 写进知识库 | "把这个总结写进知识库" |
| 放进知识库 | "把 AXI burst 传输的分析放进知识库" |
| 记录到知识库 | "刚才讨论的内容记录到知识库" |
| save to knowledge base | "save this to knowledge base" |
| add to obsidian | "add the latch explanation to obsidian" |

---

## 使用场景

### 1. 保存对话中的技术总结

```
你: 寄存器和锁存器的区别是什么？
Claude: [详细回答]
你: 把这个写进知识库
→ 自动创建 01-SV语法/03-寄存器与锁存器.md
```

### 2. 保存代码分析

```
你: 这个 Perl 回归脚本给我讲清楚
Claude: [逐段分析]
你: 放进知识库
→ 自动创建 07-Scripts/02-Perl回归脚本.md
```

### 3. 指定目录保存

```
你: 把 SPI 协议的时序分析写进知识库的 Protocol 目录
→ 自动创建 03-Protocol/SPI/01-SPI时序分析.md
```

### 4. 更新已有笔记

```
你: 把今天讨论的 config_db 用法补充到知识库里 UVM 的 config_db 笔记
→ 读取 02-UVM/02-config_db.md，在合适位置追加内容
```

### 5. 查询知识库

```
你: 知识库里有没有关于 clock gating 的笔记？
→ 搜索相关目录，返回结果
```

---

## 自动分类规则

Skill 会根据内容主题自动选择目录：

| 主题 | 目标目录 |
|------|---------|
| SV 语法、数据类型、编码 | `01-SV语法/` |
| UVM（phase、config_db、sequence） | `02-UVM/` |
| 通信协议（SPI/AXI/APB/I2C/UART） | `03-Protocol/<协议名>/` |
| EDA 工具（xrun/imc/GVim/Linux） | `04-Tools/<工具名>/` |
| 验证方法、覆盖率、FMEA | `05-Verification/` |
| 脚本（Perl/Python/Makefile） | `07-Scripts/` |
| 杂项、不确定分类 | `10-Notes/` |

---

## 文件格式

自动生成的文件遵循以下模板：

```markdown
# 标题

> 一句话概括

tags: #Tag1 #Tag2

---

## 正文内容

（代码块、表格、callout 等）

---

*创建时间: YYYY-MM-DD*
```

---

## Skill 文件位置

```
/home/muyuzhang/.claude/skills/obsidian-kb/SKILL.md
```

如需修改触发词或分类规则，编辑此文件即可。

---

*创建时间: 2026-05-22*
