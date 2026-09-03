`ifndef SPI_PARSE_IF_SV
`define SPI_PARSE_IF_SV

interface spi_parse_if(input clk_lf, input rst_ica_spis_lf_n);
    logic               mod_en;

    //------------------SPIS_Route <-> SPIS_PSR----------------//
    logic [9:0]         cmd_data_i;
    logic               cmd_data_vld_i;
    logic               cmd_data_rdy_o;

    logic [7:0]         ack_data_o;
    logic               ack_data_vld_o;
    logic               ack_data_rdy_i;

    logic               reg_spis_ctrl_len_ind;
    logic               reg_spis_clk_off_ind;
    logic               reg_spis_rw_intv_ind;
    logic [7:0]         reg_spis_rw_intv;
    logic [2:0]         reg_spis_qos;
    logic [4:0]         reg_src_port;
    logic [5:0]         reg_src_addr;

    //------------------SPIS_PSR <-> I2C SPI ARB----------------//
    logic               i_spis_tout_err;
    logic [7:0]         cmd_data_o;
    logic               cmd_data_vld_o;
    logic               cmd_data_rdy_i;
    logic               cmd_done_flag_o;
    logic               o_cmd_end_flag;

    logic [7:0]         ack_data_i;
    logic               ack_data_vld_i;
    logic               ack_data_rdy_o;

    logic               i_psr_succ;
    logic               i_head_end;
    logic [2:0]         i_op_code;
    logic               i_mp_gen_ack_flag;

    //mp_header
    logic [1:0]         o_sub_type;
    logic [10:0]        o_plyd_len;
    logic [5:0]         o_src_addr;
    logic [5:0]         o_dst_addr;
    logic [2:0]         o_qos;
    logic [4:0]         o_src_port;
    logic [2:0]         o_dst_port;
    logic [2:0]         o_op_code;
    logic [15:0]        o_ext_len_ind;
    logic [5:0]         o_rmt_addr;
    logic [7:0]         o_rw_intv_ind;
    logic [7:0]         o_rw_intv;
    logic               o_clk_off_ind;
    logic [10:0]        o_ext_dat_len_ind;
    logic [10:0]        o_rd_dat_len;

    //------------------top_ctrl reg----------------//
    logic [5:0]         reg_src_addr;
    logic [3:0][5:0]    reg_dst_addr;
    logic [7:0][4:0]    reg_dst_port;

    //------------------I2C/SPI Slave PAL reg----------------//
    logic [1:0]         reg_spis_psr_tout_step;
    logic [7:0]         reg_spis_psr_tout_thrs;
    logic               reg_spis_psr_tout_en;

    logic [5:0]         torg_spis_psr_cstate;
    logic [5:0]         torg_spis_psr_tout_cstate;
    logic               torg_cmd_loc_err;
    logic               torg_cmd_strt_err;
    logic               torg_cmd_len_err;
    logic               torg_spis_psr_tout_err;

    logic [4:0]         drv_state;

    clocking drv_cb @(posedge clk_lf);
        default input #1 output #1;
        output cmd_data_i;
        output cmd_data_vld_i;
        output ack_data_rdy_i;
        output i_spis_tout_err;
        output cmd_data_rdy_i;
        output ack_data_i;
        output ack_data_vld_i;
        output i_psr_succ;
        output i_head_end;
        output i_op_code;
        output drv_state;
        output i_mp_gen_ack_flag;
        input  cmd_data_rdy_o;
    endclocking

    clocking mon_cb @(posedge clk_lf);
        default input #0;
        input cmd_data_rdy_o;
        input cmd_data_o;
        input ack_data_o;
        input ack_data_vld_o;
        input cmd_data_vld_o;
        input cmd_done_flag_o;
        input o_cmd_end_flag;
        input ack_data_rdy_o;
        input o_sub_type;
        input o_plyd_len;
        input o_src_addr;
        input o_dst_addr;
        input o_qos;
        input o_src_port;
        input o_dst_port;
        input o_op_code;
        input o_ext_len_ind;
        input o_rmt_addr;
        input o_rw_intv_ind;
        input o_rw_intv;
        input o_clk_off_ind;
        input o_ext_dat_len_ind;
        input o_rd_dat_len;
        input torg_spis_psr_cstate;
        input torg_spis_psr_tout_cstate;
        input torg_cmd_loc_err;
        input torg_cmd_strt_err;
        input torg_cmd_len_err;
        input torg_spis_psr_tout_err;
    endclocking

    modport drv(clocking drv_cb, input clk_lf, rst_ica_spis_lf_n);
    modport mon(clocking mon_cb, input clk_lf, rst_ica_spis_lf_n);

endinterface

`endif
