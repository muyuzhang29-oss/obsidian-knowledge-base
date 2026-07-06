---
tags: [Architecture, Cache, CPU, Memory]
created: 2026-07-06
---

# Cache 基础与映射方式

## 1. 基本概念

| 术语 | 说明 |
|------|------|
| Cache Size | cache 可缓存的最大数据量 |
| Cache Line Size | 均分 cache 的块大小，数据传输最小单位 |
| Offset | 寻址 cache line 内字节 (log2 line_size) |
| Index | 寻址 cache 行/组 (log2 num_lines) |
| Tag | 高位地址，唯一标识 cache line 对应的主存地址 |

**示例**：64 Bytes cache, line size 8 Bytes → 8 行

```mermaid
flowchart LR
    A["地址 [47:0]"] --> B["Tag [47:6]<br/>42 bits"]
    A --> C["Index [5:3]<br/>3 bits (8 行)"]
    A --> D["Offset [2:0]<br/>3 bits (8 Bytes)"]
    style B fill:#f96,stroke:#333
    style C fill:#6cf,stroke:#333
    style D fill:#9c6,stroke:#333
```

## 2. 直接映射缓存

每个主存地址映射到**唯一**一个 cache line。

```mermaid
flowchart TD
    ADDR[CPU 地址] --> IDX[提取 Index]
    IDX --> LINE[找到对应 Cache Line]
    LINE --> VALID{Valid Bit?}
    VALID -->|0| MISS1[CACHE MISS<br/>从主存加载]
    VALID -->|1| TAG{Tag 匹配?}
    TAG -->|No| MISS2[CACHE MISS<br/>替换旧行]
    TAG -->|Yes| HIT[CACHE HIT<br/>返回数据]
    MISS1 --> LOAD[更新 Cache Line<br/>Set Valid=1]
    MISS2 --> LOAD
```

**颠簸问题**：地址 0x00、0x40、0x80 映射到同一 cache line：

```mermaid
flowchart LR
    subgraph Mem[主存地址]
        M0[0x00]
        M1[0x40]
        M2[0x80]
    end
    subgraph CL[同一 Cache Line]
        L0["行 0<br/>(Tag 竞争)"]
    end
    M0 --> L0
    M1 --> L0
    M2 --> L0
    style L0 fill:#f99,stroke:#c33
```

依次访问时每次 miss，频繁颠簸。

## 3. 多路组相联缓存

将 cache 均分 n 份（n 路），每路相同 index 的行组成一个 set。

**示例**：64 Bytes, 8 Bytes line, **2 路**
- 每路 32 Bytes / 8 Bytes = 4 行, 共 **4 个 set**
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
    SET[Index → 选中的 Set] --> W0S0
    SET --> W1S0
    W0S0 --> CMP[比较两路 Tag]
    W1S0 --> CMP
    CMP --> HIT[任一路匹配 → HIT]
```

```mermaid
flowchart LR
    ADDR[Address] --> EX[Extract Index<br/>2 bits] --> SETS["选 Set (共 4 组)"]
    SETS --> CMP["对比组内所有 Tag<br/>(Way 0 & Way 1)"]
    CMP -->|Way 0 匹配| H0[HIT - Way 0]
    CMP -->|Way 1 匹配| H1[HIT - Way 1]
    CMP -->|无匹配| M[CACHE MISS]
```

**优势**：0x00 和 0x40 可同时缓存在不同路，避免颠簸。

直接映射缓存 = 单路组相联（特例）。

## 4. 全相连缓存

```mermaid
flowchart LR
    ADDR[Address] --> TAG["Tag (无 Index)"]
    TAG --> CMP["与所有 Cache Line Tag 并行比较"]
    CMP -->|任一匹配| HIT[HIT]
    CMP -->|无匹配| MISS[CACHE MISS]
```

所有 cache line 在一个组内，无 index。任意地址可存于任意 cache line。

**优点**：最大程度降低颠簸。
**缺点**：硬件成本高（tag 比较器多）。

## 5. 实例：32KB 4路组相联

| 参数 | 计算 | 值 |
|------|------|----|
| Cache Size | — | 32 KB |
| 路数 | — | 4 |
| 每路大小 | 32KB / 4 | 8 KB |
| Line Size | — | 32 Bytes |
| 每组行数 | — | 4 (每路 1 行) |
| 组数 | 8KB / 32B | 256 |
| Offset | log2(32) | 5 bits |
| Index | log2(256) | 8 bits |
| Tag (48-bit) | 48 - 5 - 8 | 35 bits |

```mermaid
flowchart TB
    subgraph W0[Way 0 - 8KB]
        W0S["256 行<br/>每行 32 Bytes<br/>+ Tag + V"]
    end
    subgraph W1[Way 1 - 8KB]
        W1S["256 行<br/>每行 32 Bytes<br/>+ Tag + V"]
    end
    subgraph W2[Way 2 - 8KB]
        W2S["256 行<br/>每行 32 Bytes<br/>+ Tag + V"]
    end
    subgraph W3[Way 3 - 8KB]
        W3S["256 行<br/>每行 32 Bytes<br/>+ Tag + V"]
    end
    IDX["Index (8 bits)<br/>选 Set"] --> W0S
    IDX --> W1S
    IDX --> W2S
    IDX --> W3S
    W0S --> COMP["4 路 Tag 同时比较"]
    W1S --> COMP
    W2S --> COMP
    W3S --> COMP
```

## 6. 分配策略

| 策略 | 读缺失 | 写缺失 |
|------|--------|--------|
| 读分配 | 分配 cache line | — |
| 写分配 | — | load 数据到 cache line 后再写 |
| 非写分配 | — | 只更新主存，不分配 cache line |

```mermaid
flowchart LR
    subgraph ReadMiss[读缺失]
        RM[CPU 读<br/>Cache Miss] --> RA[分配 Cache Line<br/>从主存加载]
    end
    subgraph WriteMiss[写缺失]
        WM[CPU 写<br/>Cache Miss] --> WA{写分配?}
        WA -->|Yes| WL["Load 数据到 Line<br/>再更新"]
        WA -->|No| WN[只更新主存]
    end
```

## 7. 更新策略

| 策略 | 写命中时 | 主存一致性 | 脏标志位 |
|------|---------|-----------|---------|
| 写直通 (WT) | 更新 cache + 主存 | 一致 | 无 |
| 写回 (WB) | 只更新 cache | 可能不一致 | Dirty bit |

```mermaid
flowchart LR
    subgraph WT[Write Through]
        W1[CPU 写 Cache 命中] --> W2[更新 Cache Line] --> W3[立即更新主存]
    end
    subgraph WB[Write Back]
        B1[CPU 写 Cache 命中] --> B2[更新 Cache Line<br/>Dirty=1] --> B3[替换时才写回主存]
        B3 --> B4[Dirty=0]
    end
```

写回策略下，cache line 替换前需将脏数据写回主存，这也是 cache line 为传输最小单位的原因（每个 line 共用一个 dirty bit）。

## 8. 实例：直接映射 + 写回

64 Bytes cache, 8 Bytes line, 读地址 0x2a：

```mermaid
flowchart TD
    S1["读 0x2a<br/>Index → 找行"] --> S2{Valid?}
    S2 -->|Yes| S3{Tag 匹配?}
    S3 -->|No| S4["CACHE MISS<br/>Dirty=1, 需写回"]
    S4 --> S5["将旧数据 0x11223344<br/>写回原地址 0x0128"]
    S5 --> S6["从 0x28 加载 8 Bytes<br/>到 Cache Line, Dirty=0"]
    S6 --> S7["Offset=0x2<br/>返回数据给 CPU"]
    S2 -->|No| S6
    S3 -->|Yes| S8["HIT<br/>直接返回"]
```

---

**参见**
- [[09-Notes/07-Cache组织与策略]] — VIVT/PIPT/VIPT
