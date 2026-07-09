module spi_slave_model (
  input           clk,
  input           sclk,
  input           mosi,
  input           cs_n,
  output  reg     miso,
  output  reg     bne
);

  // ── runtime-configurable mode registers ──
  reg cpol = 0;
  reg cpha = 0;
  reg crc_mode = 0;
  reg [7:0] rd_dummy = 4;  // RD_DATA 命令段后等待的 dummy 字节数

  task set_mode(input cpol_i, input cpha_i, input crc_mode_i);
    cpol = cpol_i;
    cpha = cpha_i;
    crc_mode = crc_mode_i;
  endtask

  task set_rd_dummy(input [7:0] n);
    rd_dummy = n;
  endtask

  function integer crc_len;
    crc_len = (crc_mode == 0) ? 1 : 2;
  endfunction

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

  wire sample = (cpha == 0) ? sclk_ris : sclk_fal;
  wire drive  = (cpha == 0) ? sclk_fal : sclk_ris;

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
  reg [1:0] crc_byte_cnt;
  reg [7:0] dummy_rem;

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
      st <= CMD; bn <= 0; dcnt <= 0; dummy_rem <= 0;
      crc8_val <= 0; crc16_val <= 0; crc_byte_cnt <= 0;
      bne <= 0;
    end else if (cs_ris) begin
      if (st == WAIT) bne <= 1;
      st <= IDLE;
    end else if (sample) begin
      sr <= {sr[6:0], mosi};
      bn <= bn + 1;
      if (bn == 4'd8) begin
        bn <= 0;
        if (crc_mode == 0) crc8_val  <= crc8_upd(crc8_val, sr);
        else               crc16_val <= crc16_upd(crc16_val, sr);
        case (st)
          CMD: begin cmd_b <= sr; st <= ADR; end
          ADR: begin raddr <= sr; st <= CH;  end
          CH:  begin ctrl[15:8] <= sr; st <= CL; end
          CL: begin
            ctrl[7:0] <= sr; dlen <= sr;
            if (cmd_b[4:3] == 2'b00) begin st <= DAT; dcnt <= 0; end
            else st <= CRC;
          end
          DAT: begin
            if (dcnt < dlen) rbuf[dcnt] <= sr;
            dcnt <= dcnt + 1;
            if (dcnt + 1 >= dlen) st <= CRC;
          end
          CRC: begin
            crc_byte_cnt <= crc_byte_cnt + 1;
            if (crc_byte_cnt + 1 >= crc_len) begin
              if (cmd_b[4:3] == 2'b01) begin
                st <= WAIT;
              end else               if (cmd_b[4:3] == 2'b10) begin
                st <= RSP_D; dcnt <= 0; crc_byte_cnt <= 0;
                crc8_val <= 0; crc16_val <= 0; dummy_rem <= rd_dummy;
              end else begin
                st <= IDLE;
              end
            end
          end
        endcase
      end
    end else if (drive) begin
      if (st == RSP_D && dummy_rem > 0) begin
        // dummy stage: MISO high-Z, 等 slave 准备数据
        miso <= 1'bz;
        if (bn == 4'd8) begin dummy_rem <= dummy_rem - 1; bn <= 0; end
        else bn <= bn + 1;
      end else if (st == RSP_D && dcnt < dlen) begin
        miso <= rbuf[dcnt][7 - bn[2:0]];
        if (bn == 4'd0 && dcnt > 0) begin
          if (crc_mode == 0) crc8_val  <= crc8_upd(crc8_val, rbuf[dcnt-1]);
          else               crc16_val <= crc16_upd(crc16_val, rbuf[dcnt-1]);
        end
        if (bn == 4'd8) begin dcnt <= dcnt + 1; bn <= 0; end
        else bn <= bn + 1;
        if (dcnt + 1 >= dlen && bn == 4'd8) st <= RSP_C;
      end else if (st == RSP_C) begin
        if (crc_mode == 0) begin
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
