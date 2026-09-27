`ifndef SPI_PARSE_AGENT_SV
`define SPI_PARSE_AGENT_SV

class spi_parse_agent extends uvm_agent;
    `uvm_component_utils(spi_parse_agent)

    spi_parse_driver        driver;
    spi_parse_monitor       monitor;
    spi_parse_sequencer     sequencer;

    uvm_analysis_port #(spi_parse_trans) rx_ap;
    uvm_analysis_port #(spi_parse_trans) drv_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor = spi_parse_monitor::type_id::create("monitor", this);
        drv_ap  = new("drv_ap", this);
        rx_ap   = new("rx_ap", this);

        if (get_is_active() == UVM_ACTIVE) begin
            driver = spi_parse_driver::type_id::create("driver", this);
            sequencer = spi_parse_sequencer::type_id::create("sequencer", this);
        end
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (get_is_active() == UVM_ACTIVE) begin
            if (driver != null && sequencer != null) begin
                driver.seq_item_port.connect(sequencer.seq_item_export);
            end
        end
        monitor.rx_ap.connect(rx_ap);
        driver.drv_ap.connect(drv_ap);
    endfunction

endclass

`endif
