// SPI(B) sensor — write/read per pre-configured mode
//   set_write_mode(addr)            — CS↓ DATA0..N → regfile[addr+N]
//   set_read_mode(addr, rd_len_plus1) — CS↓:
//       rd_len_plus1=0:  直接 MISO 发 regfile 数据直到 CS↑
//       rd_len_plus1=N:  先收 N 字节 MOSI→regfile, 再 MISO 直到 CS↑

module spi_slv_reg (
  input               i_clk,
  input               i_rstn,
  input               sclk,
  input               mosi,
  input               cs_n,
  output  reg         miso,
  output  reg [15:0]  o_addr,
  output  reg [7:0]   o_wdata,
  input       [7:0]   i_rdata,
  output  reg         o_wr,
  output  reg         o_rd
);

  // ── mode registers ──
  reg r_cpol, r_cpha;
  reg r_mode;                  // 0=write, 1=read
  reg [15:0] r_saddr;          // start address
  reg [15:0] r_rd_len_plus1;   // bytes to receive before MISO (0 = no pre-data)

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

  // ── sample/drive edge ──
  wire w_sample = (r_cpha == r_cpol) ? r_scl_ris : r_scl_fal;
  wire w_drive  = (r_cpha == r_cpol) ? r_scl_fal : r_scl_ris;

  // ── bit counter ──
  reg [3:0] r_bcnt;
  wire w_end_byte = (r_bcnt==4'h7) && w_sample;

  always @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn) begin
      r_bcnt <= #1 4'h0;
    end else if (r_cs_fal) begin
      r_bcnt <= #1 4'h0;
    end else if (w_sample) begin
      r_bcnt <= #1 (r_bcnt==4'h7) ? 4'h0 : r_bcnt + 4'h1;
    end
  end

  // ── FSM ──
  localparam ST_IDLE    = 3'h0;
  localparam ST_WDATA   = 3'h1;
  localparam ST_RECV    = 3'h2;   // read: receiving pre-data on MOSI
  localparam ST_SENDM   = 3'h3;   // read: sending MISO

  reg [2:0] r_st, r_nx_st;

  always @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn) r_st <= #1 ST_IDLE;
    else         r_st <= #1 r_nx_st;
  end

  always @(*) begin
    case (r_st)
      ST_IDLE: begin
        if (r_cs_fal) begin
          if (!r_mode)                 r_nx_st = ST_WDATA;  // write
          else if (r_rd_len_plus1==0)  r_nx_st = ST_SENDM;  // read, no pre-data
          else                         r_nx_st = ST_RECV;   // read, with pre-data
        end else r_nx_st = ST_IDLE;
      end
      ST_WDATA: r_nx_st = (r_cs_ris && r_bcnt==4'h0) ? ST_IDLE  : ST_WDATA;
      ST_RECV:  r_nx_st = (r_cs_ris && r_bcnt==4'h0) ? ST_IDLE  :
                          (r_dcnt>=r_rd_len_plus1)    ? ST_SENDM : ST_RECV;
      ST_SENDM: r_nx_st = (r_cs_ris && r_bcnt==4'h0) ? ST_IDLE  : ST_SENDM;
      default:  r_nx_st = ST_IDLE;
    endcase
  end

  // ── datapath ──
  reg [7:0]  r_sr;
  reg [15:0] r_dcnt;
  reg [7:0]  r_txsr;

  always @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn) begin
      r_sr    <= #1 8'h00;
      r_dcnt  <= #1 16'h0000;
      r_txsr  <= #1 8'h00;
      o_wr    <= #1 1'b0;
      o_wdata <= #1 8'h00;
      o_addr  <= #1 16'h0000;
      o_rd    <= #1 1'b0;
    end else begin
      o_wr <= #1 1'b0;
      o_rd <= #1 1'b0;

      if (r_cs_fal) r_dcnt <= #1 16'h0000;

      // ── sample edge: capture MOSI ──
      if (w_sample) begin
        r_sr <= #1 {r_sr[6:0], mosi};
      end

      // ── byte boundary: capture full byte (use {r_sr[6:0],mosi} = 8 bits before shift) ──
      if (w_end_byte) begin
        if (r_st == ST_WDATA || r_st == ST_RECV) begin
          o_wr    <= #1 1'b1;
          o_wdata <= #1 {r_sr[6:0], mosi};
          o_addr  <= #1 r_saddr + r_dcnt;
          r_dcnt  <= #1 r_dcnt + 16'h1;
        end
      end

      // ── drive edge: load/shift tx shift register ──
      if (w_drive) begin
        if (r_st == ST_SENDM) begin
          if (r_bcnt == 4'h1) begin
            o_rd   <= #1 1'b1;
            o_addr <= #1 r_saddr + r_dcnt;
            r_txsr <= #1 i_rdata;
          end else begin
            r_txsr <= #1 {r_txsr[6:0], 1'b0};
          end
          if (r_bcnt == 4'h7) r_dcnt <= #1 r_dcnt + 16'h1;
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
    end else if (r_st == ST_SENDM) begin
      miso <= #1 r_txsr[7];
    end else begin
      miso <= #1 1'bz;
    end
  end

  // ── test tasks ──
  task set_cpol(input v);     r_cpol <= #1 v; endtask
  task set_cpha(input v);     r_cpha <= #1 v; endtask
  task set_mode(input ci, input cpha_i);  r_cpol <= #1 ci;  r_cpha <= #1 cpha_i; endtask

  task set_write_mode(input [15:0] addr);
    r_mode  <= #1 1'b0;
    r_saddr <= #1 addr;
  endtask

  task set_read_mode(input [15:0] addr, input [15:0] rd_len_plus1);
    r_mode          <= #1 1'b1;
    r_saddr         <= #1 addr;
    r_rd_len_plus1  <= #1 rd_len_plus1;
  endtask

endmodule
