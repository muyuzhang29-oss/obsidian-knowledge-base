---
tags: [UVM, Verification, 妯℃澘, Test]
created: 2026-04-17
updated: 2026-06-02
---

# 10 - Test 娴嬭瘯鐢ㄤ緥

> 閰嶇疆鐜骞跺惎鍔?sequence锛屾槸鐢ㄦ埛鐩存帴缂栧啓鐨勯儴鍒?
```verilog
`ifndef SPI_TEST_SV
`define SPI_TEST_SV

// =============================================================================
// 鍩虹 test
// =============================================================================
class spi_base_test extends uvm_test;

    `uvm_component_utils(spi_base_test)

    spi_env    env;
    spi_config cfg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // =========================================================================
    // build_phase: 閰嶇疆鐜骞跺垱寤?env
    // =========================================================================
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // 鍒涘缓骞堕厤缃?        cfg = spi_config::type_id::create("cfg");
        cfg.spi_mode       = 0;
        cfg.cs_active_pol  = 0;
        cfg.timeout_cycles = 1000;

        // 灏嗛厤缃斁鍏?config_db
        uvm_config_db#(spi_config)::set(this, "*", "spi_cfg", cfg);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "env.agent", "is_active", UVM_ACTIVE);

        env = spi_env::type_id::create("env", this);
    endfunction

    // =========================================================================
    // run_phase: 鍚姩 sequence
    // =========================================================================
    task run_phase(uvm_phase phase);
        spi_base_sequence seq;

        seq = spi_base_sequence::type_id::create("seq");
        seq.num_items = 100;

        phase.raise_objection(this);   // 闃绘浠跨湡缁撴潫
        seq.start(env.agent.seqr);     // 鍚姩 sequence
        #1000;
        phase.drop_objection(this);    // 鍏佽浠跨湡缁撴潫
    endtask

    // =========================================================================
    // end_of_elaboration_phase: 鎵撳嵃鎷撴墤缁撴瀯
    // =========================================================================
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

endclass

// =============================================================================
// 鍐欎笓鐢?test
// =============================================================================
class spi_write_test extends spi_base_test;

    `uvm_component_utils(spi_write_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        spi_write_sequence seq;
        seq = spi_write_sequence::type_id::create("seq");
        seq.num_items = 50;

        phase.raise_objection(this);
        seq.start(env.agent.seqr);
        #1000;
        phase.drop_objection(this);
    endtask

endclass

`endif
```

**鍏抽敭鐐癸細**
- test 閰嶇疆 env 鐨勮涓猴紝閫夋嫨瑕佽繍琛岀殑 sequence
- `raise_objection`/`drop_objection` 鎺у埗浠跨湡缁撴潫
- 閫氳繃 `config_db` 璁剧疆閰嶇疆锛屽瓙缁勪欢閫氳繃 `config_db` 鑾峰彇

## 鐩稿叧閾炬帴

- [[05-Verification/UVM-Template/00-鎬昏|UVM 妯℃澘鎬昏]] - UVM 楠岃瘉鐜妯℃澘
- [[02-UVM/01-Phase鏈哄埗|Phase 鏈哄埗]] - UVM Phase 璇﹁В
- [[00-鎬荤储寮昡] - 杩斿洖鎬荤储寮?
