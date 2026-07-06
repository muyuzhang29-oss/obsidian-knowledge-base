---
tags: [UVM, Verification, 妯℃澘, Agent]
created: 2026-04-17
updated: 2026-06-02
---

# 08 - Agent 浠ｇ悊

> 缁勮 driver + sequencer + monitor锛屽澶栨毚闇茬粺涓€鎺ュ彛

```verilog
`ifndef SPI_AGENT_SV
`define SPI_AGENT_SV

class spi_agent extends uvm_agent;

    `uvm_component_utils(spi_agent)

    spi_driver    drv;
    spi_sequencer seqr;
    spi_monitor   mon;

    uvm_analysis_port #(spi_trans) ap;       // 瀵瑰鏆撮湶 monitor 鐨?ap锛堢粰 scb锛?    uvm_analysis_port #(spi_trans) drv_ap;   // 瀵瑰鏆撮湶 driver 鐨?ap锛堢粰 ref_model锛?
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap     = new("ap", this);
        drv_ap = new("drv_ap", this);

        // 鎬绘槸鍒涘缓 monitor锛坧assive 妯″紡涔熼渶瑕侊級
        mon = spi_monitor::type_id::create("mon", this);

        // active 妯″紡鎵嶅垱寤?driver 鍜?sequencer
        if (get_is_active() == UVM_ACTIVE) begin
            drv  = spi_driver::type_id::create("drv", this);
            seqr = spi_sequencer::type_id::create("seqr", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // 杩炴帴 driver 鍜?sequencer
        if (get_is_active() == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end

        // 瀵瑰鏆撮湶 monitor 鐨?analysis port锛堢粰 scb锛?        mon.ap.connect(ap);
        // 瀵瑰鏆撮湶 driver 鐨?analysis port锛堢粰 ref_model锛?        drv.ap.connect(drv_ap);
    endfunction

endclass

`endif
```

**鍏抽敭鐐癸細**
- agent 鏄彲澶嶇敤鐨勯獙璇佺粍浠讹紝涓€涓?agent 瀵瑰簲涓€涓帴鍙?- **active 妯″紡**锛歞river + sequencer + monitor锛堢敤浜庨┍鍔?DUT锛?- **passive 妯″紡**锛氬彧鏈?monitor锛堢敤浜庤瀵?DUT锛?- 瀵瑰鏆撮湶涓や釜 ap锛歚ap`锛坢onitor 杈撳嚭锛岀粰 scb锛夊拰 `drv_ap`锛坉river 杈撳叆婵€鍔憋紝缁?ref_model锛?
## 鐩稿叧閾炬帴

- [[05-Verification/UVM-Template/00-鎬昏|UVM 妯℃澘鎬昏]] - UVM 楠岃瘉鐜妯℃澘
- [[02-UVM/04-缁勪欢|UVM 缁勪欢]] - UVM 缁勪欢璇﹁В
- [[00-鎬荤储寮昡] - 杩斿洖鎬荤储寮?
