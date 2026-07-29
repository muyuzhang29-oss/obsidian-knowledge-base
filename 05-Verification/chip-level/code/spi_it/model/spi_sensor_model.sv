// SPI sensor model (Verilog-2001 compatible)
//
// SPI(B) interface (to wrp internal master):
//   Write:  CS↓ DATA0..N  ───→ regfile       CS↑
//   Read:   CS↓ 先收 rd_len_plus1 字节→regfile, 再发 MISO→regfile 直到 CS↑
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
    forever #2.5 clk_osc = ~clk_osc;
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
  spi_slv_reg u_spi_slv(
    .i_clk      (clk_osc       ),
    .i_rstn     (rst_n         ),
    .sclk       (SCLK          ),
    .mosi       (MOSI          ),
    .cs_n       (CS_N          ),
    .miso       (MISO          ),
    .o_addr     (reg_addr      ),
    .o_wdata    (reg_wdata     ),
    .i_rdata    (reg_rdata     ),
    .o_wr       (reg_wr        ),
    .o_rd       (reg_rd        )
  );

  // ── register file (16K bytes) ──
  reg [7:0] slv_mem[16383:0];

  integer i;
  initial begin
    for(i=0; i<16384; i=i+1) slv_mem[i] = i[7:0];
  end

  // ── read path ──
  reg [7:0]  reg_rd_d;
  reg [15:0] reg_rd_addr;

  always @(posedge clk_osc or negedge rst_n) begin
    if(!rst_n)
      reg_rdata <= 8'b0;
    else if(reg_rd)
      reg_rdata <= slv_mem[reg_addr];
  end

  always @(posedge clk_osc or negedge rst_n) begin
    if(!rst_n) begin
      reg_rd_d    <= 1'b0;
      reg_rd_addr <= 16'b0;
    end else begin
      reg_rd_d    <= reg_rd;
      if(reg_rd) reg_rd_addr <= reg_addr;
    end
  end

  always @(posedge clk_osc or negedge rst_n) begin
    if(!rst_n) ;
    else if(reg_rd_d)
      $display("%10t: %m-(8'h%02x) register(8'h%04x) Tx_Data:8'h%02x",
               $time, DEV_ID1, reg_rd_addr, reg_rdata);
  end

  // ── write path ──
  always @(posedge clk_osc) begin
    if(reg_wr) begin
      slv_mem[reg_addr] <= reg_wdata;
      $display("%10t: %m-(8'h%02x) register(8'h%04x) Rx_Data:8'h%02x",
               $time, DEV_ID1, reg_addr, reg_wdata);
    end
  end

  // ── wrapper tasks (delegate to spi_slv_reg) ──
  task set_write_mode(input [15:0] addr);
    u_spi_slv.set_write_mode(addr);
  endtask

  task set_read_mode(input [15:0] addr, input [15:0] rd_len_plus1);
    u_spi_slv.set_read_mode(addr, rd_len_plus1);
  endtask

  task set_mode(input ci, input cpha_i);
    u_spi_slv.set_mode(ci, cpha_i);
  endtask

  task set_cs_active(input v);
    u_spi_slv.set_cs_active(v);
  endtask

  task set_wr_interval(input [15:0] n);
    u_spi_slv.set_wr_interval(n);
  endtask

  // ── 暴露数据给 test 层做断言 ──
  task read_reg(input [15:0] addr, output [7:0] data);
    data = slv_mem[addr];
  endtask

  task read_burst(input [15:0] addr, output [7:0] data[], input int len);
    data = new[len];
    for (int j = 0; j < len; j = j + 1)
      data[j] = slv_mem[addr + j];
  endtask

endmodule
