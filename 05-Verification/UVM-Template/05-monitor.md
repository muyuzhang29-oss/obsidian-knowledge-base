---
tags: [UVM, Verification, 模板, Monitor]
created: 2026-04-17
updated: 2026-06-02
---

# 05 - Monitor 监视器

> 从 vif 采集 DUT 输出，填入 transaction 的输出字段，发送给 scoreboard

```verilog
`ifndef SPI_MON_SV
`define SPI_MON_SV

class spi_monitor extends uvm_monitor;

    `uvm_component_utils(spi_monitor)

    virtual spi_if vif;
    uvm_analysis_port #(spi_trans) ap;  // 发送给 scoreboard

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
    // run_phase: 主循环
    // =========================================================================
    virtual task run_phase(uvm_phase phase);
        @(posedge vif.rst_n);

        forever begin
            spi_trans rx_trans;

            wait (vif.mon_cb.cs_n == 1'b0);  // 等待 transaction 开始

            rx_trans = spi_trans::type_id::create("rx_trans");
            collect_transaction(rx_trans);     // 采集 DUT 输出
            ap.write(rx_trans);                // 发送给 scoreboard
        end
    endtask

    // =========================================================================
    // collect_transaction: 采集 DUT 输出，填入输出字段
    // =========================================================================
    task collect_transaction(spi_trans tr);
        bit [7:0] addr_byte;
        collected_bytes.delete();

        // 采集地址
        collect_byte(addr_byte);
        tr.addr = addr_byte;

        // 采集返回数据
        while (vif.mon_cb.cs_n == 1'b0) begin
            bit [7:0] data_byte;
            collect_byte(data_byte);
            collected_bytes.push_back(data_byte);
        end

        // 填入输出字段
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

**monitor 的职责：** 采集 DUT 实际输出 → 填入 `status_o`, `data_o[]`, `error_o` → 发送给 scoreboard

## 相关链接

- [[05-Verification/UVM-Template/00-总览|UVM 模板总览]] - UVM 验证环境模板
- [[02-UVM/06-TLM通信|TLM 通信]] - TLM 通信机制
- [[00-总索引]] - 返回总索引
