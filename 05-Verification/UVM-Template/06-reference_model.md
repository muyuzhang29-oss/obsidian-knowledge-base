---
tags: [UVM, Verification, 模板, ReferenceModel]
created: 2026-04-17
updated: 2026-06-02
---

# 06 - Reference Model 参考模型

> 根据 driver 的输入激励（通过 driver.ap 广播），计算期望输出，填入输出字段

```verilog
`ifndef SPI_REF_MODEL_SV
`define SPI_REF_MODEL_SV

class spi_ref_model extends uvm_component;

    `uvm_component_utils(spi_ref_model)

    uvm_analysis_port #(spi_trans) exp_ap;  // 发送期望 transaction 给 scoreboard
    uvm_analysis_imp #(spi_trans, spi_ref_model) imp;  // 接收 driver 的输入

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        exp_ap = new("exp_ap", this);
        imp    = new("imp", this);
    endfunction

    // =========================================================================
    // write: 接收输入 transaction，计算期望输出，发送给 scoreboard
    // =========================================================================
    function void write(spi_trans tr);
        spi_trans exp_trans;

        // 创建期望 transaction
        exp_trans = spi_trans::type_id::create("exp_trans");
        exp_trans.copy(tr);  // 拷贝输入字段

        // 计算期望输出
        compute_expected(exp_trans);

        // 发送给 scoreboard
        exp_ap.write(exp_trans);
    endfunction

    // =========================================================================
    // compute_expected: 根据输入计算期望输出（核心逻辑）
    // =========================================================================
    function void compute_expected(spi_trans tr);
        case (tr.cmd)
            // 写命令：期望写成功，无返回数据
            spi_trans::WR_CMD: begin
                tr.status_o = 8'h00;
                tr.error_o  = 1'b0;
                tr.data_o   = '{};

                if (tr.inject_crc_err) begin
                    tr.status_o = 8'h01;
                    tr.error_o  = 1'b1;
                end
            end

            // 读命令：期望返回读数据
            spi_trans::RD_CMD: begin
                tr.status_o = 8'h00;
                tr.error_o  = 1'b0;

                tr.data_o = new[tr.rd_len];
                foreach (tr.data_o[i]) begin
                    tr.data_o[i] = tr.addr + i;  // 根据 DUT 寄存器映射
                end
            end

            // 带数据的读：先写后读
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

**ref_model 的职责：** 读输入字段 → 计算期望值 → 填入 `status_o`, `data_o[]`, `error_o` → 发送给 scoreboard

## 相关链接

- [[05-Verification/UVM-Template/00-总览|UVM 模板总览]] - UVM 验证环境模板
- [[05-Verification/UVM-Template/UVM-Analysis-Port数据流|Analysis Port 数据流]] - 数据流机制
- [[00-总索引]] - 返回总索引
