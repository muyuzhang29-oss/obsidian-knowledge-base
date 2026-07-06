---
tags: [UVM, Verification, 妯℃澘, Environment]
created: 2026-04-17
updated: 2026-06-02
---

# 09 - Env 楠岃瘉鐜

> 缁勮 agent + scoreboard + reference_model锛岃繛鎺ユ暟鎹祦

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
    // connect_phase: 杩炴帴鏁版嵁娴?    // =========================================================================
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // monitor 鐨勫疄闄呰緭鍑?鈫?scoreboard 鐨?rx_imp
        agent.ap.connect(scb.rx_imp);

        // driver 鐨勮緭鍏ユ縺鍔?鈫?ref_model锛坮ef_model 璇昏緭鍏ュ瓧娈佃绠楁湡鏈涳級
        agent.drv_ap.connect(ref_model.imp);

        // ref_model 鐨勬湡鏈涜緭鍑?鈫?scoreboard 鐨?exp_imp
        ref_model.exp_ap.connect(scb.exp_imp);
    endfunction

endclass

`endif
```

**鏁版嵁娴侊細**
```
monitor.ap 鈹€鈹€鈫?scb.rx_imp           (DUT 瀹為檯杈撳嚭)
driver.ap  鈹€鈹€鈫?ref_model.imp        (杈撳叆婵€鍔憋紝鐢ㄤ簬璁＄畻鏈熸湜)
ref_model.exp_ap 鈹€鈹€鈫?scb.exp_imp    (鏈熸湜杈撳嚭)
```

## 鐩稿叧閾炬帴

- [[05-Verification/UVM-Template/00-鎬昏|UVM 妯℃澘鎬昏]] - UVM 楠岃瘉鐜妯℃澘
- [[02-UVM/04-缁勪欢|UVM 缁勪欢]] - UVM 缁勪欢璇﹁В
- [[00-鎬荤储寮昡] - 杩斿洖鎬荤储寮?
