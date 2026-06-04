---
tags: [UVM, Verification, 模板, Sequence]
created: 2026-04-17
updated: 2026-06-02
---

# 03 - Sequence 事务序列

> 负责生成激励，定义"要发哪些 transaction，以什么顺序发"

```systemverilog
`ifndef SPI_SEQ_SV
`define SPI_SEQ_SV

// =============================================================================
// 基础 sequence：发送单个 transaction
// =============================================================================
class spi_base_sequence extends uvm_sequence #(spi_trans);

    `uvm_object_utils(spi_base_sequence)

    int num_items = 10;  // 发送 transaction 数量

    function new(string name = "spi_base_sequence");
        super.new(name);
    endfunction

    // body() 是 sequence 的主函数，调用 start() 时执行
    virtual task body();
        `uvm_info(get_type_name(), $sformatf("Starting sequence, num_items=%0d", num_items), UVM_LOW)

        repeat (num_items) begin
            spi_trans tr = spi_trans::type_id::create("tr");

            if (!tr.randomize()) begin
                `uvm_error(get_type_name(), "Randomization failed")
                continue;
            end

            // start_item: 等待 sequencer 授权
            // finish_item: 发送给 driver，等待 driver 完成
            start_item(tr);
            finish_item(tr);
        end

        `uvm_info(get_type_name(), "Sequence completed", UVM_LOW)
    endtask

endclass

// =============================================================================
// 写专用 sequence：只发写命令
// =============================================================================
class spi_write_sequence extends uvm_sequence #(spi_trans);

    `uvm_object_utils(spi_write_sequence)

    int num_items = 10;

    function new(string name = "spi_write_sequence");
        super.new(name);
    endfunction

    virtual task body();
        repeat (num_items) begin
            spi_trans tr = spi_trans::type_id::create("tr");

            // 约束只生成写命令
            if (!tr.randomize() with { cmd == spi_trans::WR_CMD; }) begin
                `uvm_error(get_type_name(), "Randomization failed")
                continue;
            end

            start_item(tr);
            finish_item(tr);
        end
    endtask

endclass

// =============================================================================
// 错误注入 sequence：发送带错误注入的 transaction
// =============================================================================
class spi_error_sequence extends uvm_sequence #(spi_trans);

    `uvm_object_utils(spi_error_sequence)

    int num_items = 10;

    function new(string name = "spi_error_sequence");
        super.new(name);
    endfunction

    virtual task body();
        repeat (num_items) begin
            spi_trans tr = spi_trans::type_id::create("tr");

            if (!tr.randomize() with {
                inject_crc_err     dist { 0 := 70, 1 := 30 };
                inject_timeout     dist { 0 := 80, 1 := 20 };
                inject_invalid_cmd dist { 0 := 90, 1 := 10 };
            }) begin
                `uvm_error(get_type_name(), "Randomization failed")
                continue;
            end

            start_item(tr);
            finish_item(tr);
        end
    endtask

endclass

`endif
```

**关键点：**
- sequence 是 `uvm_object`，不是 `uvm_component`，生命周期由 test 控制
- 通过 `start_item`/`finish_item` 与 driver 交互
- 用 `with {}` 内联约束控制随机化范围

## 相关链接

- [[05-Verification/UVM-Template/00-总览|UVM 模板总览]] - UVM 验证环境模板
- [[02-UVM/03-Sequence机制|Sequence 机制]] - Sequence 详解
- [[00-总索引]] - 返回总索引
