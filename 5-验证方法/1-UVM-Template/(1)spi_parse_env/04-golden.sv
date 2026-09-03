`ifndef SPI_PARSE_GOLDEN_SV
`define SPI_PARSE_GOLDEN_SV

class spi_parse_golden extends uvm_component;
    `uvm_component_utils(spi_parse_golden)

    spi_parse_config cfg;
    uvm_analysis_port#(spi_parse_trans) exp_ap;
    uvm_analysis_imp#(spi_parse_trans, spi_parse_golden) imp;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        exp_ap = new("exp_ap", this);
        imp    = new("imp", this);
        if(!uvm_config_db#(spi_parse_config)::get(this, "", "spi_parse_cfg", cfg))begin
            `uvm_fatal("NOCFG", "monitor cfg not get")
        end
    endfunction

    function void write(spi_parse_trans tr);
        spi_parse_trans exp_trans;
        `uvm_info("GOLDEN","write() called",UVM_LOW);

        exp_trans = spi_parse_trans::type_id::create("exp_trans");
        exp_trans.copy(tr);
        compute_expected(exp_trans);
        exp_ap.write(exp_trans);
    endfunction

    function void compute_expected(spi_parse_trans tr);
        `uvm_info("GOLDEN","COMPUTE_EXPECTED() called",UVM_LOW);

        tr.o_src_addr      = cfg.reg_src_addr;
        tr.o_src_port      = cfg.reg_src_port;
        tr.o_qos           = cfg.reg_spis_qos;
        tr.o_rw_intv       = cfg.reg_spis_rw_intv;
        tr.o_rw_intv_ind   = cfg.reg_spis_rw_intv_ind;
        tr.o_ext_dat_len_ind = cfg.reg_spis_ctrl_len_ind;

        case(tr.cmd[4:3])
            2'b00:begin
                tr.cmd_o = ;
                tr.ack_o = ;
            end
            2'b01:begin
            end
            2'b10:begin
            end
            2'b11:begin
            end
            default:begin
            end
        endcase
    endfunction

endclass

`endif
