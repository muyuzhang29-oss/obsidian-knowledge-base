// I2C Slave 地址（与 DUT i2cs 的 i_native_dev 一致）
`define I2C_SLV_ADDR 7'h30

// I2C_IT 外部 I2C Master 实例路径（由 tb_spi.sv 定义）
`define EXT_I2C_MST tb.u_ext_i2c_mst

// SPI 内部寄存器在 I2C 地址空间中的基地址 (16-bit)
`define SPI_REG_BASE 16'h0000

// Intel APB write (I2C_IT 风格)
task ext_apb_wr(input [11:0] addr, input [31:0] data);
  `EXT_I2C_MST.apb_wr(addr, data);
endtask

// 等待 PMBus command finish
task ext_i2c_finish;
  while((`EXT_I2C_MST.pmbus_int_st & (1<<17)) != (1<<17)) #2;
endtask

// 等待 TX FIFO empty，然后推一字节到 FIFO
task ext_i2c_wr_sub(input stop_flag, input dat_flag, input [7:0] din);
  while((`EXT_I2C_MST.pmbus_int_st & 27'h10) != 27'h10) #2;
  ext_apb_wr(12'h00c, {21'h0, stop_flag, dat_flag, 1'b0, din});
endtask

// 初始化 I2C Master（等效 ss12_host0_init）
task ext_i2c_init;
  ext_apb_wr(12'h010, 32'h0000bacf);
  ext_apb_wr(12'h014, 32'h13e833e8);
  ext_apb_wr(12'h020, 32'h00010002);
  ext_apb_wr(12'h018, 32'hffffffff);
  ext_apb_wr(12'h040, 32'h04240107);  // 1MHz
  ext_apb_wr(12'h044, 32'h000013e8);
  ext_apb_wr(12'h048, 32'h00000011);
endtask

// I2C single write (16-bit 寄存器地址)
task ext_i2c_wr_reg16(input [6:0] slv_addr, input [15:0] reg_addr, input [7:0] data);
  ext_i2c_wr_sub(1'b0, 1'b1, {slv_addr, 1'b0});  // START + ID+W
  ext_i2c_wr_sub(1'b0, 1'b0, reg_addr[15:8]);      // 寄存器地址高字节
  ext_i2c_wr_sub(1'b0, 1'b0, reg_addr[7:0]);       // 寄存器地址低字节
  ext_i2c_wr_sub(1'b1, 1'b0, data);                 // 数据 + STOP
  ext_i2c_finish;
  $display("%10t: EXT_I2C write reg[%04h] = %02h", $time, reg_addr, data);
endtask

// I2C single read (16-bit 寄存器地址)  — 需参考 I2C_IT 的 rx_host 任务定义
// TODO: 从 I2C_IT 复制 `rx_host`/`hostx_rd_reg` 等读任务，补充 RX FIFO 读取流程
task ext_i2c_rd_reg16(input [6:0] slv_addr, input [15:0] reg_addr, output [7:0] data);
  data = 8'h00;
  $error("%10t: EXT_I2C rd_reg16 not implemented — need read task from I2C_IT", $time);
endtask

// ============================================================
// SPI 任务（基于 I2C 配置路径）
// ============================================================
task spi_init(
  input cpol, cpha,
  input [7:0] sck_low, sck_high, ss_dly
);
  ext_i2c_wr_reg16(`I2C_SLV_ADDR, `SPI_REG_BASE + 16'h0000,
    {3'b0, 1'b0, cpha, cpol}); // SPIS_CFG0
  ext_i2c_wr_reg16(`I2C_SLV_ADDR, `SPI_REG_BASE + 16'h0001, 8'h01); // SPIS_CFG1
  ext_i2c_wr_reg16(`I2C_SLV_ADDR, `SPI_REG_BASE + 16'h0002,
    8'b0000_0100); // SPIS_CFG2
  ext_i2c_wr_reg16(`I2C_SLV_ADDR, `SPI_REG_BASE + 16'h0010,
    {cpol, cpha, 4'b0, 1'b0}); // SPIM_CFG0
  ext_i2c_wr_reg16(`I2C_SLV_ADDR, `SPI_REG_BASE + 16'h0011, sck_low); // SPIM_CFG1
  ext_i2c_wr_reg16(`I2C_SLV_ADDR, `SPI_REG_BASE + 16'h0012, sck_high); // SPIM_CFG2
  ext_i2c_wr_reg16(`I2C_SLV_ADDR, `SPI_REG_BASE + 16'h0013, ss_dly); // SPIM_CFG3
endtask

task spi_master_write(input [4:0] dst_port, input [16:0] dev_addr,
                      input [7:0] wr_data[], input [7:0] len);
  spi_frame_write(dst_port, dev_addr, wr_data, len);
endtask

task spi_master_read(input [4:0] dst_port, input [16:0] dev_addr,
                     input [6:0] rd_len, input [7:0] data_len,
                     output [7:0] rd_data[]);
  spi_frame_read_with_data(dst_port, dev_addr, rd_len, data_len, {});
  spi_frame_recv(rd_data, data_len);
endtask

task spi_check_timeout_err(output [7:0] spis_cnt, output [7:0] spim_cnt);
  ext_i2c_rd_reg16(`I2C_SLV_ADDR, `SPI_REG_BASE + 16'h0008, spis_cnt); // SPIS_MNT2
  ext_i2c_rd_reg16(`I2C_SLV_ADDR, `SPI_REG_BASE + 16'h0019, spim_cnt); // SPIM_MNT2
endtask

// CRC 模式配置 (TB 侧 soc_model 的 CRC 生成)
task spi_set_crc_mode(input bit use_crc16);
  u_soc.set_crc_mode(use_crc16);
endtask
