// UVM base test for SPI_IT
// Launched via run_test() from the I2C tb (which has SPI integrated)

class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("BASE_TEST", "build_phase started", UVM_LOW)
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("BASE_TEST", $sformatf("end_of_elaboration_phase : %s", get_full_name()), UVM_LOW)
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("BASE_TEST", "run_phase started", UVM_LOW)

    // SPI init with default settings
    spi_init(.cpol(0), .cpha(0), .sck_low(5), .sck_high(5), .ss_dly(2));
    spi_set_crc_mode(0);

    // Override in derived tests
    run_test_scenario();

    `uvm_info("BASE_TEST", "run_phase finished", UVM_LOW)
    phase.drop_objection(this);
  endtask

  // Virtual method — override in derived tests
  virtual task run_test_scenario();
    `uvm_info("BASE_TEST", "Empty run_test_scenario — override in derived test", UVM_MEDIUM)
  endtask

endclass
