---
tags: [Verification, Clock, Gating, PLL, CTS, STA]
created: 2026-07-06
---

# 时钟门控、PLL 与物理级时钟验证

> SoC 时钟验证中除 CDC 外的三大硬件验证专题：时钟门控/切换、PLL 时钟发生器、CTS 物理验证。

## 1. 时钟门控验证

### 1.1 基本原理

时钟门控是最常用的低功耗技术：模块不工作时关闭时钟，减少动态功耗。典型集成时钟门控单元（ICG）在时钟低电平采样使能信号，上升沿输出稳定门控时钟。

### 1.2 验证要点

- 使能信号需在时钟低电平期间变化，否则输出毛刺
- AND 类型门控的使能翻转必须在低电平进行
- 门控可能导致数据在非预期时点被锁存

### 1.3 验证方法

- **功能仿真**：遍历各工作场景下的门控行为
- **形式验证**：全面证明门控逻辑正确性
- **断言检查**：编写 SVA 检查门控时序要求

## 2. 时钟切换验证

### 2.1 应用场景

功耗敏感 SoC 需要动态切换时钟频率或时钟源，如负载变化时在不同 PLL 输出间切换。

### 2.2 验证要点

- **毛刺检测**：切换过程必须无毛刺
- **切换顺序**：ICG enable 置 0 → 切换选择 → 拉高 enable
- 时钟寄存器配置正确 ≠ 切换正确
- 使用断言模块实测时钟频率并与预期对比

## 3. PLL 与时钟发生器验证

### 3.1 验证维度

| 维度 | 内容 |
|------|------|
| 频率测试 | 输出频率符合规格 |
| 抖动测量 | 相位噪声与抖动特性 |
| 内置自测试 | 芯片级 PLL 测试能力 |
| 功能测试 | 各种工作模式行为正确性 |
| DFT | 可观测性与可控性 |

### 3.2 关键参数

- **抖动**：直接影响时序裕量与系统稳定性，PLL 各子块贡献不同
- **偏斜**：时钟到达不同终点的时间差异，PLL/DLL 去抖方法影响不同
- **占空比**：输入 40-60%，外部输出 45-55%，SCL 抖动直接影响占空比失真

## 4. 时钟树综合物理验证

### 4.1 CTS 流程

插入缓冲器/反相器构建时钟树 → 优化时钟树及时序 → 时钟树绕线 → 手动调节 → 查看报告

### 4.2 物理级验证

- 时钟树布线 DRC（最小宽度、间距）
- LVS/DRC/ERC 版图一致性
- 工具命令：`verify_clock_tree_physical`，RedHawk 功耗分析

### 4.3 分析指标

- 时钟偏斜（skew）
- 插入延迟（insertion delay）
- 噪声与功耗
- 时序裕量

## 5. 时钟监控模块

### 5.1 核心功能

- 监测上升沿/下降沿周期、相位持续时间
- 测量占空比、频率、频率切换
- 检测时钟丢失、频率偏差
- 生成事件/警报

### 5.2 实现方式

时间戳捕获 → 相位持续时间计算 → 事件生成

推荐用 SystemVerilog/UVM 实现模块化、可重用的监控器。

## 6. 多核多架构挑战

7nm 及以下节点面临：
- 轨到轨故障、占空比失真
- 转换速率下降、电源噪声
- 传统 STA 精度不足

**解决方案**：网格/脊柱时钟架构、GALS 设计风格、ClockEdge 高精度分析工具。

---

**参见**
- [[05-Verification/03-CDC验证]] — 跨时钟域验证
- [[05-Verification/06-时序分析基础]] — STA 时序分析
- [[05-Verification/09-低功耗与多域验证]] — UPF 与 MDV
- [[05-Verification/10-功能安全与高级验证方法]] — ISO 26262 与 ML

**参考来源**
- [Efficient Clock Monitoring System for SoC Clock Verification](https://dvcon-proceedings.org/wp-content/uploads/efficient-clock-monitoring-system-for-soc-clock-verification.pdf)
- [Clock Monitors in SoC Verification - eInfochips](https://www.einfochips.com/wp-content/uploads/resources/Clock-monitors-in-SoC-Verification.pdf)
- [Verifying Dynamic Clock Switching in Power-Critical SoCs](https://www.design-reuse.com/article/61243-verifying-dynamic-clock-switching-in-power-critical-socs/)
- [Multi-Domain Verification: When Clock, Power and Reset Domains Collide](https://dvcon-proceedings.org/wp-content/uploads/multi-domain-verification-when-clock-power-and-reset-domains-collide.pdf)
