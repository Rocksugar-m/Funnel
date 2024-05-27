`timescale 0.1ns / 0.1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/26 10:58:46
// Design Name: 
// Module Name: attention_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module attention_top (
    input clk,
    input rst_n,
    input [511:0] dina,
    input [511:0] dinb,
    output [11:0] addra,
    output [11:0] addrb,
    output [11:0] addrc,
    output [255:0] doutc
    );
    // K 01; Q:00; V:10; Z:11
    // Parameters
    localparam  PE_NUMBER = 32;
    localparam  IN_DATA_WIDTH = 16;
    localparam  OUT_DATA_WIDTH = 32;
    localparam  INDEX_WIDTH = 9;
    localparam  LOG2_PES = 5;
    localparam  Q_DATA_WIDTH = 4;
    localparam  K_NUMBER = 64;
    localparam  LOG2_K = 6;
    localparam  BLOCK_NUMBER = 16;
    localparam  LOG2_BLOCK_NUMBER = 4;
    localparam  ARRAY_HEIGHT = 16;
    localparam  ARRAY_WIDTH = 32;
    localparam  LOG2_HEIGHT = 4;
    localparam  LOG2_WIDTH = 5;
    
        //Ports
    reg i_cu_start;
    wire [PE_NUMBER*IN_DATA_WIDTH-1:0] i_kv_data2cu;
    
    wire w_sp_gen_over;
    wire w_cu_request_q;
    wire w_cu_request_v;
    wire w_cu_keep_kv;
    wire w_cu_jump_kv;
    wire w_cu_request;
    wire [ARRAY_HEIGHT*IN_DATA_WIDTH-1:0] w_data_bus;
    wire w_data_valid;

    attention_acc # (
        .PE_NUMBER(PE_NUMBER),
        .IN_DATA_WIDTH(IN_DATA_WIDTH),
        .OUT_DATA_WIDTH(OUT_DATA_WIDTH),
        .INDEX_WIDTH(INDEX_WIDTH),
        .LOG2_PES(LOG2_PES),
        .Q_DATA_WIDTH(Q_DATA_WIDTH),
        .K_NUMBER(K_NUMBER),
        .LOG2_K(LOG2_K),
        .BLOCK_NUMBER(BLOCK_NUMBER),
        .LOG2_BLOCK_NUMBER(LOG2_BLOCK_NUMBER),
        .ARRAY_HEIGHT(ARRAY_HEIGHT),
        .ARRAY_WIDTH(ARRAY_WIDTH),
        .LOG2_HEIGHT(LOG2_HEIGHT),
        .LOG2_WIDTH(LOG2_WIDTH)
    ) U_attention_acc (
        .clk(clk),
        .rst_n(rst_n),
        .i_cu_start(i_cu_start),
        .i_q_data2sp(bram_q_sp_rdata),
        .i_k_data2sp(bram_k_sp_rdata),
        .i_data_valid2sp(r_data_valid2sp),
        .i_q_data2cu(bram_qv_cu_rdata),
        .i_kv_data2cu(i_kv_data2cu),
        .i_data_valid2cu(r_data_valid2cu & ~w_cu_jump_kv),
        .o_sp_gen_over(w_sp_gen_over),
        .o_cu_request_q(w_cu_request_q),
        .o_cu_request_v(w_cu_request_v),
        .o_cu_keep_kv(w_cu_keep_kv),
        .o_cu_jump_kv(w_cu_jump_kv),
        .o_cu_over_last(w_cu_request),
        .o_data_bus(w_data_bus),
        .o_data_valid(w_data_valid)
    );

    reg [9:0] r_addr_k, r_addr_v;
    reg [10:0] r_addr_q;
// state machine 1: write K to bram_k
// 0:read K
// 1:read Q for cu
// 2:read V for cu
    reg state_k;

    reg bram_k_wen;
    wire [9:0] bram_k_waddr_cu;
    
    assign bram_k_waddr_cu = r_addr_k - 1; // 写入bram_k的地址
    // 把整个K矩阵取入，取入后释放bram_k的a写端口
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            state_k <= 1'b0;
        end
        else if(r_addr_k == 10'b1111111111) begin
            state_k = 1'b1;
        end
    end
    // 取K矩阵的地址不停+1，直到取完
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_addr_k <= 'b0;
            bram_k_wen <= 'b0;
        end
        else if(state_k == 1'b0) begin
            r_addr_k <= r_addr_k + 1;
            bram_k_wen <= 1'b1;
        end
        else begin
            r_addr_k <= 'b0;
            bram_k_wen <= 1'b0;
        end
    end    
    
// state machine: write Q,V to bram_qv for cu 
// 00: 从b通道读初始Q V
// 01：一大行的最后一块的Q用完，从a通道读Q，这个过程cu在计算S*V  一大行只读一次
// 10：每块V用完，从a通道读V，这个过程cu在计算Q*K  一大行的每一块都需要读V
    
    reg [1:0] state_w_cu;
    reg [5:0] r_counter3;
    reg r_cu_request_v, r_cu_request_q;
    reg r_cu_jump_kv;
    wire [6:0] bram_qv_waddr;
    wire [511:0] bram_qv_wdata;
    
    assign addra = state_k == 1'b0 ? {2'b10, r_addr_k} : 
                   state_w_cu == 2'b01 ? {1'b0, r_addr_q} : {2'b11, r_addr_v};
    
    assign bram_qv_waddr = state_w_cu == 2'b00 ? r_addr_q == 64 ? {1'b1, r_addr_v[5:0]} : {1'b0, r_addr_q[5:0]} : {state_w_cu[1], r_counter3};
    assign bram_qv_wdata = state_w_cu == 2'b00 ? dinb : dina;
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_cu_request_v <= 1'b0;
        end
        else if(w_cu_request_v) begin
            r_cu_request_v <= 1'b1;
        end
        else if(r_counter3 == 63) begin
            r_cu_request_v <= 1'b0;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_cu_request_q <= 'b0;
        end
        else if(w_cu_request_q) begin
            r_cu_request_q <= 1'b1;
        end
        else if(r_counter3 == 63) begin
            r_cu_request_q <= 'b0;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            state_w_cu <= 'b0;
        end
        else if(state_w_cu == 2'b00 & r_addr_v == 63) begin
            state_w_cu <= 2'b10;
        end
        else if(state_w_cu == 2'b01 & w_cu_request_v) begin
            state_w_cu <= 2'b10;
        end
        else if(state_w_cu == 2'b10 & w_cu_request_q) begin
            state_w_cu <= 2'b01;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_cu_jump_kv <= 'b0;
        end
        else begin
            r_cu_jump_kv <= w_cu_jump_kv;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_counter3 <= 'b0;
        end
        else if(w_cu_request_q & w_cu_jump_kv) begin
            r_counter3 <= 'b0;
        end
        else if((state_w_cu == 2'b10) & r_cu_jump_kv) begin
            r_counter3 <= 'b0;
        end
        else if(r_cu_request_v | r_cu_request_q) begin
            r_counter3 <= r_counter3 + 1;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_addr_q <= 'b0;
//            r_addr_v <= 'b0;
        end
        else if(state_w_sp != 2'b00 & state_w_cu == 2'b00 & r_addr_q != 64) begin
            r_addr_q <= r_addr_q + 1;
        end
//        else if(state_w_sp != 2'b00 & state_w_cu == 2'b00 & r_addr_q == 64 & r_addr_v != 64) begin
//            r_addr_v <= r_addr_v + 1;
//        end
//        else if(w_cu_keep_kv) begin
//            r_addr_v <= r_addr_v - 64;
//        end
        else if(w_cu_request_q & w_cu_jump_kv) begin
            r_addr_q <= r_addr_q + 1;
//            r_addr_v <= r_addr_v + 63;
        end
//        else if(w_cu_jump_kv) begin
//            r_addr_v <= r_addr_v + 63;
//        end
        else if(w_cu_request_q | (r_cu_request_q & r_counter3 != 6'b111111)) begin
            r_addr_q <= r_addr_q + 1;
        end
//        else if(w_cu_request_v | (r_cu_request_v & r_counter3 != 6'b111111)) begin
//            r_addr_v <= r_addr_v + 1;
//        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_addr_v <= 'b0;
        end
        else if(state_w_sp != 2'b00 & state_w_cu == 2'b00 & r_addr_q == 64 & r_addr_v != 64) begin
            r_addr_v <= r_addr_v + 1;
        end
        else if(w_cu_keep_kv) begin
            r_addr_v <= r_addr_v - 64;
        end
//        else if(w_cu_request_q & w_cu_jump_kv) begin
//            r_addr_v <= r_addr_v + 63;
//        end
        else if(w_cu_jump_kv) begin
            r_addr_v <= r_addr_v + 63;
        end
        else if(w_cu_request_v | (r_cu_request_v & r_counter3 != 6'b111111)) begin
            r_addr_v <= r_addr_v + 1;
        end
    end
    
// state machine: read Q K V from bram_qv for cu 
    reg r_cu_running;
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            i_cu_start <= 'b0;
        end
        else if(r_cu_running) begin
            i_cu_start <= 1'b0;
        end
        else if(w_sp_gen_over) begin
            i_cu_start <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_cu_running <= 'b0;
        end
        else if(state_k == 1'b0) begin
            r_cu_running <= 1'b0;
        end
        else if(state_k == 1'b1 & i_cu_start) begin
            r_cu_running <= 1'b1;
        end
    end
    
    reg [7:0] r_counter4;
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_counter4 <= 'b0;
        end
        else if(r_counter4 == 131) begin
            r_counter4 <= 'b0;
        end
        else if(w_cu_jump_kv) begin
            r_counter4 <= 'b0;
        end
        else if(r_cu_running) begin
            r_counter4 <= r_counter4 + 1;
        end
    end
    
    reg [9:0] bram_k_cu_raddr;
    reg [6:0] bram_qv_cu_raddr;
    reg r_kv_switch;
    reg r_data_valid2cu;
    wire [511:0] bram_k_cu_rdata;
    wire [511:0] bram_qv_cu_rdata;   
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            bram_qv_cu_raddr <= 'b0;
            r_kv_switch <= 1'b0;
            r_data_valid2cu <= 1'b0;
        end
        else if(r_cu_running & w_cu_jump_kv) begin
            bram_qv_cu_raddr <= 'b0;
            r_data_valid2cu <= 1'b0;
            r_kv_switch <= 1'b0;
        end
        else if(r_cu_running & r_counter4 < 64) begin
            bram_qv_cu_raddr <= bram_qv_cu_raddr + 1;
            r_data_valid2cu <= 1'b1;
            r_kv_switch <= 1'b0;
        end
        else if(r_cu_running & r_counter4 > 66 & r_counter4 < 131) begin
            bram_qv_cu_raddr <= bram_qv_cu_raddr + 1;
            r_data_valid2cu <= 1'b1;
            r_kv_switch <= 1'b1;
        end
        else begin
            r_data_valid2cu <= 1'b0;
            r_kv_switch <= 1'b0;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            bram_k_cu_raddr <= 'b0;
        end
        else if(r_cu_running & w_cu_jump_kv) begin
            bram_k_cu_raddr <= bram_k_cu_raddr + 64;
        end
        else if(r_cu_running & r_counter4 < 64) begin
            bram_k_cu_raddr <= bram_k_cu_raddr + 1;
        end
        else if(r_cu_running & w_cu_keep_kv) begin
            bram_k_cu_raddr <= bram_k_cu_raddr - 64;
        end
    end
    
    assign i_kv_data2cu = r_kv_switch ? bram_qv_cu_rdata : bram_k_cu_rdata;
    
// state machine: write Q to bram_sp for sp 
// 0: initial read 2 blocks
// 1: read 1st block
// 2: read 2nd block
    reg [1:0] state_w_sp;
    reg [10:0] r_addr_q_sp;
    reg [6:0] r_counter1;
    reg r_sp_fetch_en;
    reg bram_q_sp_wea;
    reg [6:0] bram_q_sp_waddr;
    reg r_sp_fetch_wait;

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            r_sp_fetch_wait <= 1'b0;
        end 
        else if(r_sp_fetch_en == 1'b1) begin
            r_sp_fetch_wait <= 1'b1;
        end
        else if(i_cu_start | w_cu_request) begin
            r_sp_fetch_wait <= 1'b0;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            bram_q_sp_wea <= 'b0;
            bram_q_sp_waddr <= 'b0;
        end
        else begin
            bram_q_sp_wea <= state_w_sp == 2'b00 | r_sp_fetch_en;
            bram_q_sp_waddr <= r_counter1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_sp_fetch_en <= 'b0;
        end
        else if((state_w_sp == 2'b01 & r_counter1 == 63) | (state_w_sp == 2'b10 & r_counter1 == 127)) begin
            r_sp_fetch_en <= 0;
        end
        else if(w_sp_gen_over & ~r_sp_fetch_wait) begin
            r_sp_fetch_en <= 1;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_counter1 <= 'b0;
        end
//        else if(r_sp_fetch_en) begin
//            r_counter1 <= 'b0;
//        end
        else if(state_w_sp == 2'b00 | r_sp_fetch_en) begin
            r_counter1 <= r_counter1 + 1;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            state_w_sp <= 'b0;
        end
        else if(state_w_sp == 2'b00 & r_counter1 == 127) begin
            state_w_sp <= 2'b01;
        end
        else if(state_w_sp == 2'b10 & r_counter1 == 127) begin
            state_w_sp <= 2'b01;
        end
        else if(state_w_sp == 2'b01 & r_counter1 == 63) begin
            state_w_sp <= 2'b10;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_addr_q_sp <= 'b0;
        end
        else if(state_w_sp == 2'b00) begin
            r_addr_q_sp <= r_addr_q_sp + 1;
        end
        else if(state_w_sp == 2'b01 & r_sp_fetch_en) begin
            r_addr_q_sp <= r_addr_q_sp + 1;
        end
        else if(state_w_sp == 2'b10 & r_sp_fetch_en) begin
            r_addr_q_sp <= r_addr_q_sp + 1;
        end
    end
    
    assign addrb = state_w_sp != 2'b00 & state_w_cu == 2'b00 & r_addr_q != 64 ? {1'b0, r_addr_q} :
                   state_w_sp != 2'b00 & state_w_cu == 2'b00 & r_addr_v != 64 ? {2'b11, r_addr_v} : {1'b0, r_addr_q_sp};
    
// state machine: read Q from bram_sp for sp
// 00:read 1st block
// 01:read 2nd block
    reg [1:0] state_r_sp;
    reg [5:0] r_counter2;
    reg [3:0] r_block_counter2;
    reg r_cu_request;
    reg r_data_valid2sp;
    wire [6:0] bram_q_sp_raddr;
    wire [9:0] bram_k_sp_raddr;
    wire [255:0] bram_q_sp_rdata;
    wire [511:0] bram_k_sp_rdata;
    wire w_count_over2;
        
    // 为了配合取完K后，开始稀疏矩阵生成
    reg sp_gen_initial, sp_gen_initial_over;
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            sp_gen_initial <= 1'b0;
        end
        else if(w_count_over2) begin
            sp_gen_initial <= 1'b0;
        end
        else if((sp_gen_initial_over == 1'b0 & state_k == 1'b1) | (r_cu_running == 1'b0 &  i_cu_start == 1'b1)) begin
            sp_gen_initial <= 1'b1;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            sp_gen_initial_over <= 1'b0;
        end
        else if(sp_gen_initial == 1'b1) begin
            sp_gen_initial_over <= 1'b1;
        end
    end
    
    assign w_count_over2 = r_block_counter2 == 4'b1111 & r_counter2 == 6'b111111;
    assign bram_q_sp_raddr = {state_r_sp[0], r_counter2};
    assign bram_k_sp_raddr = {r_block_counter2, r_counter2};
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_cu_request <= 'b0;
        end
        else if(w_count_over2) begin
            r_cu_request <= 1'b0;
        end
        else if(w_cu_request) begin
            r_cu_request <= 1'b1;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            state_r_sp <= 'b0;
        end
        else if(state_r_sp == 2'b00 & w_count_over2) begin
            state_r_sp <= 2'b01;
        end
        else if(state_r_sp == 2'b01 & w_count_over2) begin
            state_r_sp <= 2'b00;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_counter2 <= 'b0;
            r_data_valid2sp <= 'b0;
        end
        else if(sp_gen_initial | w_cu_request | r_cu_request) begin
            r_counter2 <= r_counter2 + 1;
            r_data_valid2sp <= 1'b1;
        end
//        else if(state_r_sp == 2'b01 & (w_cu_request | r_cu_request)) begin
//            r_counter2 <= r_counter2 + 1;
//            r_data_valid2sp <= 1'b1;
//        end
        else begin
            r_counter2 <= 'b0;
            r_data_valid2sp <= 1'b0;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_block_counter2 <= 'b0;
        end
        else if(r_counter2 == 6'b111111) begin
            r_block_counter2 <= r_block_counter2 + 1'b1;
        end
    end
    
    wire [9:0] bram_k_addr;
    assign bram_k_addr = state_k ? bram_k_sp_raddr : bram_k_waddr_cu;
    
    blk_mem_k U_blk_mem_k(
        .clka(clk),
        .ena(1'b1),
        .wea(bram_k_wen),
        .addra(bram_k_addr),
        .dina(dina),
        .douta(bram_k_sp_rdata),
        .clkb(clk),
        .enb(1'b1),
        .web(1'b0),
        .addrb(bram_k_cu_raddr),
        .dinb('b0),
        .doutb(bram_k_cu_rdata)
    );
  
    blk_mem_q_sp U_blk_mem_q_sp(
        .clka(clk),
        .ena(1'b1),
        .wea(bram_q_sp_wea),
        .addra(bram_q_sp_waddr),
        .dina(dinb[255:0]),
        .clkb(clk),
        .enb(1'b1),
        .addrb(bram_q_sp_raddr),
        .doutb(bram_q_sp_rdata)
    );
  
    blk_mem_qv_cu U_blk_mem_qv_cu(
        .clka(clk),
        .ena(1'b1),
        .wea(r_cu_request_q | r_cu_request_v | (state_w_sp != 2'b00 & state_w_cu == 2'b00)),
        .addra(bram_qv_waddr),
        .dina(bram_qv_wdata),
        .clkb(clk),
        .enb(1'b1),
        .addrb(bram_qv_cu_raddr),
        .doutb(bram_qv_cu_rdata)
    );
  
    assign doutc = w_data_bus;
    assign addrc = 'b0;
    
endmodule
