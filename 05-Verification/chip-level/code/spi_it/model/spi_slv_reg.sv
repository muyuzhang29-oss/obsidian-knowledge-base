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
reg  r_drive; always @(posedge i_clk) r_drive <= #1 w_drive; // [fix] 寄存一拍, 避开与 w_rd_set 同沿的竞争

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

//------读相位标记: w_rd_set进入读相位, 一直有效到CS↑------
wire w_rd_set = (w_end_byte && r_st == ST_RECV && r_dcnt + 16'h1 >= r_rd_len_plus1) ||
                (r_cs_fal && r_mode && r_rd_len_plus1 == 0);
wire w_rd_clr = r_cs_ris && r_bcnt == 4'h0;

reg  r_rd_flag;
always@(posedge i_clk or negedge i_rst_n)begin
    if(!i_rst_n)
        r_rd_flag   <= #1 1'b0;
    else begin
        if(w_rd_clr)
            r_rd_flag <= #1 1'b0;
        else if(w_rd_set)
            r_rd_flag <= #1 1'b1;
    end
end
wire w_rd_phase = r_rd_flag;

//------MISO 位计数器: 在 r_drive 上递增, w_rd_set时复位------
always@(posedge i_clk or negedge i_rst_n)begin
    if(!i_rst_n)
        r_txbcnt <= #1 4'h0;
    else if(w_rd_set)
        r_txbcnt <= #1 4'h0;
    else if(r_drive && w_rd_phase)
        r_txbcnt <= #1 (r_txbcnt == 4'h7) ? 4'h0 : r_txbcnt + 4'h1;
end
wire [3:0] w_txbcnt = w_rd_set ? 4'h0 : r_txbcnt;

//------第一字节预加载: w_rd_set后延时2 i_clk捕获i_rdata, 跳过txbcnt=0的load------
reg [1:0] r_init_shift;
reg       r_first; // 0=第一字节尚未加载, 跳过txbcnt=0 load
always@(posedge i_clk or negedge i_rst_n)begin
    if(!i_rst_n)begin
        r_init_shift <= 2'b00;
        r_first      <= 1'b0;
    end else begin
        if(w_rd_set) begin
            r_init_shift <= 2'b10; // 启动2拍延时
            r_first      <= 1'b0;  // 第一字节标记
        end else if(w_rd_phase && r_drive && w_txbcnt == 4'h7) begin
            r_first      <= 1'b1;  // 第一字节结束, 后续允许正常load
            r_init_shift <= 2'b00;
        end else if(|r_init_shift) begin
            r_init_shift <= {1'b0, r_init_shift[1]};
        end
    end
end
wire w_init_load = r_init_shift[0]; // 在w_rd_set后第 2个i_clk边沿有效

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
        // MISO 相位开始: 重新发起读, 确保 i_rdata 新鲜
        if(w_rd_set)begin
            o_rd   <= #1 1'b1;
            o_addr <= #1 r_saddr;
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
        end

        //------drive edge:advance counters,drive MISO------
        if(r_drive)begin
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
always@(posedge i_clk) begin
    if(r_drive) $display("DRIVE %0t : w_rd_phase=%b r_txbcnt=%0d w_txbcnt=%0d r_st=%d r_bcnt=%0d",
                         $time,w_rd_phase,r_txbcnt,w_txbcnt,r_st,r_bcnt);
    if(w_sample) $display("SAMPLE %0t : w_rd_phase=%b w_txbcnt=%0d r_bcnt=%0d r_st=%d miso=%b",
                          $time,w_rd_phase,w_txbcnt,r_bcnt,r_st,miso);
    if(w_rd_set) $display("RDSET %0t : i_rdata=%02h r_st=%d r_dcnt=%0d r_rd_len_plus1=%0d",
                          $time,i_rdata,r_st,r_dcnt,r_rd_len_plus1);
    if(r_cs_fal) $display("CSFAL %0t : r_mode=%b r_saddr=%04h o_rd fired",$time,r_mode,r_saddr);
    if(r_cs_ris) $display("CSRIS %0t",$time);
    if(w_rd_phase && r_drive && w_txbcnt==0)
        $display("LOAD %0t : r_txsr <= i_rdata=%02h",$time,i_rdata);
    if(w_rd_phase && r_drive && w_txbcnt==7)
        $display("PREFETCH %0t : o_rd fired, addr increment",$time);
end

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
