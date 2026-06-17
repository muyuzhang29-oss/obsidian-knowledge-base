---
tags: [UVM, Verification, 模板, Transaction]
created: 2026-04-17
updated: 2026-06-02
---

# 02 - Transaction 事务类

> UVM 验证环境的数据模型，drv/mon/ref_model 共用

**设计思路：**
- 输入字段：driver 填，驱动到 DUT
- 输出字段：monitor 填实际值，ref_model 填期望值
- scoreboard 比对两个 transaction 的输出字段

```verilog
`ifndef SPI_TRANS_SV
`define SPI_TRANS_SV

class spi_trans extends uvm_sequence_item;

    `uvm_object_utils(spi_trans)

    // =========================================================================
    // 输入字段（driver → DUT）
    // =========================================================================

    typedef enum bit [1:0] {
        WR_CMD      = 2'b01,
        RD_CMD      = 2'b10,
        RD_DATA_CMD = 2'b11
    } cmd_e;

    rand cmd_e      cmd;           // 命令类型
    rand bit [7:0]  addr;          // 目标地址
    rand bit [7:0]  data[];        // 写数据
    rand int        data_len;      // 数据长度
    rand bit        rd_en;         // 是否读数据
    rand int        rd_len;        // 读数据长度

    // =========================================================================
    // 输出字段（monitor/ref_model 填）
    // =========================================================================

    bit [7:0]       status_o;      // 状态码
    bit [7:0]       data_o[];      // 返回数据
    bit             error_o;       // 错误标志

    // =========================================================================
    // 协议控制字段（可选）
    // =========================================================================

    rand int        spi_mode;
    rand bit        cs_active_pol;
    rand int        dummy_cycles;

    // =========================================================================
    // 错误注入字段（可选）
    // =========================================================================

    rand bit        inject_crc_err;
    rand bit        inject_timeout;
    rand bit        inject_invalid_cmd;

    // =========================================================================
    // 构造函数
    // =========================================================================

    function new(string name = "spi_trans");
        super.new(name);
        data_o = '{};
    endfunction

    // =========================================================================
    // 约束
    // =========================================================================

    constraint c_data_len {
        data_len inside {[1:256]};
        data.size() == data_len;
    }

    constraint c_rd_len {
        rd_len inside {[0:64]};
    }

    constraint c_addr {
        addr inside {[0:255]};
    }

    // =========================================================================
    // 比较方法（scoreboard 用）
    // =========================================================================

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        spi_trans rhs_trans;
        if (!$cast(rhs_trans, rhs)) return 0;

        return (status_o == rhs_trans.status_o) &&
               (error_o  == rhs_trans.error_o)  &&
               (data_o   == rhs_trans.data_o);
    endfunction

endclass

`endif
```

**字段职责：**

| 字段 | driver | monitor | ref_model | scb |
|------|--------|---------|-----------|-----|
| cmd, addr, data... | 填 | - | 读 | - |
| status_o | - | 填实际值 | 填期望值 | 比对 |
| data_o[] | - | 填实际值 | 填期望值 | 比对 |
| error_o | - | 填实际值 | 填期望值 | 比对 |

## 相关链接

- [[05-Verification/UVM-Template/00-总览|UVM 模板总览]] - UVM 验证环境模板
- [[01-SV语法/02-类|类与面向对象]] - SystemVerilog 类
- [[00-总索引]] - 返回总索引
