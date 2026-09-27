---
aliases: [虚拟Sequence, Virtual Sequence, 多agent协同, virtual sequencer]
tags: [UVM, Sequence, 多Agent, 核心, Verification]
created: 2026-09-27
updated: 2026-09-27
---

# 13-虚拟Sequence与多Agent协同

> [!abstract] 解决什么问题
> 单 agent 的 `sequence` 只能在本 sequencer 上发激励。
> **跨接口协同**（例如「先配 APB，再从 AXI 写、SPI 读」）必须用 **virtual sequence** 站在环境顶层编排，否则时间关系只能靠全局事件硬凑。

---

## 1. 两类 Sequence

| 类型 | 挂在 | 作用域 |
|------|------|--------|
| 普通 sequence | 单个 sequencer | 驱动一种接口 |
| **virtual sequence** | **virtual sequencer**（或不挂） | 协调多个 sequencer |

```text
                 v_seq (virtual)
                /    |     \
          apb_seq  axi_seq  spi_seq
              |       |       |
           apb_sqr  axi_sqr  spi_sqr
```

---

## 2. Virtual Sequencer

```systemverilog
class vsqr extends uvm_sequencer;
  `uvm_component_utils(vsqr)

  apb_sequencer apb_sqr;
  axi_sequencer axi_sqr;
  spi_sequencer spi_sqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass
```

在 `env` 中 **end_of_elaboration** 或 build 后连接句柄：

```systemverilog
function void connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  vsqr.apb_sqr = apb_agent.sqr;
  vsqr.axi_sqr = axi_agent.sqr;
  vsqr.spi_sqr = spi_agent.sqr;
endfunction
```

---

## 3. Virtual Sequence 写法

```systemverilog
class v_spi_dma_seq extends uvm_sequence;
  `uvm_object_utils(v_spi_dma_seq)
  `uvm_declare_p_sequencer(vsqr)

  task body();
    apb_cfg_seq   cfg  = apb_cfg_seq::type_id::create("cfg");
    axi_wr_seq    wr   = axi_wr_seq::type_id::create("wr");
    spi_check_seq chk  = spi_check_seq::type_id::create("chk");

    // 串行编排
    cfg.start(p_sequencer.apb_sqr);
    wr.start(p_sequencer.axi_sqr);

    // 并行：fork-join
    fork
      wr.start(p_sequencer.axi_sqr);
      chk.start(p_sequencer.spi_sqr);
    join
  endtask
endclass
```

> [!tip] 启动
> virtual sequence 通常从 **test** 用 `start(null)` 或 `start(vsqr)` 启动；
> 内部子 seq 必须 `start(具体 sqr)`，不能 `start(null)`。

---

## 4. 时间关系控制

### 4.1 `fork-join` / `join_any` / `join_none`

```systemverilog
fork
  host_write_seq.start(p_sequencer.host_sqr);
  device_resp_seq.start(p_sequencer.dev_sqr);
join_any
disable fork; // 等价于 join_any 后取消另一路
```

### 4.2 事件 / mailbox 同步

```systemverilog
uvm_event start_mem_seq;

// seq A 中触发
start_mem_seq.trigger();

// seq B 中等待
start_mem_seq.wait_trigger();
mem_seq.start(p_sequencer.mem_sqr);
```

### 4.3 barrier（推荐）

```systemverilog
uvm_barrier sync_bar = new("sync_bar", 2); // 2 个参与者
sync_bar.wait_for(); // 两边都到齐才继续
```

---

## 5. 常见协同模式

| 模式 | 描述 | 用例 |
|------|------|------|
| 配置-发流 | 先配寄存器再灌数据 | 外设使能后 DMA |
| 主从并发 | Master 发、Slave 响应 | AXI out-of-order |
| 错误注入 | 一路正常、一路插错 | 协议异常 |
| 流控/背压 | 一侧持续发、一侧限速 | FIFO 水位 |
| 多主仲裁 | 两 Master 抢总线 | 优先级/公平性 |

---

## 6. 与 config_db / factory 配合

```systemverilog
// 虚拟 seq 通过 factory 覆盖子 seq
class v_err_seq extends v_normal_seq;
  virtual task body();
    // 覆盖为错误版本
    set_type_override_by_type(axi_wr_seq::get_type(), axi_err_wr_seq::get_type());
    super.body();
  endtask
endclass
```

> [!warning] 易错点
> - 忘了连 `vsqr.xxx_sqr` → 空指针
> - 子 seq 在 virtual seq 里 `start(null)` → 无 sequencer
> - objection 只在 test 加，virtual seq 不要加（避免过早 drop）
> - 并行 seq 对同一 monitor/scoreboard 写共享状态要加 semaphore

---

## 7. 验证计划勾选

- [ ] 跨接口时序用例（配置→读写）
- [ ] 并发用例（带 barrier 齐步）
- [ ] 一路异常、一路正常
- [ ] 多 master 仲裁公平性
- [ ] 断线/复位中止并发 seq

---

## 相关笔记

- [[02-UVM/03-Sequence机制]]
- [[02-UVM/05-Transaction随机与cfg联动]]
- [[06-UVM-Template/03-sequence]]
- [[02-UVM/12-寄存器模型RAL]]

---

*更新: 2026-09-27*
