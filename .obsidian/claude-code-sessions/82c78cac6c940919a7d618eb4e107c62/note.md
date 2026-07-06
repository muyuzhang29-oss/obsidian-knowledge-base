SPI Slave 楠岃瘉鏂囨。

---

# **1. 楠岃瘉姒傝堪**

## **1.1 鏂囨。鐩殑**

鏈枃妗ｉ拡瀵?SPI Slave 妯″潡鐨?UVM 楠岃瘉骞冲彴锛岃缁嗘弿杩伴獙璇佺幆澧冩灦鏋勩€佹祴璇曠偣瑙勫垝銆佹祴璇曠敤渚嬭璁＄瓑鍐呭锛屼负楠岃瘉宸ヤ綔鐨勬墽琛屽拰鍥炲綊鎻愪緵鍙傝€冧緷鎹€?
## **1.2 楠岃瘉鏂规硶瀛?*

鏈獙璇佸钩鍙伴噰鐢?UVM锛圲niversal Verification Methodology锛?鏂规硶瀛︼紝鍩轰簬 SystemVerilog 璇█瀹炵幇銆傞獙璇佺瓥鐣ュ涓嬶細

路聽婵€鍔辩敓鎴愶細閫氳繃 UVM Sequence 鏈哄埗鐢熸垚鍚勭被 SPI 浜嬪姟婵€鍔憋紝瑕嗙洊姝ｅ父鎿嶄綔鍜屽紓甯稿満鏅?
路聽鍗忚妫€鏌ワ細Monitor 瀹炴椂閲囨牱鎺ュ彛淇″彿锛岃繘琛屽崗璁悎瑙勬€ф鏌ュ拰 CRC 鏍￠獙

路聽鍔熻兘瑕嗙洊锛氶€氳繃 Covergroup 閲忓寲楠岃瘉瑕嗙洊鐜囷紝纭繚鎵€鏈夊姛鑳界偣琚厖鍒嗛獙璇?
路聽鏂█楠岃瘉锛氬湪 Monitor 涓祵鍏?SVA 骞跺彂鏂█锛屽 FSM 鐘舵€佽浆鎹€侀敊璇鐞嗙瓑鍏抽敭琛屼负杩涜瀹炴椂妫€鏌?
## **1.3 楠岃瘉鐩爣**

|   |   |
|---|---|
|**鐩爣**|**璇存槑**|
|鍔熻兘姝ｇ‘鎬楠岃瘉 SPI Slave 鍦ㄦ墍鏈?SPI 妯″紡涓嬫纭鐞嗗啓鍛戒护銆佽鍛戒护鍜岃鏁版嵁鍛戒护|
|鍗忚鍚堣鎬楠岃瘉甯ф牸寮忋€丆RC-8 鏍￠獙銆丆S 鏃跺簭绛夌鍚堝崗璁鑼億
|閿欒澶勭悊|楠岃瘉 CRC 閿欒銆佽秴鏃堕敊璇€佹棤鏁堝湴鍧€绛夊紓甯稿満鏅笅鐨勮涓簗
|杈圭晫鏉′欢|楠岃瘉鏈€灏?鏈€澶?payload銆佽竟鐣屽湴鍧€绛夋瀬绔儏鍐祙
|鐘舵€佹満瑕嗙洊|楠岃瘉 FSM 鍏ㄩ儴 8 涓姸鎬佸強鎵€鏈夊悎娉曠姸鎬佽浆鎹㈣矾寰剕
|瑕嗙洊鐜囪揪鏍噟鍔熻兘瑕嗙洊鐜囪揪鍒?100%锛屼唬鐮佽鐩栫巼杈惧埌鐩爣鍊紎

## **1.4 楠岃瘉鐜缁撴瀯**

鈹屸攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹? 
鈹?聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽spi_base_test (娴嬭瘯灞? 聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽鈹? 
鈹?聽聽聽鈹溾攢鈹€ spi_config 鈹€鈹€鈹€ config_db 鈹€鈹€> 鎵€鏈夌粍浠?聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽鈹? 
鈹?聽聽聽鈹斺攢鈹€ spi_env (鐜灞? 聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽鈹? 
鈹?聽聽聽聽聽聽聽聽鈹溾攢鈹€ spi_agent (浠ｇ悊灞? 聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽鈹? 
鈹?聽聽聽聽聽聽聽聽鈹?聽聽聽鈹溾攢鈹€ uvm_sequencer#(spi_transaction) 聽(鎺掑簭鍣? 聽聽聽鈹? 
鈹?聽聽聽聽聽聽聽聽鈹?聽聽聽鈹溾攢鈹€ spi_driver 聽<鈹€鈹€ vif.DRV 聽聽聽聽聽聽聽聽聽(椹卞姩鍣? 聽聽聽鈹? 
鈹?聽聽聽聽聽聽聽聽鈹?聽聽聽鈹斺攢鈹€ spi_monitor <鈹€鈹€ vif.MON 鈹€鈹€> ap 聽聽(鐩戞祴鍣? 聽聽聽鈹? 
鈹?聽聽聽聽聽聽聽聽鈹斺攢鈹€ spi_coverage 聽聽聽<鈹€鈹€ ap (analysis_export) (瑕嗙洊鐜? 鈹? 
鈹溾攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹? 
鈹?聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽tb_top (椤跺眰娴嬭瘯骞冲彴) 聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽鈹? 
鈹?聽聽聽鈹溾攢鈹€ spi_slave_intf (鎺ュ彛) 聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽鈹? 
鈹?聽聽聽鈹溾攢鈹€ ips_lib_asyc_fifo (RX 寮傛 FIFO) 聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽鈹? 
鈹?聽聽聽鈹溾攢鈹€ spi_slave_wrapper -> spi_slave (DUT) 聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽鈹? 
鈹?聽聽聽鈹斺攢鈹€ config_db 妗ユ帴: spi_config -> 鎺ュ彛淇″彿 聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽鈹? 
鈹斺攢鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹?
---

# **2. 寰呮祴璁捐姒傝堪**

## **2.1 DUT 妯″潡璇存槑**

寰呮祴璁捐锛圖UT锛変负 spi_slave 妯″潡锛岀敱 spi_slave_wrapper 灏佽瀹炰緥鍖栥€傝妯″潡瀹炵幇浜嗕竴涓?SPI 浠庤澶囨帴鍙ｏ紝鏀寔涓庡閮?SPI 涓昏澶囪繘琛屼覆琛岄€氫俊锛屽苟閫氳繃寮傛 FIFO 涓庣墖涓?SOC 杩涜鏁版嵁浜や簰銆?
## **2.2 DUT 绔彛鍒楄〃**

### **2.2.1 SPI 鎬荤嚎淇″彿**

|   |   |   |   |
|---|---|---|---|
|**淇″彿鍚?*|**鏂瑰悜**|**浣嶅**|**璇存槑**|
|spi_clk|input|1|SPI 鏃堕挓鍩焲
|spi_rst_n|input|1|浣庣數骞虫湁鏁堝浣峾
|clk_100mhz|input|1|100MHz 绯荤粺鏃堕挓|
|rst_100mhz|input|1|绯荤粺澶嶄綅锛堥珮鐢靛钩鏈夋晥锛墊
|spi_sck|input|1|SPI 涓茶鏃堕挓锛堟潵鑷富璁惧锛墊
|spi_cs|input|1|SPI 鐗囬€変俊鍙穦
|spi_mosi|input|1|SPI 涓诲嚭浠庡叆鏁版嵁绾縷
|spi_miso|output|1|SPI 涓诲叆浠庡嚭鏁版嵁绾縷

### **2.2.2 寮傛 FIFO TX 鎺ュ彛锛圖UT 鈫?SOC锛?*

|   |   |   |   |
|---|---|---|---|
|**淇″彿鍚?*|**鏂瑰悜**|**浣嶅**|**璇存槑**|
|asyc_fifo_tx_n_empty|output|1|TX FIFO 闈炵┖鏍囧織|
|asyc_fifo_tx_rd_en|input|1|TX FIFO 璇讳娇鑳絴
|asyc_fifo_tx_rdata|output|10|TX FIFO 璇绘暟鎹畖

### **2.2.3 寮傛 FIFO RX 鎺ュ彛锛圫OC 鈫?DUT锛?*

|   |   |   |   |
|---|---|---|---|
|**淇″彿鍚?*|**鏂瑰悜**|**浣嶅**|**璇存槑**|
|asyc_fifo_rx_wr_en|input|1|RX FIFO 鍐欎娇鑳絴
|asyc_fifo_rx_n_full|output|1|RX FIFO 闈炴弧鏍囧織|
|asyc_fifo_rx_wdata|input|8|RX FIFO 鍐欐暟鎹畖
|asyc_fifo_rx_n_empty|output|1|RX FIFO 闈炵┖鏍囧織|
|asyc_fifo_rx_rd_en|input|1|RX FIFO 璇讳娇鑳斤紙DUT 渚э級|
|asyc_fifo_rx_rdata|output|8|RX FIFO 璇绘暟鎹畖

### **2.2.4 閰嶇疆瀵勫瓨鍣?*

|   |   |   |   |
|---|---|---|---|
|**淇″彿鍚?*|**鏂瑰悜**|**浣嶅**|**璇存槑**|
|spi_slv_en_reg|input|1|浠庤澶囦娇鑳絴
|spi_cpol_reg|input|1|鏃堕挓鏋佹€
|spi_cpha_reg|input|1|鏃堕挓鐩镐綅|
|spi_cs_act_pol_reg|input|1|CS 鏈夋晥鏋佹€
|spis_ext_data_len_ins_reg|input|1|鎵╁睍鏁版嵁闀垮害妯″紡|
|spis_dummy_ins_reg|input|8|Dummy 瀛楄妭鏁皘
|spis_state_ack_tout_step_reg|input|2|瓒呮椂姝ラ暱|
|spis_state_ack_thrs_reg|input|8|瓒呮椂闃堝€紎

### **2.2.5 鐘舵€佽緭鍑?*

|   |   |   |   |
|---|---|---|---|
|**淇″彿鍚?*|**鏂瑰悜**|**浣嶅**|**璇存槑**|
|spis_state_code|output|3|FSM 鐘舵€佺紪鐮侊紙S0-S7锛墊
|spis_state_code_vld|output|1|鐘舵€佺爜鏈夋晥鏍囧織|
|spis_fail_state_data|output|64|澶辫触鐘舵€佹暟鎹紙8脳8 bit锛墊

### **2.2.6 閿欒杈撳嚭**

|   |   |   |
|---|---|---|
|**淇″彿鍚?*|**鏂瑰悜**|**璇存槑**|
|loc_rw_err|output|LOC/RW 閿欒|
|wait_read_data_cmd_flag_0_err|output|绛夊緟璇绘暟鎹爣蹇?0 閿欒|
|wait_read_data_cmd_flag_1_err|output|绛夊緟璇绘暟鎹爣蹇?1 閿欒|
|read_data_cmd_mp_head_mis_err|output|璇绘暟鎹懡浠?MP 澶撮儴涓嶅尮閰嶉敊璇瘄
|cmd_crc8_err|output|CRC-8 鏍￠獙閿欒|
|wr_cmd_rcd_err|output|鍐欏懡浠?RCD 閿欒|
|rd_cmd_rcd_err|output|璇诲懡浠?RCD 閿欒|
|spis_state_ack_tout_err|output|鐘舵€佺‘璁よ秴鏃堕敊璇瘄

## **2.3 FSM 鐘舵€佸畾涔?*

DUT 鍐呴儴鐘舵€佹満鍖呭惈 8 涓姸鎬侊紝3-bit 缂栫爜锛?
|   |   |   |
|---|---|---|
|**缂栫爜**|**鐘舵€佸悕**|**璇存槑**|
|S0 (000)|IDLE|绌洪棽鐘舵€侊紝绛夊緟 CS 鏈夋晥|
|S1 (001)|WRITE_CMD|澶勭悊鍐欏懡浠
|S2 (010)|WAIT_WRITE_CONFIRM|绛夊緟 SOC 鍐欑‘璁
|S3 (011)|READ_CMD|澶勭悊璇诲懡浠
|S4 (100)|WAIT_READ_CONFIRM|绛夊緟 SOC 璇荤‘璁
|S5 (101)|READ_SUCCESS|璇绘搷浣滄垚鍔焲
|S6 (110)|READ_FAIL|璇绘搷浣滃け璐
|S7 (111)|READ_DATA_CMD|澶勭悊璇绘暟鎹懡浠

## **2.4 SPI 鍗忚甯ф牸寮?*

### **2.4.1 甯х粨鏋?*

|   |   |
|---|---|
|**鍛戒护绫诲瀷**|**甯у唴瀹?*|
|WR_CMD (01)|cmd_byte + addr_l + ctrl_h + ctrl_l + payload[N] + crc_cmd|
|RD_CMD (10, rd_en=0)|cmd_byte + addr_l + ctrl_h + ctrl_l + crc_cmd|
|RD_CMD (10, rd_en=1)|cmd_byte + addr_l + ctrl_h + ctrl_l + payload[rd_length] + crc_cmd|
|RD_DATA_CMD (11)|cmd_byte + addr_l + ctrl_h + ctrl_l + crc_cmd + dummy[M] + data[N] + crc_data|

### **2.4.2 瀛楁璇存槑**

路聽cmd_byte锛歿1'b1, DST_ADDR[1:0]=01, cmd[1:0], DST_PORT[2:0]=010}锛? bit

路聽addr_l锛氱洰鏍囧湴鍧€锛? bit

路聽ctrl_h锛歿rd_en, 1'b0, rd_length[6:0]}锛? bit

路聽ctrl_l锛歞ata_len[7:0]锛? bit

路聽CRC-8锛氬椤瑰紡 0x2F锛屽垵濮嬪€?0xFF锛岃緭鍏ュ彇鍙嶏紝杈撳嚭鍙栧弽

### **2.4.3 SPI 妯″紡**

|   |   |   |   |
|---|---|---|---|
|**妯″紡**|**CPOL**|**CPHA**|**璇存槑**|
|Mode 0|0|0|绌洪棽浣庣數骞筹紝绗竴涓竟娌块噰鏍穦
|Mode 1|0|1|绌洪棽浣庣數骞筹紝绗簩涓竟娌块噰鏍穦
|Mode 2|1|0|绌洪棽楂樼數骞筹紝绗竴涓竟娌块噰鏍穦
|Mode 3|1|1|绌洪棽楂樼數骞筹紝绗簩涓竟娌块噰鏍穦

---

# **3. 楠岃瘉鐜缁勪欢璇﹁В**

## **3.1 椤跺眰娴嬭瘯骞冲彴锛坱b_top锛?*

椤跺眰妯″潡 tb_top 璐熻矗锛?
1. 鏃堕挓鐢熸垚锛氱敓鎴?SPI 鏃堕挓锛堢害 333MHz锛夊拰 100MHz 绯荤粺鏃堕挓

2. 澶嶄綅绠＄悊锛氫骇鐢熷浣嶄俊鍙峰苟绠＄悊澶嶄綅鏃跺簭

3. 鎺ュ彛瀹炰緥鍖栵細瀹炰緥鍖?spi_slave_intf 鎺ュ彛

4. DUT 瀹炰緥鍖栵細瀹炰緥鍖?RX 寮傛 FIFO 鍜?DUT wrapper

5. 閰嶇疆妗ユ帴锛氫粠 UVM config_db 璇诲彇 spi_config 瀵硅薄锛屽皢鍏跺瓧娈垫槧灏勫埌鎺ュ彛淇″彿绾?
6. UVM 鍚姩锛氶€氳繃 run_test() 鍚姩 UVM 楠岃瘉骞冲彴

7. 瓒呮椂鎺у埗锛氳缃?10ms 浠跨湡瓒呮椂

## **3.2 鎺ュ彛锛坰pi_slave_intf锛?*

鎺ュ彛瀹氫箟浜嗘墍鏈?SPI 鎬荤嚎淇″彿銆侀厤缃瘎瀛樺櫒淇″彿銆丗IFO 淇″彿鍜?DUT 杈撳嚭淇″彿锛屽苟鍖呭惈锛?
路聽椹卞姩鏃堕挓鍧楋紙drv_cb锛夛細鐢ㄤ簬 Driver 椹卞姩淇″彿鐨勬椂搴忔帶鍒?
路聽鐩戞祴鏃堕挓鍧楋紙mon_cb锛夛細鐢ㄤ簬 Monitor 閲囨牱淇″彿鐨勬椂搴忔帶鍒?
路聽Modport DRV锛欴river 渚х鍙ｈ鍥?
路聽Modport MON锛歁onitor 渚х鍙ｈ鍥?
## **3.3 閰嶇疆瀵硅薄锛坰pi_config锛?*

spi_config 缁ф壙鑷?uvm_object锛屽寘鍚袱绫婚厤缃細

### **3.3.1 DUT 瀵勫瓨鍣ㄩ厤缃?*

|   |   |   |   |
|---|---|---|---|
|**瀛楁**|**绫诲瀷**|**榛樿鍊?*|**璇存槑**|
|cpol|bit|闅忔満|鏃堕挓鏋佹€
|cpha|bit|闅忔満|鏃堕挓鐩镐綅|
|cs_act_pol|bit|0|CS 鏈夋晥鏋佹€
|ext_data_len|bit|闅忔満|鎵╁睍鏁版嵁闀垮害妯″紡|
|dummy_ins|bit[7:0]|0|Dummy 瀛楄妭鏁皘
|slv_en|bit|1|浠庤澶囦娇鑳絴
|tout_step|bit[1:0]|闅忔満|瓒呮椂姝ラ暱|
|tout_thrs|bit[7:0]|闅忔満|瓒呮椂闃堝€紎

### **3.3.2 娴嬭瘯娴佺▼鍙傛暟**

|   |   |   |
|---|---|---|
|**瀛楁**|**绫诲瀷**|**璇存槑**|
|num_txns|int|浜嬪姟鏁伴噺|
|sck_period_ns|real|SPI 鏃堕挓鍛ㄦ湡锛坣s锛墊

鏀寔閫氳繃 plusarg 杩涜鍙傛暟瑕嗙洊銆?
## **3.4 浜嬪姟椤癸紙spi_transaction锛?*

spi_transaction 缁ф壙鑷?uvm_sequence_item锛屽缓妯′竴涓畬鏁寸殑 SPI 鍛戒护甯с€?
### **3.4.1 涓昏瀛楁**

|   |   |   |
|---|---|---|
|**瀛楁**|**绫诲瀷**|**璇存槑**|
|cmd|bit[1:0]|鍛戒护绫诲瀷锛歐R_CMD=01, RD_CMD=10, RD_DATA_CMD=11|
|addr_l|bit[7:0]|鐩爣鍦板潃|
|rd_en|bit|璇讳娇鑳芥爣蹇梶
|rd_length|bit[6:0]|璇诲彇闀垮害|
|data_len|bit[7:0]|鏁版嵁闀垮害|
|payload_data|bit[7:0][]|payload 鏁版嵁鏁扮粍|
|inject_crc_err|bit|CRC 閿欒娉ㄥ叆鏍囧織|
|early_cs_deassert|bit|鎻愬墠 CS 鎾ら攢鏍囧織|
|mst_cmd|bit|涓昏澶囧懡浠わ細MST_SUCCESS / MST_FAIL|
|mst_resp_data|bit[7:0][]|涓昏澶囧搷搴旀暟鎹畖
|resp_data|bit[7:0][]|鍝嶅簲鏁版嵁|

### **3.4.2 绾︽潫鏉′欢**

路聽payload 澶у皬鏍规嵁鍛戒护绫诲瀷绾︽潫

路聽閿欒娉ㄥ叆鍒嗗竷锛欳RC 閿欒 5%锛屾彁鍓?CS 鎾ら攢 5%锛屼富璁惧澶辫触 20%

### **3.4.3 鍏抽敭鏂规硶**

路聽cal_crc8() / calc_crc8()锛欳RC-8 璁＄畻

路聽build_queue()锛氭瀯寤哄抚鏁版嵁闃熷垪

路聽get_frame_len()锛氳绠楀抚闀垮害

## **3.5 搴忓垪锛圫equences锛?*

|   |   |   |
|---|---|---|
|**搴忓垪绫诲悕**|**璇存槑**|**婵€鍔卞唴瀹?*|
|spi_base_seq|鍩虹搴忓垪绫粅绌哄疄鐜帮紝浣滀负鐖剁被|
|spi_mixed_seq|娣峰悎搴忓垪|鐢熸垚 N 涓殢鏈虹被鍨嬬殑浜嬪姟|
|spi_write_seq|鍐欏簭鍒梶鐢熸垚 N 涓啓鍛戒护锛圵R_CMD锛変簨鍔
|spi_read_seq|璇诲簭鍒梶鐢熸垚 N 涓鍛戒护锛圧D_CMD锛変簨鍔
|spi_read_data_seq|璇绘暟鎹簭鍒梶鐢熸垚 N 涓鏁版嵁鍛戒护锛圧D_DATA_CMD锛変簨鍔
|spi_err_inject_seq|閿欒娉ㄥ叆搴忓垪|鏁呮剰娉ㄥ叆閿欒锛? 涓?CRC 閿欒 + 3 涓棤鏁堝湴鍧€ + 3 涓彁鍓?CS 鎾ら攢|
|spi_boundary_seq|杈圭晫搴忓垪|杈圭晫鏉′欢锛氭渶灏?payload锛? byte锛夈€佹渶澶?payload锛?4 bytes锛夈€侀浂鍦板潃銆佹渶澶у湴鍧€锛?xFF锛墊
|spi_b2b_seq|鑳岄潬鑳屽簭鍒梶杩炵画鍐欎簨鍔★紝鏃犲抚闂撮棿闅攟

## **3.6 椹卞姩鍣紙spi_driver锛?*

spi_driver 缁ф壙鑷?uvm_driver#(spi_transaction)锛屾壙鎷呭弻閲嶈鑹诧細

### **3.6.1 SPI 涓昏澶囪鑹?*

路聽鐢熸垚 SPI 鏃堕挓锛堝彲閰嶇疆鍛ㄦ湡鍜屾瀬鎬э級

路聽椹卞姩 CS 鍜?MOSI 淇″彿

路聽閲囨牱 MISO 淇″彿

路聽鏀寔鍏ㄩ儴 4 绉?SPI 妯″紡锛圕POL/CPHA 缁勫悎锛?
### **3.6.2 SOC 涓绘満瑙掕壊**

路聽姣忎釜 SPI 甯у畬鎴愬悗锛屽悜 RX FIFO 鍐欏叆涓昏澶囧搷搴旓紙纭鎴栫‘璁?澶辫触鏁版嵁锛?
路聽浠?TX FIFO 璇诲彇鏁版嵁

### **3.6.3 鍐呴儴鐘舵€佹満**

Driver 鍖呭惈 8 涓唴閮ㄧ姸鎬侊細

|   |   |
|---|---|
|**鐘舵€?*|**璇存槑**|
|IDLE|绌洪棽绛夊緟|
|CS_ACTIVE|CS 鏈夋晥|
|HEADER|鍙戦€佸抚澶达紙4 瀛楄妭锛墊
|PAYLOAD|鍙戦€?payload 鏁版嵁|
|CRC|鍙戦€?CRC 鏍￠獙瀛楄妭|
|CS_DEASSERT|CS 鎾ら攢|
|MST_RX_CMD|涓昏澶囨帴鏀跺懡浠
|MST_RX_DATA|涓昏澶囨帴鏀舵暟鎹畖

### **3.6.4 椹卞姩娴佺▼**

1. 浠?Sequencer 鑾峰彇浜嬪姟椤?
2. 鏍规嵁閰嶇疆鐢熸垚 SPI 鏃堕挓

3. 椹卞姩 CS 鏈夋晥

4. 閫?bit 鍙戦€佸抚澶达紙cmd_byte + addr_l + ctrl_h + ctrl_l锛?
5. 閫?bit 鍙戦€?payload锛堝鏈夛級

6. 閫?bit 鍙戦€?CRC

7. 瀵?RD_DATA_CMD锛氬彂閫?dummy 瀛楄妭锛岀劧鍚庢帴鏀舵暟鎹瓧鑺傚拰 CRC

8. 椹卞姩 CS 鎾ら攢

9. 鍚?RX FIFO 鍐欏叆涓昏澶囧搷搴?
10. 澶嶄綅淇″彿鐘舵€?
## **3.7 鐩戞祴鍣紙spi_monitor锛?*

spi_monitor 缁ф壙鑷?uvm_mymonitor锛屾槸楠岃瘉骞冲彴鐨勬牳蹇冩鏌ョ粍浠讹紝鍖呭惈 635 琛屼唬鐮侊紝杩愯 6 涓苟琛屾鏌ヤ换鍔°€?
### **3.7.1 甯ф敹闆嗕换鍔★紙collect_spi_frames锛?*

路聽妫€娴?CS 涓婂崌娌?涓嬮檷娌?
路聽閫?bit 閲囨牱 MOSI/MISO 鏁版嵁

路聽楠岃瘉棣栧瓧鑺傦紙loc=1, rw!=00锛?
路聽甯х粨鏉熸椂杩涜 CRC-8 鏍￠獙

路聽楠岃瘉甯х粨鏋勶紙header + payload + CRC 闀垮害涓€鑷存€э級

路聽瑙ｆ瀽瀛楄妭涓?spi_transaction 骞跺彂閫佸埌鍒嗘瀽绔彛

### **3.7.2 FSM 鐘舵€佽浆鎹㈡鏌ワ紙check_fsm_transitions锛?*

路聽璺熻釜 spis_state_code 鍙樺寲

路聽楠岃瘉鎵€鏈?FSM 鐘舵€佽浆鎹㈡槸鍚︾鍚堝悎娉曠姸鎬佸浘锛?3 鏉″悎娉曡浆鎹㈣矾寰勶級

### **3.7.3 閿欒鏍囧織妫€鏌ワ紙check_error_flags锛?*

路聽鐩戞祴 7 涓敊璇緭鍑轰俊鍙?
路聽璁板綍姣忎釜閿欒浜嬩欢

路聽楠岃瘉 CRC 閿欒鍚?FSM 鍦?20 涓懆鏈熷唴杩斿洖 IDLE

路聽楠岃瘉瓒呮椂閿欒鍚?FSM 鍦?10 涓懆鏈熷唴杩斿洖 IDLE

路聽妫€鏌?CRC 閿欒鍜岃秴鏃堕敊璇殑浜掓枼鎬?
### **3.7.4 璁℃暟鍣ㄦ鏌ワ紙check_counters锛?*

路聽鍛ㄦ湡绮剧‘鐨勮鏁板櫒妫€鏌ワ紙棰勭暀鎺ュ彛锛?
### **3.7.5 FIFO 鎺ュ彛妫€鏌ワ紙check_fifo_interfaces锛?*

路聽鐩戞祴 RX FIFO 婊＄姸鎬?
### **3.7.6 淇″彿瀹屾暣鎬ф鏌ワ紙check_signal_integrity锛?*

路聽妫€鏌?state_code_vld 淇″彿鏃?X/Z

路聽妫€鏌?state_code 鍦ㄦ湁鏁堟椂鏃?X/Z

路聽妫€鏌ラ敊璇緭鍑轰俊鍙锋棤 X/Z

路聽妫€鏌ユ椿璺冨抚鏈熼棿 MISO 淇″彿鏃?X/Z

### **3.7.7 SVA 骞跺彂鏂█锛圓1-A13锛?*

|   |   |
|---|---|
|**鏂█ID**|**妫€鏌ュ唴瀹?*|
|A1|澶嶄綅鍚?FSM 杩涘叆 IDLE 鐘舵€亅
|A2|IDLE 鐘舵€佷笅涓嶅彂鐢熻秴鏃秥
|A3|鐘舵€佺爜鏈夋晥鑼冨洿锛?-7锛墊
|A4|state_code_vld 淇″彿鏃?X/Z|
|A5|閿欒杈撳嚭淇″彿鏃?X/Z|
|A6|鍚堟硶 FSM 鐘舵€佽浆鎹
|A7|CRC 閿欒寮哄埗杩斿洖 IDLE|
|A8|瓒呮椂閿欒寮哄埗杩斿洖 IDLE|
|A9|鍗曟 FSM 璺宠浆|
|A10|vld=0 鏃剁姸鎬佺爜绋冲畾|
|A11|CRC 閿欒涓庤秴鏃堕敊璇簰鏂
|A12|甯ф湡闂?CS 淇濇寔鏈夋晥|
|A13|澶嶄綅鏈熼棿淇″彿鍒濆鍖東

### **3.7.8 鐩戞祴鍣ㄥ唴閮ㄨ鐩栫粍锛坈g_mon锛?*

路聽瑕嗙洊鍏ㄩ儴 8 涓?FSM 鐘舵€?
路聽瑕嗙洊鎵€鏈夐敊璇爣蹇?
路聽CPOL 脳 CPHA 浜ゅ弶瑕嗙洊

### **3.7.9 浠跨湡缁撴潫缁熻鎶ュ憡**

鍦ㄤ豢鐪熺粨鏉熸椂杈撳嚭锛氬抚璁℃暟銆佸悇閿欒璁℃暟銆佽鐩栫巼鐧惧垎姣斻€?
## **3.8 瑕嗙洊鐜囨敹闆嗗櫒锛坰pi_coverage锛?*

spi_coverage 缁ф壙鑷?uvm_subscriber#(spi_transaction)锛岄€氳繃鍒嗘瀽绔彛杩炴帴鍒?Monitor锛屽寘鍚?3 涓鐩栫粍锛?
### **3.8.1 鍛戒护瑕嗙洊缁勶紙cg_cmd锛?*

|   |   |
|---|---|
|**瑕嗙洊鐐?*|**瑕嗙洊椤?*|
|cmd_type|WR_CMD, RD_CMD, RD_DATA_CMD|
|crc_err|0, 1|
|spi_mode|CPOL 脳 CPHA锛? bins锛墊
|cmd 脳 mode|鍛戒护绫诲瀷涓?SPI 妯″紡浜ゅ弶|
|cmd 脳 error|鍛戒护绫诲瀷涓庨敊璇敞鍏ヤ氦鍙墊

### **3.8.2 Payload 闀垮害瑕嗙洊缁勶紙cg_payload_len锛?*

|   |   |   |
|---|---|---|
|**鍖洪棿**|**鑼冨洿**|**璇存槑**|
|min|1 byte|鏈€灏?payload|
|short|2-8 bytes|鐭?payload|
|medium|9-32 bytes|涓瓑 payload|
|long|33-63 bytes|闀?payload|
|max|64 bytes|鏈€澶?payload|

### **3.8.3 鍦板潃瑕嗙洊缁勶紙cg_addr锛?*

|   |   |
|---|---|
|**鍖洪棿**|**鑼冨洿**|
|low|0-127|
|high|128-255|

## **3.9 浠ｇ悊锛坰pi_agent锛?*

spi_agent 缁ф壙鑷?uvm_agent锛屽寘鍚細

路聽spi_driver锛氶┍鍔ㄥ櫒

路聽spi_monitor锛氱洃娴嬪櫒

路聽uvm_sequencer#(spi_transaction)锛氭帓搴忓櫒

鍦?ACTIVE 妯″紡涓嬪垱寤?Driver 骞惰繛鎺?Sequencer 鍒?Driver 鐨?seq_item_port锛涘缁堝垱寤?Monitor銆?
## **3.10 鐜锛坰pi_env锛?*

spi_env 缁ф壙鑷?uvm_env锛屽寘鍚細

路聽spi_agent锛氫唬鐞?
路聽spi_coverage锛氳鐩栫巼鏀堕泦鍣?
杩炴帴 Monitor 鐨勫垎鏋愮鍙ｅ埌瑕嗙洊鐜囨敹闆嗗櫒鐨?analysis_export銆?
娉ㄦ剰锛氭湰楠岃瘉骞冲彴娌℃湁鐙珛鐨?Scoreboard锛屾墍鏈夋鏌ュ潎鍦?Monitor 鍐呴儴閫氳繃鏂█鍜屽嵆鏃舵鏌ュ畬鎴愩€?
---

# **4. 娴嬭瘯鐐逛笌闇€姹?*

## **4.1 娴嬭瘯鐐圭煩闃?*

|   |   |   |   |
|---|---|---|---|
|**缂栧彿**|**娴嬭瘯鐐?*|**浼樺厛绾?*|**瑕嗙洊娴嬭瘯**|
|TP-01|鍐欏懡浠ゅ熀鏈姛鑳絴P0|smoke, all_modes, wr_rd|
|TP-02|璇诲懡浠ゅ熀鏈姛鑳斤紙鏃犳暟鎹級|P0|all_modes, wr_rd|
|TP-03|璇诲懡浠ゅ熀鏈姛鑳斤紙鏈夋暟鎹級|P0|all_modes, wr_rd|
|TP-04|璇绘暟鎹懡浠ゅ熀鏈姛鑳絴P0|all_modes|
|TP-05|CRC-8 鏍￠獙姝ｇ‘鎬P0|smoke, all_modes|
|TP-06|CRC 閿欒妫€娴嬩笌澶勭悊|P0|err|
|TP-07|瓒呮椂閿欒妫€娴嬩笌澶勭悊|P1|err|
|TP-08|鏃犳晥鍦板潃澶勭悊|P1|err|
|TP-09|鎻愬墠 CS 鎾ら攢澶勭悊|P1|err|
|TP-10|SPI Mode 0锛圕POL=0, CPHA=0锛墊P0|all_modes|
|TP-11|SPI Mode 1锛圕POL=0, CPHA=1锛墊P0|all_modes|
|TP-12|SPI Mode 2锛圕POL=1, CPHA=0锛墊P0|all_modes|
|TP-13|SPI Mode 3锛圕POL=1, CPHA=1锛墊P0|all_modes|
|TP-14|鏈€灏?payload锛? byte锛墊P1|boundary|
|TP-15|鏈€澶?payload锛?4 bytes锛墊P1|boundary|
|TP-16|闆跺湴鍧€|P2|boundary|
|TP-17|鏈€澶у湴鍧€锛?xFF锛墊P2|boundary|
|TP-18|鑳岄潬鑳岃繛缁紶杈搢P1|b2b|
|TP-19|FSM 鐘舵€佸叏瑕嗙洊|P0|regression|
|TP-20|FSM 鍚堟硶鐘舵€佽浆鎹㈠叏瑕嗙洊|P0|regression|
|TP-21|CRC 閿欒鍚?FSM 杩斿洖 IDLE|P0|err|
|TP-22|瓒呮椂閿欒鍚?FSM 杩斿洖 IDLE|P0|err|
|TP-23|CRC 涓庤秴鏃堕敊璇簰鏂P1|err|
|TP-24|淇″彿瀹屾暣鎬э紙鏃?X/Z锛墊P1|all|
|TP-25|RX FIFO 婊＄姸鎬佸鐞唡P2|b2b|
|TP-26|涓昏澶囨垚鍔熷搷搴攟P0|smoke, wr_rd|
|TP-27|涓昏澶囧け璐ュ搷搴攟P1|all_modes|

## **4.2 瑕嗙洊鐜囩洰鏍?*

|   |   |   |
|---|---|---|
|**瑕嗙洊鐜囩被鍨?*|**鐩爣**|**璇存槑**|
|FSM 鐘舵€佽鐩栫巼|100%|鍏ㄩ儴 8 涓姸鎬佸潎琚闂畖
|SPI 妯″紡瑕嗙洊鐜噟100%|鍏ㄩ儴 4 绉?CPOL/CPHA 缁勫悎|
|閿欒鏍囧織瑕嗙洊鐜噟100%|姣忎釜閿欒鏍囧織鑷冲皯瑙﹀彂涓€娆
|鍛戒护绫诲瀷瑕嗙洊鐜噟100%|Write銆丷ead銆丷eadData 鍛戒护|
|FIFO 瑕嗙洊鐜噟100%|TX/RX FIFO 璇诲啓鍧囪楠岃瘉|
|杈圭晫瑕嗙洊鐜噟100%|瀛楄妭鏁伴檺鍒躲€佹暟鎹暱搴﹁竟鐣寍
|Payload 闀垮害瑕嗙洊鐜噟100%|5 涓尯闂达紙min/short/medium/long/max锛墊
|鍦板潃瑕嗙洊鐜噟100%|浣庡湴鍧€鍜岄珮鍦板潃鍖洪棿|

## **4.3 SVA 鏂█妫€鏌ユ竻鍗?*

|   |   |   |
|---|---|---|
|**ID**|**鏂█鎻忚堪**|**妫€鏌ュ唴瀹?*|
|A1|澶嶄綅鍚庣姸鎬佹鏌澶嶄綅閲婃斁鍚?FSM 杩涘叆 IDLE|
|A2|IDLE 瓒呮椂妫€鏌IDLE 鐘舵€佷笅涓嶅彂鐢熻秴鏃堕敊璇瘄
|A3|鐘舵€佺爜鑼冨洿妫€鏌鐘舵€佺爜鍦ㄥ悎娉曡寖鍥?0-7 鍐厊
|A4|鏈夋晥淇″彿 X/Z 妫€鏌state_code_vld 鏃?X/Z|
|A5|閿欒淇″彿 X/Z 妫€鏌鎵€鏈夐敊璇緭鍑烘棤 X/Z|
|A6|FSM 杞崲鍚堟硶鎬鐘舵€佽浆鎹㈢鍚堝畾涔夌殑鐘舵€佸浘|
|A7|CRC 閿欒寮哄埗 IDLE|CRC 閿欒鍚庡己鍒惰繑鍥?IDLE|
|A8|瓒呮椂閿欒寮哄埗 IDLE|瓒呮椂閿欒鍚庡己鍒惰繑鍥?IDLE|
|A9|鍗曟璺宠浆妫€鏌FSM 姣忔鍙烦杞竴涓姸鎬亅
|A10|鐘舵€佺ǔ瀹氭鏌vld=0 鏃剁姸鎬佺爜淇濇寔绋冲畾|
|A11|閿欒浜掓枼妫€鏌CRC 閿欒鍜岃秴鏃堕敊璇笉鍚屾椂鍙戠敓|
|A12|CS 淇濇寔妫€鏌甯т紶杈撴湡闂?CS 淇濇寔鏈夋晥|
|A13|澶嶄綅鍒濆鍖栨鏌澶嶄綅鏈熼棿淇″彿姝ｇ‘鍒濆鍖東

---

# **5. 娴嬭瘯鐢ㄤ緥璇︾粏璇存槑**

## **5.1 娴嬭瘯鐢ㄤ緥鎬昏**

|   |   |   |   |
|---|---|---|---|
|**娴嬭瘯鍚嶇О**|**娴嬭瘯绫?*|**浣跨敤搴忓垪**|**璇存槑**|
|spi_smoke_test|spi_smoke_test|spi_write_seq 脳5|鍩虹鍐欐搷浣滃啋鐑熸祴璇晐
|spi_all_modes_test|spi_all_modes_test|spi_mixed_seq 脳10|鍏?SPI 妯″紡娣峰悎鍛戒护娴嬭瘯|
|spi_err_test|spi_err_test|spi_write_seq 脳3 + spi_err_inject_seq|閿欒娉ㄥ叆娴嬭瘯|
|spi_wr_rd_test|spi_wr_rd_test|spi_write_seq 脳3 + spi_read_seq 脳3|鍐欏悗璇绘祴璇晐
|spi_boundary_test|spi_boundary_test|spi_boundary_seq|杈圭晫鏉′欢娴嬭瘯|
|spi_b2b_test|spi_b2b_test|spi_b2b_seq 脳10|鑳岄潬鑳屼紶杈撴祴璇晐
|spi_regression_test|spi_regression_test|spi_write_seq 脳10 + spi_read_seq 脳10 + spi_err_inject_seq + spi_boundary_seq|瀹屾暣鍥炲綊娴嬭瘯|

## **5.2 spi_smoke_test锛堝啋鐑熸祴璇曪級**

鐩殑锛氶獙璇佸熀鏈殑鍐欐搷浣滃姛鑳斤紝纭楠岃瘉鐜鎼缓姝ｇ‘銆?
娴嬭瘯娴佺▼锛?
1. 鍒涘缓 spi_config锛屼娇鐢ㄩ粯璁ら厤缃紙slv_en=1, cs_act_pol=0锛?
2. 鎵ц spi_write_seq锛岀敓鎴?5 涓啓鍛戒护浜嬪姟

3. 姣忎釜浜嬪姟鍖呭惈闅忔満 payload锛?-64 bytes锛?
4. 楠岃瘉 DUT 姝ｇ‘鎺ユ敹鏁版嵁骞跺啓鍏?RX FIFO

棰勬湡缁撴灉锛?
路聽鎵€鏈?5 涓啓浜嬪姟鎴愬姛瀹屾垚

路聽鏃?CRC 閿欒

路聽Monitor 鏃?uvm_error 鎶ュ憡

路聽FSM 姝ｅ父缁忓巻 IDLE 鈫?WRITE_CMD 鈫?WAIT_WRITE_CONFIRM 鈫?IDLE 杞崲

瑕嗙洊娴嬭瘯鐐癸細TP-01, TP-05, TP-10, TP-24, TP-26

---

## **5.3 spi_all_modes_test锛堝叏妯″紡娴嬭瘯锛?*

鐩殑锛氶獙璇?DUT 鍦ㄦ墍鏈?4 绉?SPI 妯″紡涓嬫纭鐞嗗悇绉嶅懡浠ょ被鍨嬨€?
娴嬭瘯娴佺▼锛?
1. 鍒涘缓 spi_config锛岄殢鏈哄寲 CPOL 鍜?CPHA

2. 鎵ц spi_mixed_seq锛岀敓鎴?10 涓殢鏈虹被鍨嬩簨鍔?
3. 浜嬪姟绫诲瀷闅忔満閫夋嫨锛歐R_CMD銆丷D_CMD銆丷D_DATA_CMD

4. 姣忔浠跨湡瑕嗙洊涓嶅悓鐨?SPI 妯″紡缁勫悎

棰勬湡缁撴灉锛?
路聽鎵€鏈変簨鍔″湪瀵瑰簲 SPI 妯″紡涓嬫纭畬鎴?
路聽MISO 鏁版嵁閲囨牱姝ｇ‘

路聽CRC 鏍￠獙閫氳繃

路聽FSM 鐘舵€佽浆鎹㈡纭?
瑕嗙洊娴嬭瘯鐐癸細TP-01 ~ TP-05, TP-10 ~ TP-13, TP-24, TP-26

---

## **5.4 spi_err_test锛堥敊璇敞鍏ユ祴璇曪級**

鐩殑锛氶獙璇?DUT 瀵瑰悇绫婚敊璇殑妫€娴嬪拰澶勭悊鑳藉姏銆?
娴嬭瘯娴佺▼锛?
1. 鍏堟墽琛?spi_write_seq 脳3 浣滀负鐑韩锛岀‘淇?DUT 姝ｅ父宸ヤ綔

2. 鎵ц spi_err_inject_seq锛屾敞鍏ヤ互涓嬮敊璇細

|   |   |   |
|---|---|---|
|**閿欒绫诲瀷**|**鏁伴噺**|**娉ㄥ叆鏂瑰紡**|
|CRC 閿欒|3|灏?CRC 瀛楄妭鎸変綅鍙栧弽|
|鏃犳晥鍦板潃|3|璁剧疆 addr_l = 0x00|
|鎻愬墠 CS 鎾ら攢|3|鍦?payload 浼犺緭涓€旀挙閿€ CS|

棰勬湡缁撴灉锛?
路聽CRC 閿欒锛欴UT 妫€娴嬪埌 cmd_crc8_err锛孎SM 鍦?20 涓懆鏈熷唴杩斿洖 IDLE

路聽鏃犳晥鍦板潃锛欴UT 妫€娴嬪埌 loc_rw_err

路聽鎻愬墠 CS 鎾ら攢锛欴UT 妫€娴嬪埌鐩稿簲閿欒鏍囧織

路聽鐑韩闃舵鏃犻敊璇?
路聽CRC 閿欒涓庤秴鏃堕敊璇笉鍚屾椂鍙戠敓

瑕嗙洊娴嬭瘯鐐癸細TP-06, TP-08, TP-09, TP-21, TP-23, TP-24

---

## **5.5 spi_wr_rd_test锛堝啓鍚庤娴嬭瘯锛?*

鐩殑锛氶獙璇佸啓鎿嶄綔鍚庤鎿嶄綔鐨勬纭€э紝妯℃嫙瀹為檯浣跨敤鍦烘櫙銆?
娴嬭瘯娴佺▼锛?
1. 鎵ц spi_write_seq 脳3锛屽啓鍏ユ暟鎹埌 DUT

2. 鎵ц spi_read_seq 脳3锛屼粠 DUT 璇诲彇鏁版嵁

3. 楠岃瘉璇诲啓鎿嶄綔鐨勭嫭绔嬫€у拰姝ｇ‘鎬?
棰勬湡缁撴灉锛?
路聽鍐欎簨鍔℃垚鍔熷畬鎴愶紝鏁版嵁鍐欏叆 RX FIFO

路聽璇讳簨鍔℃垚鍔熷畬鎴愶紝鏁版嵁浠?TX FIFO 璇诲嚭

路聽FSM 姝ｇ‘缁忓巻鍐欒矾寰勫拰璇昏矾寰勭殑鐘舵€佽浆鎹?
路聽璇诲啓鎿嶄綔涔嬮棿鏃犲共鎵?
瑕嗙洊娴嬭瘯鐐癸細TP-01, TP-02, TP-03, TP-05, TP-26

---

## **5.6 spi_boundary_test锛堣竟鐣屾祴璇曪級**

鐩殑锛氶獙璇?DUT 鍦ㄨ竟鐣屾潯浠朵笅鐨勮涓恒€?
娴嬭瘯娴佺▼锛?
鎵ц spi_boundary_seq锛岃鐩栦互涓嬭竟鐣屽満鏅細

|   |   |   |
|---|---|---|
|**鍦烘櫙**|**鍙傛暟**|**璇存槑**|
|鏈€灏?payload|data_len = 1|1 瀛楄妭 payload|
|鏈€澶?payload|data_len = 64|64 瀛楄妭 payload|
|闆跺湴鍧€|addr_l = 0x00|鍦板潃涓嬬晫|
|鏈€澶у湴鍧€|addr_l = 0xFF|鍦板潃涓婄晫|

棰勬湡缁撴灉锛?
路聽鎵€鏈夎竟鐣屼簨鍔℃纭畬鎴?
路聽甯ч暱搴﹁绠楁纭?
路聽CRC 鏍￠獙姝ｇ‘

路聽鏃犳孩鍑烘垨鎴柇

瑕嗙洊娴嬭瘯鐐癸細TP-14, TP-15, TP-16, TP-17

---

## **5.7 spi_b2b_test锛堣儗闈犺儗娴嬭瘯锛?*

鐩殑锛氶獙璇佽繛缁棤闂撮殧浼犺緭鐨勫彲闈犳€с€?
娴嬭瘯娴佺▼锛?
1. 鎵ц spi_b2b_seq 脳10

2. 姣忎釜搴忓垪鐢熸垚杩炵画鐨勫啓鍛戒护锛屽抚闂存棤浠讳綍寤惰繜

3. CS 鎾ら攢鍚庣珛鍗宠繘琛屼笅涓€娆?CS 鏈夋晥

棰勬湡缁撴灉锛?
路聽鎵€鏈夎儗闈犺儗浜嬪姟姝ｇ‘瀹屾垚

路聽DUT 鑳藉姝ｇ‘澶勭悊杩炵画浼犺緭

路聽FIFO 鐘舵€佹纭洿鏂?
路聽鏃犳暟鎹涪澶辨垨瑕嗙洊

瑕嗙洊娴嬭瘯鐐癸細TP-18, TP-25

---

## **5.8 spi_regression_test锛堝洖褰掓祴璇曪級**

鐩殑锛氬叏闈㈠洖褰掗獙璇侊紝瑕嗙洊鎵€鏈夊姛鑳界偣銆?
娴嬭瘯娴佺▼锛?
鍒?4 涓樁娈垫墽琛岋細

|   |   |   |   |
|---|---|---|---|
|**闃舵**|**搴忓垪**|**鏁伴噺**|**璇存槑**|
|1|spi_write_seq|10|鍐欐搷浣滈獙璇亅
|2|spi_read_seq|10|璇绘搷浣滈獙璇亅
|3|spi_err_inject_seq|1|閿欒娉ㄥ叆楠岃瘉|
|4|spi_boundary_seq|1|杈圭晫鏉′欢楠岃瘉|

棰勬湡缁撴灉锛?
路聽鎵€鏈夐樁娈甸€氳繃

路聽瑕嗙洊鐜囪揪鏍囷紙瑙?4.2 鑺傝鐩栫巼鐩爣锛?
路聽鏃?uvm_error 鎶ュ憡

路聽SVA 鏂█鍏ㄩ儴閫氳繃

瑕嗙洊娴嬭瘯鐐癸細鍏ㄩ儴娴嬭瘯鐐?TP-01 ~ TP-27

---

# **6. 浠跨湡杩愯鎸囧崡**

## **6.1 鐜瑕佹眰**

路聽浠跨湡鍣細Xcelium / VCS / Questa

路聽SystemVerilog 鏀寔

路聽UVM 1.2 搴?
## **6.2 杩愯鍛戒护**

### **Xcelium**

# 缂栬瘧  
make comp  
  
# 杩愯鎸囧畾娴嬭瘯  
make sim TEST=spi_smoke_test SEED=random  
  
# 杩愯鍥炲綊娴嬭瘯  
make sim TEST=spi_regression_test SEED=random  
  
# 鏌ョ湅娉㈠舰  
make waves

### **VCS**

# 缂栬瘧  
make comp SIM=vcs  
  
# 杩愯  
make sim SIM=vcs TEST=spi_smoke_test SEED=random

### **Questa**

# 缂栬瘧  
make comp SIM=questa  
  
# 杩愯  
make sim SIM=questa TEST=spi_smoke_test SEED=random

## **6.3 Plusarg 鍙傛暟**

|   |   |   |
|---|---|---|
|**鍙傛暟**|**璇存槑**|**绀轰緥**|
|+UVM_TESTNAME|鎸囧畾娴嬭瘯鍚峾+UVM_TESTNAME=spi_smoke_test|
|+UVM_VERBOSITY|鏃ュ織绾у埆|+UVM_VERBOSITY=UVM_HIGH|
|+num_txns|浜嬪姟鏁伴噺|+num_txns=100|
|+sck_period_ns|SPI 鏃堕挓鍛ㄦ湡|+sck_period_ns=3.0|

---

# **7. 闄勫綍**

## **7.1 鏂囦欢娓呭崟**

|   |   |
|---|---|
|**鏂囦欢璺緞**|**璇存槑**|
|spi_slave_pkg.svh|UVM 鍖呭ご鏂囦欢锛屽寘鍚墍鏈夌粍浠秥
|spi_slave_intf.sv|SPI 鎬荤嚎鎺ュ彛瀹氫箟|
|test_plan.md|娴嬭瘯璁″垝鏂囨。|
|Makefile|浠跨湡鏋勫缓鑴氭湰|
|filelist.f|缂栬瘧鏂囦欢鍒楄〃|
|seq_item/spi_config.sv|閰嶇疆瀵硅薄|
|seq_item/spi_transaction.sv|浜嬪姟椤箌
|sequences/spi_sequences.sv|鎵€鏈夊簭鍒楃被|
|driver/spi_driver.sv|椹卞姩鍣▅
|monitor/spi_monitor.sv|鐩戞祴鍣▅
|coverage/spi_coverage.sv|瑕嗙洊鐜囨敹闆嗗櫒|
|agent/spi_agent.sv|浠ｇ悊|
|env/spi_env.sv|鐜|
|test/spi_tests.sv|娴嬭瘯绫粅
|top/tb_top.sv|椤跺眰娴嬭瘯骞冲彴|
|rtl_models/*.sv|DUT 瀛愭ā鍧楄涓烘ā鍨媩

## **7.2 淇璁板綍**

|   |   |   |
|---|---|---|
|**鐗堟湰**|**鏃ユ湡**|**淇敼鍐呭**|
|V1.0|-|鍒濆鐗堟湰|
