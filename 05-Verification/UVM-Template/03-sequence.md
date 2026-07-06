---
tags: [UVM, Verification, 妯℃澘, Sequence]
created: 2026-04-17
updated: 2026-06-02
---

# 03 - Sequence 浜嬪姟搴忓垪

> 璐熻矗鐢熸垚婵€鍔憋紝瀹氫箟"瑕佸彂鍝簺 transaction锛屼互浠€涔堥『搴忓彂"

```verilog
`ifndef SPI_SEQ_SV
`define SPI_SEQ_SV

// =============================================================================
// 鍩虹 sequence锛氬彂閫佸崟涓?transaction
// =============================================================================
class spi_base_sequence extends uvm_sequence #(spi_trans);

    `uvm_object_utils(spi_base_sequence)

    int num_items = 10;  // 鍙戦€?transaction 鏁伴噺

    function new(string name = "spi_base_sequence");
        super.new(name);
    endfunction

    // body() 鏄?sequence 鐨勪富鍑芥暟锛岃皟鐢?start() 鏃舵墽琛?    virtual task body();
        `uvm_info(get_type_name(), $sformatf("Starting sequence, num_items=%0d", num_items), UVM_LOW)

        repeat (num_items) begin
            spi_trans tr = spi_trans::type_id::create("tr");

            if (!tr.randomize()) begin
                `uvm_error(get_type_name(), "Randomization failed")
                continue;
            end

            // start_item: 绛夊緟 sequencer 鎺堟潈
            // finish_item: 鍙戦€佺粰 driver锛岀瓑寰?driver 瀹屾垚
            start_item(tr);
            finish_item(tr);
        end

        `uvm_info(get_type_name(), "Sequence completed", UVM_LOW)
    endtask

endclass

// =============================================================================
// 鍐欎笓鐢?sequence锛氬彧鍙戝啓鍛戒护
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

            // 绾︽潫鍙敓鎴愬啓鍛戒护
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
// 閿欒娉ㄥ叆 sequence锛氬彂閫佸甫閿欒娉ㄥ叆鐨?transaction
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

**鍏抽敭鐐癸細**
- sequence 鏄?`uvm_object`锛屼笉鏄?`uvm_component`锛岀敓鍛藉懆鏈熺敱 test 鎺у埗
- 閫氳繃 `start_item`/`finish_item` 涓?driver 浜や簰
- 鐢?`with {}` 鍐呰仈绾︽潫鎺у埗闅忔満鍖栬寖鍥?
## 鐩稿叧閾炬帴

- [[05-Verification/UVM-Template/00-鎬昏|UVM 妯℃澘鎬昏]] - UVM 楠岃瘉鐜妯℃澘
- [[02-UVM/03-Sequence鏈哄埗|Sequence 鏈哄埗]] - Sequence 璇﹁В
- [[00-鎬荤储寮昡] - 杩斿洖鎬荤储寮?
