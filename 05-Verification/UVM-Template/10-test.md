---
tags: [UVM, Verification, 模板, Test]
created: 2026-04-17
updated: 2026-06-02
---

# 10 - Test 测试用例

> 配置环境并启动 sequence，是用户直接编写的部分

```verilog
`ifndef SPI_TEST_SV
`define SPI_TEST_SV

// =============================================================================
// 基础 test
// =============================================================================
class spi_base_test extends uvm_test;

    `uvm_component_utils(spi_base_test)

    spi_env    env;
    spi_config cfg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // =========================================================================
    // build_phase: 配置环境并创建 env
    // =========================================================================
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // 创建并配置
        cfg = spi_config::type_id::create("cfg");
        cfg.spi_mode       = 0;
        cfg.cs_active_pol  = 0;
        cfg.timeout_cycles = 1000;

        // 将配置放入 config_db
        uvm_config_db#(spi_config)::set(this, "*", "spi_cfg", cfg);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "env.agent", "is_active", UVM_ACTIVE);

        env = spi_env::type_id::create("env", this);
    endfunction

    // =========================================================================
    // run_phase: 启动 sequence
    // =========================================================================
    task run_phase(uvm_phase phase);
        spi_base_sequence seq;

        seq = spi_base_sequence::type_id::create("seq");
        seq.num_items = 100;

        phase.raise_objection(this);   // 阻止仿真结束
        seq.start(env.agent.seqr);     // 启动 sequence
        #1000;
        phase.drop_objection(this);    // 允许仿真结束
    endtask

    // =========================================================================
    // end_of_elaboration_phase: 打印拓扑结构
    // =========================================================================
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

endclass

// =============================================================================
// 写专用 test
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

**关键点：**
- test 配置 env 的行为，选择要运行的 sequence
- `raise_objection`/`drop_objection` 控制仿真结束
- 通过 `config_db` 设置配置，子组件通过 `config_db` 获取

## 相关链接

- [[05-Verification/UVM-Template/00-总览|UVM 模板总览]] - UVM 验证环境模板
- [[02-UVM/01-Phase机制|Phase 机制]] - UVM Phase 详解
- [[00-总索引]] - 返回总索引
