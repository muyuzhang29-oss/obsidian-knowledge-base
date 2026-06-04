---
tags: [UVM, Verification, 模板, Driver]
created: 2026-04-17
updated: 2026-06-02
---

# 04 - Driver 驱动器

> 将 transaction 转换为 vif 上的信号

```systemverilog
`ifndef SPI_DRV_SV
`define SPI_DRV_SV

class spi_driver extends uvm_driver #(spi_trans);

    `uvm_component_utils(spi_driver)

    virtual spi_if vif;

    uvm_analysis_port #(spi_trans) ap;  // 广播 transaction 给 ref_model

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // =========================================================================
    // build_phase: 获取虚拟接口
    // =========================================================================
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("DRV", "Failed to get virtual interface")
        end
    endfunction

    // =========================================================================
    // run_phase: 主循环
    // =========================================================================
    virtual task run_phase(uvm_phase phase);
        spi_trans tr;

        vif.drv_cb.cs_n  <= 1'b1;  // CS 默认无效
        vif.drv_cb.mosi  <= 1'b0;
        vif.drv_busy     <= 1'b0;

        @(posedge vif.rst_n);  // 等待复位释放

        forever begin
            seq_item_port.get_next_item(tr);  // 从 sequencer 获取 transaction

            `uvm_info("DRV", $sformatf("Driving: cmd=%s addr=0x%02h", tr.cmd.name(), tr.addr), UVM_LOW)

            vif.drv_busy <= 1'b1;

            case (tr.cmd)
                spi_trans::WR_CMD:      drive_write(tr);
                spi_trans::RD_CMD:      drive_read(tr, 0);
                spi_trans::RD_DATA_CMD: drive_read(tr, 1);
                default: `uvm_error("DRV", $sformatf("Unknown cmd: %s", tr.cmd.name()))
            endcase

            vif.drv_busy <= 1'b0;
            ap.write(tr);  // 广播 transaction 给 ref_model
            seq_item_port.item_done();  // 通知 sequencer 完成
        end
    endtask

    // =========================================================================
    // drive_write: 驱动写操作
    // =========================================================================
    task drive_write(spi_trans tr);
        vif.drv_cb.cs_n <= 1'b0;
        @(posedge vif.clk);

        drive_byte(tr.addr);  // 发送地址

        foreach (tr.data[i]) begin
            drive_byte(tr.data[i]);  // 发送数据
        end

        @(posedge vif.clk);
        vif.drv_cb.cs_n <= 1'b1;
        @(posedge vif.clk);
    endtask

    // =========================================================================
    // drive_read: 驱动读操作
    // =========================================================================
    task drive_read(spi_trans tr, bit has_write_data);
        vif.drv_cb.cs_n <= 1'b0;
        @(posedge vif.clk);

        drive_byte(tr.addr);

        if (has_write_data) begin
            foreach (tr.data[i]) begin
                drive_byte(tr.data[i]);
            end
        end

        // 读取数据（由 DUT 驱动 miso，monitor 负责采集）
        repeat (tr.rd_len) begin
            @(posedge vif.clk);
        end

        vif.drv_cb.cs_n <= 1'b1;
        @(posedge vif.clk);
    endtask

    // =========================================================================
    // drive_byte: 逐 bit 驱动一个字节
    // =========================================================================
    task drive_byte(bit [7:0] data);
        for (int i = 7; i >= 0; i--) begin
            vif.drv_cb.mosi <= data[i];
            @(posedge vif.clk);
        end
    endtask

endclass

`endif
```

**关键点：**
- driver 做两件事：把 transaction 转换为 vif 信号 + 通过 ap 广播给 ref_model
- 通过 `get_next_item`/`item_done` 与 sequencer 交互
- 使用 clocking block 驱动信号（`vif.drv_cb.signal <= value`）
- driver 不负责采集 DUT 响应，那是 monitor 的事
- `item_done()` 之前调用 `ap.write(tr)`，确保 ref_model 收到输入激励

## 相关链接

- [[05-Verification/UVM-Template/00-总览|UVM 模板总览]] - UVM 验证环境模板
- [[02-UVM/04-组件|UVM 组件]] - UVM 组件详解
- [[00-总索引]] - 返回总索引
