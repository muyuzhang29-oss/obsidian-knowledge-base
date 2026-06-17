---
tags: [UVM, Verification, 模板, Interface]
created: 2026-04-17
updated: 2026-06-02
---

# 01 - Interface 虚拟接口

> 连接 DUT 和验证环境，所有信号在这里集中定义

```verilog
`ifndef SPI_IF_SV
`define SPI_IF_SV

interface spi_if (
    input logic clk,      // SPI 时钟
    input logic rst_n     // 复位信号
);

    // =========================================================================
    // 信号定义（与 DUT 端口一一对应）
    // =========================================================================

    logic        cs_n;     // 片选（active low）
    logic        sclk;     // SPI 时钟
    logic        mosi;     // Master Out Slave In
    logic        miso;     // Master In Slave Out

    // =========================================================================
    // 控制信号（验证环境内部使用，不连 DUT）
    // =========================================================================

    logic        drv_busy;  // driver 正在驱动
    logic        mon_done;  // monitor 采集完成

    // =========================================================================
    // DUT 输出信号（monitor 采集用）
    // =========================================================================

    logic        dut_ready;     // DUT 就绪
    logic [7:0]  dut_status;    // DUT 状态寄存器
    logic        dut_error;     // DUT 错误标志

    // =========================================================================
    // Clocking Block（定义驱动和采样时序）
    // =========================================================================

    clocking drv_cb @(posedge clk);
        default input #1 output #1;  // 建立时间 1ns，输出延迟 1ns
        output cs_n, sclk, mosi;
        input  miso, dut_ready, dut_status, dut_error;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1 output #1;
        input  cs_n, sclk, mosi, miso;
        input  dut_ready, dut_status, dut_error;
    endclocking

    // =========================================================================
    // Modport（限制各组件对信号的访问方向）
    // =========================================================================

    modport DRV  (clocking drv_cb, input clk, rst_n);
    modport MON  (clocking mon_cb, input clk, rst_n);
    modport DUT  (input cs_n, sclk, mosi, output miso, dut_ready, dut_status, dut_error);

endinterface

`endif
```

**关键点：**
- interface 是 DUT 和验证环境之间的桥梁
- clocking block 定义了信号的驱动和采样时序
- modport 限制了各组件对信号的访问方向（driver 只能驱动，monitor 只能采样）

## 相关链接

- [[05-Verification/UVM-Template/00-总览|UVM 模板总览]] - UVM 验证环境模板
- [[01-SV语法/04-时钟块Clocking-Block|时钟块 Clocking Block]] - 时钟块详解
- [[00-总索引]] - 返回总索引
