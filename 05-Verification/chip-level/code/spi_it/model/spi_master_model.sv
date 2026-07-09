module spi_master_model (
  output  reg       sclk,
  output  reg       mosi,
  output  reg       cs_n,
  input             miso,
  input             bne
);

  parameter SCLK_HALF = 50;

  // ── runtime-configurable mode registers ──
  reg cpol = 0;
  reg cpha = 0;
  reg crc_mode = 0;  // 0=CRC-8, 1=CRC-16

  task set_mode(input cpol_i, input cpha_i, input crc_mode_i);
    cpol = cpol_i;
    cpha = cpha_i;
    crc_mode = crc_mode_i;
  endtask

  initial begin sclk = cpol; mosi = 0; cs_n = 1; end

  // ── byte I/O ──
  task spi_out_byte(input [7:0] d);
    integer i;
    for (i = 7; i >= 0; i--) begin
      mosi = d[i];
      #(SCLK_HALF); sclk = ~cpol;
      #(SCLK_HALF); sclk = cpol;
    end
  endtask

  task spi_in_byte(output [7:0] d);
    integer i;
    for (i = 7; i >= 0; i--) begin
      #(SCLK_HALF); sclk = ~cpol;
      d[i] = miso;
      #(SCLK_HALF); sclk = cpol;
    end
  endtask

  task spi_cs_low;  #(SCLK_HALF); cs_n = 0; #(SCLK_HALF); endtask
  task spi_cs_high; #(SCLK_HALF); cs_n = 1; #(SCLK_HALF); endtask

  // ── CRC functions (combinational, usable in tasks) ──
  function [7:0] crc8_f(input [7:0] ci, input [7:0] d);
    reg [7:0] t;
    t = ci ^ d;
    repeat (8) begin
      if (t[7]) t = {t[6:0],1'b0} ^ 8'h07;
      else      t = {t[6:0],1'b0};
    end
    return t;
  endfunction

  function [15:0] crc16_f(input [15:0] ci, input [7:0] d);
    reg [15:0] t;
    t = ci ^ {d, 8'h00};
    repeat (8) begin
      if (t[15]) t = {t[14:0],1'b0} ^ 16'h8005;
      else       t = {t[14:0],1'b0};
    end
    return t;
  endfunction

  function integer crc_len;
    crc_len = (crc_mode == 0) ? 1 : 2;
  endfunction

  // ── CMD builder ──
  function [7:0] cmd(input l, input [1:0] da, input [1:0] rw, input [2:0] dp);
    cmd = {l, da, rw, dp};
  endfunction

  // ── internal: append CRC to a fifo (uses current crc_mode) ──
  task append_crc(inout reg [7:0] fifo[$]);
    reg [7:0] c8;
    reg [15:0] c16;
    integer i;
    if (crc_mode == 0) begin
      c8 = 0;
      foreach (fifo[i]) c8 = crc8_f(c8, fifo[i]);
      fifo.push_back(c8);
    end else begin
      c16 = 0;
      foreach (fifo[i]) c16 = crc16_f(c16, fifo[i]);
      fifo.push_back(c16[15:8]);
      fifo.push_back(c16[7:0]);
    end
  endtask

  // ── Write frame ──
  task spi_write(
    input       l, input [1:0] da, input [2:0] dp,
    input [7:0] a, input [7:0] dlen, input [7:0] d[]
  );
    reg [7:0] fifo[$];
    integer i;
    fifo = {};
    fifo.push_back(cmd(l,da,2'b00,dp));
    fifo.push_back(a);
    fifo.push_back(8'h00);  // Control high: rd_en=0, rd_len=0
    fifo.push_back(dlen);   // Control low: data_len
    for (i=0; i<dlen; i++) fifo.push_back(d[i]);
    append_crc(fifo);
    spi_cs_low;
    for (i=0; i<fifo.size(); i++) spi_out_byte(fifo[i]);
    spi_cs_high;
    $display("%10t: SPI_MST write [%02h] len=%0d cpol=%0d cpha=%0d %s",
             $time, a, dlen, cpol, cpha, crc_mode ? "CRC-16" : "CRC-8");
  endtask

  // ── Read-cmd → wait BNE → read-data ──
  task spi_read(
    input       l, input [1:0] da, input [2:0] dp,
    input [7:0] a, input [6:0] rl, input [7:0] dlen,
    output [7:0] rdata[]
  );
    reg [7:0] fifo[$];
    integer i;
    fifo = {};
    fifo.push_back(cmd(l,da,2'b01,dp));
    fifo.push_back(a);
    fifo.push_back({1'b1,rl});  // Control high: rd_en=1, rd_len
    fifo.push_back(dlen);       // Control low: data_len
    append_crc(fifo);
    spi_cs_low;
    for (i=0; i<fifo.size(); i++) spi_out_byte(fifo[i]);
    spi_cs_high;
    while (!bne) #(SCLK_HALF);
    #(SCLK_HALF);
    spi_read_data(l, da, dp, a, rl, dlen, rdata);
  endtask

  // ── Read-data sub-frame ──
  task spi_read_data(
    input       l, input [1:0] da, input [2:0] dp,
    input [7:0] a, input [6:0] rl, input [7:0] dlen,
    output [7:0] rdata[]
  );
    reg [7:0] fifo[$];
    integer i, rcnt;
    fifo = {};
    fifo.push_back(cmd(l,da,2'b10,dp));
    fifo.push_back(a);
    fifo.push_back({1'b1,rl});
    fifo.push_back(dlen);
    append_crc(fifo);
    spi_cs_low;
    for (i=0; i<fifo.size(); i++) spi_out_byte(fifo[i]);
    rcnt = dlen + crc_len;
    rdata = new[rcnt];
    for (i=0; i<rcnt; i++) begin
      spi_out_byte(8'h00);
      spi_in_byte(rdata[i]);
    end
    spi_cs_high;
    $display("%10t: SPI_MST read  [%02h] len=%0d cpol=%0d cpha=%0d %s",
             $time, a, dlen, cpol, cpha, crc_mode ? "CRC-16" : "CRC-8");
  endtask

endmodule
