---
tags: [Tools, Verdi, 娉㈠舰, 璋冭瘯, Synopsys, 鏍稿績]
---

# Verdi 娉㈠舰璋冭瘯绗旇

## 1. Verdi 姒傝堪鍜岀壒鐐?
Verdi 鏄?Synopsys 鍏徃寮€鍙戠殑涓撲笟绾ц皟璇曞伐鍏凤紝骞挎硾鐢ㄤ簬鏁板瓧IC璁捐鐨勬尝褰㈡煡鐪嬪拰婧愮爜璋冭瘯銆?
### 鏍稿績鐗圭偣

- **楂樻€ц兘娉㈠舰鏌ョ湅**锛氭敮鎸?FSDB銆乂CD銆丼HM 绛夊绉嶆尝褰㈡牸寮?- **婧愮爜绾ц皟璇?*锛氭敮鎸?RTL 婧愮爜涓庢尝褰㈢殑鍙屽悜鍏宠仈
- **鏅鸿兘杩借釜**锛欴river/Load 杩借釜鍔熻兘蹇€熷畾浣嶄俊鍙烽┍鍔ㄥ叧绯?- **Transaction 绾ц皟璇?*锛氭敮鎸?UVM Transaction 鐨勫彲瑙嗗寲鍒嗘瀽
- **瑕嗙洊鐜囬泦鎴?*锛氫笌 VCS 瑕嗙洊鐜囨暟鎹棤缂濋泦鎴?- **鑴氭湰鑷姩鍖?*锛氭敮鎸?TCL 鑴氭湰瀹炵幇鑷姩鍖栬皟璇曟祦绋?
### 鏀寔鐨勬尝褰㈡牸寮?
| 鏍煎紡 | 璇存槑 | 鐗圭偣 |
|------|------|------|
| FSDB | Fast Signal Database | 鏈€甯哥敤锛屽帇缂╃巼楂橈紝Verdi 鍘熺敓鏍煎紡 |
| VCD | Value Change Dump | 鏍囧噯鏍煎紡锛屽吋瀹规€уソ |
| SHM | Cadence 鏍煎紡 | 鐢ㄤ簬 Cadence 宸ュ叿閾?|
| VPD | VCS PlusDump | VCS 榛樿鏍煎紡 |

---

## 2. 鍚姩鍜屽姞杞芥尝褰?
### 2.1 鍛戒护琛屽惎鍔?
```bash
# 鍩烘湰鍚姩
verdi &

# 鍔犺浇璁捐搴?verdi -dbdir simv.daidir &

# 鍔犺浇 FSDB 娉㈠舰
verdi -ssf waveform.fsdb &

# 鍔犺浇璁捐鍜屾尝褰?verdi -dbdir simv.daidir -ssf waveform.fsdb &

# 鎸囧畾 top 妯″潡
verdi -top worklib.top_module:sv -ssf waveform.fsdb &

# 鍔犺浇 Verilog 婧愮爜
verdi -sv -f filelist.f -ssf waveform.fsdb &
```

### 2.2 VCS 鑱斿悎鍚姩

```bash
# VCS 缂栬瘧鏃剁敓鎴?FSDB
vcs -full64 -sverilog -debug_access+all -kdb -lca source.sv

# 浠跨湡鏃剁敓鎴?FSDB
./simv +fsdb+dumpfile+waveform.fsdb

# 鍚姩 Verdi 鍔犺浇娉㈠舰
verdi -dbdir simv.daidir -ssf waveform.fsdb &
```

### 2.3 鍥惧舰鐣岄潰鍔犺浇

1. 鍚姩 Verdi 鍚庯紝閫夋嫨 `File` -> `Open`
2. 閫夋嫨娉㈠舰鏂囦欢锛?fsdb/.vcd锛?3. 鍦?Signal Browser 涓€夋嫨瑕佹煡鐪嬬殑妯″潡
4. 鍙屽嚮淇″彿娣诲姞鍒版尝褰㈢獥鍙?
---

## 3. 甯哥敤蹇嵎閿?
### 3.1 娉㈠舰瀵艰埅

| 蹇嵎閿?| 鍔熻兘 |
|--------|------|
| `Ctrl + F` | 鎼滅储淇″彿 |
| `n` / `N` | 璺宠浆鍒颁笅涓€涓?涓婁竴涓彉鍖栨部 |
| `鈫恅 / `鈫抈 | 宸﹀彸绉诲姩鏃堕棿杞?|
| `Shift + 鈫恅 / `Shift + 鈫抈 | 澶ф绉诲姩鏃堕棿杞?|
| `Home` / `End` | 璺宠浆鍒版尝褰㈣捣濮?缁撴潫浣嶇疆 |
| `Ctrl + 榧犳爣婊氳疆` | 姘村钩缂╂斁 |
| `Shift + 榧犳爣婊氳疆` | 鍨傜洿缂╂斁 |
| `z` | 妗嗛€夋斁澶?|
| `u` | 鎾ら攢缂╂斁 |

### 3.2 淇″彿鎿嶄綔

| 蹇嵎閿?| 鍔熻兘 |
|--------|------|
| `g` | 淇″彿鍒嗙粍 |
| `Ctrl + g` | 鍙栨秷鍒嗙粍 |
| `Ctrl + 榧犳爣宸﹂敭` | 澶氶€変俊鍙?|
| `Delete` | 鍒犻櫎閫変腑淇″彿 |
| `Ctrl + a` | 鍏ㄩ€変俊鍙?|
| `Ctrl + d` | 澶嶅埗淇″彿 |

### 3.3 鏍囪鍜屼功绛?
| 蹇嵎閿?| 鍔熻兘 |
|--------|------|
| `m` | 鍦ㄥ綋鍓嶄綅缃坊鍔犳爣璁?|
| `M` | 娣诲姞甯︽敞閲婄殑鏍囪 |
| `Ctrl + m` | 绠＄悊鎵€鏈夋爣璁?|
| `F2` | 璺宠浆鍒颁笅涓€涓爣璁?|
| `Shift + F2` | 璺宠浆鍒颁笂涓€涓爣璁?|

### 3.4 瑙嗗浘鎺у埗

| 蹇嵎閿?| 鍔熻兘 |
|--------|------|
| `Ctrl + t` | 鎵撳紑 Transaction 瑙嗗浘 |
| `Ctrl + s` | 鎵撳紑婧愮爜绐楀彛 |
| `Ctrl + w` | 鎵撳紑娉㈠舰绐楀彛 |
| `Ctrl + b` | 鎵撳紑鏂偣绐楀彛 |
| `F5` | 鍒锋柊娉㈠舰 |

---

## 4. 淇″彿娣诲姞鍜屽垎缁?
### 4.1 淇″彿娣诲姞鏂规硶

#### 鏂规硶涓€锛氫粠 Signal Browser 娣诲姞

1. 鍦ㄥ乏渚?Signal Browser 闈㈡澘灞曞紑妯″潡灞傛
2. 閫変腑鐩爣淇″彿
3. 鍙屽嚮鎴栨嫋鎷藉埌娉㈠舰绐楀彛

#### 鏂规硶浜岋細浣跨敤淇″彿鎼滅储

1. 鎸?`Ctrl + F` 鎵撳紑鎼滅储妗?2. 杈撳叆淇″彿鍚嶇О锛堟敮鎸侀€氶厤绗?`*` 鍜?`?`锛?3. 鐐瑰嚮鎼滅储缁撴灉涓殑淇″彿

#### 鏂规硶涓夛細浠庢簮鐮佹坊鍔?
1. 鍦ㄦ簮鐮佺獥鍙ｄ腑鎵惧埌鐩爣淇″彿
2. 鍙抽敭閫夋嫨 `Add to Waveform`
3. 鎴栫洿鎺ユ嫋鎷戒俊鍙峰悕鍒版尝褰㈢獥鍙?
#### 鏂规硶鍥涳細閫氳繃 TCL 鍛戒护娣诲姞

```tcl
# 娣诲姞鍗曚釜淇″彿
verdiSetSignalAdd -name "top.dut.clk"

# 娣诲姞鎬荤嚎淇″彿
verdiSetBusAdd -name "top.dut.data[7:0]"

# 娣诲姞妯″潡鎵€鏈変俊鍙?verdiSetModuleAdd -name "top.dut"
```

### 4.2 淇″彿鍒嗙粍

#### 鍒涘缓鍒嗙粍

1. 閫変腑澶氫釜淇″彿锛坄Ctrl + 榧犳爣宸﹂敭`锛?2. 鍙抽敭閫夋嫨 `Group` -> `Create Group`
3. 杈撳叆鍒嗙粍鍚嶇О

#### 鍒嗙粍鎿嶄綔

```tcl
# 鍒涘缓鍒嗙粍
verdiGroupCreate -name "Control Signals" -signals {top.clk top.rst top.en}

# 灞曞紑/鎶樺彔鍒嗙粍
verdiGroupExpand -name "Control Signals"
verdiGroupCollapse -name "Control Signals"

# 鍒犻櫎鍒嗙粍
verdiGroupDelete -name "Control Signals"
```

#### 淇″彿鎺掑簭

- `Ctrl + 鈫慲 / `Ctrl + 鈫揱锛氫笂涓嬬Щ鍔ㄩ€変腑淇″彿
- 鍙抽敭鑿滃崟 -> `Sort` -> 鎸夊悕绉?灞傛鎺掑簭

---

## 5. 鏂偣璁剧疆鏂规硶

### 5.1 婧愮爜鏂偣

#### 璁剧疆鏂偣

1. 鍦ㄦ簮鐮佺獥鍙ｄ腑锛岀偣鍑昏鍙峰乏渚х殑鐏拌壊鍖哄煙
2. 鍑虹幇绾㈣壊鍦嗙偣琛ㄧず鏂偣宸茶缃?3. 鎴栦娇鐢ㄥ揩鎹烽敭 `F9` 鍒囨崲鏂偣

#### 鏂偣灞炴€ц缃?
1. 鍙屽嚮鏂偣鎵撳紑灞炴€х獥鍙?2. 鍙缃細
   - **Condition**锛氭潯浠惰〃杈惧紡
   - **Hit Count**锛氬懡涓鏁?   - **Action**锛氳Е鍙戝姩浣?
#### TCL 鍛戒护璁剧疆鏂偣

```tcl
# 璁剧疆绠€鍗曟柇鐐?verdiSetBreakpoint -file "source.sv" -line 42

# 璁剧疆鏉′欢鏂偣
verdiSetBreakpoint -file "source.sv" -line 42 -condition "data == 8'hFF"

# 璁剧疆淇″彿鍊兼柇鐐?verdiSetBreakpoint -signal "top.dut.state" -value "IDLE"

# 鍒犻櫎鏂偣
verdiDeleteBreakpoint -file "source.sv" -line 42

# 绂佺敤/鍚敤鏂偣
verdiDisableBreakpoint -file "source.sv" -line 42
verdiEnableBreakpoint -file "source.sv" -line 42
```

### 5.2 淇″彿鏂偣

1. 鍦ㄦ尝褰㈢獥鍙ｄ腑鍙抽敭鐐瑰嚮淇″彿
2. 閫夋嫨 `Set Breakpoint`
3. 璁剧疆瑙﹀彂鏉′欢锛?   - 涓婂崌娌?`posedge`
   - 涓嬮檷娌?`negedge`
   - 鐗瑰畾鍊煎彉鍖?   - 鍊艰寖鍥?
### 5.3 鏂偣绠＄悊

- 鎵撳紑鏂偣绐楀彛锛歚View` -> `Breakpoints`
- 鍙互鎵归噺鍚敤/绂佺敤/鍒犻櫎鏂偣
- 鏀寔鏂偣瀵煎叆瀵煎嚭

---

## 6. 婧愮爜绾ц皟璇?
### 6.1 婧愮爜涓庢尝褰㈠悓姝?
#### 鎵撳紑婧愮爜绐楀彛

1. 鑿滃崟 `View` -> `Source Code`
2. 鎴栧揩鎹烽敭 `Ctrl + s`

#### 鍚屾鎿嶄綔

- **娉㈠舰鍒版簮鐮?*锛氬湪娉㈠舰涓€変腑鏃堕棿鐐癸紝鍙抽敭 `Show Source`
- **婧愮爜鍒版尝褰?*锛氬湪婧愮爜涓€変腑淇″彿锛屽彸閿?`Show in Waveform`
- **鍙屽悜鍚屾**锛氬紑鍚?`Sync Mode` 鑷姩鍚屾

### 6.2 婧愮爜璋冭瘯鍔熻兘

#### 浠ｇ爜楂樹寒

- 褰撳墠浠跨湡鏃堕棿鐐圭殑鎵ц琛岄珮浜樉绀?- 鍙樺寲淇″彿鐢ㄤ笉鍚岄鑹叉爣璁?
#### 鍙橀噺鏌ョ湅

1. 鍦ㄦ簮鐮佷腑鎮仠鍙橀噺鏄剧ず褰撳墠鍊?2. 鍙抽敭鍙橀噺閫夋嫨 `Add to Watch`
3. 鍦?Watch 绐楀彛瀹炴椂鐩戞帶鍙橀噺鍙樺寲

### 6.3 婧愮爜瀵艰埅

```tcl
# 璺宠浆鍒版簮鐮佷綅缃?verdiSourceGoto -file "source.sv" -line 100

# 鎼滅储婧愮爜
verdiSourceSearch -pattern "always_ff" -direction forward

# 鏌ユ壘淇″彿瀹氫箟
verdiFindDefinition -signal "data_reg"

# 鏌ユ壘淇″彿浣跨敤
verdiFindUsage -signal "data_reg"
```

---

## 7. 杩借釜鍔熻兘锛圖river/Load 杩借釜锛?
### 7.1 Driver 杩借釜

Driver 杩借釜鐢ㄤ簬鏌ユ壘淇″彿鐨勯┍鍔ㄦ簮銆?
#### 鎿嶄綔姝ラ

1. 鍦ㄦ尝褰㈢獥鍙ｄ腑閫変腑鐩爣淇″彿
2. 鍙抽敭閫夋嫨 `Trace` -> `Trace Driver`
3. 鎴栦娇鐢ㄥ揩鎹烽敭 `Ctrl + Shift + D`
4. 寮瑰嚭杩借釜缁撴灉绐楀彛锛屾樉绀烘墍鏈夐┍鍔ㄨ淇″彿鐨勮鍙?
#### 杩借釜缁撴灉鍒嗘瀽

- **缁胯壊绠ご**锛氬綋鍓嶆椿璺冪殑椹卞姩
- **绾㈣壊绠ご**锛氫笉娲昏穬鐨勯┍鍔?- **钃濊壊绠ご**锛氭潯浠堕┍鍔紙澶氶┍鍔ㄦ儏鍐碉級

#### TCL 鍛戒护

```tcl
# 杩借釜淇″彿椹卞姩
verdiTraceDriver -signal "top.dut.data"

# 杩借釜鍒版簮鐮佷綅缃?verdiTraceDriver -signal "top.dut.data" -toSource

# 杩借釜澶氶┍鍔ㄤ俊鍙?verdiTraceDriver -signal "top.dut.data" -showAllDrivers
```

### 7.2 Load 杩借釜

Load 杩借釜鐢ㄤ簬鏌ユ壘淇″彿琚摢浜涢€昏緫娑堣垂銆?
#### 鎿嶄綔姝ラ

1. 閫変腑鐩爣淇″彿
2. 鍙抽敭閫夋嫨 `Trace` -> `Trace Load`
3. 鎴栦娇鐢ㄥ揩鎹烽敭 `Ctrl + Shift + L`
4. 鏌ョ湅淇″彿鐨勬墍鏈夎礋杞?
#### 搴旂敤鍦烘櫙

- 鏌ユ壘淇″彿鎵囧嚭
- 瀹氫綅淇″彿褰卞搷鑼冨洿
- 鍒嗘瀽鍏抽敭璺緞

### 7.3 缁煎悎杩借釜

```tcl
# 鍚屾椂杩借釜 Driver 鍜?Load
verdiTraceBoth -signal "top.dut.data"

# 杩借釜骞剁敓鎴愭姤鍛?verdiTraceReport -signal "top.dut.data" -output trace_report.txt

# 杩借釜鏁翠釜璺緞
verdiTracePath -from "top.dut.input" -to "top.dut.output"
```

---

## 8. 瑕嗙洊鐜囨煡鐪?
### 8.1 鍔犺浇瑕嗙洊鐜囨暟鎹?
```bash
# 鍚姩 Verdi 鏃跺姞杞借鐩栫巼
verdi -cov -covdir coverage.vdb &

# 鎴栧湪 Verdi 涓姞杞?# File -> Load Coverage Database
```

### 8.2 瑕嗙洊鐜囩被鍨?
#### 浠ｇ爜瑕嗙洊鐜?
- **Line Coverage**锛氳瑕嗙洊鐜?- **Condition Coverage**锛氭潯浠惰鐩栫巼
- **FSM Coverage**锛氱姸鎬佹満瑕嗙洊鐜?- **Toggle Coverage**锛氱炕杞鐩栫巼

#### 鍔熻兘瑕嗙洊鐜?
- **Covergroup**锛氳鐩栫粍
- **Coverpoint**锛氳鐩栫偣
- **Cross Coverage**锛氫氦鍙夎鐩?
### 8.3 瑕嗙洊鐜囨煡鐪嬫搷浣?
1. 鎵撳紑瑕嗙洊鐜囩獥鍙ｏ細`View` -> `Coverage`
2. 宸︿晶鏄剧ず瑕嗙洊鐜囧眰娆＄粨鏋?3. 鍙抽敭妯″潡閫夋嫨锛?   - `Show Source`锛氭煡鐪嬫簮鐮佽鐩栨儏鍐?   - `Show Details`锛氭煡鐪嬭缁嗚鐩栫巼鏁版嵁
   - `Generate Report`锛氱敓鎴愯鐩栫巼鎶ュ憡

#### TCL 鍛戒护

```tcl
# 鍔犺浇瑕嗙洊鐜囨暟鎹簱
verdiCovLoad -dir "coverage.vdb"

# 鏌ョ湅瑕嗙洊鐜囨憳瑕?verdiCovSummary

# 瀵煎嚭瑕嗙洊鐜囨姤鍛?verdiCovReport -output coverage_report.html -format html

# 杩囨护瑕嗙洊鐜囨暟鎹?verdiCovFilter -type line -threshold 80
```

### 8.4 瑕嗙洊鐜囦笌娉㈠舰鍏宠仈

- 鍦ㄨ鐩栫巼绐楀彛鍙屽嚮鏈鐩栫殑浠ｇ爜琛?- 鑷姩璺宠浆鍒版尝褰㈠搴旀椂闂寸偣
- 鍒嗘瀽鏈鐩栧師鍥?
---

## 9. 鑴氭湰鑷姩鍖?
### 9.1 TCL 鑴氭湰鍩虹

#### 鍚姩 TCL 鎺у埗鍙?
- 鑿滃崟 `Tools` -> `TCL Console`
- 鎴栧揩鎹烽敭 `Ctrl + Shift + T`

#### 鍩烘湰 TCL 鍛戒护

```tcl
# 鎵撳紑娉㈠舰
verdiOpenWaveform -file "waveform.fsdb"

# 璁剧疆鏃堕棿鑼冨洿
verdiSetTimeRange -start 0 -end 1000ns

# 娣诲姞淇″彿
verdiSignalAdd -name "top.clk"

# 淇濆瓨娉㈠舰閰嶇疆
verdiSaveWaveformConfig -file "waveform.cfg"

# 鍔犺浇娉㈠舰閰嶇疆
verdiLoadWaveformConfig -file "waveform.cfg"
```

### 9.2 鑷姩鍖栬剼鏈ず渚?
#### 鎵归噺娣诲姞淇″彿

```tcl
#!/usr/bin/tclsh
# add_signals.tcl

set signal_list {
    "top.dut.clk"
    "top.dut.rst_n"
    "top.dut.data_in[7:0]"
    "top.dut.data_out[7:0]"
    "top.dut.state"
    "top.dut.next_state"
}

verdiOpenWaveform -file "waveform.fsdb"

foreach sig $signal_list {
    verdiSignalAdd -name $sig
    puts "Added signal: $sig"
}

verdiZoomFull
puts "All signals added successfully"
```

#### 鑷姩鍖栬皟璇曟祦绋?
```tcl
#!/usr/bin/tclsh
# auto_debug.tcl

# 鎵撳紑璁捐鍜屾尝褰?verdiOpenDesign -dbdir "simv.daidir"
verdiOpenWaveform -file "waveform.fsdb"

# 娣诲姞鍏抽敭淇″彿
verdiSignalAdd -name "top.dut.clk"
verdiSignalAdd -name "top.dut.error_flag"

# 璁剧疆鏂偣
verdiSetBreakpoint -file "error_handler.sv" -line 42 \
    -condition "error_flag == 1"

# 璁剧疆淇″彿鏂偣
verdiSetSignalBreakpoint -signal "top.dut.error_flag" \
    -value 1 -action "verdiTakeSnapshot"

# 鍚姩杩借釜
verdiTraceDriver -signal "top.dut.error_flag"

# 淇濆瓨閰嶇疆
verdiSaveSession -file "debug_session.rc"

puts "Debug setup completed"
```

### 9.3 鎵瑰鐞嗘ā寮?
```bash
# 闈炰氦浜掓ā寮忚繍琛?TCL 鑴氭湰
verdi -batch -tcl auto_debug.tcl

# 鐢熸垚鎶ュ憡鍚庨€€鍑?verdi -batch -tcl generate_report.tcl -exit
```

### 9.4 鑴氭湰璋冭瘯鎶€宸?
```tcl
# 鍚敤 TCL 璋冭瘯
verdiDebug -enable

# 璁剧疆鏂偣
debugger_break

# 鏌ョ湅鍙橀噺
puts "Current time: [verdiGetCurrentTime]"

# 閿欒澶勭悊
if {[catch {verdiSignalAdd -name "invalid.signal"} result]} {
    puts "Error: $result"
}
```

---

## 10. 甯歌闂鍙婅В鍐?
### 10.1 娉㈠舰鍔犺浇闂

#### 闂锛欶SDB 鏂囦欢鍔犺浇澶辫触

**鐥囩姸**锛氭彁绀?"Invalid FSDB file" 鎴栧姞杞芥棤鍙嶅簲

**瑙ｅ喅鏂规**锛?```bash
# 妫€鏌ユ枃浠跺畬鏁存€?ls -lh waveform.fsdb

# 浣跨敤 nWave 妫€鏌ユ枃浠?nWave -ssf waveform.fsdb

# 閲嶆柊鐢熸垚 FSDB
# 鍦?testbench 涓坊鍔?$fsdbDumpfile("waveform.fsdb")
# $fsdbDumpvars(0, top);
```

#### 闂锛氭尝褰㈡樉绀轰笉瀹屾暣

**鐥囩姸**锛氶儴鍒嗘椂闂存娉㈠舰缂哄け

**瑙ｅ喅鏂规**锛?1. 妫€鏌ヤ豢鐪熸椂闂磋寖鍥?2. 纭 `$fsdbDumpvars` 鐨勫眰娆¤缃?3. 浣跨敤 `verdiZoomFull` 鏌ョ湅瀹屾暣娉㈠舰

### 10.2 婧愮爜鏄剧ず闂

#### 闂锛氭簮鐮佷笌娉㈠舰涓嶅悓姝?
**鐥囩姸**锛氱偣鍑绘尝褰㈡棤娉曡烦杞埌瀵瑰簲婧愮爜

**瑙ｅ喅鏂规**锛?1. 閲嶆柊鍔犺浇璁捐搴擄細`File` -> `Reload Design`
2. 妫€鏌ユ簮鐮佽矾寰勮缃細`Tools` -> `Options` -> `Source Code`
3. 纭繚缂栬瘧鏃剁敓鎴愪簡璋冭瘯淇℃伅锛坄-debug_access+all`锛?
#### 闂锛氭簮鐮佹樉绀轰贡鐮?
**鐥囩姸**锛氫腑鏂囨敞閲婃垨鐗规畩瀛楃鏄剧ず寮傚父

**瑙ｅ喅鏂规**锛?1. 璁剧疆姝ｇ‘鐨勫瓧绗︾紪鐮侊細`Tools` -> `Options` -> `Encoding`
2. 杞崲婧愮爜鏂囦欢缂栫爜涓?UTF-8

### 10.3 鎬ц兘闂

#### 闂锛氬ぇ娉㈠舰鏂囦欢鍔犺浇缂撴參

**瑙ｅ喅鏂规**锛?```bash
# 浣跨敤娉㈠舰鍒嗗壊
verdi -ssf part1.fsdb -ssf part2.fsdb &

# 浣跨敤鏃堕棿鑼冨洿鍔犺浇
verdi -ssf waveform.fsdb -time "0ns" "1000ns" &

# 澧炲姞鍐呭瓨闄愬埗
verdi -ssf waveform.fsdb -maxmem 4096 &
```

#### 闂锛氳拷韪姛鑳藉搷搴旀參

**瑙ｅ喅鏂规**锛?1. 闄愬埗杩借釜娣卞害锛歚Tools` -> `Options` -> `Trace` -> `Max Depth`
2. 浣跨敤灞€閮ㄨ拷韪€岄潪鍏ㄨ矾寰勮拷韪?3. 鍏抽棴涓嶅繀瑕佺殑淇″彿绐楀彛

### 10.4 璁稿彲璇侀棶棰?
#### 闂锛歀icense 鑾峰彇澶辫触

**瑙ｅ喅鏂规**锛?```bash
# 妫€鏌ヨ鍙瘉鏈嶅姟鍣?lmstat -a

# 璁剧疆璁稿彲璇佹枃浠?export SNPSLMD_LICENSE_FILE=27000@license_server

# 鎴栦娇鐢ㄧ鍙涓绘満鏍煎紡
export LM_LICENSE_FILE=1717@license_server
```

### 10.5 蹇嵎閿笉鍝嶅簲

**瑙ｅ喅鏂规**锛?1. 妫€鏌ヨ緭鍏ユ硶鏄惁鍒囨崲鍒拌嫳鏂囨ā寮?2. 閲嶇疆蹇嵎閿厤缃細`Tools` -> `Options` -> `Key Bindings` -> `Reset`
3. 妫€鏌ユ槸鍚︽湁鍏朵粬杞欢鍗犵敤蹇嵎閿?
---

## 11. 鐩稿叧閾炬帴

### 瀹樻柟璧勬簮

- [Synopsys Verdi 瀹樻柟鏂囨。](https://www.synopsys.com/verification/debug.html)
- [Verdi 蹇€熷叆闂ㄦ寚鍗梋(https://solvnet.synopsys.com)
- [Synopsys TCL 鎵嬪唽](https://www.synopsys.com)

### 瀛︿範璧勬簮

- Verdi 浣跨敤鎶€宸э紙Synopsys SolvNet锛?- 鏁板瓧IC楠岃瘉璋冭瘯鏂规硶璁?- UVM璋冭瘯鏈€浣冲疄璺?
### 鐩稿叧宸ュ叿

| 宸ュ叿 | 鐢ㄩ€?|
|------|------|
| VCS | 浠跨湡缂栬瘧鍣?|
| nWave | 鐙珛娉㈠舰鏌ョ湅鍣?|
| UCLI | 缁熶竴鍛戒护琛屾帴鍙?|
| DVE | 鍥惧舰鍖栬皟璇曠幆澧冿紙鏃х増锛?|

### 鏈瑪璁扮浉鍏?
- [[04-Tools/05-VCS/00-VCS|VCS 缂栬瘧浠跨湡]]
- [[04-Tools/07-QuestaSim/00-QuestaSim|QuestaSim 浣跨敤]]
- [[03-Protocol/00-鍗忚绱㈠紩|鍗忚楠岃瘉]]

---

## 12. 闄勫綍锛歏erdi 鐜閰嶇疆

### 鐜鍙橀噺璁剧疆

```bash
# ~/.bashrc 鎴?~/.cshrc
export VERDI_HOME=/path/to/verdi
export PATH=$VERDI_HOME/bin:$PATH

# 鎸囧畾 FSDB 搴撹矾寰?export LD_LIBRARY_PATH=$VERDI_HOME/share/PLI/lib:$LD_LIBRARY_PATH

# 璁剧疆榛樿閰嶇疆
export VERDI_DEFAULT_CONFIG=$HOME/.verdi_config
```

### VCS 鑱斿悎閰嶇疆

```bash
# 缂栬瘧閫夐」
vcs -full64 -sverilog -debug_access+all -kdb -lca source.sv

# 浠跨湡閫夐」
./simv +fsdb+dumpfile+waveform.fsdb +fsdb+dumpvars
```

### 閰嶇疆鏂囦欢绀轰緥

```tcl
# ~/.verdi_config
set verdi_config(source_code_path) "./src"
set verdi_config(waveform_default_format) "fsdb"
set verdi_config(trace_max_depth) 10
set verdi_config(auto_sync) true
```

---

*Last Updated: 2026-06-02*

