---
tags:
  - SV
  - SystemVerilog
  - SVA
  - 断言
  - 验证
  - 核心
created: 2026-06-02
updated: 2026-06-18
---

# SVA 断言（SystemVerilog Assertions）

## 1. 概述

SVA 是 SystemVerilog 中内置的断言语言，用于在仿真和形式验证中检查设计行为是否符合预期。断言本质上是一条**布尔表达式**，当条件不满足时报告失败。

**核心价值：**
- 在离 Bug 最近的位置捕获错误，缩短调试时间
- 可复用于仿真（动态验证）和形式验证（静态验证）
- 作为活文档，精确描述设计意图

**断言的三种类型：**

| 类型 | 关键字 | 执行时机 |
|------|--------|----------|
| 即时断言（Immediate） | `assert` | 仿真是过程块中立即求值 |
| 并发断言（Concurrent） | `assert property` | 每个时钟边沿求值 |
| 覆盖属性（Cover） | `cover property` | 统计属性被满足的次数 |

---

## 2. 即时断言（Immediate Assertion）

即时断言在过程块中执行，本质上是 `if-else` 的简写形式。

```verilog
// 基本语法
assert (expression) else $error("message");

// 示例：检查复位期间信号值
always @(posedge clk) begin
    if (rst_n == 0) begin
        assert (data_out == 0)
            else $error("data_out not zero during reset!");
    end
end

// 带动作块
assert (fifo_count <= FIFO_DEPTH)
    else $error("FIFO overflow! count=%0d", fifo_count);
```

**即时断言的动作块：**

```verilog
assert (condition)
    $info("Pass message");      // 通过时执行
else
    $error("Fail message");     // 失败时执行

// 严重程度关键字
// $fatal   - 终止仿真
// $error   - 报告错误（默认）
// $warning - 报告警告
// $info    - 报告信息
```

---

## 3. 并发断言（Concurrent Assertion）

并发断言在时钟边沿上求值，是 SVA 的核心。它基于**采样后的**信号值，在时钟 Region 执行。

```verilog
// 基本语法
assert property (property_expression)
    else $error("message");

// 示例：请求-应答协议
assert property (@(posedge clk) req |-> ##[1:3] ack)
    else $error("ack not received within 1~3 cycles after req");
```

**关键区别：即时断言用采样前的值，并发断言用采样后的值（preponed region）。**

```verilog
// 在 module 或 interface 中声明
module example (
    input  logic clk, rst_n, req, gnt,
    output logic [7:0] data
);

    // 并发断言：grant 必须在请求后 1~5 个周期内到来
    property p_gnt_after_req;
        @(posedge clk) disable iff (!rst_n)
        req |-> ##[1:5] gnt;
    endproperty

    assert property (p_gnt_after_req)
        else $error("Grant not received after request");

endmodule
```

---

## 4. 序列（Sequence）

序列定义了信号在时间上的行为模式，是构成属性的基本单元。

### 4.1 基本序列

```verilog
// 单周期序列
sequence s_req;
    req;
endsequence

// 多周期序列：请求后2周期应答
sequence s_req_ack;
    req ##2 ack;
endsequence

// 带条件的序列
sequence s_req_ack_vld;
    req && vld ##2 ack;
endsequence
```

### 4.2 序列的参数化

```verilog
sequence s_delay_ack(int min_del, max_del);
    req ##[min_del:max_del] ack;
endsequence

// 使用
assert property (@(posedge clk) s_delay_ack(1, 5));
```

### 4.3 序列的组合

```verilog
// 串联
sequence s1;
    a ##1 b ##1 c;
endsequence

// 选择（or）
sequence s2;
    a ##1 b  or  a ##2 c;
endsequence

// 重复
sequence s3;
    a [*3];          // a 连续出现 3 次: a ##1 a ##1 a
endsequence

sequence s4;
    a [*1:3];        // a 连续出现 1~3 次
endsequence

sequence s5;
    a [=2];          // a 非连续出现 2 次（中间允许间隔）
endsequence

sequence s6;
    a [->2];         // a 非连续出现 2 次，最后一次必须紧邻后续
endsequence
```

---

## 5. 属性（Property）

属性将序列与时钟、蕴含等结合，形成可被断言或覆盖的完整检查单元。

```verilog
// 基本属性
property p_example;
    @(posedge clk) req |-> ##[1:3] ack;
endproperty

// 带 disable 条件
property p_rst_check;
    @(posedge clk) disable iff (!rst_n)
    req |-> ##1 ack;
endproperty

// 属性的组合
property p_complex;
    @(posedge clk) disable iff (!rst_n)
    (req && !busy) |-> ##[1:4] (gnt && !err);
endproperty
```

---

## 6. 常用操作符

### 6.1 蕴含操作符

| 操作符 | 含义 | 说明 |
|--------|------|------|
| `\|->` | 重叠蕴含 | 前件成立时，后件从**同一周期**开始检查 |
| `\|=>` | 非重叠蕴含 | 前件成立时，后件从**下一周期**开始检查 |

```verilog
// |-> 重叠：req 当周期开始检查
property p_overlap;
    @(posedge clk) req |-> ##1 ack;   // req 当周期开始，1 周期后 ack
endproperty

// |=> 非重叠：req 的下一周期开始检查
property p_non_overlap;
    @(posedge clk) req |=> ack;        // 等价于 req |-> ##1 ack
endproperty
```

### 6.2 时序操作符

| 操作符 | 示例 | 含义 |
|--------|------|------|
| `##N` | `##2` | 延迟 N 个时钟周期 |
| `##[M:N]` | `##[1:4]` | 延迟 M 到 N 个时钟周期 |
| `[*N]` | `a[*3]` | 重复 N 次（连续） |
| `[*M:N]` | `a[*1:3]` | 重复 M 到 N 次（连续） |
| `[=N]` | `a[=2]` | 重复 N 次（非连续，非跟随） |
| `[->N]` | `a[->2]` | 重复 N 次（非连续，跟随） |

### 6.3 throughout 操作符

`throughout` 确保左侧条件在整个右侧序列持续期间保持成立。

```verilog
// req 在整个等待 ack 的过程中必须保持有效
property p_req_until_ack;
    @(posedge clk)
    (req throughout (##[1:$] ack));
endproperty

// 更实用的例子：使能在整个传输过程中保持
property p_en_throughout_xfer;
    @(posedge clk) disable iff (!rst_n)
    (start_en |-> (en throughout (##[1:$] done))));
endproperty
```

### 6.4 until / until_with

```verilog
// until: a 一直为真直到 b 为真（b 那个周期 a 不需要为真）
property p_until;
    @(posedge clk) a until b;
endproperty

// until_with: a 一直为真直到 b 为真（包含 b 那个周期）
property p_until_with;
    @(posedge clk) a until_with b;
endproperty
```

### 6.5 逻辑与时序组合

```verilog
// and：两个序列同时开始，都必须完成
property p_and;
    @(posedge clk) (a ##2 b) and (a ##1 c ##1 d);
endproperty

// or：两个序列同时开始，至少一个完成
property p_or;
    @(posedge clk) (a ##2 b) or (a ##1 c);
endproperty

// intersect：两个序列同时开始且同时完成
property p_intersect;
    @(posedge clk) (a ##1 b ##1 c) intersect (a ##1 d ##1 c);
endproperty
```

### 6.6 first_match

```verilog
// 多个匹配中只取第一个
sequence s_multi;
    a ##[1:5] b;
endsequence

property p_first_match;
    @(posedge clk) first_match(s_multi) |-> ##1 c;
endproperty
```

---

## 7. 常见应用示例

### 7.1 握手协议检查

```verilog
// 1. 请求后必须有应答
property p_req_gnt;
    @(posedge clk) disable iff (!rst_n)
    req |-> ##[1:4] gnt;
endproperty

// 2. 应答时数据必须有效
property p_gnt_data_valid;
    @(posedge clk) disable iff (!rst_n)
    gnt |-> vld;
endproperty

// 3. 撤销请求前必须完成应答
property p_drop_req_after_gnt;
    @(posedge clk) disable iff (!rst_n)
    (gnt && req) |=> !req;
endproperty
```

### 7.2 FIFO 行为检查

```verilog
// 满时不写入
property p_no_wr_when_full;
    @(posedge clk) disable iff (!rst_n)
    full |-> !wr_en;
endproperty

// 空时不读取
property p_no_rd_when_empty;
    @(posedge clk) disable iff (!rst_n)
    empty |-> !rd_en;
endproperty

// 溢出检查
property p_no_overflow;
    @(posedge clk) disable iff (!rst_n)
    (count == DEPTH) |-> !wr_en || rd_en;
endproperty
```

### 7.3 状态机检查

```verilog
// 独热码检查
property p_onehot_state;
    @(posedge clk) $onehot(state);
endproperty

// 状态转换合法性
property p_fsm_transition;
    @(posedge clk) disable iff (!rst_n)
    (state == S_IDLE)  |-> (state_next == S_IDLE || state_next == S_ACTIVE);
endproperty

// 不应进入非法状态
property p_no_illegal_state;
    @(posedge clk) disable iff (!rst_n)
    !(state inside {S_RESERVED1, S_RESERVED2});
endproperty
```

### 7.4 总线协议检查

```verilog
// 地址对齐检查
property p_addr_aligned;
    @(posedge clk) disable iff (!rst_n)
    (req && burst_len == 4) |-> (addr[1:0] == 2'b00);
endproperty

// 写使能与字节使能一致性
property p_wstrb_check;
    @(posedge clk) disable iff (!rst_n)
    (wr_en) |-> (wstrb != 0);
endproperty
```

### 7.5 覆盖属性

```verilog
// 统计特定场景是否被覆盖
cover property (@(posedge clk) req ##[1:4] gnt);

// 带标签的覆盖
cover property (@(posedge clk) req && busy ##[1:3] gnt) begin
    $info("Covered: req during busy, then gnt");
end
```

---

## 8. 与 UVM 的集成方法

### 8.1 在 Interface 中绑定断言

最推荐的方式：将断言放在 interface 中，随 interface 复用。

```verilog
interface bus_if (input logic clk, input logic rst_n);
    logic        req, gnt, vld;
    logic [31:0] addr, data;

    // 断言定义
    property p_req_gnt;
        @(posedge clk) disable iff (!rst_n)
        req |-> ##[1:4] gnt;
    endproperty

    // 绑定断言
    assert property (p_req_gnt)
        else $error("[%m] req without gnt within 1~4 cycles");

endinterface
```

### 8.2 使用 bind 绑定断言模块

将断言分离到独立模块，通过 `bind` 关键字绑定到设计。

```verilog
// 断言模块
module bus_assertions (
    input logic clk, rst_n, req, gnt, vld
);

    property p_req_gnt;
        @(posedge clk) disable iff (!rst_n)
        req |-> ##[1:4] gnt;
    endproperty

    assert property (p_req_gnt)
        else $error("bind: req without gnt");

endmodule

// 绑定到设计模块
bind top.dut bus_assertions u_bus_chk (
    .clk   (clk),
    .rst_n (rst_n),
    .req   (req),
    .gnt   (gnt),
    .vld   (vld)
);
```

### 8.3 bind 的核心价值与使用场景

`bind` 可以把一个断言模块挂到设计模块上，**不修改 RTL 代码**。

```verilog
bind spi_master spi_master_assertions u_bind_assert (
    .clk  (clk),
    .cs_n (cs_n),
    .sck  (sck),
    .mosi (mosi)
);
```

**使用场景：**

| 场景 | 说明 |
|------|------|
| 形式验证（Formal） | 形式验证团队写 SVA property，用 bind 挂到 RTL 跑形式证明，最常见的用途 |
| SoC 集成验证 | 集成验证团队给关键接口 bind 协议检查器（AXI/SPI 等），不碰各模块 RTL |
| IP 交付/重用 | IP 供应商附带 assertion 包，客户用 bind 一行接入即可 |

**与 interface 内嵌断言的对比：**

- **interface 内嵌**：断言写在 interface 里，随 interface 复用，适合自研模块
- **bind 绑定**：断言独立于 RTL 和 interface，适合第三方 IP、不改 RTL 的场景

**模块级验证中**一般用 UVM monitor + scoreboard 覆盖，bind 不是必须的。后续做形式验证或 SoC 集成时再加即可。

### 8.4 UVM Agent 集成断言

在 UVM agent 中通过 virtual interface 触发断言：

```verilog
class bus_agent extends uvm_agent;
    `uvm_component_utils(bus_agent)

    virtual bus_if vif;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual bus_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "virtual interface not set")
    endfunction

    task run_phase(uvm_phase phase);
        // 断言已自动在 interface 中触发
        // 可在此添加额外检查逻辑
    endtask
endclass
```

### 8.5 运行时控制断言

```verilog
// 通过 config_db 控制断言开关
class my_test extends uvm_test;
    virtual bus_if vif;

    task run_phase(uvm_phase phase);
        // 关闭断言
        vif.assert_off();

        // 特定测试场景
        phase.raise_objection(this);
        // ... 测试逻辑 ...
        phase.drop_objection(this);

        // 重新开启断言
        vif.assert_on();
    endtask
endclass
```

---

## 9. 调试技巧

### 9.1 常见断言失败原因

| 现象 | 可能原因 |
|------|----------|
| 误报（False Positive） | 采样时机问题、复位条件缺失 |
| 漏报（False Negative） | 断言条件过宽、未覆盖边界场景 |
| 不触发 | 时钟/复位信号错误、属性未被实例化 |

### 9.2 采样问题调试

并发断言使用 **preponed region** 的信号值，这可能导致与预期不符：

```verilog
// 问题：驱动和断言在同一时钟沿
// 解决方案 1：使用 ##1 延迟一周期确认
property p_safe_check;
    @(posedge clk) req |-> ##1 ack;  // 下一周期确认
endproperty

// 解决方案 2：使用 iff 条件过滤无效周期
property p_filtered;
    @(posedge clk) disable iff (!rst_n || idle)
    req |-> ##1 ack;
endproperty
```

### 9.3 使用 $display 调试

```verilog
// 在序列中加入调试输出
sequence s_debug;
    (req, $display("[%0t] DEBUG: req seen", $time))
    ##[1:4]
    (ack, $display("[%0t] DEBUG: ack seen", $time));
endsequence

// 在属性中使用 $info
assert property (@(posedge clk) req |-> ##[1:4] ack)
    $info("[%0t] PASS: req->ack", $time)
else
    $error("[%0t] FAIL: req without ack", $time);
```

### 9.4 波形调试技巧

1. 在波形中观察断言失败时刻，检查 `req` 和 `ack` 的实际时序关系
2. 确认时钟和复位信号的正确性
3. 检查信号是否在 preponed region 被正确采样
4. 使用工具的断言浏览器查看断言状态（活跃/不活跃/通过/失败）

### 9.5 渐进式编写策略

```verilog
// Step 1: 先写最简单的检查
assert property (@(posedge clk) req |-> ##1 ack);

// Step 2: 加入复位条件
assert property (@(posedge clk) disable iff (!rst_n) req |-> ##1 ack);

// Step 3: 放宽时序范围
assert property (@(posedge clk) disable iff (!rst_n) req |-> ##[1:4] ack);

// Step 4: 加入更多条件
assert property (@(posedge clk) disable iff (!rst_n)
    (req && !err) |-> ##[1:4] (ack && data_vld));
```

---

## 10. 速查表

```verilog
// 即时断言
assert (expr) else $error("msg");

// 并发断言
assert property (@(posedge clk) disable iff (!rst_n) antecedent |-> consequent);

// 覆盖
cover property (@(posedge clk) seq_expr);

// 常用序列
a ##N b                        // 延迟 N 周期
a ##[M:N] b                    // 延迟 M~N 周期
a [*N]                         // 连续重复 N 次
a [*M:N]                       // 连续重复 M~N 次
a [->N]                        // 非连续重复 N 次（跟随）
a [=N]                         // 非连续重复 N 次（非跟随）
a throughout b                 // a 在 b 期间持续为真
a until b                      // a 持续为真直到 b（不含 b 周期）
a until_with b                 // a 持续为真直到 b（含 b 周期）
first_match(seq)               // 取第一个匹配
(seq1) and (seq2)              // 两个序列都完成
(seq1) or (seq2)               // 至少一个完成
(seq1) intersect (seq2)        // 同时开始同时完成
```

---

## 相关链接

- [[01-SV语法/00-入门|SV 入门]]
- [[01-SV语法/04-时钟块Clocking-Block|时钟块 Clocking Block]]
- [[02-UVM/00-入门|UVM 入门]]
- [[05-Verification/00-验证计划|验证计划]]
