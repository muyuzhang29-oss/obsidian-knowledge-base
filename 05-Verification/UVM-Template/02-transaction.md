---
tags: [UVM, Verification, 妯℃澘, Transaction]
created: 2026-04-17
updated: 2026-06-02
---

# 02 - Transaction 浜嬪姟绫?
> UVM 楠岃瘉鐜鐨勬暟鎹ā鍨嬶紝drv/mon/ref_model 鍏辩敤

**璁捐鎬濊矾锛?*
- 杈撳叆瀛楁锛歞river 濉紝椹卞姩鍒?DUT
- 杈撳嚭瀛楁锛歮onitor 濉疄闄呭€硷紝ref_model 濉湡鏈涘€?- scoreboard 姣斿涓や釜 transaction 鐨勮緭鍑哄瓧娈?
```verilog
`ifndef SPI_TRANS_SV
`define SPI_TRANS_SV

class spi_trans extends uvm_sequence_item;

    `uvm_object_utils(spi_trans)

    // =========================================================================
    // 杈撳叆瀛楁锛坉river 鈫?DUT锛?    // =========================================================================

    typedef enum bit [1:0] {
        WR_CMD      = 2'b01,
        RD_CMD      = 2'b10,
        RD_DATA_CMD = 2'b11
    } cmd_e;

    rand cmd_e      cmd;           // 鍛戒护绫诲瀷
    rand bit [7:0]  addr;          // 鐩爣鍦板潃
    rand bit [7:0]  data[];        // 鍐欐暟鎹?    rand int        data_len;      // 鏁版嵁闀垮害
    rand bit        rd_en;         // 鏄惁璇绘暟鎹?    rand int        rd_len;        // 璇绘暟鎹暱搴?
    // =========================================================================
    // 杈撳嚭瀛楁锛坢onitor/ref_model 濉級
    // =========================================================================

    bit [7:0]       status_o;      // 鐘舵€佺爜
    bit [7:0]       data_o[];      // 杩斿洖鏁版嵁
    bit             error_o;       // 閿欒鏍囧織

    // =========================================================================
    // 鍗忚鎺у埗瀛楁锛堝彲閫夛級
    // =========================================================================

    rand int        spi_mode;
    rand bit        cs_active_pol;
    rand int        dummy_cycles;

    // =========================================================================
    // 閿欒娉ㄥ叆瀛楁锛堝彲閫夛級
    // =========================================================================

    rand bit        inject_crc_err;
    rand bit        inject_timeout;
    rand bit        inject_invalid_cmd;

    // =========================================================================
    // 鏋勯€犲嚱鏁?    // =========================================================================

    function new(string name = "spi_trans");
        super.new(name);
        data_o = '{};
    endfunction

    // =========================================================================
    // 绾︽潫
    // =========================================================================

    constraint c_data_len {
        data_len inside {[1:256]};
        data.size() == data_len;
    }

    constraint c_rd_len {
        rd_len inside {[0:64]};
    }

    constraint c_addr {
        addr inside {[0:255]};
    }

    // =========================================================================
    // 姣旇緝鏂规硶锛坰coreboard 鐢級
    // =========================================================================

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        spi_trans rhs_trans;
        if (!$cast(rhs_trans, rhs)) return 0;

        return (status_o == rhs_trans.status_o) &&
               (error_o  == rhs_trans.error_o)  &&
               (data_o   == rhs_trans.data_o);
    endfunction

endclass

`endif
```

**瀛楁鑱岃矗锛?*

| 瀛楁 | driver | monitor | ref_model | scb |
|------|--------|---------|-----------|-----|
| cmd, addr, data... | 濉?| - | 璇?| - |
| status_o | - | 濉疄闄呭€?| 濉湡鏈涘€?| 姣斿 |
| data_o[] | - | 濉疄闄呭€?| 濉湡鏈涘€?| 姣斿 |
| error_o | - | 濉疄闄呭€?| 濉湡鏈涘€?| 姣斿 |

## 鐩稿叧閾炬帴

- [[05-Verification/UVM-Template/00-鎬昏|UVM 妯℃澘鎬昏]] - UVM 楠岃瘉鐜妯℃澘
- [[01-SV璇硶/02-绫粅绫讳笌闈㈠悜瀵硅薄]] - SystemVerilog 绫?- [[00-鎬荤储寮昡] - 杩斿洖鎬荤储寮?
