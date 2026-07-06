---
cssclass: dashboard
banner_y: 0.3
banner_lock: true
created: 2026-04-01
updated: 2026-05-13
tags:
  - home
  - dashboard
  - 绱㈠紩
aliases:
  - 涓婚〉
  - 棣栭〉
  - Dashboard
---

# 馃彔 鏁板瓧楠岃瘉宸ョ▼甯堢煡璇嗗簱

> [!quote] 馃挕
> **鑺墖楠岃瘉** 路 **UVM鏂规硶瀛?* 路 **鍗忚瑙勮寖** 路 **鎸佺画绮捐繘**

---

## 馃搳 鐭ヨ瘑搴撴瑙?
> [!info] 馃搱 鏁版嵁缁熻
> 
> | 鎸囨爣 | 鏁板€?| 璇存槑 |
> |------|------|------|
> | 馃摑 鎬荤瑪璁版暟 | `=length(dv.pages("").where(p => p.file.extension == "md"))` | Markdown 鏂囦欢鎬绘暟 |
> | 馃搧 鍒嗙被鏁?| `=length(dv.pages("").where(p => p.file.folder.split("/").length == 1 && p.file.folder != ""))` | 涓€绾ф枃浠跺す鏁伴噺 |
> | 馃彿锔?鏍囩鏁?| `=length(dv.pages("").flatMap(p => p.file.tags))` | 鎵€鏈夋爣绛炬€绘暟 |
> | 馃敆 閾炬帴鏁?| `=length(dv.pages("").flatMap(p => p.file.inlinks))` | 鍙屽悜閾炬帴鎬绘暟 |

---

## 馃幆 蹇€熷鑸?
### 馃摎 鏍稿績瀛︿範璺緞

> [!example]- 馃敩 UVM 楠岃瘉鏂规硶瀛?> 
> ```mermaid
> graph LR
>     A[SV 鍩虹] --> B[UVM 鍏ラ棬]
>     B --> C[Phase 鏈哄埗]
>     C --> D[config_db]
>     D --> E[Sequence 鏈哄埗]
>     E --> F[鐜鎼缓]
>     F --> G[婧愮爜鐮旂┒]
>     
>     style A fill:#fce7f3,stroke:#ec4899,color:#9d174d
>     style B fill:#dbeafe,stroke:#3b82f6,color:#1e40af
>     style C fill:#dbeafe,stroke:#3b82f6,color:#1e40af
>     style D fill:#dbeafe,stroke:#3b82f6,color:#1e40af
>     style E fill:#dbeafe,stroke:#3b82f6,color:#1e40af
>     style F fill:#dcfce7,stroke:#22c55e,color:#166534
>     style G fill:#93c5fd,stroke:#2563eb,color:#1e3a8a
> ```
> 
> **杩涘害**: 6/7 瀹屾垚

> [!example]- 馃攲 鍗忚瑙勮寖瀛︿範
> 
> ```mermaid
> graph LR
>     A[APB 绠€鍗昡 --> B[AXI 澶嶆潅]
>     B --> C[I2C]
>     B --> D[SPI]
>     B --> E[UART]
>     
>     style A fill:#bae6fd,stroke:#0369a1,color:#0c4a6e
>     style B fill:#e9d5ff,stroke:#7c3aed,color:#6d28d9
>     style C fill:#fef3c7,stroke:#d97706,color:#92400e
>     style D fill:#dcfce7,stroke:#16a34a,color:#166534
>     style E fill:#fee2e2,stroke:#dc2626,color:#991b1b
> ```
> 
> **杩涘害**: 5/5 瀹屾垚

---

### 馃搨 鐭ヨ瘑鍒嗙被

> [!note]- 馃摑 **SystemVerilog** - 纭欢鎻忚堪璇█
> 
> | 鏂囨。 | 鏍囩 | 鏇存柊鏃堕棿 |
> |------|------|----------|
> | `=link("01-SV璇硶/00-鍏ラ棬")` | #SV #鍏ラ棬 | `=dv.pages("01-SV璇硶/00-鍏ラ棬").file.mtime` |
> | `=link("01-SV璇硶/01-鏁版嵁绫诲瀷")` | #SV #鏁版嵁绫诲瀷 | `=dv.pages("01-SV璇硶/01-鏁版嵁绫诲瀷").file.mtime` |
> | `=link("01-SV璇硶/02-绫?)` | #SV #OOP | `=dv.pages("01-SV璇硶/02-绫?).file.mtime` |
> 
> **鎬昏**: 3 绡?
> [!note]- 馃敩 **UVM** - 楠岃瘉鏂规硶瀛?> 
> | 鏂囨。 | 鏍囩 | 鏇存柊鏃堕棿 |
> |------|------|----------|
> | `=link("02-UVM/00-鍏ラ棬")` | #UVM #鍏ラ棬 | `=dv.pages("02-UVM/00-鍏ラ棬").file.mtime` |
> | `=link("02-UVM/01-Phase鏈哄埗")` | #UVM #鏍稿績 | `=dv.pages("02-UVM/01-Phase鏈哄埗").file.mtime` |
> | `=link("02-UVM/02-config_db")` | #UVM #鏍稿績 | `=dv.pages("02-UVM/02-config_db").file.mtime` |
> | `=link("02-UVM/03-Sequence鏈哄埗")` | #UVM #鏍稿績 | `=dv.pages("02-UVM/03-Sequence鏈哄埗").file.mtime` |
> | `=link("02-UVM/04-缁勪欢")` | #UVM #缁勪欢 | `=dv.pages("02-UVM/04-缁勪欢").file.mtime` |
> 
> **鎬昏**: 5 绡?
> [!note]- 馃攲 **鍗忚瑙勮寖** - 鎬荤嚎鎺ュ彛
> 
> | 鍗忚 | 鏂囨。 | 鏍囩 |
> |------|------|------|
> | 鈿?AXI | `=link("03-Protocol/AXI/00-AXI")` | #Protocol #AXI |
> | 馃敆 APB | `=link("03-Protocol/APB/00-APB")` | #Protocol #APB |
> | 馃摗 I2C | `=link("03-Protocol/I2C/00-I2C")` | #Protocol #I2C |
> | 馃攧 SPI | `=link("03-Protocol/SPI/00-SPI")` | #Protocol #SPI |
> | 馃摠 UART | `=link("03-Protocol/UART/00-UART")` | #Protocol #UART |
> 
> **鎬昏**: 5 绉嶅崗璁?
> [!note]- 馃敡 **宸ュ叿閾?* - 寮€鍙戠幆澧?> 
> | 宸ュ叿 | 鏂囨。 | 璇存槑 |
> |------|------|------|
> | 馃惂 Linux | `=link("04-Tools/Linux/00-甯哥敤鍛戒护")` | 甯哥敤鍛戒护 |
> | 馃摑 GVim | `=link("04-Tools/GVim/00-蹇嵎閿?)` | 蹇嵎閿?|
> | 馃枼锔?xrun | `=link("04-Tools/xrun/00-xrun")` | Cadence 浠跨湡鍣?|
> | 馃搳 imc | `=link("04-Tools/imc/00-imc")` | 瑕嗙洊鐜囧垎鏋?|
> 
> **鎬昏**: 4 绉嶅伐鍏?
> [!note]- 鉁?**楠岃瘉鏂规硶** - 瀹炶返鎸囧崡
> 
> | 鏂囨。 | 鏍囩 | 璇存槑 |
> |------|------|------|
> | `=link("05-Verification/00-楠岃瘉璁″垝")` | #Verification #璁″垝 | 楠岃瘉璁″垝缂栧啓 |
> | `=link("05-Verification/01-瑕嗙洊鐜?)` | #Verification #Coverage | 瑕嗙洊鐜囬┍鍔ㄩ獙璇?|
> | `=link("05-Verification/02-FMEA-FuSa")` | #Verification #Safety | 鍔熻兘瀹夊叏 |
> 
> **鎬昏**: 3 绡?
> [!note]- 馃彈锔?**鐜鎼缓** - 閰嶇疆鎸囧崡
> 
> | 鏂囨。 | 鏍囩 | 璇存槑 |
> |------|------|------|
> | `=link("06-Environment/00-鐜鎼缓")` | #Environment #Setup | 瀹屾暣鐜鎼缓 |
> 
> **鎬昏**: 1 绡?
> [!note]- 馃摐 **鑴氭湰宸ュ叿** - 鑷姩鍖?> 
> | 鏂囨。 | 鏍囩 | 璇存槑 |
> |------|------|------|
> | `=link("07-Scripts/00-Makefile")` | #Script #Makefile | Makefile 缂栧啓 |
> | `=link("07-Scripts/00-Python")` | #Script #Python | Python 鑴氭湰 |
> | `=link("07-Scripts/01-Log瑙ｆ瀽")` | #Script #Log | 鏃ュ織鍒嗘瀽 |
> 
> **鎬昏**: 3 绡?
> [!note]- 馃摎 **UVM 婧愮爜** - 娣卞叆鐮旂┒
> 
> | 鏂囨。 | 鏍囩 | 璇存槑 |
> |------|------|------|
> | `=link("11-UVM婧愮爜瀛︿範/UVM婧愪唬鐮佺爺绌?)` | #UVM #婧愮爜 | 婧愮爜鐮旂┒ |
> | `=link("11-UVM婧愮爜瀛︿範/UVM-uvm涓殑factory鏈哄埗")` | #UVM #Factory | 宸ュ巶鏈哄埗 |
> | `=link("11-UVM婧愮爜瀛︿範/UVM-uvm_component涓巙vm_root")` | #UVM #Component | 缁勪欢灞傛 |
> | `=link("11-UVM婧愮爜瀛︿範/UVM-浠巖un_test娴呰皥TestBench鍚姩")` | #UVM #TestBench | 鍚姩娴佺▼ |
> 
> **鎬昏**: 4 绡?
---

## 馃搱 鏈€杩戞洿鏂?
> [!tip] 馃搮 鏈€杩?7 澶╂洿鏂?> 
> ```dataview
> TABLE
>   file.folder AS "鍒嗙被",
>   file.mtime AS "鏇存柊鏃堕棿",
>   choice(contains(file.tags, "#鏍稿績"), "猸?, "") AS "閲嶈"
> FROM ""
> WHERE file.mtime >= date(today) - dur(7 days) AND file.name != this.file.name
> SORT file.mtime DESC
> LIMIT 15
> ```

---

## 馃彿锔?鏍囩浜?
> [!abstract] 馃彿锔?甯哥敤鏍囩
> 
> | 鏍囩 | 鏁伴噺 | 璇存槑 |
> |------|------|------|
> | `#UVM` | `=length(dv.pages("#UVM"))` | UVM 鐩稿叧 |
> | `#SV` | `=length(dv.pages("#SV"))` | SystemVerilog |
> | `#Protocol` | `=length(dv.pages("#Protocol"))` | 鍗忚瑙勮寖 |
> | `#鏍稿績` | `=length(dv.pages("#鏍稿績"))` | 鏍稿績姒傚康 |
> | `#鍏ラ棬` | `=length(dv.pages("#鍏ラ棬"))` | 鍏ラ棬鏁欑▼ |
> | `#Verification` | `=length(dv.pages("#Verification"))` | 楠岃瘉鏂规硶 |
> | `#Script` | `=length(dv.pages("#Script"))` | 鑴氭湰宸ュ叿 |
> | `#Tool` | `=length(dv.pages("#Tool"))` | 宸ュ叿浣跨敤 |

---

## 鈴?寰呭姙浜嬮」

> [!todo] 馃搵 浠婃棩浠诲姟
> 
> ```tasks
> not done
> due on or before today
> short mode
> ```

> [!todo] 馃搮 鏈懆浠诲姟
> 
> ```tasks
> not done
> due on or before {{date:YYYY-MM-DD}}+7
> short mode
> ```

---

## 馃摎 瀛︿範杩涘害

> [!success] 馃幆 瀛︿範鐩爣杩借釜
> 
> | 鐩爣 | 杩涘害 | 鐘舵€?|
> |------|------|------|
> | SV 璇硶鎺屾彙 | 3/3 | 鉁?瀹屾垚 |
> | UVM 鏍稿績鏈哄埗 | 5/5 | 鉁?瀹屾垚 |
> | 鍗忚瀛︿範 | 5/5 | 鉁?瀹屾垚 |
> | 宸ュ叿鎺屾彙 | 4/4 | 鉁?瀹屾垚 |
> | 楠岃瘉鏂规硶 | 3/3 | 鉁?瀹屾垚 |
> | UVM 婧愮爜鐮旂┒ | 4/4 | 鉁?瀹屾垚 |
> | 椤圭洰瀹炴垬 | 0/3 | 鈴?杩涜涓?|
> | 闂鎬荤粨 | 0/10 | 鈴?杩涜涓?|

---

## 馃攳 蹇€熸悳绱?
> [!question] 馃攷 甯哥敤鎼滅储
> 
> | 鎼滅储鍐呭 | 鎼滅储鍛戒护 |
> |----------|----------|
> | UVM 鐩稿叧 | `tag:#UVM` |
> | SV 璇硶 | `tag:#SV` |
> | 鍗忚鏂囨。 | `tag:#Protocol` |
> | 鏍稿績姒傚康 | `tag:#鏍稿績` |
> | 鏈€杩戞洿鏂?| `file.mtime >= date(today) - dur(7 days)` |
> | 寰呭姙浠诲姟 | `tag:#todo` |

---

## 馃搳 鐭ヨ瘑鍥捐氨

> [!note] 馃暩锔?鍏崇郴鍥捐氨
> 
> 鐐瑰嚮涓嬫柟鎸夐挳鎵撳紑浜や簰寮忓叧绯诲浘璋憋細
> 
> ```button
> name 鎵撳紑鍏崇郴鍥捐氨
> action command:graph:open
> color blue
> ```

---

## 鈿欙笍 蹇嵎鎿嶄綔

> [!warning] 馃洜锔?甯哥敤鎿嶄綔
> 
> | 鎿嶄綔 | 蹇嵎閿?| 璇存槑 |
> |------|--------|------|
> | 蹇€熷垏鎹?| `Ctrl+O` | 蹇€熸墦寮€鏂囦欢 |
> | 鍛戒护闈㈡澘 | `Ctrl+P` | 鎵ц鍛戒护 |
> | 鍏ㄥ眬鎼滅储 | `Ctrl+Shift+F` | 鎼滅储鍐呭 |
> | 鎵撳紑鍥捐氨 | `Ctrl+G` | 鏌ョ湅鍏崇郴鍥捐氨 |
> | 鍒锋柊瑙嗗浘 | `Ctrl+R` | 鍒锋柊 Dataview |

---

## 馃摑 蹇€熻褰?
> [!tip] 鉁嶏笍 蹇€熷垱寤?> 
> ```button
> name 鏂板缓绗旇
> action templater-obsidian:Templater
> color green
> ```
> 
> ```button
> name 鏂板缓鏃ヨ
> action daily-notes:鎵撳紑/鍒涘缓浠婂ぉ鐨勬棩璁?> color purple
> ```
> 
> ```button
> name 鏂板缓浠诲姟
> action obsidian-tasks-plugin:鍒涘缓浠诲姟
> color orange
> ```

---

## 馃摎 鎺ㄨ崘闃呰

> [!info] 馃摉 绮鹃€夋枃绔?> 
> ```dataview
> TABLE
>   file.folder AS "鍒嗙被",
>   file.tags AS "鏍囩"
> FROM ""
> WHERE contains(file.tags, "#鏍稿績") OR contains(file.tags, "#閲嶈")
> SORT file.mtime DESC
> LIMIT 5
> ```

---

## 馃帗 瀛︿範璧勬簮

> [!abstract] 馃敆 澶栭儴璧勬簮
> 
> | 璧勬簮 | 閾炬帴 | 璇存槑 |
> |------|------|------|
> | UVM 瀹樻柟鏂囨。 | [Accellera](https://www.accellera.org/) | UVM 鏍囧噯 |
> | SystemVerilog | [IEEE 1800](https://standards.ieee.org/ieee/1800/7386/) | SV 鏍囧噯 |
> | Verification Academy | [VerificationAcademy](https://www.verificationacademy.com/) | 瀛︿範骞冲彴 |
> | ChipVerify | [ChipVerify](https://www.chipverify.com/) | 楠岃瘉鏁欑▼ |

---

*鏈€鍚庢洿鏂? `=dateformat(date(now), "yyyy-MM-dd HH:mm")`*
