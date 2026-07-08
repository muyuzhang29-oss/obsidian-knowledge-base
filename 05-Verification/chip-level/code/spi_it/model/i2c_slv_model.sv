module i2c_slv_model (
  input  wire        clk,
  input  wire        rst_n,
  inout  wire        scl,
  inout  wire        sda,
  output reg  [5:0]  reg_addr,
  output reg  [7:0]  reg_wr_data,
  output reg         reg_wren,
  output reg         reg_rden,
  input  wire [7:0]  reg_rd_data
);

  parameter SLAVE_ADDR = 7'h30;

  assign scl = 1'bz;

  reg sda_drv;
  assign sda = sda_drv ? 1'bz : 1'b0;

  reg [1:0] scl_s, sda_s;
  wire scl_ris = (scl_s == 2'b01);
  wire scl_fal = (scl_s == 2'b10);
  wire start   = (sda_s == 2'b10) & scl_s[1];
  wire stop    = (sda_s == 2'b01) & scl_s[1];

  always @(posedge clk) begin
    scl_s <= {scl_s[0], scl};
    sda_s <= {sda_s[0], sda};
  end

  typedef enum {IDLE, BYTE_RECV, BYTE_ACK} fsm_t;
  fsm_t fsm;

  reg [7:0] shreg;
  reg [3:0] bit_n;
  reg [7:0] raddr;
  logic have_raddr, is_write;

  reg_wren <= 0;
  reg_rden <= 0;
  sda_drv  <= 1;

  always @(posedge clk) begin
    if (!rst_n) begin
      fsm <= IDLE;
      bit_n <= 0;
      have_raddr <= 0;
      reg_wren <= 0;
      reg_rden <= 0;
      sda_drv <= 1;
    end else if (start) begin
      fsm <= BYTE_RECV;
      bit_n <= 0;
      have_raddr <= 0;
      reg_wren <= 0;
      reg_rden <= 0;
    end else if (stop) begin
      fsm <= IDLE;
      reg_wren <= 0;
      reg_rden <= 0;
      sda_drv <= 1;
    end else case (fsm)
      BYTE_RECV: begin
        if (scl_ris) begin
          shreg <= {shreg[6:0], sda_s[1]};
          bit_n <= bit_n + 1;
          if (bit_n == 8) begin
            fsm <= BYTE_ACK;
            bit_n <= 0;
          end
        end
        if (scl_fal && bit_n < 8) begin
          if (have_raddr && ~is_write) begin
            sda_drv <= reg_rd_data[7 - bit_n];
          end else begin
            sda_drv <= 1'bz;
          end
        end
      end

      BYTE_ACK: begin
        reg_wren <= 0;
        if (scl_ris) begin
          // Sample ACK from master (only meaningful in read mode)
        end
        if (scl_fal) begin
          if (!have_raddr) begin
            if (shreg[7:1] == SLAVE_ADDR) begin
              is_write  <= ~shreg[0];
              have_raddr <= 1;
              sda_drv <= 0;  // ACK
            end else begin
              sda_drv <= 1;  // NACK
              fsm <= IDLE;
            end
          end else if (is_write) begin
            if (raddr == 0) begin
              raddr <= shreg;  // Store register address
              sda_drv <= 0;    // ACK
            end else begin
              reg_addr   <= raddr[5:0];
              reg_wr_data <= shreg;
              reg_wren   <= 1;
              raddr <= 0;
              sda_drv <= 0;  // ACK
            end
          end else begin
            // Read: ACK to continue, data driven in BYTE_RECV
            sda_drv <= 0;
          end
          fsm <= BYTE_RECV;
          bit_n <= 0;
        end
      end
    endcase
  end

endmodule
