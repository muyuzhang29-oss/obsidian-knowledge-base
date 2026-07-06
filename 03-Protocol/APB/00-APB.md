---
tags: [Protocol, APB, AMBA, 骞惰鎬荤嚎]
---

# APB 鍗忚

> Advanced Peripheral Bus - 绠€鍗曘€佷綆鍔熻€楃殑澶栬鎬荤嚎

## 鍗忚姒傝堪

APB鏄疉MBA鍗忚涓渶绠€鍗曠殑鎬荤嚎锛岀敤浜庤繛鎺ヤ綆閫熷璁俱€?
### 鐗规€?- 绠€鍗曞崗璁紝鏃犻渶浠茶
- 涓ゅ懆鏈熸彙鎵?- 浣庡姛鑰楄璁?- 鏃犵獊鍙戜紶杈?
---

## 淇″彿瀹氫箟

### 鍩烘湰淇″彿

| 淇″彿 | 鏂瑰悜 | 璇存槑 |
|------|------|------|
| PCLK | Input | 鏃堕挓 |
| PRESETn | Input | 澶嶄綅锛堜綆鏈夋晥锛墊
| PADDR | Input | 鍦板潃 |
| PSEL | Input | 閫夋嫨淇″彿 |
| PENABLE | Input | 浣胯兘 |
| PWRITE | Input | 鍐欙紙1锛?璇伙紙0锛墊
| PWDATA | Input | 鍐欐暟鎹?|
| PRDATA | Output | 璇绘暟鎹?|
| PREADY | Output | 灏辩华锛圓PB3+锛墊
| PSLVERR | Output | 閿欒鍝嶅簲锛圓PB3+锛墊

---

## 浼犺緭鏃跺簭

### APB2锛堝熀鏈紶杈擄級

```
PCLK     鈹€鈹€鈹€鈹?  鈹屸攢鈹€鈹€鈹?  鈹屸攢鈹€鈹€鈹?  鈹屸攢鈹€鈹€鈹?  鈹屸攢鈹€鈹€鈹?              鈹斺攢鈹€鈹€鈹?  鈹斺攢鈹€鈹€鈹?  鈹斺攢鈹€鈹€鈹?  鈹斺攢鈹€鈹€鈹?
PSEL     鈹€鈹€鈹€鈹€鈹?  鈺斺晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺椻攢鈹€鈹€
              鈹斺攢鈹€鈹€鈹?                            鈹斺攢鈹€鈹€

PENABLE                  鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹愨攢鈹€鈹€
                         鈹?                    鈹?                         鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?
PADDR    鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€A鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€
             鍦板潃

PWDATA   鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€D鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€
             鏁版嵁
```

### 鏃跺簭璇存槑

1. **IDLE**: 鎬荤嚎绌洪棽
2. **SETUP**: PSEL=1, PENABLE=0, 鍙戦€佸湴鍧€鍜屾帶鍒?3. **ACCESS**: PSEL=1, PENABLE=1, 鏁版嵁浼犺緭

---

## APB3 鏂板鐗规€?
### 绛夊緟鐘舵€?
```verilog
// APB3: PREADY鍏佽鎻掑叆绛夊緟鍛ㄦ湡
always @(posedge PCLK) begin
    if (!PRESETn)
        state <= IDLE;
    else
        case (state)
            IDLE: if (PSEL) state <= SETUP;
            SETUP: state <= ACCESS;
            ACCESS: if (PREADY) state <= IDLE;
        endcase
end
```

### 閿欒鍝嶅簲

```verilog
// PSLVERR: 浠庢満鎶ュ憡閿欒
assign PSLVERR = (state == ERROR);
```

---

## UVM楠岃瘉妯″瀷

### APB Transaction

```verilog
class apb_transaction extends uvm_sequence_item;
    rand bit [31:0] addr;
    rand bit [31:0] data;
    rand bit write;
    bit error;

    `uvm_object_utils_begin(apb_transaction)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(write, UVM_ALL_ON)
    `uvm_object_utils_end
endclass
```

### APB Driver

```verilog
class apb_driver extends uvm_driver #(apb_transaction);
    virtual apb_if vif;

    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            drive_transfer(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_transfer(apb_transaction req);
        @(posedge vif.presetn);
        vif.psel    <= 1'b1;
        vif.paddr   <= req.addr;
        vif.pwrite  <= req.write;
        vif.pwdata  <= req.data;
        @(posedge vif.pclk);
        vif.penable <= 1'b1;
        @(posedge vif.pclk);
        if (!req.write)
            req.data = vif.prdata;
        @(posedge vif.pclk);
        vif.psel    <= 1'b0;
        vif.penable <= 1'b0;
    endtask
endclass
```

---

## 涓嶢XI瀵规瘮

| 鐗规€?| APB | AXI |
|------|-----|-----|
| 绐佸彂浼犺緭 | 鏃?| 鏀寔 |
| 绛夊緟鍛ㄦ湡 | 鏀寔 | 鏀寔 |
| 鐙珛閫氶亾 | 鍚?| 鏄?|
| 甯﹀ | 浣?| 楂?|
| 澶嶆潅搴?| 浣?| 楂?|

---

## 浣跨敤鍦烘櫙

- **閫傚悎**: 绠€鍗曞璁?UART, GPIO, Timer)
- **涓嶉€傚悎**: 楂樺甫瀹介渶姹?DDR, Ethernet)

---

tags: #Protocol #APB #AMBA #鏍稿績

## 鐩稿叧閾炬帴

- [[03-Protocol/00-鍗忚绱㈠紩|鍗忚绱㈠紩]] - 杩斿洖鍗忚绱㈠紩
- [[03-Protocol/AXI/00-AXI|AXI]] - AXI 鍗忚
- [[02-UVM/00-鍏ラ棬|UVM 鍏ラ棬]] - UVM 楠岃瘉鏂规硶瀛?- [[00-鎬荤储寮昡] - 杩斿洖鎬荤储寮?
