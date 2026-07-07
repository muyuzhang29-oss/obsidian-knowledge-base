module spi_sensor_model (
  input  wire        clk,
  input  wire        rst_n,
  input  wire        sclk,
  input  wire        mosi,
  input  wire        cs_n,
  output reg         miso,
  input  wire        cpol,
  input  wire        cpha,
  input  [7:0]      reg_wr_data,
  input             reg_wr_en,
  input  [16:0]     reg_wr_addr
);

  reg [7:0] mem[0:131071];
  integer i;
  initial begin
    for (i = 0; i < 131072; i++) mem[i] = 8'h00;
  end

  always @(posedge clk) begin
    if (reg_wr_en) mem[reg_wr_addr] <= reg_wr_data;
  end

  reg sclk_d1, sclk_d2, cs_n_d1, cs_n_d2;
  wire sclk_pos = sclk_d1 & ~sclk_d2;
  wire sclk_neg = ~sclk_d1 & sclk_d2;
  wire cs_start = cs_n_d1 & ~cs_n_d2;
  wire cs_end   = ~cs_n_d1 & cs_n_d2;

  always @(posedge clk) begin
    sclk_d1 <= sclk; sclk_d2 <= sclk_d1;
    cs_n_d1 <= cs_n; cs_n_d2 <= cs_n_d1;
  end

  wire sample_edge = (cpha == 0) ? sclk_pos : sclk_neg;
  wire drive_edge  = (cpha == 0) ? sclk_neg : sclk_pos;

  reg [3:0] bit_cnt;
  reg [7:0] shift_reg;

  always @(posedge clk) begin
    if (!rst_n) begin
      bit_cnt  <= 0;
      shift_reg <= 0;
      miso     <= 0;
    end else if (cs_start) begin
      bit_cnt  <= 0;
      shift_reg <= 0;
    end else if (cs_end) begin
      bit_cnt  <= 0;
    end else if (!cs_n) begin
      if (sample_edge) begin
        shift_reg <= {shift_reg[6:0], mosi};
        bit_cnt   <= bit_cnt + 1;
      end
      if (drive_edge) begin
        miso <= mem[{bit_cnt, 3'b0}][0];
      end
    end
  end

endmodule
