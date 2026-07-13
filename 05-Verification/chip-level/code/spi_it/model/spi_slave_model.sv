// SPI(B) slave — drives MISO, samples MOSI on sclk edges
// Protocol (mode 0: posedge sample, negedge drive):
//   Write:  CS↓ ADDR[8] DATA0...[8] CRC[8/16] CS↑  (ADDR[7]=0)
//   Read:   CS↓ ADDR[8] dummy×N ──────────────────── CS↑  (ADDR[7]=1)
//                                MISO: DATA0..LEN CRC
// Config (write addr < 3):
//   [0]: dummy_cnt    [1]: crc_mode    [2]: read_len

module spi_slave_model (
  input           sclk,
  input           mosi,
  input           cs_n,
  output  reg     miso = 1'bz,
  output  reg     bne
);

  // ── config & data ──
  reg [7:0] cfg[0:2];
  reg [7:0] rfile[0:255];

  // ── CRC helpers ──
  function [7:0] crc8(input [7:0] ci, input [7:0] d);
    reg [7:0] t; t = ci ^ d;
    repeat (8) begin t = t[7] ? {t[6:0],1'b0}^8'h07 : {t[6:0],1'b0}; end
    return t;
  endfunction
  function [15:0] crc16(input [15:0] ci, input [7:0] d);
    reg [15:0] t; t = ci ^ {d,8'h00};
    repeat (8) begin t = t[15] ? {t[14:0],1'b0}^16'h8005 : {t[14:0],1'b0}; end
    return t;
  endfunction

  // ── FSM ──
  typedef enum {IDLE, ADDR, WDATA, WCRC, RDUMMY, RDATA, RCRC} st_t;
  st_t st;
  reg [3:0] bn;                     // bit counter {byte_complete, bit[2:0]}
  reg [7:0] sr;                     // shift register
  reg [7:0] raddr;                  // captured address
  reg [7:0] txdummy;                // remaining dummy bytes
  reg [15:0] dcnt;                  // data byte index
  reg [7:0] crc8_val;
  reg [15:0] crc16_val;
  reg [1:0] crc_cnt;                // CRC bytes sent/received counter

  // ── edge detection (computed BEFORE delayed-value update) ──
  reg sclk_d, cs_d;

  always @(sclk or cs_n) begin
    // — edges using old delayed values —
    if ( sclk && !sclk_d) begin  // posedge: sample MOSI
      sr = {sr[6:0], mosi};
      // byte counter: bn[3] = 1 when bn == 8 (after 8 shifts)
      if (bn[3]) begin
        bn = 0;
        // tally CRC for received bytes in write path
        if (st == WDATA || st == ADDR) begin
          if (cfg[1]==0) crc8_val  = crc8(crc8_val, sr);
          else           crc16_val = crc16(crc16_val, sr);
        end
        // FSM
        case (st)
          IDLE: ;  // shouldn't happen with CS low
          ADDR: begin
            raddr = sr;
            if (sr[7]) begin st = RDUMMY; txdummy = cfg[0]; dcnt = 0; crc8_val=0; crc16_val=0; end
            else       begin st = WDATA;  dcnt = 0; end
          end
          WDATA: begin
            if (raddr < 3) cfg[raddr] = sr;
            else           rfile[raddr] = sr;
            raddr = raddr + 1;
          end
        endcase
      end else bn = bn + 1;
    end

    else if (!sclk && sclk_d) begin  // negedge: drive MISO
      if (st == RDUMMY) begin
        miso = 1'bz;
        if (bn[3]) begin bn = 0; if (txdummy > 0) txdummy = txdummy - 1; else st = RDATA; end
        else bn = bn + 1;
      end else if (st == RDATA) begin
        if (dcnt < cfg[2]) begin
          miso = rfile[{1'b0,raddr[6:0]} + dcnt][7 - bn[2:0]];
          if (bn[3]) begin
            bn = 0;
            if (cfg[1]==0) crc8_val  = crc8(crc8_val, rfile[{1'b0,raddr[6:0]} + dcnt]);
            else           crc16_val = crc16(crc16_val, rfile[{1'b0,raddr[6:0]} + dcnt]);
            dcnt = dcnt + 1;
            if (dcnt >= cfg[2]) st = RCRC;
          end else bn = bn + 1;
        end else miso = 1'bz;
      end else if (st == RCRC) begin
        if (crc_cnt < (cfg[1]==0 ? 1 : 2)) begin
          miso = (cfg[1]==0) ? crc8_val[7 - bn[2:0]] :
                 (crc_cnt==0) ? crc16_val[15 - bn[2:0]] : crc16_val[7 - bn[2:0]];
          if (bn[3]) begin bn = 0; crc_cnt = crc_cnt + 1; end
          else bn = bn + 1;
          if (crc_cnt >= (cfg[1]==0 ? 1 : 2)) miso = 1'bz;
        end else miso = 1'bz;
      end else begin
        miso = 1'bz;
      end
    end

    // — CS edge detection (frame control) —
    if ( cs_n && !cs_d) begin  // CS rise → frame end
      if (st == WDATA) st = IDLE;
      if (st == RDATA || st == RDUMMY || st == RCRC) bne = 1;
      st = IDLE;
      miso = 1'bz;
    end

    if (!cs_n && cs_d) begin  // CS fall → frame start
      st = ADDR;  bn = 0;  dcnt = 0;  miso = 1'bz;  bne = 0;
      crc8_val = 0;  crc16_val = 0;  crc_cnt = 0;
    end

    // — update delayed values for next event —
    sclk_d = sclk;
    cs_d   = cs_n;
  end

  // ── test control ──
  task init_regs();
    cfg[0] = 4;  cfg[1] = 0;  cfg[2] = 1;
    for (int i = 0; i < 256; i++) rfile[i] = 8'(i);
  endtask
  task set_dummy_cnt(input [7:0] n);  cfg[0] = n;  endtask
  task set_crc_mode(input [7:0] m);   cfg[1] = m;  endtask
  task set_read_len(input [7:0] n);   cfg[2] = n;  endtask
  task write_reg(input [7:0] a, input [7:0] d);  rfile[a] = d;  endtask

endmodule
