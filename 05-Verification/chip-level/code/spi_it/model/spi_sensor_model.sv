// SPI sensor model — follows i2c_sensor_model pattern
//
// SPI(B) interface (to wrp internal master):
//   Write:  CS↓ DATA0..N  ───→ regfile       CS↑
//   Read:   CS↓ 先收 rd_len_plus1 字节→regfile, 再发 MISO→regfile 直到 CS↑
//          CS↓ rd_len_plus1=0 时, 直接发 MISO 直到 CS↑
//
// Architecture:
//   spi_slv_reg  ←SPI pins→  decodes protocol, outputs reg bus
//        ↓ o_addr/o_wdata/o_wr/o_rd / i_rdata
//   slv_mem[16383:0]  ←寄存器文件

module spi_sensor_model #(parameter DEV_ID1 = 7'h0A)(
  input  wire    SCLK,
  input  wire    MOSI,
  output wire    MISO,
  input  wire    CS_N
);

  // ── internal clock & reset ──
  reg clk_osc;
  reg rst_n;

  initial begin
    clk_osc = 0;
    #50000;
    forever #20 clk_osc = ~clk_osc;
  end

  initial begin
    rst_n = 0;
    #51000;
    rst_n = 1;
  end

  // ── register bus (to/from spi_slv_reg) ──
  wire [15:0] reg_addr;
  wire [7:0]  reg_wdata;
  reg  [7:0]  reg_rdata;
  wire        reg_wr;
  wire        reg_rd;

  // ── protocol decoder ──
  wire miso_from_slv;

  spi_slv_reg u_spi_slv(
    .i_clk      (clk_osc       ),
    .i_rstn     (rst_n         ),
    .sclk       (SCLK          ),
    .mosi       (MOSI          ),
    .cs_n       (CS_N          ),
    .miso       (miso_from_slv ),
    .o_addr     (reg_addr      ),
    .o_wdata    (reg_wdata     ),
    .i_rdata    (reg_rdata     ),
    .o_wr       (reg_wr        ),
    .o_rd       (reg_rd        )
  );

  buf BUFF_MISO(MISO, miso_from_slv);

  // ── register file (16K bytes) ──
  reg [7:0] slv_mem[16383:0];

  integer i;
  initial begin
    for(i=0; i<16384; i=i+1) slv_mem[i] = 8'h0;
  end

  // ── read path ──
  reg [7:0] reg_rd_d;

  always @(posedge clk_osc or negedge rst_n) begin
    if(!rst_n)
      reg_rdata <= 8'b0;
    else if(reg_rd)
      reg_rdata <= slv_mem[reg_addr];
  end

  always @(posedge clk_osc or negedge rst_n) begin
    if(!rst_n)
      reg_rd_d <= 8'b0;
    else
      reg_rd_d <= reg_rd;
  end

  always @(posedge clk_osc or negedge rst_n) begin
    if(!rst_n) ;
    else if(reg_rd_d)
      $display("%10t: %m-(8'h%02x) register(8'h%04x) Tx_Data:8'h%02x",
               $time, DEV_ID1, reg_addr, reg_rdata);
  end

  // ── write path ──
  always @(posedge clk_osc) begin
    if(reg_wr) begin
      slv_mem[reg_addr] <= reg_wdata;
      $display("%10t: %m-(8'h%02x) register(8'h%04x) Rx_Data:8'h%02x",
               $time, DEV_ID1, reg_addr, reg_wdata);
    end
  end

endmodule
