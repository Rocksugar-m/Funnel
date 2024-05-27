`timescale 0.1ns / 0.1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2024 12:12:04 AM
// Design Name: 
// Module Name: sp_att_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: index_width: 9 for 512length, 8 for 256length
// 
//////////////////////////////////////////////////////////////////////////////////


module sp_att_gen #(
        parameter IN_DATA_WIDTH = 16,
        parameter Q_DATA_WIDTH = 4,
        parameter INDEX_WIDTH = 9,
        parameter K_NUMBER = 32,
        parameter LOG2_K = 5,
        parameter BLOCK_NUMBER = 16,
        parameter LOG2_BLOCK_NUMBER = 4,
        parameter ARRAY_HEIGHT = 16,
        parameter ARRAY_WIDTH = 32,
        parameter LOG2_HEIGHT = 4,
        parameter LOG2_WIDTH = 5,
        parameter LOG2_PES = 5
    )(
        input clk,
        input rst_n,
        input i_start,
        input [(9-LOG2_HEIGHT)-1:0] i_row_prefix,
        input [ARRAY_HEIGHT*IN_DATA_WIDTH-1:0] i_q_data,
        input [ARRAY_WIDTH*IN_DATA_WIDTH-1:0] i_k_data,
        input i_data_valid,
        output [(32+ARRAY_HEIGHT*K_NUMBER)*LOG2_PES-1:0] o_block_col, // 32：PE_NUMBER // 修改：索引宽度由INDEX_WIDTH改为LOG2_PES
        output [(32+ARRAY_HEIGHT*K_NUMBER)*LOG2_HEIGHT-1:0] o_block_row,
        output [(LOG2_HEIGHT+LOG2_K)*BLOCK_NUMBER-1:0] o_block_count,
        output [(LOG2_HEIGHT+LOG2_K)*BLOCK_NUMBER-1:0] o_base_index,        
//        output [BLOCK_NUMBER*(K_NUMBER+32)-1:0] o_index_valid, // 由于一块的长度设置成了理论稀疏数据量+32，此数据表示一块中有效的位置和空的位置
        output o_valid
    );
    
    localparam signed CMP0 = 16'b1101100000000000;
    localparam signed CMP1 = 16'b1101111000000000;
    localparam signed CMP2 = 16'b1110010000000000;
    localparam signed CMP3 = 16'b1110111000000000;
    localparam signed CMP4 = 16'b1111010000000000; // -3072
    localparam signed CMP5 = 16'b1111101000000000; // -1536
    localparam signed CMP6 = 16'b1111111000000000; // -512
    localparam signed CMP7 = 16'b0000010000000000; // 1024
    localparam signed CMP8 = 16'b0000101000000000; // 2560
    localparam signed CMP9 = 16'b0000111000000000; // 3584
    localparam signed CMP10 = 16'b0001010000000000;// 
    localparam signed CMP11 = 16'b0001100100000000;// 
    localparam signed CMP12 = 16'b0001111100000000;// 
    localparam signed CMP13 = 16'b0010010000000000;// 

    reg [ARRAY_HEIGHT*Q_DATA_WIDTH-1:0] r_q_data;
    reg [ARRAY_WIDTH*Q_DATA_WIDTH-1:0] r_k_data;
    reg r_data_valid;
    genvar i, j;
//    generate
//        for(i = 0; i < ARRAY_HEIGHT; i = i+1) begin
//            always @(posedge clk or negedge rst_n) begin
//                if(rst_n == 1'b0) begin
//                    r_q_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 'b0;
//                end
//                else begin
//                    r_q_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH];
//                end
//            end
//        end
//    endgenerate
    generate
        for(i = 0; i < ARRAY_HEIGHT; i = i+1) begin
            always @(posedge clk or negedge rst_n) begin
                if(rst_n == 1'b0) begin
                    r_q_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 'b0;
                end
                else if($signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP0) begin                
                    r_q_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b1001;
                end
                else if($signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP0 & $signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP1) begin                
                    r_q_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b1010;
                end
                else if($signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP1 & $signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP2) begin                
                    r_q_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b1011;
                end
                else if($signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP2 & $signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP3) begin                
                    r_q_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b1100;
                end
                else if($signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP3 & $signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP4) begin                
                    r_q_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b1101;
                end
                else if($signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP4 & $signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP5) begin                
                    r_q_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b1110;
                end
                else if($signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP5 & $signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP6) begin                
                    r_q_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b1111;
                end
                else if($signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP6 & $signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP7) begin                
                    r_q_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b0000;
                end
                else if($signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP7 & $signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP8) begin                
                    r_q_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b0001;
                end
                else if($signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP8 & $signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP9) begin                
                    r_q_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b0010;
                end
                else if($signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP9 & $signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP10) begin                
                    r_q_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b0011;
                end
                else if($signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP10 & $signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP11) begin                
                    r_q_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b0100;
                end
                else if($signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP11 & $signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP12) begin                
                    r_q_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b0101;
                end
                else if($signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP12 & $signed(i_q_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP13) begin                
                    r_q_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b0110;
                end
                else begin
                    r_q_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b0111;
                end
            end
        end
    endgenerate

//    generate
//        for(i = 0; i < ARRAY_WIDTH; i = i+1) begin
//            always @(posedge clk or negedge rst_n) begin
//                if(rst_n == 1'b0) begin
//                    r_k_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 'b0;
//                end
//                else begin
//                    r_k_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH];
//                end
//            end
//        end
//    endgenerate
    generate
        for(i = 0; i < ARRAY_WIDTH; i = i+1) begin
            always @(posedge clk or negedge rst_n) begin
                if(rst_n == 1'b0) begin
                    r_k_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 'b0;
                end
                else if($signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP0) begin                
                    r_k_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b1001;
                end
                else if($signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP0 & $signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP1) begin                
                    r_k_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b1010;
                end
                else if($signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP1 & $signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP2) begin                
                    r_k_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b1011;
                end
                else if($signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP2 & $signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP3) begin                
                    r_k_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b1100;
                end
                else if($signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP3 & $signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP4) begin                
                    r_k_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b1101;
                end
                else if($signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP4 & $signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP5) begin                
                    r_k_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b1110;
                end
                else if($signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP5 & $signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP6) begin                
                    r_k_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b1111;
                end
                else if($signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP6 & $signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP7) begin                
                    r_k_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b0000;
                end
                else if($signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP7 & $signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP8) begin                
                    r_k_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b0001;
                end
                else if($signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP8 & $signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP9) begin                
                    r_k_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b0010;
                end
                else if($signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP9 & $signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP10) begin                
                    r_k_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b0011;
                end
                else if($signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP10 & $signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP11) begin                
                    r_k_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b0100;
                end
                else if($signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP11 & $signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP12) begin                
                    r_k_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b0101;
                end
                else if($signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) >= CMP12 & $signed(i_k_data[i*IN_DATA_WIDTH +: IN_DATA_WIDTH]) < CMP13) begin                
                    r_k_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b0110;
                end
                else begin
                    r_k_data[i*Q_DATA_WIDTH +: Q_DATA_WIDTH] <= 4'b0111;
                end
            end
        end
    endgenerate
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_data_valid <= 'b0;
        end
        else begin
            r_data_valid <= i_data_valid;
        end
    end
    
    wire [ARRAY_HEIGHT-1:0] w_mdata_valid;
    wire [Q_DATA_WIDTH*2*ARRAY_HEIGHT-1:0] w_mdata_d;
    wire [LOG2_WIDTH*ARRAY_HEIGHT-1:0] w_col_index;
   
    systolic_array #(
        .IN_DATA_WIDTH(Q_DATA_WIDTH),
        .OUT_DATA_WIDTH(Q_DATA_WIDTH*2),
        .LOG2_WIDTH(LOG2_WIDTH),
        .ARRAY_WIDTH(ARRAY_WIDTH),
        .ARRAY_HEIGHT(ARRAY_HEIGHT)
    ) U_systolic_array( 
        .clk(clk),
        .rst_n(rst_n),
        .i_data_v(r_k_data),
        .i_data_h(r_q_data),
        .i_data_valid(r_data_valid),
        .o_data_valid(w_mdata_valid),
        .o_data_d(w_mdata_d),
        .o_col_index(w_col_index)
    );
   
    reg [1+LOG2_BLOCK_NUMBER-1:0] r_col_prefix;
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_col_prefix <= 'b0;
        end
        else if(i_start == 1'b1) begin
            r_col_prefix <= 'b0;
        end
        else if(w_mdata_valid == 16'b1000000000000000) begin
            r_col_prefix <= r_col_prefix + 1'b1;
        end
    end
   
    wire [ARRAY_HEIGHT*K_NUMBER*INDEX_WIDTH-1:0] w_sorted_index;
    wire [BLOCK_NUMBER*(LOG2_WIDTH+1)-1:0] w_row_block_count [0:ARRAY_HEIGHT-1];
    wire [ARRAY_HEIGHT-1:0] w_count_valid; // 每行的每个分块计数完成
    wire [ARRAY_HEIGHT-1:0] w_sort_valid; // 每行的每个分块计数完成
   
    
    generate
        for(i = 0; i < ARRAY_HEIGHT; i = i+1) begin
            insert_sort #(
                .K_NUMBER(K_NUMBER),
                .BLOCK_NUMBER(BLOCK_NUMBER),
                .LOG2_BLOCK_NUMBER(LOG2_BLOCK_NUMBER),
                .LOG2_WIDTH(LOG2_WIDTH),
                .DATA_WIDTH(Q_DATA_WIDTH*2),
                .INDEX_WIDTH(INDEX_WIDTH)
            ) U_insert_sort(
                .clk(clk),
                .rst_n(rst_n),
                .i_valid(w_mdata_valid[i]),
                .i_data(w_mdata_d[i*Q_DATA_WIDTH*2 +: Q_DATA_WIDTH*2]),
                .i_index({r_col_prefix[LOG2_BLOCK_NUMBER-1:0], w_col_index[i*LOG2_WIDTH +: LOG2_WIDTH]}),
                .i_clear(i_start),
                .i_last_block(r_col_prefix == BLOCK_NUMBER),
                .o_valid(w_sort_valid[i]),
                .o_sorted_data(),
                .o_sorted_index(w_sorted_index[i*K_NUMBER*INDEX_WIDTH+:K_NUMBER*INDEX_WIDTH]),
                .o_row_block_count(w_row_block_count[i]),
                .o_count_valid(w_count_valid[i])
            );
        end
    endgenerate
    
//    wire [BLOCK_NUMBER*LOG2_WIDTH-1:0] w_row_block_count_t [0:ARRAY_HEIGHT-1]; // 判断完成每行的每个小块是否是减成了
//    generate
//        for(i = 0; i < ARRAY_HEIGHT; i = i+1) begin
//            for(j = 0; j < BLOCK_NUMBER; j = j+1) begin // 5:LOG2_WIDTH
//                assign w_row_block_count_t[i][j*LOG2_WIDTH +: LOG2_WIDTH] = {5{w_row_block_count[i][(j+1)*(LOG2_WIDTH+1)-1]}} & w_row_block_count[i][j*(LOG2_WIDTH+1) +: LOG2_WIDTH];
//            end
//        end
//    endgenerate
    
    reg [(LOG2_HEIGHT+LOG2_K)-1:0] r_block_count [0:BLOCK_NUMBER-1];
    generate
        for(i = 0; i < BLOCK_NUMBER; i = i+1) begin
            always @(posedge clk or negedge rst_n) begin
                if(rst_n == 1'b0) begin
                    r_block_count[i] <= 'b0;
                end
                else if(i_start) begin
                    r_block_count[i] <= 'b0;
                end
                else begin
                    case(w_count_valid)
                        16'b0000000000000001:begin // 16:ARRAY_HEIGHT   
                            r_block_count[i] <= r_block_count[i] + w_row_block_count[0][i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)];
                        end
                        16'b0000000000000010:begin // ARRAY_HEIGHT
                            r_block_count[i] <= r_block_count[i] + w_row_block_count[1][i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)];
                        end
                        16'b0000000000000100:begin // ARRAY_HEIGHT
                            r_block_count[i] <= r_block_count[i] + w_row_block_count[2][i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)];
                        end
                        16'b0000000000001000:begin // ARRAY_HEIGHT
                            r_block_count[i] <= r_block_count[i] + w_row_block_count[3][i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)];
                        end
                        16'b0000000000010000:begin // ARRAY_HEIGHT
                            r_block_count[i] <= r_block_count[i] + w_row_block_count[4][i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)];
                        end
                        16'b0000000000100000:begin // ARRAY_HEIGHT
                            r_block_count[i] <= r_block_count[i] + w_row_block_count[5][i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)];
                        end
                        16'b0000000001000000:begin // ARRAY_HEIGHT
                            r_block_count[i] <= r_block_count[i] + w_row_block_count[6][i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)];
                        end
                        16'b0000000010000000:begin // ARRAY_HEIGHT
                            r_block_count[i] <= r_block_count[i] + w_row_block_count[7][i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)];
                        end
                        16'b0000000100000000:begin // ARRAY_HEIGHT
                            r_block_count[i] <= r_block_count[i] + w_row_block_count[8][i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)];
                        end
                        16'b0000001000000000:begin // ARRAY_HEIGHT
                            r_block_count[i] <= r_block_count[i] + w_row_block_count[9][i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)];
                        end
                        16'b0000010000000000:begin // ARRAY_HEIGHT
                            r_block_count[i] <= r_block_count[i] + w_row_block_count[10][i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)];
                        end
                        16'b0000100000000000:begin // ARRAY_HEIGHT
                            r_block_count[i] <= r_block_count[i] + w_row_block_count[11][i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)];
                        end
                        16'b0001000000000000:begin // ARRAY_HEIGHT
                            r_block_count[i] <= r_block_count[i] + w_row_block_count[12][i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)];
                        end
                        16'b0010000000000000:begin // ARRAY_HEIGHT
                            r_block_count[i] <= r_block_count[i] + w_row_block_count[13][i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)];
                        end
                        16'b0100000000000000:begin // ARRAY_HEIGHT
                            r_block_count[i] <= r_block_count[i] + w_row_block_count[14][i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)];
                        end
                        16'b1000000000000000:begin // ARRAY_HEIGHT
                            r_block_count[i] <= r_block_count[i] + w_row_block_count[15][i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)];
                        end
                        default:begin
                            r_block_count[i] <= r_block_count[i];
                        end
                    endcase
                end
            end
        end
    endgenerate
    
   reg r_count_finish; // 每个分块计数完成 
    
   always @(posedge clk or negedge rst_n) begin
       if(rst_n == 'b0) begin
           r_count_finish <= 'b0;
       end
       else if(i_start == 1'b1 | o_valid == 1'b1) begin
           r_count_finish <= 'b0;
       end
       else if(w_count_valid[15] == 1'b1) begin
           r_count_finish <= 1'b1;
       end
   end
    
    reg [(LOG2_HEIGHT+LOG2_K)-1:0] r_base_index [0:BLOCK_NUMBER-1];
    reg [LOG2_BLOCK_NUMBER-1:0] r_base_counter;
    wire w_base_finish; // 每个分块计数完成 
    assign w_base_finish = r_base_counter == BLOCK_NUMBER-1 & r_counter != 'd1025; // 修改稀疏度K需要修改结束信号 r_counter！=ARRAY_HEIGHT*K_NUMBER
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 'b0) begin
            r_base_counter <= 'b0;
        end
        else if(i_start == 1'b1) begin
            r_base_counter <= 'b0;
        end
        else if(r_count_finish & (w_base_finish == 1'b0)) begin
            r_base_counter <= r_base_counter + 1'b1;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 'b0) begin
            r_base_index[0] <= 'b0;
            r_base_index[1] <= 'b0;
            r_base_index[2] <= 'b0;
            r_base_index[3] <= 'b0;
            r_base_index[4] <= 'b0;
            r_base_index[5] <= 'b0;
            r_base_index[6] <= 'b0;
            r_base_index[7] <= 'b0;
            r_base_index[8] <= 'b0;
            r_base_index[9] <= 'b0;
            r_base_index[10] <= 'b0;
            r_base_index[11] <= 'b0;
            r_base_index[12] <= 'b0;
            r_base_index[13] <= 'b0;
            r_base_index[14] <= 'b0;
            r_base_index[15] <= 'b0;
        end
        else if(i_start == 1'b1) begin
            r_base_index[0] <= 'b0;
        end
        else if(r_count_finish & (w_base_finish == 1'b0)) begin
            r_base_index[r_base_counter+1] <= r_base_index[r_base_counter] + r_block_count[r_base_counter];
        end
    end    
    
//    reg [(ARRAY_WIDTH+32)*LOG2_PES-1:0] r_block_col[0:BLOCK_NUMBER-1]; // 稀疏率1/16=K_NUMBER/512，结果是1/16 * HEIGHT * WIDTH
//    reg [(ARRAY_WIDTH+32)*LOG2_HEIGHT-1:0] r_block_row[0:BLOCK_NUMBER-1]; // 修改：索引宽度由INDEX_WIDTH改为LOG2_PES
//    reg [(ARRAY_WIDTH+32)-1:0] r_index_valid [0:BLOCK_NUMBER-1];
    reg [LOG2_K+LOG2_HEIGHT+1-1:0] r_counter;
    reg [(LOG2_K+3)-1:0] r_block_counter [0:BLOCK_NUMBER-1]; // 每一块正在赋值的位置
    reg [LOG2_HEIGHT-1:0] r_row_index; // 现在进行判断是哪一块的数据的横坐标
    reg [LOG2_K-1:0] r_row_index_counter; // 每K_NUMBER个列坐标加1
//    reg [LOG2_HEIGHT-1:0] r_block_last_index [0:BLOCK_NUMBER-1]; // 每块最后一个有效数据的横坐标，用于扩展无效数据的行坐标，使得FAN将无效数据0求和到最后一个数据，不影响最终结果
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 'b0) begin
            r_counter <= 'b1;
            r_row_index_counter <= 'b1;
        end
        else if(i_start == 1'b1) begin
            r_counter <= 'b1;
            r_row_index_counter <= 'b1;
        end
        else if(w_base_finish == 1'b1) begin
            r_counter <= r_counter + 1'b1;
            r_row_index_counter <= r_row_index_counter + 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n)  begin
        if(rst_n == 'b0) begin
            r_row_index <= 'b0;
        end
        else if(i_start == 1'b1) begin
            r_row_index <= 'b0;
        end
        else if(r_counter == 1) begin
            r_row_index <= 'b0;
        end
        else if(r_row_index_counter == 'b0) begin
            r_row_index <= r_row_index + 1'b1;
        end
    end
    
    reg [LOG2_PES-1:0] r_block_col [0:32+ARRAY_HEIGHT*K_NUMBER-1];
    reg [LOG2_HEIGHT-1:0] r_block_row [0:32+ARRAY_HEIGHT*K_NUMBER-1];
//    reg [(LOG2_HEIGHT+LOG2_K)-1:0] r_block_counter;
//    reg [LOG2_BLOCK_NUMBER-1:0] r_block_index;
    
//    always @(posedge clk or negedge rst_n) begin
//        if(rst_n == 1'b0) begin
//            r_block_index <= 'b0;
//        end
//        else if(~o_valid & r_count_finish) begin
//            r_block_index <= w_sorted_index[r_counter*INDEX_WIDTH-1 -: 4];
//        end
//    end
    wire [LOG2_BLOCK_NUMBER-1:0] w_block_index;
    assign w_block_index = (~o_valid & r_count_finish) ? w_sorted_index[r_counter*INDEX_WIDTH-1 -: 4] : 'b0;
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_block_counter[0] <= 'b0;
            r_block_counter[1] <= 'b0;
            r_block_counter[2] <= 'b0;
            r_block_counter[3] <= 'b0;
            r_block_counter[4] <= 'b0;
            r_block_counter[5] <= 'b0;
            r_block_counter[6] <= 'b0;
            r_block_counter[7] <= 'b0;
            r_block_counter[8] <= 'b0;
            r_block_counter[9] <= 'b0;
            r_block_counter[10] <= 'b0;
            r_block_counter[11] <= 'b0;
            r_block_counter[12] <= 'b0;
            r_block_counter[13] <= 'b0;
            r_block_counter[14] <= 'b0;
            r_block_counter[15] <= 'b0;
            r_block_col[0] <= 'b0;
            r_block_col[1] <= 'b0;
            r_block_col[2] <= 'b0;
            r_block_col[3] <= 'b0;
            r_block_col[4] <= 'b0;
            r_block_col[5] <= 'b0;
            r_block_col[6] <= 'b0;
            r_block_col[7] <= 'b0;
            r_block_col[8] <= 'b0;
            r_block_col[9] <= 'b0;
            r_block_col[10] <= 'b0;
            r_block_col[11] <= 'b0;
            r_block_col[12] <= 'b0;
            r_block_col[13] <= 'b0;
            r_block_col[14] <= 'b0;
            r_block_col[15] <= 'b0;
            r_block_col[16] <= 'b0;
            r_block_col[17] <= 'b0;
            r_block_col[18] <= 'b0;
            r_block_col[19] <= 'b0;
            r_block_col[20] <= 'b0;
            r_block_col[21] <= 'b0;
            r_block_col[22] <= 'b0;
            r_block_col[23] <= 'b0;
            r_block_col[24] <= 'b0;
            r_block_col[25] <= 'b0;
            r_block_col[26] <= 'b0;
            r_block_col[27] <= 'b0;
            r_block_col[28] <= 'b0;
            r_block_col[29] <= 'b0;
            r_block_col[30] <= 'b0;
            r_block_col[31] <= 'b0;
            r_block_col[32] <= 'b0;
            r_block_col[33] <= 'b0;
            r_block_col[34] <= 'b0;
            r_block_col[35] <= 'b0;
            r_block_col[36] <= 'b0;
            r_block_col[37] <= 'b0;
            r_block_col[38] <= 'b0;
            r_block_col[39] <= 'b0;
            r_block_col[40] <= 'b0;
            r_block_col[41] <= 'b0;
            r_block_col[42] <= 'b0;
            r_block_col[43] <= 'b0;
            r_block_col[44] <= 'b0;
            r_block_col[45] <= 'b0;
            r_block_col[46] <= 'b0;
            r_block_col[47] <= 'b0;
            r_block_col[48] <= 'b0;
            r_block_col[49] <= 'b0;
            r_block_col[50] <= 'b0;
            r_block_col[51] <= 'b0;
            r_block_col[52] <= 'b0;
            r_block_col[53] <= 'b0;
            r_block_col[54] <= 'b0;
            r_block_col[55] <= 'b0;
            r_block_col[56] <= 'b0;
            r_block_col[57] <= 'b0;
            r_block_col[58] <= 'b0;
            r_block_col[59] <= 'b0;
            r_block_col[60] <= 'b0;
            r_block_col[61] <= 'b0;
            r_block_col[62] <= 'b0;
            r_block_col[63] <= 'b0;
            r_block_col[64] <= 'b0;
            r_block_col[65] <= 'b0;
            r_block_col[66] <= 'b0;
            r_block_col[67] <= 'b0;
            r_block_col[68] <= 'b0;
            r_block_col[69] <= 'b0;
            r_block_col[70] <= 'b0;
            r_block_col[71] <= 'b0;
            r_block_col[72] <= 'b0;
            r_block_col[73] <= 'b0;
            r_block_col[74] <= 'b0;
            r_block_col[75] <= 'b0;
            r_block_col[76] <= 'b0;
            r_block_col[77] <= 'b0;
            r_block_col[78] <= 'b0;
            r_block_col[79] <= 'b0;
            r_block_col[80] <= 'b0;
            r_block_col[81] <= 'b0;
            r_block_col[82] <= 'b0;
            r_block_col[83] <= 'b0;
            r_block_col[84] <= 'b0;
            r_block_col[85] <= 'b0;
            r_block_col[86] <= 'b0;
            r_block_col[87] <= 'b0;
            r_block_col[88] <= 'b0;
            r_block_col[89] <= 'b0;
            r_block_col[90] <= 'b0;
            r_block_col[91] <= 'b0;
            r_block_col[92] <= 'b0;
            r_block_col[93] <= 'b0;
            r_block_col[94] <= 'b0;
            r_block_col[95] <= 'b0;
            r_block_col[96] <= 'b0;
            r_block_col[97] <= 'b0;
            r_block_col[98] <= 'b0;
            r_block_col[99] <= 'b0;
            r_block_col[100] <= 'b0;
            r_block_col[101] <= 'b0;
            r_block_col[102] <= 'b0;
            r_block_col[103] <= 'b0;
            r_block_col[104] <= 'b0;
            r_block_col[105] <= 'b0;
            r_block_col[106] <= 'b0;
            r_block_col[107] <= 'b0;
            r_block_col[108] <= 'b0;
            r_block_col[109] <= 'b0;
            r_block_col[110] <= 'b0;
            r_block_col[111] <= 'b0;
            r_block_col[112] <= 'b0;
            r_block_col[113] <= 'b0;
            r_block_col[114] <= 'b0;
            r_block_col[115] <= 'b0;
            r_block_col[116] <= 'b0;
            r_block_col[117] <= 'b0;
            r_block_col[118] <= 'b0;
            r_block_col[119] <= 'b0;
            r_block_col[120] <= 'b0;
            r_block_col[121] <= 'b0;
            r_block_col[122] <= 'b0;
            r_block_col[123] <= 'b0;
            r_block_col[124] <= 'b0;
            r_block_col[125] <= 'b0;
            r_block_col[126] <= 'b0;
            r_block_col[127] <= 'b0;
            r_block_col[128] <= 'b0;
            r_block_col[129] <= 'b0;
            r_block_col[130] <= 'b0;
            r_block_col[131] <= 'b0;
            r_block_col[132] <= 'b0;
            r_block_col[133] <= 'b0;
            r_block_col[134] <= 'b0;
            r_block_col[135] <= 'b0;
            r_block_col[136] <= 'b0;
            r_block_col[137] <= 'b0;
            r_block_col[138] <= 'b0;
            r_block_col[139] <= 'b0;
            r_block_col[140] <= 'b0;
            r_block_col[141] <= 'b0;
            r_block_col[142] <= 'b0;
            r_block_col[143] <= 'b0;
            r_block_col[144] <= 'b0;
            r_block_col[145] <= 'b0;
            r_block_col[146] <= 'b0;
            r_block_col[147] <= 'b0;
            r_block_col[148] <= 'b0;
            r_block_col[149] <= 'b0;
            r_block_col[150] <= 'b0;
            r_block_col[151] <= 'b0;
            r_block_col[152] <= 'b0;
            r_block_col[153] <= 'b0;
            r_block_col[154] <= 'b0;
            r_block_col[155] <= 'b0;
            r_block_col[156] <= 'b0;
            r_block_col[157] <= 'b0;
            r_block_col[158] <= 'b0;
            r_block_col[159] <= 'b0;
            r_block_col[160] <= 'b0;
            r_block_col[161] <= 'b0;
            r_block_col[162] <= 'b0;
            r_block_col[163] <= 'b0;
            r_block_col[164] <= 'b0;
            r_block_col[165] <= 'b0;
            r_block_col[166] <= 'b0;
            r_block_col[167] <= 'b0;
            r_block_col[168] <= 'b0;
            r_block_col[169] <= 'b0;
            r_block_col[170] <= 'b0;
            r_block_col[171] <= 'b0;
            r_block_col[172] <= 'b0;
            r_block_col[173] <= 'b0;
            r_block_col[174] <= 'b0;
            r_block_col[175] <= 'b0;
            r_block_col[176] <= 'b0;
            r_block_col[177] <= 'b0;
            r_block_col[178] <= 'b0;
            r_block_col[179] <= 'b0;
            r_block_col[180] <= 'b0;
            r_block_col[181] <= 'b0;
            r_block_col[182] <= 'b0;
            r_block_col[183] <= 'b0;
            r_block_col[184] <= 'b0;
            r_block_col[185] <= 'b0;
            r_block_col[186] <= 'b0;
            r_block_col[187] <= 'b0;
            r_block_col[188] <= 'b0;
            r_block_col[189] <= 'b0;
            r_block_col[190] <= 'b0;
            r_block_col[191] <= 'b0;
            r_block_col[192] <= 'b0;
            r_block_col[193] <= 'b0;
            r_block_col[194] <= 'b0;
            r_block_col[195] <= 'b0;
            r_block_col[196] <= 'b0;
            r_block_col[197] <= 'b0;
            r_block_col[198] <= 'b0;
            r_block_col[199] <= 'b0;
            r_block_col[200] <= 'b0;
            r_block_col[201] <= 'b0;
            r_block_col[202] <= 'b0;
            r_block_col[203] <= 'b0;
            r_block_col[204] <= 'b0;
            r_block_col[205] <= 'b0;
            r_block_col[206] <= 'b0;
            r_block_col[207] <= 'b0;
            r_block_col[208] <= 'b0;
            r_block_col[209] <= 'b0;
            r_block_col[210] <= 'b0;
            r_block_col[211] <= 'b0;
            r_block_col[212] <= 'b0;
            r_block_col[213] <= 'b0;
            r_block_col[214] <= 'b0;
            r_block_col[215] <= 'b0;
            r_block_col[216] <= 'b0;
            r_block_col[217] <= 'b0;
            r_block_col[218] <= 'b0;
            r_block_col[219] <= 'b0;
            r_block_col[220] <= 'b0;
            r_block_col[221] <= 'b0;
            r_block_col[222] <= 'b0;
            r_block_col[223] <= 'b0;
            r_block_col[224] <= 'b0;
            r_block_col[225] <= 'b0;
            r_block_col[226] <= 'b0;
            r_block_col[227] <= 'b0;
            r_block_col[228] <= 'b0;
            r_block_col[229] <= 'b0;
            r_block_col[230] <= 'b0;
            r_block_col[231] <= 'b0;
            r_block_col[232] <= 'b0;
            r_block_col[233] <= 'b0;
            r_block_col[234] <= 'b0;
            r_block_col[235] <= 'b0;
            r_block_col[236] <= 'b0;
            r_block_col[237] <= 'b0;
            r_block_col[238] <= 'b0;
            r_block_col[239] <= 'b0;
            r_block_col[240] <= 'b0;
            r_block_col[241] <= 'b0;
            r_block_col[242] <= 'b0;
            r_block_col[243] <= 'b0;
            r_block_col[244] <= 'b0;
            r_block_col[245] <= 'b0;
            r_block_col[246] <= 'b0;
            r_block_col[247] <= 'b0;
            r_block_col[248] <= 'b0;
            r_block_col[249] <= 'b0;
            r_block_col[250] <= 'b0;
            r_block_col[251] <= 'b0;
            r_block_col[252] <= 'b0;
            r_block_col[253] <= 'b0;
            r_block_col[254] <= 'b0;
            r_block_col[255] <= 'b0;
            r_block_col[256] <= 'b0;
            r_block_col[257] <= 'b0;
            r_block_col[258] <= 'b0;
            r_block_col[259] <= 'b0;
            r_block_col[260] <= 'b0;
            r_block_col[261] <= 'b0;
            r_block_col[262] <= 'b0;
            r_block_col[263] <= 'b0;
            r_block_col[264] <= 'b0;
            r_block_col[265] <= 'b0;
            r_block_col[266] <= 'b0;
            r_block_col[267] <= 'b0;
            r_block_col[268] <= 'b0;
            r_block_col[269] <= 'b0;
            r_block_col[270] <= 'b0;
            r_block_col[271] <= 'b0;
            r_block_col[272] <= 'b0;
            r_block_col[273] <= 'b0;
            r_block_col[274] <= 'b0;
            r_block_col[275] <= 'b0;
            r_block_col[276] <= 'b0;
            r_block_col[277] <= 'b0;
            r_block_col[278] <= 'b0;
            r_block_col[279] <= 'b0;
            r_block_col[280] <= 'b0;
            r_block_col[281] <= 'b0;
            r_block_col[282] <= 'b0;
            r_block_col[283] <= 'b0;
            r_block_col[284] <= 'b0;
            r_block_col[285] <= 'b0;
            r_block_col[286] <= 'b0;
            r_block_col[287] <= 'b0;
            r_block_col[288] <= 'b0;
            r_block_col[289] <= 'b0;
            r_block_col[290] <= 'b0;
            r_block_col[291] <= 'b0;
            r_block_col[292] <= 'b0;
            r_block_col[293] <= 'b0;
            r_block_col[294] <= 'b0;
            r_block_col[295] <= 'b0;
            r_block_col[296] <= 'b0;
            r_block_col[297] <= 'b0;
            r_block_col[298] <= 'b0;
            r_block_col[299] <= 'b0;
            r_block_col[300] <= 'b0;
            r_block_col[301] <= 'b0;
            r_block_col[302] <= 'b0;
            r_block_col[303] <= 'b0;
            r_block_col[304] <= 'b0;
            r_block_col[305] <= 'b0;
            r_block_col[306] <= 'b0;
            r_block_col[307] <= 'b0;
            r_block_col[308] <= 'b0;
            r_block_col[309] <= 'b0;
            r_block_col[310] <= 'b0;
            r_block_col[311] <= 'b0;
            r_block_col[312] <= 'b0;
            r_block_col[313] <= 'b0;
            r_block_col[314] <= 'b0;
            r_block_col[315] <= 'b0;
            r_block_col[316] <= 'b0;
            r_block_col[317] <= 'b0;
            r_block_col[318] <= 'b0;
            r_block_col[319] <= 'b0;
            r_block_col[320] <= 'b0;
            r_block_col[321] <= 'b0;
            r_block_col[322] <= 'b0;
            r_block_col[323] <= 'b0;
            r_block_col[324] <= 'b0;
            r_block_col[325] <= 'b0;
            r_block_col[326] <= 'b0;
            r_block_col[327] <= 'b0;
            r_block_col[328] <= 'b0;
            r_block_col[329] <= 'b0;
            r_block_col[330] <= 'b0;
            r_block_col[331] <= 'b0;
            r_block_col[332] <= 'b0;
            r_block_col[333] <= 'b0;
            r_block_col[334] <= 'b0;
            r_block_col[335] <= 'b0;
            r_block_col[336] <= 'b0;
            r_block_col[337] <= 'b0;
            r_block_col[338] <= 'b0;
            r_block_col[339] <= 'b0;
            r_block_col[340] <= 'b0;
            r_block_col[341] <= 'b0;
            r_block_col[342] <= 'b0;
            r_block_col[343] <= 'b0;
            r_block_col[344] <= 'b0;
            r_block_col[345] <= 'b0;
            r_block_col[346] <= 'b0;
            r_block_col[347] <= 'b0;
            r_block_col[348] <= 'b0;
            r_block_col[349] <= 'b0;
            r_block_col[350] <= 'b0;
            r_block_col[351] <= 'b0;
            r_block_col[352] <= 'b0;
            r_block_col[353] <= 'b0;
            r_block_col[354] <= 'b0;
            r_block_col[355] <= 'b0;
            r_block_col[356] <= 'b0;
            r_block_col[357] <= 'b0;
            r_block_col[358] <= 'b0;
            r_block_col[359] <= 'b0;
            r_block_col[360] <= 'b0;
            r_block_col[361] <= 'b0;
            r_block_col[362] <= 'b0;
            r_block_col[363] <= 'b0;
            r_block_col[364] <= 'b0;
            r_block_col[365] <= 'b0;
            r_block_col[366] <= 'b0;
            r_block_col[367] <= 'b0;
            r_block_col[368] <= 'b0;
            r_block_col[369] <= 'b0;
            r_block_col[370] <= 'b0;
            r_block_col[371] <= 'b0;
            r_block_col[372] <= 'b0;
            r_block_col[373] <= 'b0;
            r_block_col[374] <= 'b0;
            r_block_col[375] <= 'b0;
            r_block_col[376] <= 'b0;
            r_block_col[377] <= 'b0;
            r_block_col[378] <= 'b0;
            r_block_col[379] <= 'b0;
            r_block_col[380] <= 'b0;
            r_block_col[381] <= 'b0;
            r_block_col[382] <= 'b0;
            r_block_col[383] <= 'b0;
            r_block_col[384] <= 'b0;
            r_block_col[385] <= 'b0;
            r_block_col[386] <= 'b0;
            r_block_col[387] <= 'b0;
            r_block_col[388] <= 'b0;
            r_block_col[389] <= 'b0;
            r_block_col[390] <= 'b0;
            r_block_col[391] <= 'b0;
            r_block_col[392] <= 'b0;
            r_block_col[393] <= 'b0;
            r_block_col[394] <= 'b0;
            r_block_col[395] <= 'b0;
            r_block_col[396] <= 'b0;
            r_block_col[397] <= 'b0;
            r_block_col[398] <= 'b0;
            r_block_col[399] <= 'b0;
            r_block_col[400] <= 'b0;
            r_block_col[401] <= 'b0;
            r_block_col[402] <= 'b0;
            r_block_col[403] <= 'b0;
            r_block_col[404] <= 'b0;
            r_block_col[405] <= 'b0;
            r_block_col[406] <= 'b0;
            r_block_col[407] <= 'b0;
            r_block_col[408] <= 'b0;
            r_block_col[409] <= 'b0;
            r_block_col[410] <= 'b0;
            r_block_col[411] <= 'b0;
            r_block_col[412] <= 'b0;
            r_block_col[413] <= 'b0;
            r_block_col[414] <= 'b0;
            r_block_col[415] <= 'b0;
            r_block_col[416] <= 'b0;
            r_block_col[417] <= 'b0;
            r_block_col[418] <= 'b0;
            r_block_col[419] <= 'b0;
            r_block_col[420] <= 'b0;
            r_block_col[421] <= 'b0;
            r_block_col[422] <= 'b0;
            r_block_col[423] <= 'b0;
            r_block_col[424] <= 'b0;
            r_block_col[425] <= 'b0;
            r_block_col[426] <= 'b0;
            r_block_col[427] <= 'b0;
            r_block_col[428] <= 'b0;
            r_block_col[429] <= 'b0;
            r_block_col[430] <= 'b0;
            r_block_col[431] <= 'b0;
            r_block_col[432] <= 'b0;
            r_block_col[433] <= 'b0;
            r_block_col[434] <= 'b0;
            r_block_col[435] <= 'b0;
            r_block_col[436] <= 'b0;
            r_block_col[437] <= 'b0;
            r_block_col[438] <= 'b0;
            r_block_col[439] <= 'b0;
            r_block_col[440] <= 'b0;
            r_block_col[441] <= 'b0;
            r_block_col[442] <= 'b0;
            r_block_col[443] <= 'b0;
            r_block_col[444] <= 'b0;
            r_block_col[445] <= 'b0;
            r_block_col[446] <= 'b0;
            r_block_col[447] <= 'b0;
            r_block_col[448] <= 'b0;
            r_block_col[449] <= 'b0;
            r_block_col[450] <= 'b0;
            r_block_col[451] <= 'b0;
            r_block_col[452] <= 'b0;
            r_block_col[453] <= 'b0;
            r_block_col[454] <= 'b0;
            r_block_col[455] <= 'b0;
            r_block_col[456] <= 'b0;
            r_block_col[457] <= 'b0;
            r_block_col[458] <= 'b0;
            r_block_col[459] <= 'b0;
            r_block_col[460] <= 'b0;
            r_block_col[461] <= 'b0;
            r_block_col[462] <= 'b0;
            r_block_col[463] <= 'b0;
            r_block_col[464] <= 'b0;
            r_block_col[465] <= 'b0;
            r_block_col[466] <= 'b0;
            r_block_col[467] <= 'b0;
            r_block_col[468] <= 'b0;
            r_block_col[469] <= 'b0;
            r_block_col[470] <= 'b0;
            r_block_col[471] <= 'b0;
            r_block_col[472] <= 'b0;
            r_block_col[473] <= 'b0;
            r_block_col[474] <= 'b0;
            r_block_col[475] <= 'b0;
            r_block_col[476] <= 'b0;
            r_block_col[477] <= 'b0;
            r_block_col[478] <= 'b0;
            r_block_col[479] <= 'b0;
            r_block_col[480] <= 'b0;
            r_block_col[481] <= 'b0;
            r_block_col[482] <= 'b0;
            r_block_col[483] <= 'b0;
            r_block_col[484] <= 'b0;
            r_block_col[485] <= 'b0;
            r_block_col[486] <= 'b0;
            r_block_col[487] <= 'b0;
            r_block_col[488] <= 'b0;
            r_block_col[489] <= 'b0;
            r_block_col[490] <= 'b0;
            r_block_col[491] <= 'b0;
            r_block_col[492] <= 'b0;
            r_block_col[493] <= 'b0;
            r_block_col[494] <= 'b0;
            r_block_col[495] <= 'b0;
            r_block_col[496] <= 'b0;
            r_block_col[497] <= 'b0;
            r_block_col[498] <= 'b0;
            r_block_col[499] <= 'b0;
            r_block_col[500] <= 'b0;
            r_block_col[501] <= 'b0;
            r_block_col[502] <= 'b0;
            r_block_col[503] <= 'b0;
            r_block_col[504] <= 'b0;
            r_block_col[505] <= 'b0;
            r_block_col[506] <= 'b0;
            r_block_col[507] <= 'b0;
            r_block_col[508] <= 'b0;
            r_block_col[509] <= 'b0;
            r_block_col[510] <= 'b0;
            r_block_col[511] <= 'b0;
            r_block_col[512] <= 'b0;
            r_block_col[513] <= 'b0;
            r_block_col[514] <= 'b0;
            r_block_col[515] <= 'b0;
            r_block_col[516] <= 'b0;
            r_block_col[517] <= 'b0;
            r_block_col[518] <= 'b0;
            r_block_col[519] <= 'b0;
            r_block_col[520] <= 'b0;
            r_block_col[521] <= 'b0;
            r_block_col[522] <= 'b0;
            r_block_col[523] <= 'b0;
            r_block_col[524] <= 'b0;
            r_block_col[525] <= 'b0;
            r_block_col[526] <= 'b0;
            r_block_col[527] <= 'b0;
            r_block_col[528] <= 'b0;
            r_block_col[529] <= 'b0;
            r_block_col[530] <= 'b0;
            r_block_col[531] <= 'b0;
            r_block_col[532] <= 'b0;
            r_block_col[533] <= 'b0;
            r_block_col[534] <= 'b0;
            r_block_col[535] <= 'b0;
            r_block_col[536] <= 'b0;
            r_block_col[537] <= 'b0;
            r_block_col[538] <= 'b0;
            r_block_col[539] <= 'b0;
            r_block_col[540] <= 'b0;
            r_block_col[541] <= 'b0;
            r_block_col[542] <= 'b0;
            r_block_col[543] <= 'b0;
            r_block_col[544] <= 'b0;
            r_block_col[545] <= 'b0;
            r_block_col[546] <= 'b0;
            r_block_col[547] <= 'b0;
            r_block_col[548] <= 'b0;
            r_block_col[549] <= 'b0;
            r_block_col[550] <= 'b0;
            r_block_col[551] <= 'b0;
            r_block_col[552] <= 'b0;
            r_block_col[553] <= 'b0;
            r_block_col[554] <= 'b0;
            r_block_col[555] <= 'b0;
            r_block_col[556] <= 'b0;
            r_block_col[557] <= 'b0;
            r_block_col[558] <= 'b0;
            r_block_col[559] <= 'b0;
            r_block_col[560] <= 'b0;
            r_block_col[561] <= 'b0;
            r_block_col[562] <= 'b0;
            r_block_col[563] <= 'b0;
            r_block_col[564] <= 'b0;
            r_block_col[565] <= 'b0;
            r_block_col[566] <= 'b0;
            r_block_col[567] <= 'b0;
            r_block_col[568] <= 'b0;
            r_block_col[569] <= 'b0;
            r_block_col[570] <= 'b0;
            r_block_col[571] <= 'b0;
            r_block_col[572] <= 'b0;
            r_block_col[573] <= 'b0;
            r_block_col[574] <= 'b0;
            r_block_col[575] <= 'b0;
            r_block_col[576] <= 'b0;
            r_block_col[577] <= 'b0;
            r_block_col[578] <= 'b0;
            r_block_col[579] <= 'b0;
            r_block_col[580] <= 'b0;
            r_block_col[581] <= 'b0;
            r_block_col[582] <= 'b0;
            r_block_col[583] <= 'b0;
            r_block_col[584] <= 'b0;
            r_block_col[585] <= 'b0;
            r_block_col[586] <= 'b0;
            r_block_col[587] <= 'b0;
            r_block_col[588] <= 'b0;
            r_block_col[589] <= 'b0;
            r_block_col[590] <= 'b0;
            r_block_col[591] <= 'b0;
            r_block_col[592] <= 'b0;
            r_block_col[593] <= 'b0;
            r_block_col[594] <= 'b0;
            r_block_col[595] <= 'b0;
            r_block_col[596] <= 'b0;
            r_block_col[597] <= 'b0;
            r_block_col[598] <= 'b0;
            r_block_col[599] <= 'b0;
            r_block_col[600] <= 'b0;
            r_block_col[601] <= 'b0;
            r_block_col[602] <= 'b0;
            r_block_col[603] <= 'b0;
            r_block_col[604] <= 'b0;
            r_block_col[605] <= 'b0;
            r_block_col[606] <= 'b0;
            r_block_col[607] <= 'b0;
            r_block_col[608] <= 'b0;
            r_block_col[609] <= 'b0;
            r_block_col[610] <= 'b0;
            r_block_col[611] <= 'b0;
            r_block_col[612] <= 'b0;
            r_block_col[613] <= 'b0;
            r_block_col[614] <= 'b0;
            r_block_col[615] <= 'b0;
            r_block_col[616] <= 'b0;
            r_block_col[617] <= 'b0;
            r_block_col[618] <= 'b0;
            r_block_col[619] <= 'b0;
            r_block_col[620] <= 'b0;
            r_block_col[621] <= 'b0;
            r_block_col[622] <= 'b0;
            r_block_col[623] <= 'b0;
            r_block_col[624] <= 'b0;
            r_block_col[625] <= 'b0;
            r_block_col[626] <= 'b0;
            r_block_col[627] <= 'b0;
            r_block_col[628] <= 'b0;
            r_block_col[629] <= 'b0;
            r_block_col[630] <= 'b0;
            r_block_col[631] <= 'b0;
            r_block_col[632] <= 'b0;
            r_block_col[633] <= 'b0;
            r_block_col[634] <= 'b0;
            r_block_col[635] <= 'b0;
            r_block_col[636] <= 'b0;
            r_block_col[637] <= 'b0;
            r_block_col[638] <= 'b0;
            r_block_col[639] <= 'b0;
            r_block_col[640] <= 'b0;
            r_block_col[641] <= 'b0;
            r_block_col[642] <= 'b0;
            r_block_col[643] <= 'b0;
            r_block_col[644] <= 'b0;
            r_block_col[645] <= 'b0;
            r_block_col[646] <= 'b0;
            r_block_col[647] <= 'b0;
            r_block_col[648] <= 'b0;
            r_block_col[649] <= 'b0;
            r_block_col[650] <= 'b0;
            r_block_col[651] <= 'b0;
            r_block_col[652] <= 'b0;
            r_block_col[653] <= 'b0;
            r_block_col[654] <= 'b0;
            r_block_col[655] <= 'b0;
            r_block_col[656] <= 'b0;
            r_block_col[657] <= 'b0;
            r_block_col[658] <= 'b0;
            r_block_col[659] <= 'b0;
            r_block_col[660] <= 'b0;
            r_block_col[661] <= 'b0;
            r_block_col[662] <= 'b0;
            r_block_col[663] <= 'b0;
            r_block_col[664] <= 'b0;
            r_block_col[665] <= 'b0;
            r_block_col[666] <= 'b0;
            r_block_col[667] <= 'b0;
            r_block_col[668] <= 'b0;
            r_block_col[669] <= 'b0;
            r_block_col[670] <= 'b0;
            r_block_col[671] <= 'b0;
            r_block_col[672] <= 'b0;
            r_block_col[673] <= 'b0;
            r_block_col[674] <= 'b0;
            r_block_col[675] <= 'b0;
            r_block_col[676] <= 'b0;
            r_block_col[677] <= 'b0;
            r_block_col[678] <= 'b0;
            r_block_col[679] <= 'b0;
            r_block_col[680] <= 'b0;
            r_block_col[681] <= 'b0;
            r_block_col[682] <= 'b0;
            r_block_col[683] <= 'b0;
            r_block_col[684] <= 'b0;
            r_block_col[685] <= 'b0;
            r_block_col[686] <= 'b0;
            r_block_col[687] <= 'b0;
            r_block_col[688] <= 'b0;
            r_block_col[689] <= 'b0;
            r_block_col[690] <= 'b0;
            r_block_col[691] <= 'b0;
            r_block_col[692] <= 'b0;
            r_block_col[693] <= 'b0;
            r_block_col[694] <= 'b0;
            r_block_col[695] <= 'b0;
            r_block_col[696] <= 'b0;
            r_block_col[697] <= 'b0;
            r_block_col[698] <= 'b0;
            r_block_col[699] <= 'b0;
            r_block_col[700] <= 'b0;
            r_block_col[701] <= 'b0;
            r_block_col[702] <= 'b0;
            r_block_col[703] <= 'b0;
            r_block_col[704] <= 'b0;
            r_block_col[705] <= 'b0;
            r_block_col[706] <= 'b0;
            r_block_col[707] <= 'b0;
            r_block_col[708] <= 'b0;
            r_block_col[709] <= 'b0;
            r_block_col[710] <= 'b0;
            r_block_col[711] <= 'b0;
            r_block_col[712] <= 'b0;
            r_block_col[713] <= 'b0;
            r_block_col[714] <= 'b0;
            r_block_col[715] <= 'b0;
            r_block_col[716] <= 'b0;
            r_block_col[717] <= 'b0;
            r_block_col[718] <= 'b0;
            r_block_col[719] <= 'b0;
            r_block_col[720] <= 'b0;
            r_block_col[721] <= 'b0;
            r_block_col[722] <= 'b0;
            r_block_col[723] <= 'b0;
            r_block_col[724] <= 'b0;
            r_block_col[725] <= 'b0;
            r_block_col[726] <= 'b0;
            r_block_col[727] <= 'b0;
            r_block_col[728] <= 'b0;
            r_block_col[729] <= 'b0;
            r_block_col[730] <= 'b0;
            r_block_col[731] <= 'b0;
            r_block_col[732] <= 'b0;
            r_block_col[733] <= 'b0;
            r_block_col[734] <= 'b0;
            r_block_col[735] <= 'b0;
            r_block_col[736] <= 'b0;
            r_block_col[737] <= 'b0;
            r_block_col[738] <= 'b0;
            r_block_col[739] <= 'b0;
            r_block_col[740] <= 'b0;
            r_block_col[741] <= 'b0;
            r_block_col[742] <= 'b0;
            r_block_col[743] <= 'b0;
            r_block_col[744] <= 'b0;
            r_block_col[745] <= 'b0;
            r_block_col[746] <= 'b0;
            r_block_col[747] <= 'b0;
            r_block_col[748] <= 'b0;
            r_block_col[749] <= 'b0;
            r_block_col[750] <= 'b0;
            r_block_col[751] <= 'b0;
            r_block_col[752] <= 'b0;
            r_block_col[753] <= 'b0;
            r_block_col[754] <= 'b0;
            r_block_col[755] <= 'b0;
            r_block_col[756] <= 'b0;
            r_block_col[757] <= 'b0;
            r_block_col[758] <= 'b0;
            r_block_col[759] <= 'b0;
            r_block_col[760] <= 'b0;
            r_block_col[761] <= 'b0;
            r_block_col[762] <= 'b0;
            r_block_col[763] <= 'b0;
            r_block_col[764] <= 'b0;
            r_block_col[765] <= 'b0;
            r_block_col[766] <= 'b0;
            r_block_col[767] <= 'b0;
            r_block_col[768] <= 'b0;
            r_block_col[769] <= 'b0;
            r_block_col[770] <= 'b0;
            r_block_col[771] <= 'b0;
            r_block_col[772] <= 'b0;
            r_block_col[773] <= 'b0;
            r_block_col[774] <= 'b0;
            r_block_col[775] <= 'b0;
            r_block_col[776] <= 'b0;
            r_block_col[777] <= 'b0;
            r_block_col[778] <= 'b0;
            r_block_col[779] <= 'b0;
            r_block_col[780] <= 'b0;
            r_block_col[781] <= 'b0;
            r_block_col[782] <= 'b0;
            r_block_col[783] <= 'b0;
            r_block_col[784] <= 'b0;
            r_block_col[785] <= 'b0;
            r_block_col[786] <= 'b0;
            r_block_col[787] <= 'b0;
            r_block_col[788] <= 'b0;
            r_block_col[789] <= 'b0;
            r_block_col[790] <= 'b0;
            r_block_col[791] <= 'b0;
            r_block_col[792] <= 'b0;
            r_block_col[793] <= 'b0;
            r_block_col[794] <= 'b0;
            r_block_col[795] <= 'b0;
            r_block_col[796] <= 'b0;
            r_block_col[797] <= 'b0;
            r_block_col[798] <= 'b0;
            r_block_col[799] <= 'b0;
            r_block_col[800] <= 'b0;
            r_block_col[801] <= 'b0;
            r_block_col[802] <= 'b0;
            r_block_col[803] <= 'b0;
            r_block_col[804] <= 'b0;
            r_block_col[805] <= 'b0;
            r_block_col[806] <= 'b0;
            r_block_col[807] <= 'b0;
            r_block_col[808] <= 'b0;
            r_block_col[809] <= 'b0;
            r_block_col[810] <= 'b0;
            r_block_col[811] <= 'b0;
            r_block_col[812] <= 'b0;
            r_block_col[813] <= 'b0;
            r_block_col[814] <= 'b0;
            r_block_col[815] <= 'b0;
            r_block_col[816] <= 'b0;
            r_block_col[817] <= 'b0;
            r_block_col[818] <= 'b0;
            r_block_col[819] <= 'b0;
            r_block_col[820] <= 'b0;
            r_block_col[821] <= 'b0;
            r_block_col[822] <= 'b0;
            r_block_col[823] <= 'b0;
            r_block_col[824] <= 'b0;
            r_block_col[825] <= 'b0;
            r_block_col[826] <= 'b0;
            r_block_col[827] <= 'b0;
            r_block_col[828] <= 'b0;
            r_block_col[829] <= 'b0;
            r_block_col[830] <= 'b0;
            r_block_col[831] <= 'b0;
            r_block_col[832] <= 'b0;
            r_block_col[833] <= 'b0;
            r_block_col[834] <= 'b0;
            r_block_col[835] <= 'b0;
            r_block_col[836] <= 'b0;
            r_block_col[837] <= 'b0;
            r_block_col[838] <= 'b0;
            r_block_col[839] <= 'b0;
            r_block_col[840] <= 'b0;
            r_block_col[841] <= 'b0;
            r_block_col[842] <= 'b0;
            r_block_col[843] <= 'b0;
            r_block_col[844] <= 'b0;
            r_block_col[845] <= 'b0;
            r_block_col[846] <= 'b0;
            r_block_col[847] <= 'b0;
            r_block_col[848] <= 'b0;
            r_block_col[849] <= 'b0;
            r_block_col[850] <= 'b0;
            r_block_col[851] <= 'b0;
            r_block_col[852] <= 'b0;
            r_block_col[853] <= 'b0;
            r_block_col[854] <= 'b0;
            r_block_col[855] <= 'b0;
            r_block_col[856] <= 'b0;
            r_block_col[857] <= 'b0;
            r_block_col[858] <= 'b0;
            r_block_col[859] <= 'b0;
            r_block_col[860] <= 'b0;
            r_block_col[861] <= 'b0;
            r_block_col[862] <= 'b0;
            r_block_col[863] <= 'b0;
            r_block_col[864] <= 'b0;
            r_block_col[865] <= 'b0;
            r_block_col[866] <= 'b0;
            r_block_col[867] <= 'b0;
            r_block_col[868] <= 'b0;
            r_block_col[869] <= 'b0;
            r_block_col[870] <= 'b0;
            r_block_col[871] <= 'b0;
            r_block_col[872] <= 'b0;
            r_block_col[873] <= 'b0;
            r_block_col[874] <= 'b0;
            r_block_col[875] <= 'b0;
            r_block_col[876] <= 'b0;
            r_block_col[877] <= 'b0;
            r_block_col[878] <= 'b0;
            r_block_col[879] <= 'b0;
            r_block_col[880] <= 'b0;
            r_block_col[881] <= 'b0;
            r_block_col[882] <= 'b0;
            r_block_col[883] <= 'b0;
            r_block_col[884] <= 'b0;
            r_block_col[885] <= 'b0;
            r_block_col[886] <= 'b0;
            r_block_col[887] <= 'b0;
            r_block_col[888] <= 'b0;
            r_block_col[889] <= 'b0;
            r_block_col[890] <= 'b0;
            r_block_col[891] <= 'b0;
            r_block_col[892] <= 'b0;
            r_block_col[893] <= 'b0;
            r_block_col[894] <= 'b0;
            r_block_col[895] <= 'b0;
            r_block_col[896] <= 'b0;
            r_block_col[897] <= 'b0;
            r_block_col[898] <= 'b0;
            r_block_col[899] <= 'b0;
            r_block_col[900] <= 'b0;
            r_block_col[901] <= 'b0;
            r_block_col[902] <= 'b0;
            r_block_col[903] <= 'b0;
            r_block_col[904] <= 'b0;
            r_block_col[905] <= 'b0;
            r_block_col[906] <= 'b0;
            r_block_col[907] <= 'b0;
            r_block_col[908] <= 'b0;
            r_block_col[909] <= 'b0;
            r_block_col[910] <= 'b0;
            r_block_col[911] <= 'b0;
            r_block_col[912] <= 'b0;
            r_block_col[913] <= 'b0;
            r_block_col[914] <= 'b0;
            r_block_col[915] <= 'b0;
            r_block_col[916] <= 'b0;
            r_block_col[917] <= 'b0;
            r_block_col[918] <= 'b0;
            r_block_col[919] <= 'b0;
            r_block_col[920] <= 'b0;
            r_block_col[921] <= 'b0;
            r_block_col[922] <= 'b0;
            r_block_col[923] <= 'b0;
            r_block_col[924] <= 'b0;
            r_block_col[925] <= 'b0;
            r_block_col[926] <= 'b0;
            r_block_col[927] <= 'b0;
            r_block_col[928] <= 'b0;
            r_block_col[929] <= 'b0;
            r_block_col[930] <= 'b0;
            r_block_col[931] <= 'b0;
            r_block_col[932] <= 'b0;
            r_block_col[933] <= 'b0;
            r_block_col[934] <= 'b0;
            r_block_col[935] <= 'b0;
            r_block_col[936] <= 'b0;
            r_block_col[937] <= 'b0;
            r_block_col[938] <= 'b0;
            r_block_col[939] <= 'b0;
            r_block_col[940] <= 'b0;
            r_block_col[941] <= 'b0;
            r_block_col[942] <= 'b0;
            r_block_col[943] <= 'b0;
            r_block_col[944] <= 'b0;
            r_block_col[945] <= 'b0;
            r_block_col[946] <= 'b0;
            r_block_col[947] <= 'b0;
            r_block_col[948] <= 'b0;
            r_block_col[949] <= 'b0;
            r_block_col[950] <= 'b0;
            r_block_col[951] <= 'b0;
            r_block_col[952] <= 'b0;
            r_block_col[953] <= 'b0;
            r_block_col[954] <= 'b0;
            r_block_col[955] <= 'b0;
            r_block_col[956] <= 'b0;
            r_block_col[957] <= 'b0;
            r_block_col[958] <= 'b0;
            r_block_col[959] <= 'b0;
            r_block_col[960] <= 'b0;
            r_block_col[961] <= 'b0;
            r_block_col[962] <= 'b0;
            r_block_col[963] <= 'b0;
            r_block_col[964] <= 'b0;
            r_block_col[965] <= 'b0;
            r_block_col[966] <= 'b0;
            r_block_col[967] <= 'b0;
            r_block_col[968] <= 'b0;
            r_block_col[969] <= 'b0;
            r_block_col[970] <= 'b0;
            r_block_col[971] <= 'b0;
            r_block_col[972] <= 'b0;
            r_block_col[973] <= 'b0;
            r_block_col[974] <= 'b0;
            r_block_col[975] <= 'b0;
            r_block_col[976] <= 'b0;
            r_block_col[977] <= 'b0;
            r_block_col[978] <= 'b0;
            r_block_col[979] <= 'b0;
            r_block_col[980] <= 'b0;
            r_block_col[981] <= 'b0;
            r_block_col[982] <= 'b0;
            r_block_col[983] <= 'b0;
            r_block_col[984] <= 'b0;
            r_block_col[985] <= 'b0;
            r_block_col[986] <= 'b0;
            r_block_col[987] <= 'b0;
            r_block_col[988] <= 'b0;
            r_block_col[989] <= 'b0;
            r_block_col[990] <= 'b0;
            r_block_col[991] <= 'b0;
            r_block_col[992] <= 'b0;
            r_block_col[993] <= 'b0;
            r_block_col[994] <= 'b0;
            r_block_col[995] <= 'b0;
            r_block_col[996] <= 'b0;
            r_block_col[997] <= 'b0;
            r_block_col[998] <= 'b0;
            r_block_col[999] <= 'b0;
            r_block_col[1000] <= 'b0;
            r_block_col[1001] <= 'b0;
            r_block_col[1002] <= 'b0;
            r_block_col[1003] <= 'b0;
            r_block_col[1004] <= 'b0;
            r_block_col[1005] <= 'b0;
            r_block_col[1006] <= 'b0;
            r_block_col[1007] <= 'b0;
            r_block_col[1008] <= 'b0;
            r_block_col[1009] <= 'b0;
            r_block_col[1010] <= 'b0;
            r_block_col[1011] <= 'b0;
            r_block_col[1012] <= 'b0;
            r_block_col[1013] <= 'b0;
            r_block_col[1014] <= 'b0;
            r_block_col[1015] <= 'b0;
            r_block_col[1016] <= 'b0;
            r_block_col[1017] <= 'b0;
            r_block_col[1018] <= 'b0;
            r_block_col[1019] <= 'b0;
            r_block_col[1020] <= 'b0;
            r_block_col[1021] <= 'b0;
            r_block_col[1022] <= 'b0;
            r_block_col[1023] <= 'b0;
            r_block_col[1024] <= 'b0;
            r_block_col[1025] <= 'b0;
            r_block_col[1026] <= 'b0;
            r_block_col[1027] <= 'b0;
            r_block_col[1028] <= 'b0;
            r_block_col[1029] <= 'b0;
            r_block_col[1030] <= 'b0;
            r_block_col[1031] <= 'b0;
            r_block_col[1032] <= 'b0;
            r_block_col[1033] <= 'b0;
            r_block_col[1034] <= 'b0;
            r_block_col[1035] <= 'b0;
            r_block_col[1036] <= 'b0;
            r_block_col[1037] <= 'b0;
            r_block_col[1038] <= 'b0;
            r_block_col[1039] <= 'b0;
            r_block_col[1040] <= 'b0;
            r_block_col[1041] <= 'b0;
            r_block_col[1042] <= 'b0;
            r_block_col[1043] <= 'b0;
            r_block_col[1044] <= 'b0;
            r_block_col[1045] <= 'b0;
            r_block_col[1046] <= 'b0;
            r_block_col[1047] <= 'b0;
            r_block_col[1048] <= 'b0;
            r_block_col[1049] <= 'b0;
            r_block_col[1050] <= 'b0;
            r_block_col[1051] <= 'b0;
            r_block_col[1052] <= 'b0;
            r_block_col[1053] <= 'b0;
            r_block_col[1054] <= 'b0;
            r_block_col[1055] <= 'b0;

            r_block_row[0] <= 'b0;
            r_block_row[1] <= 'b0;
            r_block_row[2] <= 'b0;
            r_block_row[3] <= 'b0;
            r_block_row[4] <= 'b0;
            r_block_row[5] <= 'b0;
            r_block_row[6] <= 'b0;
            r_block_row[7] <= 'b0;
            r_block_row[8] <= 'b0;
            r_block_row[9] <= 'b0;
            r_block_row[10] <= 'b0;
            r_block_row[11] <= 'b0;
            r_block_row[12] <= 'b0;
            r_block_row[13] <= 'b0;
            r_block_row[14] <= 'b0;
            r_block_row[15] <= 'b0;
            r_block_row[16] <= 'b0;
            r_block_row[17] <= 'b0;
            r_block_row[18] <= 'b0;
            r_block_row[19] <= 'b0;
            r_block_row[20] <= 'b0;
            r_block_row[21] <= 'b0;
            r_block_row[22] <= 'b0;
            r_block_row[23] <= 'b0;
            r_block_row[24] <= 'b0;
            r_block_row[25] <= 'b0;
            r_block_row[26] <= 'b0;
            r_block_row[27] <= 'b0;
            r_block_row[28] <= 'b0;
            r_block_row[29] <= 'b0;
            r_block_row[30] <= 'b0;
            r_block_row[31] <= 'b0;
            r_block_row[32] <= 'b0;
            r_block_row[33] <= 'b0;
            r_block_row[34] <= 'b0;
            r_block_row[35] <= 'b0;
            r_block_row[36] <= 'b0;
            r_block_row[37] <= 'b0;
            r_block_row[38] <= 'b0;
            r_block_row[39] <= 'b0;
            r_block_row[40] <= 'b0;
            r_block_row[41] <= 'b0;
            r_block_row[42] <= 'b0;
            r_block_row[43] <= 'b0;
            r_block_row[44] <= 'b0;
            r_block_row[45] <= 'b0;
            r_block_row[46] <= 'b0;
            r_block_row[47] <= 'b0;
            r_block_row[48] <= 'b0;
            r_block_row[49] <= 'b0;
            r_block_row[50] <= 'b0;
            r_block_row[51] <= 'b0;
            r_block_row[52] <= 'b0;
            r_block_row[53] <= 'b0;
            r_block_row[54] <= 'b0;
            r_block_row[55] <= 'b0;
            r_block_row[56] <= 'b0;
            r_block_row[57] <= 'b0;
            r_block_row[58] <= 'b0;
            r_block_row[59] <= 'b0;
            r_block_row[60] <= 'b0;
            r_block_row[61] <= 'b0;
            r_block_row[62] <= 'b0;
            r_block_row[63] <= 'b0;
            r_block_row[64] <= 'b0;
            r_block_row[65] <= 'b0;
            r_block_row[66] <= 'b0;
            r_block_row[67] <= 'b0;
            r_block_row[68] <= 'b0;
            r_block_row[69] <= 'b0;
            r_block_row[70] <= 'b0;
            r_block_row[71] <= 'b0;
            r_block_row[72] <= 'b0;
            r_block_row[73] <= 'b0;
            r_block_row[74] <= 'b0;
            r_block_row[75] <= 'b0;
            r_block_row[76] <= 'b0;
            r_block_row[77] <= 'b0;
            r_block_row[78] <= 'b0;
            r_block_row[79] <= 'b0;
            r_block_row[80] <= 'b0;
            r_block_row[81] <= 'b0;
            r_block_row[82] <= 'b0;
            r_block_row[83] <= 'b0;
            r_block_row[84] <= 'b0;
            r_block_row[85] <= 'b0;
            r_block_row[86] <= 'b0;
            r_block_row[87] <= 'b0;
            r_block_row[88] <= 'b0;
            r_block_row[89] <= 'b0;
            r_block_row[90] <= 'b0;
            r_block_row[91] <= 'b0;
            r_block_row[92] <= 'b0;
            r_block_row[93] <= 'b0;
            r_block_row[94] <= 'b0;
            r_block_row[95] <= 'b0;
            r_block_row[96] <= 'b0;
            r_block_row[97] <= 'b0;
            r_block_row[98] <= 'b0;
            r_block_row[99] <= 'b0;
            r_block_row[100] <= 'b0;
            r_block_row[101] <= 'b0;
            r_block_row[102] <= 'b0;
            r_block_row[103] <= 'b0;
            r_block_row[104] <= 'b0;
            r_block_row[105] <= 'b0;
            r_block_row[106] <= 'b0;
            r_block_row[107] <= 'b0;
            r_block_row[108] <= 'b0;
            r_block_row[109] <= 'b0;
            r_block_row[110] <= 'b0;
            r_block_row[111] <= 'b0;
            r_block_row[112] <= 'b0;
            r_block_row[113] <= 'b0;
            r_block_row[114] <= 'b0;
            r_block_row[115] <= 'b0;
            r_block_row[116] <= 'b0;
            r_block_row[117] <= 'b0;
            r_block_row[118] <= 'b0;
            r_block_row[119] <= 'b0;
            r_block_row[120] <= 'b0;
            r_block_row[121] <= 'b0;
            r_block_row[122] <= 'b0;
            r_block_row[123] <= 'b0;
            r_block_row[124] <= 'b0;
            r_block_row[125] <= 'b0;
            r_block_row[126] <= 'b0;
            r_block_row[127] <= 'b0;
            r_block_row[128] <= 'b0;
            r_block_row[129] <= 'b0;
            r_block_row[130] <= 'b0;
            r_block_row[131] <= 'b0;
            r_block_row[132] <= 'b0;
            r_block_row[133] <= 'b0;
            r_block_row[134] <= 'b0;
            r_block_row[135] <= 'b0;
            r_block_row[136] <= 'b0;
            r_block_row[137] <= 'b0;
            r_block_row[138] <= 'b0;
            r_block_row[139] <= 'b0;
            r_block_row[140] <= 'b0;
            r_block_row[141] <= 'b0;
            r_block_row[142] <= 'b0;
            r_block_row[143] <= 'b0;
            r_block_row[144] <= 'b0;
            r_block_row[145] <= 'b0;
            r_block_row[146] <= 'b0;
            r_block_row[147] <= 'b0;
            r_block_row[148] <= 'b0;
            r_block_row[149] <= 'b0;
            r_block_row[150] <= 'b0;
            r_block_row[151] <= 'b0;
            r_block_row[152] <= 'b0;
            r_block_row[153] <= 'b0;
            r_block_row[154] <= 'b0;
            r_block_row[155] <= 'b0;
            r_block_row[156] <= 'b0;
            r_block_row[157] <= 'b0;
            r_block_row[158] <= 'b0;
            r_block_row[159] <= 'b0;
            r_block_row[160] <= 'b0;
            r_block_row[161] <= 'b0;
            r_block_row[162] <= 'b0;
            r_block_row[163] <= 'b0;
            r_block_row[164] <= 'b0;
            r_block_row[165] <= 'b0;
            r_block_row[166] <= 'b0;
            r_block_row[167] <= 'b0;
            r_block_row[168] <= 'b0;
            r_block_row[169] <= 'b0;
            r_block_row[170] <= 'b0;
            r_block_row[171] <= 'b0;
            r_block_row[172] <= 'b0;
            r_block_row[173] <= 'b0;
            r_block_row[174] <= 'b0;
            r_block_row[175] <= 'b0;
            r_block_row[176] <= 'b0;
            r_block_row[177] <= 'b0;
            r_block_row[178] <= 'b0;
            r_block_row[179] <= 'b0;
            r_block_row[180] <= 'b0;
            r_block_row[181] <= 'b0;
            r_block_row[182] <= 'b0;
            r_block_row[183] <= 'b0;
            r_block_row[184] <= 'b0;
            r_block_row[185] <= 'b0;
            r_block_row[186] <= 'b0;
            r_block_row[187] <= 'b0;
            r_block_row[188] <= 'b0;
            r_block_row[189] <= 'b0;
            r_block_row[190] <= 'b0;
            r_block_row[191] <= 'b0;
            r_block_row[192] <= 'b0;
            r_block_row[193] <= 'b0;
            r_block_row[194] <= 'b0;
            r_block_row[195] <= 'b0;
            r_block_row[196] <= 'b0;
            r_block_row[197] <= 'b0;
            r_block_row[198] <= 'b0;
            r_block_row[199] <= 'b0;
            r_block_row[200] <= 'b0;
            r_block_row[201] <= 'b0;
            r_block_row[202] <= 'b0;
            r_block_row[203] <= 'b0;
            r_block_row[204] <= 'b0;
            r_block_row[205] <= 'b0;
            r_block_row[206] <= 'b0;
            r_block_row[207] <= 'b0;
            r_block_row[208] <= 'b0;
            r_block_row[209] <= 'b0;
            r_block_row[210] <= 'b0;
            r_block_row[211] <= 'b0;
            r_block_row[212] <= 'b0;
            r_block_row[213] <= 'b0;
            r_block_row[214] <= 'b0;
            r_block_row[215] <= 'b0;
            r_block_row[216] <= 'b0;
            r_block_row[217] <= 'b0;
            r_block_row[218] <= 'b0;
            r_block_row[219] <= 'b0;
            r_block_row[220] <= 'b0;
            r_block_row[221] <= 'b0;
            r_block_row[222] <= 'b0;
            r_block_row[223] <= 'b0;
            r_block_row[224] <= 'b0;
            r_block_row[225] <= 'b0;
            r_block_row[226] <= 'b0;
            r_block_row[227] <= 'b0;
            r_block_row[228] <= 'b0;
            r_block_row[229] <= 'b0;
            r_block_row[230] <= 'b0;
            r_block_row[231] <= 'b0;
            r_block_row[232] <= 'b0;
            r_block_row[233] <= 'b0;
            r_block_row[234] <= 'b0;
            r_block_row[235] <= 'b0;
            r_block_row[236] <= 'b0;
            r_block_row[237] <= 'b0;
            r_block_row[238] <= 'b0;
            r_block_row[239] <= 'b0;
            r_block_row[240] <= 'b0;
            r_block_row[241] <= 'b0;
            r_block_row[242] <= 'b0;
            r_block_row[243] <= 'b0;
            r_block_row[244] <= 'b0;
            r_block_row[245] <= 'b0;
            r_block_row[246] <= 'b0;
            r_block_row[247] <= 'b0;
            r_block_row[248] <= 'b0;
            r_block_row[249] <= 'b0;
            r_block_row[250] <= 'b0;
            r_block_row[251] <= 'b0;
            r_block_row[252] <= 'b0;
            r_block_row[253] <= 'b0;
            r_block_row[254] <= 'b0;
            r_block_row[255] <= 'b0;
            r_block_row[256] <= 'b0;
            r_block_row[257] <= 'b0;
            r_block_row[258] <= 'b0;
            r_block_row[259] <= 'b0;
            r_block_row[260] <= 'b0;
            r_block_row[261] <= 'b0;
            r_block_row[262] <= 'b0;
            r_block_row[263] <= 'b0;
            r_block_row[264] <= 'b0;
            r_block_row[265] <= 'b0;
            r_block_row[266] <= 'b0;
            r_block_row[267] <= 'b0;
            r_block_row[268] <= 'b0;
            r_block_row[269] <= 'b0;
            r_block_row[270] <= 'b0;
            r_block_row[271] <= 'b0;
            r_block_row[272] <= 'b0;
            r_block_row[273] <= 'b0;
            r_block_row[274] <= 'b0;
            r_block_row[275] <= 'b0;
            r_block_row[276] <= 'b0;
            r_block_row[277] <= 'b0;
            r_block_row[278] <= 'b0;
            r_block_row[279] <= 'b0;
            r_block_row[280] <= 'b0;
            r_block_row[281] <= 'b0;
            r_block_row[282] <= 'b0;
            r_block_row[283] <= 'b0;
            r_block_row[284] <= 'b0;
            r_block_row[285] <= 'b0;
            r_block_row[286] <= 'b0;
            r_block_row[287] <= 'b0;
            r_block_row[288] <= 'b0;
            r_block_row[289] <= 'b0;
            r_block_row[290] <= 'b0;
            r_block_row[291] <= 'b0;
            r_block_row[292] <= 'b0;
            r_block_row[293] <= 'b0;
            r_block_row[294] <= 'b0;
            r_block_row[295] <= 'b0;
            r_block_row[296] <= 'b0;
            r_block_row[297] <= 'b0;
            r_block_row[298] <= 'b0;
            r_block_row[299] <= 'b0;
            r_block_row[300] <= 'b0;
            r_block_row[301] <= 'b0;
            r_block_row[302] <= 'b0;
            r_block_row[303] <= 'b0;
            r_block_row[304] <= 'b0;
            r_block_row[305] <= 'b0;
            r_block_row[306] <= 'b0;
            r_block_row[307] <= 'b0;
            r_block_row[308] <= 'b0;
            r_block_row[309] <= 'b0;
            r_block_row[310] <= 'b0;
            r_block_row[311] <= 'b0;
            r_block_row[312] <= 'b0;
            r_block_row[313] <= 'b0;
            r_block_row[314] <= 'b0;
            r_block_row[315] <= 'b0;
            r_block_row[316] <= 'b0;
            r_block_row[317] <= 'b0;
            r_block_row[318] <= 'b0;
            r_block_row[319] <= 'b0;
            r_block_row[320] <= 'b0;
            r_block_row[321] <= 'b0;
            r_block_row[322] <= 'b0;
            r_block_row[323] <= 'b0;
            r_block_row[324] <= 'b0;
            r_block_row[325] <= 'b0;
            r_block_row[326] <= 'b0;
            r_block_row[327] <= 'b0;
            r_block_row[328] <= 'b0;
            r_block_row[329] <= 'b0;
            r_block_row[330] <= 'b0;
            r_block_row[331] <= 'b0;
            r_block_row[332] <= 'b0;
            r_block_row[333] <= 'b0;
            r_block_row[334] <= 'b0;
            r_block_row[335] <= 'b0;
            r_block_row[336] <= 'b0;
            r_block_row[337] <= 'b0;
            r_block_row[338] <= 'b0;
            r_block_row[339] <= 'b0;
            r_block_row[340] <= 'b0;
            r_block_row[341] <= 'b0;
            r_block_row[342] <= 'b0;
            r_block_row[343] <= 'b0;
            r_block_row[344] <= 'b0;
            r_block_row[345] <= 'b0;
            r_block_row[346] <= 'b0;
            r_block_row[347] <= 'b0;
            r_block_row[348] <= 'b0;
            r_block_row[349] <= 'b0;
            r_block_row[350] <= 'b0;
            r_block_row[351] <= 'b0;
            r_block_row[352] <= 'b0;
            r_block_row[353] <= 'b0;
            r_block_row[354] <= 'b0;
            r_block_row[355] <= 'b0;
            r_block_row[356] <= 'b0;
            r_block_row[357] <= 'b0;
            r_block_row[358] <= 'b0;
            r_block_row[359] <= 'b0;
            r_block_row[360] <= 'b0;
            r_block_row[361] <= 'b0;
            r_block_row[362] <= 'b0;
            r_block_row[363] <= 'b0;
            r_block_row[364] <= 'b0;
            r_block_row[365] <= 'b0;
            r_block_row[366] <= 'b0;
            r_block_row[367] <= 'b0;
            r_block_row[368] <= 'b0;
            r_block_row[369] <= 'b0;
            r_block_row[370] <= 'b0;
            r_block_row[371] <= 'b0;
            r_block_row[372] <= 'b0;
            r_block_row[373] <= 'b0;
            r_block_row[374] <= 'b0;
            r_block_row[375] <= 'b0;
            r_block_row[376] <= 'b0;
            r_block_row[377] <= 'b0;
            r_block_row[378] <= 'b0;
            r_block_row[379] <= 'b0;
            r_block_row[380] <= 'b0;
            r_block_row[381] <= 'b0;
            r_block_row[382] <= 'b0;
            r_block_row[383] <= 'b0;
            r_block_row[384] <= 'b0;
            r_block_row[385] <= 'b0;
            r_block_row[386] <= 'b0;
            r_block_row[387] <= 'b0;
            r_block_row[388] <= 'b0;
            r_block_row[389] <= 'b0;
            r_block_row[390] <= 'b0;
            r_block_row[391] <= 'b0;
            r_block_row[392] <= 'b0;
            r_block_row[393] <= 'b0;
            r_block_row[394] <= 'b0;
            r_block_row[395] <= 'b0;
            r_block_row[396] <= 'b0;
            r_block_row[397] <= 'b0;
            r_block_row[398] <= 'b0;
            r_block_row[399] <= 'b0;
            r_block_row[400] <= 'b0;
            r_block_row[401] <= 'b0;
            r_block_row[402] <= 'b0;
            r_block_row[403] <= 'b0;
            r_block_row[404] <= 'b0;
            r_block_row[405] <= 'b0;
            r_block_row[406] <= 'b0;
            r_block_row[407] <= 'b0;
            r_block_row[408] <= 'b0;
            r_block_row[409] <= 'b0;
            r_block_row[410] <= 'b0;
            r_block_row[411] <= 'b0;
            r_block_row[412] <= 'b0;
            r_block_row[413] <= 'b0;
            r_block_row[414] <= 'b0;
            r_block_row[415] <= 'b0;
            r_block_row[416] <= 'b0;
            r_block_row[417] <= 'b0;
            r_block_row[418] <= 'b0;
            r_block_row[419] <= 'b0;
            r_block_row[420] <= 'b0;
            r_block_row[421] <= 'b0;
            r_block_row[422] <= 'b0;
            r_block_row[423] <= 'b0;
            r_block_row[424] <= 'b0;
            r_block_row[425] <= 'b0;
            r_block_row[426] <= 'b0;
            r_block_row[427] <= 'b0;
            r_block_row[428] <= 'b0;
            r_block_row[429] <= 'b0;
            r_block_row[430] <= 'b0;
            r_block_row[431] <= 'b0;
            r_block_row[432] <= 'b0;
            r_block_row[433] <= 'b0;
            r_block_row[434] <= 'b0;
            r_block_row[435] <= 'b0;
            r_block_row[436] <= 'b0;
            r_block_row[437] <= 'b0;
            r_block_row[438] <= 'b0;
            r_block_row[439] <= 'b0;
            r_block_row[440] <= 'b0;
            r_block_row[441] <= 'b0;
            r_block_row[442] <= 'b0;
            r_block_row[443] <= 'b0;
            r_block_row[444] <= 'b0;
            r_block_row[445] <= 'b0;
            r_block_row[446] <= 'b0;
            r_block_row[447] <= 'b0;
            r_block_row[448] <= 'b0;
            r_block_row[449] <= 'b0;
            r_block_row[450] <= 'b0;
            r_block_row[451] <= 'b0;
            r_block_row[452] <= 'b0;
            r_block_row[453] <= 'b0;
            r_block_row[454] <= 'b0;
            r_block_row[455] <= 'b0;
            r_block_row[456] <= 'b0;
            r_block_row[457] <= 'b0;
            r_block_row[458] <= 'b0;
            r_block_row[459] <= 'b0;
            r_block_row[460] <= 'b0;
            r_block_row[461] <= 'b0;
            r_block_row[462] <= 'b0;
            r_block_row[463] <= 'b0;
            r_block_row[464] <= 'b0;
            r_block_row[465] <= 'b0;
            r_block_row[466] <= 'b0;
            r_block_row[467] <= 'b0;
            r_block_row[468] <= 'b0;
            r_block_row[469] <= 'b0;
            r_block_row[470] <= 'b0;
            r_block_row[471] <= 'b0;
            r_block_row[472] <= 'b0;
            r_block_row[473] <= 'b0;
            r_block_row[474] <= 'b0;
            r_block_row[475] <= 'b0;
            r_block_row[476] <= 'b0;
            r_block_row[477] <= 'b0;
            r_block_row[478] <= 'b0;
            r_block_row[479] <= 'b0;
            r_block_row[480] <= 'b0;
            r_block_row[481] <= 'b0;
            r_block_row[482] <= 'b0;
            r_block_row[483] <= 'b0;
            r_block_row[484] <= 'b0;
            r_block_row[485] <= 'b0;
            r_block_row[486] <= 'b0;
            r_block_row[487] <= 'b0;
            r_block_row[488] <= 'b0;
            r_block_row[489] <= 'b0;
            r_block_row[490] <= 'b0;
            r_block_row[491] <= 'b0;
            r_block_row[492] <= 'b0;
            r_block_row[493] <= 'b0;
            r_block_row[494] <= 'b0;
            r_block_row[495] <= 'b0;
            r_block_row[496] <= 'b0;
            r_block_row[497] <= 'b0;
            r_block_row[498] <= 'b0;
            r_block_row[499] <= 'b0;
            r_block_row[500] <= 'b0;
            r_block_row[501] <= 'b0;
            r_block_row[502] <= 'b0;
            r_block_row[503] <= 'b0;
            r_block_row[504] <= 'b0;
            r_block_row[505] <= 'b0;
            r_block_row[506] <= 'b0;
            r_block_row[507] <= 'b0;
            r_block_row[508] <= 'b0;
            r_block_row[509] <= 'b0;
            r_block_row[510] <= 'b0;
            r_block_row[511] <= 'b0;
            r_block_row[512] <= 'b0;
            r_block_row[513] <= 'b0;
            r_block_row[514] <= 'b0;
            r_block_row[515] <= 'b0;
            r_block_row[516] <= 'b0;
            r_block_row[517] <= 'b0;
            r_block_row[518] <= 'b0;
            r_block_row[519] <= 'b0;
            r_block_row[520] <= 'b0;
            r_block_row[521] <= 'b0;
            r_block_row[522] <= 'b0;
            r_block_row[523] <= 'b0;
            r_block_row[524] <= 'b0;
            r_block_row[525] <= 'b0;
            r_block_row[526] <= 'b0;
            r_block_row[527] <= 'b0;
            r_block_row[528] <= 'b0;
            r_block_row[529] <= 'b0;
            r_block_row[530] <= 'b0;
            r_block_row[531] <= 'b0;
            r_block_row[532] <= 'b0;
            r_block_row[533] <= 'b0;
            r_block_row[534] <= 'b0;
            r_block_row[535] <= 'b0;
            r_block_row[536] <= 'b0;
            r_block_row[537] <= 'b0;
            r_block_row[538] <= 'b0;
            r_block_row[539] <= 'b0;
            r_block_row[540] <= 'b0;
            r_block_row[541] <= 'b0;
            r_block_row[542] <= 'b0;
            r_block_row[543] <= 'b0;
            r_block_row[544] <= 'b0;
            r_block_row[545] <= 'b0;
            r_block_row[546] <= 'b0;
            r_block_row[547] <= 'b0;
            r_block_row[548] <= 'b0;
            r_block_row[549] <= 'b0;
            r_block_row[550] <= 'b0;
            r_block_row[551] <= 'b0;
            r_block_row[552] <= 'b0;
            r_block_row[553] <= 'b0;
            r_block_row[554] <= 'b0;
            r_block_row[555] <= 'b0;
            r_block_row[556] <= 'b0;
            r_block_row[557] <= 'b0;
            r_block_row[558] <= 'b0;
            r_block_row[559] <= 'b0;
            r_block_row[560] <= 'b0;
            r_block_row[561] <= 'b0;
            r_block_row[562] <= 'b0;
            r_block_row[563] <= 'b0;
            r_block_row[564] <= 'b0;
            r_block_row[565] <= 'b0;
            r_block_row[566] <= 'b0;
            r_block_row[567] <= 'b0;
            r_block_row[568] <= 'b0;
            r_block_row[569] <= 'b0;
            r_block_row[570] <= 'b0;
            r_block_row[571] <= 'b0;
            r_block_row[572] <= 'b0;
            r_block_row[573] <= 'b0;
            r_block_row[574] <= 'b0;
            r_block_row[575] <= 'b0;
            r_block_row[576] <= 'b0;
            r_block_row[577] <= 'b0;
            r_block_row[578] <= 'b0;
            r_block_row[579] <= 'b0;
            r_block_row[580] <= 'b0;
            r_block_row[581] <= 'b0;
            r_block_row[582] <= 'b0;
            r_block_row[583] <= 'b0;
            r_block_row[584] <= 'b0;
            r_block_row[585] <= 'b0;
            r_block_row[586] <= 'b0;
            r_block_row[587] <= 'b0;
            r_block_row[588] <= 'b0;
            r_block_row[589] <= 'b0;
            r_block_row[590] <= 'b0;
            r_block_row[591] <= 'b0;
            r_block_row[592] <= 'b0;
            r_block_row[593] <= 'b0;
            r_block_row[594] <= 'b0;
            r_block_row[595] <= 'b0;
            r_block_row[596] <= 'b0;
            r_block_row[597] <= 'b0;
            r_block_row[598] <= 'b0;
            r_block_row[599] <= 'b0;
            r_block_row[600] <= 'b0;
            r_block_row[601] <= 'b0;
            r_block_row[602] <= 'b0;
            r_block_row[603] <= 'b0;
            r_block_row[604] <= 'b0;
            r_block_row[605] <= 'b0;
            r_block_row[606] <= 'b0;
            r_block_row[607] <= 'b0;
            r_block_row[608] <= 'b0;
            r_block_row[609] <= 'b0;
            r_block_row[610] <= 'b0;
            r_block_row[611] <= 'b0;
            r_block_row[612] <= 'b0;
            r_block_row[613] <= 'b0;
            r_block_row[614] <= 'b0;
            r_block_row[615] <= 'b0;
            r_block_row[616] <= 'b0;
            r_block_row[617] <= 'b0;
            r_block_row[618] <= 'b0;
            r_block_row[619] <= 'b0;
            r_block_row[620] <= 'b0;
            r_block_row[621] <= 'b0;
            r_block_row[622] <= 'b0;
            r_block_row[623] <= 'b0;
            r_block_row[624] <= 'b0;
            r_block_row[625] <= 'b0;
            r_block_row[626] <= 'b0;
            r_block_row[627] <= 'b0;
            r_block_row[628] <= 'b0;
            r_block_row[629] <= 'b0;
            r_block_row[630] <= 'b0;
            r_block_row[631] <= 'b0;
            r_block_row[632] <= 'b0;
            r_block_row[633] <= 'b0;
            r_block_row[634] <= 'b0;
            r_block_row[635] <= 'b0;
            r_block_row[636] <= 'b0;
            r_block_row[637] <= 'b0;
            r_block_row[638] <= 'b0;
            r_block_row[639] <= 'b0;
            r_block_row[640] <= 'b0;
            r_block_row[641] <= 'b0;
            r_block_row[642] <= 'b0;
            r_block_row[643] <= 'b0;
            r_block_row[644] <= 'b0;
            r_block_row[645] <= 'b0;
            r_block_row[646] <= 'b0;
            r_block_row[647] <= 'b0;
            r_block_row[648] <= 'b0;
            r_block_row[649] <= 'b0;
            r_block_row[650] <= 'b0;
            r_block_row[651] <= 'b0;
            r_block_row[652] <= 'b0;
            r_block_row[653] <= 'b0;
            r_block_row[654] <= 'b0;
            r_block_row[655] <= 'b0;
            r_block_row[656] <= 'b0;
            r_block_row[657] <= 'b0;
            r_block_row[658] <= 'b0;
            r_block_row[659] <= 'b0;
            r_block_row[660] <= 'b0;
            r_block_row[661] <= 'b0;
            r_block_row[662] <= 'b0;
            r_block_row[663] <= 'b0;
            r_block_row[664] <= 'b0;
            r_block_row[665] <= 'b0;
            r_block_row[666] <= 'b0;
            r_block_row[667] <= 'b0;
            r_block_row[668] <= 'b0;
            r_block_row[669] <= 'b0;
            r_block_row[670] <= 'b0;
            r_block_row[671] <= 'b0;
            r_block_row[672] <= 'b0;
            r_block_row[673] <= 'b0;
            r_block_row[674] <= 'b0;
            r_block_row[675] <= 'b0;
            r_block_row[676] <= 'b0;
            r_block_row[677] <= 'b0;
            r_block_row[678] <= 'b0;
            r_block_row[679] <= 'b0;
            r_block_row[680] <= 'b0;
            r_block_row[681] <= 'b0;
            r_block_row[682] <= 'b0;
            r_block_row[683] <= 'b0;
            r_block_row[684] <= 'b0;
            r_block_row[685] <= 'b0;
            r_block_row[686] <= 'b0;
            r_block_row[687] <= 'b0;
            r_block_row[688] <= 'b0;
            r_block_row[689] <= 'b0;
            r_block_row[690] <= 'b0;
            r_block_row[691] <= 'b0;
            r_block_row[692] <= 'b0;
            r_block_row[693] <= 'b0;
            r_block_row[694] <= 'b0;
            r_block_row[695] <= 'b0;
            r_block_row[696] <= 'b0;
            r_block_row[697] <= 'b0;
            r_block_row[698] <= 'b0;
            r_block_row[699] <= 'b0;
            r_block_row[700] <= 'b0;
            r_block_row[701] <= 'b0;
            r_block_row[702] <= 'b0;
            r_block_row[703] <= 'b0;
            r_block_row[704] <= 'b0;
            r_block_row[705] <= 'b0;
            r_block_row[706] <= 'b0;
            r_block_row[707] <= 'b0;
            r_block_row[708] <= 'b0;
            r_block_row[709] <= 'b0;
            r_block_row[710] <= 'b0;
            r_block_row[711] <= 'b0;
            r_block_row[712] <= 'b0;
            r_block_row[713] <= 'b0;
            r_block_row[714] <= 'b0;
            r_block_row[715] <= 'b0;
            r_block_row[716] <= 'b0;
            r_block_row[717] <= 'b0;
            r_block_row[718] <= 'b0;
            r_block_row[719] <= 'b0;
            r_block_row[720] <= 'b0;
            r_block_row[721] <= 'b0;
            r_block_row[722] <= 'b0;
            r_block_row[723] <= 'b0;
            r_block_row[724] <= 'b0;
            r_block_row[725] <= 'b0;
            r_block_row[726] <= 'b0;
            r_block_row[727] <= 'b0;
            r_block_row[728] <= 'b0;
            r_block_row[729] <= 'b0;
            r_block_row[730] <= 'b0;
            r_block_row[731] <= 'b0;
            r_block_row[732] <= 'b0;
            r_block_row[733] <= 'b0;
            r_block_row[734] <= 'b0;
            r_block_row[735] <= 'b0;
            r_block_row[736] <= 'b0;
            r_block_row[737] <= 'b0;
            r_block_row[738] <= 'b0;
            r_block_row[739] <= 'b0;
            r_block_row[740] <= 'b0;
            r_block_row[741] <= 'b0;
            r_block_row[742] <= 'b0;
            r_block_row[743] <= 'b0;
            r_block_row[744] <= 'b0;
            r_block_row[745] <= 'b0;
            r_block_row[746] <= 'b0;
            r_block_row[747] <= 'b0;
            r_block_row[748] <= 'b0;
            r_block_row[749] <= 'b0;
            r_block_row[750] <= 'b0;
            r_block_row[751] <= 'b0;
            r_block_row[752] <= 'b0;
            r_block_row[753] <= 'b0;
            r_block_row[754] <= 'b0;
            r_block_row[755] <= 'b0;
            r_block_row[756] <= 'b0;
            r_block_row[757] <= 'b0;
            r_block_row[758] <= 'b0;
            r_block_row[759] <= 'b0;
            r_block_row[760] <= 'b0;
            r_block_row[761] <= 'b0;
            r_block_row[762] <= 'b0;
            r_block_row[763] <= 'b0;
            r_block_row[764] <= 'b0;
            r_block_row[765] <= 'b0;
            r_block_row[766] <= 'b0;
            r_block_row[767] <= 'b0;
            r_block_row[768] <= 'b0;
            r_block_row[769] <= 'b0;
            r_block_row[770] <= 'b0;
            r_block_row[771] <= 'b0;
            r_block_row[772] <= 'b0;
            r_block_row[773] <= 'b0;
            r_block_row[774] <= 'b0;
            r_block_row[775] <= 'b0;
            r_block_row[776] <= 'b0;
            r_block_row[777] <= 'b0;
            r_block_row[778] <= 'b0;
            r_block_row[779] <= 'b0;
            r_block_row[780] <= 'b0;
            r_block_row[781] <= 'b0;
            r_block_row[782] <= 'b0;
            r_block_row[783] <= 'b0;
            r_block_row[784] <= 'b0;
            r_block_row[785] <= 'b0;
            r_block_row[786] <= 'b0;
            r_block_row[787] <= 'b0;
            r_block_row[788] <= 'b0;
            r_block_row[789] <= 'b0;
            r_block_row[790] <= 'b0;
            r_block_row[791] <= 'b0;
            r_block_row[792] <= 'b0;
            r_block_row[793] <= 'b0;
            r_block_row[794] <= 'b0;
            r_block_row[795] <= 'b0;
            r_block_row[796] <= 'b0;
            r_block_row[797] <= 'b0;
            r_block_row[798] <= 'b0;
            r_block_row[799] <= 'b0;
            r_block_row[800] <= 'b0;
            r_block_row[801] <= 'b0;
            r_block_row[802] <= 'b0;
            r_block_row[803] <= 'b0;
            r_block_row[804] <= 'b0;
            r_block_row[805] <= 'b0;
            r_block_row[806] <= 'b0;
            r_block_row[807] <= 'b0;
            r_block_row[808] <= 'b0;
            r_block_row[809] <= 'b0;
            r_block_row[810] <= 'b0;
            r_block_row[811] <= 'b0;
            r_block_row[812] <= 'b0;
            r_block_row[813] <= 'b0;
            r_block_row[814] <= 'b0;
            r_block_row[815] <= 'b0;
            r_block_row[816] <= 'b0;
            r_block_row[817] <= 'b0;
            r_block_row[818] <= 'b0;
            r_block_row[819] <= 'b0;
            r_block_row[820] <= 'b0;
            r_block_row[821] <= 'b0;
            r_block_row[822] <= 'b0;
            r_block_row[823] <= 'b0;
            r_block_row[824] <= 'b0;
            r_block_row[825] <= 'b0;
            r_block_row[826] <= 'b0;
            r_block_row[827] <= 'b0;
            r_block_row[828] <= 'b0;
            r_block_row[829] <= 'b0;
            r_block_row[830] <= 'b0;
            r_block_row[831] <= 'b0;
            r_block_row[832] <= 'b0;
            r_block_row[833] <= 'b0;
            r_block_row[834] <= 'b0;
            r_block_row[835] <= 'b0;
            r_block_row[836] <= 'b0;
            r_block_row[837] <= 'b0;
            r_block_row[838] <= 'b0;
            r_block_row[839] <= 'b0;
            r_block_row[840] <= 'b0;
            r_block_row[841] <= 'b0;
            r_block_row[842] <= 'b0;
            r_block_row[843] <= 'b0;
            r_block_row[844] <= 'b0;
            r_block_row[845] <= 'b0;
            r_block_row[846] <= 'b0;
            r_block_row[847] <= 'b0;
            r_block_row[848] <= 'b0;
            r_block_row[849] <= 'b0;
            r_block_row[850] <= 'b0;
            r_block_row[851] <= 'b0;
            r_block_row[852] <= 'b0;
            r_block_row[853] <= 'b0;
            r_block_row[854] <= 'b0;
            r_block_row[855] <= 'b0;
            r_block_row[856] <= 'b0;
            r_block_row[857] <= 'b0;
            r_block_row[858] <= 'b0;
            r_block_row[859] <= 'b0;
            r_block_row[860] <= 'b0;
            r_block_row[861] <= 'b0;
            r_block_row[862] <= 'b0;
            r_block_row[863] <= 'b0;
            r_block_row[864] <= 'b0;
            r_block_row[865] <= 'b0;
            r_block_row[866] <= 'b0;
            r_block_row[867] <= 'b0;
            r_block_row[868] <= 'b0;
            r_block_row[869] <= 'b0;
            r_block_row[870] <= 'b0;
            r_block_row[871] <= 'b0;
            r_block_row[872] <= 'b0;
            r_block_row[873] <= 'b0;
            r_block_row[874] <= 'b0;
            r_block_row[875] <= 'b0;
            r_block_row[876] <= 'b0;
            r_block_row[877] <= 'b0;
            r_block_row[878] <= 'b0;
            r_block_row[879] <= 'b0;
            r_block_row[880] <= 'b0;
            r_block_row[881] <= 'b0;
            r_block_row[882] <= 'b0;
            r_block_row[883] <= 'b0;
            r_block_row[884] <= 'b0;
            r_block_row[885] <= 'b0;
            r_block_row[886] <= 'b0;
            r_block_row[887] <= 'b0;
            r_block_row[888] <= 'b0;
            r_block_row[889] <= 'b0;
            r_block_row[890] <= 'b0;
            r_block_row[891] <= 'b0;
            r_block_row[892] <= 'b0;
            r_block_row[893] <= 'b0;
            r_block_row[894] <= 'b0;
            r_block_row[895] <= 'b0;
            r_block_row[896] <= 'b0;
            r_block_row[897] <= 'b0;
            r_block_row[898] <= 'b0;
            r_block_row[899] <= 'b0;
            r_block_row[900] <= 'b0;
            r_block_row[901] <= 'b0;
            r_block_row[902] <= 'b0;
            r_block_row[903] <= 'b0;
            r_block_row[904] <= 'b0;
            r_block_row[905] <= 'b0;
            r_block_row[906] <= 'b0;
            r_block_row[907] <= 'b0;
            r_block_row[908] <= 'b0;
            r_block_row[909] <= 'b0;
            r_block_row[910] <= 'b0;
            r_block_row[911] <= 'b0;
            r_block_row[912] <= 'b0;
            r_block_row[913] <= 'b0;
            r_block_row[914] <= 'b0;
            r_block_row[915] <= 'b0;
            r_block_row[916] <= 'b0;
            r_block_row[917] <= 'b0;
            r_block_row[918] <= 'b0;
            r_block_row[919] <= 'b0;
            r_block_row[920] <= 'b0;
            r_block_row[921] <= 'b0;
            r_block_row[922] <= 'b0;
            r_block_row[923] <= 'b0;
            r_block_row[924] <= 'b0;
            r_block_row[925] <= 'b0;
            r_block_row[926] <= 'b0;
            r_block_row[927] <= 'b0;
            r_block_row[928] <= 'b0;
            r_block_row[929] <= 'b0;
            r_block_row[930] <= 'b0;
            r_block_row[931] <= 'b0;
            r_block_row[932] <= 'b0;
            r_block_row[933] <= 'b0;
            r_block_row[934] <= 'b0;
            r_block_row[935] <= 'b0;
            r_block_row[936] <= 'b0;
            r_block_row[937] <= 'b0;
            r_block_row[938] <= 'b0;
            r_block_row[939] <= 'b0;
            r_block_row[940] <= 'b0;
            r_block_row[941] <= 'b0;
            r_block_row[942] <= 'b0;
            r_block_row[943] <= 'b0;
            r_block_row[944] <= 'b0;
            r_block_row[945] <= 'b0;
            r_block_row[946] <= 'b0;
            r_block_row[947] <= 'b0;
            r_block_row[948] <= 'b0;
            r_block_row[949] <= 'b0;
            r_block_row[950] <= 'b0;
            r_block_row[951] <= 'b0;
            r_block_row[952] <= 'b0;
            r_block_row[953] <= 'b0;
            r_block_row[954] <= 'b0;
            r_block_row[955] <= 'b0;
            r_block_row[956] <= 'b0;
            r_block_row[957] <= 'b0;
            r_block_row[958] <= 'b0;
            r_block_row[959] <= 'b0;
            r_block_row[960] <= 'b0;
            r_block_row[961] <= 'b0;
            r_block_row[962] <= 'b0;
            r_block_row[963] <= 'b0;
            r_block_row[964] <= 'b0;
            r_block_row[965] <= 'b0;
            r_block_row[966] <= 'b0;
            r_block_row[967] <= 'b0;
            r_block_row[968] <= 'b0;
            r_block_row[969] <= 'b0;
            r_block_row[970] <= 'b0;
            r_block_row[971] <= 'b0;
            r_block_row[972] <= 'b0;
            r_block_row[973] <= 'b0;
            r_block_row[974] <= 'b0;
            r_block_row[975] <= 'b0;
            r_block_row[976] <= 'b0;
            r_block_row[977] <= 'b0;
            r_block_row[978] <= 'b0;
            r_block_row[979] <= 'b0;
            r_block_row[980] <= 'b0;
            r_block_row[981] <= 'b0;
            r_block_row[982] <= 'b0;
            r_block_row[983] <= 'b0;
            r_block_row[984] <= 'b0;
            r_block_row[985] <= 'b0;
            r_block_row[986] <= 'b0;
            r_block_row[987] <= 'b0;
            r_block_row[988] <= 'b0;
            r_block_row[989] <= 'b0;
            r_block_row[990] <= 'b0;
            r_block_row[991] <= 'b0;
            r_block_row[992] <= 'b0;
            r_block_row[993] <= 'b0;
            r_block_row[994] <= 'b0;
            r_block_row[995] <= 'b0;
            r_block_row[996] <= 'b0;
            r_block_row[997] <= 'b0;
            r_block_row[998] <= 'b0;
            r_block_row[999] <= 'b0;
            r_block_row[1000] <= 'b0;
            r_block_row[1001] <= 'b0;
            r_block_row[1002] <= 'b0;
            r_block_row[1003] <= 'b0;
            r_block_row[1004] <= 'b0;
            r_block_row[1005] <= 'b0;
            r_block_row[1006] <= 'b0;
            r_block_row[1007] <= 'b0;
            r_block_row[1008] <= 'b0;
            r_block_row[1009] <= 'b0;
            r_block_row[1010] <= 'b0;
            r_block_row[1011] <= 'b0;
            r_block_row[1012] <= 'b0;
            r_block_row[1013] <= 'b0;
            r_block_row[1014] <= 'b0;
            r_block_row[1015] <= 'b0;
            r_block_row[1016] <= 'b0;
            r_block_row[1017] <= 'b0;
            r_block_row[1018] <= 'b0;
            r_block_row[1019] <= 'b0;
            r_block_row[1020] <= 'b0;
            r_block_row[1021] <= 'b0;
            r_block_row[1022] <= 'b0;
            r_block_row[1023] <= 'b0;
            r_block_row[1024] <= 'b0;
            r_block_row[1025] <= 'b0;
            r_block_row[1026] <= 'b0;
            r_block_row[1027] <= 'b0;
            r_block_row[1028] <= 'b0;
            r_block_row[1029] <= 'b0;
            r_block_row[1030] <= 'b0;
            r_block_row[1031] <= 'b0;
            r_block_row[1032] <= 'b0;
            r_block_row[1033] <= 'b0;
            r_block_row[1034] <= 'b0;
            r_block_row[1035] <= 'b0;
            r_block_row[1036] <= 'b0;
            r_block_row[1037] <= 'b0;
            r_block_row[1038] <= 'b0;
            r_block_row[1039] <= 'b0;
            r_block_row[1040] <= 'b0;
            r_block_row[1041] <= 'b0;
            r_block_row[1042] <= 'b0;
            r_block_row[1043] <= 'b0;
            r_block_row[1044] <= 'b0;
            r_block_row[1045] <= 'b0;
            r_block_row[1046] <= 'b0;
            r_block_row[1047] <= 'b0;
            r_block_row[1048] <= 'b0;
            r_block_row[1049] <= 'b0;
            r_block_row[1050] <= 'b0;
            r_block_row[1051] <= 'b0;
            r_block_row[1052] <= 'b0;
            r_block_row[1053] <= 'b0;
            r_block_row[1054] <= 'b0;
            r_block_row[1055] <= 'b0;
        end
        else if(i_start == 1'b1) begin
            r_block_counter[0] <= 'b0;
            r_block_counter[1] <= 'b0;
            r_block_counter[2] <= 'b0;
            r_block_counter[3] <= 'b0;
            r_block_counter[4] <= 'b0;
            r_block_counter[5] <= 'b0;
            r_block_counter[6] <= 'b0;
            r_block_counter[7] <= 'b0;
            r_block_counter[8] <= 'b0;
            r_block_counter[9] <= 'b0;
            r_block_counter[10] <= 'b0;
            r_block_counter[11] <= 'b0;
            r_block_counter[12] <= 'b0;
            r_block_counter[13] <= 'b0;
            r_block_counter[14] <= 'b0;
            r_block_counter[15] <= 'b0;
        end
        else if(w_base_finish == 1'b1) begin
            r_block_col[r_base_index[w_block_index]+r_block_counter[w_block_index]] <= w_sorted_index[(r_counter-1)*INDEX_WIDTH +: LOG2_PES];
            r_block_counter[w_block_index] <= r_block_counter[w_block_index] + 1'b1;
            r_block_row[r_base_index[w_block_index]+r_block_counter[w_block_index]] <= r_row_index;
//            case(w_sorted_index[r_counter*INDEX_WIDTH-1 -: 4])
//                4'b0000: begin
//                    r_block_col[r_base_index[0]+r_block_counter[0]] <= w_sorted_index[(r_counter-1)*INDEX_WIDTH +: LOG2_PES];
//                    r_block_counter[0] <= r_block_counter[0] + 1'b1;
//                end
//                4'b0001: begin
//                    r_block_col[r_base_index[0]+r_block_counter[0]] <= w_sorted_index[(r_counter-1)*INDEX_WIDTH +: LOG2_PES];
//                    r_block_counter[0] <= r_block_counter[0] + 1'b1;
//                end
//            endcase
        end
    end

//    generate
//        for(i = 0; i < BLOCK_NUMBER; i = i+1) begin
//            always @(posedge clk or negedge rst_n) begin
//                if(rst_n == 'b0) begin
//                    r_block_col[i] <= 'b0;
//                    r_block_row[i] <= 'b0;
//                    r_index_valid[i] <= 'b0;
//                    r_block_counter[i] <= 'b0;
//                    r_block_last_index[i] <= 'b0;
//                end
//                else if(i_start == 1'b1) begin
//                    r_block_col[i] <= 'b0;
//                    r_block_row[i] <= 'b0;
//                    r_index_valid[i] <= 'b0;
//                    r_block_counter[i] <= 'b0;
//                    r_block_last_index[i] <= 'b0;
//                end
//                else if(r_block_counter[i] < r_block_count[i] & r_count_finish == 1'b1)begin
//                    if(w_sorted_index[r_counter*INDEX_WIDTH-1 -: 4] == i) begin// 修改：索引宽度由INDEX_WIDTH改为LOG2_PES
//                        r_block_col[i][r_block_counter[i]*LOG2_PES +: LOG2_PES] <= w_sorted_index[(r_counter-1)*INDEX_WIDTH +: LOG2_PES];//w_sorted_index[r_counter*INDEX_WIDTH-1 -: INDEX_WIDTH];
//                        r_block_row[i][r_block_counter[i]*LOG2_HEIGHT +: LOG2_HEIGHT] <= r_row_index;
//                        r_index_valid[i][r_block_counter[i]] <= 1'b1;
//                        r_block_counter[i] <= r_block_counter[i] + 1;
//                        r_block_last_index[i] <= r_row_index;
//                    end
//                end
//                else if (r_block_counter[i] < (ARRAY_WIDTH+32) & r_count_finish == 1'b1) begin// 修改：索引宽度由INDEX_WIDTH改为LOG2_PES
//                    r_block_col[i][r_block_counter[i]*LOG2_PES +: LOG2_PES] <= 'b0;
//                    r_block_row[i][r_block_counter[i]*LOG2_HEIGHT +: LOG2_HEIGHT] <= r_block_last_index[i];
//                    r_index_valid[i][r_block_counter[i]] <= 1'b0;
//                    r_block_counter[i] <= r_block_counter[i] + 1;
//                end
//                // else if(r_count_finish == 1'b1) begin
                    
//                // end
//            end
//        end
//    endgenerate

    generate
        for(i = 0; i < (ARRAY_HEIGHT*K_NUMBER+32); i = i+1) begin
            assign o_block_col[i*LOG2_PES +: LOG2_PES] = r_block_col[i];
            assign o_block_row[i*LOG2_HEIGHT +: LOG2_HEIGHT] = r_block_row[i];
        end
    endgenerate
    
    generate
        for(i = 0; i < BLOCK_NUMBER; i = i+1) begin
            assign o_block_count[i*(LOG2_HEIGHT+LOG2_K) +: (LOG2_HEIGHT+LOG2_K)] = r_block_count[i];
            assign o_base_index[i*(LOG2_HEIGHT+LOG2_K) +: (LOG2_HEIGHT+LOG2_K)] = r_base_index[i];
        end
    endgenerate
//    wire [BLOCK_NUMBER-1:0] w_valid;

//    generate
//        for(i = 0; i < BLOCK_NUMBER; i = i+1) begin
//            assign w_valid[i] = r_block_counter[i] == (ARRAY_WIDTH+32);
//        end
//    endgenerate

    assign o_valid = r_counter == 'd1025;
    
//    assign o_valid = r_over == 16'hffff;

//    reg [LOG2_BLOCK_NUMBER-1:0] r_counter;
//    reg r_counter_stop;
    
//    always @(posedge clk or negedge rst_n) begin
//        if(rst_n == 'b0) begin
//            r_counter_stop <= 'b0;
//        end
//        else if(i_start == 1'b1) begin
//            r_counter_stop <= 1'b0;
//        end
//        else if(r_counter == 4'd15) begin
//            r_counter_stop <= 1'b1;
//        end
        
//    end    
    
//    always @(posedge clk or negedge rst_n) begin
//        if(rst_n == 'b0) begin
//            r_counter <= 'b0;
//        end
//        else if(r_counter_stop) begin
//            r_counter <= 'b0;
//        end
//        else if(w_count_valid == 16'b1000000000000000 | r_count_finish) begin
//            r_counter <= r_counter + 1;
//        end
//    end

//    reg [BLOCK_NUMBER*(LOG2_K+1)-1:0] r_block_count_p [0:ARRAY_HEIGHT-1]; // 记录每块中不同行的起始位置
//    generate
//        for(i = 0; i < ARRAY_HEIGHT; i = i+1) begin
//            always @(posedge clk or negedge rst_n) begin
//                if(rst_n == 'b0) begin
//                    r_block_count_p[i] <= 'b0;
//                end
//                else if(r_counter != 'b0) begin
//                    r_block_count_p[i][r_counter*(LOG2_K+1) +: (LOG2_K+1)] <= r_block_count_p[i][(r_counter-1)*(LOG2_K+1) +: (LOG2_K+1)] + w_row_block_count[i][(r_counter-1)*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)];
//                end
//            end
//        end  
//    endgenerate


    
//    reg [(ARRAY_WIDTH+32)*INDEX_WIDTH-1:0] r_block_col[0:BLOCK_NUMBER-1]; // K_NUMBER其实代表的是每一块的非零元素，稀疏率1/16=K_NUMBER/512，结果是1/16 * HEIGHT * WIDTH
//    reg [(ARRAY_WIDTH+32)*INDEX_WIDTH-1:0] r_block_row[0:BLOCK_NUMBER-1];
//    reg [(ARRAY_WIDTH+32)-1:0] r_index_valid [0:BLOCK_NUMBER-1];

//    reg [5:0] r_counter1 [0:BLOCK_NUMBER-1]; // 分块内的数据计数
//    reg [3:0] r_counter2 [0:BLOCK_NUMBER-1]; // 正在执行的未分块的行，其实是状态机
//    reg [4:0] r_counter3 [0:BLOCK_NUMBER-1]; // 行内的小分块的数据计数
//    reg [BLOCK_NUMBER-1:0] r_over;
    
//    generate
//        for(i = 0; i < BLOCK_NUMBER; i = i+1) begin
//            if(i == 0) begin
//                 always @(posedge clk or negedge rst_n) begin
//                     if(rst_n == 1'b0) begin
//                         r_block_col[i] <= 'b0;
//                         r_block_row[i] <= 'b0;
//                         r_index_valid[i] <= 'b0;
//                         r_counter1[i] <= 'b0;
//                         r_counter2[i] <= 'b0;
//                         r_counter3[i] <= 'b0;
//                         r_over[i] <= 'b0;
//                     end
//                     else if(i_start) begin
//                         r_block_col[i] <= 'b0;
//                         r_block_row[i] <= 'b0;
//                         r_index_valid[i] <= 'b0;
//                         r_counter1[i] <= 'b0;
//                         r_counter2[i] <= 'b0;
//                         r_counter3[i] <= 'b0;
//                         r_over[i] <= 'b0;
//                     end
//                     else if((r_counter1[i] < r_block_count[i]) && r_count_finish) begin
//                         if(r_counter3[i] < w_row_block_count[r_counter2[i]][i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)]) begin
//                                 r_block_col[i][INDEX_WIDTH*r_counter1[i] +: INDEX_WIDTH] <= w_sorted_index[r_counter2[i]][INDEX_WIDTH*r_counter3[i] +: INDEX_WIDTH];
//                                 r_block_row[i][INDEX_WIDTH*r_counter1[i] +: INDEX_WIDTH] <= {i_row_prefix, r_counter2[i]};
//                                 r_index_valid[i][r_counter1[i] +: 1] <= 1'b1;
//                                 r_counter1[i] <= r_counter1[i] + 1;
//                                 r_counter3[i] <= r_counter3[i] + 1;
//                         end
//                         else begin
//                                 r_counter2[i] <= r_counter2[i] + 1;
//                                 r_counter3[i] <= 'b0;
//                         end
//                         // case
//                     end
//                     else begin
//                        r_over[i] <= 1'b1;
//                     end
//                 end
//             end
//             else begin
//                 always @(posedge clk or negedge rst_n) begin
//                     if(rst_n == 1'b0) begin
//                         r_block_col[i] <= 'b0;
//                         r_block_row[i] <= 'b0;
//                         r_index_valid[i] <= 'b0;
//                         r_counter1[i] <= 'b0;
//                         r_counter2[i] <= 'b0;
//                         r_counter3[i] <= 'b0;
//                     end
//                     else if(i_start) begin
//                         r_block_col[i] <= 'b0;
//                         r_block_row[i] <= 'b0;
//                         r_index_valid[i] <= 'b0;
//                         r_counter1[i] <= 'b0;
//                         r_counter2[i] <= 'b0;
//                         r_counter3[i] <= 'b0;
//                     end
//                     else if((r_counter1[i] < r_block_count[i]) && r_count_finish) begin
//                        if(r_counter3[i] < w_row_block_count[r_counter2[i]][i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)]) begin
//                            r_block_col[i][INDEX_WIDTH*r_counter1[i] +: INDEX_WIDTH] <= w_sorted_index[r_counter2[i]][INDEX_WIDTH*(r_counter3[i]+r_block_count_p[r_counter2[i]][i*(LOG2_K+1)+:(LOG2_K+1)]) +: INDEX_WIDTH];
//                            r_block_row[i][INDEX_WIDTH*r_counter1[i] +: INDEX_WIDTH] <= {i_row_prefix, r_counter2[i]};
//                            r_index_valid[i][r_counter1[i] +: 1] <= 1'b1;
//                            r_counter1[i] <= r_counter1[i] + 1;
//                            r_counter3[i] <= r_counter3[i] + 1;
//                        end
//                        else begin
//                            r_counter2[i] <= r_counter2[i] + 1;
//                            r_counter3[i] <= 'b0;
//                        end
//                        // case
//                     end
//                     else begin
//                        r_over[i] <= 1'b1;
//                     end
//                 end
//             end
//        end
//    endgenerate
    

    
endmodule
