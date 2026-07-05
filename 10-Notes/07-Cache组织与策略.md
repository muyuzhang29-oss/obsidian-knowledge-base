---
tags: [Architecture, Cache, MMU, VIPT, PIPT]
created: 2026-07-06
---

# Cache 组织方式与策略

> cache 控制器根据地址判断命中的依据：虚拟地址 (VA) 还是物理地址 (PA)。

CPU 发出虚拟地址 → MMU 转换成物理地址 → 读取数据。cache 可用 VA、PA 或两者组合。

## 1. VIVT（虚拟高速缓存）

Index 和 Tag 均取自虚拟地址。

```mermaid
flowchart LR
    CPU[CPU] --> VA[虚拟地址]
    VA --> CACHE[CACHE<br/>Index + Tag 都用 VA]
    CACHE -->|HIT| DATA[返回数据]
    CACHE -->|MISS| MMU[MMU 转换]
    MMU --> MEM[主存]
```

**优点**：无需地址转换即可查 cache，速度快。

**问题 1：歧义** — 相同 VA 映射不同 PA

```mermaid
flowchart LR
    T1["线程 A<br/>VA=0x1000 → PA=0xA000<br/>数据: 1234"] --> CL["Cache Line<br/>Tag=0x1000"]
    T2["线程 B<br/>VA=0x1000 → PA=0xB000<br/>数据: 5678"] --> CL
    CL --> ERR["B 命中 A 的旧数据!<br/>(歧义)"]
    style ERR fill:#f99,stroke:#c33
```

- 解决：切换时 flush cache（写回脏数据 + 无效化）

**问题 2：别名** — 不同 VA 映射相同 PA，且 index 不同

```mermaid
flowchart LR
    VA1["VA=0x2000<br/>Index=0x200"] --> CL1["Cache Line 0x200<br/>数据: 1234"]
    VA2["VA=0x4000<br/>Index=0x400"] --> CL2["Cache Line 0x400<br/>数据: 1234"]
    PA["PA=0x8000<br/>数据: 1234"] --> VA1
    PA --> VA2
    MOD["CPU 改 VA=0x2000 → 5678"] --> CL1
    READ["读 VA=0x4000"] --> CL2
    READ --> ERR["得到旧数据 1234<br/>(别名不一致)"]
    style ERR fill:#f99,stroke:#c33
```

- 解决：nocache 映射、flush cache、保证 VA 索引到相同 cache line

**结论**：VIVT 问题太多，已基本淘汰。

## 2. PIPT（物理高速缓存）

Index 和 Tag 均取自物理地址。

```mermaid
flowchart LR
    CPU[CPU] --> VA[虚拟地址]
    VA --> MMU[MMU 转换]
    MMU --> PA[物理地址]
    PA --> CACHE[CACHE<br/>Index + Tag 都用 PA]
    CACHE -->|HIT| DATA[返回数据]
    CACHE -->|MISS| MEM[主存]
    MMU --> TLB[TLB<br/>加速 VA→PA]
```

**优点**：
- Tag 唯一 → 无歧义
- Index 唯一 → 无异名
- 软件无需维护

**缺点**：
- 需等待 VA→PA 转换后才能查 cache
- 硬件复杂

**现状**：Linux 中 PIPT 管理函数全为空，无需维护。现代 CPU 普遍采用。

## 3. VIPT（物理标记的虚拟高速缓存）

Index 取自虚拟地址，Tag 取自物理地址。查 cache 与 MMU 转换**同时进行**。

```mermaid
flowchart LR
    CPU[CPU] --> VA[虚拟地址]
    VA --> PATH1["提取 Index<br/>(来自 VA)"]
    VA --> PATH2["MMU 转换<br/>(同时进行)"]
    PATH1 --> CACHE[CACHE<br/>用 VA Index 查行]
    PATH2 --> PA[物理地址]
    PA --> TAG["提取 Tag<br/>(来自 PA)"]
    CACHE --> CMP["比较 Tag"]
    TAG --> CMP
    CMP -->|匹配| HIT[HIT]
    CMP -->|不匹配| MISS[MISS → 主存]
```

**优点**：性能好（并行），无歧义（tag 是物理的）。

```mermaid
flowchart TD
    subgraph NoAlias[一路 ≤ 4KB: 无异名]
        N1["VA 和 PA 的 [11:0] 相同<br/>(页内偏移)"] --> N2["Index 取自 [11:x]<br/>不超出页边界"]
        N2 --> N3["等价于 PIPT<br/>无需额外维护"]
    end
    subgraph Alias[一路 > 4KB: 可能别名]
        A1["例: 8KB 直接映射<br/>256B line"] --> A2["Index 需要 bit12<br/>VA bit12 ≠ PA bit12"]
        A2 --> A3["相同 PA 数据<br/>加载到不同 cache line"]
    end
```

**解决别名**：
- 建立共享映射时，返回的虚拟地址按 cache size 对齐11
- 多路组相联时按一路大小对齐

## 4. 三种方式对比

```mermaid
flowchart TB
    subgraph VIVT_C[VIVT]
        V1["VA → Tag(VA) + Index(VA)"]
    end
    subgraph PIPT_C[PIPT]
        P1["VA → MMU → PA → Tag(PA) + Index(PA)"]
    end
    subgraph VIPT_C[VIPT]
        I1["VA Index → Cache<br/>VA → MMU → PA Tag → 比较"]
    end
```

| 特性         | VIVT | PIPT | VIPT         |
| ---------- | ---- | ---- | ------------ |
| Index 来源   | VA   | PA   | VA           |
| Tag 来源     | VA   | PA   | PA           |
| 歧义问题       | ❌ 有  | ✅ 无  | ✅ 无          |
| 别名问题       | ❌ 有  | ✅ 无  | ⚠️ 一路>4KB 时有 |
| 查 cache 时机 | 转换前  | 转换后  | 同时           |
| 软件维护成本     | 高    | 无    | 低            |
| 当前使用       | 淘汰   | 常见   | 常见（一路≤4KB时）  |

## 5. 补充：TLB

```mermaid
flowchart LR
    CPU[CPU] --> VA[虚拟地址]
    VA --> TLB{"TLB<br/>(VA→PA 缓存)"}
    TLB -->|HIT| PA1[物理地址 → Cache]
    TLB -->|MISS| PT[查页表<br/>慢速路径]
    PT --> PA2[物理地址]
    PT --> TLB[更新 TLB]
    style TLB fill:#6cf,stroke:#333
```

MMU 中缓存 VA→PA 映射关系的小容量 cache。加速地址转换。

---

**参见**
- [[10-Notes/06-Cache基础与映射方式]] — 映射方式与策略
