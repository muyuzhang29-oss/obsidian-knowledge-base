---
tags: [Verification, Clock, Gating, PLL, CTS, STA]
created: 2026-07-06
---

# 鏃堕挓闂ㄦ帶銆丳LL 涓庣墿鐞嗙骇鏃堕挓楠岃瘉

> SoC 鏃堕挓楠岃瘉涓櫎 CDC 澶栫殑涓夊ぇ纭欢楠岃瘉涓撻锛氭椂閽熼棬鎺?鍒囨崲銆丳LL 鏃堕挓鍙戠敓鍣ㄣ€丆TS 鐗╃悊楠岃瘉銆?

## 1. 鏃堕挓闂ㄦ帶楠岃瘉

### 1.1 鍩烘湰鍘熺悊

鏃堕挓闂ㄦ帶鏄渶甯哥敤鐨勪綆鍔熻€楁妧鏈細妯″潡涓嶅伐浣滄椂鍏抽棴鏃堕挓锛屽噺灏戝姩鎬佸姛鑰椼€傚吀鍨嬮泦鎴愭椂閽熼棬鎺у崟鍏冿紙ICG锛夊湪鏃堕挓浣庣數骞抽噰鏍蜂娇鑳戒俊鍙凤紝涓婂崌娌胯緭鍑虹ǔ瀹氶棬鎺ф椂閽熴€?

### 1.2 楠岃瘉瑕佺偣

- 浣胯兘淇″彿闇€鍦ㄦ椂閽熶綆鐢靛钩鏈熼棿鍙樺寲锛屽惁鍒欒緭鍑烘瘺鍒?
- AND 绫诲瀷闂ㄦ帶鐨勪娇鑳界炕杞繀椤诲湪浣庣數骞宠繘琛?
- 闂ㄦ帶鍙兘瀵艰嚧鏁版嵁鍦ㄩ潪棰勬湡鏃剁偣琚攣瀛?

### 1.3 楠岃瘉鏂规硶

- **鍔熻兘浠跨湡**锛氶亶鍘嗗悇宸ヤ綔鍦烘櫙涓嬬殑闂ㄦ帶琛屼负
- **褰㈠紡楠岃瘉**锛氬叏闈㈣瘉鏄庨棬鎺ч€昏緫姝ｇ‘鎬?
- **鏂█妫€鏌?*锛氱紪鍐?SVA 妫€鏌ラ棬鎺ф椂搴忚姹?

## 2. 鏃堕挓鍒囨崲楠岃瘉

### 2.1 搴旂敤鍦烘櫙

鍔熻€楁晱鎰?SoC 闇€瑕佸姩鎬佸垏鎹㈡椂閽熼鐜囨垨鏃堕挓婧愶紝濡傝礋杞藉彉鍖栨椂鍦ㄤ笉鍚?PLL 杈撳嚭闂村垏鎹€?

### 2.2 楠岃瘉瑕佺偣

- **姣涘埡妫€娴?*锛氬垏鎹㈣繃绋嬪繀椤绘棤姣涘埡
- **鍒囨崲椤哄簭**锛欼CG enable 缃?0 鈫?鍒囨崲閫夋嫨 鈫?鎷夐珮 enable
- 鏃堕挓瀵勫瓨鍣ㄩ厤缃纭?鈮?鍒囨崲姝ｇ‘
- 浣跨敤鏂█妯″潡瀹炴祴鏃堕挓棰戠巼骞朵笌棰勬湡瀵规瘮

## 3. PLL 涓庢椂閽熷彂鐢熷櫒楠岃瘉

### 3.1 楠岃瘉缁村害

| 缁村害 | 鍐呭 |
|------|------|
| 棰戠巼娴嬭瘯 | 杈撳嚭棰戠巼绗﹀悎瑙勬牸 |
| 鎶栧姩娴嬮噺 | 鐩镐綅鍣０涓庢姈鍔ㄧ壒鎬?|
| 鍐呯疆鑷祴璇?| 鑺墖绾?PLL 娴嬭瘯鑳藉姏 |
| 鍔熻兘娴嬭瘯 | 鍚勭宸ヤ綔妯″紡琛屼负姝ｇ‘鎬?|
| DFT | 鍙娴嬫€т笌鍙帶鎬?|

### 3.2 鍏抽敭鍙傛暟

- **鎶栧姩**锛氱洿鎺ュ奖鍝嶆椂搴忚閲忎笌绯荤粺绋冲畾鎬э紝PLL 鍚勫瓙鍧楄础鐚笉鍚?
- **鍋忔枩**锛氭椂閽熷埌杈句笉鍚岀粓鐐圭殑鏃堕棿宸紓锛孭LL/DLL 鍘绘姈鏂规硶褰卞搷涓嶅悓
- **鍗犵┖姣?*锛氳緭鍏?40-60%锛屽閮ㄨ緭鍑?45-55%锛孲CL 鎶栧姩鐩存帴褰卞搷鍗犵┖姣斿け鐪?

## 4. 鏃堕挓鏍戠患鍚堢墿鐞嗛獙璇?

### 4.1 CTS 娴佺▼

鎻掑叆缂撳啿鍣?鍙嶇浉鍣ㄦ瀯寤烘椂閽熸爲 鈫?浼樺寲鏃堕挓鏍戝強鏃跺簭 鈫?鏃堕挓鏍戠粫绾?鈫?鎵嬪姩璋冭妭 鈫?鏌ョ湅鎶ュ憡

### 4.2 鐗╃悊绾ч獙璇?

- 鏃堕挓鏍戝竷绾?DRC锛堟渶灏忓搴︺€侀棿璺濓級
- LVS/DRC/ERC 鐗堝浘涓€鑷存€?
- 宸ュ叿鍛戒护锛歚verify_clock_tree_physical`锛孯edHawk 鍔熻€楀垎鏋?

### 4.3 鍒嗘瀽鎸囨爣

- 鏃堕挓鍋忔枩锛坰kew锛?
- 鎻掑叆寤惰繜锛坕nsertion delay锛?
- 鍣０涓庡姛鑰?
- 鏃跺簭瑁曢噺

## 5. 鏃堕挓鐩戞帶妯″潡

### 5.1 鏍稿績鍔熻兘

- 鐩戞祴涓婂崌娌?涓嬮檷娌垮懆鏈熴€佺浉浣嶆寔缁椂闂?
- 娴嬮噺鍗犵┖姣斻€侀鐜囥€侀鐜囧垏鎹?
- 妫€娴嬫椂閽熶涪澶便€侀鐜囧亸宸?
- 鐢熸垚浜嬩欢/璀︽姤

### 5.2 瀹炵幇鏂瑰紡

鏃堕棿鎴虫崟鑾?鈫?鐩镐綅鎸佺画鏃堕棿璁＄畻 鈫?浜嬩欢鐢熸垚

鎺ㄨ崘鐢?SystemVerilog/UVM 瀹炵幇妯″潡鍖栥€佸彲閲嶇敤鐨勭洃鎺у櫒銆?

## 6. 澶氭牳澶氭灦鏋勬寫鎴?

7nm 鍙婁互涓嬭妭鐐归潰涓达細
- 杞ㄥ埌杞ㄦ晠闅溿€佸崰绌烘瘮澶辩湡
- 杞崲閫熺巼涓嬮檷銆佺數婧愬櫔澹?
- 浼犵粺 STA 绮惧害涓嶈冻

**瑙ｅ喅鏂规**锛氱綉鏍?鑴婃煴鏃堕挓鏋舵瀯銆丟ALS 璁捐椋庢牸銆丆lockEdge 楂樼簿搴﹀垎鏋愬伐鍏枫€?

---

**鍙傝**
- [[05-Verification/03-CDC楠岃瘉]] 鈥?璺ㄦ椂閽熷煙楠岃瘉
- [[05-Verification/06-鏃跺簭鍒嗘瀽鍩虹]] 鈥?STA 鏃跺簭鍒嗘瀽
- [[05-Verification/09-浣庡姛鑰椾笌澶氬煙楠岃瘉]] 鈥?UPF 涓?MDV
- [[05-Verification/10-鍔熻兘瀹夊叏涓庨珮绾ч獙璇佹柟娉昡] 鈥?ISO 26262 涓?ML

**鍙傝€冩潵婧?*
- [Efficient Clock Monitoring System for SoC Clock Verification](https://dvcon-proceedings.org/wp-content/uploads/efficient-clock-monitoring-system-for-soc-clock-verification.pdf)
- [Clock Monitors in SoC Verification - eInfochips](https://www.einfochips.com/wp-content/uploads/resources/Clock-monitors-in-SoC-Verification.pdf)
- [Verifying Dynamic Clock Switching in Power-Critical SoCs](https://www.design-reuse.com/article/61243-verifying-dynamic-clock-switching-in-power-critical-socs/)
- [Multi-Domain Verification: When Clock, Power and Reset Domains Collide](https://dvcon-proceedings.org/wp-content/uploads/multi-domain-verification-when-clock-power-and-reset-domains-collide.pdf)

