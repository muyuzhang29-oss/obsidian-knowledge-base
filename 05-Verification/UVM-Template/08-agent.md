---
tags: [UVM, Verification, 模板, Agent]
created: 2026-04-17
updated: 2026-06-02
---

# 08 - Agent 代理

> 组装 driver + sequencer + monitor，对外暴露统一接口

```systemverilog
`ifndef SPI_AGENT_SV
`define SPI_AGENT_SV

class spi_agent extends uvm_agent;

    `uvm_component_utils(spi_agent)

    spi_driver    drv;
    spi_sequencer seqr;
    spi_monitor   mon;

    uvm_analysis_port #(spi_trans) ap;       // 对外暴露 monitor 的 ap（给 scb）
    uvm_analysis_port #(spi_trans) drv_ap;   // 对外暴露 driver 的 ap（给 ref_model）

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap     = new("ap", this);
        drv_ap = new("drv_ap", this);

        // 总是创建 monitor（passive 模式也需要）
        mon = spi_monitor::type_id::create("mon", this);

        // active 模式才创建 driver 和 sequencer
        if (get_is_active() == UVM_ACTIVE) begin
            drv  = spi_driver::type_id::create("drv", this);
            seqr = spi_sequencer::type_id::create("seqr", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // 连接 driver 和 sequencer
        if (get_is_active() == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end

        // 对外暴露 monitor 的 analysis port（给 scb）
        mon.ap.connect(ap);
        // 对外暴露 driver 的 analysis port（给 ref_model）
        drv.ap.connect(drv_ap);
    endfunction

endclass

`endif
```

**关键点：**
- agent 是可复用的验证组件，一个 agent 对应一个接口
- **active 模式**：driver + sequencer + monitor（用于驱动 DUT）
- **passive 模式**：只有 monitor（用于观察 DUT）
- 对外暴露两个 ap：`ap`（monitor 输出，给 scb）和 `drv_ap`（driver 输入激励，给 ref_model）

## 相关链接

- [[05-Verification/UVM-Template/00-总览|UVM 模板总览]] - UVM 验证环境模板
- [[02-UVM/04-组件|UVM 组件]] - UVM 组件详解
- [[00-总索引]] - 返回总索引
