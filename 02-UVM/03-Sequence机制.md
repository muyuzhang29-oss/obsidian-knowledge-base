---
tags: [UVM, Sequence, 机制, 核心]
created: 2026-05-13
updated: 2026-06-02
---

# UVM Sequence 机制

> UVM中的激励生成与发送机制

## 架构概览

```
┌──────────────────────────────────────┐
│              Sequencer               │
│  ┌────────────────────────────────┐ │
│  │        Sequence Layer          │ │
│  │   ┌───────┐ ┌───────┐        │ │
│  │   │Seq 1  │ │Seq 2  │  ...  │ │
│  │   └───┬───┘ └───┬───┘        │ │
│  │       └─────────┬┘            │ │
│  │                 ▼              │ │
│  │      ┌─────────────────┐      │ │
│  │      │  Sequence Item  │      │ │
│  │      │   (Transaction) │      │ │
│  │      └────────┬────────┘      │ │
│  └──────────────┼────────────────┘ │
│                 ▼                  │
│            ┌─────────┐            │
│            │ Driver  │            │
│            └─────────┘            │
└──────────────────────────────────────┘
```

---

## 1. Transaction 定义

```verilog
class my_transaction extends uvm_sequence_item;
    rand bit [31:0] addr;
    rand bit [31:0] data;
    rand bit [3:0] be;
    rand bit rw;               // 0=read, 1=write

    `uvm_object_utils_begin(my_transaction)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "my_transaction");
        super.new(name);
    endfunction
endclass
```

---

## 2. Sequence 定义

```verilog
class my_sequence extends uvm_sequence #(my_transaction);
    `uvm_object_utils(my_sequence)

    int num_trans = 10;

    function new(string name = "my_sequence");
        super.new(name);
        set_response_queue_depth(10);
    endfunction

    virtual task body();
        `uvm_info("SEQ", "Starting sequence", UVM_MEDIUM)
        repeat(num_trans) begin
            `uvm_do(req)
        end
        `uvm_info("SEQ", "Sequence completed", UVM_MEDIUM)
    endtask
endclass
```

---

## 3. 常用宏

| 宏 | 说明 |
|-----|------|
| `` `uvm_do(item) `` | 创建、随机化、发送 |
| `` `uvm_do_with(item, {constraints}) `` | 带约束发送 |
| `` `uvm_create(item) `` | 仅创建 |
| `` `uvm_send(item) `` | 发送已创建的 |

### 示例

```verilog
// 基本
`uvm_do(req)

// 带约束
`uvm_do_with(req, { req.addr >= 0 && req.addr < 'h100; })

// 分步
`uvm_create(req)
assert(req.randomize() with { addr == 0; });
`uvm_send(req)
```

---

## 4. 启动 Sequence

### 方式1：config_db

```verilog
class my_test extends uvm_test;
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(uvm_object_wrapper)::set(this,
            "env.agent.sequencer.main_phase",
            "default_sequence",
            my_sequence::get_type());
    endfunction
endclass
```

### 方式2：start()

```verilog
class my_test extends uvm_test;
    my_sequence seq;
    function void start_of_simulation_phase(uvm_phase phase);
        seq = my_sequence::type_id::create("seq");
        seq.start(uvm_top.find("env.agent.sequencer"));
    endfunction
endclass
```

---

## 5. Sequencer 仲裁

```verilog
// 设置仲裁模式
sqr.set_arbitration(UVM_SEQ_ARB_STRICT_RANDOM);  // 随机
sqr.set_arbitration(UVM_SEQ_ARB_FIFO);          // FIFO
sqr.set_arbitration(UVM_SEQ_ARB_PRIORITY);        // 优先级

// 优先级
`uvm_do_pri(req, 100)    // 高优先级
`uvm_do_pri(req, 50)     // 低优先级
```

---

tags: #UVM #Sequence #Stimulus #核心

## 相关笔记

- [[02-UVM/00-入门|UVM 入门]] - UVM 基础入门
- [[01-Phase机制]] - UVM Phase 机制
- [[02-config_db]] - config_db 配置机制
- [[04-组件]] - UVM 组件结构
- [[05-Transaction随机与cfg联动]] - Transaction 随机与 cfg 联动
- [[06-TLM通信]] - TLM 通信机制
