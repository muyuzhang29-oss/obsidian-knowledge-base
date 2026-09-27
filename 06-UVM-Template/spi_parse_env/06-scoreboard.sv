`ifndef SPI_PARSE_SCOREBOARD_SV
`define SPI_PARSE_SCOREBOARD_SV

`uvm_analysis_imp_decl(_rx)
`uvm_analysis_imp_decl(_exp)

class spi_parse_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(spi_parse_scoreboard)

    uvm_analysis_imp_rx #(spi_parse_trans, spi_parse_scoreboard) rx_imp;
    uvm_analysis_imp_exp #(spi_parse_trans, spi_parse_scoreboard) exp_imp;

    spi_parse_trans exp_queue[$];

    int pass_count = 0;
    int fail_count = 0;
    int total_count = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rx_imp  = new("rx_imp", this);
        exp_imp = new("exp_imp", this);
    endfunction

    // 接收 monitor 的实际输出
    function void write_rx(spi_parse_trans rx_trans);
        spi_parse_trans exp_trans;
        if(exp_queue.size() == 0) begin
            `uvm_error("SCB", "NO EXP TRANS AVAILABLE");
            fail_count++;
            total_count++;
            return;
        end
        exp_trans = exp_queue.pop_front();
        compare_trans(rx_trans, exp_trans);
    endfunction

    // 接收 golden 的期望输出
    function void write_exp(spi_parse_trans exp_trans);
        exp_queue.push_back(exp_trans);
        `uvm_info("SCB", $sformatf("Got exp trans, queue size=%0d", exp_queue.size()), UVM_LOW);
    endfunction

    function void compare_trans(spi_parse_trans rx, spi_parse_trans exp);
        bit match = 1;
        total_count++;
        if(match) begin
            pass_count++;
            `uvm_info("SCB", $sformatf("PASS[%0d/%0d]", pass_count, total_count), UVM_LOW);
        end else begin
            fail_count++;
            `uvm_error("SCB", $sformatf("FAILED[%0d/%0d]", fail_count, total_count));
        end
    endfunction

endclass

`endif
