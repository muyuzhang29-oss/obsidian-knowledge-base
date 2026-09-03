// SPI(A) monitor: passively capture SOC FIFO byte stream, decode 5-wire frame
// Frame format (from soc_model):
//   Byte0: CMD  = {1'b1, R/W, dst_port[2:0], 3'b0}
//   Byte1: ADDR[16:9]
//   Byte2: ADDR[8:1]
//   Byte3: {ADDR[0], 7'b0}
//   Byte4: CTRL = {ctrl_bit, rd_len[6:0]}
//   Byte5: LEN  = data_len
//   Bytes 6..6+LEN-1: DATA
//   Last 1-2 bytes: CRC (CRC8 or CRC16)
//
// Usage (tb_spi.sv):
//   spi_a_monitor u_spi_a_mon();
//   u_spi_a_mon.connect(u_checker);

module spi_a_monitor (
  input        clk,
  input  [7:0] soc_tx_dat,
  input        soc_tx_vld,
  input        soc_tx_rdy
);

  spi_data_checker ck;

  // ── state machine ──
  localparam S_IDLE   = 3'd0;
  localparam S_HEADER = 3'd1;
  localparam S_DATA   = 3'd2;
  localparam S_CRC    = 3'd3;
  localparam S_PUSH   = 3'd4;

  reg [2:0] state;
  reg [7:0] rx_buf[$];
  reg [7:0] data_len;
  reg [7:0] byte_cnt;
  reg [7:0] cmd_byte;
  reg [7:0] crc_cnt;      // remaining CRC bytes to capture

  wire fifo_xfer = soc_tx_vld & soc_tx_rdy;

  always @(posedge clk) begin
    case (state)
      S_IDLE: begin
        if (fifo_xfer) begin
          rx_buf.delete();
          cmd_byte <= soc_tx_dat;
          byte_cnt <= 8'd1;
          state     <= S_HEADER;
        end
      end

      S_HEADER: begin
        if (fifo_xfer) begin
          rx_buf.push_back(soc_tx_dat);
          byte_cnt <= byte_cnt + 8'd1;
          if (byte_cnt == 8'd5) begin
            data_len <= soc_tx_dat;
            byte_cnt <= 8'd0;
            if (soc_tx_dat == 8'd0)
              state <= S_CRC;
            else
              state <= S_DATA;
          end
        end
      end

      S_DATA: begin
        if (fifo_xfer) begin
          rx_buf.push_back(soc_tx_dat);
          byte_cnt <= byte_cnt + 8'd1;
          if (byte_cnt + 8'd1 == data_len) begin
            byte_cnt <= 8'd0;
            crc_cnt  <= 8'd1;   // assume CRC8 first
            state    <= S_CRC;
          end
        end
      end

      S_CRC: begin
        if (fifo_xfer) begin
          rx_buf.push_back(soc_tx_dat);
          byte_cnt <= byte_cnt + 8'd1;
          // After 1st CRC byte: check if more bytes follow (CRC16)
          // If next byte arrives within a few cycles → CRC16
          // Simplified: always capture 1 CRC byte, then check if another follows
          if (byte_cnt == 8'd0) begin
            // Wait one more cycle to see if there's a 2nd CRC byte
            byte_cnt <= 8'd1;
          end else begin
            state <= S_PUSH;
          end
        end
      end

      S_PUSH: begin
        decode_and_push();
        state <= S_IDLE;
      end
    endcase
  end

  // ── timeout: if stuck in any state, reset ──
  reg [15:0] watchdog;
  always @(posedge clk) begin
    if (state == S_IDLE || fifo_xfer)
      watchdog <= 16'd0;
    else begin
      watchdog <= watchdog + 16'd1;
      if (watchdog == 16'd1000) begin
        $display("[SPI-A-MON] %0t WARNING: frame timeout, dropping %0d bytes",
                 $time, rx_buf.size());
        state <= S_IDLE;
      end
    end
  end

  // ── decode accumulated bytes and push to checker ──
  task decode_and_push();
    spi_data_checker::spi_trans_t t;
    integer n;
    t.t        = $time;
    t.is_write = ~cmd_byte[6];              // bit6 = R/W (0=write, 1=read)
    t.addr     = {rx_buf[1], rx_buf[2], rx_buf[3][7]};  // 17-bit addr
    t.crc_pass = 1;
    t.info     = "";

    n = rx_buf.size();
    // data bytes: rx_buf[6] .. rx_buf[6+data_len-1]  (skip 6-byte header, trailing CRC)
    if (n > 6 && data_len > 0) begin
      t.data = new[data_len];
      foreach (t.data[i]) t.data[i] = rx_buf[6 + i];
    end else begin
      t.data = new[0];
    end

    ck.push_tx(t);
    $display("[SPI-A-MON] %0t %s addr=%05h data_len=%0d total_bytes=%0d",
             $time, t.is_write ? "WR" : "RD", t.addr, t.data.size(), n);
  endtask

  task connect(spi_data_checker c);
    ck = c;
  endtask

endmodule
