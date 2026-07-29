// SPI random write/read test with randomized config
//   Round-trips: write data → SPIM → sensor, then read back via SPIM → verify
//   Config randomization via cfg_randomize() — override in subclass for custom distributions

class ss12_spi_write_random_test extends base_test;
  `uvm_component_utils(ss12_spi_write_random_test)

  function new(string name = "ss12_spi_write_random_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // ── randomized config (call cfg_randomize() in run_test_scenario) ──
  rand bit        cpol;
  rand bit        cpha;
  rand bit        cs_active;
  rand bit        crc_enable;
  rand int        wr_interval;      // 0 = no interval
  rand int        rd_len_plus1;     // 0 = no pre-data, else N
  rand int        data_len;         // bytes (1..255)
  rand int        num_trans;        // how many write/read rounds (1..32)

  // ── constraints ──
  constraint c_data_len  { data_len inside {[1:255]}; }
  constraint c_interval  { wr_interval inside {[0:8]}; }
  constraint c_rd_len    { rd_len_plus1 inside {[0:8]}; }
  constraint c_num_trans { num_trans inside {[1:32]}; }

  // ── virtual — override for different config distributions ──
  virtual function void cfg_randomize();
    if (!this.randomize())
      `uvm_fatal("TEST", "Randomization failed — override cfg_randomize() in subclass")
  endfunction

  virtual task run_test_scenario();
    int pass_cnt, fail_cnt, seed;
    reg [7:0] wdata[], rdata[], sensor_data[];

    pass_cnt = 0;
    fail_cnt = 0;

    cfg_randomize();

    `uvm_info("TEST", $sformatf("Config: CPOL=%0d CPHA=%0d cs_active=%0d crc=%0d "
                                "wr_interval=%0d rd_len_plus1=%0d data_len=%0d x %0d rounds",
                                cpol, cpha, cs_active, crc_enable,
                                wr_interval, rd_len_plus1, data_len, num_trans), UVM_LOW)

    // ── Apply config to SPI master (via I2C) ──
    spi_init(.cpol(cpol), .cpha(cpha), .sck_low(5), .sck_high(5), .ss_dly(2));
    spi_set_crc_mode(crc_enable);

    // ── Apply config to sensor model ──
    u_sensor.set_mode(cpol, cpha);
    u_sensor.set_cs_active(cs_active);
    u_sensor.set_wr_interval(wr_interval);

    for (int round = 0; round < num_trans; round++) begin
      seed = $urandom();

      // ── Generate random write data ──
      wdata = new[data_len];
      foreach (wdata[i]) wdata[i] = 8'($urandom(seed + i));

      // ── Write via SPI(A) → wrp → SPI(B) → sensor ──
      `uvm_info("TEST", $sformatf("[%0d/%0d] Write %0d bytes @ 16'h%04h",
                round+1, num_trans, data_len, round*data_len), UVM_MEDIUM)
      spi_sensor_write(.addr(16'(round * data_len)), .data(wdata), .len(data_len));

      // ── Sensor self-check: verify write data ──
      u_sensor.read_burst(16'(round * data_len), sensor_data, data_len);
      foreach (wdata[i]) begin
        if (sensor_data[i] !== wdata[i]) begin
          `uvm_error("TEST", $sformatf("WRITE FAIL [%0d][%0d]: exp=0x%02h got=0x%02h",
                     round, i, wdata[i], sensor_data[i]))
          fail_cnt++;
        end else begin
          pass_cnt++;
        end
      end

      // ── Read back via SPI(A) → wrp → SPI(B) → sensor ──
      rdata = new[data_len];
      `uvm_info("TEST", $sformatf("[%0d/%0d] Read %0d bytes @ 16'h%04h (rd_len_plus1=%0d)",
                round+1, num_trans, data_len, round*data_len, rd_len_plus1), UVM_MEDIUM)
      spi_sensor_read(.addr(16'(round * data_len)), .rd_len_plus1(rd_len_plus1),
                      .rdata(rdata));

      // ── Verify read data against sensor memory ──
      u_sensor.read_burst(16'(round * data_len), sensor_data, data_len);
      foreach (rdata[i]) begin
        if (rdata[i] !== sensor_data[i]) begin
          `uvm_error("TEST", $sformatf("READ FAIL [%0d][%0d]: exp=0x%02h got=0x%02h",
                     round, i, sensor_data[i], rdata[i]))
          fail_cnt++;
        end else begin
          pass_cnt++;
        end
      end
    end

    `uvm_info("TEST", $sformatf("=== RESULT: %0d PASS, %0d FAIL (config: CPOL=%0d CPHA=%0d "
                                "cs_active=%0d wr_interval=%0d rd_len_plus1=%0d crc=%0d) ===",
              pass_cnt, fail_cnt,
              cpol, cpha, cs_active, wr_interval, rd_len_plus1, crc_enable), UVM_LOW)

    $display("=== ss12_spi_write_random_test done ===");
  endtask

endclass
