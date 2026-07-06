---
tags: [UVM, 源码, 核心, 设计模式]
created: 2026-04-27
updated: 2026-06-02
---

# 09-factory机制（uvm-1.2版）

## 摘要

本文深入分析UVM中的factory机制，基于UVM-1.2版本源码。Factory机制是UVM最核心的机制之一，它是经典软件开发中工厂设计模式的实现。

> 来源：[IC验证者之家 - 08-源代码研究专辑](https://mp.weixin.qq.com/mp/appmsgalbum?action=getalbum&album_id=4331728764897247235)
> 作者：青松立雪

---

## 概述

> ⚠️ 由于微信公众号访问限制，本文完整内容暂时无法获取。请通过原文链接访问完整版本。

---

## Factory机制简介

UVM factory是**经典软件开发中工厂设计模式(factory design pattern)的实现**，该模式用于创建通用代码，从而在运行时(run-time)确定对象的确切子类型。

### 核心优势

1. **运行时多态** - 可以在仿真运行时决定创建哪个具体的类
2. **灵活替换** - 无需修改代码即可替换已创建的组件
3. **组件注册** - 通过宏自动注册到factory进行管理

---

## 快速入门示例

```verilog
// 1. 定义可重用的类
class state extends uvm_component;
    `uvm_component_utils(state)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass

// 2. 创建子类
class florida extends state;
    `uvm_component_utils(florida)
    // ...
endclass

// 3. 在创建对象之前，使用类型替换
factory.set_type_override_by_type(state::get_type(), 
                                   florida::get_type());

// 4. 通过factory创建对象
state my_state = state::type_id::create("my_state", null);
```

---

## 使用宏进行注册

UVM提供了两个重要的宏用于factory注册：

### `uvm_component_utils

```verilog
`uvm_component_utils(T)
```
- 用于从`uvm_component`派生的类
- 构造函数需要两个参数：`name`和`parent`

### `uvm_object_utils

```verilog
`uvm_object_utils(T)
```
- 用于从`uvm_object`派生的类
- 构造函数只需要一个参数：`name`

---

## 相关链接

- [[11-run_test与TestBench启动]]
- [[10-uvm_component与uvm_root]]
- [[01-Log解析]]

---

*创建时间: 2026-04-27*
*备注: 完整内容待补充*

