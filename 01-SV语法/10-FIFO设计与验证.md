---
tags:
  - SV
  - 数字设计
  - FIFO
  - 缓冲
  - 验证
  - 核心
  - 时隙
---

# FIFO 设计与验证

> FIFO（First In First Out）是数字设计中最基础也最重要的缓冲结构。作为验证工程师，理解 FIFO 的内部机制、满/空标志的生成逻辑、跨时钟域处理以及常见设计缺陷，是验证数据通路模块的前提。

---

## 📑 目录

- [1. FIFO 基础](#1-fifo-基础)
  - [1.1 什么是 FIFO](#11-什么是-fifo)
  - [1.2 FIFO 的应用场景](#12-fifo-的应用场景)
  - [1.3 FIFO 类型对比](#13-fifo-类型对比)
- [2. 同步 FIFO 设计](#2-同步-fifo-设计)
  - [2.1 结构图](#21-结构图)
  - [2.2 完整实现代码](#22-完整实现代码)
  - [2.3 同步 FIFO 验证代码](#23-同步-fifo-验证代码)
- [3. 异步 FIFO 设计](#3-异步-fifo-设计)
  - [3.1 结构图](#31-结构图)
  - [3.2 格雷码转换原理](#32-格雷码转换原理)
  - [3.3 完整实现代码](#33-完整实现代码)
  - [3.4 异步 FIFO 验证代码](#34-异步-fifo-验证代码)
- [4. 时隙（Time Slot）](#4-时隙-time-slot)
  - [4.1 什么是时隙](#41-什么是时隙)
  - [4.2 时隙的重要性](#42-时隙的重要性)
  - [4.3 时隙分析](#43-时隙分析)
  - [4.4 时隙与同步器延迟](#44-时隙与同步器延迟)
  - [4.5 时隙计算](#45-时隙计算)
  - [4.6 时隙验证](#46-时隙验证)
  - [4.7 时隙优化策略](#47-时隙优化策略)
  - [4.8 时隙与性能](#48-时隙与性能)
  - [4.9 常见时隙问题](#49-常见时隙问题)
  - [4.10 时隙验证策略](#410-时隙验证策略)
- [5. FIFO 验证要点](#5-fifo-验证要点)
  - [5.1 功能验证 Checklist](#51-功能验证-checklist)
  - [5.2 时序验证 Checklist](#52-时序验证-checklist)
  - [5.3 边界条件 Checklist](#53-边界条件-checklist)
  - [5.4 SVA 断言模块](#54-sva-断言模块)
- [6. 常见问题及解决](#6-常见问题及解决)
  - [6.1 满标志提前断言](#61-满标志提前断言)
  - [6.2 空标志延迟断言](#62-空标志延迟断言)
  - [6.3 数据丢失](#63-数据丢失)
- [7. 实用总结](#7-实用总结)

---

## 1. FIFO 基础

### 1.1 什么是 FIFO

FIFO 是一种先进先出的数据缓冲器：最先写入的数据最先被读出。它没有地址接口，写入和读出由内部指针自动管理。

```
    写入端                          读出端
    ┌───┐                          ┌───┐
    │ D ├──┐                  ┌────┤ Q │
    └───┘  │   ┌───────────┐  │    └───┘
           ├──▶│  存储阵列  ├──┤
    wr_en──┤   │ [0][1]... │  ├──rd_en
           │   │ [N-1]     │  │
    full◀──┤   └───────────┘  ├──▶empty
           │       ▲    ▲     │
           └───────┼────┼─────┘
                 wr_ptr rd_ptr
```

核心特征：
- **无地址接口**：用户不需要管理读写地址
- **自动流控**：满时阻止写入，空时阻止读出
- **顺序保证**：数据严格按照写入顺序被读出

### 1.2 FIFO 的应用场景

| 场景 | 说明 | 典型实例 |
|------|------|----------|
| **跨时钟域 (CDC)** | 在两个不同时钟域之间安全传递数据 | AXI 跨频桥、PCIe PHY 接口 |
| **速率匹配** | 上下游模块吞吐率不同，FIFO 吸收速率差 | CPU 写入、DMA 读出 |
| **数据缓冲** | 突发数据暂存，防止下游来不及处理 | 网络包缓冲、视频行缓冲 |
| **流量控制** | 配合 valid/ready 握手实现反压 | AXI-Stream 中间缓冲 |

### 1.3 FIFO 类型对比

| 特性 | 同步 FIFO | 异步 FIFO |
|------|----------|----------|
| **时钟** | 读写共用一个时钟 | 读写使用不同时钟 |
| **指针比较** | 直接比较二进制指针 | 需要格雷码 + 同步器 |
| **满/空判断** | 组合逻辑直接判断 | 跨时钟域同步后判断，延迟 2~3 拍 |
| **复杂度** | 低 | 高（需处理 CDC） |
| **典型应用** | 模块内部缓冲、流水线平衡 | 跨时钟域数据传输 |
| **面积** | 较小 | 较大（额外同步器 + 格雷码逻辑） |
| **最大频率** | 受限于单时钟域 | 两个时钟域可独立优化 |
| **设计风险** | 低 | 高（亚稳态、格雷码错误） |

---

## 2. 同步 FIFO 设计

### 2.1 结构图

```
                写入端                           读出端
               ┌─────┐                         ┌─────┐
  clk ─────────┤     │                         │     │
  rst_n ───────┤     │                         │     │
  wr_en ───────┤  写 ├──▶ wr_ptr               │  读 ├──▶ rd_ptr
  wr_data ─────┤  指 │       │                  │  指 │       │
               │  针 │       ▼                  │  针 │       ▼
               │     │  ┌─────────┐             │     │  ┌─────────┐
               │     │  │ Mem[0]  │             │     │  │ Mem[0]  │
               │     │  │ Mem[1]  │             │     │  │ Mem[1]  │
               │     │  │ ...     │             │     │  │ ...     │
               │     │  │ Mem[N-1]│             │     │  │ Mem[N-1]│
               │     │  └─────────┘             │     │  └─────────┘
               │     │       │                  │     │       │
               │     │       ▼                  │     │       ▼
               │     │   ┌───────┐              │     │   ┌───────┐
               │     │   │满/空  │              │     │   │满/空  │
               │     │   │逻辑   │              │     │   │逻辑   │
               │     │   └───┬───┘              │     │   └───┬───┘
               └─────┘       │                  └─────┘       │
                             ▼                                ▼
                           full                              empty
```

### 2.2 完整实现代码

```systemverilog
module sync_fifo #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 16,
    parameter int ADDR_WIDTH = $clog2(DEPTH)
)(
    input  logic                    clk,
    input  logic                    rst_n,

    // 写端口
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wr_data,
    output logic                    full,

    // 读端口
    input  logic                    rd_en,
    output logic [DATA_WIDTH-1:0]   rd_data,
    output logic                    empty,

    // 状态
    output logic [ADDR_WIDTH:0]     count
);

    //==========================================================
    // 存储阵列
    //==========================================================
    logic [DATA_WIDTH-1:0] mem [DEPTH];

    //==========================================================
    // 读写指针（多一位用于区分满和空）
    //==========================================================
    logic [ADDR_WIDTH:0] wr_ptr;
    logic [ADDR_WIDTH:0] rd_ptr;

    //==========================================================
    // 写指针更新
    //==========================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            wr_ptr <= '0;
        else if (wr_en && !full) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
            wr_ptr <= wr_ptr + 1'b1;
        end
    end

    //==========================================================
    // 读指针更新
    //==========================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rd_ptr <= '0;
        else if (rd_en && !empty)
            rd_ptr <= rd_ptr + 1'b1;
    end

    //==========================================================
    // 读数据输出（组合逻辑读出）
    //==========================================================
    assign rd_data = mem[rd_ptr[ADDR_WIDTH-1:0]];

    //==========================================================
    // 计数器（可选，用于状态监控）
    //==========================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= '0;
        else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10:   count <= count + 1'b1;
                2'b01:   count <= count - 1'b1;
                default: count <= count;  // 2'b00 或 2'b11
            endcase
        end
    end

    //==========================================================
    // 满/空标志
    //==========================================================
    // 满：写指针追上读指针（最高位不同，低位相同）
    assign full  = (wr_ptr == {~rd_ptr[ADDR_WIDTH], rd_ptr[ADDR_WIDTH-1:0]});
    // 空：读指针追上写指针（所有位相同）
    assign empty = (wr_ptr == rd_ptr);

endmodule
```

**设计要点解读：**

| 要点 | 说明 |
|------|------|
| **多一位指针** | 指针宽度 = ADDR_WIDTH + 1，最高位用于区分满和空 |
| **满标志** | `wr_ptr` 和 `rd_ptr` 最高位不同、低位相同 → 写指针绕了一圈追上读指针 |
| **空标志** | `wr_ptr == rd_ptr` → 读指针追上写指针 |
| **组合逻辑读** | `rd_data` 直接由 `mem[rd_ptr]` 输出，读使能仅推进指针 |
| **写保护** | `wr_en && !full` 才写入，满时写入被忽略 |
| **读保护** | `rd_en && !empty` 才读出，空时读出被忽略 |

### 2.3 同步 FIFO 验证代码

```systemverilog
module tb_sync_fifo;

    //==========================================================
    // 参数
    //==========================================================
    parameter int DATA_WIDTH = 32;
    parameter int DEPTH      = 16;
    parameter int CLK_PERIOD = 10;

    //==========================================================
    // 信号
    //==========================================================
    logic                    clk;
    logic                    rst_n;
    logic                    wr_en;
    logic [DATA_WIDTH-1:0]   wr_data;
    logic                    full;
    logic                    rd_en;
    logic [DATA_WIDTH-1:0]   rd_data;
    logic                    empty;
    logic [$clog2(DEPTH):0]  count;

    //==========================================================
    // DUT 实例化
    //==========================================================
    sync_fifo #(
        .DATA_WIDTH (DATA_WIDTH),
        .DEPTH      (DEPTH)
    ) u_fifo (
        .clk      (clk),
        .rst_n    (rst_n),
        .wr_en    (wr_en),
        .wr_data  (wr_data),
        .full     (full),
        .rd_en    (rd_en),
        .rd_data  (rd_data),
        .empty    (empty),
        .count    (count)
    );

    //==========================================================
    // 时钟生成
    //==========================================================
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    //==========================================================
    // 参考模型
    //==========================================================
    logic [DATA_WIDTH-1:0] ref_queue[$];
    int match_cnt   = 0;
    int mismatch_cnt = 0;

    task automatic check_data(input logic [DATA_WIDTH-1:0] actual);
        logic [DATA_WIDTH-1:0] expected;
        if (ref_queue.size() == 0) begin
            $error("[CHECK] Reference queue empty, but got data: 0x%h", actual);
            mismatch_cnt++;
            return;
        end
        expected = ref_queue.pop_front();
        assert (actual === expected) begin
            match_cnt++;
        end else begin
            $error("[CHECK] Data mismatch: expected=0x%h, actual=0x%h", expected, actual);
            mismatch_cnt++;
        end
    endtask

    //==========================================================
    // 辅助任务
    //==========================================================
    task automatic reset();
        rst_n   = 0;
        wr_en   = 0;
        rd_en   = 0;
        wr_data = 0;
        ref_queue.delete();
        repeat(3) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
    endtask

    task automatic write_one(input logic [DATA_WIDTH-1:0] data);
        @(posedge clk);
        wr_en   <= 1;
        wr_data <= data;
        ref_queue.push_back(data);
        @(posedge clk);
        wr_en <= 0;
    endtask

    task automatic read_one();
        @(posedge clk);
        rd_en <= 1;
        @(posedge clk);
        check_data(rd_data);
        rd_en <= 0;
    endtask

    //==========================================================
    // 测试 1: 满标志验证
    //==========================================================
    task test_full_flag();
        $display("\n=== Test 1: Full Flag ===");
        reset();

        // 写满整个 FIFO
        for (int i = 0; i < DEPTH; i++) begin
            @(posedge clk);
            wr_en   <= 1;
            wr_data <= i;
            ref_queue.push_back(i);
        end
        @(posedge clk);
        wr_en <= 0;

        // 检查满标志
        assert (full === 1'b1)
            $display("[PASS] Full flag asserted after %0d writes", DEPTH);
        else
            $error("[FAIL] Full flag not asserted. full=%b, count=%0d", full, count);

        // 满时继续写入（不应改变 FIFO 状态）
        @(posedge clk);
        wr_en   <= 1;
        wr_data <= 32'hDEAD_BEEF;
        @(posedge clk);
        wr_en <= 0;

        assert (full === 1'b1)
            $display("[PASS] Full flag stable after overflow attempt");
        else
            $error("[FAIL] Full flag changed after overflow attempt");

        assert (count === DEPTH)
            $display("[PASS] Count unchanged after overflow attempt");
        else
            $error("[FAIL] Count changed: expected=%0d, actual=%0d", DEPTH, count);

        $display("=== Test 1 Done ===\n");
    endtask

    //==========================================================
    // 测试 2: 空标志验证
    //==========================================================
    task test_empty_flag();
        $display("\n=== Test 2: Empty Flag ===");
        reset();

        // 复位后应为空
        assert (empty === 1'b1)
            $display("[PASS] Empty flag asserted after reset");
        else
            $error("[FAIL] Empty flag not asserted after reset");

        // 写入一个再读出
        write_one(32'hA5A5_A5A5);
        assert (empty === 1'b0)
            $display("[PASS] Empty flag deasserted after write");
        else
            $error("[FAIL] Empty flag still asserted after write");

        read_one();
        assert (empty === 1'b1)
            $display("[PASS] Empty flag asserted after reading all data");
        else
            $error("[FAIL] Empty flag not asserted. empty=%b, count=%0d", empty, count);

        // 空时继续读取（不应改变 FIFO 状态）
        @(posedge clk);
        rd_en <= 1;
        @(posedge clk);
        rd_en <= 0;

        assert (empty === 1'b1)
            $display("[PASS] Empty flag stable after underflow attempt");
        else
            $error("[FAIL] Empty flag changed after underflow attempt");

        assert (count === 0)
            $display("[PASS] Count zero after underflow attempt");
        else
            $error("[FAIL] Count not zero: %0d", count);

        $display("=== Test 2 Done ===\n");
    endtask

    //==========================================================
    // 测试 3: 数据顺序验证（FIFO 特性）
    //==========================================================
    task test_data_order();
        $display("\n=== Test 3: Data Order (FIFO property) ===");
        reset();

        // 写入 N 个递增数据
        for (int i = 0; i < DEPTH; i++) begin
            write_one(i * 32'h0101_0101);
        end

        // 读出并验证顺序
        for (int i = 0; i < DEPTH; i++) begin
            read_one();
        end

        assert (match_cnt == DEPTH)
            $display("[PASS] All %0d data items read in correct FIFO order", DEPTH);
        else
            $error("[FAIL] %0d mismatches in FIFO order check", mismatch_cnt);

        $display("=== Test 3 Done ===\n");
    endtask

    //==========================================================
    // 测试 4: 溢出保护
    //==========================================================
    task test_overflow_protection();
        $display("\n=== Test 4: Overflow Protection ===");
        reset();

        // 写满
        for (int i = 0; i < DEPTH; i++) begin
            @(posedge clk);
            wr_en   <= 1;
            wr_data <= i;
        end
        @(posedge clk);
        wr_en <= 0;

        // 记录当前指针和计数
        logic [$clog2(DEPTH):0] count_before = count;

        // 尝试溢出写入
        repeat(5) begin
            @(posedge clk);
            wr_en   <= 1;
            wr_data <= 32'hFFFF_FFFF;
        end
        @(posedge clk);
        wr_en <= 0;

        // 验证 FIFO 状态未被破坏
        assert (count === count_before)
            $display("[PASS] Count preserved after overflow: %0d", count);
        else
            $error("[FAIL] Count corrupted: before=%0d, after=%0d", count_before, count);

        // 读出所有数据，验证原始数据未被覆盖
        for (int i = 0; i < DEPTH; i++) begin
            @(posedge clk);
            rd_en <= 1;
            @(posedge clk);
            assert (rd_data === i[DATA_WIDTH-1:0])
                $display("[PASS] Data[%0d] = 0x%h preserved", i, rd_data);
            else
                $error("[FAIL] Data[%0d] corrupted: expected=0x%h, got=0x%h",
                       i, i[DATA_WIDTH-1:0], rd_data);
            rd_en <= 0;
        end

        $display("=== Test 4 Done ===\n");
    endtask

    //==========================================================
    // 测试 5: 下溢保护
    //==========================================================
    task test_underflow_protection();
        $display("\n=== Test 5: Underflow Protection ===");
        reset();

        // 不写入任何数据，直接读
        repeat(5) begin
            @(posedge clk);
            rd_en <= 1;
            @(posedge clk);
            rd_en <= 0;
        end

        assert (empty === 1'b1)
            $display("[PASS] Empty flag stable after underflow");
        else
            $error("[FAIL] Empty flag not stable");

        assert (count === 0)
            $display("[PASS] Count zero after underflow");
        else
            $error("[FAIL] Count not zero after underflow");

        // 写入一个数据，验证 FIFO 恢复正常
        write_one(32'hCAFE_BABE);
        assert (empty === 1'b0)
            $display("[PASS] FIFO recovers after write following underflow");
        else
            $error("[FAIL] FIFO not recovering");

        read_one();

        $display("=== Test 5 Done ===\n");
    endtask

    //==========================================================
    // 测试 6: 同时读写
    //==========================================================
    task test_simultaneous_rw();
        $display("\n=== Test 6: Simultaneous Read/Write ===");
        reset();

        // 先写入一半
        for (int i = 0; i < DEPTH/2; i++) begin
            write_one(i);
        end

        // 同时读写
        for (int i = DEPTH/2; i < DEPTH; i++) begin
            @(posedge clk);
            wr_en   <= 1;
            wr_data <= i;
            rd_en   <= 1;
            @(posedge clk);
            wr_en <= 0;
            rd_en <= 0;
        end

        // 计数应保持不变（每拍 +1 -1 = 0）
        assert (count === DEPTH/2)
            $display("[PASS] Count stable during simultaneous R/W: %0d", count);
        else
            $error("[FAIL] Count wrong after simultaneous R/W: %0d", count);

        // 读出剩余数据验证顺序
        while (!empty) begin
            read_one();
        end

        $display("=== Test 6 Done ===\n");
    endtask

    //==========================================================
    // 主测试流程
    //==========================================================
    initial begin
        $display("========================================");
        $display("  Sync FIFO Verification");
        $display("  DEPTH=%0d, DATA_WIDTH=%0d", DEPTH, DATA_WIDTH);
        $display("========================================");

        test_full_flag();
        test_empty_flag();
        test_data_order();
        test_overflow_protection();
        test_underflow_protection();
        test_simultaneous_rw();

        $display("\n========================================");
        $display("  Results: %0d PASS, %0d FAIL", match_cnt, mismatch_cnt);
        $display("========================================");

        if (mismatch_cnt == 0)
            $display("[INFO] All tests PASSED");
        else
            $error("[INFO] Some tests FAILED");

        $finish;
    end

endmodule
```

---

## 3. 异步 FIFO 设计

### 3.1 结构图

异步 FIFO 的核心挑战：读写指针处于不同时钟域，不能直接比较。解决方案是将二进制指针转换为格雷码，再通过同步器跨时钟域传递。

```
  写时钟域 (wr_clk)                    读时钟域 (rd_clk)
  ┌───────────────────────┐            ┌───────────────────────┐
  │                       │            │                       │
  │  wr_en ──┐            │            │            ┌── rd_en  │
  │          ▼            │            │            ▼          │
  │  ┌─────────────┐      │            │      ┌─────────────┐  │
  │  │ wr_ptr_bin  │      │            │      │ rd_ptr_bin  │  │
  │  │ (二进制)    │      │            │      │ (二进制)    │  │
  │  └──────┬──────┘      │            │      └──────┬──────┘  │
  │         │  bin2gray    │            │   bin2gray │          │
  │         ▼             │            │            ▼          │
  │  ┌─────────────┐      │            │      ┌─────────────┐  │
  │  │ wr_ptr_gray │──────┼───sync───▶│─────▶│ wr_ptr_gray │  │
  │  │ (格雷码)    │      │  (2~3拍)  │      │ (同步后)    │  │
  │  └──────┬──────┘      │            │      └──────┬──────┘  │
  │         │             │            │             │          │
  │         ▼             │            │             ▼          │
  │  ┌─────────────┐      │            │      ┌─────────────┐  │
  │  │ 满标志判断  │      │            │      │ 空标志判断  │  │
  │  │ (比较格雷码)│      │            │      │ (比较格雷码)│  │
  │  └──────┬──────┘      │            │      └──────┬──────┘  │
  │         │             │            │             │          │
  │         ▼             │            │             ▼          │
  │       full            │            │           empty        │
  │                       │            │                       │
  │  ┌─────────────────┐  │            │  ┌─────────────────┐  │
  │  │   存储阵列      │◀─┼────────────┼──│   读数据输出    │  │
  │  │   mem[0..N-1]   │  │            │  │   rd_data       │  │
  │  └─────────────────┘  │            │  └─────────────────┘  │
  └───────────────────────┘            └───────────────────────┘

  同步器链:
  wr_ptr_gray ──▶ [FF1] ──▶ [FF2] ──▶ wr_ptr_gray_sync (在rd_clk域)
  rd_ptr_gray ──▶ [FF1] ──▶ [FF2] ──▶ rd_ptr_gray_sync (在wr_clk域)
```

**格雷码的关键性质：** 相邻两个值之间只有 1 位变化。这意味着同步器在采样格雷码指针时，即使采到了中间态，最多导致满/空标志延迟一个周期断言，不会产生错误的指针值。

### 3.2 格雷码转换原理

```
  二进制 → 格雷码转换规则:
  gray[N]   = bin[N]
  gray[N-1] = bin[N] ^ bin[N-1]
  gray[N-2] = bin[N-1] ^ bin[N-2]
  ...
  gray[0]   = bin[1] ^ bin[0]

  例：4位
  十进制  二进制   格雷码
    0      0000     0000
    1      0001     0001     ← 只变1位
    2      0010     0011     ← 只变1位
    3      0011     0010     ← 只变1位
    4      0100     0110     ← 只变1位
    5      0101     0111     ← 只变1位
    6      0110     0101     ← 只变1位
    7      0111     0100     ← 只变1位
    8      1000     1100     ← 只变1位
    9      1001     1101
   10      1010     1111
   11      1011     1110
   12      1100     1010
   13      1101     1011
   14      1110     1001
   15      1111     1000     ← 回绕到0也只有1位变化
```

### 3.3 完整实现代码

```systemverilog
module async_fifo #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 16,
    parameter int ADDR_WIDTH = $clog2(DEPTH),
    parameter int SYNC_STAGES = 2           // 同步器级数，通常2或3
)(
    // 写时钟域
    input  logic                    wr_clk,
    input  logic                    wr_rst_n,
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wr_data,
    output logic                    full,

    // 读时钟域
    input  logic                    rd_clk,
    input  logic                    rd_rst_n,
    input  logic                    rd_en,
    output logic [DATA_WIDTH-1:0]   rd_data,
    output logic                    empty
);

    //==========================================================
    // 存储阵列
    //==========================================================
    logic [DATA_WIDTH-1:0] mem [DEPTH];

    //==========================================================
    // 指针（多一位用于满/空判断）
    //==========================================================
    logic [ADDR_WIDTH:0] wr_ptr_bin;      // 写指针（二进制）
    logic [ADDR_WIDTH:0] wr_ptr_gray;     // 写指针（格雷码）
    logic [ADDR_WIDTH:0] rd_ptr_bin;      // 读指针（二进制）
    logic [ADDR_WIDTH:0] rd_ptr_gray;     // 读指针（格雷码）

    //==========================================================
    // 同步后的指针
    //==========================================================
    logic [ADDR_WIDTH:0] wr_ptr_gray_sync; // 写指针同步到读时钟域
    logic [ADDR_WIDTH:0] rd_ptr_gray_sync; // 读指针同步到写时钟域

    //==========================================================
    // 二进制转格雷码函数
    //==========================================================
    function automatic logic [ADDR_WIDTH:0] bin2gray(
        input logic [ADDR_WIDTH:0] bin
    );
        return bin ^ (bin >> 1);
    endfunction

    //==========================================================
    // 格雷码转二进制函数
    //==========================================================
    function automatic logic [ADDR_WIDTH:0] gray2bin(
        input logic [ADDR_WIDTH:0] gray
    );
        logic [ADDR_WIDTH:0] bin;
        bin[ADDR_WIDTH] = gray[ADDR_WIDTH];
        for (int i = ADDR_WIDTH - 1; i >= 0; i--)
            bin[i] = bin[i+1] ^ gray[i];
        return bin;
    endfunction

    //==========================================================
    // 写指针更新（写时钟域）
    //==========================================================
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_ptr_bin  <= '0;
            wr_ptr_gray <= '0;
        end else if (wr_en && !full) begin
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;
            wr_ptr_bin  <= wr_ptr_bin + 1'b1;
            wr_ptr_gray <= bin2gray(wr_ptr_bin + 1'b1);
        end
    end

    //==========================================================
    // 读指针更新（读时钟域）
    //==========================================================
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_ptr_bin  <= '0;
            rd_ptr_gray <= '0;
        end else if (rd_en && !empty) begin
            rd_ptr_bin  <= rd_ptr_bin + 1'b1;
            rd_ptr_gray <= bin2gray(rd_ptr_bin + 1'b1);
        end
    end

    //==========================================================
    // 读数据输出
    //==========================================================
    assign rd_data = mem[rd_ptr_bin[ADDR_WIDTH-1:0]];

    //==========================================================
    // 同步器：写指针格雷码 → 读时钟域
    //==========================================================
    logic [ADDR_WIDTH:0] wr_ptr_gray_sync_pipe [SYNC_STAGES];

    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            for (int i = 0; i < SYNC_STAGES; i++)
                wr_ptr_gray_sync_pipe[i] <= '0;
        end else begin
            wr_ptr_gray_sync_pipe[0] <= wr_ptr_gray;
            for (int i = 1; i < SYNC_STAGES; i++)
                wr_ptr_gray_sync_pipe[i] <= wr_ptr_gray_sync_pipe[i-1];
        end
    end

    assign wr_ptr_gray_sync = wr_ptr_gray_sync_pipe[SYNC_STAGES-1];

    //==========================================================
    // 同步器：读指针格雷码 → 写时钟域
    //==========================================================
    logic [ADDR_WIDTH:0] rd_ptr_gray_sync_pipe [SYNC_STAGES];

    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            for (int i = 0; i < SYNC_STAGES; i++)
                rd_ptr_gray_sync_pipe[i] <= '0;
        end else begin
            rd_ptr_gray_sync_pipe[0] <= rd_ptr_gray;
            for (int i = 1; i < SYNC_STAGES; i++)
                rd_ptr_gray_sync_pipe[i] <= rd_ptr_gray_sync_pipe[i-1];
        end
    end

    assign rd_ptr_gray_sync = rd_ptr_gray_sync_pipe[SYNC_STAGES-1];

    //==========================================================
    // 满标志（写时钟域判断）
    //==========================================================
    // 满：写指针格雷码与同步后的读指针格雷码
    //     最高2位相反，其余位相同
    assign full = (wr_ptr_gray == {~rd_ptr_gray_sync[ADDR_WIDTH:ADDR_WIDTH-1],
                                   rd_ptr_gray_sync[ADDR_WIDTH-2:0]});

    //==========================================================
    // 空标志（读时钟域判断）
    //==========================================================
    // 空：读指针格雷码与同步后的写指针格雷码完全相同
    assign empty = (rd_ptr_gray == wr_ptr_gray_sync);

endmodule
```

**设计要点解读：**

| 要点 | 说明 |
|------|------|
| **格雷码传递指针** | 保证同步器采样时最多错 1 位，不会产生非法指针值 |
| **同步器级数** | 通常 2 级（延迟 2 拍），高频设计可增加到 3 级 |
| **满标志保守** | 由于同步延迟，满标志可能提前断言（保守），不会漏判 |
| **空标志保守** | 由于同步延迟，空标志可能延迟断言（保守），不会漏判 |
| **独立复位** | 两个时钟域各自有独立的异步复位 |

### 3.4 异步 FIFO 验证代码

```systemverilog
module tb_async_fifo;

    //==========================================================
    // 参数
    //==========================================================
    parameter int DATA_WIDTH = 32;
    parameter int DEPTH      = 16;
    parameter int WR_CLK_PERIOD = 10;   // 100MHz
    parameter int RD_CLK_PERIOD = 7;    // ~143MHz (不同频率)

    //==========================================================
    // 信号
    //==========================================================
    logic                    wr_clk, rd_clk;
    logic                    wr_rst_n, rd_rst_n;
    logic                    wr_en;
    logic [DATA_WIDTH-1:0]   wr_data;
    logic                    full;
    logic                    rd_en;
    logic [DATA_WIDTH-1:0]   rd_data;
    logic                    empty;

    //==========================================================
    // DUT 实例化
    //==========================================================
    async_fifo #(
        .DATA_WIDTH  (DATA_WIDTH),
        .DEPTH       (DEPTH),
        .SYNC_STAGES (2)
    ) u_fifo (
        .wr_clk   (wr_clk),
        .wr_rst_n (wr_rst_n),
        .wr_en    (wr_en),
        .wr_data  (wr_data),
        .full     (full),
        .rd_clk   (rd_clk),
        .rd_rst_n (rd_rst_n),
        .rd_en    (rd_en),
        .rd_data  (rd_data),
        .empty    (empty)
    );

    //==========================================================
    // 时钟生成（不同频率）
    //==========================================================
    initial wr_clk = 0;
    always #(WR_CLK_PERIOD/2) wr_clk = ~wr_clk;

    initial rd_clk = 0;
    always #(RD_CLK_PERIOD/2) rd_clk = ~rd_clk;

    //==========================================================
    // 参考模型与统计
    //==========================================================
    logic [DATA_WIDTH-1:0] ref_queue[$];
    int wr_count = 0;
    int rd_count = 0;
    int match_cnt = 0;
    int mismatch_cnt = 0;

    //==========================================================
    // 复位任务
    //==========================================================
    task automatic reset();
        wr_rst_n = 0;
        rd_rst_n = 0;
        wr_en    = 0;
        rd_en    = 0;
        wr_data  = 0;
        ref_queue.delete();
        wr_count = 0;
        rd_count = 0;
        repeat(5) @(posedge wr_clk);
        wr_rst_n = 1;
        repeat(5) @(posedge rd_clk);
        rd_rst_n = 1;
        // 等待同步器稳定
        repeat(5) @(posedge wr_clk);
    endtask

    //==========================================================
    // 测试 1: 跨时钟域同步验证
    //==========================================================
    task test_cdc_sync();
        $display("\n=== Test 1: CDC Synchronization ===");
        reset();

        // 写入端以 wr_clk 频率写入
        fork
            // 写进程
            begin
                for (int i = 0; i < DEPTH; i++) begin
                    @(posedge wr_clk);
                    wr_en   <= 1;
                    wr_data <= i;
                    ref_queue.push_back(i);
                    wr_count++;
                    @(posedge wr_clk);
                    wr_en <= 0;
                end
            end
            // 读进程（稍后启动）
            begin
                // 等待写入几个数据后开始读
                repeat(DEPTH/2) @(posedge rd_clk);
                for (int i = 0; i < DEPTH; i++) begin
                    @(posedge rd_clk);
                    if (!empty) begin
                        rd_en <= 1;
                        @(posedge rd_clk);
                        rd_en <= 0;
                        rd_count++;
                    end
                end
            end
        join

        // 等待同步器稳定
        repeat(5) @(posedge rd_clk);

        assert (empty === 1'b1)
            $display("[PASS] FIFO empty after all data transferred across CDC");
        else
            $error("[FAIL] FIFO not empty: empty=%b", empty);

        $display("[INFO] Wrote %0d, Read %0d items", wr_count, rd_count);
        $display("=== Test 1 Done ===\n");
    endtask

    //==========================================================
    // 测试 2: 格雷码转换正确性
    //==========================================================
    task test_gray_code();
        $display("\n=== Test 2: Gray Code Conversion ===");
        reset();

        // 通过内部层次引用检查格雷码
        logic [ADDR_WIDTH:0] bin, gray, bin_recovered;

        // 测试所有可能的指针值
        for (int i = 0; i <= DEPTH; i++) begin
            bin = i;
            gray = bin ^ (bin >> 1);  // bin2gray

            // 验证相邻格雷码只差1位
            if (i > 0) begin
                logic [ADDR_WIDTH:0] prev_gray;
                logic [ADDR_WIDTH:0] diff;
                prev_gray = (i-1) ^ ((i-1) >> 1);
                diff = gray ^ prev_gray;
                // diff 应该是2的幂（只有1位为1）
                assert ($countones(diff) == 1)
                    $display("[PASS] Gray[%0d] to Gray[%0d]: diff=%b (1 bit changed)",
                             i-1, i, diff);
                else
                    $error("[FAIL] Gray[%0d] to Gray[%0d]: diff=%b (multiple bits changed!)",
                           i-1, i, diff);
            end
        end

        // 测试回绕（DEPTH-1 → 0 也只差1位）
        begin
            logic [ADDR_WIDTH:0] gray_last, gray_first, diff;
            gray_last  = (DEPTH-1) ^ ((DEPTH-1) >> 1);
            gray_first = 0;
            diff = gray_last ^ gray_first;
            assert ($countones(diff) == 1)
                $display("[PASS] Wrap-around: Gray[%0d] to Gray[0]: diff=%b", DEPTH-1, diff);
            else
                $error("[FAIL] Wrap-around: multiple bits changed: %b", diff);
        end

        $display("=== Test 2 Done ===\n");
    endtask

    //==========================================================
    // 测试 3: 数据完整性（写入多少读出多少，顺序正确）
    //==========================================================
    task test_data_integrity();
        $display("\n=== Test 3: Data Integrity ===");
        reset();

        // 写入随机数据
        fork
            begin
                for (int i = 0; i < 64; i++) begin
                    @(posedge wr_clk);
                    if (!full) begin
                        wr_en   <= 1;
                        wr_data <= $urandom_range(0, 32'hFFFF_FFFF);
                        ref_queue.push_back(wr_data);
                    end else begin
                        wr_en <= 0;
                    end
                    @(posedge wr_clk);
                    wr_en <= 0;
                end
            end
            begin
                // 持续读取
                for (int i = 0; i < 64; i++) begin
                    @(posedge rd_clk);
                    if (!empty) begin
                        rd_en <= 1;
                        @(posedge rd_clk);
                        if (ref_queue.size() > 0) begin
                            logic [DATA_WIDTH-1:0] exp = ref_queue.pop_front();
                            if (rd_data === exp)
                                match_cnt++;
                            else begin
                                $error("[FAIL] Data mismatch: exp=0x%h, act=0x%h", exp, rd_data);
                                mismatch_cnt++;
                            end
                        end
                        rd_en <= 0;
                    end
                end
            end
        join

        // 读出剩余数据
        while (!empty) begin
            @(posedge rd_clk);
            rd_en <= 1;
            @(posedge rd_clk);
            rd_en <= 0;
        end

        $display("[INFO] Matched: %0d, Mismatched: %0d", match_cnt, mismatch_cnt);
        assert (mismatch_cnt == 0)
            $display("[PASS] All data transferred correctly across CDC");
        else
            $error("[FAIL] %0d data mismatches detected", mismatch_cnt);

        $display("=== Test 3 Done ===\n");
    endtask

    //==========================================================
    // 测试 4: 满/空标志在不同时钟域的正确性
    //==========================================================
    task test_full_empty_across_clk();
        $display("\n=== Test 4: Full/Empty Across Clock Domains ===");
        reset();

        // 快速写满（写时钟域）
        while (!full) begin
            @(posedge wr_clk);
            wr_en   <= 1;
            wr_data <= $urandom;
            @(posedge wr_clk);
            wr_en <= 0;
        end

        $display("[INFO] FIFO full asserted in wr_clk domain");

        // 等待空标志在读时钟域同步
        repeat(5) @(posedge rd_clk);
        assert (full === 1'b1)
            $display("[PASS] Full flag stable across CDC");
        else
            $error("[FAIL] Full flag not stable");

        // 读空
        while (!empty) begin
            @(posedge rd_clk);
            rd_en <= 1;
            @(posedge rd_clk);
            rd_en <= 0;
        end

        // 等待空标志稳定
        repeat(5) @(posedge rd_clk);
        assert (empty === 1'b1)
            $display("[PASS] Empty flag stable after draining");
        else
            $error("[FAIL] Empty flag not stable");

        $display("=== Test 4 Done ===\n");
    endtask

    //==========================================================
    // 主测试流程
    //==========================================================
    initial begin
        $display("========================================");
        $display("  Async FIFO Verification");
        $display("  DEPTH=%0d, WR_CLK=%0dns, RD_CLK=%0dns",
                 DEPTH, WR_CLK_PERIOD, RD_CLK_PERIOD);
        $display("========================================");

        test_cdc_sync();
        test_gray_code();
        test_data_integrity();
        test_full_empty_across_clk();

        $display("\n========================================");
        $display("  Results: %0d PASS, %0d FAIL", match_cnt, mismatch_cnt);
        $display("========================================");

        $finish;
    end

    //==========================================================
    // SVA 断言
    //==========================================================

    // 写满后不应继续写入
    property p_no_write_when_full;
        @(posedge wr_clk) disable iff (!wr_rst_n)
        full |-> !wr_en;
    endproperty
    assert property (p_no_write_when_full)
        else $warning("[SVA] Write attempted when full");

    // 读空后不应继续读取
    property p_no_read_when_empty;
        @(posedge rd_clk) disable iff (!rd_rst_n)
        empty |-> !rd_en;
    endproperty
    assert property (p_no_read_when_empty)
        else $warning("[SVA] Read attempted when empty");

endmodule
```

---

## 4. 时隙（Time Slot）

### 4.1 什么是时隙

时隙是异步 FIFO 中数据传输的时间窗口。每个时隙对应一个时钟周期，时隙决定了数据在不同时钟域之间的传输时序关系。

- **时隙是异步 FIFO 中数据传输的时间窗口**
- **每个时隙对应一个时钟周期**
- **时隙决定了数据传输的时序关系**

### 4.2 时隙的重要性

| 重要性 | 说明 |
|--------|------|
| **确保正确采样** | 数据必须在正确的时钟域被采样，否则产生亚稳态 |
| **避免数据丢失** | 时隙错位可能导致写入数据未被读出 |
| **影响性能** | 时隙利用率直接决定 FIFO 的有效吞吐量 |
| **影响可靠性** | 时隙分析是验证异步 FIFO 正确性的关键 |

### 4.3 时隙分析

```
写时钟域                         读时钟域
    |                               |
    v                               v
CLK_WR ___|‾|___|‾|___|‾|___         CLK_RD ___|‾|___|‾|___|‾|___

    时隙1    时隙2    时隙3             时隙1    时隙2    时隙3
    |--------|--------|--------|       |--------|--------|--------|

    写入数据                           读出数据
    [D0]     [D1]     [D2]             [D0]     [D1]     [D2]


异步 FIFO 中的时隙映射（含同步器延迟）:

  wr_clk 时隙:  T1    T2    T3    T4    T5    T6    T7    T8
                 |     |     |     |     |     |     |     |
  写操作:       [W0]  [W1]  [W2]  [W3]  ---   ---   ---   ---
                      |     |     |     |
  同步延迟:          +2    +2    +2    +2   （2拍同步器）
                      |     |     |     |
                      v     v     v     v
  rd_clk 可见:  ---   ---  [W0]  [W1]  [W2]  [W3]  ---   ---
                           |     |     |     |
  读操作:                 ---  [R0]  [R1]  [R2]  [R3]  ---
```

**关键观察：**
- 写入的数据需要经过 2~3 个读时钟周期后才对读端口可见
- 满标志的判断基于"同步后的读指针"，因此会提前断言（保守）
- 空标志的判断基于"同步后的写指针"，因此会延迟断言（保守）

### 4.4 时隙与同步器延迟

同步器引入 2~3 个时钟周期延迟，时隙分析必须考虑这一延迟：

```
同步器延迟对时隙的影响:

  写指针变化:      ──▶ wr_ptr 更新
                        |
  同步器第1拍:         [FF1] ──▶ 亚稳态窗口
                        |
  同步器第2拍:         [FF2] ──▶ 稳定输出
                        |
  读端口可见:          ──▶ wr_ptr_sync 更新

  总延迟 = 同步器级数 × 读时钟周期
  2级同步器: 延迟 = 2 × T_rd
  3级同步器: 延迟 = 3 × T_rd
```

| 同步器级数 | 延迟（读时钟周期） | 亚稳态 MTBF | 适用场景 |
|------------|-------------------|-------------|----------|
| 2 级 | 2 | 中等 | 一般频率设计 |
| 3 级 | 3 | 高 | 高频或高可靠性设计 |
| 4 级 | 4 | 极高 | 极端条件 |

### 4.5 时隙计算

```
写时隙 = 1 / CLK_WR频率
读时隙 = 1 / CLK_RD频率
同步延迟 = 同步器级数 × 读时隙

有效传输率 = 有效时隙 / 总时隙

示例:
  CLK_WR = 100MHz → 写时隙 = 10ns
  CLK_RD = 150MHz → 读时隙 = 6.67ns
  同步器 = 2级   → 同步延迟 = 2 × 6.67ns = 13.34ns

  满标志提前断言量 = 同步延迟 / 写时隙 = 13.34ns / 10ns ≈ 1.3 个写时隙
  → 满标志约提前 1~2 个写时钟周期断言
```

**带宽损失估算：**

```
理想写入带宽 = CLK_WR × DATA_WIDTH
实际写入带宽 = 理想带宽 × (1 - 同步延迟导致的空时隙比例)

示例:
  理想带宽 = 100MHz × 32bit = 3.2 Gbps
  同步延迟空时隙 ≈ 2/16 = 12.5% （FIFO深度16时）
  实际带宽 ≈ 3.2 × 0.875 = 2.8 Gbps
```

### 4.6 时隙验证

```systemverilog
// 时隙验证属性：写使能后，考虑同步延迟，读端口应响应
property time_slot_check;
  @(posedge wr_clk) disable iff (!wr_rst_n)
    $rose(wr_en) |-> 
      ##[2:4] $rose(rd_en);  // 考虑2~4拍同步延迟
endproperty

// 时隙完整性验证：同步后的指针应正确反映空状态
property slot_integrity;
  @(posedge rd_clk) disable iff (!rd_rst_n)
    (rd_ptr_gray == wr_ptr_gray_sync) |-> 
      empty;
endproperty

// 时隙满标志验证：写指针追上同步后的读指针时应断言满
property slot_full_check;
  @(posedge wr_clk) disable iff (!wr_rst_n)
    (wr_ptr_gray == {~rd_ptr_gray_sync[ADDR_WIDTH:ADDR_WIDTH-1],
                     rd_ptr_gray_sync[ADDR_WIDTH-2:0]}) |->
      full;
endproperty

// 时隙连续性验证：连续写入不应丢失数据
property slot_continuity;
  @(posedge wr_clk) disable iff (!wr_rst_n)
    (wr_en && !full) [*DEPTH] |=> 
      full;
endproperty
```

### 4.7 时隙优化策略

| 优化方向 | 具体方法 | 效果 | 代价 |
|----------|----------|------|------|
| **增加时隙利用率** | 减少空闲时隙，持续读写 | 提高吞吐量 | 需要更复杂的流控 |
| **优化同步延迟** | 使用 2 级同步器替代 3 级 | 减少延迟 | 亚稳态风险增加 |
| **平衡读写速率** | 读写时钟频率匹配 | 避免满/空 | 灵活性降低 |
| **使用背压机制** | full/empty 信号反馈给上游 | 防止溢出 | 增加控制复杂度 |
| **增加 FIFO 深度** | 弥补同步延迟的带宽损失 | 更大余量 | 面积增加 |
| **流水线化读写** | 读写操作不占满整个时隙 | 提高频率 | 延迟增加 |

### 4.8 时隙与性能

| 参数 | 影响 | 优化方向 |
|------|------|----------|
| **时隙宽度** | 决定数据传输速率，宽度越小速率越高 | 提高时钟频率 |
| **同步延迟** | 影响响应时间和满/空标志准确性 | 减少同步器级数 |
| **时隙利用率** | 影响吞吐量，空闲时隙降低有效带宽 | 持续读写操作 |
| **时隙对齐** | 影响数据完整性，错位导致数据丢失 | 时钟域设计 |

**性能指标公式：**

```
有效吞吐量 = min(CLK_WR, CLK_RD) × DATA_WIDTH × 时隙利用率

时隙利用率 = (总时隙 - 空闲时隙) / 总时隙

满标志余量 = 同步延迟 / 写时隙 （满标志提前断言的时隙数）
空标志余量 = 同步延迟 / 读时隙 （空标志延迟断言的时隙数）
```

### 4.9 常见时隙问题

| 问题 | 表现 | 原因 | 解决方法 |
|------|------|------|----------|
| **时隙错位** | 数据读出顺序错误 | 读写时隙不对齐 | 检查时钟域设计 |
| **时隙浪费** | 吞吐量低于预期 | 空闲时隙过多 | 优化读写调度 |
| **时隙冲突** | 数据丢失或覆盖 | 同时读写同一时隙 | 增加 FIFO 深度 |
| **时隙延迟** | 响应时间过长 | 同步器延迟过大 | 减少同步器级数 |
| **满标志提前** | 写入带宽降低 | 同步延迟导致保守判断 | 增加深度或减少同步级数 |
| **空标志延迟** | 读出无效数据 | 同步延迟导致判断滞后 | 使用 valid 信号配合 |

### 4.10 时隙验证策略

| 验证方法 | 目标 | 工具/手段 |
|----------|------|-----------|
| **时序仿真** | 验证时隙时序关系 | VCS / Questa + 波形分析 |
| **形式验证** | 检查时隙属性（SVA） | JasperGold / VC Formal |
| **覆盖率** | 覆盖所有时隙场景（满、空、同时读写） | 功能覆盖率模型 |
| **性能分析** | 测量时隙利用率和有效吞吐量 | 性能计数器 + 统计分析 |
| **CDC 验证** | 检查跨时钟域时隙安全性 | Spyglass CDC |

```systemverilog
// 时隙覆盖率模型
covergroup time_slot_cg @(posedge wr_clk);
  // 覆盖各种时隙利用率
  slot_utilization: coverpoint fifo_count {
    bins empty     = {0};
    bins low       = {[1:DEPTH/4]};
    bins medium    = {[DEPTH/4:DEPTH/2]};
    bins high      = {[DEPTH/2:3*DEPTH/4]};
    bins almost_full = {[3*DEPTH/4:DEPTH-1]};
    bins full      = {DEPTH};
  }
  
  // 覆盖同时读写场景
  simultaneous_rw: coverpoint {wr_en, rd_en} {
    bins write_only = {2'b10};
    bins read_only  = {2'b01};
    bins both       = {2'b11};
    bins idle       = {2'b00};
  }
  
  // 覆盖满/空标志切换
  full_transition: coverpoint full {
    bins rise  = (0 => 1);
    bins fall  = (1 => 0);
  }
  empty_transition: coverpoint empty {
    bins rise  = (0 => 1);
    bins fall  = (1 => 0);
  }
endgroup
```

---

## 5. FIFO 验证要点

### 5.1 功能验证 Checklist

| 检查项 | 验证方法 | 优先级 |
|--------|----------|--------|
| **满标志正确性** | 写满后检查 full=1，再写一个检查不变 | P0 |
| **空标志正确性** | 读空后检查 empty=1，再读一个检查不变 | P0 |
| **数据顺序** | 写入递增数据，读出验证顺序一致 | P0 |
| **溢出保护** | 满时写入不改变 FIFO 内容和状态 | P0 |
| **下溢保护** | 空时读取不改变 FIFO 状态 | P0 |
| **同时读写** | 同一拍读写，计数不变，数据正确 | P0 |
| **计数器** | 各种操作下计数器值正确 | P1 |
| **指针回绕** | 指针从最大值回绕到 0，满/空判断正确 | P1 |

### 5.2 时序验证 Checklist

| 检查项 | 验证方法 | 适用类型 |
|--------|----------|----------|
| **建立时间** | 确保写数据在 wr_clk 上升沿前稳定 | 同步/异步 |
| **保持时间** | 确保写数据在 wr_clk 上升沿后保持 | 同步/异步 |
| **时钟偏斜** | 异步 FIFO 中两个时钟域的 skew 分析 | 异步 |
| **亚稳态** | 同步器级数是否足够（MTBF 分析） | 异步 |
| **同步器延迟** | 满/空标志的断言延迟是否可接受 | 异步 |

### 5.3 边界条件 Checklist

| 场景 | 关注点 | 典型 Bug |
|------|--------|----------|
| **满时写入** | 写入被忽略，数据不丢失 | 指针误推进导致数据覆盖 |
| **空时读取** | 读取被忽略，输出不变 | 读出 X 态或旧数据 |
| **同时读写** | 计数不变，满/空标志正确 | 同时读写时满标志误清 |
| **指针回绕** | 最高位翻转，满/空判断正确 | 回绕时满标志计算错误 |
| **复位** | 所有指针、计数、标志归零 | 异步复位释放时的同步问题 |

### 5.4 SVA 断言模块

```systemverilog
module fifo_sva_checker #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 16
)(
    input logic                    clk,
    input logic                    rst_n,
    input logic                    wr_en,
    input logic [DATA_WIDTH-1:0]   wr_data,
    input logic                    full,
    input logic                    rd_en,
    input logic [DATA_WIDTH-1:0]   rd_data,
    input logic                    empty,
    input logic [$clog2(DEPTH):0]  count
);

    //==========================================================
    // 1. 满标志与计数器一致性
    //==========================================================
    property p_full_iff_count_full;
        @(posedge clk) disable iff (!rst_n)
        (full == (count == DEPTH));
    endproperty
    a_full_count: assert property (p_full_iff_count_full)
        else $error("[SVA] full=%b but count=%0d (expected %0d)", full, count, DEPTH);

    //==========================================================
    // 2. 空标志与计数器一致性
    //==========================================================
    property p_empty_iff_count_zero;
        @(posedge clk) disable iff (!rst_n)
        (empty == (count == 0));
    endproperty
    a_empty_count: assert property (p_empty_iff_count_zero)
        else $error("[SVA] empty=%b but count=%0d (expected 0)", empty, count);

    //==========================================================
    // 3. 满和空不能同时为真
    //==========================================================
    property p_not_full_and_empty;
        @(posedge clk) disable iff (!rst_n)
        !(full && empty);
    endproperty
    a_not_both: assert property (p_not_full_and_empty)
        else $error("[SVA] full and empty both asserted!");

    //==========================================================
    // 4. 满时不应写入
    //==========================================================
    property p_no_wr_when_full;
        @(posedge clk) disable iff (!rst_n)
        full |-> !wr_en;
    endproperty
    a_no_wr_full: assert property (p_no_wr_when_full)
        else $warning("[SVA] Write enable asserted when full");

    //==========================================================
    // 5. 空时不应读取
    //==========================================================
    property p_no_rd_when_empty;
        @(posedge clk) disable iff (!rst_n)
        empty |-> !rd_en;
    endproperty
    a_no_rd_empty: assert property (p_no_rd_when_empty)
        else $warning("[SVA] Read enable asserted when empty");

    //==========================================================
    // 6. 计数器边界
    //==========================================================
    property p_count_in_range;
        @(posedge clk) disable iff (!rst_n)
        count <= DEPTH;
    endproperty
    a_count_range: assert property (p_count_in_range)
        else $error("[SVA] Count exceeds DEPTH: %0d", count);

    //==========================================================
    // 7. 计数器变化正确性
    //==========================================================
    property p_count_increment;
        @(posedge clk) disable iff (!rst_n)
        (wr_en && !full && !rd_en) |=> (count == $past(count) + 1);
    endproperty
    a_count_inc: assert property (p_count_increment)
        else $error("[SVA] Count not incremented correctly");

    property p_count_decrement;
        @(posedge clk) disable iff (!rst_n)
        (!wr_en && rd_en && !empty) |=> (count == $past(count) - 1);
    endproperty
    a_count_dec: assert property (p_count_decrement)
        else $error("[SVA] Count not decremented correctly");

    property p_count_stable;
        @(posedge clk) disable iff (!rst_n)
        ((wr_en && !full && rd_en && !empty) ||
         (!wr_en && !rd_en)) |=> (count == $past(count));
    endproperty
    a_count_stable: assert property (p_count_stable)
        else $error("[SVA] Count changed unexpectedly");

endmodule
```

---

## 6. 常见问题及解决

### 6.1 满标志提前断言

**问题：** 异步 FIFO 的满标志比实际满提前几个周期断言，导致写入带宽降低。

**原因：** 同步器延迟（2~3 拍）导致读指针的同步值滞后于实际值，写时钟域看到的"读指针"比真实值小，因此更早判断为满。

**解决思路：**

| 方法 | 说明 | 代价 |
|------|------|------|
| **接受保守设计** | 满标志提前是安全的，不会丢数据 | 写入带宽略有损失 |
| **增加 FIFO 深度** | 多留余量，弥补同步延迟的"假满" | 面积增加 |
| **减少同步器级数** | 从 3 级减到 2 级 | 亚稳态风险增加 |

```
实际 FIFO 使用量 vs 满标志行为：

  使用量
  ┌─────────────────────────────────────
  │                         ████████████ ← 实际满
  │               ██████████
  │     ██████████
  │█████
  └───────────────────────────────────── 时间
       ▲           ▲
       │           │
    实际满      满标志断言（提前）
```

### 6.2 空标志延迟断言

**问题：** 异步 FIFO 的空标志比实际空延迟几个周期才断言，导致读出无效数据。

**原因：** 写指针的同步值滞后，读时钟域看到的"写指针"比真实值小，因此更晚判断为空。

**解决思路：**

| 方法 | 说明 |
|------|------|
| **读端口加 valid 信号** | 用 `!empty` 作为 valid，下游根据 valid 采样 |
| **保守读策略** | 读操作检查 `!empty`，空时不读 |
| **增加 FIFO 深度** | 给同步延迟留余量 |

```systemverilog
// 推荐：读端口带 valid 信号
assign rd_valid = !empty;
// 下游根据 rd_valid 采样 rd_data
```

### 6.3 数据丢失

**问题：** 写入的数据在读出时丢失或被覆盖。

**常见原因：**

| 原因 | 排查方法 |
|------|----------|
| **满判断错误** | 检查格雷码比较逻辑，特别是最高位 |
| **同步器复位不同步** | 确保两个时钟域的复位释放顺序正确 |
| **写指针在满时误推进** | 检查 `wr_en && !full` 条件 |
| **格雷码回绕错误** | 验证 DEPTH 必须是 2 的幂 |
| **亚稳态导致指针错误** | 增加同步器级数或降低频率 |

**关键约束：** FIFO 深度必须是 2 的幂。如果不是，格雷码在回绕时会有多个位同时变化，破坏格雷码的单比特变化特性。

```systemverilog
// 编译时检查深度是否为 2 的幂
initial begin
    assert (DEPTH > 0 && (DEPTH & (DEPTH - 1)) == 0)
        else $error("FIFO DEPTH must be a power of 2, got %0d", DEPTH);
end
```

---

## 7. 实用总结

### 验证工程师速查表

| 检查项 | 方法 | 工具/手段 |
|--------|------|-----------|
| 满/空标志 | 计数器比较 + 边界测试 | SV Testbench + SVA |
| 数据顺序 | FIFO 特性：先写先读 | 参考模型比对 |
| 跨时钟域 | 格雷码 + 同步器 | Spyglass CDC |
| 亚稳态 | MTBF 计算 + 同步器级数 | 手动分析 + 形式验证 |
| 指针回绕 | 深度满写满读 | 边界测试 |
| 同时读写 | 计数不变 + 数据正确 | 并发测试 |

### 同步 vs 异步 FIFO 选择指南

```
需要跨时钟域？
  │
  ├─ 是 → 异步 FIFO（格雷码 + 同步器）
  │
  └─ 同一时钟域
       │
       ├─ 需要缓冲 + 流控 → 同步 FIFO
       │
       └─ 简单寄存器缓冲 → 寄存器组
```

### 常见参数配置参考

| 参数 | 推荐值 | 说明 |
|------|--------|------|
| DEPTH | 16, 32, 64, 128 | 必须是 2 的幂 |
| DATA_WIDTH | 8, 16, 32, 64 | 按数据通路宽度配置 |
| SYNC_STAGES | 2（标准）, 3（高频） | 越多越安全，延迟越大 |

---

## 相关链接

- [[01-SV语法/07-寄存器深入]] - 寄存器时序特性，理解 FIFO 中触发器的行为
- [[05-Verification/03-CDC验证]] - 跨时钟域验证方法论，异步 FIFO 的 CDC 验证策略
- [[01-SV语法/11-握手协议]] - Valid-Ready 握手与 FIFO 流控的结合
- [[01-SV语法/12-流水线设计]] - 流水线中的 FIFO 缓冲应用
- **时隙（Time Slot）** - 见本文第 4 章，异步 FIFO 中数据传输的时间窗口分析
