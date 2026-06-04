---
tags:
  - UVM
  - Verification
  - TLM
  - 通信
  - 核心
---

# TLM通信机制

## 1. TLM概述

TLM（Transaction Level Modeling，事务级建模）是UVM中组件间通信的核心机制。它提供了一套标准化的接口，使得验证组件能够以事务（transaction）为单位进行数据交换，而无需关心底层实现细节。

### 核心思想

- **解耦**：生产者和消费者通过接口通信，彼此独立
- **标准化**：统一的端口类型和接口协议
- **可复用**：组件可在不同环境中复用，只要接口匹配

### TLM通信三要素

| 要素 | 说明 |
|------|------|
| **Port（端口）** | 发起通信请求的一方 |
| **Export（导出端口）** | 中间传递层 |
| **Imp（实现端口）** | 实际实现通信方法的一方 |

## 2. 端口类型

### 2.1 Port（端口）

Port是通信的发起方，定义了组件对外提供的接口。

```systemverilog
// 定义port
class my_driver extends uvm_driver #(my_transaction);
  `uvm_component_utils(my_driver)

  // 申明一个put类型的port
  uvm_put_port #(my_transaction) put_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    put_port = new("put_port", this);
  endfunction

  task run_phase(uvm_phase phase);
    my_transaction tr;
    // 通过port发送事务
    put_port.put(tr);
  endtask
endclass
```

### 2.2 Export（导出端口）

Export是中间层，用于连接port和imp，实现多级连接。

```systemverilog
class my_agent extends uvm_agent;
  `uvm_component_utils(my_agent)

  // Agent的export，暴露给外部
  uvm_put_export #(my_transaction) put_export;

  // 内部driver的port
  my_driver drv;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    put_export = new("put_export", this);
    drv = my_driver::type_id::create("drv", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // 将export连接到driver的port
    put_export.connect(drv.put_port);
  endfunction
endclass
```

### 2.3 Imp（实现端口）

Imp是实际实现通信方法的地方，必须实现对应的接口方法。

```systemverilog
class my_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(my_scoreboard)

  // 实现put接口
  uvm_put_imp #(my_transaction, my_scoreboard) put_imp;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    put_imp = new("put_imp", this);
  endfunction

  // 必须实现put方法
  task put(my_transaction t);
    `uvm_info("SCB", $sformatf("Received: %s", t.convert2string()), UVM_MEDIUM)
    // 比较逻辑
  endtask
endclass
```

### 2.4 端口连接规则

```
Port ──→ Export ──→ Imp
（发起方）  （中间层）  （实现方）
```

连接代码在`connect_phase`中完成：

```systemverilog
class my_env extends uvm_env;
  `uvm_component_utils(my_env)

  my_agent agent;
  my_scoreboard scb;

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Port -> Export -> Imp 的完整连接
    agent.put_export.connect(scb.put_imp);
  endfunction
endclass
```

## 3. 接口类型

### 3.1 Put接口

单向数据传输，从port端推送到imp端。

```systemverilog
// put接口 - 阻塞式
task put(T t);          // 发送事务，阻塞直到完成

// try_put - 非阻塞式
function bit try_put(T t);  // 尝试发送，立即返回成功/失败

// can_put - 检查是否可以put
function bit can_put();     // 检查是否可发送
```

**使用示例：**

```systemverilog
// Driver端
task run_phase(uvm_phase phase);
  forever begin
    seq_item_port.get_next_item(req);
    // 推送到scoreboard
    put_port.put(req);
    seq_item_port.item_done();
  end
endtask

// Scoreboard端
task put(my_transaction t);
  // 处理接收到的事务
  compare_queue.push_back(t);
endtask
```

### 3.2 Get接口

单向数据获取，从imp端拉取数据到port端。

```systemverilog
// get接口 - 阻塞式
task get(output T t);       // 获取事务，阻塞直到有数据

// try_get - 非阻塞式
function bit try_get(output T t);  // 尝试获取

// can_get - 检查是否可以get
function bit can_get();            // 检查是否可获取
```

**使用示例：**

```systemverilog
// Monitor端（提供数据）
class my_monitor extends uvm_monitor;
  uvm_blocking_get_imp #(my_transaction, my_monitor) get_imp;

  task get(output my_transaction t);
    // 等待采集到数据
    @(posedge vif.valid);
    t = my_transaction::type_id::create("t");
    t.data = vif.data;
  endtask
endclass

// Scoreboard端（获取数据）
class my_scoreboard extends uvm_scoreboard;
  uvm_blocking_get_port #(my_transaction) get_port;

  task run_phase(uvm_phase phase);
    my_transaction tr;
    forever begin
      get_port.get(tr);
      // 处理事务
    end
  endtask
endclass
```

### 3.3 Peek接口

类似Get，但不移除数据（窥探）。

```systemverilog
// peek接口 - 阻塞式
task peek(output T t);       // 窥探数据但不消费

// try_peek - 非阻塞式
function bit try_peek(output T t);

// can_peek - 检查是否可以peek
function bit can_peek();
```

### 3.4 Transport接口

双向通信，包含请求和响应。

```systemverilog
// transport接口 - 阻塞式
task transport(input T req, output T rsp);  // 请求-响应

// nb_transport - 非阻塞式
function bit nb_transport(input T req, output T rsp);
```

**使用示例：**

```systemverilog
// Driver端发起transport请求
task run_phase(uvm_phase phase);
  my_transaction req, rsp;
  forever begin
    seq_item_port.get_next_item(req);
    // 发送请求并接收响应
    transport_port.transport(req, rsp);
    // 处理响应
    `uvm_info("DRV", $sformatf("Got response: %h", rsp.data), UVM_MEDIUM)
    seq_item_port.item_done();
  end
endtask

// Sequencer端实现transport
task transport(input my_transaction req, output my_transaction rsp);
  // 处理请求，生成响应
  rsp = my_transaction::type_id::create("rsp");
  rsp.data = req.data + 1;
endtask
```

### 3.5 接口类型汇总

| 接口类型 | 方向 | 阻塞版本 | 非阻塞版本 | 检查版本 |
|---------|------|---------|-----------|---------|
| **Put** | Port → Imp | `put()` | `try_put()` | `can_put()` |
| **Get** | Imp → Port | `get()` | `try_get()` | `can_get()` |
| **Peek** | Imp → Port | `peek()` | `try_peek()` | `can_peek()` |
| **Transport** | 双向 | `transport()` | `nb_transport()` | - |

## 4. Analysis Port

Analysis Port是一种特殊的广播端口，支持一对多通信，常用于覆盖率收集和结果检查。

### 4.1 基本用法

```systemverilog
// Monitor端 - 使用analysis port广播
class my_monitor extends uvm_monitor;
  `uvm_component_utils(my_monitor)

  // Analysis port声明
  uvm_analysis_port #(my_transaction) ap;

  virtual my_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
  endfunction

  task run_phase(uvm_phase phase);
    my_transaction tr;
    forever begin
      @(posedge vif.clk);
      if (vif.valid) begin
        tr = my_transaction::type_id::create("tr");
        tr.data = vif.data;
        // 通过analysis port广播事务
        ap.write(tr);
      end
    end
  endtask
endclass
```

### 4.2 多端口连接

```systemverilog
// Scoreboard端 - 实现write方法
class my_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(my_scoreboard)

  // Analysis imp声明（注意：需要指定实现类）
  uvm_analysis_imp #(my_transaction, my_scoreboard) ap_imp;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap_imp = new("ap_imp", this);
  endfunction

  // 实现write方法
  function void write(my_transaction t);
    `uvm_info("SCB", $sformatf("Received: %h", t.data), UVM_MEDIUM)
    // 比较逻辑
  endfunction
endclass

// Coverage collector - 另一个analysis port的实现
class my_coverage extends uvm_subscriber #(my_transaction);
  `uvm_component_utils(my_coverage)

  covergroup my_cg;
    coverpoint data;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    my_cg = new();
  endfunction

  function void write(my_transaction t);
    my_cg.sample();
  endfunction
endclass
```

### 4.3 在Env中连接

```systemverilog
class my_env extends uvm_env;
  `uvm_component_utils(my_env)

  my_agent agent;
  my_scoreboard scb;
  my_coverage cov;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = my_agent::type_id::create("agent", this);
    scb = my_scoreboard::type_id::create("scb", this);
    cov = my_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // 一个analysis port可以连接多个imp
    agent.monitor.ap.connect(scb.ap_imp);
    agent.monitor.ap.connect(cov.analysis_export);
  endfunction
endclass
```

## 5. TLM FIFO

TLM FIFO提供了带缓冲的数据传输通道，解耦生产者和消费者的速率。

### 5.1 基本用法

```systemverilog
class my_env extends uvm_env;
  `uvm_component_utils(my_env)

  // TLM FIFO声明
  uvm_tlm_fifo #(my_transaction) fifo;

  my_producer prod;
  my_consumer cons;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // 创建FIFO，指定缓冲深度
    fifo = new("fifo", this, 16);  // 深度为16
    prod = my_producer::type_id::create("prod", this);
    cons = my_consumer::type_id::create("cons", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // 连接生产者到FIFO的put端口
    prod.out_port.connect(fifo.put_export);
    // 连接消费者到FIFO的get端口
    cons.in_port.connect(fifo.get_export);
  endfunction
endclass
```

### 5.2 FIFO接口方法

```systemverilog
// FIFO提供的接口
uvm_put_imp        put_export;    // put接口实现
uvm_get_imp        get_export;    // get接口实现
uvm_peek_imp       peek_export;   // peek接口实现

// FIFO查询方法
function int used();      // 已使用空间
function int size();      // FIFO总大小
function bit is_empty();  // 是否为空
function bit is_full();   // 是否已满

// 阻塞操作
task put(T t);           // 满时阻塞
task get(output T t);    // 空时阻塞
task peek(output T t);   // 空时阻塞

// 非阻塞操作
function bit try_put(T t);
function bit try_get(output T t);
function bit try_peek(output T t);
```

### 5.3 Analysis FIFO

专用于analysis port的FIFO，支持`write`方法。

```systemverilog
class my_env extends uvm_env;
  `uvm_component_utils(my_env)

  // Analysis FIFO
  uvm_tlm_analysis_fifo #(my_transaction) analysis_fifo;

  my_monitor mon;
  my_scoreboard scb;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_fifo = new("analysis_fifo", this);
    mon = my_monitor::type_id::create("mon", this);
    scb = my_scoreboard::type_id::create("scb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Monitor的analysis port连接到analysis FIFO
    mon.ap.connect(analysis_fifo.analysis_export);
    // Scoreboard从FIFO获取数据
    scb.get_port.connect(analysis_fifo.get_export);
  endfunction
endclass
```

## 6. 阻塞与非阻塞通信

### 6.1 阻塞通信

阻塞方式会等待操作完成才返回。

```systemverilog
// 阻塞put - 如果目标满则等待
task put(my_transaction t);
  while (is_full()) begin
    @(posedge clk);  // 等待时钟周期
  end
  buffer.push_back(t);
endtask

// 阻塞get - 如果源空则等待
task get(output my_transaction t);
  while (is_empty()) begin
    @(posedge clk);
  end
  t = buffer.pop_front();
endtask
```

### 6.2 非阻塞通信

非阻塞方式立即返回，通过返回值表示操作结果。

```systemverilog
// 非阻塞put - 立即返回
function bit try_put(my_transaction t);
  if (is_full()) begin
    return 0;  // 失败
  end
  buffer.push_back(t);
  return 1;    // 成功
endfunction

// 非阻塞get - 立即返回
function bit try_get(output my_transaction t);
  if (is_empty()) begin
    return 0;  // 失败
  end
  t = buffer.pop_front();
  return 1;    // 成功
endfunction
```

### 6.3 使用建议

| 场景 | 推荐方式 | 原因 |
|------|---------|------|
| Driver获取事务 | 阻塞 | 必须等待事务到来 |
| Monitor广播 | 阻塞 | 确保数据完整传输 |
| 检查缓冲区状态 | 非阻塞 | 避免死锁 |
| 超时处理 | 非阻塞 | 实现超时机制 |

## 7. 常见应用示例

### 7.1 完整的Agent结构

```systemverilog
class my_agent extends uvm_agent;
  `uvm_component_utils(my_agent)

  my_driver    drv;
  my_monitor   mon;
  uvm_sequencer #(my_transaction) sqr;

  // 对外接口
  uvm_analysis_port #(my_transaction) ap;  // Monitor数据出口
  uvm_seq_item_pull_port #(my_transaction) seq_item_port;  // Sequencer接口

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = my_monitor::type_id::create("mon", this);
    if (get_is_active() == UVM_ACTIVE) begin
      drv = my_driver::type_id::create("drv", this);
      sqr = uvm_sequencer#(my_transaction)::type_id::create("sqr", this);
    end
    ap = new("ap", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Monitor的analysis port连接到agent的ap
    mon.ap.connect(ap);
    // Driver连接到Sequencer
    if (get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(sqr.seq_item_export);
    end
  endfunction
endclass
```

### 7.2 Scoreboard实现

```systemverilog
class my_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(my_scoreboard)

  // 期望值和实际值的analysis imp
  uvm_analysis_imp_decl(_expected)
  uvm_analysis_imp_decl(_actual)

  uvm_analysis_imp_expected #(my_transaction, my_scoreboard) exp_imp;
  uvm_analysis_imp_actual #(my_transaction, my_scoreboard) act_imp;

  // 事务队列
  my_transaction exp_queue[$];
  my_transaction act_queue[$];

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    exp_imp = new("exp_imp", this);
    act_imp = new("act_imp", this);
  endfunction

  // 接收期望事务
  function void write_expected(my_transaction t);
    exp_queue.push_back(t);
    compare();
  endfunction

  // 接收实际事务
  function void write_actual(my_transaction t);
    act_queue.push_back(t);
    compare();
  endfunction

  // 比较逻辑
  function void compare();
    my_transaction exp, act;
    while (exp_queue.size() > 0 && act_queue.size() > 0) begin
      exp = exp_queue.pop_front();
      act = act_queue.pop_front();
      if (!exp.compare(act)) begin
        `uvm_error("SCB", $sformatf("Mismatch! Exp: %h, Act: %h", exp.data, act.data))
      end
    end
  endfunction
endclass
```

### 7.3 多级组件连接

```systemverilog
class my_subsystem extends uvm_component;
  `uvm_component_utils(my_subsystem)

  my_agent agent;
  my_scoreboard scb;
  uvm_tlm_fifo #(my_transaction) fifo;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = my_agent::type_id::create("agent", this);
    scb = my_scoreboard::type_id::create("scb", this);
    fifo = new("fifo", this, 8);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Monitor -> FIFO -> Scoreboard
    agent.ap.connect(fifo.put_export);
    scb.get_port.connect(fifo.get_export);
  endfunction
endclass
```

## 8. 与UVM组件的集成

### 8.1 UVM组件中的标准TLM端口

| 组件 | 标准端口 | 用途 |
|------|---------|------|
| **Driver** | `seq_item_port` | 从Sequencer获取事务 |
| **Sequencer** | `seq_item_export` | 向Driver提供事务 |
| **Monitor** | `ap` (analysis port) | 广播采集到的事务 |
| **Scoreboard** | `analysis_imp` | 接收事务进行比较 |

### 8.2 Sequencer-Driver连接

```systemverilog
class my_driver extends uvm_driver #(my_transaction);
  `uvm_component_utils(my_driver)

  task run_phase(uvm_phase phase);
    forever begin
      // 从Sequencer获取下一个事务
      seq_item_port.get_next_item(req);
      `uvm_info("DRV", $sformatf("Driving: %h", req.data), UVM_HIGH)

      // 驱动到接口
      @(posedge vif.clk);
      vif.data <= req.data;
      vif.valid <= 1'b1;
      @(posedge vif.clk);
      vif.valid <= 1'b0;

      // 通知Sequencer事务完成
      seq_item_port.item_done();
    end
  endtask
endclass

class my_env extends uvm_env;
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Driver连接到Sequencer
    agent.drv.seq_item_port.connect(agent.sqr.seq_item_export);
  endfunction
endclass
```

### 8.3 使用uvm_subscriber

`uvm_subscriber`是专门用于analysis port实现的基类。

```systemverilog
class my_coverage_collector extends uvm_subscriber #(my_transaction);
  `uvm_component_utils(my_coverage_collector)

  my_transaction tr;

  covergroup cg;
    coverpoint tr.data {
      bins low  = {[0:8'h3F]};
      bins mid  = {[8'h40:8'hBF]};
      bins high = {[8'hC0:8'hFF]};
    }
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg = new();
  endfunction

  // 实现write方法（uvm_subscriber要求）
  function void write(my_transaction t);
    tr = t;
    cg.sample();
  endfunction
endclass

// 连接
monitor.ap.connect(cov_collector.analysis_export);
```

## 9. 最佳实践

### 9.1 端口命名规范

```systemverilog
// 推荐命名
uvm_analysis_port #(my_transaction) ap;              // Analysis port
uvm_put_port #(my_transaction) put_port;              // Put port
uvm_get_port #(my_transaction) get_port;              // Get port
uvm_tlm_fifo #(my_transaction) fifo;                  // FIFO
uvm_analysis_imp #(my_transaction, my_class) ap_imp;  // Analysis imp
```

### 9.2 常见错误

**错误1：忘记实现接口方法**

```systemverilog
// 错误：uvm_put_imp没有实现put方法
class bad_scoreboard extends uvm_scoreboard;
  uvm_put_imp #(my_transaction, bad_scoreboard) put_imp;
  // 缺少 task put(my_transaction t) 实现！
endclass
```

**错误2：analysis_imp多端口问题**

```systemverilog
// 错误：同一个类使用两个相同类型的analysis_imp
class bad_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp #(my_transaction, bad_scoreboard) exp_imp;
  uvm_analysis_imp #(my_transaction, bad_scoreboard) act_imp;
  // 两个imp的write方法会冲突！
endclass

// 正确：使用宏声明不同后缀
`uvm_analysis_imp_decl(_expected)
`uvm_analysis_imp_decl(_actual)

class good_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp_expected #(my_transaction, good_scoreboard) exp_imp;
  uvm_analysis_imp_actual #(my_transaction, good_scoreboard) act_imp;
endclass
```

**错误3：连接顺序错误**

```systemverilog
// 错误：在build_phase中连接
function void build_phase(uvm_phase phase);
  agent.ap.connect(scb.ap_imp);  // 过早！
endfunction

// 正确：在connect_phase中连接
function void connect_phase(uvm_phase phase);
  agent.ap.connect(scb.ap_imp);
endfunction
```

### 9.3 调试技巧

```systemverilog
// 检查连接状态
function void connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  agent.ap.connect(scb.ap_imp);

  // 打印连接信息
  `uvm_info("ENV", $sformatf("Agent AP size: %0d", agent.ap.size()), UVM_LOW)
endfunction

// 使用UVM拓扑打印
initial begin
  uvm_top.print_topology();
end
```

## 10. 相关链接

- [[02-UVM/00-入门|UVM入门]]
- [[02-UVM/03-Sequence机制|Sequence机制]]
- [[02-UVM/04-组件|UVM组件]]
- [[05-Verification/UVM-Template/UVM-Analysis-Port数据流|UVM Analysis Port数据流]]
- [[05-Verification/UVM-Template/uvm_analysis_imp多端口陷阱|uvm_analysis_imp多端口陷阱]]
