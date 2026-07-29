`timescale 1ns/1ps

module spi_slv_reg(
    input               i_clk,          // 25MHz
    input               i_rst_n,
    input               sclk,
    input               mosi,
    input               cs_n,
    output  wire        miso,
    output  reg [15:0]  o_addr,
    output  reg [7:0]   o_wdata,
    input       [7:0]   i_rdata,
    output  reg         o_wr,
    output  reg         o_rd
);

reg                 r_mode;         //0=write 1=read
reg     [15:0]      r_saddr;        //statr addr
reg     [15:0]      r_rd_len_plus1; // bytes before to receive MISO
reg                 cpol;
reg                 cpha;
reg                 cs_active = 1'b0;

reg                 r_scl_d1;

reg                 r_cs_in;
reg                 r_cs_s1;
reg                 r_cs_s2;
reg                 r_cs_d1;

reg                 r_cs_ris;
reg                 r_cs_fal;

wire w_cs_n  = cs_n ^ cs_active;
always @(posedge i_clk or negedge i_rst_n)
begin
    if (!i_rst_n) begin
        r_scl_d1    <= #1 1'b0;
    end else begin
        r_scl_d1    <= #1 sclk;
    end
end

wire w_scl_ris = ~r_scl_d1 & sclk;
wire w_scl_fal = r_scl_d1 & ~sclk;
always @(posedge i_clk or negedge i_rst_n)
begin
    if (!i_rst_n) begin
        r_cs_in     <= #1 1'b1;
        r_cs_s1     <= #1 1'b1;
        r_cs_s2     <= #1 1'b1;
        r_cs_ris    <= #1 1'b0;
        r_cs_fal    <= #1 1'b0;
    end else begin
        r_cs_s1     <= #1 w_cs_n;
        r_cs_s2     <= #1 r_cs_s1;
        r_cs_in     <= #1 r_cs_s2;

        r_cs_d1     <= #1 r_cs_in;
        r_cs_ris    <= #1 ( r_cs_in & ~r_cs_d1);
        r_cs_fal    <= #1 (~r_cs_in & r_cs_d1);
    end
end

reg r_mos_in;
always @(posedge i_clk or negedge i_rst_n)
begin
    if (!i_rst_n) begin
        r_mos_in    <= #1 1'b0;
    end else begin
        r_mos_in    <= #1 mosi;
    end
end

wire w_sample = (cpha == cpol) ? w_scl_ris:w_scl_fal;
wire w_drive  = (cpha == cpol) ? w_scl_fal:w_scl_ris;

//------bit_counter-------
reg [3:0] r_bcnt;
wire w_end_byte = (r_bcnt == 4'd7) && w_sample;

always@(posedge i_clk or negedge i_rst_n)begin
    if(!i_rst_n)begin
        r_bcnt      <= #1 4'h0;
    end else if(r_cs_fal)begin
        r_bcnt      <= #1 4'h0;
    end else begin
        if(w_sample)begin
            r_bcnt  <= #1(r_bcnt == 4'h7)? 4'h0:(r_bcnt + 4'h1);
        end
    end
end

//------FSM-------
localparam ST_IDLE   = 2'b00;
localparam ST_WDATA  = 2'b01;
localparam ST_RECV   = 2'b10;
localparam ST_RDATA  = 2'b11;

reg [2:0] r_st,r_nx_st;
reg [7:0] r_sr;    //MOSI shift register
reg [15:0]r_dcnt;  //byte counter
reg [7:0] r_txsr;  //MISO shift register
reg [3:0] r_txbcnt;//MISO bit counter (driving edge)

always@(posedge i_clk or negedge i_rst_n)begin
    if(!i_rst_n) r_st <= #1 ST_IDLE;
    else         r_st <= #1 r_nx_st;
end

always@(*)begin
    case(r_st)
    ST_IDLE:begin
        if(r_cs_fal)begin
            if(!r_mode)
                r_nx_st = ST_WDATA;//write
            else if(r_rd_len_plus1 == 0)
                r_nx_st = ST_RDATA;//read
            else
                r_nx_st = ST_RECV;//write
        end else begin
            r_nx_st = ST_IDLE;
        end
    end
    ST_WDATA:begin
        r_nx_st = (r_cs_ris && r_bcnt == 4'h0) ? ST_IDLE:ST_WDATA;
    end
    ST_RECV:begin
        r_nx_st = (r_cs_ris && r_bcnt == 4'h0) ? ST_IDLE:(w_end_byte && r_dcnt + 16'h1 >= r_rd_len_plus1) ? ST_RDATA : ST_RECV;
    end
    ST_RDATA:begin
        r_nx_st = (r_cs_ris && r_bcnt == 4'h0) ? ST_IDLE:ST_RDATA;
    end
    default:begin
        r_nx_st = ST_IDLE;
    end
    endcase
end

//------MISO 位计数器: 在 w_drive 上递增, 进入读相位时复位------
always@(posedge i_clk or negedge i_rst_n)begin
    if(!i_rst_n)
        r_txbcnt <= #1 4'h0;
    else if(w_rd_set)
        r_txbcnt <= #1 4'h0;
    else if(w_drive && w_rd_phase)
        r_txbcnt <= #1 (r_txbcnt == 4'h7) ? 4'h0 : r_txbcnt + 4'h1;
end
// 组合覆写: w_rd_set 拍强制 txbcnt=0 (提前于寄存器更新)
wire [3:0] w_txbcnt = w_rd_set ? 4'h0 : r_txbcnt;

//------读相位标记: 从决定进入ST_RDATA开始一直有效到CS↑------
// w_rd_set 是 w_end_byte 处的一个脉冲; 用 r_rd_set_d1 延长一拍,
// 避免 w_rd_set 变0后 r_rd_flag 尚未更新导致的组合逻辑毛刺
wire w_rd_set = w_end_byte && r_st == ST_RECV && r_dcnt + 16'h1 >= r_rd_len_plus1;
wire w_rd_clr = r_cs_ris && r_bcnt == 4'h0;
reg  r_rd_flag;
reg  r_rd_set_d1;
always@(posedge i_clk or negedge i_rst_n)begin
    if(!i_rst_n)begin
        r_rd_flag   <= #1 1'b0;
        r_rd_set_d1 <= #1 1'b0;
    end else begin
        r_rd_set_d1 <= #1 w_rd_set;
        if(w_rd_clr)
            r_rd_flag <= #1 1'b0;
        else if(w_rd_set)
            r_rd_flag <= #1 1'b1;
    end
end
wire w_rd_phase = r_rd_flag || w_rd_set || r_rd_set_d1;

//------datapath------
always@(posedge i_clk or negedge i_rst_n)begin
    if(!i_rst_n)begin
        r_sr        <= #1 8'h00;
        r_dcnt      <= #1 16'h0000;
        r_txsr      <= #1 8'h00;
        r_mode      <= #1 1'b0;
        r_saddr     <= #1 16'h0000;
        r_rd_len_plus1 <= #1 16'h0000;
        cpol        <= #1 1'b0;
        cpha        <= #1 1'b0;
        cs_active   <= #1 1'b0;
        o_wr        <= #1 1'b0;
        o_addr      <= #1 16'h0000;
        o_wdata     <= #1 8'h00;
        o_rd        <= #1 1'b0;
    end else begin
        o_wr    <= #1 1'b0;
        o_rd    <= #1 1'b0;

        if(r_cs_fal)begin
            r_dcnt  <= #1 16'h0000;
        end

        if(r_cs_fal && r_mode)begin
            o_rd    <= #1 1'b1;
            o_addr  <= #1 r_saddr;
        end

        //------sample edge :capture MOSI------
        if(w_sample)begin
            r_sr <= #1 {r_sr[6:0],r_mos_in};
        end

        if(w_end_byte)begin
            if(r_st == ST_WDATA)begin
                o_wr        <= #1 1'b1;
                o_wdata     <= #1 {r_sr[6:0],r_mos_in};
                o_addr      <= #1 r_saddr + r_dcnt;
                r_dcnt      <= #1 r_dcnt +16'h1;
            end
            if(r_st == ST_RECV)begin
                r_dcnt      <= #1 r_dcnt +16'h1;
            end
            //进入读相位: 预加载第一个MISO字节
            if(w_rd_set)begin
                r_txsr <= #1 i_rdata;
            end
        end

        //------drive edge:advance counters,drive MISO------
        if(w_drive)begin
            if(w_rd_phase)begin
                if(w_txbcnt == 4'h0)begin
                    r_txsr <= #1 i_rdata;
                end else begin
                    r_txsr <= #1 {r_txsr[6:0],1'b0};
                end
                if(w_txbcnt == 4'h7)begin
                    o_addr <= #1 o_addr + 16'h1;
                    o_rd   <= #1 1'b1;
                    r_dcnt <= #1 r_dcnt +16'h1;
                end
            end
        end
    end
end

//------miso output (combinational)------
wire [7:0] r_txsr_next = (w_rd_phase && w_txbcnt == 4'h0) ? i_rdata :
                          (w_rd_phase) ? {r_txsr[6:0],1'b0} : r_txsr;
assign miso = w_cs_n ? 1'bz : (r_mode ? r_txsr_next[7] : 1'b0);

// DEBUG
always@(posedge i_clk) if(w_drive && w_rd_phase)
$display("SLV_DRV %0t : txbcnt = %0d dcnt = %0d txsr = %02h i_rdata = %02h miso = %b",$time,w_txbcnt,r_dcnt,r_txsr,i_rdata,miso);

//TEST
task set_mode(input cpol_i,input cpha_i,input cs_active_i);
    cpol <= #1 cpol_i;
    cpha <= #1 cpha_i;
    cs_active <= #1 cs_active_i;
endtask

task set_write_mode(input [15:0] addr);
    r_mode <= #1 1'b0;
    r_saddr <= #1 addr;
endtask

task set_read_mode(input [15:0] addr,input [15:0] rd_len_plus1);
    r_mode <= #1 1'b1;
    r_saddr <= #1 addr;
    r_rd_len_plus1 <= #1 rd_len_plus1;
endtask

endmodule
