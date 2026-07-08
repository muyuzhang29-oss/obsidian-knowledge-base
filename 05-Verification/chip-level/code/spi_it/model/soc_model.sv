module soc_model (
  input  wire        clk,
  input  wire        rst_n,
  output reg  [7:0]  soc_tx_dat,
  output reg         soc_tx_vld,
  input  wire        soc_tx_rdy,
  input  wire [7:0]  soc_rx_dat,
  input  wire        soc_rx_vld,
  output reg         soc_rx_rdy
);

  bit crc_mode = 0;

  task set_crc_mode(input bit mode);
    crc_mode = mode;
  endtask

  task fifo_put(input [7:0] dat);
    soc_tx_dat = dat;
    soc_tx_vld = 1;
    while (!soc_tx_rdy) @(posedge clk);
    @(posedge clk);
    soc_tx_vld = 0;
  endtask

  task fifo_get(output [7:0] dat);
    soc_rx_rdy = 1;
    while (!soc_rx_vld) @(posedge clk);
    dat = soc_rx_dat;
    @(posedge clk);
    soc_rx_rdy = 0;
  endtask

  task crc_append(ref reg [7:0] fifo_data[$]);
    if (crc_mode == 0) begin
      fifo_data.push_back(calc_crc8(fifo_data));
    end else begin
      reg [15:0] crc = calc_crc16(fifo_data);
      fifo_data.push_back(crc[15:8]);
      fifo_data.push_back(crc[7:0]);
    end
  endtask

  task spi_frame_write(
    input [4:0]  dst_port,
    input [16:0] addr,
    input [7:0]  data[],
    input [7:0]  len
  );
    reg [7:0] fifo_data[$]; fifo_data = {};
    fifo_data.push_back({1'b1, 1'b0, dst_port[2:0], 3'b0});
    fifo_data.push_back(addr[16:9]);
    fifo_data.push_back(addr[8:1]);
    fifo_data.push_back({addr[0], 7'b0});
    fifo_data.push_back({1'b0, 7'b0});
    fifo_data.push_back(len);
    for (int i = 0; i < len; i++) fifo_data.push_back(data[i]);
    crc_append(fifo_data);
    foreach (fifo_data[i]) fifo_put(fifo_data[i]);
  endtask

  task spi_frame_read_no_data(
    input [4:0]  dst_port,
    input [16:0] addr,
    input [6:0]  rd_len,
    input [7:0]  data_len
  );
    reg [7:0] fifo_data[$]; fifo_data = {};
    fifo_data.push_back({1'b1, 1'b1, dst_port[2:0], 3'b0});
    fifo_data.push_back(addr[16:9]);
    fifo_data.push_back(addr[8:1]);
    fifo_data.push_back({addr[0], 7'b0});
    fifo_data.push_back({1'b1, rd_len});
    fifo_data.push_back(data_len);
    crc_append(fifo_data);
    foreach (fifo_data[i]) fifo_put(fifo_data[i]);
  endtask

  task spi_frame_read_with_data(
    input [4:0]  dst_port,
    input [16:0] addr,
    input [6:0]  rd_len,
    input [7:0]  data_len,
    input [7:0]  data[]
  );
    reg [7:0] fifo_data[$]; fifo_data = {};
    fifo_data.push_back({1'b1, 1'b1, dst_port[2:0], 3'b0});
    fifo_data.push_back(addr[16:9]);
    fifo_data.push_back(addr[8:1]);
    fifo_data.push_back({addr[0], 7'b0});
    fifo_data.push_back({1'b1, rd_len});
    fifo_data.push_back(data_len);
    for (int i = 0; i < data_len; i++) fifo_data.push_back(data[i]);
    crc_append(fifo_data);
    foreach (fifo_data[i]) fifo_put(fifo_data[i]);
  endtask

  task spi_frame_recv(output [7:0] rx_buf[], input [7:0] exp_len);
    rx_buf = new[exp_len];
    for (int i = 0; i < exp_len; i++) fifo_get(rx_buf[i]);
  endtask

  function [7:0] calc_crc8(reg [7:0] data[$]);
    reg [7:0] crc = 8'h00;
    foreach (data[i]) begin
      crc = crc ^ data[i];
      repeat (8) begin
        if (crc[7]) crc = {crc[6:0], 1'b0} ^ 8'h07;
        else        crc = {crc[6:0], 1'b0};
      end
    end
    return crc;
  endfunction

  function [15:0] calc_crc16(reg [7:0] data[$]);
    reg [15:0] crc = 16'h0000;
    foreach (data[i]) begin
      crc = crc ^ {data[i], 8'h00};
      repeat (8) begin
        if (crc[15]) crc = {crc[14:0], 1'b0} ^ 16'h8005;
        else         crc = {crc[14:0], 1'b0};
      end
    end
    return crc;
  endfunction

endmodule
