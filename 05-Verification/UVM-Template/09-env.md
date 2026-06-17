---
tags: [UVM, Verification, 模板, Environment]
created: 2026-04-17
updated: 2026-06-02
---

# 09 - Env 验证环境

> 组装 agent + scoreboard + reference_model，连接数据流

```verilog
`ifndef SPI_ENV_SV
`define SPI_ENV_SV

class spi_env extends uvm_env;

    `uvm_component_utils(spi_env)

    spi_agent       agent;
    spi_scoreboard  scb;
    spi_ref_model   ref_model;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent     = spi_agent::type_id::create("agent", this);
        scb       = spi_scoreboard::type_id::create("scb", this);
        ref_model = spi_ref_model::type_id::create("ref_model", this);
    endfunction

    // =========================================================================
    // connect_phase: 连接数据流
    // =========================================================================
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // monitor 的实际输出 → scoreboard 的 rx_imp
        agent.ap.connect(scb.rx_imp);

        // driver 的输入激励 → ref_model（ref_model 读输入字段计算期望）
        agent.drv_ap.connect(ref_model.imp);

        // ref_model 的期望输出 → scoreboard 的 exp_imp
        ref_model.exp_ap.connect(scb.exp_imp);
    endfunction

endclass

`endif
```

**数据流：**
```
monitor.ap ──→ scb.rx_imp           (DUT 实际输出)
driver.ap  ──→ ref_model.imp        (输入激励，用于计算期望)
ref_model.exp_ap ──→ scb.exp_imp    (期望输出)
```

## 相关链接

- [[05-Verification/UVM-Template/00-总览|UVM 模板总览]] - UVM 验证环境模板
- [[02-UVM/04-组件|UVM 组件]] - UVM 组件详解
- [[00-总索引]] - 返回总索引
