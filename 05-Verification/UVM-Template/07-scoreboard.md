---
tags: [UVM, Verification, 妯℃澘, Scoreboard]
created: 2026-04-17
updated: 2026-06-02
---

# 07 - Scoreboard 璁板垎鏉?
> 姣斿 monitor 鐨勫疄闄呰緭鍑哄拰 ref_model 鐨勬湡鏈涜緭鍑?
```verilog
`ifndef SPI_SCB_SV
`define SPI_SCB_SV

class spi_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(spi_scoreboard)

    uvm_analysis_imp #(spi_trans, spi_scoreboard) rx_imp;   // 鎺ユ敹 monitor 鐨勫疄闄呰緭鍑?    uvm_analysis_imp #(spi_trans, spi_scoreboard) exp_imp;  // 鎺ユ敹 ref_model 鐨勬湡鏈涜緭鍑?
    spi_trans exp_queue[$];  // 鏈熸湜 transaction 闃熷垪

    int pass_count = 0;
    int fail_count = 0;
    int total_count = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rx_imp  = new("rx_imp",  this);
        exp_imp = new("exp_imp", this);
    endfunction

    // =========================================================================
    // write (rx): 鎺ユ敹 monitor 鐨勫疄闄呰緭鍑猴紝杩涜姣斿
    // =========================================================================
    function void write(spi_trans rx_trans);
        spi_trans exp_trans;

        if (exp_queue.size() == 0) begin
            `uvm_error("SCB", "No expected transaction available!")
            fail_count++;
            total_count++;
            return;
        end

        exp_trans = exp_queue.pop_front();
        compare(rx_trans, exp_trans);
    endfunction

    // =========================================================================
    // write_exp: 鎺ユ敹 ref_model 鐨勬湡鏈涜緭鍑猴紝鏀惧叆闃熷垪
    // =========================================================================
    function void write_exp(spi_trans exp_trans);
        exp_queue.push_back(exp_trans);
    endfunction

    // =========================================================================
    // compare: 姣斿杈撳嚭瀛楁
    // =========================================================================
    function void compare(spi_trans rx, spi_trans exp);
        bit match = 1;
        total_count++;

        if (rx.status_o !== exp.status_o) begin
            `uvm_error("SCB", $sformatf("status_o mismatch: rx=0x%02h exp=0x%02h",
                       rx.status_o, exp.status_o))
            match = 0;
        end

        if (rx.error_o !== exp.error_o) begin
            `uvm_error("SCB", $sformatf("error_o mismatch: rx=%0d exp=%0d",
                       rx.error_o, exp.error_o))
            match = 0;
        end

        if (rx.data_o.size() !== exp.data_o.size()) begin
            `uvm_error("SCB", $sformatf("data_o size mismatch: rx=%0d exp=%0d",
                       rx.data_o.size(), exp.data_o.size()))
            match = 0;
        end else begin
            foreach (rx.data_o[i]) begin
                if (rx.data_o[i] !== exp.data_o[i]) begin
                    `uvm_error("SCB", $sformatf("data_o[%0d] mismatch: rx=0x%02h exp=0x%02h",
                               i, rx.data_o[i], exp.data_o[i]))
                    match = 0;
                end
            end
        end

        if (match) begin
            pass_count++;
            `uvm_info("SCB", $sformatf("PASS [%0d/%0d]", pass_count, total_count), UVM_LOW)
        end else begin
            fail_count++;
            `uvm_error("SCB", $sformatf("FAIL [%0d/%0d]", fail_count, total_count))
        end
    endfunction

    // =========================================================================
    // report_phase: 鎵撳嵃缁熻
    // =========================================================================
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCB", "========================================", UVM_LOW)
        `uvm_info("SCB", $sformatf("  Total:  %0d", total_count), UVM_LOW)
        `uvm_info("SCB", $sformatf("  Pass:   %0d", pass_count), UVM_LOW)
        `uvm_info("SCB", $sformatf("  Fail:   %0d", fail_count), UVM_LOW)
        `uvm_info("SCB", "========================================", UVM_LOW)
    endfunction

endclass

`endif
```

**scb 鐨勮亴璐ｏ細** 鎺ユ敹涓や釜 transaction 鈫?姣斿杈撳嚭瀛楁 (`status_o`, `data_o[]`, `error_o`)

## 鐩稿叧閾炬帴

- [[05-Verification/UVM-Template/00-鎬昏|UVM 妯℃澘鎬昏]] - UVM 楠岃瘉鐜妯℃澘
- [[02-UVM/04-缁勪欢|UVM 缁勪欢]] - UVM 缁勪欢璇﹁В
- [[00-鎬荤储寮昡] - 杩斿洖鎬荤储寮?
