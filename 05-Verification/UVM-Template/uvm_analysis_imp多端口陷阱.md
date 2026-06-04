---
tags: [UVM, Verification, 模板, TLM, 陷阱]
created: 2026-04-17
updated: 2026-06-02
---

# uvm_analysis_imp 多端口陷阱

> 同一个类中使用多个 `uvm_analysis_imp` 时，所有端口都调用同一个 `write` 函数

---

## 一、问题描述

当 scoreboard 需要接收来自两个不同源（monitor 和 golden）的数据时，会声明两个 `uvm_analysis_imp`：

```systemverilog
// ❌ 错误写法
uvm_analysis_imp#(spi_trans, spi_scoreboard) rx_imp;   // 接收 monitor 实际输出
uvm_analysis_imp#(spi_trans, spi_scoreboard) exp_imp;  // 接收 golden 期望输出
```

**问题：** 两个端口都是 `uvm_analysis_imp`，UVM 框架只认 `write` 函数。无论数据从哪个端口进来，都调用 `write()`。

```systemverilog
function void write(spi_trans tr);     // rx_imp 调用 ✓
    ...
endfunction

function void write_exp(spi_trans tr); // exp_imp 也调用 write()，不会调用 write_exp()
    ...
endfunction
```

**结果：** `write_exp()` 永远不会被调用，期望值队列始终为空。

---

## 二、解决方法

用 `` `uvm_analysis_imp_decl `` 宏生成带后缀的 `write` 函数：

```systemverilog
// ✅ 正确写法
`uvm_analysis_imp_decl(_rx)    // 生成 uvm_analysis_imp_rx 类，调用 write_rx()
`uvm_analysis_imp_decl(_exp)   // 生成 uvm_analysis_imp_exp 类，调用 write_exp()

class spi_scoreboard extends uvm_scoreboard;
    uvm_analysis_imp_rx #(spi_trans, spi_scoreboard) rx_imp;   // → 调用 write_rx()
    uvm_analysis_imp_exp #(spi_trans, spi_scoreboard) exp_imp;  // → 调用 write_exp()

    function void write_rx(spi_trans rx_trans);
        // 处理 monitor 的实际输出
    endfunction

    function void write_exp(spi_trans exp_trans);
        // 处理 golden 的期望输出
    endfunction
endclass
```

---

## 三、工作原理

`` `uvm_analysis_imp_decl(_rx) `` 展开后生成一个类：

```systemverilog
class uvm_analysis_imp_rx #(type T=int, type IMP=int);
    function void write(T t);
        m_imp.write_rx(t);  // 自动调用带后缀的函数
    endfunction
endclass
```

所以：
- `uvm_analysis_imp_rx` 的 `write()` → 调用 `write_rx()`
- `uvm_analysis_imp_exp` 的 `write()` → 调用 `write_exp()`

---

## 四、完整 Scoreboard 模板

```systemverilog
`uvm_analysis_imp_decl(_rx)
`uvm_analysis_imp_decl(_exp)

class spi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(spi_scoreboard)

    uvm_analysis_imp_rx #(spi_trans, spi_scoreboard) rx_imp;
    uvm_analysis_imp_exp #(spi_trans, spi_scoreboard) exp_imp;

    spi_trans exp_queue[$];

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rx_imp  = new("rx_imp", this);
        exp_imp = new("exp_imp", this);
    endfunction

    // 接收 monitor 的实际输出
    function void write_rx(spi_trans rx_trans);
        spi_trans exp_trans;
        if(exp_queue.size() == 0) begin
            `uvm_error("SCB", "NO EXP TRANS AVAILABLE");
            return;
        end
        exp_trans = exp_queue.pop_front();
        compare(rx_trans, exp_trans);
    endfunction

    // 接收 golden 的期望输出
    function void write_exp(spi_trans exp_trans);
        exp_queue.push_back(exp_trans);
    endfunction

    function void compare(spi_trans rx, spi_trans exp);
        bit match = rx.compare(exp);
        if(match)
            `uvm_info("SCB", "PASS", UVM_LOW)
        else
            `uvm_error("SCB", "FAIL")
    endfunction

endclass
```

---

## 五、常见错误汇总

| 场景 | 错误写法 | 正确写法 |
|------|----------|----------|
| 单端口 | `uvm_analysis_imp#(T, C)` | 可以，`write()` 无歧义 |
| 双端口 | 两个 `uvm_analysis_imp#(T, C)` | 用 `` `uvm_analysis_imp_decl `` 区分 |
| 函数名 | `write()` + `write_exp()` | `write_rx()` + `write_exp()` |
| 宏位置 | 在 class 内部 | 在 class 外部，`include` 之前 |

---

## 六、调试技巧

如果怀疑 `write` 函数没被调用，加打印确认：

```systemverilog
function void write_rx(spi_trans rx_trans);
    `uvm_info("SCB", "write_rx() called", UVM_LOW)  // ← 确认有没有被调用
    ...
endfunction

function void write_exp(spi_trans exp_trans);
    `uvm_info("SCB", "write_exp() called", UVM_LOW)  // ← 确认有没有被调用
    ...
endfunction
```

如果只打印了 `write_rx` 没有 `write_exp` → 说明 `uvm_analysis_imp_decl` 没加或加错了。

---

*创建时间: 2026-06-01*
