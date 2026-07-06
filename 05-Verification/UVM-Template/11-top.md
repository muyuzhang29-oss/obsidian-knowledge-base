---
tags: [UVM, Verification, 妯℃澘, TopModule]
created: 2026-04-17
updated: 2026-06-02
---

# 11 - Top 椤跺眰妯″潡

> 浠跨湡鍣ㄥ叆鍙ｏ紝渚嬪寲 DUT + interface锛屽惎鍔?UVM

```verilog
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
    // 鏃堕挓鍜屽浣?    // =========================================================================
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
    // interface 渚嬪寲
    // =========================================================================
    spi_if spi_intf (
        .clk   (clk),
        .rst_n (rst_n)
    );

    // =========================================================================
    // DUT 渚嬪寲
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
    // 灏?virtual interface 鏀惧叆 config_db
    // =========================================================================
    initial begin
        uvm_config_db#(virtual spi_if)::set(null, "uvm_test_top.env.agent.*", "vif", spi_intf);
    end

    // =========================================================================
    // 鍚姩 UVM
    // =========================================================================
    initial begin
        run_test("spi_base_test");  // 涔熷彲鐢?+UVM_TESTNAME=xxx 鍛戒护琛屾寚瀹?    end

    // =========================================================================
    // 娉㈠舰杈撳嚭锛堝彲閫夛級
    // =========================================================================
    initial begin
        $fsdbDumpfile("wave.fsdb");
        $fsdbDumpvars(0, tb_top);
    end

    // =========================================================================
    // 瓒呮椂淇濇姢锛堝彲閫夛級
    // =========================================================================
    initial begin
        #1000000;
        `uvm_fatal("TOP", "Simulation timeout!")
    end

endmodule

`endif
```

**鍏抽敭鐐癸細**
- top 鏄豢鐪熷櫒鍏ュ彛锛屼緥鍖?interface 鍜?DUT 骞惰繛鎺?- 閫氳繃 `config_db#(virtual spi_if)::set` 浼犻€掕櫄鎷熸帴鍙?- `run_test()` 鐨勫弬鏁版槸 test 绫诲悕锛屼篃鍙敤 `+UVM_TESTNAME=xxx` 鍛戒护琛屾寚瀹?
## 鐩稿叧閾炬帴

- [[05-Verification/UVM-Template/00-鎬昏|UVM 妯℃澘鎬昏]] - UVM 楠岃瘉鐜妯℃澘
- [[02-UVM/02-config_db|config_db]] - UVM 閰嶇疆鏈哄埗
- [[00-鎬荤储寮昡] - 杩斿洖鎬荤储寮?
