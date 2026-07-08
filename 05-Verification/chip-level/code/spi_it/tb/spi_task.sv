// I2C Slave 地址 (与 DUT i2cs 的 i_native_dev 一致)
`define I2C_SLV_ADDR 7'h30

// SPI 内部寄存器在 I2C 地址空间中的基地址 (16-bit)
`define SPI_REG_BASE 16'h0000

// 初始化：通过 I2C 配 SPIM + SPIS 工作参数
task spi_init(
  input cpol, cpha,
  input [7:0] sck_low, sck_high, ss_dly
);
  u_i2c_mst.i2c_wr_reg16(`I2C_SLV_ADDR, `SPI_REG_BASE + 16'h0000,
    {3'b0, 1'b0, cpha, cpol}); // SPIS_CFG0
  u_i2c_mst.i2c_wr_reg16(`I2C_SLV_ADDR, `SPI_REG_BASE + 16'h0001, 8'h01); // SPIS_CFG1
  u_i2c_mst.i2c_wr_reg16(`I2C_SLV_ADDR, `SPI_REG_BASE + 16'h0002,
    8'b0000_0100); // SPIS_CFG2
  u_i2c_mst.i2c_wr_reg16(`I2C_SLV_ADDR, `SPI_REG_BASE + 16'h0010,
    {cpol, cpha, 4'b0, 1'b0}); // SPIM_CFG0
  u_i2c_mst.i2c_wr_reg16(`I2C_SLV_ADDR, `SPI_REG_BASE + 16'h0011, sck_low); // SPIM_CFG1
  u_i2c_mst.i2c_wr_reg16(`I2C_SLV_ADDR, `SPI_REG_BASE + 16'h0012, sck_high); // SPIM_CFG2
  u_i2c_mst.i2c_wr_reg16(`I2C_SLV_ADDR, `SPI_REG_BASE + 16'h0013, ss_dly); // SPIM_CFG3
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
  u_i2c_mst.i2c_rd_reg16(`I2C_SLV_ADDR, `SPI_REG_BASE + 16'h0008, spis_cnt); // SPIS_MNT2
  u_i2c_mst.i2c_rd_reg16(`I2C_SLV_ADDR, `SPI_REG_BASE + 16'h0019, spim_cnt); // SPIM_MNT2
endtask

// CRC 模式配置 (TB 侧 soc_model 的 CRC 生成，模拟 top 寄存器)
task spi_set_crc_mode(input bit use_crc16);
  u_soc.set_crc_mode(use_crc16);
endtask
