`include "tb_define.v"
`include "tb_include.sv"

module tb_spi;

  reg clk_spi, clk_lf, clk_reg, rst_n;
  initial clk_spi = 0; always #1.5 clk_spi = ~clk_spi;
  initial clk_lf  = 0; always #5   clk_lf  = ~clk_lf;
  initial clk_reg = 0; always #20  clk_reg = ~clk_reg;
  initial begin rst_n = 0; #100 rst_n = 1; end

  // ========================================
  // I2C bus (top-level, shared by all chips)
  // ========================================
  wire i2c_scl, i2c_sda;

  // I2C Master: 模拟外部 MCU，通过 I2C 配 SS12 + SS11
  i2c_master_model #(.SCL_HALF(50)) u_i2c_mst (
    .scl (i2c_scl),
    .sda (i2c_sda)
  );

  // ========================================
  // SOC FIFO interface
  // ========================================
  wire [7:0] soc_tx_dat, soc_rx_dat;
  wire soc_tx_vld, soc_tx_rdy, soc_rx_vld, soc_rx_rdy;

  soc_model u_soc (
    .clk         (clk_spi),
    .rst_n       (rst_n),
    .soc_tx_dat  (soc_tx_dat),
    .soc_tx_vld  (soc_tx_vld),
    .soc_tx_rdy  (soc_tx_rdy),
    .soc_rx_dat  (soc_rx_dat),
    .soc_rx_vld  (soc_rx_vld),
    .soc_rx_rdy  (soc_rx_rdy)
  );

  // ========================================
  // SPI sensor
  // ========================================
  wire sclk, mosi, miso, cs_n;

  spi_sensor_model u_sensor (
    .clk         (clk_spi),
    .rst_n       (rst_n),
    .sclk        (sclk),
    .mosi        (mosi),
    .cs_n        (cs_n),
    .miso        (miso),
    .cpol        (1'b0),
    .cpha        (1'b0),
    .reg_wr_data (8'h00),
    .reg_wr_en   (1'b0),
    .reg_wr_addr (17'h0)
  );

  // ========================================
  // DUT: SS12 (含 I2C Slave) + 4×SS11
  // 按实际顶层 module 名和 port 名替换
  // ========================================
  SS12_CHP u_ss12 (
    // I2C 引脚 (接 master)
    .i2c_scl      (i2c_scl),
    .i2c_sda      (i2c_sda),
    // SOC FIFO
    .soc_tx_dat   (soc_tx_dat),
    .soc_tx_vld   (soc_tx_vld),
    .soc_tx_rdy   (soc_tx_rdy),
    .soc_rx_dat   (soc_rx_dat),
    .soc_rx_vld   (soc_rx_vld),
    .soc_rx_rdy   (soc_rx_rdy),
    // SPI 引脚
    .sclk         (sclk),
    .mosi         (mosi),
    .miso         (miso),
    .cs_n         (cs_n),
    // 其他 (时钟、复位、4×SS11 coax 等)
    .clk_sys      (clk_reg),
    .clk_ica_lf   (clk_lf),
    .rst_sys_n    (rst_n)
  );

  initial begin
    #200; @(posedge rst_n); #100;
  end

endmodule
