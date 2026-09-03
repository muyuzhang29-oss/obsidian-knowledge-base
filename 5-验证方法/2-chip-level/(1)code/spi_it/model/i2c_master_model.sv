module i2c_master_model (
  inout  wire       scl,
  inout  wire       sda
);

  parameter SCL_HALF = 50;

  reg scl_drv = 1;
  reg sda_drv = 1;
  assign scl = scl_drv ? 1'bz : 1'b0;
  assign sda = sda_drv ? 1'bz : 1'b0;

  task i2c_start();
    sda_drv = 1; scl_drv = 1;
    #(SCL_HALF);
    sda_drv = 0;
    #(SCL_HALF);
    scl_drv = 0;
  endtask

  task i2c_stop();
    sda_drv = 0; scl_drv = 0;
    #(SCL_HALF);
    scl_drv = 1;
    #(SCL_HALF);
    sda_drv = 1;
    #(SCL_HALF);
  endtask

  task i2c_write_byte(input [7:0] dat, output bit ack);
    for (int i = 7; i >= 0; i--) begin
      sda_drv = dat[i];
      #(SCL_HALF);
      scl_drv = 1;
      #(SCL_HALF);
      scl_drv = 0;
    end
    sda_drv = 1;
    #(SCL_HALF);
    scl_drv = 1;
    ack = ~sda;
    #(SCL_HALF);
    scl_drv = 0;
  endtask

  task i2c_read_byte(output [7:0] dat, input bit nack);
    sda_drv = 1;
    for (int i = 7; i >= 0; i--) begin
      #(SCL_HALF);
      scl_drv = 1;
      dat[i] = sda;
      #(SCL_HALF);
      scl_drv = 0;
    end
    sda_drv = nack;
    #(SCL_HALF);
    scl_drv = 1;
    #(SCL_HALF);
    scl_drv = 0;
    sda_drv = 1;
  endtask

  // 8-bit register address (兼容)
  task i2c_wr_reg(input [6:0] slv_addr, input [7:0] reg_addr, input [7:0] dat);
    bit ack;
    i2c_start();
    i2c_write_byte({slv_addr, 1'b0}, ack);
    i2c_write_byte(reg_addr, ack);
    i2c_write_byte(dat, ack);
    i2c_stop();
  endtask

  task i2c_rd_reg(input [6:0] slv_addr, input [7:0] reg_addr, output [7:0] dat);
    bit ack;
    i2c_start();
    i2c_write_byte({slv_addr, 1'b0}, ack);
    i2c_write_byte(reg_addr, ack);
    i2c_start();
    i2c_write_byte({slv_addr, 1'b1}, ack);
    i2c_read_byte(dat, 1);
    i2c_stop();
  endtask

  // 16-bit register address (适配 DUT i2cs: o_reg_adr_std[15:0])
  task i2c_wr_reg16(input [6:0] slv_addr, input [15:0] reg_addr, input [7:0] dat);
    bit ack;
    i2c_start();
    i2c_write_byte({slv_addr, 1'b0}, ack);
    i2c_write_byte(reg_addr[15:8], ack);
    i2c_write_byte(reg_addr[7:0], ack);
    i2c_write_byte(dat, ack);
    i2c_stop();
  endtask

  task i2c_rd_reg16(input [6:0] slv_addr, input [15:0] reg_addr, output [7:0] dat);
    bit ack;
    i2c_start();
    i2c_write_byte({slv_addr, 1'b0}, ack);
    i2c_write_byte(reg_addr[15:8], ack);
    i2c_write_byte(reg_addr[7:0], ack);
    i2c_start();
    i2c_write_byte({slv_addr, 1'b1}, ack);
    i2c_read_byte(dat, 1);
    i2c_stop();
  endtask

endmodule
