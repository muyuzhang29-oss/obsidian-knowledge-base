---
tags: [UVM, Verification, 核心, 实践]
created: 2026-04-17
updated: 2026-06-02
---

# Transaction 随机与 cfg 联动

> 核心原则：transaction 只定义变量和基础约束，和 cfg 联动的随机约束写在 sequence 里

---

## 架构分工

```
test          →  配置 cfg，挂 env，启动 seq（不碰 trans）
sequence      →  拿 cfg，创建 trans，randomize with cfg 约束
transaction   →  只定义 rand 变量 + 通用约束（不依赖 cfg）
```

---

## 为什么不能写在 transaction 内部

```verilog
// ❌ 错误写法：trans 内部依赖 cfg
class my_trans extends uvm_sequence_item;
    my_cfg cfg;                    // trans 依赖外部配置
    rand bit [7:0] data;

    constraint c_data {
        data inside {[cfg.min : cfg.max]};  // 约束依赖 cfg
    }
endclass
```

**问题：**
- trans 必须独立、可复用，不能依赖外部配置
- 不同 test 可能用不同 cfg，trans 无法适配
- 约束规则应该由 seq 控制，trans 只提供变量

---

## 最标准写法：sequence 里 randomize with

```verilog
class my_sequence extends uvm_sequence #(my_trans);
    `uvm_object_utils(my_sequence)

    task body();
        my_trans tr;
        my_cfg   cfg;

        // 1. 从 config_db 拿 cfg
        if (!uvm_config_db#(my_cfg)::get(null, get_full_name(), "cfg", cfg))
            `uvm_fatal("SEQ", "cfg get fail")

        // 2. 创建 trans + 联动 cfg 约束
        tr = my_trans::type_id::create("tr");
        assert(tr.randomize() with {
            data   inside {[cfg.min_data : cfg.max_data]};
            addr   == cfg.base_addr;
            mode   == cfg.work_mode;
            length == cfg.pkg_len;
        }) else `uvm_fatal("SEQ", "randomize fail")

        // 3. 发送
        start_item(tr);
        finish_item(tr);
    endtask
endclass
```

**优势：**
- 每个 sequence 可以有不同的随机策略
- 同一个 trans 可以被不同 sequence 复用
- cfg 约束集中在 sequence，职责清晰

---

## 次选写法：transaction 的 pre_randomize()

> 适合所有 sequence 都必须遵守的全局规则

```verilog
class my_trans extends uvm_sequence_item;
    my_cfg cfg;
    rand bit [7:0] data;

    function void pre_randomize();
        super.pre_randomize();
        // 从 config_db 拿 cfg（全局路径，不推荐；建议通过 sequence 传入）
        uvm_config_db#(my_cfg)::get(null, "", "cfg", cfg);
    endfunction

    constraint c_data {
        data inside {[cfg.min : cfg.max]};
    }
endclass
```

**注意：** 这种写法耦合度较高，不如 sequence 里 randomize with 灵活。

---

## test 该做什么

test 只负责配置 cfg，不碰 trans 随机：

```verilog
class my_test extends uvm_test;
    my_env env;
    my_cfg cfg;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = my_env::type_id::create("env", this);

        // test 只配置 cfg
        cfg = my_cfg::type_id::create("cfg");
        cfg.work_mode = 2'b11;
        cfg.base_addr = 32'h4000_0000;
        cfg.min_data  = 0;
        cfg.max_data  = 255;
        cfg.pkg_len   = 8;
        uvm_config_db#(my_cfg)::set(this, "*", "cfg", cfg);
    endfunction

    task run_phase(uvm_phase phase);
        my_sequence seq;
        phase.raise_objection(this);
        seq = my_sequence::type_id::create("seq");
        seq.start(env.agent.sqr);
        phase.drop_objection(this);
    endtask
endclass
```

---

## 多 constraint mode 切换

cfg 里定义约束模式，sequence 里根据模式切换约束：

```verilog
// cfg 定义模式
class my_cfg extends uvm_object;
    typedef enum {NORMAL, STRESS, CORNER} test_mode_e;
    rand test_mode_e mode;
endclass

// sequence 里根据模式选择约束
task body();
    my_cfg cfg;
    uvm_config_db#(my_cfg)::get(null, get_full_name(), "cfg", cfg);

    tr = my_trans::type_id::create("tr");

    case (cfg.mode)
        my_cfg::NORMAL: begin
            assert(tr.randomize() with {
                data inside {[0:127]};
                addr[1:0] == 0;          // 对齐
            });
        end
        my_cfg::STRESS: begin
            assert(tr.randomize() with {
                data inside {[200:255]};  // 边界压力
                burst_len inside {[16:32]};
            });
        end
        my_cfg::CORNER: begin
            assert(tr.randomize() with {
                data inside {0, 8'hFF, 8'h55, 8'hAA};  // 典型值
            });
        end
    endcase

    start_item(tr);
    finish_item(tr);
endtask
```

---

## 实用技巧

### 1. 多 trans 批量发送

```verilog
task body();
    my_cfg cfg;
    uvm_config_db#(my_cfg)::get(null, get_full_name(), "cfg", cfg);

    repeat (cfg.num_trans) begin
        tr = my_trans::type_id::create("tr");
        assert(tr.randomize() with {
            cmd inside {[cfg.cmd_min : cfg.cmd_max]};
        });
        start_item(tr);
        finish_item(tr);
    end
endtask
```

### 2. 子 sequence 继承 cfg 约束

```verilog
class base_sequence extends uvm_sequence #(my_trans);
    my_cfg cfg;

    task pre_body();
        if (!uvm_config_db#(my_cfg)::get(null, get_full_name(), "cfg", cfg))
            `uvm_fatal("SEQ", "cfg get fail")
    endtask
endclass

class wr_sequence extends base_sequence;
    task body();
        tr = my_trans::type_id::create("tr");
        assert(tr.randomize() with {
            cmd == WR_CMD;
            data inside {[cfg.wr_min : cfg.wr_max]};
        });
        start_item(tr);
        finish_item(tr);
    endtask
endclass
```

### 3. inline constraint 覆盖

```verilog
// sequence 可以额外加约束，覆盖 trans 的默认约束
assert(tr.randomize() with {
    inject_crc_err == 1;          // 强制注入错误
    data_len == 1;                // 固定长度
});
```

---

## 一句话总结

> **trans 提供变量，test 配置 cfg，sequence 拿 cfg 约束 trans 随机 — 各司其职。**

## 相关链接

- [[02-UVM/02-config_db|config_db]] - UVM 配置机制
- [[02-UVM/03-Sequence机制|Sequence 机制]] - Sequence 激励生成
- [[01-SV语法/06-随机化约束|随机化约束]] - SystemVerilog 随机化
- [[00-总索引]] - 返回总索引
