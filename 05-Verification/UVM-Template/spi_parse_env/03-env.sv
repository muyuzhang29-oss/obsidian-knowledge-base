`ifndef SPI_PARSE_ENV_SV
`define SPI_PARSE_ENV_SV

class spi_parse_env extends uvm_env;
    `uvm_component_utils(spi_parse_env)

    spi_parse_agent       agent;
    spi_parse_scoreboard  scb;
    spi_parse_golden      golden;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent  = spi_parse_agent::type_id::create("agent", this);
        scb    = spi_parse_scoreboard::type_id::create("scb", this);
        golden = spi_parse_golden::type_id::create("golden", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.monitor.rx_ap.connect(scb.rx_imp);
        agent.driver.drv_ap.connect(golden.imp);
        golden.exp_ap.connect(scb.exp_imp);
    endfunction

endclass

`endif
