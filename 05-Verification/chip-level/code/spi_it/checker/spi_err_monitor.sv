// Chip-level error register monitor
//   Periodically reads error registers via I2C, logs any change

module spi_err_monitor;

  // ── register descriptor ──
  typedef struct {
    string     name;
    bit [15:0] addr;    // I2C reg address (SPI_REG_BASE + offset)
    bit [7:0]  last;
    int        chg_cnt;
  } reg_desc_t;

  reg_desc_t regs[$];

  // ── add register to watchlist ──
  task add_reg(string name, bit [15:0] addr);
    reg_desc_t r;
    r.name = name;
    r.addr = addr;
    r.last = 8'h00;
    r.chg_cnt = 0;
    regs.push_back(r);
  endtask

  // ── sample all watched registers, report changes ──
  task sample();
    foreach (regs[i]) begin
      bit [7:0] cur;
      ext_i2c_rd_reg16(`I2C_SLV_ADDR, regs[i].addr, cur);
      if (cur !== regs[i].last) begin
        regs[i].chg_cnt++;
        $display("[ERRMON] %0t %-12s changed: %02h → %02h (cnt=%0d)",
                 $time, regs[i].name, regs[i].last, cur, regs[i].chg_cnt);
        regs[i].last = cur;
      end
    end
  endtask

  // ── run: sample every N ns ──
  task run(input int interval_ns = 1000);
    forever begin
      #(interval_ns);
      sample();
    end
  endtask

  // ── final summary ──
  task summary();
    $display("=== ERR_MONITOR summary ===");
    foreach (regs[i])
      $display("  %-12s : %02h  changed %0d times",
               regs[i].name, regs[i].last, regs[i].chg_cnt);
  endtask

endmodule
