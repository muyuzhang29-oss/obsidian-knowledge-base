// SPI write sanity test
//   1. Init SPI master
//   2. Write data to sensor via SPI(B)
//   3. Read back and verify (test 层断言)

class spi_write_test extends base_test;
  `uvm_component_utils(spi_write_test)

  function new(string name = "spi_write_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_test_scenario();
    reg [7:0] wdata[], rdata[], sensor_data[];
    int pass_cnt, fail_cnt;

    pass_cnt = 0;
    fail_cnt = 0;

    // ========================
    // Test 1: Write single byte
    // ========================
    `uvm_info("TEST", "=== Test 1: SPI write single byte ===", UVM_LOW)
    wdata = new[1];  wdata[0] = 8'hA5;
    spi_sensor_write(.addr(16'h0010), .data(wdata), .len(1));

    // sensor 自检: 读回寄存器值 vs 写入值
    u_sensor.read_reg(16'h0010, sensor_data[0]);
    assert (sensor_data[0] === wdata[0]) begin
      `uvm_info("TEST", $sformatf("WRITE CHECK PASS: reg[0010]=0x%02h == 0x%02h",
                sensor_data[0], wdata[0]), UVM_LOW)
      pass_cnt++;
    end else begin
      `uvm_error("TEST", $sformatf("WRITE CHECK FAIL: reg[0010]=0x%02h != 0x%02h",
                 sensor_data[0], wdata[0]))
      fail_cnt++;
    end

    // master 读回比对
    rdata = new[1];
    spi_sensor_read(.addr(16'h0010), .rd_len_plus1(0), .rdata(rdata));
    u_sensor.read_reg(16'h0010, sensor_data[0]);
    assert (rdata[0] === sensor_data[0]) begin
      `uvm_info("TEST", $sformatf("READ CHECK PASS: master=0x%02h == sensor=0x%02h",
                rdata[0], sensor_data[0]), UVM_LOW)
      pass_cnt++;
    end else begin
      `uvm_error("TEST", $sformatf("READ CHECK FAIL: master=0x%02h != sensor=0x%02h",
                 rdata[0], sensor_data[0]))
      fail_cnt++;
    end

    // ========================
    // Test 2: Write multiple bytes
    // ========================
    `uvm_info("TEST", "=== Test 2: SPI write multiple bytes ===", UVM_LOW)
    wdata = new[4];
    for (int i = 0; i < 4; i++) wdata[i] = 8'(i * 16 + i);
    spi_sensor_write(.addr(16'h0020), .data(wdata), .len(4));

    // 逐字节写校验
    for (int i = 0; i < 4; i++) begin
      u_sensor.read_reg(16'h0020 + i, sensor_data[0]);
      assert (sensor_data[0] === wdata[i]) begin
        pass_cnt++;
      end else begin
        `uvm_error("TEST", $sformatf("WRITE FAIL [%0d]: reg=0x%02h != exp=0x%02h",
                   i, sensor_data[0], wdata[i]))
        fail_cnt++;
      end
    end

    // master 读回比对
    rdata = new[4];
    spi_sensor_read(.addr(16'h0020), .rd_len_plus1(0), .rdata(rdata));
    for (int i = 0; i < 4; i++) begin
      u_sensor.read_reg(16'h0020 + i, sensor_data[0]);
      assert (rdata[i] === sensor_data[0]) begin
        pass_cnt++;
      end else begin
        `uvm_error("TEST", $sformatf("READ FAIL [%0d]: master=0x%02h != sensor=0x%02h",
                   i, rdata[i], sensor_data[0]))
        fail_cnt++;
      end
    end

    // ========================
    // Test 3: Write with pre-data before read
    // ========================
    `uvm_info("TEST", "=== Test 3: SPI read with pre-data (rd_len_plus1=2) ===", UVM_LOW)
    wdata = new[2];  wdata[0] = 8'h11;  wdata[1] = 8'h22;
    spi_sensor_write(.addr(16'h0030), .data(wdata), .len(2));

    for (int i = 0; i < 2; i++) begin
      u_sensor.read_reg(16'h0030 + i, sensor_data[0]);
      assert (sensor_data[0] === wdata[i]) begin
        pass_cnt++;
      end else begin
        `uvm_error("TEST", $sformatf("WRITE FAIL [%0d]: reg=0x%02h != exp=0x%02h",
                   i, sensor_data[0], wdata[i]))
        fail_cnt++;
      end
    end

    rdata = new[2];
    spi_sensor_read(.addr(16'h0030), .rd_len_plus1(2), .rdata(rdata));
    for (int i = 0; i < 2; i++) begin
      u_sensor.read_reg(16'h0030 + i, sensor_data[0]);
      assert (rdata[i] === sensor_data[0]) begin
        pass_cnt++;
      end else begin
        `uvm_error("TEST", $sformatf("READ FAIL [%0d]: master=0x%02h != sensor=0x%02h",
                   i, rdata[i], sensor_data[0]))
        fail_cnt++;
      end
    end

    #100;

    // 最终报告
    `uvm_info("TEST", $sformatf("=== RESULT: %0d PASS, %0d FAIL ===",
              pass_cnt, fail_cnt), UVM_LOW)

    $display("=== SPI write test done ===");
  endtask

endclass
