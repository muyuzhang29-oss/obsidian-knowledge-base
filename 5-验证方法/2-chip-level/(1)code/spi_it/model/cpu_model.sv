module cpu_model (
  input  wire        clk_reg,
  input  wire        rst_reg_n,
  output reg  [5:0]  reg_addr,
  output reg  [7:0]  reg_wr_data,
  output reg         reg_wren,
  output reg         reg_rden,
  input  wire [7:0]  reg_rd_data
);

  task cpu_wr_reg(input [5:0] addr, input [7:0] data);
    @(posedge clk_reg);
    reg_addr   = addr;
    reg_wr_data = data;
    reg_wren   = 1;
    @(posedge clk_reg);
    reg_wren   = 0;
    reg_addr   = 6'h0;
    reg_wr_data = 8'h0;
  endtask

  task cpu_rd_reg(input [5:0] addr, output [7:0] data);
    @(posedge clk_reg);
    reg_addr   = addr;
    reg_rden   = 1;
    @(posedge clk_reg);
    data       = reg_rd_data;
    reg_rden   = 0;
    reg_addr   = 6'h0;
  endtask

endmodule
