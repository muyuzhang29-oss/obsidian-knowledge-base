// SPI(B) sensor — receives/stores or sources data per pre-configured mode
// Mode is set via testbench task before each SPI transaction:
//   set_write_mode(start_addr)  — subsequent SPI frame data → regfile
//   set_read_mode(start_addr, len, dummy) — SPI frame → regfile data on MISO

module spi_slv_reg (
  input               i_clk,
  input               i_rstn,
  input               sclk,
  input               mosi,
  input               cs_n,
  output  reg         miso,
  output  reg         bne,
  output  reg [15:0]  o_addr,
  output  reg [7:0]   o_wdata,
  input       [7:0]   i_rdata,
  output  reg         o_wr,
  output  reg         o_rd
);

  // ── configurable mode registers ──
  reg r_cpol;
  reg r_cpha;

  // ── SCLK/CS sync + edge detect ──
  reg r_scl_s1, r_scl_s2, r_scl_in, r_scl_d, r_scl_ris, r_scl_fal;
  reg r_cs_s1,  r_cs_s2,  r_cs_in,  r_cs_d,  r_cs_ris, r_cs_fal;

  always @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn) begin
      r_scl_s1 <= #1 1'b0; r_scl_s2 <= #1 1'b0;
      r_scl_in <= #1 1'b0; r_scl_d  <= #1 1'b0;
      r_scl_ris <= #1 1'b0; r_scl_fal <= #1 1'b0;
      r_cs_s1 <= #1 1'b1; r_cs_s2 <= #1 1'b1;
      r_cs_in <= #1 1'b1; r_cs_d  <= #1 1'b1;
      r_cs_ris <= #1 1'b0; r_cs_fal <= #1 1'b0;
    end else begin
      r_scl_s1 <= #1 sclk;      r_cs_s1 <= #1 cs_n;
      r_scl_s2 <= #1 r_scl_s1;  r_cs_s2 <= #1 r_cs_s1;
      r_scl_in <= #1 r_scl_s2;  r_cs_in <= #1 r_cs_s2;
      r_scl_d  <= #1 r_scl_in;  r_cs_d  <= #1 r_cs_in;
      r_scl_ris <= #1 ~r_scl_d &  r_scl_in;
      r_scl_fal <= #1  r_scl_d & ~r_scl_in;
      r_cs_ris  <= #1 ~r_cs_d  &  r_cs_in;
      r_cs_fal  <= #1  r_cs_d  & ~r_cs_in;
    end
  end

  // ── sample/drive edge (depends on CPOL/CPHA) ──
  wire w_sample = (r_cpha == r_cpol) ? r_scl_ris : r_scl_fal;
  wire w_drive  = (r_cpha == r_cpol) ? r_scl_fal : r_scl_ris;

  // ── bit counter (increments on sample edge) ──
  reg [3:0] r_bcnt, r_bcnt_d;
  wire w_end_byte = (r_bcnt_d==4'h8) && w_sample;

  always @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn) begin
      r_bcnt   <= #1 4'h0;
      r_bcnt_d <= #1 4'h0;
    end else if (r_cs_fal) begin
      r_bcnt   <= #1 4'h0;
      r_bcnt_d <= #1 4'h0;
    end else if (w_sample) begin
      r_bcnt   <= #1 (r_bcnt==4'h8) ? 4'h1 : r_bcnt + 4'h1;
      r_bcnt_d <= #1 r_bcnt;
    end
  end

  // ── config registers (set via tasks, not SPI) ──
  reg        r_wr_mode;       // 1=write, 0=read
  reg [15:0] r_start_addr;    // regfile start address
  reg [15:0] r_rd_len;        // read length (bytes)
  reg [7:0]  r_dummy;         // read dummy count

  // ── FSM ──
  localparam ST_IDLE  = 2'h0;
  localparam ST_WDATA = 2'h1;
  localparam ST_RDUM  = 2'h2;
  localparam ST_RDATA = 2'h3;

  reg [1:0] r_st, r_nx_st;

  always @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn) r_st <= #1 ST_IDLE;
    else         r_st <= #1 r_nx_st;
  end

  always @(*) begin
    case (r_st)
      ST_IDLE:  r_nx_st = r_cs_fal                    ? (r_wr_mode ? ST_WDATA : ST_RDUM) : ST_IDLE;
      ST_WDATA: r_nx_st = (r_cs_ris && r_bcnt==4'h0)  ? ST_IDLE   : ST_WDATA;
      ST_RDUM:  r_nx_st = (r_cs_ris && r_bcnt==4'h0)  ? ST_IDLE   : (r_dcnt >= r_dummy) ? ST_RDATA : ST_RDUM;
      ST_RDATA: r_nx_st = (r_cs_ris && r_bcnt==4'h0)  ? ST_IDLE   : (r_dcnt >= r_rd_len) ? ST_IDLE  : ST_RDATA;
      default:  r_nx_st = ST_IDLE;
    endcase
  end

  // ── datapath ──
  reg [7:0]  r_sr;              // MOSI shift register
  reg [15:0] r_dcnt;            // byte counter
  reg [7:0]  r_txsr;            // MISO shift register

  always @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn) begin
      r_sr    <= #1 8'h00;
      r_dcnt  <= #1 16'h0000;
      r_txsr  <= #1 8'h00;
      o_wr    <= #1 1'b0;
      o_wdata <= #1 8'h00;
      o_addr  <= #1 16'h0000;
      o_rd    <= #1 1'b0;
      bne     <= #1 1'b0;
    end else begin
      o_wr <= #1 1'b0;
      o_rd <= #1 1'b0;

      if (r_cs_fal) begin
        r_dcnt <= #1 16'h0000;
        bne    <= #1 1'b0;
      end

      if (r_cs_ris) begin
        if (r_st==ST_RDATA || r_st==ST_RDUM) bne <= #1 1'b1;
      end

      // ── sample edge: capture MOSI ──
      if (w_sample) begin
        r_sr <= #1 {r_sr[6:0], mosi};
        if (w_end_byte && r_st==ST_WDATA) begin
          o_wr    <= #1 1'b1;
          o_wdata <= #1 r_sr;
          o_addr  <= #1 r_start_addr + r_dcnt;
          r_dcnt  <= #1 r_dcnt + 16'h1;
        end
      end

      // ── drive edge: advance counters, drive MISO ──
      if (w_drive) begin
        if (r_st == ST_RDUM) begin
          if (r_dcnt < r_dummy) r_dcnt <= #1 r_dcnt + 16'h1;
        end else if (r_st == ST_RDATA) begin
          if (r_dcnt < r_rd_len) begin
            if (r_bcnt == 4'h1) begin               // first bit of new byte
              o_rd   <= #1 1'b1;
              o_addr <= #1 r_start_addr + r_dcnt;
              r_txsr <= #1 i_rdata;
            end else begin
              r_txsr <= #1 {r_txsr[6:0], 1'b0};
            end
          end
          if (r_bcnt == 4'h8) r_dcnt <= #1 r_dcnt + 16'h1;
        end
      end
    end
  end

  // ── MISO output ──
  always @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn) begin
      miso <= #1 1'bz;
    end else if (r_cs_in) begin
      miso <= #1 1'bz;
    end else if (r_st == ST_RDATA && r_dcnt < r_rd_len) begin
      miso <= #1 r_txsr[7];
    end else begin
      miso <= #1 1'bz;
    end
  end

  // ── test tasks ──
  task set_cpol(input v);    r_cpol <= #1 v; endtask
  task set_cpha(input v);    r_cpha <= #1 v; endtask

  task set_mode(input cpol_i, input cpha_i);
    r_cpol <= #1 cpol_i;
    r_cpha <= #1 cpha_i;
  endtask

  task set_write_mode(input [15:0] addr);
    r_wr_mode   <= #1 1'b1;
    r_start_addr <= #1 addr;
  endtask

  task set_read_mode(input [15:0] addr, input [15:0] len, input [7:0] dummy);
    r_wr_mode   <= #1 1'b0;
    r_start_addr <= #1 addr;
    r_rd_len    <= #1 len;
    r_dummy     <= #1 dummy;
  endtask

endmodule
