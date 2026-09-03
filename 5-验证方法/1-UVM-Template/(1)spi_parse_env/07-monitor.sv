`ifndef SPI_PARSE_MONITOR_SV
`define SPI_PARSE_MONITOR_SV

class spi_parse_monitor extends uvm_monitor;
    `uvm_component_utils(spi_parse_monitor)

    virtual spi_parse_if vif;
    spi_parse_config cfg;
    uvm_analysis_port#(spi_parse_trans) rx_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        rx_ap = new("rx_ap", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual spi_parse_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOIF", "Virtual interface not found")
        end
        if(!uvm_config_db#(spi_parse_config)::get(this, "", "spi_parse_cfg", cfg)) begin
            `uvm_fatal("NOCFG", "monitor cfg not get")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        if(cfg.mod_en != 0) begin
            @(posedge vif.rst_ica_spis_lf_n);
            forever begin
                spi_parse_trans rx_trans;
                rx_trans = spi_parse_trans::type_id::create("rx_trans");
                collect_parse_frame(rx_trans);
                rx_ap.write(rx_trans);
            end
        end
    endtask

    virtual task collect_parse_frame(spi_parse_trans trans);
        trans.o_sub_type       = vif.mon_cb.o_sub_type;
        trans.o_src_addr       = vif.mon_cb.o_src_addr;
        trans.o_dst_addr       = vif.mon_cb.o_dst_addr;
        trans.o_qos            = vif.mon_cb.o_qos;
        trans.o_src_port       = vif.mon_cb.o_src_port;
        trans.o_rw_intv        = vif.mon_cb.o_rw_intv;
        trans.o_rw_intv_ind    = vif.mon_cb.o_rw_intv_ind;
        trans.o_clk_off_ind    = vif.mon_cb.o_clk_off_ind;

        wait(vif.mon_cb.cmd_data_vld_o == 1'b1);
        if(vif.mon_cb.cmd_data_vld_o == 1'b1) begin
            trans.cmd_o.delete();
            while(vif.mon_cb.cmd_data_vld_o == 1'b1) begin
                trans.cmd_o.push_back(vif.mon_cb.cmd_data_o);
                `uvm_info("MON", $sformatf("Trans data == 0x%02h", vif.mon_cb.cmd_data_o), UVM_LOW);
                @(vif.mon_cb);
                if(vif.mon_cb.cmd_data_vld_o == 1'b0) begin
                    break;
                end
            end
        end
        `uvm_info("MON", $sformatf("Trans data num == %0d", trans.cmd_o.size()), UVM_LOW);

        trans.o_plyd_len      = vif.mon_cb.o_plyd_len;
        trans.o_dst_port      = vif.mon_cb.o_dst_port;
        trans.o_op_code       = vif.mon_cb.o_op_code;
        trans.o_ext_len_ind   = vif.mon_cb.o_ext_len_ind;
        trans.o_ext_dat_len_ind = vif.mon_cb.o_ext_dat_len_ind;
        trans.o_rd_dat_len    = vif.mon_cb.o_rd_dat_len;
        trans.o_rmt_addr      = vif.mon_cb.o_rmt_addr;

        wait(vif.mon_cb.ack_data_vld_o == 1'b1);
        if(vif.mon_cb.ack_data_vld_o == 1'b1) begin
            `uvm_info("MON", "Start collecting ack data", UVM_LOW);
            begin : collect_ack
                int idle_cnt = 0;
                const int MAX_IDLE = 20;
                trans.ack_o.delete();
                forever begin
                    @(vif.mon_cb);
                    if(vif.mon_cb.ack_data_vld_o == 1'b1) begin
                        idle_cnt = 0;
                        trans.ack_o.push_back(vif.mon_cb.ack_data_o);
                        `uvm_info("MON", $sformatf("Trans ack data == 0x%02h", vif.mon_cb.ack_data_o), UVM_LOW);
                    end else begin
                        idle_cnt++;
                        if(idle_cnt >= MAX_IDLE) begin
                            break;
                        end
                    end
                end
            end
        end
        `uvm_info("MON", $sformatf("Trans ack data num == %0d", trans.ack_o.size()), UVM_LOW);
    endtask

endclass

`endif
