module spi_master_model (
  output  reg       sclk,
  output  reg       mosi,
  output  reg       cs_n,
  input             miso,
  input             bne,
  input       [7:0] crc_init
);

  parameter CPOL = 0;
  parameter CPHA = 0;
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

  // ── CRC-8 ──
  function [7:0] crc8(reg [7:0] data[$]);
    reg [7:0] c = 8'h00;
    foreach (data[i]) begin
      c = c ^ data[i];
      repeat (8) begin
        if (c[7]) c = {c[6:0],1'b0} ^ 8'h07;
        else      c = {c[6:0],1'b0};
      end
    end
    return c;
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
    fifo = {cmd(l,da,2'b00,dp), a, 8'h00, dlen};
    for (int i=0; i<dlen; i++) fifo.push_back(d[i]);
    fifo.push_back(crc8(fifo));
    spi_cs_low;
    for (int i=0; i<fifo.size(); i++) spi_out_byte(fifo[i]);
    spi_cs_high;
    $display("%10t: SPI_MST write [%02h] len=%0d", $time, a, dlen);
  endtask

  // ── Read-cmd frame → wait BNE → read-data frame ──
  task spi_read(
    input       l, input [1:0] da, input [2:0] dp,
    input [7:0] a, input [6:0] rl, input [7:0] dlen,
    output [7:0] rdata[]
  );
    reg [7:0] fifo[$];
    // RD_CMD
    fifo = {cmd(l,da,2'b01,dp), a, {1'b1,rl}, dlen};
    fifo.push_back(crc8(fifo));
    spi_cs_low;
    for (int i=0; i<fifo.size(); i++) spi_out_byte(fifo[i]);
    spi_cs_high;
    // wait BNE
    while (!bne) #(SCLK_HALF);
    #(SCLK_HALF);
    // RD_DATA
    spi_read_data(l, da, dp, a, rl, dlen, rdata);
  endtask

  // ── Read-data sub-frame ──
  task spi_read_data(
    input       l, input [1:0] da, input [2:0] dp,
    input [7:0] a, input [6:0] rl, input [7:0] dlen,
    output [7:0] rdata[]
  );
    reg [7:0] fifo[$];
    fifo = {cmd(l,da,2'b10,dp), a, {1'b1,rl}, dlen};
    fifo.push_back(crc8(fifo));  // CRC_cmd
    spi_cs_low;
    for (int i=0; i<fifo.size(); i++) spi_out_byte(fifo[i]);
    rdata = new[dlen+1];
    for (int i=0; i<dlen+1; i++) begin  // data + CRC_data
      spi_out_byte(8'h00);
      spi_in_byte(rdata[i]);
    end
    spi_cs_high;
    $display("%10t: SPI_MST read  [%02h] len=%0d", $time, a, dlen);
  endtask

endmodule
