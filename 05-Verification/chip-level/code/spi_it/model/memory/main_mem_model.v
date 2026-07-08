module main_mem_model (
  input  wire        clk,
  input  wire        rst_n,
  input  wire        wr_en,
  input  [16:0]      wr_addr,
  input  [7:0]       wr_data,
  input  [16:0]      rd_addr,
  output reg [7:0]   rd_data
);

  reg [7:0] mem [0:131071];

  integer i;
  initial begin
    for (i = 0; i < 131072; i++) mem[i] = 8'h00;
  end

  always @(posedge clk) begin
    if (wr_en) mem[wr_addr] <= wr_data;
  end

  always @(*) begin
    rd_data = mem[rd_addr];
  end

endmodule
