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


module attention_acc #(
    parameter PE_NUMBER = 32,
    parameter IN_DATA_WIDTH = 16,
    parameter OUT_DATA_WIDTH = 32,
    parameter INDEX_WIDTH = 9,
    parameter LOG2_PES = 5,
    parameter Q_DATA_WIDTH = 4,
    parameter K_NUMBER = 32,
    parameter LOG2_K = 5,
    parameter BLOCK_NUMBER = 16,
    parameter LOG2_BLOCK_NUMBER = 4,
    parameter ARRAY_HEIGHT = 16,
    parameter ARRAY_WIDTH = 32,
    parameter LOG2_HEIGHT = 4,
    parameter LOG2_WIDTH = 5
    )(
    input clk,
    input rst_n,
    input i_cu_start,
    input [ARRAY_HEIGHT*IN_DATA_WIDTH-1:0] i_q_data2sp,
    input [ARRAY_WIDTH*IN_DATA_WIDTH-1:0] i_k_data2sp,
    input i_data_valid2sp,
    input [PE_NUMBER*IN_DATA_WIDTH-1:0] i_q_data2cu,
    input [PE_NUMBER*IN_DATA_WIDTH-1:0] i_kv_data2cu,
    input i_data_valid2cu,
    output o_sp_gen_over,
    output o_cu_request_q,
    output o_cu_request_v,
    output o_cu_keep_kv,
    output o_cu_jump_kv,
    output o_cu_over_last,
    output [ARRAY_HEIGHT*IN_DATA_WIDTH-1:0] o_data_bus,
    output o_data_valid
    );
    
    reg [(9-LOG2_HEIGHT)-1:0] r_row_prefix2sp;
    wire [(32+ARRAY_HEIGHT*K_NUMBER)*LOG2_PES-1:0] w_block_col;// 修改：索引宽度由INDEX_WIDTH改为LOG2_PES
    wire [(32+ARRAY_HEIGHT*K_NUMBER)*LOG2_HEIGHT-1:0] w_block_row;
    wire [(LOG2_HEIGHT+LOG2_K)*BLOCK_NUMBER-1:0] w_block_count;
    wire [(LOG2_HEIGHT+LOG2_K)*BLOCK_NUMBER-1:0] w_base_index;
//    wire [BLOCK_NUMBER*(K_NUMBER+32)-1:0] w_index_valid;
    wire w_sp_gen_valid;
    
    wire w_qk_over;
    wire w_cu_request;
    wire [ARRAY_HEIGHT*IN_DATA_WIDTH-1:0] w_data_bus;
    wire w_data_valid;
    wire w_cu_over;
    wire jump_last_block;
    assign jump_last_block = r_block_counter == 15 & r_block_count[r_block_counter] == 'b0;
         
    wire [PE_NUMBER*LOG2_HEIGHT-1:0] w_row_index;
    wire [PE_NUMBER*LOG2_PES-1:0] w_col_index;
    wire [PE_NUMBER-1:0] w_pe_en;
    
    sp_att_gen #(
        .IN_DATA_WIDTH(IN_DATA_WIDTH),
        .Q_DATA_WIDTH(Q_DATA_WIDTH),
        .INDEX_WIDTH(INDEX_WIDTH),
        .K_NUMBER(K_NUMBER),
        .LOG2_K(LOG2_K),
        .BLOCK_NUMBER(BLOCK_NUMBER),
        .LOG2_BLOCK_NUMBER(LOG2_BLOCK_NUMBER),
        .ARRAY_HEIGHT(ARRAY_HEIGHT),
        .ARRAY_WIDTH(ARRAY_WIDTH),
        .LOG2_HEIGHT(LOG2_HEIGHT),
        .LOG2_WIDTH(LOG2_WIDTH),
        .LOG2_PES(LOG2_PES)
    ) u_att_gen(
        .clk(clk),
        .rst_n(rst_n),
        .i_start(i_cu_start | (r_last_block & w_cu_over) | jump_last_block),
        .i_row_prefix(r_row_prefix2sp),
        .i_q_data(i_q_data2sp),
        .i_k_data(i_k_data2sp),
        .i_data_valid(i_data_valid2sp),
        .o_block_col(w_block_col),
        .o_block_row(w_block_row),
        .o_block_count(w_block_count),
        .o_base_index(w_base_index),
//        .o_index_valid(w_index_valid),
        .o_valid(w_sp_gen_valid)
    );
    
    reg r_sp_gen_valid;
    
    cu #(
        .NUM_PES(PE_NUMBER),
        .IN_DATA_WIDTH(IN_DATA_WIDTH),
        .OUT_DATA_WIDTH(OUT_DATA_WIDTH),
        .INDEX_WIDTH(INDEX_WIDTH),
        .LOG2_PES(LOG2_PES),
        .ARRAY_HEIGHT(ARRAY_HEIGHT),
        .LOG2_HEIGHT(LOG2_HEIGHT)
    ) U_cu(
        .clk(clk),
        .rst_n(rst_n),
        .i_q_data_bus(i_q_data2cu),
        .i_kv_data_bus(i_kv_data2cu),
        .i_q_index_bus(w_row_index),
        .i_kv_index_bus(w_col_index),
        .i_pe_en(w_pe_en),
        .i_index_valid(r_sp_gen_valid),
        .i_data_valid(i_data_valid2cu),
        .o_qk_over(w_qk_over),
        .o_v_data_request(w_cu_request),
        .o_data_bus(w_data_bus),
        .o_data_valid(w_data_valid),
        .o_over(w_cu_over)
       );
    
    index_parser #(
        .PE_NUMBER(PE_NUMBER),
        .LOG2_HEIGHT(LOG2_HEIGHT),
        .LOG2_PES(LOG2_PES),
        .LOG2_K(LOG2_K)
    ) U_index_parser(
        .i_row_index(r_block_row[r_index*LOG2_HEIGHT +: PE_NUMBER*LOG2_HEIGHT]),
        .i_col_index(r_block_col[r_index*LOG2_PES +: PE_NUMBER*LOG2_PES]),
        .i_remain_count(r_remain_count),
        .o_row_index(w_row_index),
        .o_col_index(w_col_index),
        .o_pe_en(w_pe_en)
    );
        
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_row_prefix2sp <= 'b0;
        end
        else if(w_sp_gen_valid) begin
            r_row_prefix2sp <= r_row_prefix2sp + 1'b1;
        end
    end
    


    reg [(32+ARRAY_HEIGHT*K_NUMBER)*LOG2_PES-1:0] r_block_col;
    reg [(32+ARRAY_HEIGHT*K_NUMBER)*LOG2_HEIGHT-1:0] r_block_row;
    reg [(LOG2_HEIGHT+LOG2_K)-1:0] r_block_count [0:BLOCK_NUMBER-1];
    reg [(LOG2_HEIGHT+LOG2_K)-1:0] r_base_index [0:BLOCK_NUMBER-1];
    wire w_cu_request_v_last;
    
    assign w_cu_request_v_last = (w_last_block & w_cu_request) | jump_last_block;
    
    genvar i;

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_block_col <= 'b0;
            r_block_row <= 'b0;
            r_sp_gen_valid <= 'b0;
        end
        else if(w_sp_gen_valid & (w_cu_request_v_last | i_cu_start)) begin
            r_block_col <= w_block_col;
            r_block_row <= w_block_row;
            r_sp_gen_valid <= 1'b1;
        end
    end
    
    generate
        for(i = 0; i < BLOCK_NUMBER; i = i+1) begin
            always @(posedge clk or negedge rst_n) begin
                if(rst_n == 1'b0) begin
                    r_block_count[i] <= 'b0;
                    r_base_index[i] <= 'b0;
                end
                else if(w_sp_gen_valid & (w_cu_request_v_last | i_cu_start)) begin
                    r_block_count[i] <= w_block_count[i*(LOG2_HEIGHT+LOG2_K) +: (LOG2_HEIGHT+LOG2_K)];
                    r_base_index[i] <= w_base_index[i*(LOG2_HEIGHT+LOG2_K) +: (LOG2_HEIGHT+LOG2_K)];
                end
            end
        end
    endgenerate

    // 一大行的结束标志是最后一块（最后一块的剩余数量<32）且V做完
    reg [LOG2_BLOCK_NUMBER-1:0] r_block_counter;
    reg [(LOG2_HEIGHT+LOG2_K)-1:0] r_remain_count;
    wire w_cu_keep_kv; // 正在做的这一块剩余数量>32
    wire w_cu_jump_kv; // 某块数量为0
    reg [(LOG2_HEIGHT+LOG2_K)-1:0] r_index;

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_block_counter <= 'b0;
        end
        else if(w_sp_gen_valid & (w_cu_request_v_last | i_cu_start)) begin
            r_block_counter <= 'b0;
        end
        else if(w_cu_jump_kv) begin
            r_block_counter <= r_block_counter + 1'b1;
        end
        else if(w_cu_request & r_remain_count <= 32) begin
            r_block_counter <= r_block_counter + 1'b1;
        end
    end    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_remain_count <= 'b0;
            r_index <= 'b0;
        end
        else if(w_sp_gen_valid & (w_cu_request_v_last | i_cu_start)) begin
            r_remain_count <= w_block_count[0 +: (LOG2_HEIGHT+LOG2_K)];
            r_index <= 'b0;
        end
        else if(w_cu_jump_kv) begin
            r_remain_count <= r_block_count[r_block_counter+1];
            r_index <= r_base_index[r_block_counter+1];
        end
        else if(w_cu_request & r_remain_count > 32) begin
            r_remain_count <= r_remain_count - 32;
            r_index <= r_index + 32;
        end
        else if(w_cu_request & r_remain_count <= 32) begin
            r_remain_count <= r_block_count[r_block_counter+1];
            r_index <= r_base_index[r_block_counter+1];
        end
    end   
    
    reg r_cu_running;
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_cu_running <= 'b0;
        end
        else if(i_cu_start) begin
            r_cu_running <= 1'b1;
        end
    end
    
    assign w_cu_jump_kv = r_cu_running & r_block_count[r_block_counter] == 'b0;
    assign w_cu_keep_kv = w_qk_over & (r_remain_count > 32);
    
//    reg [PE_NUMBER*LOG2_PES-1:0] r_block_col [0:2*BLOCK_NUMBER-1]; // (K_NUMBER+32)
//    reg [PE_NUMBER*LOG2_HEIGHT-1:0] r_block_row [0:2*BLOCK_NUMBER-1]; // 修改：索引宽度由INDEX_WIDTH改为LOG2_PES
//    reg [PE_NUMBER-1:0] r_index_valid [0:2*BLOCK_NUMBER-1];    
//    genvar i;
//    generate
//        for(i = 0; i < 2*BLOCK_NUMBER; i = i+1) begin
//            always @(posedge clk or negedge rst_n) begin
//                if(rst_n == 1'b0) begin
//                    r_block_col[i] <= 'b0;
//                    r_block_row[i] <= 'b0;
//                    r_index_valid[i] <= 'b0;
//                    r_sp_gen_valid <= 'b0;
//                end
//                else if(w_sp_gen_valid & (w_cu_request_v_last | i_cu_start)) begin
//                    r_block_col[i] <= w_block_col[i*PE_NUMBER*LOG2_PES +: PE_NUMBER*LOG2_PES];
//                    r_block_row[i] <= w_block_row[i*PE_NUMBER*LOG2_HEIGHT +: PE_NUMBER*LOG2_HEIGHT];
//                    r_index_valid[i] <= w_index_valid[i*PE_NUMBER +: PE_NUMBER];
//                    r_sp_gen_valid <= 1'b1;
//                end
//            end
//        end
//    endgenerate
    
//    reg [4:0] r_index_counter; // 因为为了处理尾巴，为每块多加了32个元素的位置，所以多加的如果空了就要跳过
//    always @(posedge clk or negedge rst_n) begin
//        if(rst_n == 1'b0) begin
//            r_index_counter <= 'b0;
//        end
//        else if(o_cu_request_v & r_index_valid[r_index_counter+1] == 'b0) begin
//            r_index_counter <= r_index_counter + 2;
//        end
//        else if(o_cu_request_v) begin // TODO：check每个大行的最后一块结束后，应该加为0
//            r_index_counter <= r_index_counter + 1;
//        end
//    end
    
    reg r_data_valid;
    reg [6:0] r_counter;
    reg [ARRAY_HEIGHT*IN_DATA_WIDTH-1:0] r_s_row_sum;
//    reg [ARRAY_HEIGHT*OUT_DATA_WIDTH-1:0] r_v_out [0:63];
//    reg [ARRAY_HEIGHT*64*OUT_DATA_WIDTH-1:0] r_v_out;
    reg [64*IN_DATA_WIDTH-1:0] r_v_out [0:ARRAY_HEIGHT-1];
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_data_valid <= 'b0;
        end
        else begin
            r_data_valid <= w_data_valid;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_counter <= 'b0;
        end
        else if(r_counter == 64) begin
            r_counter <= 'b0;
        end
        else if(w_data_valid & r_data_valid) begin
            r_counter <= r_counter + 1;
        end
    end
    
    generate
        for(i = 0; i < ARRAY_HEIGHT; i = i+1) begin
            always @(posedge clk or negedge rst_n) begin
                if(rst_n == 1'b0) begin
                    r_s_row_sum[i*IN_DATA_WIDTH +: IN_DATA_WIDTH] <= 'b0;
                end
                else if(w_data_valid & ~r_data_valid) begin
                    r_s_row_sum[i*IN_DATA_WIDTH +: IN_DATA_WIDTH] <= r_s_row_sum[i*IN_DATA_WIDTH +: IN_DATA_WIDTH] + w_data_bus[i*IN_DATA_WIDTH +: IN_DATA_WIDTH];
                end
            end
        end
    endgenerate
    
    generate
        for(i = 0; i < ARRAY_HEIGHT; i = i+1) begin
            always @(posedge clk or negedge rst_n) begin
                if(rst_n == 1'b0) begin
                    r_v_out[i] <= 'b0;
//                    r_v_out[4*i+1] <= 'b0;
//                    r_v_out[4*i+2] <= 'b0;
//                    r_v_out[4*i+3] <= 'b0;
                end
                else if(w_data_valid & r_data_valid) begin
                    r_v_out[i][r_counter*IN_DATA_WIDTH +: IN_DATA_WIDTH] <= r_v_out[i][r_counter*IN_DATA_WIDTH +: IN_DATA_WIDTH] + w_data_bus[i*IN_DATA_WIDTH +: IN_DATA_WIDTH];
                end
            end
        end
    endgenerate
    
//    generate
//        for(i = 0; i < ARRAY_HEIGHT; i = i+1) begin
//            always @(posedge clk or negedge rst_n) begin
//                if(rst_n == 1'b0) begin
//                    r_v_out <= 'b0;
////                    r_v_out[4*i+1] <= 'b0;
////                    r_v_out[4*i+2] <= 'b0;
////                    r_v_out[4*i+3] <= 'b0;
//                end
//                else if(w_data_valid & r_data_valid) begin
//                    r_v_out[r_counter*i*OUT_DATA_WIDTH +: OUT_DATA_WIDTH] <= r_v_out[r_counter*i*OUT_DATA_WIDTH +: OUT_DATA_WIDTH] + w_data_bus[i*OUT_DATA_WIDTH +: OUT_DATA_WIDTH];
//                end
//            end
//        end
//    endgenerate

//    generate
//        for(i = 0; i < ARRAY_HEIGHT; i = i+1) begin
//            always @(posedge clk or negedge rst_n) begin
//                if(rst_n == 1'b0) begin
//                    r_v_out[4*i+0] <= 'b0;
////                    r_v_out[4*i+1] <= 'b0;
////                    r_v_out[4*i+2] <= 'b0;
////                    r_v_out[4*i+3] <= 'b0;
//                end
//                else if(w_data_valid & r_data_valid) begin
//                    r_v_out[r_counter][i*OUT_DATA_WIDTH +: OUT_DATA_WIDTH] <= r_v_out[r_counter][i*OUT_DATA_WIDTH +: OUT_DATA_WIDTH] + w_data_bus[i*OUT_DATA_WIDTH +: OUT_DATA_WIDTH];
//                end
//            end
//        end
//    endgenerate
    
    wire w_last_block;
    assign w_last_block = r_block_counter == 15 & r_remain_count <= 32;
    
    reg r_last_block;
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_last_block <= 'b0;
        end
        else if(w_last_block == 1'b1) begin
            r_last_block <= 1'b1;
        end
        else if(r_data_valid == 1'b0) begin
            r_last_block <= 'b0;
        end
    end
    
    wire [ARRAY_HEIGHT*IN_DATA_WIDTH-1:0] w_v_out;
    generate
        for(i = 0; i < ARRAY_HEIGHT; i = i+1) begin
            assign w_v_out[i*IN_DATA_WIDTH +: IN_DATA_WIDTH] = r_counter == 'b0 ? 'b0 : r_v_out[i][(r_counter-1)*IN_DATA_WIDTH +: IN_DATA_WIDTH];
        end
    endgenerate
    
    assign o_data_bus = (r_data_valid & (r_counter == 0)) ? r_s_row_sum : w_v_out;
    assign o_data_valid = r_data_valid;
    assign o_sp_gen_over = w_sp_gen_valid;
    assign o_cu_request_q = w_last_block & (w_qk_over | (r_block_count[15] == 'b0));
    assign o_cu_request_v = w_cu_request;
    assign o_cu_jump_kv = w_cu_jump_kv;
    assign o_cu_keep_kv = w_cu_keep_kv;
    assign o_cu_over_last = (r_last_block & w_cu_over) | jump_last_block;
    
endmodule
