`include "tb_define.v"
`include "tb_include.sv"

module tb_spi;

  reg clk_spi, clk_lf, clk_reg, rst_n;
  initial clk_spi = 0; always #1.5 clk_spi = ~clk_spi;
  initial clk_lf  = 0; always #5   clk_lf  = ~clk_lf;
  initial clk_reg = 0; always #20  clk_reg = ~clk_reg;
  initial begin rst_n = 0; #100 rst_n = 1; end

  // ========================================
  // I2C 总线（外部 MCU 通过 I2C 配 SS12 寄存器）
  // 使用 I2C_IT 的 i2c_master_model（含 PMBus 协议栈）
  // 文件依赖: i2c_master_model.v + apb_master_model.v + pmb_* + std cells
  // ========================================
  wire i2c_scl, i2c_sda;

  i2c_master_model u_ext_i2c_mst (
    .SDA (i2c_sda),
    .SCL (i2c_scl)
  );
  // u_ext_i2c_mst 内部产生独立 clk/rst_n
  // u_ext_i2c_mst 的 APB 接口通过 spi_task.sv 中的 ext_apb_wr 驱动

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
  // SPI(B) sensor model — 新接口只剩 SCLK/MOSI/MISO/CS_N
  // ========================================
  wire sclk, mosi, miso, cs_n;
  pullup (weak1) pull_miso (miso);

  spi_sensor_model u_sensor (
    .SCLK (sclk),
    .MOSI (mosi),
    .MISO (miso),
    .CS_N (cs_n)
  );

  // ========================================
  // DUT: SS12 (含 I2C Slave) + 4×SS11
  // 按实际顶层 module 名和 port 名替换
  // ========================================
  SS12_CHP u_ss12 (
    // I2C 引脚 (接外部 master)
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
    // 其他
    .clk_sys      (clk_reg),
    .clk_ica_lf   (clk_lf),
    .rst_sys_n    (rst_n)
  );

  initial begin
    #200; @(posedge rst_n); #100;
    run_test("spi_write_test");
  end

endmodule
