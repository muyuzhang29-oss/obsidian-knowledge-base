module base_test;
  initial begin
    #200; @(posedge u_tb.rst_n); #100;

    // ==========================================
    // Test 1: CRC-8 (default) — SPI Master Write
    // ==========================================
    $display("[TEST] SPI Master Write (CRC-8): SOC -> SENSOR");
    spi_init(.cpol(0), .cpha(0), .sck_low(5), .sck_high(5), .ss_dly(2));
    spi_set_crc_mode(0);  // CRC-8 (default)

    reg [7:0] wdata[]; wdata = new[4];
    wdata[0] = 8'hA5; wdata[1] = 8'h5A; wdata[2] = 8'hFF; wdata[3] = 8'h00;
    spi_master_write(5'b00010, 17'h1A2B3, wdata, 8'd4);
    #1000;

    // ==========================================
    // Test 2: CRC-8 (default) — SPI Master Read
    // ==========================================
    $display("[TEST] SPI Master Read (CRC-8): SOC <- SENSOR");
    reg [7:0] rdata[];
    spi_master_read(5'b00010, 17'h1A2B3, 7'd4, 8'd4, rdata);
    for (int i = 0; i < 4; i++)
      $display("  rdata[%0d] = 0x%02h", i, rdata[i]);

    reg [7:0] spis_err, spim_err;
    spi_check_timeout_err(spis_err, spim_err);
    if (spis_err || spim_err)
      $display("[FAIL] Timeout err SPIS=%0d SPIM=%0d", spis_err, spim_err);
    else
      $display("[PASS] No timeout error (CRC-8)");

    #500;

    // ==========================================
    // Test 3: CRC-16 — SPI Master Write
    // ==========================================
    $display("[TEST] SPI Master Write (CRC-16): SOC -> SENSOR");
    spi_set_crc_mode(1);  // CRC-16

    wdata = new[4];
    wdata[0] = 8'hA5; wdata[1] = 8'h5A; wdata[2] = 8'hFF; wdata[3] = 8'h00;
    spi_master_write(5'b00010, 17'h1A2B3, wdata, 8'd4);
    #1000;

    // ==========================================
    // Test 4: CRC-16 — SPI Master Read
    // ==========================================
    $display("[TEST] SPI Master Read (CRC-16): SOC <- SENSOR");
    spi_master_read(5'b00010, 17'h1A2B3, 7'd4, 8'd4, rdata);
    for (int i = 0; i < 4; i++)
      $display("  rdata[%0d] = 0x%02h", i, rdata[i]);

    spi_check_timeout_err(spis_err, spim_err);
    if (spis_err || spim_err)
      $display("[FAIL] Timeout err SPIS=%0d SPIM=%0d", spis_err, spim_err);
    else
      $display("[PASS] No timeout error (CRC-16)");

    #500; $finish;
  end
endmodule
