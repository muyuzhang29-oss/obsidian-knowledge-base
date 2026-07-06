---
tags: [UVM, 源码, 仿真, 核心]
created: 2026-04-27
updated: 2026-06-02
---

# UVM-从run_test浅谈Test Bench的启动

## 摘要

本文从run_test()函数出发，深入分析UVM Test Bench的启动机制，探讨SystemVerilog与Verilog之间的协作方式。

> 来源：[IC验证者之家 - 从run_test浅谈Test Bench的启动](https://mp.weixin.qq.com/s/Bab0j1feGeIy0TvMky5Ccg)
> 作者：青松立雪

---

## 1. 典型UVM测试架构的误区

*UVM user guide 1.2* 1.1节中有一幅典型的UVM测试架构图，但这幅图有些地方是错误的：

1. **Test Bench是一个module**，不是UVM的任何分支或组件
2. **Test Bench所对应的tb_top+RTL文件和UVM验证平台**对应的平台组件+Test文件是并列进行编译的，两者各自内部存在实例化关系，但两者之间并不存在实例化关系
3. 从实例化的结构上讲，**只有DUT是被包含在Test Bench之中**的，而sequencer, reference model, checker, agent等组件是被实例化在env中，env是被实例化在test中的

---

## 2. UVM平台架构

SystemVerilog定义的class，由class组成了UVM的各个组件，又由这些组件组成了UVM验证平台：

```
uvm_test_top/uvm_test (最外层)
  └── env/uvm_env
        ├── virtual sequencer
        ├── reference model
        ├── checker
        ├── configure_file
        └── agents
              ├── driver
              ├── sequencer
              └── monitor
```

**重要说明：**
- **Sequence不能算是env的内部组件**，而是独立在env之外，实例化在uvm_test之内的一个组件(object)
- 这样设计降低了Sequence与env平台的耦合性，提高了sequence的重用性
- Factory和CFG_DB也是独立在uvm_env之外的结构

---

## 3. 仿真组件的拓扑结构

由Verilog定义的module (harness/tb_top_module) 与由SystemVerilog定义的class (uvm_test_top/uvm_test) 是分开的，彼此相对独立的。在仿真系统中，这两者都是实例化在$root下面。

### 关键特性

在test, env，甚至env的各个下属组件中，可以直接"看到" tb_top_module和其下面的DUT_top，即可以直接访问TB顶层和DUT及内部信号。

### SV与Verilog之间的联系

既然uvm_test_top和tb_top_module是两个平行的分支，那么从tb_top_module这边也应该可以"看到" uvm_test_top那边分支中定义的参数和函数：
- 可以在initial begin...end内直接调用uvm_root类中定义的run_test()任务
- 可以使用cfg_db::set/get函数
- 可以直接实例化UVM组件

---

## 4. UVM验证平台架构图

我心中的UVM验证平台架构：

| 右边 (Verilog) | 左边 (SystemVerilog) |
|----------------|---------------------|
| tb_top_module | uvm_test_top |
| DUT_top | env/agents |
| Interface | Driver/Monitor |
| | Sequence |

### 两条联系路径

#### 第一条路：config_db::set()和get()
这条路主要是传输virtual interface：
- Interface是中介，一边连着DUT的接口信号，另一边与agent里面的driver和monitor相联
- 激励从Driver输入到interface，再输入到DUT_top接口
- DUT_top的输出信号输出到interface，再输出到Driver和Monitor

#### 第二条路：run_test()
这条路主要是从tb_top_module发起的对UVM平台的各个组件的启动控制：
- 通过启动各个组件，实现对UVM平台的启动
- 启动之后，UVM平台自主运行
- UVM平台自己决定什么时候关闭UVM平台

---

## 5. run_test()函数分析

按照Verilog的语法，所有的`initial begin...end`过程模块在仿真的一开始同时立即开始执行，且只执行一次。被initial过程模块包起来的run_test()就在仿真开始的时候，会被调用执行一次。

### run_test()主要干了两件事：

#### 第一：统一test_name
把传进来的test_name统一替换为uvm_test_top。这个test_name可以是：
- 调用run_test函数的时候传进来的字符串
- 在Makefile中用`+UVM_TESTNAME=$(tc)`传进来的test case name

#### 第二：启动phase
启动uvm_test_top和其内部实例化的全部component的phase：
- 由fork join_none可知启动过程和执行各个phase是放在后台运行的
- 然后等待uvm_test_top和其内部实例化的全部component的phase执行完成
- 之后调用$finish()结束仿真

### UVM Phase的启动源码

```
图6：UVM Phase的启动源码
在图6中，506行代码，#0; 注释是启动phase。
```

---

## 6. EDA仿真到底是什么？

**我的理解：** 仿真实际上是SystemVerilog(SV)把无数的与仿真相关的事件（events），例如：
- 产生报文
- 发送报文
- 驱动信号
- 采样数据
- 比对信息
- 打印信息

把这些events与漫长的仿真周期关联起来，为各个events分配相应的仿真时间，在不同的仿真时间执行不同的events。

### 时间槽概念

SV需要把仿真周期分段，然后把events分配到各个时间段上：
- Events是动态的，不断产生的
- 仿真周期是动态的，不断延长的
- 时间段也是不断增加的

SV把分配到一个时间段内的全部events和该时间段，整体称为一个**时间槽(a time slot)**。一个时间槽被SV细化了18个小的Region，详见IEEE Standard for SystemVerilog 章节4.4.1和4.4.2。

### SV的simulation reference algorithm

SV的仿真过程就是从当前的时间槽移动到下一个时间槽的过程。

### #0;的作用

节选自IEEE Standard for SystemVerilog：**#0;可以让当前的仿真强行进入到time slot 0**，把仿真的events都放置到仿真的第一个时间小段，即time slot 0。仿真就此开始。

---

## 7. run_test()的高级用法

通过run_test()不仅仅可以启动uvm_test和下面的各个components，也可以只启动UVM平台的某一个组件。

### 应用场景

在交付一个项目时，开发了一个function coverage model：
- 要挂在SoC的Test Bench上
- 把该model做成了一个component（extends 自uvm_monitor）
- TestBench不是基于UVM的，没有env组件

### 解决方案

1. 创建一个env class，在其中实例化function coverage model文件
2. 在TB_top中用`run_test(env);`实现启动env和其下面的实例化的function coverage model文件

### 进一步优化

也可以直接通过`run_test(function_coverage_model);`来直接启动该模型。

---

## 8. 总结

UVM平台中所有component的各个phase，通过raise_objection和drop_objection机制实现全部component之间的运行时间的同步。再结合UVM phase本身的运行顺序，实现了整个仿真平台全部组件（test, env, reference model, checker, sequencer, agents等全部components）的启动和运行。

---

## 相关链接

- [[10-uvm_component与uvm_root]]
- [[09-factory机制]]
- [[01-Log解析]] - UVM日志相关

---

*创建时间: 2026-04-27*

