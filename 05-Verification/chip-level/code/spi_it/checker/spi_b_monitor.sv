// SPI-B monitor: 被动抓 cs_n/sclk/mosi/miso，捕获 raw bytes → push_rx 到 checker
// SPI-B 线没有地址（预先配置），只抓 MOSI/MISO 字节数

module spi_b_monitor;

  spi_data_checker  ck;

  input        sclk;
  input        mosi;
  input        cs_n;
  input        miso;

  // ── state ──
  reg [7:0]   sr;
  reg [3:0]   bit_cnt;
  reg         in_frame;
  reg [7:0]   mosi_bytes[$];
  reg [7:0]   miso_bytes[$];

  // ── SCLK posedge: sample MOSI ──
  always @(posedge sclk) begin
    if (!cs_n) begin
      sr <= {sr[6:0], mosi};
      bit_cnt <= bit_cnt + 1;
      if (bit_cnt == 4'd8) begin
        bit_cnt <= 4'd0;
        sr <= 8'h00;
        mosi_bytes.push_back({sr[6:0], mosi});
      end
    end
  end

  // ── SCLK negedge: sample MISO ──
  always @(negedge sclk) begin
    if (!cs_n) begin
      if (bit_cnt == 4'd8) begin
        // miso bit 0 is being driven now; capture previous byte at bit7 position
      end
    end
  end

  // ── actual MISO capture using internal counter ──
  reg [3:0]   m_bit_cnt;
  reg [7:0]   m_sr;

  always @(negedge sclk) begin
    if (!cs_n) begin
      m_sr <= {m_sr[6:0], miso};
      m_bit_cnt <= m_bit_cnt + 1;
      if (m_bit_cnt == 4'd8) begin
        m_bit_cnt <= 4'd0;
        m_sr <= 8'h00;
        miso_bytes.push_back({m_sr[6:0], miso});
      end
    end
  end

  // ── CS fall → reset ──
  always @(negedge cs_n) begin
    in_frame <= 1;
    sr <= 8'h00;
    bit_cnt <= 4'd0;
    m_sr <= 8'h00;
    m_bit_cnt <= 4'd0;
    mosi_bytes.delete();
    miso_bytes.delete();
  end

  // ── CS rise → push transaction ──
  always @(posedge cs_n) begin
    spi_data_checker::spi_trans_t t;
    integer n;
    if (in_frame) begin
      in_frame <= 0;
      t.t       = $time;
      t.is_write = (miso_bytes.size() == 0);  // no MISO = write
      // SPI-B 无地址在线上，填 0
      t.addr    = 0;
      if (t.is_write) begin
        t.data = new[mosi_bytes.size()];
        foreach (t.data[i]) t.data[i] = mosi_bytes[i];
      end else begin
        t.data = new[miso_bytes.size()];
        foreach (t.data[i]) t.data[i] = miso_bytes[i];
      end
      ck.push_rx(t);
      $display("[SPI-B-MON] %0t %s mosi=%0d miso=%0d",
               $time, t.is_write ? "WR" : "RD", mosi_bytes.size(), miso_bytes.size());
    end
  end

  task connect(spi_data_checker c);
    ck = c;
  endtask

endmodule
