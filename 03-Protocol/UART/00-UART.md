---
tags: [Protocol, UART, 涓茶澶栬]
---

# UART 鍗忚

> Universal Asynchronous Receiver/Transmitter - 寮傛涓茶閫氫俊

## 馃搵 鍗忚姒傝堪

### 鐗规€?- 涓ゆ牴淇″彿绾匡細TX(鍙戦€?銆丷X(鎺ユ敹)
- 寮傛浼犺緭锛屾棤闇€鏃堕挓绾?- 璧峰浣?鏁版嵁浣?鏍￠獙浣?鍋滄浣?- 甯哥敤娉㈢壒鐜囷細9600/115200/921600

---

## 馃攲 淇″彿瀹氫箟

| 淇″彿 | 鏂瑰悜 | 璇存槑 |
|------|------|------|
| TX | Output | 鍙戦€佹暟鎹?|
| RX | Input | 鎺ユ敹鏁版嵁 |
| RTS | Output | 璇锋眰鍙戦€?鍙€? |
| CTS | Input | 娓呴櫎鍙戦€?鍙€? |

---

## 馃搳 鏁版嵁甯ф牸寮?
### 鏍囧噯甯х粨鏋?
```
鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹€鈹€鈹?鈹係TART 鈹? Data  鈹?Parity鈹?STOP 鈹?STOP 鈹?鈹?(1b) 鈹?(5-9b) 鈹?opt)鈹?(1b) 鈹?opt) 鈹?鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹粹攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹粹攢鈹€鈹€鈹€鈹€鈹粹攢鈹€鈹€鈹€鈹€鈹€鈹粹攢鈹€鈹€鈹€鈹€鈹€鈹?   0      D0-D8    P/E    1     1
```

### 甯哥敤閰嶇疆

| 鍙傛暟 | 甯哥敤鍊?| 璇存槑 |
|------|--------|------|
| 娉㈢壒鐜?| 9600,115200 | 姣旂壒/绉?|
| 鏁版嵁浣?| 8 | 鍏稿瀷鍊?|
| 鍋滄浣?| 1/2 | 鍋滄浣嶅搴?|
| 鏍￠獙浣?| None/Odd/Even | 鏍￠獙鏂瑰紡 |
| 娴佹帶 | None/RTS/CTS | 纭欢娴佹帶 |

---

## 鈴憋笍 鏃跺簭鍥?
### 鍙戦€佹椂搴?
```
        1    2    3    4    5    6    7    8
TX  鈹€鈹€鈹?鈹€鈹€鈹攢鈹攢鈹攢鈹攢鈹攢鈹攢鈹攢鈹攢鈹攢鈹攢鈹攢鈹?鈹€鈹€
     鈹?鈹侱0鈹侱1鈹侱2鈹侱3鈹侱4鈹侱5鈹侱6鈹侱7鈹侾鈹?鈹?鈹?     鈹斺攢鈹粹攢鈹粹攢鈹粹攢鈹粹攢鈹粹攢鈹粹攢鈹粹攢鈹粹攢鈹粹攢鈹粹攢鈹粹攢鈹?鈹斺攢

     鈹€鈹€鈹€绌洪棽鈹€鈹€鈹€START鈹€鈹ゆ暟鎹攢鈹鈹€鈹TOP鈹€绌洪棽
```

### 鎺ユ敹閲囨牱

```verilog
// 鎺ユ敹鐘舵€佹満
IDLE:    if (!uart_rx) state <= START;
START:   if (baud_tick) state <= DATA;
DATA:    if (bit_cnt==7 && baud_tick) state <= PARITY;
PARITY:  if (baud_tick) state <= STOP;
STOP:    if (baud_tick) state <= IDLE;
```

---

## 馃摑 UVM楠岃瘉妯″瀷

### UART Transaction

```verilog
class uart_transaction extends uvm_sequence_item;
    typedef enum {NONE, ODD, EVEN} parity_e;

    rand bit [7:0] data;
    rand parity_e parity_type;
    rand int baud_rate;

    `uvm_object_utils_begin(uart_transaction)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_enum(parity_e, parity_tpe, UVM_ALL_ON)
    `uvm_object_utils_end

    function bit calculate_parity();
        case (parity_type)
            NONE: return 0;
            ODD: return ^data;    // 濂囨牎楠?            EVEN: return ~^data;  // 鍋舵牎楠?        endcase
    endfunction
endclass
```

### UART Monitor

```verilog
class uart_monitor extends uvm_monitor;
    virtual uart_if vif;
    uvm_analysis_port #(uart_transaction) ap;

    typedef enum {IDLE, START, DATA, PARITY, STOP} state_e;
    state_e state;

    function void build_phase(uvm_phase phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual uart_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "vif not found")
    endfunction

    task run_phase(uvm_phase phase);
        bit [7:0] rx_data;
        bit parity_bit;

        forever begin
            @(posedge vif.clock);
            case (state)
                IDLE: begin
                    if (!vif.rx) begin  // 妫€娴嬭捣濮嬩綅
                        state <= START;
                        `uvm_info("MON", "Start bit detected", UVM_LOW)
                    end
                end

                START: begin
                    @(posedge vif.clock);
                    if (vif.rx == 0) begin
                        state <= DATA;
                        rx_data = 0;
                    end else
                        state <= IDLE;
                end

                DATA: begin
                    for (int i = 0; i < 8; i++) begin
                        @(posedge vif.clock);
                        rx_data[i] = vif.rx;
                    end
                    state <= PARITY;
                end

                PARITY: begin
                    @(posedge vif.clock);
                    parity_bit = vif.rx;
                    state <= STOP;
                end

                STOP: begin
                    @(posedge vif.clock);
                    if (vif.rx == 1) begin  // 鍋滄浣?                        uart_transaction tr;
                        tr = uart_transaction::type_id::create("tr");
                        tr.data = rx_data;
                        ap.write(tr);
                        `uvm_info("MON", $sformatf("Received: 0x%h", rx_data), UVM_LOW)
                    end
                    state <= IDLE;
                end
            endcase
        end
    endtask
endclass
```

### UART Scoreboard

```verilog
class uart_scoreboard extends uvm_scoreboard;
    uvm_analysis_export #(uart_transaction) tx_export;
    uvm_analysis_export #(uart_transaction) rx_export;

    uvm_tlm_analysis_fifo #(uart_transaction) expected_fifo;
    uvm_tlm_analysis_fifo #(uart_transaction) actual_fifo;

    function void check_phase(uvm_phase phase);
        if (expected_fifo.used() != 0)
            `uvm_error("SB", "Unexpected transactions in expected FIFO");
        if (actual_fifo.used() != 0)
            `uvm_error("SB", "Unexpected transactions in actual FIFO");
    endfunction
endclass
```

---

## 鉁?楠岃瘉瑕佺偣

### 鍩虹鍔熻兘
- [x] 姝ｇ‘鎺ユ敹瀛楄妭
- [x] 璧峰浣嶆娴?- [ ] 鍋滄浣嶉獙璇?- [ ] 娉㈢壒鐜囩簿搴?
### 鏍￠獙鍔熻兘
- [ ] 濂囧伓鏍￠獙姝ｇ‘
- [ ] 鏍￠獙閿欒妫€娴?- [ ] 鏃犳牎楠屾ā寮?
### 杈圭晫鏉′欢
- [ ] 杩炵画瀛楄妭鎺ユ敹
- [ ] 涓棿绌洪棽
- [ ] 娉㈢壒鐜囧垏鎹?- [ ] 鏁版嵁瀹屾暣鎬?
### 寮傚父鍦烘櫙
- [ ] 甯ч敊璇?- [ ] 鏍￠獙閿欒
- [ ] FIFO婧㈠嚭
- [ ] 瓒呮椂妫€娴?
---

## 馃敡 甯哥敤鑴氭湰

### Python Uart 妯℃嫙

```python
import serial
import time

class UartComm:
    def __init__(self, port, baudrate=115200):
        self.ser = serial.Serial(port, baudrate, timeout=1)

    def send(self, data):
        self.ser.write(bytes([data]))
        time.sleep(0.01)

    def receive(self, num_bytes=1):
        return self.ser.read(num_bytes)

    def close(self):
        self.ser.close()

# 浣跨敤
uart = UartComm('COM3', 115200)
uart.send(0x55)
response = uart.receive()
uart.close()
```

---

## 馃敆 鐩稿叧閾炬帴

- [[03-Protocol/00-鍗忚绱㈠紩|鍗忚绱㈠紩]] - 杩斿洖鍗忚绱㈠紩
- [[03-Protocol/I2C/00-I2C|I2C]] - I2C 鎬荤嚎鍗忚
- [[03-Protocol/SPI/00-SPI|SPI]] - SPI 鍗忚
- [[00-鎬荤储寮昡] - 杩斿洖鎬荤储寮?
---

tags: #Protocol #UART #Async

