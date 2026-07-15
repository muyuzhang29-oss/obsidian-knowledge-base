// SPI-A monitor: 被动抓 sclk/mosi/cs_n，解码 5-wire 帧 → push_tx 到 checker
// 用法 (tb_spi.sv):
//   spi_a_monitor #(.SCLK_HALF(50)) u_spi_a_mon();
//   u_spi_a_mon.connect(u_checker);

module spi_a_monitor #(parameter SCLK_HALF = 50);

  spi_data_checker  ck;

  // 从外部传进来的 pin 信号（必须由 tb_spi.sv 用 assign 或直接接）
  input        sclk;
  input        mosi;
  input        cs_n;

  // ── internal state ──
  reg [7:0]   sr;          // shift register
  reg [3:0]   bit_cnt;     // 0..8
  reg [7:0]   rx_buf[$];   // received bytes
  reg         in_frame;

  // ── SCLK posedge sampling ──
  always @(posedge sclk) begin
    if (!cs_n) begin
      sr <= {sr[6:0], mosi};
      bit_cnt <= bit_cnt + 1;
      if (bit_cnt == 4'd8) begin
        sr <= 8'h00;
        bit_cnt <= 4'd0;
        rx_buf.push_back({sr[6:0], mosi});
      end
    end
  end

  // ── CS fall → frame start ──
  always @(negedge cs_n) begin
    in_frame <= 1;
    sr <= 8'h00;
    bit_cnt <= 4'd0;
    rx_buf.delete();
  end

  // ── CS rise → frame end → decode and push ──
  always @(posedge cs_n) begin
    integer n;
    spi_data_checker::spi_trans_t t;
    if (in_frame && rx_buf.size() >= 4) begin
      in_frame <= 0;
      t.t       = $time;
      t.is_write = (rx_buf[0][3:2] == 2'b00);
      t.addr    = {rx_buf[1], rx_buf[2][7:1]};
      n         = rx_buf.size();
      // data bytes: skip CMD(1)+ADDR(2)+CTRL(1)+CRC(last1/2)
      t.data    = new[n - 4 - (rx_buf[n-1]!==8'h00 ? 2 : 1)];
      foreach (t.data[i]) t.data[i] = rx_buf[4 + i];
      ck.push_tx(t);
      $display("[SPI-A-MON] %0t %s addr=%05h len=%0d crc_bytes=%0d",
               $time, t.is_write ? "WR" : "RD", t.addr, t.data.size(),
               rx_buf[n-1]!==8'h00 ? 2 : 1);
    end
    rx_buf.delete();
  end

  task connect(spi_data_checker c);
    ck = c;
  endtask

endmodule
