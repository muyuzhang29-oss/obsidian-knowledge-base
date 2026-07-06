---
aliases: [绱㈠紩, Index, 鐩綍]
tags: [绱㈠紩]
---

# 鐭ヨ瘑搴撶储寮?
> [!abstract] 蹇€熷畾浣?> 鏈储寮曚娇鐢?**Dataview** 鑷姩鐢熸垚锛屾坊鍔犳柊鏂囦欢鍚庢寜 `Ctrl+R` 鍒锋柊鍗冲彲鏇存柊銆?
---

## 鍐呭鎬昏

### 鐩綍缁撴瀯

```dataview
TABLE
length(file.children) as "鏂囦欢鏁?,
choice(length(file.children) > 0, "馃搧 鏂囦欢澶?, "馃搫 鍗曟枃浠?) as "绫诲瀷"
FROM "00-绱㈠紩"
WHERE file.name != "00-鎬荤储寮? AND file.name != "00-鎬荤储寮?鏂?
SORT file.name
```

**鎬昏**: ``=`length(list("01-SV璇硶", "02-UVM", "03-Protocol", "04-Tools", "05-Verification", "06-Environment", "07-Scripts", "10-Notes", "11-UVM婧愮爜瀛︿範"))` `` 涓垎绫?
### 鏂囦欢缁熻

```dataview
TABLE length(rows) as "鏂囦欢鏁?
FROM ""
WHERE file.extension = "md"
GROUP BY file.folder
SORT file.folder
```

---

## 鏍稿績鏂囨。

> [!tip] 蹇呰鏂囨。
> 浠ヤ笅鏂囨。鏄暣涓煡璇嗕綋绯荤殑鏍稿績锛屽缓璁紭鍏堟帉鎻°€?
### 鍩虹鍏ラ棬

| 鏂囨。 | 鏍囩 | 璇存槑 |
|------|------|------|
| [[00-鍏ラ棬]] | #SV #鍏ラ棬 | SystemVerilog 鍩虹鍏ラ棬 |
| [[00-鍏ラ棬]] | #UVM #鍏ラ棬 | UVM 楠岃瘉鏂规硶瀛﹀叆闂?|
| [[00-鐜鎼缓]] | #UVM #瀹炶返 | 瀹屾暣楠岃瘉鐜鎼缓 |

### 鏍稿績鏈哄埗

| 鏂囨。 | 鏍囩 | 璇存槑 |
|------|------|------|
| [[01-Phase鏈哄埗]] | #UVM #鏍稿績 | Phase 鎵ц椤哄簭涓庢満鍒?|
| [[02-config_db]] | #UVM #鏍稿績 | 閰嶇疆浼犻€掓満鍒?|
| [[03-Sequence鏈哄埗]] | #UVM #鏍稿績 | Sequence 鏈哄埗涓庝娇鐢?|

### 鍗忚瑙勮寖

| 鏂囨。 | 鏍囩 | 璇存槑 |
|------|------|------|
| [[00-AXI]] | #Protocol #AXI #鏍稿績 | AXI 鎬荤嚎鍗忚璇﹁В |
| [[00-APB]] | #Protocol #APB | APB 鎬荤嚎鍗忚 |
| [[00-I2C]] | #Protocol #I2C | I2C 鎬荤嚎鍗忚 |

### 閲嶈姒傚康

| 鏂囨。 | 鏍囩 | 璇存槑 |
|------|------|------|
| [[鏃堕殭-TimeSlot]] | #鏃跺簭 #FIFO #鏍稿績 | 鏃堕殭鍘熺悊涓庡紓姝?FIFO |
| [[鏁板瓧瀵勫瓨鍣╙] | #瀵勫瓨鍣?#鏍稿績 | 瀵勫瓨鍣ㄥ瓧娈靛懡鍚嶈鑼?|
| [[01-瑕嗙洊鐜嘳] | #Verification #Coverage | 瑕嗙洊鐜囬┍鍔ㄩ獙璇?|

---

## 鎸夋爣绛剧储寮?
### #UVM

```dataview
LIST
FROM "02-UVM"
SORT file.name
```

### #SV

```dataview
LIST
FROM "01-SV璇硶"
SORT file.name
```

### #Protocol

```dataview
LIST
FROM "03-Protocol"
SORT file.name
```

### #Tools

```dataview
LIST
FROM "04-Tools"
SORT file.name
```

### #Verification

```dataview
LIST
FROM "05-Verification"
SORT file.name
```

### #Scripts

```dataview
LIST
FROM "07-Scripts"
SORT file.name
```

### #UVM婧愮爜瀛︿範

```dataview
LIST
FROM "11-UVM婧愮爜瀛︿範"
SORT file.name
```

### #Notes

```dataview
LIST
FROM "10-Notes"
SORT file.name
```

---

## 鐩綍鏍?
```
knowledge-base/
鈹溾攢鈹€ 00-绱㈠紩/          # 鏈枃妗?鈹溾攢鈹€ 01-SV璇硶/        # SystemVerilog 璇硶涓庣壒鎬?鈹?  鈹溾攢鈹€ 00-鍏ラ棬.md
鈹?  鈹溾攢鈹€ 01-鏁版嵁绫诲瀷.md
鈹?  鈹斺攢鈹€ 02-绫?md
鈹溾攢鈹€ 02-UVM/           # UVM 楠岃瘉鏂规硶瀛?鈹?  鈹溾攢鈹€ 00-鍏ラ棬.md
鈹?  鈹溾攢鈹€ 01-Phase鏈哄埗.md
鈹?  鈹溾攢鈹€ 02-config_db.md
鈹?  鈹溾攢鈹€ 03-Sequence鏈哄埗.md
鈹?  鈹斺攢鈹€ 04-缁勪欢.md
鈹溾攢鈹€ 03-Protocol/      # 鍗忚瑙勮寖
鈹?  鈹溾攢鈹€ AXI/
鈹?  鈹溾攢鈹€ APB/
鈹?  鈹溾攢鈹€ I2C/
鈹?  鈹溾攢鈹€ SPI/
鈹?  鈹斺攢鈹€ UART/
鈹溾攢鈹€ 04-Tools/         # 宸ュ叿鎸囦护
鈹?  鈹溾攢鈹€ Linux/
鈹?  鈹溾攢鈹€ GVim/
鈹?  鈹溾攢鈹€ xrun/         # Cadence 浠跨湡鍣?鈹?  鈹斺攢鈹€ imc/          # 瑕嗙洊鐜囧垎鏋?鈹溾攢鈹€ 05-Verification/   # 楠岃瘉鏂规硶瀛?鈹?  鈹溾攢鈹€ 00-楠岃瘉璁″垝.md
鈹?  鈹溾攢鈹€ 01-瑕嗙洊鐜?md
鈹?  鈹斺攢鈹€ 02-FMEA-FuSa.md
鈹溾攢鈹€ 06-Environment/   # 鐜鎼缓
鈹?  鈹斺攢鈹€ 00-鐜鎼缓.md
鈹溾攢鈹€ 07-Scripts/       # 鑴氭湰
鈹?  鈹溾攢鈹€ 00-Makefile.md
鈹?  鈹溾攢鈹€ 00-Python.md
鈹?  鈹斺攢鈹€ 01-Log瑙ｆ瀽.md
鈹溾攢鈹€ 08-Projects/      # 椤圭洰锛堝緟濉厖锛?鈹溾攢鈹€ 09-Issues/        # 闂锛堝緟濉厖锛?鈹溾攢鈹€ 10-Notes/         # 绗旇
鈹?  鈹溾攢鈹€ 鏃堕殭-TimeSlot.md
鈹?  鈹斺攢鈹€ 鏁板瓧瀵勫瓨鍣?md
鈹斺攢鈹€ 11-UVM婧愮爜瀛︿範/   # UVM 婧愮爜娣卞叆鐮旂┒
    鈹溾攢鈹€ UVM-浠巖un_test娴呰皥TestBench鍚姩.md
    鈹溾攢鈹€ UVM-uvm_component涓巙vm_root.md
    鈹溾攢鈹€ UVM-uvm涓殑factory鏈哄埗.md
    鈹斺攢鈹€ UVM婧愪唬鐮佺爺绌?md
```

---

## 瀛︿範璺緞

> [!example] UVM 瀛︿範璺緞
> ```
> SV 鍏ラ棬 鈫?UVM 鍏ラ棬 鈫?Phase 鏈哄埗 鈫?config_db 鈫?Sequence 鈫?鐜鎼缓 鈫?UVM 婧愮爜娣卞叆鐮旂┒
> ```

> [!example] 鍗忚瀛︿範璺緞
> ```
> APB锛堢畝鍗曪級鈫?AXI锛堝鏉傦級鈫?I2C / SPI / UART锛堝璁撅級
> ```

> [!example] 宸ュ叿鎺屾彙
> ```
> Linux 鍩虹 鈫?GVim 鈫?Python 鑴氭湰 鈫?Makefile
> ```

> [!example] 楠岃瘉鏂规硶瀛?> ```
> 楠岃瘉璁″垝 鈫?瑕嗙洊鐜?鈫?FMEA/FuSa 鈫?鐜鎼缓
> ```

---

## 鑴氭湰宸ュ叿

| 鑴氭湰 | 鍔熻兘 | 浣跨敤鏂规硶 |
|------|------|----------|
| `auto-classify.ps1` | 鑷姩鍒嗙被涓庢爣绛?| `.\auto-classify.ps1 -AutoTag` |
| `random-review.ps1` | 闅忔満澶嶄範 | `.\random-review.ps1 -Count 5` |
| `search-knowledgebase.ps1` | 鎼滅储鐭ヨ瘑搴?| `.\search-knowledgebase.ps1 -Query "鍏抽敭璇?` |
| `sync-onedrive.ps1` | 鍚屾鍒癘neDrive | `.\sync-onedrive.ps1 -Action sync` |

---

*鏈€鍚庢洿鏂? `=dateformat(date(now), "yyyy-MM-dd")`*
