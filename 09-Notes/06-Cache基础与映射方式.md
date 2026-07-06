---
tags: [Architecture, Cache, CPU, Memory]
created: 2026-07-06
---

# Cache 鍩虹涓庢槧灏勬柟寮?

## 1. 鍩烘湰姒傚康

| 鏈 | 璇存槑 |
|------|------|
| Cache Size | cache 鍙紦瀛樼殑鏈€澶ф暟鎹噺 |
| Cache Line Size | 鍧囧垎 cache 鐨勫潡澶у皬锛屾暟鎹紶杈撴渶灏忓崟浣?|
| Offset | 瀵诲潃 cache line 鍐呭瓧鑺?(log2 line_size) |
| Index | 瀵诲潃 cache 琛?缁?(log2 num_lines) |
| Tag | 楂樹綅鍦板潃锛屽敮涓€鏍囪瘑 cache line 瀵瑰簲鐨勪富瀛樺湴鍧€ |

**绀轰緥**锛?4 Bytes cache, line size 8 Bytes 鈫?8 琛?

```mermaid
flowchart LR
    A["鍦板潃 [47:0]"] --> B["Tag [47:6]<br/>42 bits"]
    A --> C["Index [5:3]<br/>3 bits (8 琛?"]
    A --> D["Offset [2:0]<br/>3 bits (8 Bytes)"]
    style B fill:#f96,stroke:#333
    style C fill:#6cf,stroke:#333
    style D fill:#9c6,stroke:#333
```

## 2. 鐩存帴鏄犲皠缂撳瓨

姣忎釜涓诲瓨鍦板潃鏄犲皠鍒?*鍞竴**涓€涓?cache line銆?

```mermaid
flowchart TD
    ADDR[CPU 鍦板潃] --> IDX[鎻愬彇 Index]
    IDX --> LINE[鎵惧埌瀵瑰簲 Cache Line]
    LINE --> VALID{Valid Bit?}
    VALID -->|0| MISS1[CACHE MISS<br/>浠庝富瀛樺姞杞絔
    VALID -->|1| TAG{Tag 鍖归厤?}
    TAG -->|No| MISS2[CACHE MISS<br/>鏇挎崲鏃ц]
    TAG -->|Yes| HIT[CACHE HIT<br/>杩斿洖鏁版嵁]
    MISS1 --> LOAD[鏇存柊 Cache Line<br/>Set Valid=1]
    MISS2 --> LOAD
```

**棰犵案闂**锛氬湴鍧€ 0x00銆?x40銆?x80 鏄犲皠鍒板悓涓€ cache line锛?

```mermaid
flowchart LR
    subgraph Mem[涓诲瓨鍦板潃]
        M0[0x00]
        M1[0x40]
        M2[0x80]
    end
    subgraph CL[鍚屼竴 Cache Line]
        L0["琛?0<br/>(Tag 绔炰簤)"]
    end
    M0 --> L0
    M1 --> L0
    M2 --> L0
    style L0 fill:#f99,stroke:#c33
```

渚濇璁块棶鏃舵瘡娆?miss锛岄绻侀绨搞€?

## 3. 澶氳矾缁勭浉鑱旂紦瀛?

灏?cache 鍧囧垎 n 浠斤紙n 璺級锛屾瘡璺浉鍚?index 鐨勮缁勬垚涓€涓?set銆?

**绀轰緥**锛?4 Bytes, 8 Bytes line, **2 璺?*
- 姣忚矾 32 Bytes / 8 Bytes = 4 琛? 鍏?**4 涓?set**
- offset = 3 bits, index = 2 bits, tag = 43 bits

```mermaid
flowchart TB
    subgraph Way0[Way 0 - 32 Bytes]
        W0S0["Set 0<br/>Line 0"]
        W0S1["Set 1<br/>Line 1"]
        W0S2["Set 2<br/>Line 2"]
        W0S3["Set 3<br/>Line 3"]
    end
    subgraph Way1[Way 1 - 32 Bytes]
        W1S0["Set 0<br/>Line 0"]
        W1S1["Set 1<br/>Line 1"]
        W1S2["Set 2<br/>Line 2"]
        W1S3["Set 3<br/>Line 3"]
    end
    SET[Index 鈫?閫変腑鐨?Set] --> W0S0
    SET --> W1S0
    W0S0 --> CMP[姣旇緝涓よ矾 Tag]
    W1S0 --> CMP
    CMP --> HIT[浠讳竴璺尮閰?鈫?HIT]
```

```mermaid
flowchart LR
    ADDR[Address] --> EX[Extract Index<br/>2 bits] --> SETS["閫?Set (鍏?4 缁?"]
    SETS --> CMP["瀵规瘮缁勫唴鎵€鏈?Tag<br/>(Way 0 & Way 1)"]
    CMP -->|Way 0 鍖归厤| H0[HIT - Way 0]
    CMP -->|Way 1 鍖归厤| H1[HIT - Way 1]
    CMP -->|鏃犲尮閰峾 M[CACHE MISS]
```

**浼樺娍**锛?x00 鍜?0x40 鍙悓鏃剁紦瀛樺湪涓嶅悓璺紝閬垮厤棰犵案銆?

鐩存帴鏄犲皠缂撳瓨 = 鍗曡矾缁勭浉鑱旓紙鐗逛緥锛夈€?

## 4. 鍏ㄧ浉杩炵紦瀛?

```mermaid
flowchart LR
    ADDR[Address] --> TAG["Tag (鏃?Index)"]
    TAG --> CMP["涓庢墍鏈?Cache Line Tag 骞惰姣旇緝"]
    CMP -->|浠讳竴鍖归厤| HIT[HIT]
    CMP -->|鏃犲尮閰峾 MISS[CACHE MISS]
```

鎵€鏈?cache line 鍦ㄤ竴涓粍鍐咃紝鏃?index銆備换鎰忓湴鍧€鍙瓨浜庝换鎰?cache line銆?

**浼樼偣**锛氭渶澶х▼搴﹂檷浣庨绨搞€?
**缂虹偣**锛氱‖浠舵垚鏈珮锛坱ag 姣旇緝鍣ㄥ锛夈€?

## 5. 瀹炰緥锛?2KB 4璺粍鐩歌仈

| 鍙傛暟 | 璁＄畻 | 鍊?|
|------|------|----|
| Cache Size | 鈥?| 32 KB |
| 璺暟 | 鈥?| 4 |
| 姣忚矾澶у皬 | 32KB / 4 | 8 KB |
| Line Size | 鈥?| 32 Bytes |
| 姣忕粍琛屾暟 | 鈥?| 4 (姣忚矾 1 琛? |
| 缁勬暟 | 8KB / 32B | 256 |
| Offset | log2(32) | 5 bits |
| Index | log2(256) | 8 bits |
| Tag (48-bit) | 48 - 5 - 8 | 35 bits |

```mermaid
flowchart TB
    subgraph W0[Way 0 - 8KB]
        W0S["256 琛?br/>姣忚 32 Bytes<br/>+ Tag + V"]
    end
    subgraph W1[Way 1 - 8KB]
        W1S["256 琛?br/>姣忚 32 Bytes<br/>+ Tag + V"]
    end
    subgraph W2[Way 2 - 8KB]
        W2S["256 琛?br/>姣忚 32 Bytes<br/>+ Tag + V"]
    end
    subgraph W3[Way 3 - 8KB]
        W3S["256 琛?br/>姣忚 32 Bytes<br/>+ Tag + V"]
    end
    IDX["Index (8 bits)<br/>閫?Set"] --> W0S
    IDX --> W1S
    IDX --> W2S
    IDX --> W3S
    W0S --> COMP["4 璺?Tag 鍚屾椂姣旇緝"]
    W1S --> COMP
    W2S --> COMP
    W3S --> COMP
```

## 6. 鍒嗛厤绛栫暐

| 绛栫暐 | 璇荤己澶?| 鍐欑己澶?|
|------|--------|--------|
| 璇诲垎閰?| 鍒嗛厤 cache line | 鈥?|
| 鍐欏垎閰?| 鈥?| load 鏁版嵁鍒?cache line 鍚庡啀鍐?|
| 闈炲啓鍒嗛厤 | 鈥?| 鍙洿鏂颁富瀛橈紝涓嶅垎閰?cache line |

```mermaid
flowchart LR
    subgraph ReadMiss[璇荤己澶盷
        RM[CPU 璇?br/>Cache Miss] --> RA[鍒嗛厤 Cache Line<br/>浠庝富瀛樺姞杞絔
    end
    subgraph WriteMiss[鍐欑己澶盷
        WM[CPU 鍐?br/>Cache Miss] --> WA{鍐欏垎閰?}
        WA -->|Yes| WL["Load 鏁版嵁鍒?Line<br/>鍐嶆洿鏂?]
        WA -->|No| WN[鍙洿鏂颁富瀛榏
    end
```

## 7. 鏇存柊绛栫暐

| 绛栫暐 | 鍐欏懡涓椂 | 涓诲瓨涓€鑷存€?| 鑴忔爣蹇椾綅 |
|------|---------|-----------|---------|
| 鍐欑洿閫?(WT) | 鏇存柊 cache + 涓诲瓨 | 涓€鑷?| 鏃?|
| 鍐欏洖 (WB) | 鍙洿鏂?cache | 鍙兘涓嶄竴鑷?| Dirty bit |

```mermaid
flowchart LR
    subgraph WT[Write Through]
        W1[CPU 鍐?Cache 鍛戒腑] --> W2[鏇存柊 Cache Line] --> W3[绔嬪嵆鏇存柊涓诲瓨]
    end
    subgraph WB[Write Back]
        B1[CPU 鍐?Cache 鍛戒腑] --> B2[鏇存柊 Cache Line<br/>Dirty=1] --> B3[鏇挎崲鏃舵墠鍐欏洖涓诲瓨]
        B3 --> B4[Dirty=0]
    end
```

鍐欏洖绛栫暐涓嬶紝cache line 鏇挎崲鍓嶉渶灏嗚剰鏁版嵁鍐欏洖涓诲瓨锛岃繖涔熸槸 cache line 涓轰紶杈撴渶灏忓崟浣嶇殑鍘熷洜锛堟瘡涓?line 鍏辩敤涓€涓?dirty bit锛夈€?

## 8. 瀹炰緥锛氱洿鎺ユ槧灏?+ 鍐欏洖

64 Bytes cache, 8 Bytes line, 璇诲湴鍧€ 0x2a锛?

```mermaid
flowchart TD
    S1["璇?0x2a<br/>Index 鈫?鎵捐"] --> S2{Valid?}
    S2 -->|Yes| S3{Tag 鍖归厤?}
    S3 -->|No| S4["CACHE MISS<br/>Dirty=1, 闇€鍐欏洖"]
    S4 --> S5["灏嗘棫鏁版嵁 0x11223344<br/>鍐欏洖鍘熷湴鍧€ 0x0128"]
    S5 --> S6["浠?0x28 鍔犺浇 8 Bytes<br/>鍒?Cache Line, Dirty=0"]
    S6 --> S7["Offset=0x2<br/>杩斿洖鏁版嵁缁?CPU"]
    S2 -->|No| S6
    S3 -->|Yes| S8["HIT<br/>鐩存帴杩斿洖"]
```

---

**鍙傝**
- [[09-Notes/07-Cache缁勭粐涓庣瓥鐣] 鈥?VIVT/PIPT/VIPT

