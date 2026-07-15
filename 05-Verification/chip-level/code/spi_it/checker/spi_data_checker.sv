// Chip-level data integrity checker
//   SPI-A monitor → tx_q[$]
//   SPI-B monitor → rx_q[$]
//   Compare: for each tx, verify matching rx appears at sensor

module spi_data_checker;

  // Transaction type
  typedef struct {
    time        t;
    bit         is_write;      // 1=write, 0=read
    bit [16:0]  addr;
    bit [7:0]   data[];
    bit         crc_pass;
    string      info;
  } spi_trans_t;

  spi_trans_t tx_q[$];   // SPI-A transactions
  spi_trans_t rx_q[$];   // SPI-B transactions

  // ── push from SPI-A monitor ──
  task push_tx(input spi_trans_t t);
    tx_q.push_back(t);
  endtask

  // ── match a rx against pending tx ──
  task try_match(spi_trans_t t, output int matched);
    spi_trans_t exp;
    matched = 0;
    // 1) 先按 addr + direction 匹配
    foreach (tx_q[i]) begin
      if (tx_q[i].addr == t.addr && tx_q[i].is_write == t.is_write) begin
        exp = tx_q[i];
        matched = 1;
        tx_q.delete(i);
        break;
      end
    end
    // 2) 没匹配到 → 按 FIFO 顺序匹配（SPI-B 无地址）
    if (!matched && tx_q.size() > 0) begin
      exp = tx_q[0];
      if (exp.is_write == t.is_write) begin
        matched = 1;
        tx_q.pop_front();
      end
    end
    if (matched) begin
      if (t.data.size() != exp.data.size()) begin
        $error("[CK] %0t size mismatch: tx=%0d rx=%0d (addr=%04h)",
               $time, exp.data.size(), t.data.size(), exp.addr);
      end else begin
        foreach (t.data[j]) begin
          if (t.data[j] !== exp.data[j]) begin
            $error("[CK] %0t data[%0d] mismatch: tx=%02h rx=%02h (addr=%04h)",
                   $time, j, exp.data[j], t.data[j], exp.addr);
          end
        end
        if (exp.addr == 0)
          $display("[CK] %0t PASS seq trans len=%0d", $time, exp.data.size());
        else
          $display("[CK] %0t PASS trans addr=%04h len=%0d", $time, exp.addr, exp.data.size());
      end
    end
  endtask

  // ── push from SPI-B monitor ──
  task push_rx(input spi_trans_t t);
    int match;
    rx_q.push_back(t);
    try_match(t, match);
    if (!match) begin
      $display("[CK] %0t UNMATCHED rx addr=%04h (queued)", $time, t.addr);
    end
  endtask

  // ── flush unmatched at end of test ──
  task flush();
    foreach (tx_q[i])
      $error("[CK] %0t UNMATCHED tx addr=%04h data=%p", tx_q[i].t, tx_q[i].addr, tx_q[i].data);
    foreach (rx_q[i])
      $display("[CK] %0t LEAKED rx addr=%04h", rx_q[i].t, rx_q[i].addr);
  endtask

endmodule
