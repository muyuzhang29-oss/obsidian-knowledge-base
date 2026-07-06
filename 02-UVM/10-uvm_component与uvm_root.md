---
tags: [UVM, 源码, 核心]
created: 2026-04-27
updated: 2026-06-02
---

# 10-uvm_component与uvm_root（uvm-1.2版）

## 摘要

本文深入分析uvm_component与uvm_root的关系，基于UVM-1.2版本源码。

> 来源：[IC验证者之家 - 08-源代码研究专辑](https://mp.weixin.qq.com/mp/appmsgalbum?action=getalbum&album_id=4331728764897247235)
> 作者：青松立雪

---

## 概述

> ⚠️ 由于微信公众号访问限制，本文完整内容暂时无法获取。请通过原文链接访问完整版本。

---

## uvm_root类简介

`uvm_root`是UVM验证环境的根节点，是一个单例模式(singleton)的类。它继承自`uvm_component`，是所有UVM组件的最终祖先。

### 主要职责

1. **作为仿真起点** - run_test()函数实际上调用的是uvm_root的方法
2. **管理顶层组件** - 维护uvm_test_top的引用
3. **提供全���服务** - 如factory、configuration database等

### 关键方法

```verilog
// uvm-1.2中的关键方法
task run_test(string test_name="");
```

---

## uvm_component层级结构

```
uvm_void
  └── uvm_object
        └── uvm_report_object
              └── uvm_component
                    ├── uvm_test (测试用例基类)
                    ├── uvm_env (验证环境基类)
                    ├── uvm_agent (代理基类)
                    ├── uvm_scoreboard (计分板基类)
                    └── uvm_subscriber (订阅者基类)
```

---

## 相关链接

- [[11-run_test与TestBench启动]]
- [[09-factory机制]]
- [[01-Log解析]]

---

*创建时间: 2026-04-27*
*备注: 完整内容待补充*

