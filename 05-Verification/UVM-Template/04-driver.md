---
tags: [UVM, Verification, 妯℃澘, Driver]
created: 2026-04-17
updated: 2026-06-02
---

# 04 - Driver 椹卞姩鍣?
> 灏?transaction 杞崲涓?vif 涓婄殑淇″彿

```verilog
`ifndef SPI_DRV_SV
`define SPI_DRV_SV

class spi_driver extends uvm_driver #(spi_trans);

    `uvm_component_utils(spi_driver)

    virtual spi_if vif;

    uvm_analysis_port #(spi_trans) ap;  // 骞挎挱 transaction 缁?ref_model

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // =========================================================================
    // build_phase: 鑾峰彇铏氭嫙鎺ュ彛
    // =========================================================================
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("DRV", "Failed to get virtual interface")
        end
    endfunction

    // =========================================================================
    // run_phase: 涓诲惊鐜?    // =========================================================================
    virtual task run_phase(uvm_phase phase);
        spi_trans tr;

        vif.drv_cb.cs_n  <= 1'b1;  // CS 榛樿鏃犳晥
        vif.drv_cb.mosi  <= 1'b0;
        vif.drv_busy     <= 1'b0;

        @(posedge vif.rst_n);  // 绛夊緟澶嶄綅閲婃斁

        forever begin
            seq_item_port.get_next_item(tr);  // 浠?sequencer 鑾峰彇 transaction

            `uvm_info("DRV", $sformatf("Driving: cmd=%s addr=0x%02h", tr.cmd.name(), tr.addr), UVM_LOW)

            vif.drv_busy <= 1'b1;

            case (tr.cmd)
                spi_trans::WR_CMD:      drive_write(tr);
                spi_trans::RD_CMD:      drive_read(tr, 0);
                spi_trans::RD_DATA_CMD: drive_read(tr, 1);
                default: `uvm_error("DRV", $sformatf("Unknown cmd: %s", tr.cmd.name()))
            endcase

            vif.drv_busy <= 1'b0;
            ap.write(tr);  // 骞挎挱 transaction 缁?ref_model
            seq_item_port.item_done();  // 閫氱煡 sequencer 瀹屾垚
        end
    endtask

    // =========================================================================
    // drive_write: 椹卞姩鍐欐搷浣?    // =========================================================================
    task drive_write(spi_trans tr);
        vif.drv_cb.cs_n <= 1'b0;
        @(posedge vif.clk);

        drive_byte(tr.addr);  // 鍙戦€佸湴鍧€

        foreach (tr.data[i]) begin
            drive_byte(tr.data[i]);  // 鍙戦€佹暟鎹?        end

        @(posedge vif.clk);
        vif.drv_cb.cs_n <= 1'b1;
        @(posedge vif.clk);
    endtask

    // =========================================================================
    // drive_read: 椹卞姩璇绘搷浣?    // =========================================================================
    task drive_read(spi_trans tr, bit has_write_data);
        vif.drv_cb.cs_n <= 1'b0;
        @(posedge vif.clk);

        drive_byte(tr.addr);

        if (has_write_data) begin
            foreach (tr.data[i]) begin
                drive_byte(tr.data[i]);
            end
        end

        // 璇诲彇鏁版嵁锛堢敱 DUT 椹卞姩 miso锛宮onitor 璐熻矗閲囬泦锛?        repeat (tr.rd_len) begin
            @(posedge vif.clk);
        end

        vif.drv_cb.cs_n <= 1'b1;
        @(posedge vif.clk);
    endtask

    // =========================================================================
    // drive_byte: 閫?bit 椹卞姩涓€涓瓧鑺?    // =========================================================================
    task drive_byte(bit [7:0] data);
        for (int i = 7; i >= 0; i--) begin
            vif.drv_cb.mosi <= data[i];
            @(posedge vif.clk);
        end
    endtask

endclass

`endif
```

**鍏抽敭鐐癸細**
- driver 鍋氫袱浠朵簨锛氭妸 transaction 杞崲涓?vif 淇″彿 + 閫氳繃 ap 骞挎挱缁?ref_model
- 閫氳繃 `get_next_item`/`item_done` 涓?sequencer 浜や簰
- 浣跨敤 clocking block 椹卞姩淇″彿锛坄vif.drv_cb.signal <= value`锛?- driver 涓嶈礋璐ｉ噰闆?DUT 鍝嶅簲锛岄偅鏄?monitor 鐨勪簨
- `item_done()` 涔嬪墠璋冪敤 `ap.write(tr)`锛岀‘淇?ref_model 鏀跺埌杈撳叆婵€鍔?
## 鐩稿叧閾炬帴

- [[05-Verification/UVM-Template/00-鎬昏|UVM 妯℃澘鎬昏]] - UVM 楠岃瘉鐜妯℃澘
- [[02-UVM/04-缁勪欢|UVM 缁勪欢]] - UVM 缁勪欢璇﹁В
- [[00-鎬荤储寮昡] - 杩斿洖鎬荤储寮?
