---
tags: [UVM, config_db, 閰嶇疆, 鏍稿績]
created: 2026-05-13
updated: 2026-06-02
---

# UVM config_db 鏈哄埗

> 閰嶇疆浼犻€掓満鍒讹紝鍏佽testbench灞傛鍖栭厤缃?
## 鍩烘湰姒傚康

```
testbench
    鈹斺攢鈹€ env (uvm_env)
            鈹溾攢鈹€ agent (uvm_agent)
            鈹?      鈹溾攢鈹€ driver (uvm_driver)
            鈹?      鈹斺攢鈹€ monitor (uvm_monitor)
            鈹斺攢鈹€ scoreboard
```

---

## set/get 閰嶅

```verilog
// 鍦╰est鎴杄nv涓缃?uvm_config_db#(int)::set(this, "env.agent", "is_active", UVM_ACTIVE);
uvm_config_db#(virtual uvm_if)::set(this, "env.agent*", "vif", dut_if);

// 鍦╠river/monitor涓幏鍙?uvm_config_db#(virtual uvm_if)::get(this, "", "vif", vif);
if (vif == null)
    `uvm_fatal("NOVIF", "vif is null")
```

---

## 閫氶厤绗﹁矾寰?
| 璺緞 | 鍚箟 |
|------|------|
| `"env.agent"` | 绮剧‘鍖归厤 |
| `"env.*"` | env涓嬫墍鏈?|
| `"env.**"` | env鍙婂叾鎵€鏈夊瓙缁勪欢 |
| `"*"` | 鍏ㄥ眬 |

---

## 甯哥敤閰嶇疆绫诲瀷

### 1. Virtual Interface

```verilog
// Top灞傝缃?module tb;
    interface dut_if();
    endinterface
    initial begin
        uvm_config_db#(virtual dut_if)::set(uvm_root::get(), "*", "vif", dut_if);
    end
endmodule

// Driver鑾峰彇
class my_driver extends uvm_driver;
    virtual dut_if vif;
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Cannot get vif")
    endfunction
endclass
```

### 2. 绠€鍗曞彉閲?
```verilog
uvm_config_db#(int)::set(this, "env", "verbosity", UVM_MEDIUM);
uvm_config_db#(string)::set(this, "env.agent", "mode", "MASTER");
```

### 3. 瀵硅薄/鍙ユ焺

```verilog
my_config cfg;
cfg = my_config::type_id::create("cfg");
uvm_config_db#(my_config)::set(this, "env", "cfg", cfg);
```

---

## 甯哥敤棰勫畾涔夐厤缃?
```verilog
// is_active: 鍒涘缓driver
uvm_config_db#(uvm_active_passive_enum)::set(this, "env.agent", "is_active", UVM_PASSIVE);

// sequence鏉愭枡
uvm_config_db#(uvm_object_wrapper)::set(this,
    "env.agent.sequencer.main_phase",
    "default_sequence",
    my_sequence::get_type());
```

---

## 甯歌閿欒

```verilog
// 閿欒1锛氳矾寰勪笉鍖归厤
uvm_config_db#(int)::set(this, "env.agent.drv", "value", 10);
uvm_config_db#(int)::get(this, "env.agent.driver", "value", v);  // 涓嶅尮閰嶏紒

// 閿欒2锛氬湪top灞備娇鐢ㄧ浉瀵硅矾寰?uvm_config_db#(virtual dut_if)::set(uvm_root::get(), "env.drv", "vif", vif);
// 搴旇鐢ㄩ€氶厤绗?uvm_config_db#(virtual dut_if)::set(uvm_root::get(), "*", "vif", vif);
```

---

tags: #UVM #config_db #鏍稿績

## 鐩稿叧绗旇

- [[02-UVM/00-鍏ラ棬|UVM 鍏ラ棬]] - UVM 鍩虹鍏ラ棬
- [[01-Phase鏈哄埗]] - UVM Phase 鏈哄埗
- [[03-Sequence鏈哄埗]] - Sequence 婵€鍔辩敓鎴?- [[04-缁勪欢]] - UVM 缁勪欢缁撴瀯
- [[05-Transaction闅忔満涓巆fg鑱斿姩]] - cfg 涓?Transaction 闅忔満鑱斿姩

