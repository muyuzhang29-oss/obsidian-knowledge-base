// SPI(B) monitor: passive capture cs_n/sclk/mosi/miso, raw bytes → push_rx to checker
// SPI(B) has no address on wire (pre-configured), only captures MOSI/MISO byte counts
// CPHA-aware: samples on correct edge based on CPOL/CPHA setting

module spi_b_monitor (
  input  sclk,
  input  mosi,
  input  miso,
  input  cs_n
);

  spi_data_checker ck;

  // ── CPOL/CPHA configuration ──
  reg r_cpol, r_cpha;

  task set_mode(input bit cpol_i, input bit cpha_i);
    r_cpol = cpol_i;
    r_cpha = cpha_i;
  endtask

  // ── Sample edge logic ──
  // CPHA=0: sample on first edge  (posedge if CPOL=0, negedge if CPOL=1)
  // CPHA=1: sample on second edge (negedge if CPOL=0, posedge if CPOL=1)
  // Simplifies to: sample on posedge when CPOL==CPHA, negedge when CPOL!=CPHA
  wire sample_on_posedge = (r_cpol == r_cpha);
  wire sample_on_negedge = (r_cpol != r_cpha);

  // ── MOSI capture ──
  reg [7:0] sr;
  reg [3:0] bit_cnt;
  reg       in_frame;
  reg [7:0] mosi_bytes[$];

  // ── MISO capture ──
  reg [3:0] m_bit_cnt;
  reg [7:0] m_sr;
  reg [7:0] miso_bytes[$];

  // ── SCLK posedge: sample MOSI and MISO if CPHA matches ──
  always @(posedge sclk) begin
    if (!cs_n && sample_on_posedge) begin
      sr <= {sr[6:0], mosi};
      m_sr <= {m_sr[6:0], miso};
      bit_cnt <= bit_cnt + 1;
      m_bit_cnt <= m_bit_cnt + 1;
      if (bit_cnt == 4'd7) begin
        bit_cnt <= 4'd0;
        mosi_bytes.push_back({sr[6:0], mosi});
      end
      if (m_bit_cnt == 4'd7) begin
        m_bit_cnt <= 4'd0;
        miso_bytes.push_back({m_sr[6:0], miso});
      end
    end
  end

  // ── SCLK negedge: sample MOSI and MISO if CPHA matches ──
  always @(negedge sclk) begin
    if (!cs_n && sample_on_negedge) begin
      sr <= {sr[6:0], mosi};
      m_sr <= {m_sr[6:0], miso};
      bit_cnt <= bit_cnt + 1;
      m_bit_cnt <= m_bit_cnt + 1;
      if (bit_cnt == 4'd7) begin
        bit_cnt <= 4'd0;
        mosi_bytes.push_back({sr[6:0], mosi});
      end
      if (m_bit_cnt == 4'd7) begin
        m_bit_cnt <= 4'd0;
        miso_bytes.push_back({m_sr[6:0], miso});
      end
    end
  end

  // ── CS fall → reset ──
  always @(negedge cs_n) begin
    in_frame  <= 1;
    sr        <= 8'h00;
    bit_cnt   <= 4'd0;
    m_sr      <= 8'h00;
    m_bit_cnt <= 4'd0;
    mosi_bytes.delete();
    miso_bytes.delete();
  end

  // ── CS rise → push transaction ──
  always @(posedge cs_n) begin
    spi_data_checker::spi_trans_t t;
    if (in_frame) begin
      in_frame <= 0;
      t.t       = $time;
      t.is_write = (miso_bytes.size() == 0);
      t.addr    = 0;
      if (t.is_write) begin
        t.data = new[mosi_bytes.size()];
        foreach (t.data[i]) t.data[i] = mosi_bytes[i];
      end else begin
        t.data = new[miso_bytes.size()];
        foreach (t.data[i]) t.data[i] = miso_bytes[i];
      end
      ck.push_rx(t);
      $display("[SPI-B-MON] %0t %s mosi_bytes=%0d miso_bytes=%0d",
               $time, t.is_write ? "WR" : "RD",
               mosi_bytes.size(), miso_bytes.size());
    end
  end

  task connect(spi_data_checker c);
    ck = c;
  endtask

endmodule
