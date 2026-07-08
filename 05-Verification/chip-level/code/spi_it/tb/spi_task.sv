// 初始化：配 SPIM + SPIS 工作参数
task spi_init(
  input cpol, cpha,
  input [7:0] sck_low, sck_high, ss_dly
);
  cpu_wr_reg(6'h00, {3'b0, 1'b0, cpha, cpol}); // SPIS_CFG0
  cpu_wr_reg(6'h01, 8'h01);   // SPIS_CFG1
  cpu_wr_reg(6'h02, 8'b0000_0100); // SPIS_CFG2
  cpu_wr_reg(6'h10, {cpol, cpha, 4'b0, 1'b0}); // SPIM_CFG0
  cpu_wr_reg(6'h11, sck_low);  // SPIM_CFG1
  cpu_wr_reg(6'h12, sck_high); // SPIM_CFG2
  cpu_wr_reg(6'h13, ss_dly);   // SPIM_CFG3
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
  cpu_rd_reg(6'h08, spis_cnt); // SPIS_MNT2
  cpu_rd_reg(6'h19, spim_cnt); // SPIM_MNT2
endtask

// CRC 模式配置（模拟 I2C 写 top 层级寄存器）
task spi_set_crc_mode(input bit use_crc16);
  u_soc.set_crc_mode(use_crc16);
endtask
