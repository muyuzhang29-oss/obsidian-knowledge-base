`ifndef SPI_PARSE_DRIVER_SV
`define SPI_PARSE_DRIVER_SV

class spi_parse_driver extends uvm_driver#(spi_parse_trans);
    `uvm_component_utils(spi_parse_driver)

    virtual spi_parse_if vif;
    spi_parse_config cfg;
    spi_parse_trans trans;

    uvm_analysis_port #(spi_parse_trans) drv_ap;

    typedef enum logic [4:0] {
        DRV_IDLE      = 5'd0,
        DRV_CMD       = 5'd1,
        DRV_ADDR      = 5'd2,
        DRV_RDC       = 5'd3,
        DRV_DATA_LEN  = 5'd4,
        DRV_PAYLOAD   = 5'd5,
        DRV_DATA      = 5'd6,
        DRV_MST_RX_DATA = 5'd7,
        DRV_DUMMY     = 5'd8,
        DRV_RD_DATA   = 5'd9,
        DRV_RD_DATA_CRC = 5'd10
    } drv_state_e;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv_ap = new("drv_ap", this);
        if (!uvm_config_db#(virtual spi_parse_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOIF", "Virtual interface not found")
        end
        if (!uvm_config_db#(spi_parse_config)::get(this, "", "spi_parse_cfg", cfg)) begin
            `uvm_fatal("NOCFG", "driver cfg not get")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        @(posedge vif.rst_ica_spis_lf_n);
        init_single();
        repeat(10) @(posedge vif.clk_lf);
        fork
            begin
                driver_loop();
            end
            begin
                reset_signals();
            end
        join
    endtask

    virtual task driver_loop();
        int step = 0;
        int trans_id = 0;
        forever begin
            seq_item_port.get_next_item(trans);
            drv_ap.write(trans);
            `uvm_info("DRV", $sformatf("=====TRANS_ID = %0d=====", trans_id++), UVM_LOW);

            vif.drv_cb.drv_state <= DRV_IDLE;
            `uvm_info("DRV", $sformatf("STEP %0d:DRIVE FRAME", step++), UVM_LOW);

            drive_spi_parse_frame(trans);

            seq_item_port.item_done();
        end
    endtask

    virtual task init_single();
        vif.drv_cb.cmd_data_i      <= 10'b0;
        vif.drv_cb.cmd_data_vld_i  <= 1'b0;
        vif.drv_cb.ack_data_rdy_i  <= 1'b0;
        vif.drv_cb.drv_state       <= DRV_IDLE;
        vif.drv_cb.i_spis_tout_err <= 1'b0;
        vif.drv_cb.cmd_data_rdy_i  <= 1'b0;
        vif.drv_cb.ack_data_i      <= 8'b0;
        vif.drv_cb.ack_data_vld_i  <= 1'b0;
        vif.drv_cb.i_psr_succ      <= 1'b0;
        vif.drv_cb.i_head_end      <= 1'b0;
        vif.drv_cb.i_op_code       <= 3'b0;
    endtask

    virtual task reset_signals();
        forever begin
            @(negedge vif.rst_ica_spis_lf_n);
            `uvm_info("DRV", "reset start", UVM_LOW);
            vif.drv_cb.cmd_data_i      <= 10'b0;
            vif.drv_cb.cmd_data_vld_i  <= 1'b0;
            vif.drv_cb.ack_data_rdy_i  <= 1'b0;
            vif.drv_cb.drv_state       <= DRV_IDLE;
            vif.drv_cb.i_spis_tout_err <= 1'b0;
            vif.drv_cb.cmd_data_rdy_i  <= 1'b0;
            vif.drv_cb.ack_data_i      <= 8'b0;
            vif.drv_cb.ack_data_vld_i  <= 1'b0;
            vif.drv_cb.i_psr_succ      <= 1'b0;
            vif.drv_cb.i_head_end      <= 1'b0;
            vif.drv_cb.i_op_code       <= 3'b0;
        end
    endtask

    virtual task drive_spi_parse_frame(spi_parse_trans trans);
        int byte_cnt = 0;
        int frame_len;

        vif.drv_cb.cmd_data_rdy_i <= 1'b1;
        vif.drv_cb.i_spis_tout_err <= 1'b0;
        vif.drv_cb.cmd_data_vld_i <= 1'b1;

        @(posedge vif.clk_lf);
        if(vif.drv_cb.i_spis_tout_err == 1'b0) begin
            drive_bytes(trans.cmd, DRV_CMD);
            `uvm_info("DRV", $sformatf("CMD == 0x%03h", trans.cmd), UVM_LOW);

            drive_bytes(trans.addr, DRV_ADDR);
            `uvm_info("DRV", $sformatf("ADDR == 0x%03h", trans.addr), UVM_LOW);

            drive_bytes(trans.rdc, DRV_RDC);
            `uvm_info("DRV", $sformatf("RDC == 0x%03h", trans.rdc), UVM_LOW);

            if(cfg.reg_spis_ctrl_len_ind == 1'b1) begin
                drive_bytes(trans.data_len_h, DRV_DATA_LEN);
                drive_bytes(trans.data_len_l, DRV_DATA_LEN);
            end else begin
                drive_bytes(trans.data_len_l, DRV_DATA_LEN);
            end
            `uvm_info("DRV", $sformatf("DATA_LEN == 0x%03h", trans.data_len_l), UVM_LOW);

            case(trans.cmd[4:3])
                2'b01: begin // WRITE
                    if(cfg.reg_spis_ctrl_len_ind == 1'b1) begin
                        for(int i=0;i<{trans.data_len_h[2:0],trans.data_len_l[7:0]};i++) begin
                            drive_bytes(trans.payload[i], DRV_DATA);
                            `uvm_info("DRV", $sformatf("DATA == 0x%03h", trans.payload[i]), UVM_LOW);
                        end
                    end else begin
                        for(int i=0;i<trans.data_len_l[7:0];i++) begin
                            drive_bytes(trans.payload[i], DRV_DATA);
                            `uvm_info("DRV", $sformatf("DATA == 0x%03h", trans.payload[i]), UVM_LOW);
                        end
                    end
                end
                2'b10 : begin // RD_CMD
                    if(trans.rdc[7] == 1'b1) begin
                        for(int i=0;i<={trans.rdc[6:0]};i++) begin
                            drive_bytes(trans.payload_rd[i], DRV_DATA);
                        end
                    end else begin
                        drive_bytes(trans.data_len_l, DRV_DATA_LEN);
                    end
                end
                2'b11 : begin // RD_DATA
                end
                default: `uvm_error("DRV_ERR", "UNVALID RW")
            endcase
            @(posedge vif.clk_lf);
            vif.drv_cb.cmd_data_vld_i <= 1'b0;
            repeat(10) @(posedge vif.clk_lf);

            repeat(2) @(posedge vif.clk_lf);
            vif.i_mp_gen_ack_flag <= 1'b1;
            repeat(2) @(posedge vif.clk_lf);
            vif.i_mp_gen_ack_flag <= 1'b0;

            vif.i_head_end <= 1'b1;
        end

        vif.i_psr_succ <= 1'b1;
        vif.i_op_code <= trans.i_op_code;
        @(posedge vif.clk_lf);
        vif.i_head_end <= 1'b0;

        //////////////////////////ACK////////////////////////
        vif.ack_data_vld_i <= 1'b1;
        vif.ack_data_rdy_i <= 1'b1;
        for(int i=0;i<trans.payload_rsp.size();i++) begin
            vif.ack_data_i = trans.payload_rsp[i];
            `uvm_info("DRV ACK", $sformatf("ack_data = 0x%02h", trans.payload_rsp[i]), UVM_LOW);
            @(posedge vif.clk_lf);
        end
        vif.ack_data_vld_i <= 1'b0;
    endtask

    virtual task drive_bytes(input bit[9:0] data_i, input bit[3:0] state);
        vif.drv_cb.cmd_data_vld_i <= 1'b1;
        vif.drv_cb.drv_state <= state;
        vif.drv_cb.cmd_data_i <= data_i;
        do begin
            @(posedge vif.clk_lf);
        end while (vif.cmd_data_rdy_o == 1'b0);
        vif.drv_cb.cmd_data_vld_i <= 1'b0;
    endtask

endclass
`endif
