`include "tb_define.v"
`include "tb_include.sv"

program base_test;

  initial begin
    #300;  // 等待 rst_n 释放 + DUT 稳定

    // === Phase 1: 初始化 I2C master ===
    $display("%10t: === I2C Master init ===", $time);
    ext_i2c_init;
    $display("%10t: === I2C Master init done ===", $time);

    // === Phase 2: 配置 SPI 控制器 ===
    $display("%10t: === SPI init ===", $time);
    spi_init(.cpol(0), .cpha(0), .sck_low(8'd100), .sck_high(8'd100), .ss_dly(8'd10));
    $display("%10t: === SPI init done ===", $time);

    // === Phase 3: SPI loopback test ===
    test_spi_loopback;

    #1000;
    $finish;
  end

  // SPI loopback: master write → sensor echo back → master read
  task test_spi_loopback;
    reg [7:0] tx_data[0:7];
    reg [7:0] rx_data[0:7];
    integer i;

    tx_data = '{8'hA5, 8'h5A, 8'hFF, 8'h00, 8'h12, 8'h34, 8'hAB, 8'hCD};

    $display("%10t: === SPI loopback test start ===", $time);

    // Master write to sensor (dev_addr = 17'h1_0000 = port0 sensor)
    spi_master_write(.dst_port(5'd0), .dev_addr(17'h1_0000),
                     .wr_data(tx_data), .len(8'd8));

    // Read back from sensor
    spi_master_read(.dst_port(5'd0), .dev_addr(17'h1_0000),
                    .rd_len(7'd8), .data_len(8'd8), .rd_data(rx_data));

    // Check
    for (i = 0; i < 8; i++) begin
      if (rx_data[i] !== tx_data[i]) begin
        $error("Mismatch at byte %0d: tx=%02h rx=%02h", i, tx_data[i], rx_data[i]);
      end
    end
    $display("%10t: === SPI loopback test pass ===", $time);
  endtask

endprogram
