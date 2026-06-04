---
tags: [UVM, Verification, 模板, TLM, 数据流]
created: 2026-04-17
updated: 2026-06-02
---

# UVM Analysis Port 数据流机制

> driver → ref_model / monitor → scoreboard 的完整数据流解析

---

## 一、Analysis Port 回调机制

UVM 的 `uvm_analysis_port` 是**一对多广播**：一个 `ap.write(tr)` 会自动调用所有连接的 `write(tr)` 函数。

```systemverilog
// driver 侧：广播
ap.write(tr);  // tr 是 driver 的原始输入 trans

// ref_model 侧：自动被回调
function void write(spi_trans tr);  // tr 就是 driver 传过来的那个对象
    // 直接使用 tr，不需要额外传递
endfunction
```

**关键理解：** `write(spi_trans tr)` 的参数 `tr` 就是调用方 `ap.write(tr)` 传过来的对象，UVM 框架自动完成回调，不需要手动传递。

---

## 二、完整数据流架构

```
sequence
   ↓
sequencer
   ↓
driver ← get_next_item ── transaction (输入字段: cmd, addr, data[], rd_len)
   ↓            ↓
  DUT      driver.ap.write(tr)  ← 广播原始输入 trans
   ↓                ↓
monitor         ref_model.write(tr)
   ↓                ↓
monitor 采集     exp_trans.copy(tr) ← 拷贝输入字段
DUT 实际输出     compute_expected(exp_trans) ← 读输入字段，填输出字段
   ↓                ↓
rx_trans         exp_trans
(输出字段:       (输出字段:
 实际值)          期望值)
   ↓                ↓
   └──→ scoreboard ←──┘
         比对 rx_trans vs exp_trans
```

---

## 三、各组件职责

| 组件 | 输入 | 输出 | 职责 |
|------|------|------|------|
| driver | sequencer 的 trans | vif 信号 + ap 广播 | 驱动 DUT + 广播输入给 ref_model |
| monitor | vif 信号 | rx_trans（输出字段实际值） | 采集 DUT 输出 |
| ref_model | driver.ap 的 tr | exp_trans（输出字段期望值） | 读输入字段，计算期望输出 |
| scoreboard | rx_trans + exp_trans | 比对结果 | 比对实际值 vs 期望值 |

---

## 四、Transaction 字段分工

```systemverilog
class spi_trans extends uvm_sequence_item;
    // 输入字段：driver 填，ref_model 读
    rand cmd_t  cmd;
    rand bit [7:0]  addr;
    rand bit [7:0]  data[];
    rand int        data_len;
    rand bit        rd_en;
    rand int        rd_len;

    // 输出字段：monitor 填实际值，ref_model 填期望值
    bit [7:0]  status_o;
    bit [7:0]  data_o[];
    bit        error_o;
endclass
```

**同一个 transaction 类，不同组件用不同字段：**
- **driver**：填输入字段 → 驱动 DUT + 广播给 ref_model
- **ref_model**：读输入字段 → 填输出字段（期望值）
- **monitor**：填输出字段（实际值）
- **scoreboard**：只比对输出字段

---

## 五、连接关系（env connect_phase）

```systemverilog
function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // monitor 实际输出 → scoreboard
    agent.ap.connect(scb.rx_imp);

    // driver 输入激励 → ref_model
    agent.drv_ap.connect(ref_model.imp);

    // ref_model 期望输出 → scoreboard
    ref_model.exp_ap.connect(scb.exp_imp);
endfunction
```

**agent 内部连接：**
```systemverilog
function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);  // driver ↔ sequencer
    mon.ap.connect(ap);        // monitor.ap → agent.ap（对外暴露）
    drv.ap.connect(drv_ap);    // driver.ap → agent.drv_ap（对外暴露）
endfunction
```

---

## 六、为什么用 driver.ap 而不是 monitor.ap 给 ref_model

| | driver.ap → ref_model | monitor.ap → ref_model |
|---|---|---|
| 输入来源 | driver 发出的原始激励 | monitor 采集的 DUT 输入 |
| 时序 | 更早（driver 发完立即广播） | 更晚（等 monitor 采集） |
| 可靠性 | 直接，无延迟 | 需要 monitor 能看到输入信号 |
| 适用场景 | DUT 不修改输入 | DUT 可能修改输入 |

**推荐用 driver.ap：**
- driver 发完数据后直接广播，ref_model 不需要等 monitor
- monitor 只负责采集 DUT 输出，职责更清晰
- 不依赖 monitor 能否看到输入信号

---

## 相关链接

- [[02-UVM/06-TLM通信|TLM 通信机制]] - UVM TLM 通信详解
- [[05-Verification/UVM-Template/00-总览|UVM 模板总览]] - UVM 验证环境模板
- [[02-UVM/04-组件|UVM 组件]] - UVM 组件结构
- [[00-总索引]] - 返回总索引

---

*创建时间: 2026-06-01*
