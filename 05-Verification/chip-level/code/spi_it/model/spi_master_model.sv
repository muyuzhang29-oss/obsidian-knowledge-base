module spi_master_model (
  output  reg       sclk,
  output  reg       mosi,
  output  reg       cs_n,
  input             miso,
  input             bne
);

  parameter CPOL     = 0;
  parameter CPHA     = 0;
  parameter CRC_MODE = 0;  // 0=CRC-8, 1=CRC-16
  parameter SCLK_HALF = 50;

  initial begin sclk = CPOL; mosi = 0; cs_n = 1; end

  // ── byte I/O ──
  task spi_out_byte(input [7:0] d);
    integer i;
    for (i = 7; i >= 0; i--) begin
      mosi = d[i];
      #(SCLK_HALF); sclk = ~CPOL;
      #(SCLK_HALF); sclk = CPOL;
    end
  endtask

  task spi_in_byte(output [7:0] d);
    integer i;
    for (i = 7; i >= 0; i--) begin
      #(SCLK_HALF); sclk = ~CPOL;
      d[i] = miso;
      #(SCLK_HALF); sclk = CPOL;
    end
  endtask

  task spi_cs_low;  #(SCLK_HALF); cs_n = 0; #(SCLK_HALF); endtask
  task spi_cs_high; #(SCLK_HALF); cs_n = 1; #(SCLK_HALF); endtask

  // ── CRC functions ──
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

  // CRC-8 append = 1 byte, CRC-16 append = 2 bytes
  function integer crc_bytes;
    return (CRC_MODE == 0) ? 1 : 2;
  endfunction

  // ── CMD builder ──
  function [7:0] cmd(input l, input [1:0] da, input [1:0] rw, input [2:0] dp);
    cmd = {l, da, rw, dp};
  endfunction

  // ── Write frame ──
  task spi_write(
    input       l, input [1:0] da, input [2:0] dp,
    input [7:0] a, input [7:0] dlen, input [7:0] d[]
  );
    reg [7:0] fifo[$];
    reg [7:0] crc8_val;
    reg [15:0] crc16_val;
    integer i;
    fifo = {cmd(l,da,2'b00,dp), a, 8'h00, dlen};
    for (i=0; i<dlen; i++) fifo.push_back(d[i]);
    // CRC
    if (CRC_MODE == 0) begin
      crc8_val = 0;
      foreach (fifo[i]) crc8_val = crc8_f(crc8_val, fifo[i]);
      fifo.push_back(crc8_val);
    end else begin
      crc16_val = 0;
      foreach (fifo[i]) crc16_val = crc16_f(crc16_val, fifo[i]);
      fifo.push_back(crc16_val[15:8]);
      fifo.push_back(crc16_val[7:0]);
    end
    spi_cs_low;
    for (i=0; i<fifo.size(); i++) spi_out_byte(fifo[i]);
    spi_cs_high;
    $display("%10t: SPI_MST write [%02h] len=%0d crc=%s",
             $time, a, dlen, CRC_MODE ? "CRC-16" : "CRC-8");
  endtask

  // ── Read-cmd → wait BNE → read-data ──
  task spi_read(
    input       l, input [1:0] da, input [2:0] dp,
    input [7:0] a, input [6:0] rl, input [7:0] dlen,
    output [7:0] rdata[]
  );
    reg [7:0] fifo[$];
    integer i;
    // RD_CMD frame
    fifo = {cmd(l,da,2'b01,dp), a, {1'b1,rl}, dlen};
    append_crc(fifo);
    spi_cs_low;
    for (i=0; i<fifo.size(); i++) spi_out_byte(fifo[i]);
    spi_cs_high;
    // wait BNE
    while (!bne) #(SCLK_HALF);
    #(SCLK_HALF);
    // RD_DATA frame
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
    fifo = {cmd(l,da,2'b10,dp), a, {1'b1,rl}, dlen};
    append_crc(fifo);  // CRC_cmd
    spi_cs_low;
    for (i=0; i<fifo.size(); i++) spi_out_byte(fifo[i]);
    // dummy → read back data + CRC_data
    rcnt = dlen + crc_bytes;
    rdata = new[rcnt];
    for (i=0; i<rcnt; i++) begin
      spi_out_byte(8'h00);
      spi_in_byte(rdata[i]);
    end
    spi_cs_high;
    $display("%10t: SPI_MST read  [%02h] len=%0d crc=%s",
             $time, a, dlen, CRC_MODE ? "CRC-16" : "CRC-8");
  endtask

  // ── internal: append CRC to a fifo ──
  task append_crc(inout reg [7:0] fifo[$]);
    reg [7:0] c8;
    reg [15:0] c16;
    integer i;
    if (CRC_MODE == 0) begin
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

endmodule
