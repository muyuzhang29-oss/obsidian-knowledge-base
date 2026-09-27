---
aliases: [RAL, 寄存器模型, uvm_reg, Register Model]
tags: [UVM, RAL, 寄存器, 核心, Verification]
created: 2026-09-27
updated: 2026-09-27
---

# 12-寄存器模型 RAL

> [!abstract] 为什么需要 RAL
> SoC/IP 的可编程寄存器动辄上百个：复位值、读写属性、字段、地址图都要测。
> UVM Register Abstraction Layer（RAL）把寄存器描述与访问路径解耦——同一套用例既能走**总线前端**（frontdoor），也能**直接打到 RTL 层次**（backdoor），并自动做镜像值对比。

---

## 1. 核心概念

```text
uvm_reg_block
├── uvm_reg          单个寄存器
│   ├── uvm_reg_field  字段（access / reset / width）
│   └── ...
├── uvm_mem          存储器
└── 子 block        地址图嵌套

uvm_reg_map           地址映射（base + offset）
uvm_reg_predictor      把总线事务写回镜像
uvm_reg_adapter        总线事务 ↔ reg 适配
```

> [!tip] 三个值必须分清
>
> | 名称 | 含义 |
> |------|------|
> | **desired** | 软件想要的值（`set()`） |
> | **mirrored** | 镜像认为 DUT 当前值 |
> | **actual** | DUT 真实值（后门读到的） |

---

## 2. 字段访问属性

| access | 含义 | 典型场景 |
|--------|------|----------|
| `RW` | 读写 | 普通配置 |
| `RO` | 只读 | 状态、ID |
| `WO` | 只写 | FIFO 数据口 |
| `W1C` | 写 1 清零 | 中断状态 |
| `W1S` / `W1T` | 写 1 置位 / 翻转 | 软件触发 |
| `RC` / `RS` | 读清零 / 读置位 | 队列状态 |
| `WC` / `WS` | 写清零 / 写置位 | — |
| `W0C` / `W0S` | 写 0 清零 / 置位 | — |
| `W0CRS` 等 | 组合行为 | 芯片手册常见 |

```systemverilog
class ctrl_reg extends uvm_reg;
  `uvm_object_utils(ctrl_reg)

  rand uvm_reg_field enable;
  rand uvm_reg_field mode;
  uvm_reg_field       status; // RO

  virtual function void build();
    enable = uvm_reg_field::type_id::create("enable");
    enable.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 1);
    mode = uvm_reg_field::type_id::create("mode");
    mode.configure(this, 3, 1, "RW", 0, 3'h0, 1, 1, 1);
    status = uvm_reg_field::type_id::create("status");
    status.configure(this, 1, 4, "RO", 1, 1'b0, 1, 1, 1);
  endfunction
endclass
```

---

## 3. 前门 vs 后门

> [!info] Frontdoor（默认）
> 通过 driver/driver→总线发起真实读写，检查协议与地址译码。

```systemverilog
// 写后读，检查镜像
reg.write(status, 32'h0000_0001, .status(uvm_status_e'()));
reg.read (status, data, .status(uvm_status_e'()));
```

> [!warning] Backdoor
> 用 `uvm_hdl_deposit` / `uvm_hdl_read` 直读 RTL 路径，**快、但不测协议**。
> 需要 `set_hdl_path_root()` 或 `add_hdl_path()`。

```systemverilog
blk.reg_block.set_hdl_path_root("tb.dut.u_regs");
reg.write(status, 32'hFFFF_FFFF, UVM_BACKDOOR, map);
reg.read (status, data, UVM_BACKDOOR, map);
```

| 对比 | Frontdoor | Backdoor |
|------|-----------|----------|
| 速度 | 慢 | 极快 |
| 测协议 | 是 | 否 |
| 地址译码 | 是 | 否 |
| 典型用途 | 功能/协议 | 灌初值、对镜像、翻覆盖率 |

---

## 4. 适配器与 Predictor

```systemverilog
class spi_reg_adapter extends uvm_reg_adapter;
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    spi_trans tr = spi_trans::type_id::create("tr");
    tr.dir = (rw.kind == UVM_READ) ? SPI_READ : SPI_WRITE;
    tr.addr = rw.addr;
    tr.data = rw.data;
    return tr;
  endfunction

  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    spi_trans tr;
    if (!$cast(tr, bus_item)) `uvm_fatal("CAST", "adapter type mismatch")
    rw.kind = (tr.dir == SPI_READ) ? UVM_READ : UVM_WRITE;
    rw.addr = tr.addr;
    rw.data = tr.data;
    rw.status = UVM_IS_OK;
  endfunction
endclass
```

```systemverilog
// 在 env 中挂接
reg_agent.ap.connect(predictor.bus_in);
predictor.map     = map;
predictor.adapter = adapter;
map.set_sequencer(reg_agent.sqr, adapter);
```

---

## 5. 内建寄存器测试序列

```systemverilog
// 标准套件：不必自己写底
uvm_reg_hw_reset_seq      // 复位值
uvm_reg_bit_bash_seq      // 字段可写性
uvm_reg_access_seq        // 前后门一致性
uvm_mem_walk_seq          // 存储器 walk
```

```systemverilog
class ral_test extends base_test;
  virtual task run_phase(uvm_phase phase);
    uvm_reg_hw_reset_seq seq = uvm_reg_hw_reset_seq::type_id::create("seq");
    phase.raise_objection(this);
    seq.model = env.regmodel;
    seq.start(null);
    phase.drop_objection(this);
  endtask
endclass
```

> [!tip] bit_bash 与 W1C
> `uvm_reg_bit_bash_seq` 对 W1C/RO 字段行为与手册不一致时，需要**锁定字段**或改用自定义序列，不要硬跑。

---

## 6. 预测与镜像一致性

1. 写寄存器 → predictor 根据总线事务更新 **mirrored**
2. DUT 内部状态变化（硬件更新）→ 需要 **passive predictor / explicit predict**
3. 比对策略：
   - `reg.read() > get_mirrored_value()` 自动比对
   - 或 `reg.predict(desired)`
   - 后门读 **actual** 与 mirrored  diff，用于测后门路径

> [!bug] 常见坑
> - adapter `bus2reg` 的 `rw.status` 未置 OK，sequence 会一直报错
> - map base address 与 RTL 实际译码不一致
> - 后门路径写错层次名（综合后易变）
> - 只测写读值、不测 **access 属性**（RO/W1C）

---

## 7. 与验证计划的对应

| 检查项 | 覆盖方式 |
|--------|----------|
| 复位值 | `uvm_reg_hw_reset_seq` |
| 字段读写 | `uvm_reg_bit_bash_seq` |
| 字段功能语义 | 业务 sequence + 功能覆盖率 |
| 地址译码 | frontdoor 遍历 map |
| 后门可达 | `uvm_reg_access_seq` |
| 软硬件共享字段 | 前门写 + 后门读/硬件写后前门读 |

---

## 相关笔记

- [[02-UVM/02-config_db]]
- [[02-UVM/06-TLM通信]]
- [[06-UVM-Template/07-scoreboard]]
- [[05-Verification/16-参考模型与Scoreboard]]

---

*更新: 2026-09-27*
