`include "tb_define.v"
`include "tb_include.sv"

module tb_spi;

  reg clk_spi, clk_lf, clk_reg, rst_n;
  initial clk_spi = 0; always #1.5 clk_spi = ~clk_spi;
  initial clk_lf  = 0; always #5   clk_lf  = ~clk_lf;
  initial clk_reg = 0; always #20  clk_reg = ~clk_reg;
  initial begin rst_n = 0; #100 rst_n = 1; end

  // I2C bus (top-level)
  wire i2c_scl, i2c_sda;

  // DUT register interface (driven by I2C slave → DUT spi_wrp)
  wire [5:0] reg_addr;
  wire [7:0] reg_wr_data, reg_rd_data;
  wire reg_wren, reg_rden;

  // SPI pins to sensor
  wire sclk, mosi, miso, cs_n;

  // SOC FIFO interface
  wire [7:0] soc_tx_dat, soc_rx_dat;
  wire soc_tx_vld, soc_tx_rdy, soc_rx_vld, soc_rx_rdy;

  // I2C Master: 模拟外部 MCU 通过 I2C 配 SS12 寄存器
  i2c_master_model #(.SCL_HALF(50)) u_i2c_mst (
    .scl (i2c_scl),
    .sda (i2c_sda)
  );

  // I2C Slave 占位: 模拟 SS12 内部 I2C Slave + 寄存器桥
  // DUT RTL 到位后替换为 u_dut.i2c_slv
  i2c_slv_model #(.SLAVE_ADDR(7'h30)) u_i2c_slv (
    .clk          (clk_reg),
    .rst_n        (rst_n),
    .scl          (i2c_scl),
    .sda          (i2c_sda),
    .reg_addr     (reg_addr),
    .reg_wr_data  (reg_wr_data),
    .reg_wren     (reg_wren),
    .reg_rden     (reg_rden),
    .reg_rd_data  (reg_rd_data)
  );

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

  // DUT: spi_wrp + ROUTE + PAL（DE 提供，此处为占位）
  // spi_wrp u_dut (
  //   .clk_spi      (clk_spi),
  //   .clk_reg      (clk_reg),
  //   .rst_n        (rst_n),
  //   // reg 接口（来自 I2C Slave → 内部总线桥）
  //   .reg_addr     (reg_addr),
  //   .reg_wr_data  (reg_wr_data),
  //   .reg_wren     (reg_wren),
  //   .reg_rden     (reg_rden),
  //   .reg_rd_data  (reg_rd_data),
  //   // SPI 引脚（接 sensor 模型）
  //   .sclk         (sclk),
  //   .mosi         (mosi),
  //   .cs_n         (cs_n),
  //   .miso         (miso),
  //   // SOC FIFO（接 soc_model）
  //   .soc_tx_dat   (soc_tx_dat),
  //   .soc_tx_vld   (soc_tx_vld),
  //   .soc_tx_rdy   (soc_tx_rdy),
  //   .soc_rx_dat   (soc_rx_dat),
  //   .soc_rx_vld   (soc_rx_vld),
  //   .soc_rx_rdy   (soc_rx_rdy)
  // );

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

  initial begin
    #200; @(posedge rst_n); #100;
  end

endmodule
