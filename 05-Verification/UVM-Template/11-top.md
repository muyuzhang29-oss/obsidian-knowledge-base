---
tags: [UVM, Verification, 模板, TopModule]
created: 2026-04-17
updated: 2026-06-02
---

# 11 - Top 顶层模块

> 仿真器入口，例化 DUT + interface，启动 UVM

```systemverilog
`ifndef TB_TOP_SV
`define TB_TOP_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "spi_config.sv"
`include "spi_trans.sv"
`include "spi_sequencer.sv"
`include "spi_driver.sv"
`include "spi_monitor.sv"
`include "spi_ref_model.sv"
`include "spi_scoreboard.sv"
`include "spi_agent.sv"
`include "spi_env.sv"
`include "spi_sequence.sv"
`include "spi_test.sv"

module tb_top;

    // =========================================================================
    // 时钟和复位
    // =========================================================================
    logic clk;
    logic rst_n;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz
    end

    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
    end

    // =========================================================================
    // interface 例化
    // =========================================================================
    spi_if spi_intf (
        .clk   (clk),
        .rst_n (rst_n)
    );

    // =========================================================================
    // DUT 例化
    // =========================================================================
    spi_slave dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .cs_n      (spi_intf.cs_n),
        .sclk      (spi_intf.sclk),
        .mosi      (spi_intf.mosi),
        .miso      (spi_intf.miso),
        .dut_ready (spi_intf.dut_ready),
        .dut_status(spi_intf.dut_status),
        .dut_error (spi_intf.dut_error)
    );

    // =========================================================================
    // 将 virtual interface 放入 config_db
    // =========================================================================
    initial begin
        uvm_config_db#(virtual spi_if)::set(null, "uvm_test_top.env.agent.*", "vif", spi_intf);
    end

    // =========================================================================
    // 启动 UVM
    // =========================================================================
    initial begin
        run_test("spi_base_test");  // 也可用 +UVM_TESTNAME=xxx 命令行指定
    end

    // =========================================================================
    // 波形输出（可选）
    // =========================================================================
    initial begin
        $fsdbDumpfile("wave.fsdb");
        $fsdbDumpvars(0, tb_top);
    end

    // =========================================================================
    // 超时保护（可选）
    // =========================================================================
    initial begin
        #1000000;
        `uvm_fatal("TOP", "Simulation timeout!")
    end

endmodule

`endif
```

**关键点：**
- top 是仿真器入口，例化 interface 和 DUT 并连接
- 通过 `config_db#(virtual spi_if)::set` 传递虚拟接口
- `run_test()` 的参数是 test 类名，也可用 `+UVM_TESTNAME=xxx` 命令行指定

## 相关链接

- [[05-Verification/UVM-Template/00-总览|UVM 模板总览]] - UVM 验证环境模板
- [[02-UVM/02-config_db|config_db]] - UVM 配置机制
- [[00-总索引]] - 返回总索引
