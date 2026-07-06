# 06 - Reference Model 鍙傝€冩ā鍨?
> 鏍规嵁 driver 鐨勮緭鍏?transaction锛岃绠楁湡鏈涜緭鍑猴紝濉叆杈撳嚭瀛楁

```systemverilog
`ifndef SPI_REF_MODEL_SV
`define SPI_REF_MODEL_SV

class spi_ref_model extends uvm_component;

    `uvm_component_utils(spi_ref_model)

    uvm_analysis_port #(spi_trans) exp_ap;  // 鍙戦€佹湡鏈?transaction 缁?scoreboard
    uvm_analysis_imp #(spi_trans, spi_ref_model) imp;  // 鎺ユ敹 driver 鐨勮緭鍏?
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        exp_ap = new("exp_ap", this);
        imp    = new("imp", this);
    endfunction

    // =========================================================================
    // write: 鎺ユ敹杈撳叆 transaction锛岃绠楁湡鏈涜緭鍑猴紝鍙戦€佺粰 scoreboard
    // =========================================================================
    function void write(spi_trans tr);
        spi_trans exp_trans;

        // 鍒涘缓鏈熸湜 transaction
        exp_trans = spi_trans::type_id::create("exp_trans");
        exp_trans.copy(tr);  // 鎷疯礉杈撳叆瀛楁

        // 璁＄畻鏈熸湜杈撳嚭
        compute_expected(exp_trans);

        // 鍙戦€佺粰 scoreboard
        exp_ap.write(exp_trans);
    endfunction

    // =========================================================================
    // compute_expected: 鏍规嵁杈撳叆璁＄畻鏈熸湜杈撳嚭锛堟牳蹇冮€昏緫锛?    // =========================================================================
    function void compute_expected(spi_trans tr);
        case (tr.cmd)
            // 鍐欏懡浠わ細鏈熸湜鍐欐垚鍔燂紝鏃犺繑鍥炴暟鎹?            spi_trans::WR_CMD: begin
                tr.status_o = 8'h00;
                tr.error_o  = 1'b0;
                tr.data_o   = '{};

                if (tr.inject_crc_err) begin
                    tr.status_o = 8'h01;
                    tr.error_o  = 1'b1;
                end
            end

            // 璇诲懡浠わ細鏈熸湜杩斿洖璇绘暟鎹?            spi_trans::RD_CMD: begin
                tr.status_o = 8'h00;
                tr.error_o  = 1'b0;

                tr.data_o = new[tr.rd_len];
                foreach (tr.data_o[i]) begin
                    tr.data_o[i] = tr.addr + i;  // 鏍规嵁 DUT 瀵勫瓨鍣ㄦ槧灏?                end
            end

            // 甯︽暟鎹殑璇伙細鍏堝啓鍚庤
            spi_trans::RD_DATA_CMD: begin
                tr.status_o = 8'h00;
                tr.error_o  = 1'b0;

                tr.data_o = new[tr.rd_len];
                foreach (tr.data_o[i]) begin
                    tr.data_o[i] = (i < tr.data_len) ? tr.data[i] : 8'h00;
                end
            end

            default: begin
                tr.status_o = 8'hFF;
                tr.error_o  = 1'b1;
            end
        endcase
    endfunction

endclass

`endif
```

**ref_model 鐨勮亴璐ｏ細** 璇昏緭鍏ュ瓧娈?鈫?璁＄畻鏈熸湜鍊?鈫?濉叆 `status_o`, `data_o[]`, `error_o` 鈫?鍙戦€佺粰 scoreboard

