---
tags:
  - uvm
  - testbench
  - verification
date: {{date}}
---

# 🧪 {{title}} - UVM Testbench

> [!info]- 📋 Testbench 信息
> | 属性 | 值 | 属性 | 值 |
> |------|-----|------|-----|
> | **Testbench 名** | `{{title}}` | **创建日期** | {{date}} |
> | **DUT** | | **作者** | muyuEDA |
> | **验证目标** | | **状态** | |

---

## 📐 架构概览

> [!abstract]- 🏗️ 系统架构
> ```
> ┌─────────────────────────────────────────────────────────┐
> │                      Testbench Top                       │
> │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐   │
> │  │  Test    │  │  Env    │  │  Agent  │  │  Scorebd│   │
> │  └────┬─────┘  └────┬────┘  └────┬────┘  └────┬────┘   │
> │       │             │            │             │         │
> │  ┌────▼─────────────▼────────────▼─────────────▼────┐   │
> │  │                  Interface                        │   │
> │  └──────────────────────────────────────────────────┘   │
> │                         │                                │
> │  ┌──────────────────────▼───────────────────────────┐   │
> │  │                    DUT                            │   │
> │  └──────────────────────────────────────────────────┘   │
> └─────────────────────────────────────────────────────────┘
> ```

---

## 📦 组件清单

> [!note]- 🧩 UVM 组件
> | 组件 | 类型 | 类名 | 说明 |
> |------|------|------|------|
> | **Environment** | uvm_env | `{{title}}_env` | 环境类，包含所有组件 |
> | **Agent** | uvm_agent | `{{title}}_agent` | 代理类，封装 driver/monitor |
> | **Driver** | uvm_driver | `{{title}}_driver` | 驱动类，驱动 DUT 信号 |
> | **Monitor** | uvm_monitor | `{{title}}_monitor` | 监控类，监控 DUT 信号 |
> | **Scoreboard** | uvm_scoreboard | `{{title}}_scoreboard` | 记分板，验证结果 |
> | **Sequence** | uvm_sequence | `{{title}}_sequence` | 序列类，生成激励 |

---

## 📝 组件代码

> [!code]- 💻 Environment 类
> ```systemverilog
> // {{title}}_env.sv
> // UVM Environment 类
> // 功能: 集成所有验证组件
>
> class {{title}}_env extends uvm_env;
>   `uvm_component_utils({{title}}_env)
>
>   // 组件句柄
>   {{title}}_agent      agent;
>   {{title}}_scoreboard sb;
>
>   // 构造函数
>   function new(string name = "{{title}}_env", uvm_component parent = null);
>     super.new(name, parent);
>   endfunction
>
>   // 构建阶段
>   virtual function void build_phase(uvm_phase phase);
>     super.build_phase(phase);
>     // 创建组件
>     agent = {{title}}_agent::type_id::create("agent", this);
>     sb = {{title}}_scoreboard::type_id::create("sb", this);
>   endfunction
>
>   // 连接阶段
>   virtual function void connect_phase(uvm_phase phase);
>     super.connect_phase(phase);
>     // 连接 monitor 到 scoreboard
>     agent.monitor.item_collected_port.connect(sb.item_export);
>   endfunction
>
> endclass
> ```

> [!code]- 💻 Agent 类
> ```systemverilog
> // {{title}}_agent.sv
> // UVM Agent 类
> // 功能: 封装 driver 和 monitor
>
> class {{title}}_agent extends uvm_agent;
>   `uvm_component_utils({{title}}_agent)
>
>   // 组件句柄
>   {{title}}_driver  driver;
>   {{title}}_monitor monitor;
>   uvm_sequencer#({{title}}_transaction) sequencer;
>
>   // 构造函数
>   function new(string name = "{{title}}_agent", uvm_component parent = null);
>     super.new(name, parent);
>   endfunction
>
>   // 构建阶段
>   virtual function void build_phase(uvm_phase phase);
>     super.build_phase(phase);
>     if (get_is_active() == UVM_ACTIVE) begin
>       driver = {{title}}_driver::type_id::create("driver", this);
>       sequencer = uvm_sequencer#({{title}}_transaction)::type_id::create("sequencer", this);
>     end
>     monitor = {{title}}_monitor::type_id::create("monitor", this);
>   endfunction
>
>   // 连接阶段
>   virtual function void connect_phase(uvm_phase phase);
>     super.connect_phase(phase);
>     if (get_is_active() == UVM_ACTIVE) begin
>       driver.seq_item_port.connect(sequencer.seq_item_export);
>     end
>   endfunction
>
> endclass
> ```

> [!code]- 💻 Driver 类
> ```systemverilog
> // {{title}}_driver.sv
> // UVM Driver 类
> // 功能: 驱动 DUT 信号
>
> class {{title}}_driver extends uvm_driver#({{title}}_transaction);
>   `uvm_component_utils({{title}}_driver)
>
>   // 虚接口句柄
>   virtual {{title}}_if vif;
>
>   // 构造函数
>   function new(string name = "{{title}}_driver", uvm_component parent = null);
>     super.new(name, parent);
>   endfunction
>
>   // 构建阶段
>   virtual function void build_phase(uvm_phase phase);
>     super.build_phase(phase);
>     // 获取虚接口
>     if (!uvm_config_db#(virtual {{title}}_if)::get(this, "", "vif", vif)) begin
>       `uvm_fatal("NOVIF", "Virtual interface not defined")
>     end
>   endfunction
>
>   // 运行阶段
>   virtual task run_phase(uvm_phase phase);
>     forever begin
>       seq_item_port.get_next_item(req);
>       drive_item(req);
>       seq_item_port.item_done();
>     end
>   endtask
>
>   // 驱动事务
>   virtual task drive_item({{title}}_transaction tr);
>     // TODO: 实现驱动逻辑
>   endtask
>
> endclass
> ```

---

## 🧪 测试用例

> [!example]- 📋 测试列表
> | 测试名 | 描述 | 类型 | 状态 |
> |--------|------|------|------|
> | `{{title}}_basic_test` | 基本功能测试 | 功能 | ⬜ 待运行 |
> | `{{title}}_random_test` | 随机测试 | 随机 | ⬜ 待运行 |
> | `{{title}}_corner_test` | 边界条件测试 | 边界 | ⬜ 待运行 |
> | `{{title}}_error_test` | 异常处理测试 | 异常 | ⬜ 待运行 |

> [!code]- 💻 基本测试类
> ```systemverilog
> // {{title}}_basic_test.sv
> // 基本功能测试
>
> class {{title}}_basic_test extends uvm_test;
>   `uvm_component_utils({{title}}_basic_test)
>
>   {{title}}_env env;
>
>   function new(string name = "{{title}}_basic_test", uvm_component parent = null);
>     super.new(name, parent);
>   endfunction
>
>   virtual function void build_phase(uvm_phase phase);
>     super.build_phase(phase);
>     env = {{title}}_env::type_id::create("env", this);
>   endfunction
>
>   virtual task run_phase(uvm_phase phase);
>     {{title}}_basic_sequence seq;
>     phase.raise_objection(this);
>
>     seq = {{title}}_basic_sequence::type_id::create("seq");
>     seq.start(env.agent.sequencer);
>
>     phase.drop_objection(this);
>   endtask
>
> endclass
> ```

---

## 🔧 仿真命令

> [!tip]- 💻 运行仿真
> ```bash
> # 进入项目目录
> cd /home/muyuEDA/<项目目录>
>
> # 编译并运行仿真
> xrun \
>   +incdir+./sv \
>   +incdir+./tb \
>   -uvm \
>   -access +r \
>   -gui \
>   -sv_seed random \
>   {{title}}_top.sv
> ```

> [!tip]- 💻 运行特定测试
> ```bash
> # 运行基本测试
> xrun {{title}}_top.sv -uvm -access +r +UVM_TESTNAME={{title}}_basic_test -exit
>
> # 运行随机测试
> xrun {{title}}_top.sv -uvm -access +r +UVM_TESTNAME={{title}}_random_test -sv_seed random -exit
> ```

---

## 📂 文件结构

> [!abstract]- 📁 项目结构
> ```
> 📁 {{title}}/
> ├── 📁 sv/                    ← SV 源文件
> │   ├── {{title}}_pkg.sv      ← 包定义
> │   ├── {{title}}_if.sv       ← 接口定义
> │   └── {{title}}_top.sv      ← 顶层模块
> ├── 📁 tb/                    ← Testbench 文件
> │   ├── {{title}}_env.sv      ← 环境类
> │   ├── {{title}}_agent.sv    ← 代理类
> │   ├── {{title}}_driver.sv   ← 驱动类
> │   ├── {{title}}_monitor.sv  ← 监控类
> │   ├── {{title}}_sb.sv       ← 记分板
> │   └── {{title}}_seq.sv      ← 序列类
> ├── 📁 tests/                 ← 测试用例
> │   └── {{title}}_test.sv     ← 测试类
> └── 📁 waveforms/             ← 波形文件
> ```

---

## 📊 覆盖率目标

> [!summary]- 📈 覆盖率指标
> | 覆盖类型 | 目标 | 实际 | 状态 |
> |----------|------|------|------|
> | 代码覆盖率 | 95% | | ⬜ |
> | 功能覆盖率 | 90% | | ⬜ |
> | 断言覆盖率 | 85% | | ⬜ |

---

## 📚 参考资料

> [!reference]- 📖 学习资源
> - [[UVM架构]]
> - [[UVM组件]]
> - [[Sequence机制]]
> - [[UVM最佳实践]]

---

> [!note]- 📝 使用说明
> **模板使用指南：**
> 1. 填写 Testbench 基本信息
> 2. 根据架构图实现各组件
> 3. 参考代码模板创建组件
> 4. 编写测试用例
> 5. 运行仿真并收集覆盖率
>
> **UVM 组件层次：**
> - Test → Environment → Agent → Driver/Monitor
> - Sequence → Sequencer → Driver
> - Monitor → Scoreboard
>
> **常用命令：**
> - `+UVM_TESTNAME=<test>` 指定测试
> - `+UVM_VERBOSITY=UVM_HIGH` 设置详细级别
> - `-sv_seed random` 随机种子

---

*最后更新：{{date}}*
