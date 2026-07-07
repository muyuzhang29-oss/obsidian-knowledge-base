`include "tb_define.v"
`include "tb_include.sv"

module tb_spi;

  reg clk_spi, clk_lf, clk_reg, rst_n;
  initial clk_spi = 0; always #1.5 clk_spi = ~clk_spi;
  initial clk_lf  = 0; always #5   clk_lf  = ~clk_lf;
  initial clk_reg = 0; always #20  clk_reg = ~clk_reg;
  initial begin rst_n = 0; #100 rst_n = 1; end

  wire [5:0] reg_addr;
  wire [7:0] reg_wr_data, reg_rd_data;
  wire reg_wren, reg_rden;
  wire sclk, mosi, miso, cs_n;
  wire [7:0] soc_tx_dat, soc_rx_dat;
  wire soc_tx_vld, soc_tx_rdy, soc_rx_vld, soc_rx_rdy;

  cpu_model u_cpu (.*);
  soc_model u_soc (
    .clk         (clk_spi), .rst_n (rst_n),
    .soc_tx_dat  (soc_tx_dat), .soc_tx_vld (soc_tx_vld),
    .soc_tx_rdy  (soc_tx_rdy), .soc_rx_dat (soc_rx_dat),
    .soc_rx_vld  (soc_rx_vld), .soc_rx_rdy (soc_rx_rdy)
  );

  // DUT: spi_wrp + ROUTE + PAL（DE 提供，此处为占位）
  // spi_wrp u_dut ( ... );

  spi_sensor_model u_sensor (
    .clk (clk_spi), .rst_n (rst_n),
    .sclk (sclk), .mosi (mosi), .cs_n (cs_n), .miso (miso),
    .cpol (1'b0), .cpha (1'b0),
    .reg_wr_data (8'h00), .reg_wr_en (1'b0), .reg_wr_addr (17'h0)
  );

  initial begin
    #200; @(posedge rst_n); #100;
  end

endmodule
