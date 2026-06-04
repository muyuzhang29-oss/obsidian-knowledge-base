---
tags: [UVM, config_db, 配置, 核心]
created: 2026-05-13
updated: 2026-06-02
---

# UVM config_db 机制

> 配置传递机制，允许testbench层次化配置

## 基本概念

```
testbench
    └── env (uvm_env)
            ├── agent (uvm_agent)
            │       ├── driver (uvm_driver)
            │       └── monitor (uvm_monitor)
            └── scoreboard
```

---

## set/get 配对

```systemverilog
// 在test或env中设置
uvm_config_db#(int)::set(this, "env.agent", "is_active", UVM_ACTIVE);
uvm_config_db#(virtual uvm_if)::set(this, "env.agent*", "vif", dut_if);

// 在driver/monitor中获取
uvm_config_db#(virtual uvm_if)::get(this, "", "vif", vif);
if (vif == null)
    `uvm_fatal("NOVIF", "vif is null")
```

---

## 通配符路径

| 路径 | 含义 |
|------|------|
| `"env.agent"` | 精确匹配 |
| `"env.*"` | env下所有 |
| `"env.**"` | env及其所有子组件 |
| `"*"` | 全局 |

---

## 常用配置类型

### 1. Virtual Interface

```systemverilog
// Top层设置
module tb;
    interface dut_if();
    endinterface
    initial begin
        uvm_config_db#(virtual dut_if)::set(uvm_root::get(), "*", "vif", dut_if);
    end
endmodule

// Driver获取
class my_driver extends uvm_driver;
    virtual dut_if vif;
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Cannot get vif")
    endfunction
endclass
```

### 2. 简单变量

```systemverilog
uvm_config_db#(int)::set(this, "env", "verbosity", UVM_MEDIUM);
uvm_config_db#(string)::set(this, "env.agent", "mode", "MASTER");
```

### 3. 对象/句柄

```systemverilog
my_config cfg;
cfg = my_config::type_id::create("cfg");
uvm_config_db#(my_config)::set(this, "env", "cfg", cfg);
```

---

## 常用预定义配置

```systemverilog
// is_active: 创建driver
uvm_config_db#(uvm_active_passive_enum)::set(this, "env.agent", "is_active", UVM_PASSIVE);

// sequence材料
uvm_config_db#(uvm_object_wrapper)::set(this,
    "env.agent.sequencer.main_phase",
    "default_sequence",
    my_sequence::get_type());
```

---

## 常见错误

```systemverilog
// 错误1：路径不匹配
uvm_config_db#(int)::set(this, "env.agent.drv", "value", 10);
uvm_config_db#(int)::get(this, "env.agent.driver", "value", v);  // 不匹配！

// 错误2：在top层使用相对路径
uvm_config_db#(virtual dut_if)::set(uvm_root::get(), "env.drv", "vif", vif);
// 应该用通配符
uvm_config_db#(virtual dut_if)::set(uvm_root::get(), "*", "vif", vif);
```

---

tags: #UVM #config_db #核心

## 相关笔记

- [[02-UVM/00-入门|UVM 入门]] - UVM 基础入门
- [[01-Phase机制]] - UVM Phase 机制
- [[03-Sequence机制]] - Sequence 激励生成
- [[04-组件]] - UVM 组件结构
- [[05-Transaction随机与cfg联动]] - cfg 与 Transaction 随机联动
