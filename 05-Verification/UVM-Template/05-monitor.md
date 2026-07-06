---
tags: [UVM, Verification, 妯℃澘, Monitor]
created: 2026-04-17
updated: 2026-06-02
---

# 05 - Monitor 鐩戣鍣?
> 浠?vif 閲囬泦 DUT 杈撳嚭锛屽～鍏?transaction 鐨勮緭鍑哄瓧娈碉紝鍙戦€佺粰 scoreboard

```verilog
`ifndef SPI_MON_SV
`define SPI_MON_SV

class spi_monitor extends uvm_monitor;

    `uvm_component_utils(spi_monitor)

    virtual spi_if vif;
    uvm_analysis_port #(spi_trans) ap;  // 鍙戦€佺粰 scoreboard

    bit [7:0] collected_bytes[$];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("MON", "Failed to get virtual interface")
        end
    endfunction

    // =========================================================================
    // run_phase: 涓诲惊鐜?    // =========================================================================
    virtual task run_phase(uvm_phase phase);
        @(posedge vif.rst_n);

        forever begin
            spi_trans rx_trans;

            wait (vif.mon_cb.cs_n == 1'b0);  // 绛夊緟 transaction 寮€濮?
            rx_trans = spi_trans::type_id::create("rx_trans");
            collect_transaction(rx_trans);     // 閲囬泦 DUT 杈撳嚭
            ap.write(rx_trans);                // 鍙戦€佺粰 scoreboard
        end
    endtask

    // =========================================================================
    // collect_transaction: 閲囬泦 DUT 杈撳嚭锛屽～鍏ヨ緭鍑哄瓧娈?    // =========================================================================
    task collect_transaction(spi_trans tr);
        bit [7:0] addr_byte;
        collected_bytes.delete();

        // 閲囬泦鍦板潃
        collect_byte(addr_byte);
        tr.addr = addr_byte;

        // 閲囬泦杩斿洖鏁版嵁
        while (vif.mon_cb.cs_n == 1'b0) begin
            bit [7:0] data_byte;
            collect_byte(data_byte);
            collected_bytes.push_back(data_byte);
        end

        // 濉叆杈撳嚭瀛楁
        if (collected_bytes.size() > 0) begin
            tr.status_o = collected_bytes[0];
            tr.error_o  = collected_bytes[0][0];
            collected_bytes.pop_front();

            tr.data_o = new[collected_bytes.size()];
            foreach (collected_bytes[i]) begin
                tr.data_o[i] = collected_bytes[i];
            end
        end
    endtask

    task collect_byte(output bit [7:0] data);
        for (int i = 7; i >= 0; i--) begin
            @(posedge vif.clk);
            data[i] = vif.mon_cb.miso;
        end
    endtask

endclass

`endif
```

**monitor 鐨勮亴璐ｏ細** 閲囬泦 DUT 瀹為檯杈撳嚭 鈫?濉叆 `status_o`, `data_o[]`, `error_o` 鈫?鍙戦€佺粰 scoreboard

## 鐩稿叧閾炬帴

- [[05-Verification/UVM-Template/00-鎬昏|UVM 妯℃澘鎬昏]] - UVM 楠岃瘉鐜妯℃澘
- [[02-UVM/06-TLM閫氫俊|TLM 閫氫俊]] - TLM 閫氫俊鏈哄埗
- [[00-鎬荤储寮昡] - 杩斿洖鎬荤储寮?
