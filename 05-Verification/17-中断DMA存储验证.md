---
aliases: [中断验证, DMA验证, 存储器模型, Interrupt DMA Memory]
tags: [Verification, Interrupt, DMA, Memory, 核心]
created: 2026-09-27
updated: 2026-09-27
---

# 17-中断 DMA 存储器验证

> [!abstract] 为什么单列
> 大部分 IP 验证完「数据通路」还会挂在这三类系统能力上：中断聚合、DMA 搬数、片上/外接存储。它们常是集成后 bug 高发区。

---

## 1. 中断验证

### 1.1 寄存器模型字段语义

| 字段 | access | 说明 |
|------|--------|------|
| `src_status` | W1C / RO | 中断源状态 |
| `src_enable` | RW | 单源使能 |
| `global_en` | RW | 总开关 |
| `irq_out` | 电平/脉冲 | 到 SoC 的输出 |
| `raw_status` | RO | 未 mask 的源 |

### 1.2 检查点

```text
1) 复位：irq_out = 0，status = 0
2) 单源触发 → status 置位 → irq_out 拉高（若 enable）
3) enable=0 → 只置 status，不拉 irq
4) W1C 清 status → irq 拉低（无其它 pending）
5) 多源同时 pending → 聚合正确、优先级正确
6) 电平型：status 未清则保持；脉冲型：宽度检查
7) 写 clear 与硬件置位冲突（同拍）→ 文档定义谁赢
8) 低功耗/复位时中断行为
```

### 1.3 激励骨架

```systemverilog
class irq_seq extends uvm_sequence;
  task body();
    regmodel.ctrl.write(status, 32'h0, UVM_FRONTDOOR); // 清
    inject_irq(SRC_RX_DONE);
    wait (pin_if.irq === 1'b1);
    regmodel.status.read(status, data); // 期望 bit
    regmodel.status.write(status, 32'h1, UVM_FRONTDOOR); // W1C
    wait (pin_if.irq === 1'b0);
  endtask
endclass
```

> [!bug] 坑
> - 只测 irq=1，不测 **W1C 清不掉 / 清错位**
> - 同拍 set+clear 语义与手册不一致
> - 未测「enable 关掉后硬件置位」
> - 未做 **中断丢失** 压力（连打 N 个）

---

## 2. DMA 验证

### 2.1 典型 descriptor

```text
src_addr | dst_addr | length | dir | burst | status | next
```

### 2.2 用例矩阵

| 类别 | 用例 |
|------|------|
| 基本 | src→dst 单块、反向 |
| 边界 | length=0/1/max、地址非对齐、跨页 |
| 流控 | 完成中断、half/full、ring buffer |
| 链式 | descriptor chain / scatter-gather |
| 冲突 | 与 CPU 同址、两 DMA 同slave |
| 异常 | 超时、非法地址、长度溢出、中止 |
| 性能 | outstanding、带宽、背压 |

### 2.3 数据比对

```text
RefModel：按 len/dir 生成期望 mem image
Monitor：采 DMA 描述符 + 总线 burst
Scoreboard：source mem vs dest mem byte/word diff
```

```systemverilog
function void check_xfer(int src, int dst, int len);
  for (int i = 0; i < len; i++) begin
    if (mem_src[src+i] !== mem_dst[dst+i])
      `uvm_error("DMA", $sformatf("byte %0d exp=%02h act=%02h",
                 i, mem_src[src+i], mem_dst[dst+i]))
  end
endfunction
```

---

## 3. 存储器模型

### 3.1 三类

| 类型 | 建模 | 注意 |
|------|------|------|
| 行为 mem[] | SV associative/array | 要处理 X、byte enable |
| SRAM 模型 | 厂商 behavioral | latency、power-down |
| 外部 DDR | 芯片模型/SO-DIMM | 时序、刷新 |

### 3.2 行为存储器骨架

```systemverilog
class mem_model extends uvm_component;
  byte unsigned mem [int unsigned];

  function void write(int unsigned addr, byte data, bit [3:0] be);
    if (be[0]) mem[addr] = data;
  endfunction

  function byte unsigned read(int unsigned addr);
    return mem.exists(addr) ? mem[addr] : 8'hxx;
  endfunction

  // 便于后门注入/比对
  function void load_from_file(string path);
    // $readmemh 可换成
  endfunction
endclass
```

### 3.3 检查点

- [ ] 复位后 mem 内容/使能
- [ ] byte enable 逐字节
- [ ] 读写同址冲突（同拍/上拍）
- [ ] 超出 size / 保护区间
- [ ] ECC/parity 故障注入（若有）
- [ ] 初始化镜像与后门 dump 一致

---

## 4. 联调场景（系统级）

```text
CPU 写 DMA descriptor
  → DMA 启动 → 从 mem A 搬到 mem B
  → 完成置 status → irq 线
  → 软件 W1C 清 → irq 落
  → 后门读 mem B 校验
```

> [!tip] 虚拟 sequence
> 用 [[02-UVM/13-虚拟Sequence|virtual sequence]] 串起 APB 配置 + AXI 总线流 + 中断检查。

---

## 5. 与寄存器模型联动

```systemverilog
// 中断状态寄存器建议 W1C
regmodel.irq_status.read(uvm_status, data);
regmodel.irq_status.write(uvm_status, data, UVM_FRONTDOOR); // 清位
```

参考 [[02-UVM/12-寄存器模型RAL]] 的 frontdoor/backdoor 用法。

---

## 6. 验证计划条目模板

```text
IRQ-01 复位默认值
IRQ-02 单源 pending/enable/mask
IRQ-03 多源聚合与优先级
IRQ-04 W1C 语义与同拍冲突
IRQ-05 电平 vs 脉冲
DMA-01 传输正确性（全 0/全 1/随机）
DMA-02 边界长度与地址
DMA-03 链式 SG / ring
DMA-04 异常中止
MEM-01 byte enable
MEM-02 读写冲突
MEM-03 越界保护
```

---

## 相关笔记

- [[02-UVM/12-寄存器模型RAL]]
- [[02-UVM/13-虚拟Sequence]]
- [[06-UVM-Template/06-reference_model]]
- [[06-UVM-Template/07-scoreboard]]
- [[05-Verification/07-FIFO设计与验证]]

---

*更新: 2026-09-27*
