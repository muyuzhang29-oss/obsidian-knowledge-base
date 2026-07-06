---
tags: [UVM, Sequence, 鏈哄埗, 鏍稿績]
created: 2026-05-13
updated: 2026-06-02
---

# UVM Sequence 鏈哄埗

> UVM涓殑婵€鍔辩敓鎴愪笌鍙戦€佹満鍒?
## 鏋舵瀯姒傝

```
鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?鈹?             Sequencer               鈹?鈹? 鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?鈹?鈹? 鈹?       Sequence Layer          鈹?鈹?鈹? 鈹?  鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹?鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹?       鈹?鈹?鈹? 鈹?  鈹係eq 1  鈹?鈹係eq 2  鈹? ...  鈹?鈹?鈹? 鈹?  鈹斺攢鈹€鈹€鈹攢鈹€鈹€鈹?鈹斺攢鈹€鈹€鈹攢鈹€鈹€鈹?       鈹?鈹?鈹? 鈹?      鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹敇            鈹?鈹?鈹? 鈹?                鈻?             鈹?鈹?鈹? 鈹?     鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?     鈹?鈹?鈹? 鈹?     鈹? Sequence Item  鈹?     鈹?鈹?鈹? 鈹?     鈹?  (Transaction) 鈹?     鈹?鈹?鈹? 鈹?     鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?     鈹?鈹?鈹? 鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹尖攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?鈹?鈹?                鈻?                 鈹?鈹?           鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?           鈹?鈹?           鈹?Driver  鈹?           鈹?鈹?           鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?           鈹?鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?```

---

## 1. Transaction 瀹氫箟

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

## 2. Sequence 瀹氫箟

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

## 3. 甯哥敤瀹?
| 瀹?| 璇存槑 |
|-----|------|
| `` `uvm_do(item) `` | 鍒涘缓銆侀殢鏈哄寲銆佸彂閫?|
| `` `uvm_do_with(item, {constraints}) `` | 甯︾害鏉熷彂閫?|
| `` `uvm_create(item) `` | 浠呭垱寤?|
| `` `uvm_send(item) `` | 鍙戦€佸凡鍒涘缓鐨?|

### 绀轰緥

```verilog
// 鍩烘湰
`uvm_do(req)

// 甯︾害鏉?`uvm_do_with(req, { req.addr >= 0 && req.addr < 'h100; })

// 鍒嗘
`uvm_create(req)
assert(req.randomize() with { addr == 0; });
`uvm_send(req)
```

---

## 4. 鍚姩 Sequence

### 鏂瑰紡1锛歝onfig_db

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

### 鏂瑰紡2锛歴tart()

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

## 5. Sequencer 浠茶

```verilog
// 璁剧疆浠茶妯″紡
sqr.set_arbitration(UVM_SEQ_ARB_STRICT_RANDOM);  // 闅忔満
sqr.set_arbitration(UVM_SEQ_ARB_FIFO);          // FIFO
sqr.set_arbitration(UVM_SEQ_ARB_PRIORITY);        // 浼樺厛绾?
// 浼樺厛绾?`uvm_do_pri(req, 100)    // 楂樹紭鍏堢骇
`uvm_do_pri(req, 50)     // 浣庝紭鍏堢骇
```

---

tags: #UVM #Sequence #Stimulus #鏍稿績

## 鐩稿叧绗旇

- [[02-UVM/00-鍏ラ棬|UVM 鍏ラ棬]] - UVM 鍩虹鍏ラ棬
- [[01-Phase鏈哄埗]] - UVM Phase 鏈哄埗
- [[02-config_db]] - config_db 閰嶇疆鏈哄埗
- [[04-缁勪欢]] - UVM 缁勪欢缁撴瀯
- [[05-Transaction闅忔満涓巆fg鑱斿姩]] - Transaction 闅忔満涓?cfg 鑱斿姩
- [[06-TLM閫氫俊]] - TLM 閫氫俊鏈哄埗

