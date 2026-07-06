# I2C 鍗忚

> Inter-Integrated Circuit - 鍙岀嚎涓茶鎬荤嚎

## 馃搵 鍗忚姒傝堪

### 鐗规€?- 涓ゆ牴淇″彿绾匡細SCL(鏃堕挓)銆丼DA(鏁版嵁)
- 涓讳粠鏋舵瀯锛屾敮鎸佸涓诲浠?- 寮€婕忚緭鍑猴紝闇€瑕佷笂鎷夌數闃?- 閫熷害锛氭爣鍑嗘ā寮?100KHz)銆佸揩閫熸ā寮?400KHz)銆侀珮閫熸ā寮?3.4MHz)

---

## 馃攲 淇″彿瀹氫箟

| 淇″彿 | 鏂瑰悜 | 璇存槑 |
|------|------|------|
| SCL | Master鈫扐ll | 涓茶鏃堕挓 |
| SDA | Bidirectional | 涓茶鏁版嵁 |
| SCL | Slave Input | 浠庢満鎺ユ敹鏃堕挓 |

### 鐢佃矾缁撴瀯

#### 寮€婕忚緭鍑?+ 涓婃媺鐢甸樆

```
         VCC (3.3V/5V)
            鈹?       鈹屸攢鈹€鈹€鈹€鈹粹攢鈹€鈹€鈹€鈹?       鈹?  Rpu   鈹? 涓婃媺鐢甸樆 (4.7K惟~10K惟)
       鈹斺攢鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹?            鈹?     鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹尖攢鈹€鈹€鈹€鈹€鈹€鈹?     鈹?            鈹?  鈹屸攢鈹€鈹粹攢鈹€鈹?     鈹屸攢鈹€鈹粹攢鈹€鈹?   SDA/SCL
  鈹?MOS 鈹?     鈹?MOS 鈹?    鈹斺攢鈫?璁惧IO
  鈹?    鈹?     鈹?    鈹?  鈹斺攢鈹攢鈹€鈹?     鈹斺攢鈹€鈹攢鈹€鈹?    鈹?            鈹?    鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹€鈹?           鈹?         GND
```

- **寮€婕?寮€闆嗘瀬杈撳嚭**: 杈撳嚭绾OSFET/鏅朵綋绠″彧椹卞姩浣庣數骞筹紝楂樼數骞崇敱涓婃媺鐢甸樆鎻愪緵
- **绾夸笌閫昏緫**: 澶氫釜璁惧鍙悓鏃惰緭鍑轰綆鐢靛钩锛屽疄鐜?绾夸笌"浠茶
- **涓婃媺鐢甸樆閫夋嫨**:
  - 閫熷害蹇啋灏忕數闃?濡?.7K惟)
  - 鍔熻€椾綆鈫掑ぇ鐢甸樆(濡?0K惟)
  - 鎬荤嚎鐢靛400pF浠ュ唴

#### 鍩烘湰缁撴瀯鍥?(澶氫富澶氫粠)

```
    鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?    鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?    鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?    鈹?Master1 鈹?    鈹?Master2 鈹?    鈹? MasterN  鈹?    鈹?  MCU   鈹?    鈹?  MCU   鈹?    鈹?   GPU    鈹?    鈹斺攢鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹?    鈹斺攢鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹?    鈹斺攢鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹?         鈹?              鈹?              鈹?         鈹? SCL  鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺晲鈺愨晲鈺愨晲鈺?         鈹? SDA  鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺晲鈺愨晲鈺愨晲鈺?         鈹?              鈹?              鈹?    鈹屸攢鈹€鈹€鈹€鈹粹攢鈹€鈹€鈹€鈹?   鈹屸攢鈹€鈹€鈹€鈹粹攢鈹€鈹€鈹€鈹?   鈹屸攢鈹€鈹€鈹€鈹粹攢鈹€鈹€鈹€鈹?    鈹?Slave1  鈹?   鈹?Slave2  鈹?   鈹?SlaveN   鈹?    鈹? EEPROM 鈹?   鈹? Sensor 鈹?   鈹?  RTC    鈹?    鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?   鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?   鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?```

- **涓昏澶?Master)**: 鍙戣捣閫氫俊銆佷骇鐢熸椂閽烻CL
- **浠庤澶?Slave)**: 鍝嶅簲涓昏澶囥€佽瀵诲潃
- **鍦板潃鍞竴鎬?*: 鎵€鏈変粠璁惧蹇呴』鏈夊敮涓€鍦板潃
- **鎬荤嚎绔炰簤**: 澶氫富璁惧鏃堕€氳繃浠茶鍐冲畾涓绘帶鏉?
---

## 馃搳 浼犺緭鏍煎紡

### 鍩烘湰缁撴瀯

```
鈹屸攢鈹€鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹攢鈹€鈹€鈹€鈹€鈹?鈹係TART鈹?7浣嶅湴鍧€ 鈹?R/W 鈹?ACK 鈹?8浣嶆暟鎹?鈹?ACK 鈹?8浣嶆暟鎹?鈹?ACK 鈹係TOP鈹?鈹斺攢鈹€鈹€鈹€鈹€鈹粹攢鈹€鈹€鈹€鈹€鈹粹攢鈹€鈹€鈹€鈹€鈹粹攢鈹€鈹€鈹€鈹€鈹粹攢鈹€鈹€鈹€鈹€鈹粹攢鈹€鈹€鈹€鈹€鈹粹攢鈹€鈹€鈹€鈹€鈹粹攢鈹€鈹€鈹€鈹€鈹粹攢鈹€鈹€鈹€鈹粹攢鈹€鈹€鈹€鈹€鈹?```

### 鍦板潃鏍煎紡

```
鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?鈹? 7浣嶈澶囧湴鍧€   鈹?R/W 鈹?              鈹?鈹? [6:1] [0]    鈹?    鈹?              鈹?鈹? 鑺墖鍦板潃  鏂瑰悜 鈹?              鈹?鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?```

---

## 鈴憋笍 鏃跺簭鍥?
### 鍐欐搷浣?
```
SDA  鈹€鈹€鈹€鈹?   鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?   鈹屸攢鈹€
         鈹斺攢鈹€鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹屸攢鈹€鈹?
SCL  鈹€鈹€鈹€鈹€鈹€鈹? 鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹€
          鈹斺攢鈹€鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹€鈹?
        START  A6  A5  A4  A3  A2  A1  A0  W  ACK
```

### 璇绘搷浣?
```
SDA  鈹€鈹€鈹€鈹?   鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?   鈹屸攢鈹€
         鈹斺攢鈹€鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹屸攢鈹€鈹?
SCL  鈹€鈹€鈹€鈹€鈹€鈹? 鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹?鈹屸攢鈹€
          鈹斺攢鈹€鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹?鈹斺攢鈹€鈹?
        START  A6  A5  A4  A3  A2  A1  A0  R  ACK
```

---

## 馃摑 UVM楠岃瘉妯″瀷

### I2C Transaction

```systemverilog
class i2c_transaction extends uvm_sequence_item;
    typedef enum {WRITE, READ} rw_e;

    rand rw_e read_write;
    rand bit [6:0] addr;
    rand bit [7:0] data[];
    int delay_cycles;

    `uvm_object_utils_begin(i2c_transaction)
        `uvm_field_enum(rw_e, read_write, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_array_int(data, UVM_ALL_ON)
    `uvm_object_utils_end

    constraint data_size_c {
        data.size() inside {[1:256]};
    }
endclass
```

### I2C Driver

```systemverilog
class i2c_driver extends uvm_driver #(i2c_transaction);
    virtual i2c_if vif;

    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_transaction(i2c_transaction tr);
        vif.sda_drive(1'b1);
        vif.scl_drive(1'b1);

        // START
        @(posedge vif.scl);
        vif.sda_drive(1'b0);
        @(negedge vif.scl);

        // Address + R/W
        drive_byte({tr.addr, tr.read_write});

        // ACK
        drive_ack();

        // Data
        foreach (tr.data[i]) begin
            drive_byte(tr.data[i]);
            drive_ack();
        end

        // STOP
        @(negedge vif.scl);
        vif.sda_drive(1'b0);
        @(posedge vif.scl);
        vif.sda_drive(1'b1);
    endtask

    task drive_byte(bit [7:0] data);
        for (int i = 7; i >= 0; i--) begin
            @(negedge vif.scl);
            vif.sda_drive(data[i]);
        end
    endtask
endclass
```

---

## 鉁?楠岃瘉瑕佺偣

### 1. 鍩虹鍔熻兘
- [ ] START/STOP鏉′欢
- [ ] 鍦板潃璇嗗埆
- [ ] 璇诲啓鍒囨崲
- [ ] ACK/NACK鍝嶅簲

### 2. 鏁版嵁浼犺緭
- [ ] 鍗曞瓧鑺傝鍐?- [ ] 澶氬瓧鑺傝繛缁鍐?- [ ] 瀵勫瓨鍣ㄨ鍐?
### 3. 杈圭晫鏉′欢
- [ ] 浠庢満涓嶅簲绛?- [ ] 鎬荤嚎浠茶
- [ ] 鏃堕挓 stretching
- [ ] 閲嶅START

### 4. 寮傚父鍦烘櫙
- [ ] 鎬荤嚎蹇欐娴?- [ ] 瓒呮椂澶勭悊
- [ ] 閿欒鎭㈠

---

## 馃敆 鐩稿叧鍗忚

- [[../AXI/00-AXI]] - AXI鎬荤嚎鍗忚
- [[00-SPI]] - SPI鍗忚
- [[00-UART]] - UART鍗忚

---

tags: #Protocol #I2C #Interface
related: [[00-鎬荤储寮昡], [[../AXI/00-AXI]], [[00-SPI]]

