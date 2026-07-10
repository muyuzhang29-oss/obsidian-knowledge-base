// Standalone sensor test — no DUT needed
// Uses a simple SPI master to drive SCLK/MOSI/CS_N to sensor
//
// Usage: vlog +v2k tb_sensor_only.sv spi_slv_reg.sv spi_sensor_model.sv
//        vsim -c top_sensor_test -do "run -all"

`timescale 1ns / 1ps

module top_sensor_test;

  reg clk = 0;
  always #10 clk = ~clk;  // 50MHz

  reg sclk, mosi, cs_n;
  wire miso;

  // SPI(B) sensor
  spi_sensor_model u_sensor (
    .SCLK (sclk),
    .MOSI (mosi),
    .MISO (miso),
    .CS_N (cs_n)
  );

  // Simple SPI write sequence
  task spi_single_write(input [15:0] addr, input [7:0] data);
    integer i;
    reg [15:0] addr_tmp;
    // 1. Configure sensor for write at addr
    u_sensor.set_write_mode(addr);
    // 2. Generate SPI cycle: CS↓ → 8×data → CS↑
    addr_tmp = addr;
    cs_n = 1; sclk = 0; mosi = 0;
    #200;
    cs_n = 0;
    #100;
    for (i = 0; i < 16; i++) begin
      mosi = addr_tmp[15];  addr_tmp = {addr_tmp[14:0], 1'b0};
      #10 sclk = 1;  #10 sclk = 0;
    end
    for (i = 0; i < 8; i++) begin
      mosi = data[7];  data = {data[6:0], 1'b0};
      #10 sclk = 1;  #10 sclk = 0;
    end
    #100;
    cs_n = 1;
    #200;
  endtask

  task spi_single_read(input [15:0] addr, input [15:0] rd_len_plus1);
    integer i;
    reg [7:0] rbuf;
    u_sensor.set_read_mode(addr, rd_len_plus1);
    cs_n = 1; sclk = 0; mosi = 0;
    #200;
    cs_n = 0;
    #100;
    // Send dummy SCLKs to get MISO data
    for (i = 0; i < 16; i++) begin
      #10 sclk = 1;  #10 sclk = 0;
      if (i == 0) $display("  MISO bit[%0d] = %b", i, miso);
    end
    #100;
    cs_n = 1;
    #200;
  endtask

  initial begin
    // Wait for sensor internal reset
    #60000;

    // Test write
    $display("=== Standalone: write 0xA5 to addr 0x0010 ===");
    spi_single_write(16'h0010, 8'hA5);

    // Test read
    $display("=== Standalone: read addr 0x0010 ===");
    spi_single_read(16'h0010, 0);

    #1000;
    $display("=== Standalone test done ===");
    $finish;
  end

endmodule
