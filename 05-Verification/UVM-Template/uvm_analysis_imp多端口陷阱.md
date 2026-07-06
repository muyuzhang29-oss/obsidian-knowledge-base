---
tags: [UVM, Verification, 妯℃澘, TLM, 闄烽槺]
created: 2026-04-17
updated: 2026-06-02
---

# uvm_analysis_imp 澶氱鍙ｉ櫡闃?
> 鍚屼竴涓被涓娇鐢ㄥ涓?`uvm_analysis_imp` 鏃讹紝鎵€鏈夌鍙ｉ兘璋冪敤鍚屼竴涓?`write` 鍑芥暟

---

## 涓€銆侀棶棰樻弿杩?
褰?scoreboard 闇€瑕佹帴鏀舵潵鑷袱涓笉鍚屾簮锛坢onitor 鍜?golden锛夌殑鏁版嵁鏃讹紝浼氬０鏄庝袱涓?`uvm_analysis_imp`锛?
```verilog
// 鉂?閿欒鍐欐硶
uvm_analysis_imp#(spi_trans, spi_scoreboard) rx_imp;   // 鎺ユ敹 monitor 瀹為檯杈撳嚭
uvm_analysis_imp#(spi_trans, spi_scoreboard) exp_imp;  // 鎺ユ敹 golden 鏈熸湜杈撳嚭
```

**闂锛?* 涓や釜绔彛閮芥槸 `uvm_analysis_imp`锛孶VM 妗嗘灦鍙 `write` 鍑芥暟銆傛棤璁烘暟鎹粠鍝釜绔彛杩涙潵锛岄兘璋冪敤 `write()`銆?
```verilog
function void write(spi_trans tr);     // rx_imp 璋冪敤 鉁?    ...
endfunction

function void write_exp(spi_trans tr); // exp_imp 涔熻皟鐢?write()锛屼笉浼氳皟鐢?write_exp()
    ...
endfunction
```

**缁撴灉锛?* `write_exp()` 姘歌繙涓嶄細琚皟鐢紝鏈熸湜鍊奸槦鍒楀缁堜负绌恒€?
---

## 浜屻€佽В鍐虫柟娉?
鐢?`` `uvm_analysis_imp_decl `` 瀹忕敓鎴愬甫鍚庣紑鐨?`write` 鍑芥暟锛?
```verilog
// 鉁?姝ｇ‘鍐欐硶
`uvm_analysis_imp_decl(_rx)    // 鐢熸垚 uvm_analysis_imp_rx 绫伙紝璋冪敤 write_rx()
`uvm_analysis_imp_decl(_exp)   // 鐢熸垚 uvm_analysis_imp_exp 绫伙紝璋冪敤 write_exp()

class spi_scoreboard extends uvm_scoreboard;
    uvm_analysis_imp_rx #(spi_trans, spi_scoreboard) rx_imp;   // 鈫?璋冪敤 write_rx()
    uvm_analysis_imp_exp #(spi_trans, spi_scoreboard) exp_imp;  // 鈫?璋冪敤 write_exp()

    function void write_rx(spi_trans rx_trans);
        // 澶勭悊 monitor 鐨勫疄闄呰緭鍑?    endfunction

    function void write_exp(spi_trans exp_trans);
        // 澶勭悊 golden 鐨勬湡鏈涜緭鍑?    endfunction
endclass
```

---

## 涓夈€佸伐浣滃師鐞?
`` `uvm_analysis_imp_decl(_rx) `` 灞曞紑鍚庣敓鎴愪竴涓被锛?
```verilog
class uvm_analysis_imp_rx #(type T=int, type IMP=int);
    function void write(T t);
        m_imp.write_rx(t);  // 鑷姩璋冪敤甯﹀悗缂€鐨勫嚱鏁?    endfunction
endclass
```

鎵€浠ワ細
- `uvm_analysis_imp_rx` 鐨?`write()` 鈫?璋冪敤 `write_rx()`
- `uvm_analysis_imp_exp` 鐨?`write()` 鈫?璋冪敤 `write_exp()`

---

## 鍥涖€佸畬鏁?Scoreboard 妯℃澘

```verilog
`uvm_analysis_imp_decl(_rx)
`uvm_analysis_imp_decl(_exp)

class spi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(spi_scoreboard)

    uvm_analysis_imp_rx #(spi_trans, spi_scoreboard) rx_imp;
    uvm_analysis_imp_exp #(spi_trans, spi_scoreboard) exp_imp;

    spi_trans exp_queue[$];

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rx_imp  = new("rx_imp", this);
        exp_imp = new("exp_imp", this);
    endfunction

    // 鎺ユ敹 monitor 鐨勫疄闄呰緭鍑?    function void write_rx(spi_trans rx_trans);
        spi_trans exp_trans;
        if(exp_queue.size() == 0) begin
            `uvm_error("SCB", "NO EXP TRANS AVAILABLE");
            return;
        end
        exp_trans = exp_queue.pop_front();
        compare(rx_trans, exp_trans);
    endfunction

    // 鎺ユ敹 golden 鐨勬湡鏈涜緭鍑?    function void write_exp(spi_trans exp_trans);
        exp_queue.push_back(exp_trans);
    endfunction

    function void compare(spi_trans rx, spi_trans exp);
        bit match = rx.compare(exp);
        if(match)
            `uvm_info("SCB", "PASS", UVM_LOW)
        else
            `uvm_error("SCB", "FAIL")
    endfunction

endclass
```

---

## 浜斻€佸父瑙侀敊璇眹鎬?
| 鍦烘櫙 | 閿欒鍐欐硶 | 姝ｇ‘鍐欐硶 |
|------|----------|----------|
| 鍗曠鍙?| `uvm_analysis_imp#(T, C)` | 鍙互锛宍write()` 鏃犳涔?|
| 鍙岀鍙?| 涓や釜 `uvm_analysis_imp#(T, C)` | 鐢?`` `uvm_analysis_imp_decl `` 鍖哄垎 |
| 鍑芥暟鍚?| `write()` + `write_exp()` | `write_rx()` + `write_exp()` |
| 瀹忎綅缃?| 鍦?class 鍐呴儴 | 鍦?class 澶栭儴锛宍include` 涔嬪墠 |

---

## 鍏€佽皟璇曟妧宸?
濡傛灉鎬€鐤?`write` 鍑芥暟娌¤璋冪敤锛屽姞鎵撳嵃纭锛?
```verilog
function void write_rx(spi_trans rx_trans);
    `uvm_info("SCB", "write_rx() called", UVM_LOW)  // 鈫?纭鏈夋病鏈夎璋冪敤
    ...
endfunction

function void write_exp(spi_trans exp_trans);
    `uvm_info("SCB", "write_exp() called", UVM_LOW)  // 鈫?纭鏈夋病鏈夎璋冪敤
    ...
endfunction
```

濡傛灉鍙墦鍗颁簡 `write_rx` 娌℃湁 `write_exp` 鈫?璇存槑 `uvm_analysis_imp_decl` 娌″姞鎴栧姞閿欎簡銆?
---

*鍒涘缓鏃堕棿: 2026-06-01*

