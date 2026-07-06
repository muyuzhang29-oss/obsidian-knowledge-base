---
tags:
  - UVM
  - Verification
  - TLM
  - 閫氫俊
  - 鏍稿績
---

# TLM閫氫俊鏈哄埗

## 1. TLM姒傝堪

TLM锛圱ransaction Level Modeling锛屼簨鍔＄骇寤烘ā锛夋槸UVM涓粍浠堕棿閫氫俊鐨勬牳蹇冩満鍒躲€傚畠鎻愪緵浜嗕竴濂楁爣鍑嗗寲鐨勬帴鍙ｏ紝浣垮緱楠岃瘉缁勪欢鑳藉浠ヤ簨鍔★紙transaction锛変负鍗曚綅杩涜鏁版嵁浜ゆ崲锛岃€屾棤闇€鍏冲績搴曞眰瀹炵幇缁嗚妭銆?
### 鏍稿績鎬濇兂

- **瑙ｈ€?*锛氱敓浜ц€呭拰娑堣垂鑰呴€氳繃鎺ュ彛閫氫俊锛屽郊姝ょ嫭绔?- **鏍囧噯鍖?*锛氱粺涓€鐨勭鍙ｇ被鍨嬪拰鎺ュ彛鍗忚
- **鍙鐢?*锛氱粍浠跺彲鍦ㄤ笉鍚岀幆澧冧腑澶嶇敤锛屽彧瑕佹帴鍙ｅ尮閰?
### TLM閫氫俊涓夎绱?
| 瑕佺礌 | 璇存槑 |
|------|------|
| **Port锛堢鍙ｏ級** | 鍙戣捣閫氫俊璇锋眰鐨勪竴鏂?|
| **Export锛堝鍑虹鍙ｏ級** | 涓棿浼犻€掑眰 |
| **Imp锛堝疄鐜扮鍙ｏ級** | 瀹為檯瀹炵幇閫氫俊鏂规硶鐨勪竴鏂?|

## 2. 绔彛绫诲瀷

### 2.1 Port锛堢鍙ｏ級

Port鏄€氫俊鐨勫彂璧锋柟锛屽畾涔変簡缁勪欢瀵瑰鎻愪緵鐨勬帴鍙ｃ€?
```verilog
// 瀹氫箟port
class my_driver extends uvm_driver #(my_transaction);
  `uvm_component_utils(my_driver)

  // 鐢虫槑涓€涓猵ut绫诲瀷鐨刾ort
  uvm_put_port #(my_transaction) put_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    put_port = new("put_port", this);
  endfunction

  task run_phase(uvm_phase phase);
    my_transaction tr;
    // 閫氳繃port鍙戦€佷簨鍔?    put_port.put(tr);
  endtask
endclass
```

### 2.2 Export锛堝鍑虹鍙ｏ級

Export鏄腑闂村眰锛岀敤浜庤繛鎺ort鍜宨mp锛屽疄鐜板绾ц繛鎺ャ€?
```verilog
class my_agent extends uvm_agent;
  `uvm_component_utils(my_agent)

  // Agent鐨別xport锛屾毚闇茬粰澶栭儴
  uvm_put_export #(my_transaction) put_export;

  // 鍐呴儴driver鐨刾ort
  my_driver drv;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    put_export = new("put_export", this);
    drv = my_driver::type_id::create("drv", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // 灏唀xport杩炴帴鍒癲river鐨刾ort
    put_export.connect(drv.put_port);
  endfunction
endclass
```

### 2.3 Imp锛堝疄鐜扮鍙ｏ級

Imp鏄疄闄呭疄鐜伴€氫俊鏂规硶鐨勫湴鏂癸紝蹇呴』瀹炵幇瀵瑰簲鐨勬帴鍙ｆ柟娉曘€?
```verilog
class my_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(my_scoreboard)

  // 瀹炵幇put鎺ュ彛
  uvm_put_imp #(my_transaction, my_scoreboard) put_imp;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    put_imp = new("put_imp", this);
  endfunction

  // 蹇呴』瀹炵幇put鏂规硶
  task put(my_transaction t);
    `uvm_info("SCB", $sformatf("Received: %s", t.convert2string()), UVM_MEDIUM)
    // 姣旇緝閫昏緫
  endtask
endclass
```

### 2.4 绔彛杩炴帴瑙勫垯

```
Port 鈹€鈹€鈫?Export 鈹€鈹€鈫?Imp
锛堝彂璧锋柟锛? 锛堜腑闂村眰锛? 锛堝疄鐜版柟锛?```

杩炴帴浠ｇ爜鍦╜connect_phase`涓畬鎴愶細

```verilog
class my_env extends uvm_env;
  `uvm_component_utils(my_env)

  my_agent agent;
  my_scoreboard scb;

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Port -> Export -> Imp 鐨勫畬鏁磋繛鎺?    agent.put_export.connect(scb.put_imp);
  endfunction
endclass
```

## 3. 鎺ュ彛绫诲瀷

### 3.1 Put鎺ュ彛

鍗曞悜鏁版嵁浼犺緭锛屼粠port绔帹閫佸埌imp绔€?
```verilog
// put鎺ュ彛 - 闃诲寮?task put(T t);          // 鍙戦€佷簨鍔★紝闃诲鐩村埌瀹屾垚

// try_put - 闈為樆濉炲紡
function bit try_put(T t);  // 灏濊瘯鍙戦€侊紝绔嬪嵆杩斿洖鎴愬姛/澶辫触

// can_put - 妫€鏌ユ槸鍚﹀彲浠ut
function bit can_put();     // 妫€鏌ユ槸鍚﹀彲鍙戦€?```

**浣跨敤绀轰緥锛?*

```verilog
// Driver绔?task run_phase(uvm_phase phase);
  forever begin
    seq_item_port.get_next_item(req);
    // 鎺ㄩ€佸埌scoreboard
    put_port.put(req);
    seq_item_port.item_done();
  end
endtask

// Scoreboard绔?task put(my_transaction t);
  // 澶勭悊鎺ユ敹鍒扮殑浜嬪姟
  compare_queue.push_back(t);
endtask
```

### 3.2 Get鎺ュ彛

鍗曞悜鏁版嵁鑾峰彇锛屼粠imp绔媺鍙栨暟鎹埌port绔€?
```verilog
// get鎺ュ彛 - 闃诲寮?task get(output T t);       // 鑾峰彇浜嬪姟锛岄樆濉炵洿鍒版湁鏁版嵁

// try_get - 闈為樆濉炲紡
function bit try_get(output T t);  // 灏濊瘯鑾峰彇

// can_get - 妫€鏌ユ槸鍚﹀彲浠et
function bit can_get();            // 妫€鏌ユ槸鍚﹀彲鑾峰彇
```

**浣跨敤绀轰緥锛?*

```verilog
// Monitor绔紙鎻愪緵鏁版嵁锛?class my_monitor extends uvm_monitor;
  uvm_blocking_get_imp #(my_transaction, my_monitor) get_imp;

  task get(output my_transaction t);
    // 绛夊緟閲囬泦鍒版暟鎹?    @(posedge vif.valid);
    t = my_transaction::type_id::create("t");
    t.data = vif.data;
  endtask
endclass

// Scoreboard绔紙鑾峰彇鏁版嵁锛?class my_scoreboard extends uvm_scoreboard;
  uvm_blocking_get_port #(my_transaction) get_port;

  task run_phase(uvm_phase phase);
    my_transaction tr;
    forever begin
      get_port.get(tr);
      // 澶勭悊浜嬪姟
    end
  endtask
endclass
```

### 3.3 Peek鎺ュ彛

绫讳技Get锛屼絾涓嶇Щ闄ゆ暟鎹紙绐ユ帰锛夈€?
```verilog
// peek鎺ュ彛 - 闃诲寮?task peek(output T t);       // 绐ユ帰鏁版嵁浣嗕笉娑堣垂

// try_peek - 闈為樆濉炲紡
function bit try_peek(output T t);

// can_peek - 妫€鏌ユ槸鍚﹀彲浠eek
function bit can_peek();
```

### 3.4 Transport鎺ュ彛

鍙屽悜閫氫俊锛屽寘鍚姹傚拰鍝嶅簲銆?
```verilog
// transport鎺ュ彛 - 闃诲寮?task transport(input T req, output T rsp);  // 璇锋眰-鍝嶅簲

// nb_transport - 闈為樆濉炲紡
function bit nb_transport(input T req, output T rsp);
```

**浣跨敤绀轰緥锛?*

```verilog
// Driver绔彂璧穞ransport璇锋眰
task run_phase(uvm_phase phase);
  my_transaction req, rsp;
  forever begin
    seq_item_port.get_next_item(req);
    // 鍙戦€佽姹傚苟鎺ユ敹鍝嶅簲
    transport_port.transport(req, rsp);
    // 澶勭悊鍝嶅簲
    `uvm_info("DRV", $sformatf("Got response: %h", rsp.data), UVM_MEDIUM)
    seq_item_port.item_done();
  end
endtask

// Sequencer绔疄鐜皌ransport
task transport(input my_transaction req, output my_transaction rsp);
  // 澶勭悊璇锋眰锛岀敓鎴愬搷搴?  rsp = my_transaction::type_id::create("rsp");
  rsp.data = req.data + 1;
endtask
```

### 3.5 鎺ュ彛绫诲瀷姹囨€?
| 鎺ュ彛绫诲瀷 | 鏂瑰悜 | 闃诲鐗堟湰 | 闈為樆濉炵増鏈?| 妫€鏌ョ増鏈?|
|---------|------|---------|-----------|---------|
| **Put** | Port 鈫?Imp | `put()` | `try_put()` | `can_put()` |
| **Get** | Imp 鈫?Port | `get()` | `try_get()` | `can_get()` |
| **Peek** | Imp 鈫?Port | `peek()` | `try_peek()` | `can_peek()` |
| **Transport** | 鍙屽悜 | `transport()` | `nb_transport()` | - |

## 4. Analysis Port

Analysis Port鏄竴绉嶇壒娈婄殑骞挎挱绔彛锛屾敮鎸佷竴瀵瑰閫氫俊锛屽父鐢ㄤ簬瑕嗙洊鐜囨敹闆嗗拰缁撴灉妫€鏌ャ€?
### 4.1 鍩烘湰鐢ㄦ硶

```verilog
// Monitor绔?- 浣跨敤analysis port骞挎挱
class my_monitor extends uvm_monitor;
  `uvm_component_utils(my_monitor)

  // Analysis port澹版槑
  uvm_analysis_port #(my_transaction) ap;

  virtual my_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
  endfunction

  task run_phase(uvm_phase phase);
    my_transaction tr;
    forever begin
      @(posedge vif.clk);
      if (vif.valid) begin
        tr = my_transaction::type_id::create("tr");
        tr.data = vif.data;
        // 閫氳繃analysis port骞挎挱浜嬪姟
        ap.write(tr);
      end
    end
  endtask
endclass
```

### 4.2 澶氱鍙ｈ繛鎺?
```verilog
// Scoreboard绔?- 瀹炵幇write鏂规硶
class my_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(my_scoreboard)

  // Analysis imp澹版槑锛堟敞鎰忥細闇€瑕佹寚瀹氬疄鐜扮被锛?  uvm_analysis_imp #(my_transaction, my_scoreboard) ap_imp;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap_imp = new("ap_imp", this);
  endfunction

  // 瀹炵幇write鏂规硶
  function void write(my_transaction t);
    `uvm_info("SCB", $sformatf("Received: %h", t.data), UVM_MEDIUM)
    // 姣旇緝閫昏緫
  endfunction
endclass

// Coverage collector - 鍙︿竴涓猘nalysis port鐨勫疄鐜?class my_coverage extends uvm_subscriber #(my_transaction);
  `uvm_component_utils(my_coverage)

  covergroup my_cg;
    coverpoint data;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    my_cg = new();
  endfunction

  function void write(my_transaction t);
    my_cg.sample();
  endfunction
endclass
```

### 4.3 鍦‥nv涓繛鎺?
```verilog
class my_env extends uvm_env;
  `uvm_component_utils(my_env)

  my_agent agent;
  my_scoreboard scb;
  my_coverage cov;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = my_agent::type_id::create("agent", this);
    scb = my_scoreboard::type_id::create("scb", this);
    cov = my_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // 涓€涓猘nalysis port鍙互杩炴帴澶氫釜imp
    agent.monitor.ap.connect(scb.ap_imp);
    agent.monitor.ap.connect(cov.analysis_export);
  endfunction
endclass
```

## 5. TLM FIFO

TLM FIFO鎻愪緵浜嗗甫缂撳啿鐨勬暟鎹紶杈撻€氶亾锛岃В鑰︾敓浜ц€呭拰娑堣垂鑰呯殑閫熺巼銆?
### 5.1 鍩烘湰鐢ㄦ硶

```verilog
class my_env extends uvm_env;
  `uvm_component_utils(my_env)

  // TLM FIFO澹版槑
  uvm_tlm_fifo #(my_transaction) fifo;

  my_producer prod;
  my_consumer cons;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // 鍒涘缓FIFO锛屾寚瀹氱紦鍐叉繁搴?    fifo = new("fifo", this, 16);  // 娣卞害涓?6
    prod = my_producer::type_id::create("prod", this);
    cons = my_consumer::type_id::create("cons", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // 杩炴帴鐢熶骇鑰呭埌FIFO鐨刾ut绔彛
    prod.out_port.connect(fifo.put_export);
    // 杩炴帴娑堣垂鑰呭埌FIFO鐨刧et绔彛
    cons.in_port.connect(fifo.get_export);
  endfunction
endclass
```

### 5.2 FIFO鎺ュ彛鏂规硶

```verilog
// FIFO鎻愪緵鐨勬帴鍙?uvm_put_imp        put_export;    // put鎺ュ彛瀹炵幇
uvm_get_imp        get_export;    // get鎺ュ彛瀹炵幇
uvm_peek_imp       peek_export;   // peek鎺ュ彛瀹炵幇

// FIFO鏌ヨ鏂规硶
function int used();      // 宸蹭娇鐢ㄧ┖闂?function int size();      // FIFO鎬诲ぇ灏?function bit is_empty();  // 鏄惁涓虹┖
function bit is_full();   // 鏄惁宸叉弧

// 闃诲鎿嶄綔
task put(T t);           // 婊℃椂闃诲
task get(output T t);    // 绌烘椂闃诲
task peek(output T t);   // 绌烘椂闃诲

// 闈為樆濉炴搷浣?function bit try_put(T t);
function bit try_get(output T t);
function bit try_peek(output T t);
```

### 5.3 Analysis FIFO

涓撶敤浜巃nalysis port鐨凢IFO锛屾敮鎸乣write`鏂规硶銆?
```verilog
class my_env extends uvm_env;
  `uvm_component_utils(my_env)

  // Analysis FIFO
  uvm_tlm_analysis_fifo #(my_transaction) analysis_fifo;

  my_monitor mon;
  my_scoreboard scb;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_fifo = new("analysis_fifo", this);
    mon = my_monitor::type_id::create("mon", this);
    scb = my_scoreboard::type_id::create("scb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Monitor鐨刟nalysis port杩炴帴鍒癮nalysis FIFO
    mon.ap.connect(analysis_fifo.analysis_export);
    // Scoreboard浠嶧IFO鑾峰彇鏁版嵁
    scb.get_port.connect(analysis_fifo.get_export);
  endfunction
endclass
```

## 6. 闃诲涓庨潪闃诲閫氫俊

### 6.1 闃诲閫氫俊

闃诲鏂瑰紡浼氱瓑寰呮搷浣滃畬鎴愭墠杩斿洖銆?
```verilog
// 闃诲put - 濡傛灉鐩爣婊″垯绛夊緟
task put(my_transaction t);
  while (is_full()) begin
    @(posedge clk);  // 绛夊緟鏃堕挓鍛ㄦ湡
  end
  buffer.push_back(t);
endtask

// 闃诲get - 濡傛灉婧愮┖鍒欑瓑寰?task get(output my_transaction t);
  while (is_empty()) begin
    @(posedge clk);
  end
  t = buffer.pop_front();
endtask
```

### 6.2 闈為樆濉為€氫俊

闈為樆濉炴柟寮忕珛鍗宠繑鍥烇紝閫氳繃杩斿洖鍊艰〃绀烘搷浣滅粨鏋溿€?
```verilog
// 闈為樆濉瀙ut - 绔嬪嵆杩斿洖
function bit try_put(my_transaction t);
  if (is_full()) begin
    return 0;  // 澶辫触
  end
  buffer.push_back(t);
  return 1;    // 鎴愬姛
endfunction

// 闈為樆濉瀏et - 绔嬪嵆杩斿洖
function bit try_get(output my_transaction t);
  if (is_empty()) begin
    return 0;  // 澶辫触
  end
  t = buffer.pop_front();
  return 1;    // 鎴愬姛
endfunction
```

### 6.3 浣跨敤寤鸿

| 鍦烘櫙 | 鎺ㄨ崘鏂瑰紡 | 鍘熷洜 |
|------|---------|------|
| Driver鑾峰彇浜嬪姟 | 闃诲 | 蹇呴』绛夊緟浜嬪姟鍒版潵 |
| Monitor骞挎挱 | 闃诲 | 纭繚鏁版嵁瀹屾暣浼犺緭 |
| 妫€鏌ョ紦鍐插尯鐘舵€?| 闈為樆濉?| 閬垮厤姝婚攣 |
| 瓒呮椂澶勭悊 | 闈為樆濉?| 瀹炵幇瓒呮椂鏈哄埗 |

## 7. 甯歌搴旂敤绀轰緥

### 7.1 瀹屾暣鐨凙gent缁撴瀯

```verilog
class my_agent extends uvm_agent;
  `uvm_component_utils(my_agent)

  my_driver    drv;
  my_monitor   mon;
  uvm_sequencer #(my_transaction) sqr;

  // 瀵瑰鎺ュ彛
  uvm_analysis_port #(my_transaction) ap;  // Monitor鏁版嵁鍑哄彛
  uvm_seq_item_pull_port #(my_transaction) seq_item_port;  // Sequencer鎺ュ彛

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = my_monitor::type_id::create("mon", this);
    if (get_is_active() == UVM_ACTIVE) begin
      drv = my_driver::type_id::create("drv", this);
      sqr = uvm_sequencer#(my_transaction)::type_id::create("sqr", this);
    end
    ap = new("ap", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Monitor鐨刟nalysis port杩炴帴鍒癮gent鐨刟p
    mon.ap.connect(ap);
    // Driver杩炴帴鍒癝equencer
    if (get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(sqr.seq_item_export);
    end
  endfunction
endclass
```

### 7.2 Scoreboard瀹炵幇

```verilog
class my_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(my_scoreboard)

  // 鏈熸湜鍊煎拰瀹為檯鍊肩殑analysis imp
  uvm_analysis_imp_decl(_expected)
  uvm_analysis_imp_decl(_actual)

  uvm_analysis_imp_expected #(my_transaction, my_scoreboard) exp_imp;
  uvm_analysis_imp_actual #(my_transaction, my_scoreboard) act_imp;

  // 浜嬪姟闃熷垪
  my_transaction exp_queue[$];
  my_transaction act_queue[$];

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    exp_imp = new("exp_imp", this);
    act_imp = new("act_imp", this);
  endfunction

  // 鎺ユ敹鏈熸湜浜嬪姟
  function void write_expected(my_transaction t);
    exp_queue.push_back(t);
    compare();
  endfunction

  // 鎺ユ敹瀹為檯浜嬪姟
  function void write_actual(my_transaction t);
    act_queue.push_back(t);
    compare();
  endfunction

  // 姣旇緝閫昏緫
  function void compare();
    my_transaction exp, act;
    while (exp_queue.size() > 0 && act_queue.size() > 0) begin
      exp = exp_queue.pop_front();
      act = act_queue.pop_front();
      if (!exp.compare(act)) begin
        `uvm_error("SCB", $sformatf("Mismatch! Exp: %h, Act: %h", exp.data, act.data))
      end
    end
  endfunction
endclass
```

### 7.3 澶氱骇缁勪欢杩炴帴

```verilog
class my_subsystem extends uvm_component;
  `uvm_component_utils(my_subsystem)

  my_agent agent;
  my_scoreboard scb;
  uvm_tlm_fifo #(my_transaction) fifo;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = my_agent::type_id::create("agent", this);
    scb = my_scoreboard::type_id::create("scb", this);
    fifo = new("fifo", this, 8);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Monitor -> FIFO -> Scoreboard
    agent.ap.connect(fifo.put_export);
    scb.get_port.connect(fifo.get_export);
  endfunction
endclass
```

## 8. 涓嶶VM缁勪欢鐨勯泦鎴?
### 8.1 UVM缁勪欢涓殑鏍囧噯TLM绔彛

| 缁勪欢 | 鏍囧噯绔彛 | 鐢ㄩ€?|
|------|---------|------|
| **Driver** | `seq_item_port` | 浠嶴equencer鑾峰彇浜嬪姟 |
| **Sequencer** | `seq_item_export` | 鍚慏river鎻愪緵浜嬪姟 |
| **Monitor** | `ap` (analysis port) | 骞挎挱閲囬泦鍒扮殑浜嬪姟 |
| **Scoreboard** | `analysis_imp` | 鎺ユ敹浜嬪姟杩涜姣旇緝 |

### 8.2 Sequencer-Driver杩炴帴

```verilog
class my_driver extends uvm_driver #(my_transaction);
  `uvm_component_utils(my_driver)

  task run_phase(uvm_phase phase);
    forever begin
      // 浠嶴equencer鑾峰彇涓嬩竴涓簨鍔?      seq_item_port.get_next_item(req);
      `uvm_info("DRV", $sformatf("Driving: %h", req.data), UVM_HIGH)

      // 椹卞姩鍒版帴鍙?      @(posedge vif.clk);
      vif.data <= req.data;
      vif.valid <= 1'b1;
      @(posedge vif.clk);
      vif.valid <= 1'b0;

      // 閫氱煡Sequencer浜嬪姟瀹屾垚
      seq_item_port.item_done();
    end
  endtask
endclass

class my_env extends uvm_env;
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Driver杩炴帴鍒癝equencer
    agent.drv.seq_item_port.connect(agent.sqr.seq_item_export);
  endfunction
endclass
```

### 8.3 浣跨敤uvm_subscriber

`uvm_subscriber`鏄笓闂ㄧ敤浜巃nalysis port瀹炵幇鐨勫熀绫汇€?
```verilog
class my_coverage_collector extends uvm_subscriber #(my_transaction);
  `uvm_component_utils(my_coverage_collector)

  my_transaction tr;

  covergroup cg;
    coverpoint tr.data {
      bins low  = {[0:8'h3F]};
      bins mid  = {[8'h40:8'hBF]};
      bins high = {[8'hC0:8'hFF]};
    }
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg = new();
  endfunction

  // 瀹炵幇write鏂规硶锛坲vm_subscriber瑕佹眰锛?  function void write(my_transaction t);
    tr = t;
    cg.sample();
  endfunction
endclass

// 杩炴帴
monitor.ap.connect(cov_collector.analysis_export);
```

## 9. 鏈€浣冲疄璺?
### 9.1 绔彛鍛藉悕瑙勮寖

```verilog
// 鎺ㄨ崘鍛藉悕
uvm_analysis_port #(my_transaction) ap;              // Analysis port
uvm_put_port #(my_transaction) put_port;              // Put port
uvm_get_port #(my_transaction) get_port;              // Get port
uvm_tlm_fifo #(my_transaction) fifo;                  // FIFO
uvm_analysis_imp #(my_transaction, my_class) ap_imp;  // Analysis imp
```

### 9.2 甯歌閿欒

**閿欒1锛氬繕璁板疄鐜版帴鍙ｆ柟娉?*

```verilog
// 閿欒锛歶vm_put_imp娌℃湁瀹炵幇put鏂规硶
class bad_scoreboard extends uvm_scoreboard;
  uvm_put_imp #(my_transaction, bad_scoreboard) put_imp;
  // 缂哄皯 task put(my_transaction t) 瀹炵幇锛?endclass
```

**閿欒2锛歛nalysis_imp澶氱鍙ｉ棶棰?*

```verilog
// 閿欒锛氬悓涓€涓被浣跨敤涓や釜鐩稿悓绫诲瀷鐨刟nalysis_imp
class bad_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp #(my_transaction, bad_scoreboard) exp_imp;
  uvm_analysis_imp #(my_transaction, bad_scoreboard) act_imp;
  // 涓や釜imp鐨剋rite鏂规硶浼氬啿绐侊紒
endclass

// 姝ｇ‘锛氫娇鐢ㄥ畯澹版槑涓嶅悓鍚庣紑
`uvm_analysis_imp_decl(_expected)
`uvm_analysis_imp_decl(_actual)

class good_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp_expected #(my_transaction, good_scoreboard) exp_imp;
  uvm_analysis_imp_actual #(my_transaction, good_scoreboard) act_imp;
endclass
```

**閿欒3锛氳繛鎺ラ『搴忛敊璇?*

```verilog
// 閿欒锛氬湪build_phase涓繛鎺?function void build_phase(uvm_phase phase);
  agent.ap.connect(scb.ap_imp);  // 杩囨棭锛?endfunction

// 姝ｇ‘锛氬湪connect_phase涓繛鎺?function void connect_phase(uvm_phase phase);
  agent.ap.connect(scb.ap_imp);
endfunction
```

### 9.3 璋冭瘯鎶€宸?
```verilog
// 妫€鏌ヨ繛鎺ョ姸鎬?function void connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  agent.ap.connect(scb.ap_imp);

  // 鎵撳嵃杩炴帴淇℃伅
  `uvm_info("ENV", $sformatf("Agent AP size: %0d", agent.ap.size()), UVM_LOW)
endfunction

// 浣跨敤UVM鎷撴墤鎵撳嵃
initial begin
  uvm_top.print_topology();
end
```

## 10. 鐩稿叧閾炬帴

- [[02-UVM/00-鍏ラ棬|UVM鍏ラ棬]]
- [[02-UVM/03-Sequence鏈哄埗|Sequence鏈哄埗]]
- [[02-UVM/04-缁勪欢|UVM缁勪欢]]
- [[05-Verification/UVM-Template/UVM-Analysis-Port鏁版嵁娴亅UVM Analysis Port鏁版嵁娴乚]
- [[05-Verification/UVM-Template/uvm_analysis_imp澶氱鍙ｉ櫡闃眧uvm_analysis_imp澶氱鍙ｉ櫡闃盷]

