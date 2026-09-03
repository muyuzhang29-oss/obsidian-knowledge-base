---
tags: [Verification, CDC, 跨时钟域, 时序, 核心]
created: 2026-06-02
updated: 2026-06-02
---

## 📑 目录

- [CDC概述与重要性](#cdc概述与重要性)
  - [为什么CDC验证至关重要](#为什么cdc验证至关重要)
- [亚稳态问题与MTBF](#亚稳态问题与mtbf)
  - [亚稳态的物理本质](#亚稳态的物理本质)
  - [MTBF计算](#mtbf计算)
  - [关键设计启示](#关键设计启示)
- [同步器设计](#同步器设计)
  - [双触发器同步器（最常用）](#双触发器同步器最常用)
  - [三级触发器同步器](#三级触发器同步器)
  - [同步器设计要点](#同步器设计要点)
- [格雷码编码](#格雷码编码)
  - [原理](#原理)
  - [二进制与格雷码转换](#二进制与格雷码转换)
  - [应用场景](#应用场景)
- [异步FIFO设计](#异步fifo设计)
  - [架构概览](#架构概览)
  - [核心实现](#核心实现)
  - [异步FIFO设计要点](#异步fifo设计要点)
- [脉冲同步器](#脉冲同步器)
  - [问题场景](#问题场景)
  - [方案一：Toggle同步器（最常用）](#方案一togglesync同步器最常用)
  - [方案二：反馈确认同步器](#方案二反馈确认同步器)
- [握手协议同步](#握手协议同步)
  - [适用场景](#适用场景)
  - [req-ack 握手协议](#req-ack-握手协议)
  - [握手时序图](#握手时序图)
- [CDC验证方法](#cdc验证方法)
  - [静态检查（CDC工具分析）](#静态检查cdc工具分析)
  - [动态验证（约束随机测试）](#动态验证约束随机测试)
  - [形式验证](#形式验证)
- [常见CDC错误与案例](#常见cdc错误与案例)
  - [错误1：多位总线逐位同步](#错误1多位总线逐位同步)
  - [错误2：组合逻辑后接同步器](#错误2组合逻辑后接同步器)
  - [错误3：异步复位释放未同步](#错误3异步复位释放未同步)
- [CDC验证工具](#cdc验证工具)
  - [SpyGlass CDC](#spyglass-cdc)
  - [Questa CDC](#questa-cdc)
  - [工具对比](#工具对比)

---

# 03-CDC验证

## CDC概述与重要性

CDC（Clock Domain Crossing，跨时钟域）是指信号从一个时钟域传输到另一个时钟域的过程。在现代SoC设计中，多时钟域架构无处不在——处理器核心、外设接口、DDR控制器、高速SerDes等模块往往运行在不同的时钟频率下。CDC处理不当会导致**亚稳态（Metastability）**，引发功能错误、数据丢失甚至系统崩溃，且这类Bug极其难以复现和调试。

### 为什么CDC验证至关重要

| 风险维度 | 说明 |
|---------|------|
| 功能正确性 | 亚稳态导致数据采样错误，产生随机功能故障 |
| 可靠性 | CDC Bug可能在芯片工作数小时甚至数天后才偶发出现 |
| 调试难度 | 无法在仿真中稳定复现，传统波形调试手段基本失效 |
| 流片风险 | 一旦流片后发现CDC问题，修复成本极高，可能需要重新设计 |

```
时钟域A (clk_a)          时钟域B (clk_b)
    ┌──┐  ┌──┐  ┌──┐         ┌───┐  ┌───┐  ┌───┐
    │  │  │  │  │  │         │   │  │   │  │   │
────┘  └──┘  └──┘  └──       ┘   └──┘   └──┘   └──

    sig_a ──────────────────►  sig_b (?)
                               ↑
                          亚稳态风险点
```

---

## 亚稳态问题与MTBF

### 亚稳态的物理本质

当触发器的输入信号在**建立时间（Setup Time）**和**保持时间（Hold Time）**窗口内发生变化时，触发器无法确定输出是0还是1，进入一个**亚稳态**——输出电压处于逻辑0和逻辑1之间的不确定电平，并在一段时间内震荡后才最终稳定。

```
         tsu  th
          │◄─►│
          ┌───┐
clk  ─────┘   └─────
               ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
data ────────X▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓────────
               ┌──────────────────┐
Q    ──────────┤  亚稳态 (震荡)    ├─────?──
               └──────────────────┘
               │←─ 恢复时间 Tmet ─→│
```

### MTBF计算

MTBF（Mean Time Between Failures，平均故障间隔时间）是衡量CDC可靠性的核心指标：

$$MTBF = \frac{1}{f_{clk} \cdot f_{data} \cdot T_0 \cdot e^{T_{met}/\tau}}$$

其中：
- `f_clk`：采样时钟频率
- `f_data`：数据翻转频率
- `T_0`：与工艺相关的常数（典型值约 0.1~1 ns）
- `T_met`：允许的亚稳态恢复时间（即时钟周期减去组合逻辑延迟和建立时间）
- `τ`：触发器的亚稳态时间常数（典型值约 10~50 ps，取决于工艺）

### 关键设计启示

| 措施 | 对MTBF的影响 |
|------|-------------|
| 增加一级同步触发器 | MTBF指数级提升（e^(T/τ)项增大） |
| 降低时钟频率 | MTBF线性提升 |
| 使用更快的工艺 | τ更小，MTBF指数级提升 |
| 减少跨时钟域信号翻转率 | MTBF线性提升 |

典型数值：双触发器同步器在现代工艺下，MTBF可达数十年甚至数百年；但高频设计（>500MHz）可能需要三级同步器才能满足要求。

---

## 同步器设计

### 双触发器同步器（最常用）

最基本的CDC同步方案，将亚稳态恢复时间扩展到一个完整时钟周期：

```verilog
// 双触发器同步器
module sync_2ff #(
    parameter INIT = 1'b0
)(
    input  logic clk_dst,   // 目标时钟域
    input  logic rst_n,     // 异步复位
    input  logic sig_src,   // 源时钟域信号
    output logic sig_dst    // 同步后的信号
);

    logic sig_meta;  // 第一级：可能进入亚稳态

    always_ff @(posedge clk_dst or negedge rst_n) begin
        if (!rst_n) begin
            sig_meta <= INIT;
            sig_dst  <= INIT;
        end else begin
            sig_meta <= sig_src;   // 第一级采样
            sig_dst  <= sig_meta;  // 第二级稳定输出
        end
    end

endmodule
```

时序波形：

```
clk_dst  ┌┐  ┌┐  ┌┐  ┌┐  ┌┐  ┌┐
         ┘└──┘└──┘└──┘└──┘└──┘└──

sig_src  ──────────────┐
                       │
                       └──────────────

sig_meta ────────────── ┐ ┌──────────
                        ▓▓▓▓  (亚稳态)
                         └──┘

sig_dst  ──────────────────────┐
                               │
                               └──────
                        ↑ 同步延迟 = 2个clk_dst周期
```

### 三级触发器同步器

用于极高频率或对MTBF要求极严的场景（如汽车级ASIL-D功能安全）：

```verilog
// 三级触发器同步器
module sync_3ff #(
    parameter INIT = 1'b0
)(
    input  logic clk_dst,
    input  logic rst_n,
    input  logic sig_src,
    output logic sig_dst
);

    logic sig_meta1, sig_meta2;

    always_ff @(posedge clk_dst or negedge rst_n) begin
        if (!rst_n) begin
            sig_meta1 <= INIT;
            sig_meta2 <= INIT;
            sig_dst   <= INIT;
        end else begin
            sig_meta1 <= sig_src;
            sig_meta2 <= sig_meta1;
            sig_dst   <= sig_meta2;
        end
    end

endmodule
```

### 同步器设计要点

| 要点 | 说明 |
|------|------|
| 同步器必须放在目标时钟域 | 采样端必须用目标时钟驱动 |
| 禁止对同步器输出做组合逻辑 | 会引入新的亚稳态窗口 |
| 复位值应与源信号初始状态一致 | 避免上电后同步器输出错误电平 |
| 综合属性保护 | 添加 `(* ASYNC_REG = "TRUE" *)` 防止综合工具优化 |

```verilog
// Xilinx 风格的异步寄存器声明
(* ASYNC_REG = "TRUE" *)
logic sig_meta, sig_dst;
```

---

## 格雷码编码

### 原理

格雷码（Gray Code）的编码特点是：**相邻两个编码之间仅有1位发生翻转**。这使得在跨时钟域传输多位计数器/地址时，即使采样时刻不精确，最多只有1位出错，错误幅度仅为1。

```
十进制  二进制  格雷码
  0      000     000
  1      001     001
  2      010     011
  3      011     010
  4      100     110
  5      101     111
  6      110     101
  7      111     100
```

### 二进制与格雷码转换

```verilog
// 二进制 → 格雷码
function automatic logic [N-1:0] bin2gray(input logic [N-1:0] bin);
    return bin ^ (bin >> 1);
endfunction

// 格雷码 → 二进制（逐位异或还原）
function automatic logic [N-1:0] gray2bin(input logic [N-1:0] gray);
    logic [N-1:0] bin;
    bin[N-1] = gray[N-1];
    for (int i = N-2; i >= 0; i--)
        bin[i] = bin[i+1] ^ gray[i];
    return bin;
endfunction
```

### 应用场景

格雷码最典型的应用是**异步FIFO的读写指针同步**。将二进制指针转换为格雷码后跨时钟域传输，目标时钟域同步后再转换回二进制。

---

## 异步FIFO设计

### 架构概览

异步FIFO是跨时钟域传输批量数据的标准方案，核心思想是用**双端口RAM**作为共享存储，配合**格雷码指针**和**同步器**实现安全的跨时钟域通信。

```
写时钟域 (wr_clk)                          读时钟域 (rd_clk)
┌──────────────┐                          ┌──────────────┐
│  wr_ptr_gray │──────┐            ┌──────│  rd_ptr_gray │
│  (二进制→格雷)│      │            │      │  (二进制→格雷)│
└──────────────┘      │            │      └──────────────┘
                      ▼            ▼
                 ┌─────────────────────┐
                 │   双端口 RAM        │
                 │   (深度 N)          │
                 └─────────────────────┘
                      │            │
                      ▼            ▼
               ┌──────────┐  ┌──────────┐
               │ 同步器    │  │ 同步器    │
               │ wr→rd域   │  │ rd→wr域   │
               └──────────┘  └──────────┘
                      │            │
                      ▼            ▼
               ┌──────────┐  ┌──────────┐
               │ 满标志    │  │ 空标志    │
               │ (full)   │  │ (empty)  │
               └──────────┘  └──────────┘
```

### 核心实现

```verilog
module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4,       // FIFO深度 = 2^ADDR_WIDTH
    parameter FIFO_DEPTH = 1 << ADDR_WIDTH
)(
    // 写端口
    input  logic                    wr_clk,
    input  logic                    wr_rst_n,
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wr_data,
    output logic                    full,
    // 读端口
    input  logic                    rd_clk,
    input  logic                    rd_rst_n,
    input  logic                    rd_en,
    output logic [DATA_WIDTH-1:0]   rd_data,
    output logic                    empty
);

    // ---------- 存储体 ----------
    logic [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];

    // ---------- 写指针 ----------
    logic [ADDR_WIDTH:0] wr_ptr_bin;      // 多1位用于判满
    logic [ADDR_WIDTH:0] wr_ptr_gray;
    logic [ADDR_WIDTH:0] wr_ptr_gray_sync; // 同步到读时钟域
    logic [ADDR_WIDTH:0] rd_ptr_gray_in_wr; // 读指针同步到写域

    // 写指针递增与格雷码转换
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n)
            wr_ptr_bin <= '0;
        else if (wr_en && !full)
            wr_ptr_bin <= wr_ptr_bin + 1;
    end

    assign wr_ptr_gray = bin2gray(wr_ptr_bin);

    // 写数据
    always_ff @(posedge wr_clk) begin
        if (wr_en && !full)
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;
    end

    // ---------- 读指针 ----------
    logic [ADDR_WIDTH:0] rd_ptr_bin;
    logic [ADDR_WIDTH:0] rd_ptr_gray;

    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n)
            rd_ptr_bin <= '0;
        else if (rd_en && !empty)
            rd_ptr_bin <= rd_ptr_bin + 1;
    end

    assign rd_ptr_gray = bin2gray(rd_ptr_bin);

    // 读数据
    assign rd_data = mem[rd_ptr_bin[ADDR_WIDTH-1:0]];

    // ---------- 同步器 ----------
    // 写指针格雷码 → 读时钟域
    sync_2ff #(.INIT('0)) u_sync_wr2rd (
        .clk_dst(rd_clk), .rst_n(rd_rst_n),
        .sig_src(wr_ptr_gray[ADDR_WIDTH]),
        .sig_dst(wr_ptr_gray_sync[ADDR_WIDTH])
    );
    // (实际实现需对每一位单独同步，此处简化示意)

    // 读指针格雷码 → 写时钟域
    sync_2ff #(.INIT('0)) u_sync_rd2wr (
        .clk_dst(wr_clk), .rst_n(wr_rst_n),
        .sig_src(rd_ptr_gray[ADDR_WIDTH]),
        .sig_dst(rd_ptr_gray_in_wr[ADDR_WIDTH])
    );

    // ---------- 满/空判断 ----------
    // 满：写指针格雷码高位相反，其余位相同
    assign full  = (wr_ptr_gray == {~rd_ptr_gray_in_wr[ADDR_WIDTH:ADDR_WIDTH-1],
                                     rd_ptr_gray_in_wr[ADDR_WIDTH-2:0]});
    // 空：读写指针格雷码完全相同
    assign empty = (rd_ptr_gray == wr_ptr_gray_sync);

endmodule
```

### 异步FIFO设计要点

| 要点 | 说明 |
|------|------|
| 指针宽度 = 地址宽度 + 1 | 多出的1位用于区分满和空 |
| 格雷码同步延迟 | 满/空标志可能"保守"（多报告1~2个），但不会漏报 |
| 复位处理 | 读写指针需同步复位，或使用异步复位同步释放 |
| 深度必须是2的幂 | 格雷码的单比特翻转特性要求深度为2^n |

---

## 脉冲同步器

### 问题场景

当源时钟域的一个**单周期脉冲**需要传递到目标时钟域时，如果直接用双触发器同步，脉冲宽度可能不足一个目标时钟周期，导致目标域**完全采样不到**。

```
clk_src  ┌┐┌┐┌┐┌┐┌┐┌┐┌┐┌┐
         ┘└┘└┘└┘└┘┘└┘└┘└┘└

pulse_src ─┐
           └────────────────  (仅1个clk_src周期宽)

clk_dst     ┌──┐  ┌──┐  ┌──┐
            └──┘  └──┘  └──┘

pulse_dst ────────────────────  (未被采样到!)
```

### 方案一：Toggle同步器（最常用）

源域将脉冲转换为电平翻转，目标域检测翻转边沿：

```verilog
module pulse_sync_toggle (
    input  logic clk_src,
    input  logic rst_n,
    input  logic pulse_src,    // 源域脉冲
    input  logic clk_dst,
    output logic pulse_dst     // 目标域脉冲
);

    // ---------- 源时钟域：脉冲 → 翻转电平 ----------
    logic toggle_src;
    always_ff @(posedge clk_src or negedge rst_n) begin
        if (!rst_n)
            toggle_src <= 1'b0;
        else if (pulse_src)
            toggle_src <= ~toggle_src;
    end

    // ---------- 目标时钟域：同步 + 边沿检测 ----------
    logic toggle_sync, toggle_sync_d;

    sync_2ff #(.INIT(1'b0)) u_sync (
        .clk_dst(clk_dst),
        .rst_n(rst_n),
        .sig_src(toggle_src),
        .sig_dst(toggle_sync)
    );

    always_ff @(posedge clk_dst or negedge rst_n) begin
        if (!rst_n)
            toggle_sync_d <= 1'b0;
        else
            toggle_sync_d <= toggle_sync;
    end

    // 边沿检测：当前值与上一周期不同 → 输出脉冲
    assign pulse_dst = toggle_sync ^ toggle_sync_d;

endmodule
```

时序波形：

```
clk_src     ┌┐┌┐┌┐┌┐┌┐┌┐
            ┘└┘└┘└┘┘└┘└┘└

pulse_src   ─┐
             └──────────────

toggle_src  ──────────┐
                      └────  (电平翻转)

clk_dst         ┌──┐  ┌──┐  ┌──┐  ┌──┐
                └──┘  └──┘  └──┘  └──┘

toggle_sync ───────────────┐  (经过2级同步)
                           └──────

pulse_dst   ───────────────────┐  (边沿检测输出)
                               └──
```

### 方案二：反馈确认同步器

适用于源域需要确认脉冲已被目标域接收的场景（速率更低但更可靠）：

```verilog
module pulse_sync_ack (
    input  logic clk_src, rst_n,
    input  logic pulse_src,
    input  logic clk_dst,
    output logic pulse_dst
);

    logic req_src, ack_src, req_dst;

    // 源域：请求发出 & 等待确认
    always_ff @(posedge clk_src or negedge rst_n) begin
        if (!rst_n)
            req_src <= 1'b0;
        else if (pulse_src)
            req_src <= 1'b1;
        else if (ack_src)
            req_src <= 1'b0;
    end

    // 目标域：同步请求并生成脉冲
    logic req_sync;
    sync_2ff u_sync_req (.clk_dst(clk_dst), .rst_n(rst_n),
                         .sig_src(req_src), .sig_dst(req_sync));

    logic req_sync_d;
    always_ff @(posedge clk_dst or negedge rst_n) begin
        if (!rst_n) req_sync_d <= 1'b0;
        else        req_sync_d <= req_sync;
    end
    assign pulse_dst = req_sync & ~req_sync_d;

    // 回传确认
    sync_2ff u_sync_ack (.clk_dst(clk_src), .rst_n(rst_n),
                         .sig_src(req_sync), .sig_dst(ack_src));

endmodule
```

---

## 握手协议同步

### 适用场景

当需要跨时钟域传输**多位数据总线**且对吞吐量要求不高时，握手协议是比异步FIFO更简单的方案。

### req-ack 握手协议

```
源时钟域                          目标时钟域
┌─────────┐                    ┌─────────┐
│ 数据寄存 │──── data_bus ────►│ 数据寄存 │
│         │                    │         │
│ req发起  │──── req ──[同步]──►│ req检测  │
│         │                    │         │
│ ack接收  │◄──[同步]── ack ───│ ack应答  │
└─────────┘                    └─────────┘
```

```verilog
module handshake_sync #(
    parameter DATA_WIDTH = 8
)(
    // 源端口
    input  logic                    clk_src,
    input  logic                    rst_n,
    input  logic                    valid_src,
    input  logic [DATA_WIDTH-1:0]   data_src,
    output logic                    ready_src,
    // 目标端口
    input  logic                    clk_dst,
    output logic                    valid_dst,
    output logic [DATA_WIDTH-1:0]   data_dst,
    input  logic                    ready_dst
);

    // ---------- 源时钟域 ----------
    logic req_src, ack_src_sync, ack_src_sync_d;
    logic [DATA_WIDTH-1:0] data_reg;

    // 数据锁存：在req发起时锁存数据
    always_ff @(posedge clk_src or negedge rst_n) begin
        if (!rst_n) begin
            req_src <= 1'b0;
            data_reg <= '0;
        end else if (valid_src && ready_src) begin
            req_src <= 1'b1;
            data_reg <= data_src;
        end else if (ack_src_sync && !ack_src_sync_d) begin
            // 检测到ack上升沿，完成握手
            req_src <= 1'b0;
        end
    end

    // ack同步到源域
    logic ack_raw;
    sync_2ff u_sync_ack (.clk_dst(clk_src), .rst_n(rst_n),
                         .sig_src(ack_raw), .sig_dst(ack_src_sync));

    always_ff @(posedge clk_src or negedge rst_n) begin
        if (!rst_n) ack_src_sync_d <= 1'b0;
        else        ack_src_sync_d <= ack_src_sync;
    end

    assign ready_src = !req_src;

    // ---------- 目标时钟域 ----------
    logic req_sync, req_sync_d;

    // req同步到目标域
    sync_2ff u_sync_req (.clk_dst(clk_dst), .rst_n(rst_n),
                         .sig_src(req_src), .sig_dst(req_sync));

    always_ff @(posedge clk_dst or negedge rst_n) begin
        if (!rst_n) req_sync_d <= 1'b0;
        else        req_sync_d <= req_sync;
    end

    // req上升沿 → 输出valid
    logic valid_dst_r;
    always_ff @(posedge clk_dst or negedge rst_n) begin
        if (!rst_n)
            valid_dst_r <= 1'b0;
        else if (req_sync && !req_sync_d)
            valid_dst_r <= 1'b1;
        else if (ready_dst)
            valid_dst_r <= 1'b0;
    end

    assign valid_dst = valid_dst_r;
    assign data_dst  = data_reg;  // 数据在req有效期间稳定

    // ack应答
    always_ff @(posedge clk_dst or negedge rst_n) begin
        if (!rst_n) ack_raw <= 1'b0;
        else        ack_raw <= req_sync;  // 跟随req
    end

endmodule
```

### 握手时序图

```
clk_src   ┌┐┌┐┌┐┌┐┌┐┌┐┌┐┌┐┌┐┌┐
          ┘└┘└┘└┘└┘└┘└┘└┘└┘└┘└┘

valid_src ─┐
           └──────────────────────

req_src   ─────────────────────────┐
                                   └──

clk_dst      ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐
             └──┘  └──┘  └──┘  └──┘  └──┘

req_sync  ──────────────────────────────┐
                                        └──

valid_dst ─────────────────────────────────┐
                                           └──

ack_raw   ──────────────────────────────────┐
                                            └──

ack_sync  ──────────────────────────────────────┐
                                                └──
          │←── 握手延迟 ≈ 2×T_src + 2×T_dst ──→│
```

---

## CDC验证方法

### 静态检查（CDC工具分析）

静态CDC分析是**最核心、最高效**的CDC验证手段，无需仿真即可穷举所有CDC路径。

**检查内容：**

| 检查项 | 说明 |
|--------|------|
| 缺少同步器 | 信号跨越时钟域但未经过同步器 |
| 多位信号独立同步 | 多位总线每位分别同步，导致数据不一致 |
| 组合逻辑后同步 | 同步器前有组合逻辑，可能产生毛刺 |
| 复位同步问题 | 异步复位释放时序不满足恢复/移除时间 |
| 时钟分频器未同步 | 分频器输出跨域未处理 |
| 门控时钟问题 | 门控时钟导致使能信号的CDC问题 |

**典型CDC工具使用流程：**

```tcl
# SpyGlass CDC 流程示例
read_file -type verilog {./rtl/*.sv}
current_design top_module

# 设置时钟
set_option stop {module_name}
clock -name clk_a -period 10
clock -name clk_b -period 15

# 运行CDC分析
run_goal cdc/cdc_verify

# 查看报告
report_goal cdc/cdc_verify -output cdc_report.rpt
```

### 动态验证（约束随机测试）

动态CDC验证通过**注入亚稳态延迟**来模拟真实硬件行为：

```verilog
// CDC验证专用接口：注入随机延迟
interface cdc_if (input logic clk_a, input logic clk_b);
    logic sig_a;
    logic sig_b;

    // 在信号跨域时注入0~1个周期的随机延迟
    clocking cb_src @(posedge clk_a);
        output sig_a;
    endclocking

    // 模拟亚稳态：随机选择采样时刻
    task automatic inject_metastability(ref logic signal);
        randcase
            1: #0;                    // 正常采样
            1: #(0.1ns);              // 轻微延迟
            1: #(0.5ns);              // 接近亚稳态
        endcase
    endtask
endinterface

// CDC验证测试用例
class cdc_random_test extends uvm_test;
    `uvm_component_utils(cdc_random_test)

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        repeat (10000) begin
            // 随机化时钟频率比
            cfg.randomize() with {
                clk_a_period inside {[5:20]};
                clk_b_period inside {[8:30]};
            };

            // 随机化数据模式
            send_random_transaction();

            // 检查CDC数据一致性
            check_cdc_consistency();
        end

        phase.drop_objection(this);
    endtask
endclass
```

### 形式验证

利用形式化方法证明CDC电路的正确性：

```verilog
// 使用SVA验证FIFO空标志的正确性
property p_fifo_empty_correct;
    @(posedge rd_clk) disable iff (!rd_rst_n)
    (rd_ptr_gray == wr_ptr_gray_sync) |-> empty;
endproperty

assert property (p_fifo_empty_correct)
    else `uvm_error("CDC", "FIFO empty flag incorrect!");

// 验证脉冲同步器不会丢失脉冲
property p_pulse_no_loss;
    @(posedge clk_src) disable iff (!rst_n)
    $rose(pulse_src) |-> ##[3:6] $rose(pulse_dst);
    // 脉冲发出后，3~6个目标时钟周期内必须出现输出脉冲
endproperty
```

---

## 常见CDC错误与案例

### 错误1：多位总线逐位同步

**错误写法：**

```verilog
// ❌ 错误：多位数据每位独立同步，可能采样到不同周期的值
logic [3:0] data_src, data_sync1, data_dst;

always_ff @(posedge clk_dst or negedge rst_n) begin
    if (!rst_n) begin
        data_sync1 <= '0;
        data_dst   <= '0;
    end else begin
        data_sync1 <= data_src;  // 4位分别同步
        data_dst   <= data_sync1;
    end
end
```

**问题：** 如果 `data_src` 从 `4'b0111` 变为 `4'b1000`，同步器可能采样到 `4'b0100`、`4'b1110` 等中间态。

**正确方案：**

```verilog
// ✓ 正确：使用异步FIFO、格雷码或握手协议
// 方案1：格雷码（适用于计数器/地址）
// 方案2：异步FIFO（适用于数据流）
// 方案3：握手协议（适用于低速控制信号）
```

### 错误2：组合逻辑后接同步器

```verilog
// ❌ 错误：组合逻辑可能产生毛刺
logic a, b, cdc_in;
assign cdc_in = a & b;  // 组合逻辑输出

sync_2ff u_sync (.clk_dst(clk_dst), .rst_n(rst_n),
                 .sig_src(cdc_in), .sig_dst(cdc_out));

// ✓ 正确：先在源域寄存一拍
logic cdc_in_reg;
always_ff @(posedge clk_src or negedge rst_n) begin
    if (!rst_n) cdc_in_reg <= 1'b0;
    else        cdc_in_reg <= a & b;
end

sync_2ff u_sync (.clk_dst(clk_dst), .rst_n(rst_n),
                 .sig_src(cdc_in_reg), .sig_dst(cdc_out));
```

### 错误3：异步复位释放未同步

```verilog
// ❌ 错误：异步复位释放可能违反恢复/移除时间
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) q <= 1'b0;
    else        q <= d;
end

// ✓ 正确：异步复位同步释放
logic rst_n_sync;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) rst_n_sync <= 1'b0;   // 异步复位
    else        rst_n_sync <= 1'b1;   // 同步释放
end

always_ff @(posedge clk or negedge rst_n_sync) begin
    if (!rst_n_sync) q <= 1'b0;
    else             q <= d;
end
```

### 实际案例：SPI接口CDC问题

```
案例背景：某SoC的SPI Master运行在100MHz，外接Flash运行在50MHz。
         配置寄存器在APB域(25MHz)，直接送到SPI域导致偶发配置错误。

根因：8位配置寄存器[7:0]直接跨域，未做CDC处理。
      配置从0x55变为0xAA时，采样到0x75等中间值。

修复：将配置寄存器改为"写入-握手-更新"机制：
      1. APB域写入配置到影子寄存器
      2. 通过脉冲同步器发送更新请求
      3. SPI域收到请求后，从影子寄存器加载配置
      4. 通过握手协议回传确认
```

---

## CDC验证工具

### SpyGlass CDC

Synopsys的SpyGlass CDC是业界最广泛使用的静态CDC分析工具：

**核心检查规则：**

| 规则ID | 检查内容 | 严重级别 |
|--------|---------|---------|
| CDCR01 | 跨时钟域信号缺少同步器 | Error |
| CDCR02 | 多位信号独立同步 | Error |
| CDCR03 | 同步器前存在组合逻辑 | Warning |
| CDCR04 | 复位信号跨域未同步 | Error |
| CDCR05 | 门控时钟使能信号跨域 | Warning |
| WYSIWYGS | 同步器结构识别 | Info |

**典型使用流程：**

```tcl
# 1. 读入设计
read_file -type sverilog ./rtl/top.sv
current_design top

# 2. 约束设置
set_option enableSV yes
set_option enableV05 yes

# 3. 定义时钟域
clock -name sys_clk -period 10 -domain D1
clock -name usb_clk -period 16.67 -domain D2
clock -name eth_clk  -period 8 -domain D3

# 4. 指定同步器库
set_option lib sync_cells.lib

# 5. 运行分析
run_goal cdc/cdc_abstract -dmsw cdc

# 6. 审阅和waive
# 对确认安全的CDC路径添加waiver
waiver -goal cdc -rule CDCR01 -comment "Confirmed safe toggle sync"
```

### Questa CDC

Siemens EDA的Questa CDC（原0in CDC）集成在Questa验证平台中：

**特点：**
- 与Questa仿真环境深度集成
- 支持形式化CDC验证
- 可与UVM验证平台联动
- 自动识别同步器结构（FF、MUX、RAM等）

```tcl
# Questa CDC 流程
vlog -sv rtl/*.sv
vsim -c -do "cdc_setup.do" work.top

# 运行CDC检查
cdc check -all
cdc report -summary
cdc report -details -output cdc_detail.rpt
```

### 工具对比

| 特性 | SpyGlass CDC | Questa CDC |
|------|-------------|------------|
| 厂商 | Synopsys | Siemens EDA |
| 方法 | 静态分析为主 | 静态 + 形式 |
| 集成度 | 独立工具 | 集成在Questa平台 |
| 同步器识别 | 库匹配 + 自定义 | 自动推断 + 库匹配 |
| 报告质量 | 详细的路径追踪 | 交互式波形回溯 |
| 业界采用 | 最广泛 | 快速增长 |

---

## 相关笔记

- [[04-时钟块Clocking-Block]] - SystemVerilog时钟块与信号采样/驱动时序控制
- [[04-时序问题排查]] - 时序违例与修复方法
- [[00-验证计划]] - 如何在验证计划中纳入CDC测试项
- [[01-覆盖率]] - CDC相关功能覆盖率的定义方法

---

## 参考资源

- Clifford E. Cummings, "Clock Domain Crossing (CDC) Design & Verification Techniques Using SystemVerilog"
- SNUG 2008: "Synthesis and Scripting Techniques for Designing Multi-Asynchronous Clock Designs"
- Cadence: "Clock Domain Crossing (CDC) Verification White Paper"
