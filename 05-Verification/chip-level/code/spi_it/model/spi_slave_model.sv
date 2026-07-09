module spi_slave_model (
  input           clk,      // TB 系统时钟
  input           sclk,
  input           mosi,
  input           cs_n,
  output  reg     miso,
  output  reg     bne
);

  parameter CPOL     = 0;
  parameter CPHA     = 0;
  parameter CRC_MODE = 0;  // 0=CRC-8, 1=CRC-16

  // ── 2-flop synchronizers ──
  reg sclk_s1, sclk_s2, cs_s1, cs_s2;
  wire sclk_ris = (sclk_s1 && !sclk_s2);
  wire sclk_fal = (!sclk_s1 && sclk_s2);
  wire cs_ris   = (cs_s1 && !cs_s2);
  wire cs_fal   = (!cs_s1 && cs_s2);

  always @(posedge clk) begin
    sclk_s1 <= sclk; sclk_s2 <= sclk_s1;
    cs_s1   <= cs_n;  cs_s2   <= cs_s1;
  end

  wire sample = (CPHA == 0) ? sclk_ris : sclk_fal;
  wire drive  = (CPHA == 0) ? sclk_fal : sclk_ris;

  // ── FSM ──
  typedef enum {IDLE, CMD, ADR, CH, CL, DAT, CRC, WAIT, RSP_D, RSP_C} st_t;
  st_t st;
  reg [3:0] bn;
  reg [7:0] sr, cmd_b, raddr;
  reg [15:0] ctrl;
  reg [7:0] dlen;
  reg [15:0] dcnt;
  reg [7:0] rbuf[0:255];
  reg [7:0] crc8_val;
  reg [15:0] crc16_val;
  reg [1:0] crc_byte_cnt;   // for CRC-16 2-byte receive

  function integer crc_len;
    crc_len = (CRC_MODE == 0) ? 1 : 2;
  endfunction

  // ── CRC functions ──
  function [7:0] crc8_upd(input [7:0] ci, input [7:0] d);
    reg [7:0] t;
    t = ci ^ d;
    repeat (8) begin
      if (t[7]) t = {t[6:0],1'b0} ^ 8'h07;
      else      t = {t[6:0],1'b0};
    end
    return t;
  endfunction

  function [15:0] crc16_upd(input [15:0] ci, input [7:0] d);
    reg [15:0] t;
    t = ci ^ {d, 8'h00};
    repeat (8) begin
      if (t[15]) t = {t[14:0],1'b0} ^ 16'h8005;
      else       t = {t[14:0],1'b0};
    end
    return t;
  endfunction

  initial begin miso = 1'bz; bne = 0; st = IDLE; end

  always @(posedge clk) begin
    if (cs_fal) begin
      st <= CMD; bn <= 0; dcnt <= 0;
      crc8_val <= 0; crc16_val <= 0; crc_byte_cnt <= 0;
      bne <= 0;
    end else if (cs_ris) begin
      // RD_CMD done → BNE high for next frame
      if (st == WAIT) bne <= 1;
      st <= IDLE;
    end else if (sample) begin
      sr <= {sr[6:0], mosi};
      bn <= bn + 1;
      if (bn == 4'd8) begin
        bn <= 0;
        // update CRC
        if (CRC_MODE == 0) crc8_val  <= crc8_upd(crc8_val, sr);
        else               crc16_val <= crc16_upd(crc16_val, sr);
        case (st)
          CMD: begin
            cmd_b <= sr; st <= ADR;
          end
          ADR: begin
            raddr <= sr; st <= CH;
          end
          CH: begin
            ctrl[15:8] <= sr; st <= CL;
          end
          CL: begin
            ctrl[7:0] <= sr;
            dlen <= sr;
            if (cmd_b[4:3] == 2'b00) begin st <= DAT; dcnt <= 0; end
            else st <= CRC;  // read-cmd or read-data → CRC next
          end
          DAT: begin
            if (dcnt < dlen) rbuf[dcnt] <= sr;
            dcnt <= dcnt + 1;
            if (dcnt + 1 >= dlen) st <= CRC;
          end
          CRC: begin
            // multi-byte CRC: wait for crc_len bytes
            crc_byte_cnt <= crc_byte_cnt + 1;
            if (crc_byte_cnt + 1 >= crc_len) begin
              // CRC done
              if (cmd_b[4:3] == 2'b01) st <= WAIT;     // RD_CMD
              else if (cmd_b[4:3] == 2'b10) begin
                st <= RSP_D; dcnt <= 0;                   // RD_DATA → respond
                crc8_val <= 0; crc16_val <= 0;            // reset CRC for response
              end else st <= IDLE;                          // WR done
            end
          end
        endcase
      end
    end else if (drive) begin
      if (st == RSP_D && dcnt < dlen) begin
        miso <= rbuf[dcnt][7 - bn[2:0]];
        // update CRC for response
        if (bn == 4'd0 && dcnt > 0) begin
          if (CRC_MODE == 0) crc8_val  <= crc8_upd(crc8_val, rbuf[dcnt-1]);
          else               crc16_val <= crc16_upd(crc16_val, rbuf[dcnt-1]);
        end
        if (bn == 4'd8) begin dcnt <= dcnt + 1; bn <= 0; end
        else bn <= bn + 1;
        if (dcnt + 1 >= dlen && bn == 4'd8) st <= RSP_C;
      end else if (st == RSP_C) begin
        // drive CRC on MISO
        if (CRC_MODE == 0) begin
          miso <= crc8_val[7 - bn[2:0]];
          if (bn == 4'd8) st <= IDLE;
          else bn <= bn + 1;
        end else begin
          if (crc_byte_cnt == 0) begin
            miso <= crc16_val[15 - bn[2:0]];
            if (bn == 4'd8) begin bn <= 0; crc_byte_cnt <= 1; end
            else bn <= bn + 1;
          end else begin
            miso <= crc16_val[7 - bn[2:0]];
            if (bn == 4'd8) st <= IDLE;
            else bn <= bn + 1;
          end
        end
      end else begin
        miso <= 1'bz;
      end
    end
  end

  task set_response(input [7:0] d[], input [7:0] len);
    for (int i = 0; i < len && i < 256; i++) rbuf[i] = d[i];
    dlen = len;
  endtask

endmodule
