// SPI write sanity test
//   1. Init SPI master
//   2. Write data to sensor via SPI(B)
//   3. Read back and verify

class spi_write_test extends base_test;
  `uvm_component_utils(spi_write_test)

  function new(string name = "spi_write_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_test_scenario();
    reg [7:0] wdata[], rdata[];
    bit pass;

    // ========================
    // Test 1: Write single byte
    // ========================
    $display("=== Test 1: SPI write single byte ===");
    wdata = new[1];  wdata[0] = 8'hA5;
    spi_sensor_write(.addr(16'h0010), .data(wdata), .len(1));

    rdata = new[1];
    spi_sensor_read(.addr(16'h0010), .rd_len_plus1(0), .rdata(rdata));
    pass = (rdata[0] === 8'hA5);
    $display("[%s] write 0xA5 → read 0x%02h", pass ? "PASS" : "FAIL", rdata[0]);

    // ========================
    // Test 2: Write multiple bytes
    // ========================
    $display("=== Test 2: SPI write multiple bytes ===");
    wdata = new[4];  for (int i = 0; i < 4; i++) wdata[i] = 8'(i * 16 + i);
    spi_sensor_write(.addr(16'h0020), .data(wdata), .len(4));

    rdata = new[4];
    spi_sensor_read(.addr(16'h0020), .rd_len_plus1(0), .rdata(rdata));
    pass = 1;
    for (int i = 0; i < 4; i++) begin
      if (rdata[i] !== wdata[i]) pass = 0;
      $display("  [%s] byte[%0d] wrote 0x%02h → read 0x%02h",
               (rdata[i] === wdata[i]) ? "PASS" : "FAIL", i, wdata[i], rdata[i]);
    end

    // ========================
    // Test 3: Write with pre-data before read
    // ========================
    $display("=== Test 3: SPI read with pre-data (rd_len_plus1=2) ===");
    wdata = new[2];  wdata[0] = 8'h11;  wdata[1] = 8'h22;
    spi_sensor_write(.addr(16'h0030), .data(wdata), .len(2));

    rdata = new[2];
    spi_sensor_read(.addr(16'h0030), .rd_len_plus1(2), .rdata(rdata));
    pass = (rdata[0] === 8'h11 && rdata[1] === 8'h22);
    $display("[%s] read with pre-data: 0x%02h 0x%02h", pass ? "PASS" : "FAIL",
             rdata[0], rdata[1]);

    #100;
    $display("=== SPI write test done ===");
  endtask

endclass
