---
tags: [UVM, Verification, 妯℃澘, TLM, 鏁版嵁娴乚
created: 2026-04-17
updated: 2026-06-02
---

# UVM Analysis Port 鏁版嵁娴佹満鍒?
> driver 鈫?ref_model / monitor 鈫?scoreboard 鐨勫畬鏁存暟鎹祦瑙ｆ瀽

---

## 涓€銆丄nalysis Port 鍥炶皟鏈哄埗

UVM 鐨?`uvm_analysis_port` 鏄?*涓€瀵瑰骞挎挱**锛氫竴涓?`ap.write(tr)` 浼氳嚜鍔ㄨ皟鐢ㄦ墍鏈夎繛鎺ョ殑 `write(tr)` 鍑芥暟銆?
```verilog
// driver 渚э細骞挎挱
ap.write(tr);  // tr 鏄?driver 鐨勫師濮嬭緭鍏?trans

// ref_model 渚э細鑷姩琚洖璋?function void write(spi_trans tr);  // tr 灏辨槸 driver 浼犺繃鏉ョ殑閭ｄ釜瀵硅薄
    // 鐩存帴浣跨敤 tr锛屼笉闇€瑕侀澶栦紶閫?endfunction
```

**鍏抽敭鐞嗚В锛?* `write(spi_trans tr)` 鐨勫弬鏁?`tr` 灏辨槸璋冪敤鏂?`ap.write(tr)` 浼犺繃鏉ョ殑瀵硅薄锛孶VM 妗嗘灦鑷姩瀹屾垚鍥炶皟锛屼笉闇€瑕佹墜鍔ㄤ紶閫掋€?
---

## 浜屻€佸畬鏁存暟鎹祦鏋舵瀯

```
sequence
   鈫?sequencer
   鈫?driver 鈫?get_next_item 鈹€鈹€ transaction (杈撳叆瀛楁: cmd, addr, data[], rd_len)
   鈫?           鈫?  DUT      driver.ap.write(tr)  鈫?骞挎挱鍘熷杈撳叆 trans
   鈫?               鈫?monitor         ref_model.write(tr)
   鈫?               鈫?monitor 閲囬泦     exp_trans.copy(tr) 鈫?鎷疯礉杈撳叆瀛楁
DUT 瀹為檯杈撳嚭     compute_expected(exp_trans) 鈫?璇昏緭鍏ュ瓧娈碉紝濉緭鍑哄瓧娈?   鈫?               鈫?rx_trans         exp_trans
(杈撳嚭瀛楁:       (杈撳嚭瀛楁:
 瀹為檯鍊?          鏈熸湜鍊?
   鈫?               鈫?   鈹斺攢鈹€鈫?scoreboard 鈫愨攢鈹€鈹?         姣斿 rx_trans vs exp_trans
```

---

## 涓夈€佸悇缁勪欢鑱岃矗

| 缁勪欢 | 杈撳叆 | 杈撳嚭 | 鑱岃矗 |
|------|------|------|------|
| driver | sequencer 鐨?trans | vif 淇″彿 + ap 骞挎挱 | 椹卞姩 DUT + 骞挎挱杈撳叆缁?ref_model |
| monitor | vif 淇″彿 | rx_trans锛堣緭鍑哄瓧娈靛疄闄呭€硷級 | 閲囬泦 DUT 杈撳嚭 |
| ref_model | driver.ap 鐨?tr | exp_trans锛堣緭鍑哄瓧娈垫湡鏈涘€硷級 | 璇昏緭鍏ュ瓧娈碉紝璁＄畻鏈熸湜杈撳嚭 |
| scoreboard | rx_trans + exp_trans | 姣斿缁撴灉 | 姣斿瀹為檯鍊?vs 鏈熸湜鍊?|

---

## 鍥涖€乀ransaction 瀛楁鍒嗗伐

```verilog
class spi_trans extends uvm_sequence_item;
    // 杈撳叆瀛楁锛歞river 濉紝ref_model 璇?    rand cmd_t  cmd;
    rand bit [7:0]  addr;
    rand bit [7:0]  data[];
    rand int        data_len;
    rand bit        rd_en;
    rand int        rd_len;

    // 杈撳嚭瀛楁锛歮onitor 濉疄闄呭€硷紝ref_model 濉湡鏈涘€?    bit [7:0]  status_o;
    bit [7:0]  data_o[];
    bit        error_o;
endclass
```

**鍚屼竴涓?transaction 绫伙紝涓嶅悓缁勪欢鐢ㄤ笉鍚屽瓧娈碉細**
- **driver**锛氬～杈撳叆瀛楁 鈫?椹卞姩 DUT + 骞挎挱缁?ref_model
- **ref_model**锛氳杈撳叆瀛楁 鈫?濉緭鍑哄瓧娈碉紙鏈熸湜鍊硷級
- **monitor**锛氬～杈撳嚭瀛楁锛堝疄闄呭€硷級
- **scoreboard**锛氬彧姣斿杈撳嚭瀛楁

---

## 浜斻€佽繛鎺ュ叧绯伙紙env connect_phase锛?
```verilog
function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // monitor 瀹為檯杈撳嚭 鈫?scoreboard
    agent.ap.connect(scb.rx_imp);

    // driver 杈撳叆婵€鍔?鈫?ref_model
    agent.drv_ap.connect(ref_model.imp);

    // ref_model 鏈熸湜杈撳嚭 鈫?scoreboard
    ref_model.exp_ap.connect(scb.exp_imp);
endfunction
```

**agent 鍐呴儴杩炴帴锛?*
```verilog
function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);  // driver 鈫?sequencer
    mon.ap.connect(ap);        // monitor.ap 鈫?agent.ap锛堝澶栨毚闇诧級
    drv.ap.connect(drv_ap);    // driver.ap 鈫?agent.drv_ap锛堝澶栨毚闇诧級
endfunction
```

---

## 鍏€佷负浠€涔堢敤 driver.ap 鑰屼笉鏄?monitor.ap 缁?ref_model

| | driver.ap 鈫?ref_model | monitor.ap 鈫?ref_model |
|---|---|---|
| 杈撳叆鏉ユ簮 | driver 鍙戝嚭鐨勫師濮嬫縺鍔?| monitor 閲囬泦鐨?DUT 杈撳叆 |
| 鏃跺簭 | 鏇存棭锛坉river 鍙戝畬绔嬪嵆骞挎挱锛?| 鏇存櫄锛堢瓑 monitor 閲囬泦锛?|
| 鍙潬鎬?| 鐩存帴锛屾棤寤惰繜 | 闇€瑕?monitor 鑳界湅鍒拌緭鍏ヤ俊鍙?|
| 閫傜敤鍦烘櫙 | DUT 涓嶄慨鏀硅緭鍏?| DUT 鍙兘淇敼杈撳叆 |

**鎺ㄨ崘鐢?driver.ap锛?*
- driver 鍙戝畬鏁版嵁鍚庣洿鎺ュ箍鎾紝ref_model 涓嶉渶瑕佺瓑 monitor
- monitor 鍙礋璐ｉ噰闆?DUT 杈撳嚭锛岃亴璐ｆ洿娓呮櫚
- 涓嶄緷璧?monitor 鑳藉惁鐪嬪埌杈撳叆淇″彿

---

## 鐩稿叧閾炬帴

- [[02-UVM/06-TLM閫氫俊|TLM 閫氫俊鏈哄埗]] - UVM TLM 閫氫俊璇﹁В
- [[05-Verification/UVM-Template/00-鎬昏|UVM 妯℃澘鎬昏]] - UVM 楠岃瘉鐜妯℃澘
- [[02-UVM/04-缁勪欢|UVM 缁勪欢]] - UVM 缁勪欢缁撴瀯
- [[00-鎬荤储寮昡] - 杩斿洖鎬荤储寮?
---

*鍒涘缓鏃堕棿: 2026-06-01*

