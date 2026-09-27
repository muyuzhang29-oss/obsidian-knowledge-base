---
aliases: [AXI验证, AXI VIP, AXI checklist]
tags: [Protocol, AXI, Verification, 核心]
created: 2026-09-27
updated: 2026-09-27
---

# 02-AXI验证要点

> [!abstract] 用途
> 写 AXI master/slave VIP 或搭互联验证时的**用例矩阵 + 断言 + 覆盖**清单。
> 协议细节见 [[03-Protocol/AXI/01-AXI事务与突发]]。

---

## 1. Agent 分层

```text
axi_master_agent
├── driver     看 VALID/READY，产生 addr/data/resp 等待
├── sequencer  单 ID / 多 ID
└── monitor    解 5 通道，重组 trans → ap

axi_slave_agent
├── driver/responder  可 out-of-order、可限流
└── monitor
```

> [!tip] 驱动时机
> - Master：`AWVALID=1` 后等 `AWREADY`，**同拍允许**
> - 读数据：`RREADY` 可先拉，slave 再给 `RVALID`
> - 写：必须给够 `WLAST`，beats = AWLEN+1

---

## 2. 主用例矩阵

| # | 类别 | 用例 | 期望 |
|---|------|------|------|
| A1 | 基本 | INCR 读/写，len=1 | OKAY |
| A2 | 长度 | len=0 / max / 中间 | 数据正确 |
| A3 | 大小 | size=0..max | 对齐/非对齐 |
| A4 | 突发 | FIXED / INCR / WRAP | 地址序列正确 |
| A5 | ID | 多 ID 并发 | 同 ID 保序 |
| A6 | outstanding | 连发 N 笔 | 无丢/错序 |
| A7 | 背压 | READY 随机拉低 | 不丢拍 |
| A8 | 响应 | SLVERR / DECERR | 上报、恢复 |
| A9 | exclusive | 读改写 | EXOKAY/OKAY |
| A10 | 4KB | 贴边、跨 4KB 应禁止 | 预期 error |
| A11 | 复位 | 传输中复位 | 通道 idle、再启动 |
| A12 | 乱序 | slave 不同 ID 换序 | 重组正确 |

---

## 3. 约束示例

```systemverilog
constraint c_size {
  size <= 3'd3;              // ≤8B 便于仿真
  (1 << size) <= 4 * (len+1) // 不超过 burst 字节上限
}
constraint c_align {
  soft addr % (1<<size) == 0;
}
constraint c_burst {
  burst != 2'b11;
  burst == WRAP -> (len+1) inside {2,4,8,16};
}
constraint c_4k {
  // 不跨 4KB
  ((addr % 4096) + (len+1)*(1<<size)) <= 4096;
}
```

---

## 4. Monitor 重组要点

```text
1) AW 与 W 通过 ID / 顺序配对（AXI4 W 顺序跟 AW）
2) 统计 beats，比对 WLAST 位置
3) 收满 B 才完成 write trans
4) 读：AR → 收 R 直到 RLAST，打 RRESP
5) 超时：等待 B/R 过 N 拍报 error
```

```systemverilog
// WLAST 检查
if (w_cnt != exp_beats) `uvm_error("WLAST", ...)
if (w_last !== (w_cnt == exp_beats)) `uvm_error("WLAST_POS", ...)
```

---

## 5. SVA 断言建议

```systemverilog
// VALID 不可撤回
property p_stable_valid;
  @(posedge clk) disable iff (!rst_n)
  (valid && !ready) |=> valid && $stable(payload);
endproperty
a_stable: assert property (p_stable_valid);

// 突发不跨 4KB
a_4k: assert property (@(posedge clk) aw_valid |-> no_cross_4k(aw_addr, aw_len, aw_size));

// 同 ID 写响应顺序
a_bid: assert property (...);

// RLAST 计数
a_rlast: assert property (@(posedge clk) r_valid && r_last |-> r_beat_cnt == ar_len+1);
```

| 断言 | 防什么 |
|------|--------|
| VALID 稳定 | 违规撤回 |
| 4KB | 地址撕裂 |
| WLAST 位置 | 少/多 beat |
| 同 ID 保序 | VIP/互联 bug |
| READY 饥饿 | 合理 timeout |
| PROT/LOCK 合法 | 配置错 |

---

## 6. 功能覆盖

```systemverilog
covergroup cg_axi_wr @(posedge clk);
  cp_size  : coverpoint wr.size;
  cp_len   : coverpoint wr.len { bins short={0,1}; bins mid={[2:8]}; bins long={[9:255]}; }
  cp_burst : coverpoint wr.burst;
  cp_resp  : coverpoint b.resp;
  cp_id    : coverpoint wr.id;
  x_size_burst : cross cp_size, cp_burst;
  x_id_resp    : cross cp_id, cp_resp;
endgroup
```

必打 coverpoint：

- size × burst
- 非对齐地址
- FIXED/WRAP 边界
- resp 四种
- 多 ID 同时 outstanding
- exclusive 失败/成功
- 复位打断

---

## 7. Slave 行为模型

| 策略 | 配置 |
|------|------|
| 时钟对齐延迟 | 固定 0..N |
| 随机背压 | READY 概率 |
| 随机错误 | BRESP/RRESP 注入 |
| out-of-order | 不同 ID 乱序 |
| 有限 outstanding | 最大在途 |

```systemverilog
// 随机 SLVERR
if ($urandom_range(0,99) < err_pct)
  bresp = 2'b10;
```

---

## 8. 性能检查（可选）

- **outstanding 深度**：无空泡时吞吐
- **写聚合**：back-to-back AW/W
- **读延迟**：AR→第一拍 R
- **背压恢复**：READY 抖动后带宽恢复

---

## 9. 回归 checklist

- [ ] 全 size / 全 burst
- [ ] len=0/max
- [ ] 非对齐 + 4KB 拒绝
- [ ] 多 ID 保序
- [ ] 错误响应恢复
- [ ] 复位中传输
- [ ] exclusive
- [ ] 断言 0 fail
- [ ] 代码覆盖：接口 toggle 100%

---

## 相关

- [[03-Protocol/AXI/00-AXI]]
- [[03-Protocol/AXI/01-AXI事务与突发]]
- [[02-UVM/13-虚拟Sequence]]
- [[05-Verification/15-代码覆盖率目标与收敛]]

---

*更新: 2026-09-27*
