---
tags: [Verification, CDC, 璺ㄦ椂閽熷煙, 鏃跺簭, 鏍稿績]
created: 2026-06-02
updated: 2026-06-02
---

## 馃搼 鐩綍

- [CDC姒傝堪涓庨噸瑕佹€(#cdc姒傝堪涓庨噸瑕佹€?
  - [涓轰粈涔圕DC楠岃瘉鑷冲叧閲嶈](#涓轰粈涔坈dc楠岃瘉鑷冲叧閲嶈)
- [浜氱ǔ鎬侀棶棰樹笌MTBF](#浜氱ǔ鎬侀棶棰樹笌mtbf)
  - [浜氱ǔ鎬佺殑鐗╃悊鏈川](#浜氱ǔ鎬佺殑鐗╃悊鏈川)
  - [MTBF璁＄畻](#mtbf璁＄畻)
  - [鍏抽敭璁捐鍚ず](#鍏抽敭璁捐鍚ず)
- [鍚屾鍣ㄨ璁(#鍚屾鍣ㄨ璁?
  - [鍙岃Е鍙戝櫒鍚屾鍣紙鏈€甯哥敤锛塢(#鍙岃Е鍙戝櫒鍚屾鍣ㄦ渶甯哥敤)
  - [涓夌骇瑙﹀彂鍣ㄥ悓姝ュ櫒](#涓夌骇瑙﹀彂鍣ㄥ悓姝ュ櫒)
  - [鍚屾鍣ㄨ璁¤鐐筣(#鍚屾鍣ㄨ璁¤鐐?
- [鏍奸浄鐮佺紪鐮乚(#鏍奸浄鐮佺紪鐮?
  - [鍘熺悊](#鍘熺悊)
  - [浜岃繘鍒朵笌鏍奸浄鐮佽浆鎹(#浜岃繘鍒朵笌鏍奸浄鐮佽浆鎹?
  - [搴旂敤鍦烘櫙](#搴旂敤鍦烘櫙)
- [寮傛FIFO璁捐](#寮傛fifo璁捐)
  - [鏋舵瀯姒傝](#鏋舵瀯姒傝)
  - [鏍稿績瀹炵幇](#鏍稿績瀹炵幇)
  - [寮傛FIFO璁捐瑕佺偣](#寮傛fifo璁捐瑕佺偣)
- [鑴夊啿鍚屾鍣╙(#鑴夊啿鍚屾鍣?
  - [闂鍦烘櫙](#闂鍦烘櫙)
  - [鏂规涓€锛歍oggle鍚屾鍣紙鏈€甯哥敤锛塢(#鏂规涓€togglesync鍚屾鍣ㄦ渶甯哥敤)
  - [鏂规浜岋細鍙嶉纭鍚屾鍣╙(#鏂规浜屽弽棣堢‘璁ゅ悓姝ュ櫒)
- [鎻℃墜鍗忚鍚屾](#鎻℃墜鍗忚鍚屾)
  - [閫傜敤鍦烘櫙](#閫傜敤鍦烘櫙)
  - [req-ack 鎻℃墜鍗忚](#req-ack-鎻℃墜鍗忚)
  - [鎻℃墜鏃跺簭鍥綸(#鎻℃墜鏃跺簭鍥?
- [CDC楠岃瘉鏂规硶](#cdc楠岃瘉鏂规硶)
  - [闈欐€佹鏌ワ紙CDC宸ュ叿鍒嗘瀽锛塢(#闈欐€佹鏌dc宸ュ叿鍒嗘瀽)
  - [鍔ㄦ€侀獙璇侊紙绾︽潫闅忔満娴嬭瘯锛塢(#鍔ㄦ€侀獙璇佺害鏉熼殢鏈烘祴璇?
  - [褰㈠紡楠岃瘉](#褰㈠紡楠岃瘉)
- [甯歌CDC閿欒涓庢渚媇(#甯歌cdc閿欒涓庢渚?
  - [閿欒1锛氬浣嶆€荤嚎閫愪綅鍚屾](#閿欒1澶氫綅鎬荤嚎閫愪綅鍚屾)
  - [閿欒2锛氱粍鍚堥€昏緫鍚庢帴鍚屾鍣╙(#閿欒2缁勫悎閫昏緫鍚庢帴鍚屾鍣?
  - [閿欒3锛氬紓姝ュ浣嶉噴鏀炬湭鍚屾](#閿欒3寮傛澶嶄綅閲婃斁鏈悓姝?
- [CDC楠岃瘉宸ュ叿](#cdc楠岃瘉宸ュ叿)
  - [SpyGlass CDC](#spyglass-cdc)
  - [Questa CDC](#questa-cdc)
  - [宸ュ叿瀵规瘮](#宸ュ叿瀵规瘮)

---

# 03-CDC楠岃瘉

## CDC姒傝堪涓庨噸瑕佹€?
CDC锛圕lock Domain Crossing锛岃法鏃堕挓鍩燂級鏄寚淇″彿浠庝竴涓椂閽熷煙浼犺緭鍒板彟涓€涓椂閽熷煙鐨勮繃绋嬨€傚湪鐜颁唬SoC璁捐涓紝澶氭椂閽熷煙鏋舵瀯鏃犲涓嶅湪鈥斺€斿鐞嗗櫒鏍稿績銆佸璁炬帴鍙ｃ€丏DR鎺у埗鍣ㄣ€侀珮閫烻erDes绛夋ā鍧楀線寰€杩愯鍦ㄤ笉鍚岀殑鏃堕挓棰戠巼涓嬨€侰DC澶勭悊涓嶅綋浼氬鑷?*浜氱ǔ鎬侊紙Metastability锛?*锛屽紩鍙戝姛鑳介敊璇€佹暟鎹涪澶辩敋鑷崇郴缁熷穿婧冿紝涓旇繖绫籅ug鏋佸叾闅句互澶嶇幇鍜岃皟璇曘€?
### 涓轰粈涔圕DC楠岃瘉鑷冲叧閲嶈

| 椋庨櫓缁村害 | 璇存槑 |
|---------|------|
| 鍔熻兘姝ｇ‘鎬?| 浜氱ǔ鎬佸鑷存暟鎹噰鏍烽敊璇紝浜х敓闅忔満鍔熻兘鏁呴殰 |
| 鍙潬鎬?| CDC Bug鍙兘鍦ㄨ姱鐗囧伐浣滄暟灏忔椂鐢氳嚦鏁板ぉ鍚庢墠鍋跺彂鍑虹幇 |
| 璋冭瘯闅惧害 | 鏃犳硶鍦ㄤ豢鐪熶腑绋冲畾澶嶇幇锛屼紶缁熸尝褰㈣皟璇曟墜娈靛熀鏈け鏁?|
| 娴佺墖椋庨櫓 | 涓€鏃︽祦鐗囧悗鍙戠幇CDC闂锛屼慨澶嶆垚鏈瀬楂橈紝鍙兘闇€瑕侀噸鏂拌璁?|

```
鏃堕挓鍩烝 (clk_a)          鏃堕挓鍩烞 (clk_b)
    鈹屸攢鈹€鈹? 鈹屸攢鈹€鈹? 鈹屸攢鈹€鈹?        鈹屸攢鈹€鈹€鈹? 鈹屸攢鈹€鈹€鈹? 鈹屸攢鈹€鈹€鈹?    鈹? 鈹? 鈹? 鈹? 鈹? 鈹?        鈹?  鈹? 鈹?  鈹? 鈹?  鈹?鈹€鈹€鈹€鈹€鈹? 鈹斺攢鈹€鈹? 鈹斺攢鈹€鈹? 鈹斺攢鈹€       鈹?  鈹斺攢鈹€鈹?  鈹斺攢鈹€鈹?  鈹斺攢鈹€

    sig_a 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈻? sig_b (?)
                               鈫?                          浜氱ǔ鎬侀闄╃偣
```

---

## 浜氱ǔ鎬侀棶棰樹笌MTBF

### 浜氱ǔ鎬佺殑鐗╃悊鏈川

褰撹Е鍙戝櫒鐨勮緭鍏ヤ俊鍙峰湪**寤虹珛鏃堕棿锛圫etup Time锛?*鍜?*淇濇寔鏃堕棿锛圚old Time锛?*绐楀彛鍐呭彂鐢熷彉鍖栨椂锛岃Е鍙戝櫒鏃犳硶纭畾杈撳嚭鏄?杩樻槸1锛岃繘鍏ヤ竴涓?*浜氱ǔ鎬?*鈥斺€旇緭鍑虹數鍘嬪浜庨€昏緫0鍜岄€昏緫1涔嬮棿鐨勪笉纭畾鐢靛钩锛屽苟鍦ㄤ竴娈垫椂闂村唴闇囪崱鍚庢墠鏈€缁堢ǔ瀹氥€?
```
         tsu  th
          鈹傗梽鈹€鈻衡攤
          鈹屸攢鈹€鈹€鈹?clk  鈹€鈹€鈹€鈹€鈹€鈹?  鈹斺攢鈹€鈹€鈹€鈹€
               鈻撯枔鈻撯枔鈻撯枔鈻撯枔鈻撯枔鈻撯枔鈻撯枔鈻撯枔鈻撯枔
data 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€X鈻撯枔鈻撯枔鈻撯枔鈻撯枔鈻撯枔鈻撯枔鈻撯枔鈻撯枔鈻撯枔鈻撯枔鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€
               鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?Q    鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹? 浜氱ǔ鎬?(闇囪崱)    鈹溾攢鈹€鈹€鈹€鈹€?鈹€鈹€
               鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?               鈹傗啇鈹€ 鎭㈠鏃堕棿 Tmet 鈹€鈫掆攤
```

### MTBF璁＄畻

MTBF锛圡ean Time Between Failures锛屽钩鍧囨晠闅滈棿闅旀椂闂达級鏄　閲廋DC鍙潬鎬х殑鏍稿績鎸囨爣锛?
$$MTBF = \frac{1}{f_{clk} \cdot f_{data} \cdot T_0 \cdot e^{T_{met}/\tau}}$$

鍏朵腑锛?- `f_clk`锛氶噰鏍锋椂閽熼鐜?- `f_data`锛氭暟鎹炕杞鐜?- `T_0`锛氫笌宸ヨ壓鐩稿叧鐨勫父鏁帮紙鍏稿瀷鍊肩害 0.1~1 ns锛?- `T_met`锛氬厑璁哥殑浜氱ǔ鎬佹仮澶嶆椂闂达紙鍗虫椂閽熷懆鏈熷噺鍘荤粍鍚堥€昏緫寤惰繜鍜屽缓绔嬫椂闂达級
- `蟿`锛氳Е鍙戝櫒鐨勪簹绋虫€佹椂闂村父鏁帮紙鍏稿瀷鍊肩害 10~50 ps锛屽彇鍐充簬宸ヨ壓锛?
### 鍏抽敭璁捐鍚ず

| 鎺柦 | 瀵筂TBF鐨勫奖鍝?|
|------|-------------|
| 澧炲姞涓€绾у悓姝ヨЕ鍙戝櫒 | MTBF鎸囨暟绾ф彁鍗囷紙e^(T/蟿)椤瑰澶э級 |
| 闄嶄綆鏃堕挓棰戠巼 | MTBF绾挎€ф彁鍗?|
| 浣跨敤鏇村揩鐨勫伐鑹?| 蟿鏇村皬锛孧TBF鎸囨暟绾ф彁鍗?|
| 鍑忓皯璺ㄦ椂閽熷煙淇″彿缈昏浆鐜?| MTBF绾挎€ф彁鍗?|

鍏稿瀷鏁板€硷細鍙岃Е鍙戝櫒鍚屾鍣ㄥ湪鐜颁唬宸ヨ壓涓嬶紝MTBF鍙揪鏁板崄骞寸敋鑷虫暟鐧惧勾锛涗絾楂橀璁捐锛?500MHz锛夊彲鑳介渶瑕佷笁绾у悓姝ュ櫒鎵嶈兘婊¤冻瑕佹眰銆?
---

## 鍚屾鍣ㄨ璁?
### 鍙岃Е鍙戝櫒鍚屾鍣紙鏈€甯哥敤锛?
鏈€鍩烘湰鐨凜DC鍚屾鏂规锛屽皢浜氱ǔ鎬佹仮澶嶆椂闂存墿灞曞埌涓€涓畬鏁存椂閽熷懆鏈燂細

```verilog
// 鍙岃Е鍙戝櫒鍚屾鍣?module sync_2ff #(
    parameter INIT = 1'b0
)(
    input  logic clk_dst,   // 鐩爣鏃堕挓鍩?    input  logic rst_n,     // 寮傛澶嶄綅
    input  logic sig_src,   // 婧愭椂閽熷煙淇″彿
    output logic sig_dst    // 鍚屾鍚庣殑淇″彿
);

    logic sig_meta;  // 绗竴绾э細鍙兘杩涘叆浜氱ǔ鎬?
    always_ff @(posedge clk_dst or negedge rst_n) begin
        if (!rst_n) begin
            sig_meta <= INIT;
            sig_dst  <= INIT;
        end else begin
            sig_meta <= sig_src;   // 绗竴绾ч噰鏍?            sig_dst  <= sig_meta;  // 绗簩绾хǔ瀹氳緭鍑?        end
    end

endmodule
```

鏃跺簭娉㈠舰锛?
```
clk_dst  鈹屸攼  鈹屸攼  鈹屸攼  鈹屸攼  鈹屸攼  鈹屸攼
         鈹樷敂鈹€鈹€鈹樷敂鈹€鈹€鈹樷敂鈹€鈹€鈹樷敂鈹€鈹€鈹樷敂鈹€鈹€鈹樷敂鈹€鈹€

sig_src  鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?                       鈹?                       鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€

sig_meta 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€ 鈹?鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€
                        鈻撯枔鈻撯枔  (浜氱ǔ鎬?
                         鈹斺攢鈹€鈹?
sig_dst  鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?                               鈹?                               鈹斺攢鈹€鈹€鈹€鈹€鈹€
                        鈫?鍚屾寤惰繜 = 2涓猚lk_dst鍛ㄦ湡
```

### 涓夌骇瑙﹀彂鍣ㄥ悓姝ュ櫒

鐢ㄤ簬鏋侀珮棰戠巼鎴栧MTBF瑕佹眰鏋佷弗鐨勫満鏅紙濡傛苯杞︾骇ASIL-D鍔熻兘瀹夊叏锛夛細

```verilog
// 涓夌骇瑙﹀彂鍣ㄥ悓姝ュ櫒
module sync_3ff #(
    parameter INIT = 1'b0
)(
    input  logic clk_dst,
    input  logic rst_n,
    input  logic sig_src,
    output logic sig_dst
);

    logic sig_meta1, sig_meta2;

    always_ff @(posedge clk_dst or negedge rst_n) begin
        if (!rst_n) begin
            sig_meta1 <= INIT;
            sig_meta2 <= INIT;
            sig_dst   <= INIT;
        end else begin
            sig_meta1 <= sig_src;
            sig_meta2 <= sig_meta1;
            sig_dst   <= sig_meta2;
        end
    end

endmodule
```

### 鍚屾鍣ㄨ璁¤鐐?
| 瑕佺偣 | 璇存槑 |
|------|------|
| 鍚屾鍣ㄥ繀椤绘斁鍦ㄧ洰鏍囨椂閽熷煙 | 閲囨牱绔繀椤荤敤鐩爣鏃堕挓椹卞姩 |
| 绂佹瀵瑰悓姝ュ櫒杈撳嚭鍋氱粍鍚堥€昏緫 | 浼氬紩鍏ユ柊鐨勪簹绋虫€佺獥鍙?|
| 澶嶄綅鍊煎簲涓庢簮淇″彿鍒濆鐘舵€佷竴鑷?| 閬垮厤涓婄數鍚庡悓姝ュ櫒杈撳嚭閿欒鐢靛钩 |
| 缁煎悎灞炴€т繚鎶?| 娣诲姞 `(* ASYNC_REG = "TRUE" *)` 闃叉缁煎悎宸ュ叿浼樺寲 |

```verilog
// Xilinx 椋庢牸鐨勫紓姝ュ瘎瀛樺櫒澹版槑
(* ASYNC_REG = "TRUE" *)
logic sig_meta, sig_dst;
```

---

## 鏍奸浄鐮佺紪鐮?
### 鍘熺悊

鏍奸浄鐮侊紙Gray Code锛夌殑缂栫爜鐗圭偣鏄細**鐩搁偦涓や釜缂栫爜涔嬮棿浠呮湁1浣嶅彂鐢熺炕杞?*銆傝繖浣垮緱鍦ㄨ法鏃堕挓鍩熶紶杈撳浣嶈鏁板櫒/鍦板潃鏃讹紝鍗充娇閲囨牱鏃跺埢涓嶇簿纭紝鏈€澶氬彧鏈?浣嶅嚭閿欙紝閿欒骞呭害浠呬负1銆?
```
鍗佽繘鍒? 浜岃繘鍒? 鏍奸浄鐮?  0      000     000
  1      001     001
  2      010     011
  3      011     010
  4      100     110
  5      101     111
  6      110     101
  7      111     100
```

### 浜岃繘鍒朵笌鏍奸浄鐮佽浆鎹?
```verilog
// 浜岃繘鍒?鈫?鏍奸浄鐮?function automatic logic [N-1:0] bin2gray(input logic [N-1:0] bin);
    return bin ^ (bin >> 1);
endfunction

// 鏍奸浄鐮?鈫?浜岃繘鍒讹紙閫愪綅寮傛垨杩樺師锛?function automatic logic [N-1:0] gray2bin(input logic [N-1:0] gray);
    logic [N-1:0] bin;
    bin[N-1] = gray[N-1];
    for (int i = N-2; i >= 0; i--)
        bin[i] = bin[i+1] ^ gray[i];
    return bin;
endfunction
```

### 搴旂敤鍦烘櫙

鏍奸浄鐮佹渶鍏稿瀷鐨勫簲鐢ㄦ槸**寮傛FIFO鐨勮鍐欐寚閽堝悓姝?*銆傚皢浜岃繘鍒舵寚閽堣浆鎹负鏍奸浄鐮佸悗璺ㄦ椂閽熷煙浼犺緭锛岀洰鏍囨椂閽熷煙鍚屾鍚庡啀杞崲鍥炰簩杩涘埗銆?
---

## 寮傛FIFO璁捐

### 鏋舵瀯姒傝

寮傛FIFO鏄法鏃堕挓鍩熶紶杈撴壒閲忔暟鎹殑鏍囧噯鏂规锛屾牳蹇冩€濇兂鏄敤**鍙岀鍙AM**浣滀负鍏变韩瀛樺偍锛岄厤鍚?*鏍奸浄鐮佹寚閽?*鍜?*鍚屾鍣?*瀹炵幇瀹夊叏鐨勮法鏃堕挓鍩熼€氫俊銆?
```
鍐欐椂閽熷煙 (wr_clk)                          璇绘椂閽熷煙 (rd_clk)
鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?                         鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?鈹? wr_ptr_gray 鈹傗攢鈹€鈹€鈹€鈹€鈹€鈹?           鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹? rd_ptr_gray 鈹?鈹? (浜岃繘鍒垛啋鏍奸浄)鈹?     鈹?           鈹?     鈹? (浜岃繘鍒垛啋鏍奸浄)鈹?鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?     鈹?           鈹?     鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?                      鈻?           鈻?                 鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?                 鈹?  鍙岀鍙?RAM        鈹?                 鈹?  (娣卞害 N)          鈹?                 鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?                      鈹?           鈹?                      鈻?           鈻?               鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹? 鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?               鈹?鍚屾鍣?   鈹? 鈹?鍚屾鍣?   鈹?               鈹?wr鈫抮d鍩?  鈹? 鈹?rd鈫抴r鍩?  鈹?               鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹? 鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?                      鈹?           鈹?                      鈻?           鈻?               鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹? 鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?               鈹?婊℃爣蹇?   鈹? 鈹?绌烘爣蹇?   鈹?               鈹?(full)   鈹? 鈹?(empty)  鈹?               鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹? 鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?```

### 鏍稿績瀹炵幇

```verilog
module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4,       // FIFO娣卞害 = 2^ADDR_WIDTH
    parameter FIFO_DEPTH = 1 << ADDR_WIDTH
)(
    // 鍐欑鍙?    input  logic                    wr_clk,
    input  logic                    wr_rst_n,
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wr_data,
    output logic                    full,
    // 璇荤鍙?    input  logic                    rd_clk,
    input  logic                    rd_rst_n,
    input  logic                    rd_en,
    output logic [DATA_WIDTH-1:0]   rd_data,
    output logic                    empty
);

    // ---------- 瀛樺偍浣?----------
    logic [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];

    // ---------- 鍐欐寚閽?----------
    logic [ADDR_WIDTH:0] wr_ptr_bin;      // 澶?浣嶇敤浜庡垽婊?    logic [ADDR_WIDTH:0] wr_ptr_gray;
    logic [ADDR_WIDTH:0] wr_ptr_gray_sync; // 鍚屾鍒拌鏃堕挓鍩?    logic [ADDR_WIDTH:0] rd_ptr_gray_in_wr; // 璇绘寚閽堝悓姝ュ埌鍐欏煙

    // 鍐欐寚閽堥€掑涓庢牸闆风爜杞崲
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n)
            wr_ptr_bin <= '0;
        else if (wr_en && !full)
            wr_ptr_bin <= wr_ptr_bin + 1;
    end

    assign wr_ptr_gray = bin2gray(wr_ptr_bin);

    // 鍐欐暟鎹?    always_ff @(posedge wr_clk) begin
        if (wr_en && !full)
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;
    end

    // ---------- 璇绘寚閽?----------
    logic [ADDR_WIDTH:0] rd_ptr_bin;
    logic [ADDR_WIDTH:0] rd_ptr_gray;

    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n)
            rd_ptr_bin <= '0;
        else if (rd_en && !empty)
            rd_ptr_bin <= rd_ptr_bin + 1;
    end

    assign rd_ptr_gray = bin2gray(rd_ptr_bin);

    // 璇绘暟鎹?    assign rd_data = mem[rd_ptr_bin[ADDR_WIDTH-1:0]];

    // ---------- 鍚屾鍣?----------
    // 鍐欐寚閽堟牸闆风爜 鈫?璇绘椂閽熷煙
    sync_2ff #(.INIT('0)) u_sync_wr2rd (
        .clk_dst(rd_clk), .rst_n(rd_rst_n),
        .sig_src(wr_ptr_gray[ADDR_WIDTH]),
        .sig_dst(wr_ptr_gray_sync[ADDR_WIDTH])
    );
    // (瀹為檯瀹炵幇闇€瀵规瘡涓€浣嶅崟鐙悓姝ワ紝姝ゅ绠€鍖栫ず鎰?

    // 璇绘寚閽堟牸闆风爜 鈫?鍐欐椂閽熷煙
    sync_2ff #(.INIT('0)) u_sync_rd2wr (
        .clk_dst(wr_clk), .rst_n(wr_rst_n),
        .sig_src(rd_ptr_gray[ADDR_WIDTH]),
        .sig_dst(rd_ptr_gray_in_wr[ADDR_WIDTH])
    );

    // ---------- 婊?绌哄垽鏂?----------
    // 婊★細鍐欐寚閽堟牸闆风爜楂樹綅鐩稿弽锛屽叾浣欎綅鐩稿悓
    assign full  = (wr_ptr_gray == {~rd_ptr_gray_in_wr[ADDR_WIDTH:ADDR_WIDTH-1],
                                     rd_ptr_gray_in_wr[ADDR_WIDTH-2:0]});
    // 绌猴細璇诲啓鎸囬拡鏍奸浄鐮佸畬鍏ㄧ浉鍚?    assign empty = (rd_ptr_gray == wr_ptr_gray_sync);

endmodule
```

### 寮傛FIFO璁捐瑕佺偣

| 瑕佺偣 | 璇存槑 |
|------|------|
| 鎸囬拡瀹藉害 = 鍦板潃瀹藉害 + 1 | 澶氬嚭鐨?浣嶇敤浜庡尯鍒嗘弧鍜岀┖ |
| 鏍奸浄鐮佸悓姝ュ欢杩?| 婊?绌烘爣蹇楀彲鑳?淇濆畧"锛堝鎶ュ憡1~2涓級锛屼絾涓嶄細婕忔姤 |
| 澶嶄綅澶勭悊 | 璇诲啓鎸囬拡闇€鍚屾澶嶄綅锛屾垨浣跨敤寮傛澶嶄綅鍚屾閲婃斁 |
| 娣卞害蹇呴』鏄?鐨勫箓 | 鏍奸浄鐮佺殑鍗曟瘮鐗圭炕杞壒鎬ц姹傛繁搴︿负2^n |

---

## 鑴夊啿鍚屾鍣?
### 闂鍦烘櫙

褰撴簮鏃堕挓鍩熺殑涓€涓?*鍗曞懆鏈熻剦鍐?*闇€瑕佷紶閫掑埌鐩爣鏃堕挓鍩熸椂锛屽鏋滅洿鎺ョ敤鍙岃Е鍙戝櫒鍚屾锛岃剦鍐插搴﹀彲鑳戒笉瓒充竴涓洰鏍囨椂閽熷懆鏈燂紝瀵艰嚧鐩爣鍩?*瀹屽叏閲囨牱涓嶅埌**銆?
```
clk_src  鈹屸攼鈹屸攼鈹屸攼鈹屸攼鈹屸攼鈹屸攼鈹屸攼鈹屸攼
         鈹樷敂鈹樷敂鈹樷敂鈹樷敂鈹樷敇鈹斺敇鈹斺敇鈹斺敇鈹?
pulse_src 鈹€鈹?           鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€  (浠?涓猚lk_src鍛ㄦ湡瀹?

clk_dst     鈹屸攢鈹€鈹? 鈹屸攢鈹€鈹? 鈹屸攢鈹€鈹?            鈹斺攢鈹€鈹? 鈹斺攢鈹€鈹? 鈹斺攢鈹€鈹?
pulse_dst 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€  (鏈閲囨牱鍒?)
```

### 鏂规涓€锛歍oggle鍚屾鍣紙鏈€甯哥敤锛?
婧愬煙灏嗚剦鍐茶浆鎹负鐢靛钩缈昏浆锛岀洰鏍囧煙妫€娴嬬炕杞竟娌匡細

```verilog
module pulse_sync_toggle (
    input  logic clk_src,
    input  logic rst_n,
    input  logic pulse_src,    // 婧愬煙鑴夊啿
    input  logic clk_dst,
    output logic pulse_dst     // 鐩爣鍩熻剦鍐?);

    // ---------- 婧愭椂閽熷煙锛氳剦鍐?鈫?缈昏浆鐢靛钩 ----------
    logic toggle_src;
    always_ff @(posedge clk_src or negedge rst_n) begin
        if (!rst_n)
            toggle_src <= 1'b0;
        else if (pulse_src)
            toggle_src <= ~toggle_src;
    end

    // ---------- 鐩爣鏃堕挓鍩燂細鍚屾 + 杈规部妫€娴?----------
    logic toggle_sync, toggle_sync_d;

    sync_2ff #(.INIT(1'b0)) u_sync (
        .clk_dst(clk_dst),
        .rst_n(rst_n),
        .sig_src(toggle_src),
        .sig_dst(toggle_sync)
    );

    always_ff @(posedge clk_dst or negedge rst_n) begin
        if (!rst_n)
            toggle_sync_d <= 1'b0;
        else
            toggle_sync_d <= toggle_sync;
    end

    // 杈规部妫€娴嬶細褰撳墠鍊间笌涓婁竴鍛ㄦ湡涓嶅悓 鈫?杈撳嚭鑴夊啿
    assign pulse_dst = toggle_sync ^ toggle_sync_d;

endmodule
```

鏃跺簭娉㈠舰锛?
```
clk_src     鈹屸攼鈹屸攼鈹屸攼鈹屸攼鈹屸攼鈹屸攼
            鈹樷敂鈹樷敂鈹樷敂鈹樷敇鈹斺敇鈹斺敇鈹?
pulse_src   鈹€鈹?             鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€

toggle_src  鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?                      鈹斺攢鈹€鈹€鈹€  (鐢靛钩缈昏浆)

clk_dst         鈹屸攢鈹€鈹? 鈹屸攢鈹€鈹? 鈹屸攢鈹€鈹? 鈹屸攢鈹€鈹?                鈹斺攢鈹€鈹? 鈹斺攢鈹€鈹? 鈹斺攢鈹€鈹? 鈹斺攢鈹€鈹?
toggle_sync 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹? (缁忚繃2绾у悓姝?
                           鈹斺攢鈹€鈹€鈹€鈹€鈹€

pulse_dst   鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹? (杈规部妫€娴嬭緭鍑?
                               鈹斺攢鈹€
```

### 鏂规浜岋細鍙嶉纭鍚屾鍣?
閫傜敤浜庢簮鍩熼渶瑕佺‘璁よ剦鍐插凡琚洰鏍囧煙鎺ユ敹鐨勫満鏅紙閫熺巼鏇翠綆浣嗘洿鍙潬锛夛細

```verilog
module pulse_sync_ack (
    input  logic clk_src, rst_n,
    input  logic pulse_src,
    input  logic clk_dst,
    output logic pulse_dst
);

    logic req_src, ack_src, req_dst;

    // 婧愬煙锛氳姹傚彂鍑?& 绛夊緟纭
    always_ff @(posedge clk_src or negedge rst_n) begin
        if (!rst_n)
            req_src <= 1'b0;
        else if (pulse_src)
            req_src <= 1'b1;
        else if (ack_src)
            req_src <= 1'b0;
    end

    // 鐩爣鍩燂細鍚屾璇锋眰骞剁敓鎴愯剦鍐?    logic req_sync;
    sync_2ff u_sync_req (.clk_dst(clk_dst), .rst_n(rst_n),
                         .sig_src(req_src), .sig_dst(req_sync));

    logic req_sync_d;
    always_ff @(posedge clk_dst or negedge rst_n) begin
        if (!rst_n) req_sync_d <= 1'b0;
        else        req_sync_d <= req_sync;
    end
    assign pulse_dst = req_sync & ~req_sync_d;

    // 鍥炰紶纭
    sync_2ff u_sync_ack (.clk_dst(clk_src), .rst_n(rst_n),
                         .sig_src(req_sync), .sig_dst(ack_src));

endmodule
```

---

## 鎻℃墜鍗忚鍚屾

### 閫傜敤鍦烘櫙

褰撻渶瑕佽法鏃堕挓鍩熶紶杈?*澶氫綅鏁版嵁鎬荤嚎**涓斿鍚炲悙閲忚姹備笉楂樻椂锛屾彙鎵嬪崗璁槸姣斿紓姝IFO鏇寸畝鍗曠殑鏂规銆?
### req-ack 鎻℃墜鍗忚

```
婧愭椂閽熷煙                          鐩爣鏃堕挓鍩?鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?                   鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?鈹?鏁版嵁瀵勫瓨 鈹傗攢鈹€鈹€鈹€ data_bus 鈹€鈹€鈹€鈹€鈻衡攤 鏁版嵁瀵勫瓨 鈹?鈹?        鈹?                   鈹?        鈹?鈹?req鍙戣捣  鈹傗攢鈹€鈹€鈹€ req 鈹€鈹€[鍚屾]鈹€鈹€鈻衡攤 req妫€娴? 鈹?鈹?        鈹?                   鈹?        鈹?鈹?ack鎺ユ敹  鈹傗梽鈹€鈹€[鍚屾]鈹€鈹€ ack 鈹€鈹€鈹€鈹?ack搴旂瓟  鈹?鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?                   鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?```

```verilog
module handshake_sync #(
    parameter DATA_WIDTH = 8
)(
    // 婧愮鍙?    input  logic                    clk_src,
    input  logic                    rst_n,
    input  logic                    valid_src,
    input  logic [DATA_WIDTH-1:0]   data_src,
    output logic                    ready_src,
    // 鐩爣绔彛
    input  logic                    clk_dst,
    output logic                    valid_dst,
    output logic [DATA_WIDTH-1:0]   data_dst,
    input  logic                    ready_dst
);

    // ---------- 婧愭椂閽熷煙 ----------
    logic req_src, ack_src_sync, ack_src_sync_d;
    logic [DATA_WIDTH-1:0] data_reg;

    // 鏁版嵁閿佸瓨锛氬湪req鍙戣捣鏃堕攣瀛樻暟鎹?    always_ff @(posedge clk_src or negedge rst_n) begin
        if (!rst_n) begin
            req_src <= 1'b0;
            data_reg <= '0;
        end else if (valid_src && ready_src) begin
            req_src <= 1'b1;
            data_reg <= data_src;
        end else if (ack_src_sync && !ack_src_sync_d) begin
            // 妫€娴嬪埌ack涓婂崌娌匡紝瀹屾垚鎻℃墜
            req_src <= 1'b0;
        end
    end

    // ack鍚屾鍒版簮鍩?    logic ack_raw;
    sync_2ff u_sync_ack (.clk_dst(clk_src), .rst_n(rst_n),
                         .sig_src(ack_raw), .sig_dst(ack_src_sync));

    always_ff @(posedge clk_src or negedge rst_n) begin
        if (!rst_n) ack_src_sync_d <= 1'b0;
        else        ack_src_sync_d <= ack_src_sync;
    end

    assign ready_src = !req_src;

    // ---------- 鐩爣鏃堕挓鍩?----------
    logic req_sync, req_sync_d;

    // req鍚屾鍒扮洰鏍囧煙
    sync_2ff u_sync_req (.clk_dst(clk_dst), .rst_n(rst_n),
                         .sig_src(req_src), .sig_dst(req_sync));

    always_ff @(posedge clk_dst or negedge rst_n) begin
        if (!rst_n) req_sync_d <= 1'b0;
        else        req_sync_d <= req_sync;
    end

    // req涓婂崌娌?鈫?杈撳嚭valid
    logic valid_dst_r;
    always_ff @(posedge clk_dst or negedge rst_n) begin
        if (!rst_n)
            valid_dst_r <= 1'b0;
        else if (req_sync && !req_sync_d)
            valid_dst_r <= 1'b1;
        else if (ready_dst)
            valid_dst_r <= 1'b0;
    end

    assign valid_dst = valid_dst_r;
    assign data_dst  = data_reg;  // 鏁版嵁鍦╮eq鏈夋晥鏈熼棿绋冲畾

    // ack搴旂瓟
    always_ff @(posedge clk_dst or negedge rst_n) begin
        if (!rst_n) ack_raw <= 1'b0;
        else        ack_raw <= req_sync;  // 璺熼殢req
    end

endmodule
```

### 鎻℃墜鏃跺簭鍥?
```
clk_src   鈹屸攼鈹屸攼鈹屸攼鈹屸攼鈹屸攼鈹屸攼鈹屸攼鈹屸攼鈹屸攼鈹屸攼
          鈹樷敂鈹樷敂鈹樷敂鈹樷敂鈹樷敂鈹樷敂鈹樷敂鈹樷敂鈹樷敂鈹樷敂鈹?
valid_src 鈹€鈹?           鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€

req_src   鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?                                   鈹斺攢鈹€

clk_dst      鈹屸攢鈹€鈹? 鈹屸攢鈹€鈹? 鈹屸攢鈹€鈹? 鈹屸攢鈹€鈹? 鈹屸攢鈹€鈹?             鈹斺攢鈹€鈹? 鈹斺攢鈹€鈹? 鈹斺攢鈹€鈹? 鈹斺攢鈹€鈹? 鈹斺攢鈹€鈹?
req_sync  鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?                                        鈹斺攢鈹€

valid_dst 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?                                           鈹斺攢鈹€

ack_raw   鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?                                            鈹斺攢鈹€

ack_sync  鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?                                                鈹斺攢鈹€
          鈹傗啇鈹€鈹€ 鎻℃墜寤惰繜 鈮?2脳T_src + 2脳T_dst 鈹€鈹€鈫掆攤
```

---

## CDC楠岃瘉鏂规硶

### 闈欐€佹鏌ワ紙CDC宸ュ叿鍒嗘瀽锛?
闈欐€丆DC鍒嗘瀽鏄?*鏈€鏍稿績銆佹渶楂樻晥**鐨凜DC楠岃瘉鎵嬫锛屾棤闇€浠跨湡鍗冲彲绌蜂妇鎵€鏈塁DC璺緞銆?
**妫€鏌ュ唴瀹癸細**

| 妫€鏌ラ」 | 璇存槑 |
|--------|------|
| 缂哄皯鍚屾鍣?| 淇″彿璺ㄨ秺鏃堕挓鍩熶絾鏈粡杩囧悓姝ュ櫒 |
| 澶氫綅淇″彿鐙珛鍚屾 | 澶氫綅鎬荤嚎姣忎綅鍒嗗埆鍚屾锛屽鑷存暟鎹笉涓€鑷?|
| 缁勫悎閫昏緫鍚庡悓姝?| 鍚屾鍣ㄥ墠鏈夌粍鍚堥€昏緫锛屽彲鑳戒骇鐢熸瘺鍒?|
| 澶嶄綅鍚屾闂 | 寮傛澶嶄綅閲婃斁鏃跺簭涓嶆弧瓒虫仮澶?绉婚櫎鏃堕棿 |
| 鏃堕挓鍒嗛鍣ㄦ湭鍚屾 | 鍒嗛鍣ㄨ緭鍑鸿法鍩熸湭澶勭悊 |
| 闂ㄦ帶鏃堕挓闂 | 闂ㄦ帶鏃堕挓瀵艰嚧浣胯兘淇″彿鐨凜DC闂 |

**鍏稿瀷CDC宸ュ叿浣跨敤娴佺▼锛?*

```tcl
# SpyGlass CDC 娴佺▼绀轰緥
read_file -type verilog {./rtl/*.sv}
current_design top_module

# 璁剧疆鏃堕挓
set_option stop {module_name}
clock -name clk_a -period 10
clock -name clk_b -period 15

# 杩愯CDC鍒嗘瀽
run_goal cdc/cdc_verify

# 鏌ョ湅鎶ュ憡
report_goal cdc/cdc_verify -output cdc_report.rpt
```

### 鍔ㄦ€侀獙璇侊紙绾︽潫闅忔満娴嬭瘯锛?
鍔ㄦ€丆DC楠岃瘉閫氳繃**娉ㄥ叆浜氱ǔ鎬佸欢杩?*鏉ユā鎷熺湡瀹炵‖浠惰涓猴細

```verilog
// CDC楠岃瘉涓撶敤鎺ュ彛锛氭敞鍏ラ殢鏈哄欢杩?interface cdc_if (input logic clk_a, input logic clk_b);
    logic sig_a;
    logic sig_b;

    // 鍦ㄤ俊鍙疯法鍩熸椂娉ㄥ叆0~1涓懆鏈熺殑闅忔満寤惰繜
    clocking cb_src @(posedge clk_a);
        output sig_a;
    endclocking

    // 妯℃嫙浜氱ǔ鎬侊細闅忔満閫夋嫨閲囨牱鏃跺埢
    task automatic inject_metastability(ref logic signal);
        randcase
            1: #0;                    // 姝ｅ父閲囨牱
            1: #(0.1ns);              // 杞诲井寤惰繜
            1: #(0.5ns);              // 鎺ヨ繎浜氱ǔ鎬?        endcase
    endtask
endinterface

// CDC楠岃瘉娴嬭瘯鐢ㄤ緥
class cdc_random_test extends uvm_test;
    `uvm_component_utils(cdc_random_test)

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        repeat (10000) begin
            // 闅忔満鍖栨椂閽熼鐜囨瘮
            cfg.randomize() with {
                clk_a_period inside {[5:20]};
                clk_b_period inside {[8:30]};
            };

            // 闅忔満鍖栨暟鎹ā寮?            send_random_transaction();

            // 妫€鏌DC鏁版嵁涓€鑷存€?            check_cdc_consistency();
        end

        phase.drop_objection(this);
    endtask
endclass
```

### 褰㈠紡楠岃瘉

鍒╃敤褰㈠紡鍖栨柟娉曡瘉鏄嶤DC鐢佃矾鐨勬纭€э細

```verilog
// 浣跨敤SVA楠岃瘉FIFO绌烘爣蹇楃殑姝ｇ‘鎬?property p_fifo_empty_correct;
    @(posedge rd_clk) disable iff (!rd_rst_n)
    (rd_ptr_gray == wr_ptr_gray_sync) |-> empty;
endproperty

assert property (p_fifo_empty_correct)
    else `uvm_error("CDC", "FIFO empty flag incorrect!");

// 楠岃瘉鑴夊啿鍚屾鍣ㄤ笉浼氫涪澶辫剦鍐?property p_pulse_no_loss;
    @(posedge clk_src) disable iff (!rst_n)
    $rose(pulse_src) |-> ##[3:6] $rose(pulse_dst);
    // 鑴夊啿鍙戝嚭鍚庯紝3~6涓洰鏍囨椂閽熷懆鏈熷唴蹇呴』鍑虹幇杈撳嚭鑴夊啿
endproperty
```

---

## 甯歌CDC閿欒涓庢渚?
### 閿欒1锛氬浣嶆€荤嚎閫愪綅鍚屾

**閿欒鍐欐硶锛?*

```verilog
// 鉂?閿欒锛氬浣嶆暟鎹瘡浣嶇嫭绔嬪悓姝ワ紝鍙兘閲囨牱鍒颁笉鍚屽懆鏈熺殑鍊?logic [3:0] data_src, data_sync1, data_dst;

always_ff @(posedge clk_dst or negedge rst_n) begin
    if (!rst_n) begin
        data_sync1 <= '0;
        data_dst   <= '0;
    end else begin
        data_sync1 <= data_src;  // 4浣嶅垎鍒悓姝?        data_dst   <= data_sync1;
    end
end
```

**闂锛?* 濡傛灉 `data_src` 浠?`4'b0111` 鍙樹负 `4'b1000`锛屽悓姝ュ櫒鍙兘閲囨牱鍒?`4'b0100`銆乣4'b1110` 绛変腑闂存€併€?
**姝ｇ‘鏂规锛?*

```verilog
// 鉁?姝ｇ‘锛氫娇鐢ㄥ紓姝IFO銆佹牸闆风爜鎴栨彙鎵嬪崗璁?// 鏂规1锛氭牸闆风爜锛堥€傜敤浜庤鏁板櫒/鍦板潃锛?// 鏂规2锛氬紓姝IFO锛堥€傜敤浜庢暟鎹祦锛?// 鏂规3锛氭彙鎵嬪崗璁紙閫傜敤浜庝綆閫熸帶鍒朵俊鍙凤級
```

### 閿欒2锛氱粍鍚堥€昏緫鍚庢帴鍚屾鍣?
```verilog
// 鉂?閿欒锛氱粍鍚堥€昏緫鍙兘浜х敓姣涘埡
logic a, b, cdc_in;
assign cdc_in = a & b;  // 缁勫悎閫昏緫杈撳嚭

sync_2ff u_sync (.clk_dst(clk_dst), .rst_n(rst_n),
                 .sig_src(cdc_in), .sig_dst(cdc_out));

// 鉁?姝ｇ‘锛氬厛鍦ㄦ簮鍩熷瘎瀛樹竴鎷?logic cdc_in_reg;
always_ff @(posedge clk_src or negedge rst_n) begin
    if (!rst_n) cdc_in_reg <= 1'b0;
    else        cdc_in_reg <= a & b;
end

sync_2ff u_sync (.clk_dst(clk_dst), .rst_n(rst_n),
                 .sig_src(cdc_in_reg), .sig_dst(cdc_out));
```

### 閿欒3锛氬紓姝ュ浣嶉噴鏀炬湭鍚屾

```verilog
// 鉂?閿欒锛氬紓姝ュ浣嶉噴鏀惧彲鑳借繚鍙嶆仮澶?绉婚櫎鏃堕棿
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) q <= 1'b0;
    else        q <= d;
end

// 鉁?姝ｇ‘锛氬紓姝ュ浣嶅悓姝ラ噴鏀?logic rst_n_sync;
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) rst_n_sync <= 1'b0;   // 寮傛澶嶄綅
    else        rst_n_sync <= 1'b1;   // 鍚屾閲婃斁
end

always_ff @(posedge clk or negedge rst_n_sync) begin
    if (!rst_n_sync) q <= 1'b0;
    else             q <= d;
end
```

### 瀹為檯妗堜緥锛歋PI鎺ュ彛CDC闂

```
妗堜緥鑳屾櫙锛氭煇SoC鐨凷PI Master杩愯鍦?00MHz锛屽鎺lash杩愯鍦?0MHz銆?         閰嶇疆瀵勫瓨鍣ㄥ湪APB鍩?25MHz)锛岀洿鎺ラ€佸埌SPI鍩熷鑷村伓鍙戦厤缃敊璇€?
鏍瑰洜锛?浣嶉厤缃瘎瀛樺櫒[7:0]鐩存帴璺ㄥ煙锛屾湭鍋欳DC澶勭悊銆?      閰嶇疆浠?x55鍙樹负0xAA鏃讹紝閲囨牱鍒?x75绛変腑闂村€笺€?
淇锛氬皢閰嶇疆瀵勫瓨鍣ㄦ敼涓?鍐欏叆-鎻℃墜-鏇存柊"鏈哄埗锛?      1. APB鍩熷啓鍏ラ厤缃埌褰卞瓙瀵勫瓨鍣?      2. 閫氳繃鑴夊啿鍚屾鍣ㄥ彂閫佹洿鏂拌姹?      3. SPI鍩熸敹鍒拌姹傚悗锛屼粠褰卞瓙瀵勫瓨鍣ㄥ姞杞介厤缃?      4. 閫氳繃鎻℃墜鍗忚鍥炰紶纭
```

---

## CDC楠岃瘉宸ュ叿

### SpyGlass CDC

Synopsys鐨凷pyGlass CDC鏄笟鐣屾渶骞挎硾浣跨敤鐨勯潤鎬丆DC鍒嗘瀽宸ュ叿锛?
**鏍稿績妫€鏌ヨ鍒欙細**

| 瑙勫垯ID | 妫€鏌ュ唴瀹?| 涓ラ噸绾у埆 |
|--------|---------|---------|
| CDCR01 | 璺ㄦ椂閽熷煙淇″彿缂哄皯鍚屾鍣?| Error |
| CDCR02 | 澶氫綅淇″彿鐙珛鍚屾 | Error |
| CDCR03 | 鍚屾鍣ㄥ墠瀛樺湪缁勫悎閫昏緫 | Warning |
| CDCR04 | 澶嶄綅淇″彿璺ㄥ煙鏈悓姝?| Error |
| CDCR05 | 闂ㄦ帶鏃堕挓浣胯兘淇″彿璺ㄥ煙 | Warning |
| WYSIWYGS | 鍚屾鍣ㄧ粨鏋勮瘑鍒?| Info |

**鍏稿瀷浣跨敤娴佺▼锛?*

```tcl
# 1. 璇诲叆璁捐
read_file -type sverilog ./rtl/top.sv
current_design top

# 2. 绾︽潫璁剧疆
set_option enableSV yes
set_option enableV05 yes

# 3. 瀹氫箟鏃堕挓鍩?clock -name sys_clk -period 10 -domain D1
clock -name usb_clk -period 16.67 -domain D2
clock -name eth_clk  -period 8 -domain D3

# 4. 鎸囧畾鍚屾鍣ㄥ簱
set_option lib sync_cells.lib

# 5. 杩愯鍒嗘瀽
run_goal cdc/cdc_abstract -dmsw cdc

# 6. 瀹￠槄鍜寃aive
# 瀵圭‘璁ゅ畨鍏ㄧ殑CDC璺緞娣诲姞waiver
waiver -goal cdc -rule CDCR01 -comment "Confirmed safe toggle sync"
```

### Questa CDC

Siemens EDA鐨凲uesta CDC锛堝師0in CDC锛夐泦鎴愬湪Questa楠岃瘉骞冲彴涓細

**鐗圭偣锛?*
- 涓嶲uesta浠跨湡鐜娣卞害闆嗘垚
- 鏀寔褰㈠紡鍖朇DC楠岃瘉
- 鍙笌UVM楠岃瘉骞冲彴鑱斿姩
- 鑷姩璇嗗埆鍚屾鍣ㄧ粨鏋勶紙FF銆丮UX銆丷AM绛夛級

```tcl
# Questa CDC 娴佺▼
vlog -sv rtl/*.sv
vsim -c -do "cdc_setup.do" work.top

# 杩愯CDC妫€鏌?cdc check -all
cdc report -summary
cdc report -details -output cdc_detail.rpt
```

### 宸ュ叿瀵规瘮

| 鐗规€?| SpyGlass CDC | Questa CDC |
|------|-------------|------------|
| 鍘傚晢 | Synopsys | Siemens EDA |
| 鏂规硶 | 闈欐€佸垎鏋愪负涓?| 闈欐€?+ 褰㈠紡 |
| 闆嗘垚搴?| 鐙珛宸ュ叿 | 闆嗘垚鍦≦uesta骞冲彴 |
| 鍚屾鍣ㄨ瘑鍒?| 搴撳尮閰?+ 鑷畾涔?| 鑷姩鎺ㄦ柇 + 搴撳尮閰?|
| 鎶ュ憡璐ㄩ噺 | 璇︾粏鐨勮矾寰勮拷韪?| 浜や簰寮忔尝褰㈠洖婧?|
| 涓氱晫閲囩敤 | 鏈€骞挎硾 | 蹇€熷闀?|

---

## 鐩稿叧绗旇

- [[04-鏃堕挓鍧桟locking-Block]] - SystemVerilog鏃堕挓鍧椾笌淇″彿閲囨牱/椹卞姩鏃跺簭鎺у埗
- [[04-鏃跺簭闂鎺掓煡]] - 鏃跺簭杩濅緥涓庝慨澶嶆柟娉?- [[00-楠岃瘉璁″垝]] - 濡備綍鍦ㄩ獙璇佽鍒掍腑绾冲叆CDC娴嬭瘯椤?- [[01-瑕嗙洊鐜嘳] - CDC鐩稿叧鍔熻兘瑕嗙洊鐜囩殑瀹氫箟鏂规硶

---

## 鍙傝€冭祫婧?
- Clifford E. Cummings, "Clock Domain Crossing (CDC) Design & Verification Techniques Using SystemVerilog"
- SNUG 2008: "Synthesis and Scripting Techniques for Designing Multi-Asynchronous Clock Designs"
- Cadence: "Clock Domain Crossing (CDC) Verification White Paper"

