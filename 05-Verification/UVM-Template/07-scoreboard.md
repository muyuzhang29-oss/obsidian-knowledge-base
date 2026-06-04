---
tags: [UVM, Verification, 模板, Scoreboard]
created: 2026-04-17
updated: 2026-06-02
---

# 07 - Scoreboard 记分板

> 比对 monitor 的实际输出和 ref_model 的期望输出

```systemverilog
`ifndef SPI_SCB_SV
`define SPI_SCB_SV

class spi_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(spi_scoreboard)

    uvm_analysis_imp #(spi_trans, spi_scoreboard) rx_imp;   // 接收 monitor 的实际输出
    uvm_analysis_imp #(spi_trans, spi_scoreboard) exp_imp;  // 接收 ref_model 的期望输出

    spi_trans exp_queue[$];  // 期望 transaction 队列

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
    // write (rx): 接收 monitor 的实际输出，进行比对
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
    // write_exp: 接收 ref_model 的期望输出，放入队列
    // =========================================================================
    function void write_exp(spi_trans exp_trans);
        exp_queue.push_back(exp_trans);
    endfunction

    // =========================================================================
    // compare: 比对输出字段
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
    // report_phase: 打印统计
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

**scb 的职责：** 接收两个 transaction → 比对输出字段 (`status_o`, `data_o[]`, `error_o`)

## 相关链接

- [[05-Verification/UVM-Template/00-总览|UVM 模板总览]] - UVM 验证环境模板
- [[02-UVM/04-组件|UVM 组件]] - UVM 组件详解
- [[00-总索引]] - 返回总索引
