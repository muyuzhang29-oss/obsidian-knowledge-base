---
aliases: [绱㈠紩, Index, 鐩綍, 鎬荤洰褰昡
tags: [绱㈠紩, 鏍稿績]
created: 2026-04-01
updated: 2026-05-13
---

# 馃搼 鏁板瓧楠岃瘉宸ョ▼甯堢煡璇嗗簱绱㈠紩

> [!abstract] 馃摉 蹇€熷畾浣?> [[00-宸ヤ綔鍙?00-涓婚〉|馃彔 宸ヤ綔鍙癩] 路 [[00-宸ヤ綔鍙?01-浠婃棩浠诲姟|馃搵 浠婃棩浠诲姟]] 路 [[00-宸ヤ綔鍙?02-瀛︿範杩涘害|馃搱 瀛︿範杩涘害]] 路 鎸?`Ctrl+R` 鍒锋柊 Dataview

---

## 馃搳 鍐呭鎬昏

### 馃搱 缁熻姒傝

| 鎸囨爣 | 鏁板€?| 璇存槑 |
|------|------|------|
| 馃摑 鎬荤瑪璁版暟 | `=length(link("").file.inlinks)` | Markdown 鏂囦欢鎬绘暟锛堣繎浼硷級 |
| 馃搧 鍒嗙被鏁?| 11 | 涓€绾ф枃浠跺す鏁伴噺 |
| 馃彿锔?鏍囩鏁?| 42+ | 涓嶉噸澶嶆爣绛炬暟 |

### 馃搨 鐩綍缁撴瀯

```dataview
TABLE
  length(file.children) as "鏂囦欢鏁?,
  choice(length(file.children) > 0, "馃搧 鏂囦欢澶?, "馃搫 鍗曟枃浠?) as "绫诲瀷"
FROM "00-绱㈠紩"
WHERE file.name != "00-鎬荤储寮? AND file.name != "00-鎬荤储寮?鏂?
SORT file.name
```

---

## 馃幆 鏍稿績鏂囨。

> [!tip] 猸?蹇呰鏂囨。

### 馃摑 鍩虹鍏ラ棬
- `=link("01-SV璇硶/00-鍏ラ棬")` 鈥?#SV #鍏ラ棬
- `=link("02-UVM/00-鍏ラ棬")` 鈥?#UVM #鍏ラ棬
- `=link("06-Environment/00-鐜鎼缓")` 鈥?#UVM #瀹炶返

### 馃敩 鏍稿績鏈哄埗
- `=link("02-UVM/01-Phase鏈哄埗")` 鈥?#UVM #鏍稿績
- `=link("02-UVM/02-config_db")` 鈥?#UVM #鏍稿績
- `=link("02-UVM/03-Sequence鏈哄埗")` 鈥?#UVM #鏍稿績

### 馃攲 鍗忚瑙勮寖
- `=link("03-Protocol/AXI/00-AXI")` 鈥?#Protocol #AXI #鏍稿績
- `=link("03-Protocol/APB/00-APB")` 鈥?#Protocol #APB
- `=link("03-Protocol/I2C/00-I2C")` 鈥?#Protocol #I2C

### 馃挕 閲嶈姒傚康
- `=link("10-Notes/鏃堕殭-TimeSlot")` 鈥?#鏃跺簭 #FIFO #鏍稿績
- `=link("10-Notes/鏁板瓧瀵勫瓨鍣?)` 鈥?#瀵勫瓨鍣?#鏍稿績
- `=link("05-Verification/01-瑕嗙洊鐜?)` 鈥?#Verification #Coverage

---

## 馃彿锔?鎸夋爣绛剧储寮?
### #UVM - 楠岃瘉鏂规硶瀛?
```dataview
TABLE file.folder AS "鍒嗙被"
FROM "02-UVM" OR "11-UVM婧愮爜瀛︿範"
SORT file.name
```

### #SV - SystemVerilog

```dataview
TABLE file.folder AS "鍒嗙被"
FROM "01-SV璇硶"
SORT file.name
```

### #Protocol - 鍗忚瑙勮寖

```dataview
TABLE file.folder AS "鍒嗙被"
FROM "03-Protocol"
SORT file.name
```

### #Verification - 楠岃瘉鏂规硶

```dataview
TABLE file.folder AS "鍒嗙被"
FROM "05-Verification"
SORT file.name
```

### #Tool - 宸ュ叿浣跨敤

```dataview
TABLE file.folder AS "鍒嗙被"
FROM "04-Tools"
SORT file.name
```

### #Script - 鑴氭湰宸ュ叿

```dataview
TABLE file.folder AS "鍒嗙被"
FROM "07-Scripts"
SORT file.name
```

---

## 馃搧 鎸夌洰褰曠储寮?
### 馃摑 01-SV璇硶

```dataview
TABLE file.tags AS "鏍囩"
FROM "01-SV璇硶"
SORT file.name
```

### 馃敩 02-UVM

```dataview
TABLE file.tags AS "鏍囩"
FROM "02-UVM"
SORT file.name
```

### 馃攲 03-Protocol

```dataview
TABLE file.tags AS "鏍囩"
FROM "03-Protocol"
SORT file.name
```

### 馃敡 04-Tools

```dataview
TABLE file.tags AS "鏍囩"
FROM "04-Tools"
SORT file.name
```

### 鉁?05-Verification

```dataview
TABLE file.tags AS "鏍囩"
FROM "05-Verification"
SORT file.name
```

### 馃彈锔?06-Environment

```dataview
TABLE file.tags AS "鏍囩"
FROM "06-Environment"
SORT file.name
```

### 馃摐 07-Scripts

```dataview
TABLE file.tags AS "鏍囩"
FROM "07-Scripts"
SORT file.name
```

### 馃搾 10-Notes

```dataview
TABLE file.tags AS "鏍囩"
FROM "10-Notes"
SORT file.name
```

### 馃摎 11-UVM婧愮爜瀛︿範

```dataview
TABLE file.tags AS "鏍囩"
FROM "11-UVM婧愮爜瀛︿範"
SORT file.name
```

---

## 馃搨 鐩綍鏍?
```
knowledge-base/
鈹溾攢鈹€ 00-宸ヤ綔鍙?        馃彔 宸ヤ綔鍙颁笌浠〃鐩?鈹溾攢鈹€ 00-绱㈠紩/          馃搼 绱㈠紩鐩綍
鈹溾攢鈹€ 01-SV璇硶/        馃拵 SystemVerilog 璇硶涓庣壒鎬?鈹?  鈹溾攢鈹€ 00-鍏ラ棬.md
鈹?  鈹溾攢鈹€ 01-鏁版嵁绫诲瀷.md
鈹?  鈹斺攢鈹€ 02-绫?md
鈹溾攢鈹€ 02-UVM/           馃敩 UVM 楠岃瘉鏂规硶瀛?鈹?  鈹溾攢鈹€ 00-鍏ラ棬.md
鈹?  鈹溾攢鈹€ 01-Phase鏈哄埗.md
鈹?  鈹溾攢鈹€ 02-config_db.md
鈹?  鈹溾攢鈹€ 03-Sequence鏈哄埗.md
鈹?  鈹斺攢鈹€ 04-缁勪欢.md
鈹溾攢鈹€ 03-Protocol/      馃攲 鍗忚瑙勮寖
鈹?  鈹溾攢鈹€ AXI/         鈿?AXI 鎬荤嚎
鈹?  鈹溾攢鈹€ APB/         馃敆 APB 鎬荤嚎
鈹?  鈹溾攢鈹€ I2C/         馃摗 I2C 鎬荤嚎
鈹?  鈹溾攢鈹€ SPI/         馃攧 SPI 鎬荤嚎
鈹?  鈹斺攢鈹€ UART/        馃摠 UART 鎬荤嚎
鈹溾攢鈹€ 04-Tools/         馃敡 宸ュ叿鎸囦护
鈹?  鈹溾攢鈹€ Linux/       馃惂 Linux 鍛戒护
鈹?  鈹溾攢鈹€ GVim/        馃摑 GVim 缂栬緫鍣?鈹?  鈹溾攢鈹€ xrun/        馃枼锔?Cadence 浠跨湡鍣?鈹?  鈹斺攢鈹€ imc/         馃搳 瑕嗙洊鐜囧垎鏋?鈹溾攢鈹€ 05-Verification/  鉁?楠岃瘉鏂规硶瀛?鈹?  鈹溾攢鈹€ 00-楠岃瘉璁″垝.md
鈹?  鈹溾攢鈹€ 01-瑕嗙洊鐜?md
鈹?  鈹斺攢鈹€ 02-FMEA-FuSa.md
鈹溾攢鈹€ 06-Environment/   馃彈锔?鐜鎼缓
鈹?  鈹斺攢鈹€ 00-鐜鎼缓.md
鈹溾攢鈹€ 07-Scripts/       馃摐 鑴氭湰
鈹?  鈹溾攢鈹€ 00-Makefile.md
鈹?  鈹溾攢鈹€ 00-Python.md
鈹?  鈹斺攢鈹€ 01-Log瑙ｆ瀽.md
鈹溾攢鈹€ 08-Projects/      馃殌 椤圭洰
鈹溾攢鈹€ 09-Issues/        鈿狅笍 闂
鈹溾攢鈹€ 10-Notes/         馃搾 绗旇
鈹?  鈹溾攢鈹€ 鏃堕殭-TimeSlot.md
鈹?  鈹斺攢鈹€ 鏁板瓧瀵勫瓨鍣?md
鈹溾攢鈹€ 11-UVM婧愮爜瀛︿範/   馃摎 UVM 婧愮爜娣卞叆鐮旂┒
鈹?  鈹溾攢鈹€ UVM-浠巖un_test娴呰皥TestBench鍚姩.md
鈹?  鈹溾攢鈹€ UVM-uvm_component涓巙vm_root.md
鈹?  鈹溾攢鈹€ UVM-uvm涓殑factory鏈哄埗.md
鈹?  鈹斺攢鈹€ UVM婧愪唬鐮佺爺绌?md
鈹溾攢鈹€ 12-Life/          馃彔 鐢熸椿绠＄悊
鈹?  鈹溾攢鈹€ 01-鏃ュ父瑙勫垝/ 馃搵 姣忔棩璁″垝
鈹?  鈹溾攢鈹€ 02-璐︽湰/     馃挵 鏀舵敮绠＄悊
鈹?  鈹溾攢鈹€ 03-鍋ュ悍/     馃挭 鍋ュ悍杩借釜
鈹?  鈹溾攢鈹€ 04-闃呰/     馃摉 闃呰娓呭崟
鈹?  鈹斺攢鈹€ 05-鐩爣/     馃幆 鐩爣绠＄悊
鈹斺攢鈹€ 13-Archive/       馃梽锔?褰掓。
```

---

## 馃搱 瀛︿範璺緞

> [!example] 馃敩 UVM 瀛︿範璺緞
> 1. `=link("01-SV璇硶/00-鍏ラ棬")` - SV 鍩虹鍏ラ棬
> 2. `=link("02-UVM/00-鍏ラ棬")` - UVM 鍩虹鍏ラ棬
> 3. `=link("02-UVM/01-Phase鏈哄埗")` - Phase 鏈哄埗
> 4. `=link("02-UVM/02-config_db")` - config_db 鏈哄埗
> 5. `=link("02-UVM/03-Sequence鏈哄埗")` - Sequence 鏈哄埗
> 6. `=link("06-Environment/00-鐜鎼缓")` - 鐜鎼缓
> 7. `=link("11-UVM婧愮爜瀛︿範/UVM婧愪唬鐮佺爺绌?)` - UVM 婧愮爜鐮旂┒

> [!example] 馃攲 鍗忚瀛︿範璺緞
> 8. `=link("03-Protocol/APB/00-APB")` - APB锛堢畝鍗曪級
> 9. `=link("03-Protocol/AXI/00-AXI")` - AXI锛堝鏉傦級
> 10. `=link("03-Protocol/I2C/00-I2C")` - I2C锛堝璁撅級
> 11. `=link("03-Protocol/SPI/00-SPI")` - SPI锛堝璁撅級
> 12. `=link("03-Protocol/UART/00-UART")` - UART锛堝璁撅級

> [!example] 馃敡 宸ュ叿鎺屾彙
> 13. `=link("04-Tools/Linux/00-甯哥敤鍛戒护")` - Linux 鍩虹
> 14. `=link("04-Tools/GVim/00-蹇嵎閿?)` - GVim 缂栬緫鍣?> 15. `=link("07-Scripts/00-Python")` - Python 鑴氭湰
> 16. `=link("07-Scripts/00-Makefile")` - Makefile 鏋勫缓

> [!example] 鉁?楠岃瘉鏂规硶瀛?> 17. `=link("05-Verification/00-楠岃瘉璁″垝")` - 楠岃瘉璁″垝
> 18. `=link("05-Verification/01-瑕嗙洊鐜?)` - 瑕嗙洊鐜?> 19. `=link("05-Verification/02-FMEA-FuSa")` - FMEA/FuSa
> 20. `=link("06-Environment/00-鐜鎼缓")` - 鐜鎼缓

---

## 馃搳 鏇存柊璁板綍

> [!info] 馃搮 鏈€杩戞洿鏂?> ```dataview
> TABLE
>   file.folder AS "鍒嗙被",
>   file.mtime AS "鏇存柊鏃堕棿"
> FROM ""
> WHERE file.name != this.file.name
> SORT file.mtime DESC
> LIMIT 10
> ```

---

*鏈€鍚庢洿鏂? `=dateformat(date(now), "yyyy-MM-dd HH:mm")`*
