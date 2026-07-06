---
tags:
  - uvm
  - testbench
  - verification
date: {{date}}
---

# 馃И {{title}} - UVM Testbench

> [!info]- 馃搵 Testbench 淇℃伅
> | 灞炴€?| 鍊?| 灞炴€?| 鍊?|
> |------|-----|------|-----|
> | **Testbench 鍚?* | `{{title}}` | **鍒涘缓鏃ユ湡** | {{date}} |
> | **DUT** | | **浣滆€?* | muyuEDA |
> | **楠岃瘉鐩爣** | | **鐘舵€?* | |

---

## 馃搻 鏋舵瀯姒傝

> [!abstract]- 馃彈锔?绯荤粺鏋舵瀯
> ```
> 鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?> 鈹?                     Testbench Top                       鈹?> 鈹? 鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹? 鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹? 鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹? 鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?  鈹?> 鈹? 鈹? Test    鈹? 鈹? Env    鈹? 鈹? Agent  鈹? 鈹? Scorebd鈹?  鈹?> 鈹? 鈹斺攢鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹€鈹? 鈹斺攢鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹? 鈹斺攢鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹? 鈹斺攢鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹?  鈹?> 鈹?      鈹?            鈹?           鈹?            鈹?        鈹?> 鈹? 鈹屸攢鈹€鈹€鈹€鈻尖攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈻尖攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈻尖攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈻尖攢鈹€鈹€鈹€鈹?  鈹?> 鈹? 鈹?                 Interface                        鈹?  鈹?> 鈹? 鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?  鈹?> 鈹?                        鈹?                               鈹?> 鈹? 鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈻尖攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?  鈹?> 鈹? 鈹?                   DUT                            鈹?  鈹?> 鈹? 鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?  鈹?> 鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?> ```

---

## 馃摝 缁勪欢娓呭崟

> [!note]- 馃З UVM 缁勪欢
> | 缁勪欢 | 绫诲瀷 | 绫诲悕 | 璇存槑 |
> |------|------|------|------|
> | **Environment** | uvm_env | `{{title}}_env` | 鐜绫伙紝鍖呭惈鎵€鏈夌粍浠?|
> | **Agent** | uvm_agent | `{{title}}_agent` | 浠ｇ悊绫伙紝灏佽 driver/monitor |
> | **Driver** | uvm_driver | `{{title}}_driver` | 椹卞姩绫伙紝椹卞姩 DUT 淇″彿 |
> | **Monitor** | uvm_monitor | `{{title}}_monitor` | 鐩戞帶绫伙紝鐩戞帶 DUT 淇″彿 |
> | **Scoreboard** | uvm_scoreboard | `{{title}}_scoreboard` | 璁板垎鏉匡紝楠岃瘉缁撴灉 |
> | **Sequence** | uvm_sequence | `{{title}}_sequence` | 搴忓垪绫伙紝鐢熸垚婵€鍔?|

---

## 馃摑 缁勪欢浠ｇ爜

> [!code]- 馃捇 Environment 绫?> ```systemverilog
> // {{title}}_env.sv
> // UVM Environment 绫?> // 鍔熻兘: 闆嗘垚鎵€鏈夐獙璇佺粍浠?>
> class {{title}}_env extends uvm_env;
>   `uvm_component_utils({{title}}_env)
>
>   // 缁勪欢鍙ユ焺
>   {{title}}_agent      agent;
>   {{title}}_scoreboard sb;
>
>   // 鏋勯€犲嚱鏁?>   function new(string name = "{{title}}_env", uvm_component parent = null);
>     super.new(name, parent);
>   endfunction
>
>   // 鏋勫缓闃舵
>   virtual function void build_phase(uvm_phase phase);
>     super.build_phase(phase);
>     // 鍒涘缓缁勪欢
>     agent = {{title}}_agent::type_id::create("agent", this);
>     sb = {{title}}_scoreboard::type_id::create("sb", this);
>   endfunction
>
>   // 杩炴帴闃舵
>   virtual function void connect_phase(uvm_phase phase);
>     super.connect_phase(phase);
>     // 杩炴帴 monitor 鍒?scoreboard
>     agent.monitor.item_collected_port.connect(sb.item_export);
>   endfunction
>
> endclass
> ```

> [!code]- 馃捇 Agent 绫?> ```systemverilog
> // {{title}}_agent.sv
> // UVM Agent 绫?> // 鍔熻兘: 灏佽 driver 鍜?monitor
>
> class {{title}}_agent extends uvm_agent;
>   `uvm_component_utils({{title}}_agent)
>
>   // 缁勪欢鍙ユ焺
>   {{title}}_driver  driver;
>   {{title}}_monitor monitor;
>   uvm_sequencer#({{title}}_transaction) sequencer;
>
>   // 鏋勯€犲嚱鏁?>   function new(string name = "{{title}}_agent", uvm_component parent = null);
>     super.new(name, parent);
>   endfunction
>
>   // 鏋勫缓闃舵
>   virtual function void build_phase(uvm_phase phase);
>     super.build_phase(phase);
>     if (get_is_active() == UVM_ACTIVE) begin
>       driver = {{title}}_driver::type_id::create("driver", this);
>       sequencer = uvm_sequencer#({{title}}_transaction)::type_id::create("sequencer", this);
>     end
>     monitor = {{title}}_monitor::type_id::create("monitor", this);
>   endfunction
>
>   // 杩炴帴闃舵
>   virtual function void connect_phase(uvm_phase phase);
>     super.connect_phase(phase);
>     if (get_is_active() == UVM_ACTIVE) begin
>       driver.seq_item_port.connect(sequencer.seq_item_export);
>     end
>   endfunction
>
> endclass
> ```

> [!code]- 馃捇 Driver 绫?> ```systemverilog
> // {{title}}_driver.sv
> // UVM Driver 绫?> // 鍔熻兘: 椹卞姩 DUT 淇″彿
>
> class {{title}}_driver extends uvm_driver#({{title}}_transaction);
>   `uvm_component_utils({{title}}_driver)
>
>   // 铏氭帴鍙ｅ彞鏌?>   virtual {{title}}_if vif;
>
>   // 鏋勯€犲嚱鏁?>   function new(string name = "{{title}}_driver", uvm_component parent = null);
>     super.new(name, parent);
>   endfunction
>
>   // 鏋勫缓闃舵
>   virtual function void build_phase(uvm_phase phase);
>     super.build_phase(phase);
>     // 鑾峰彇铏氭帴鍙?>     if (!uvm_config_db#(virtual {{title}}_if)::get(this, "", "vif", vif)) begin
>       `uvm_fatal("NOVIF", "Virtual interface not defined")
>     end
>   endfunction
>
>   // 杩愯闃舵
>   virtual task run_phase(uvm_phase phase);
>     forever begin
>       seq_item_port.get_next_item(req);
>       drive_item(req);
>       seq_item_port.item_done();
>     end
>   endtask
>
>   // 椹卞姩浜嬪姟
>   virtual task drive_item({{title}}_transaction tr);
>     // TODO: 瀹炵幇椹卞姩閫昏緫
>   endtask
>
> endclass
> ```

---

## 馃И 娴嬭瘯鐢ㄤ緥

> [!example]- 馃搵 娴嬭瘯鍒楄〃
> | 娴嬭瘯鍚?| 鎻忚堪 | 绫诲瀷 | 鐘舵€?|
> |--------|------|------|------|
> | `{{title}}_basic_test` | 鍩烘湰鍔熻兘娴嬭瘯 | 鍔熻兘 | 猬?寰呰繍琛?|
> | `{{title}}_random_test` | 闅忔満娴嬭瘯 | 闅忔満 | 猬?寰呰繍琛?|
> | `{{title}}_corner_test` | 杈圭晫鏉′欢娴嬭瘯 | 杈圭晫 | 猬?寰呰繍琛?|
> | `{{title}}_error_test` | 寮傚父澶勭悊娴嬭瘯 | 寮傚父 | 猬?寰呰繍琛?|

> [!code]- 馃捇 鍩烘湰娴嬭瘯绫?> ```systemverilog
> // {{title}}_basic_test.sv
> // 鍩烘湰鍔熻兘娴嬭瘯
>
> class {{title}}_basic_test extends uvm_test;
>   `uvm_component_utils({{title}}_basic_test)
>
>   {{title}}_env env;
>
>   function new(string name = "{{title}}_basic_test", uvm_component parent = null);
>     super.new(name, parent);
>   endfunction
>
>   virtual function void build_phase(uvm_phase phase);
>     super.build_phase(phase);
>     env = {{title}}_env::type_id::create("env", this);
>   endfunction
>
>   virtual task run_phase(uvm_phase phase);
>     {{title}}_basic_sequence seq;
>     phase.raise_objection(this);
>
>     seq = {{title}}_basic_sequence::type_id::create("seq");
>     seq.start(env.agent.sequencer);
>
>     phase.drop_objection(this);
>   endtask
>
> endclass
> ```

---

## 馃敡 浠跨湡鍛戒护

> [!tip]- 馃捇 杩愯浠跨湡
> ```bash
> # 杩涘叆椤圭洰鐩綍
> cd /home/muyuEDA/<椤圭洰鐩綍>
>
> # 缂栬瘧骞惰繍琛屼豢鐪?> xrun \
>   +incdir+./sv \
>   +incdir+./tb \
>   -uvm \
>   -access +r \
>   -gui \
>   -sv_seed random \
>   {{title}}_top.sv
> ```

> [!tip]- 馃捇 杩愯鐗瑰畾娴嬭瘯
> ```bash
> # 杩愯鍩烘湰娴嬭瘯
> xrun {{title}}_top.sv -uvm -access +r +UVM_TESTNAME={{title}}_basic_test -exit
>
> # 杩愯闅忔満娴嬭瘯
> xrun {{title}}_top.sv -uvm -access +r +UVM_TESTNAME={{title}}_random_test -sv_seed random -exit
> ```

---

## 馃搨 鏂囦欢缁撴瀯

> [!abstract]- 馃搧 椤圭洰缁撴瀯
> ```
> 馃搧 {{title}}/
> 鈹溾攢鈹€ 馃搧 sv/                    鈫?SV 婧愭枃浠?> 鈹?  鈹溾攢鈹€ {{title}}_pkg.sv      鈫?鍖呭畾涔?> 鈹?  鈹溾攢鈹€ {{title}}_if.sv       鈫?鎺ュ彛瀹氫箟
> 鈹?  鈹斺攢鈹€ {{title}}_top.sv      鈫?椤跺眰妯″潡
> 鈹溾攢鈹€ 馃搧 tb/                    鈫?Testbench 鏂囦欢
> 鈹?  鈹溾攢鈹€ {{title}}_env.sv      鈫?鐜绫?> 鈹?  鈹溾攢鈹€ {{title}}_agent.sv    鈫?浠ｇ悊绫?> 鈹?  鈹溾攢鈹€ {{title}}_driver.sv   鈫?椹卞姩绫?> 鈹?  鈹溾攢鈹€ {{title}}_monitor.sv  鈫?鐩戞帶绫?> 鈹?  鈹溾攢鈹€ {{title}}_sb.sv       鈫?璁板垎鏉?> 鈹?  鈹斺攢鈹€ {{title}}_seq.sv      鈫?搴忓垪绫?> 鈹溾攢鈹€ 馃搧 tests/                 鈫?娴嬭瘯鐢ㄤ緥
> 鈹?  鈹斺攢鈹€ {{title}}_test.sv     鈫?娴嬭瘯绫?> 鈹斺攢鈹€ 馃搧 waveforms/             鈫?娉㈠舰鏂囦欢
> ```

---

## 馃搳 瑕嗙洊鐜囩洰鏍?
> [!summary]- 馃搱 瑕嗙洊鐜囨寚鏍?> | 瑕嗙洊绫诲瀷 | 鐩爣 | 瀹為檯 | 鐘舵€?|
> |----------|------|------|------|
> | 浠ｇ爜瑕嗙洊鐜?| 95% | | 猬?|
> | 鍔熻兘瑕嗙洊鐜?| 90% | | 猬?|
> | 鏂█瑕嗙洊鐜?| 85% | | 猬?|

---

## 馃摎 鍙傝€冭祫鏂?
> [!reference]- 馃摉 瀛︿範璧勬簮
> - [[UVM鏋舵瀯]]
> - [[UVM缁勪欢]]
> - [[Sequence鏈哄埗]]
> - [[UVM鏈€浣冲疄璺礭]

---

> [!note]- 馃摑 浣跨敤璇存槑
> **妯℃澘浣跨敤鎸囧崡锛?*
> 1. 濉啓 Testbench 鍩烘湰淇℃伅
> 2. 鏍规嵁鏋舵瀯鍥惧疄鐜板悇缁勪欢
> 3. 鍙傝€冧唬鐮佹ā鏉垮垱寤虹粍浠?> 4. 缂栧啓娴嬭瘯鐢ㄤ緥
> 5. 杩愯浠跨湡骞舵敹闆嗚鐩栫巼
>
> **UVM 缁勪欢灞傛锛?*
> - Test 鈫?Environment 鈫?Agent 鈫?Driver/Monitor
> - Sequence 鈫?Sequencer 鈫?Driver
> - Monitor 鈫?Scoreboard
>
> **甯哥敤鍛戒护锛?*
> - `+UVM_TESTNAME=<test>` 鎸囧畾娴嬭瘯
> - `+UVM_VERBOSITY=UVM_HIGH` 璁剧疆璇︾粏绾у埆
> - `-sv_seed random` 闅忔満绉嶅瓙

---

*鏈€鍚庢洿鏂帮細{{date}}*

