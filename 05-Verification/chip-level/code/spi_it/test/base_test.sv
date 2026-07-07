module base_test;
  initial begin
    #200; @(posedge u_tb.rst_n); #100;

    $display("[TEST] SPI Master Write: SOC -> SENSOR");
    spi_init(.cpol(0), .cpha(0), .sck_low(5), .sck_high(5), .ss_dly(2));

    reg [7:0] wdata[]; wdata = new[4];
    wdata[0] = 8'hA5; wdata[1] = 8'h5A; wdata[2] = 8'hFF; wdata[3] = 8'h00;
    spi_master_write(5'b00010, 17'h1A2B3, wdata, 8'd4);
    #1000;

    $display("[TEST] SPI Master Read: SOC <- SENSOR");
    reg [7:0] rdata[];
    spi_master_read(5'b00010, 17'h1A2B3, 7'd4, 8'd4, rdata);
    for (int i = 0; i < 4; i++)
      $display("  rdata[%0d] = 0x%02h", i, rdata[i]);

    reg [7:0] spis_err, spim_err;
    spi_check_timeout_err(spis_err, spim_err);
    if (spis_err || spim_err)
      $display("[FAIL] Timeout err SPIS=%0d SPIM=%0d", spis_err, spim_err);
    else
      $display("[PASS] No timeout error");
    #500; $finish;
  end
endmodule
