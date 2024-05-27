`timescale 0.1ns / 0.1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/24/2024 04:02:12 PM
// Design Name: 
// Module Name: insert_sort
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


module insert_sort #(
    parameter K_NUMBER = 32,
    parameter BLOCK_NUMBER = 16,
    parameter LOG2_BLOCK_NUMBER = 4,
    parameter LOG2_WIDTH = 5,
    parameter DATA_WIDTH = 4,
    parameter INDEX_WIDTH = 9
    )(
    input clk,
    input rst_n,
    input i_valid,
    input [DATA_WIDTH-1:0] i_data,
    input [INDEX_WIDTH-1:0] i_index,
    input i_clear,
    input i_last_block,
    output o_valid,
    output [DATA_WIDTH*K_NUMBER-1:0] o_sorted_data,
    output [INDEX_WIDTH*K_NUMBER-1:0] o_sorted_index,
    output reg [BLOCK_NUMBER*(LOG2_WIDTH+1)-1:0] o_row_block_count,
    output reg o_count_valid
    );
    
    wire [DATA_WIDTH-1:0] w_data [0:K_NUMBER-1];
    wire [(INDEX_WIDTH+1)-1:0] w_index [0:K_NUMBER-1];
    wire [K_NUMBER-1:0] w_valid;

    genvar i;
    generate 
        for(i = 0; i < K_NUMBER; i = i + 1) begin
            if(i == 0) begin
                sort_pe #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .INDEX_WIDTH(INDEX_WIDTH)
                    ) U_sort_pe(
                    .clk(clk),
                    .rst_n(rst_n),
                    .i_valid(i_valid),
                    .i_data(i_data),
                    .i_index({1'b0,i_index}),
                    .i_clear(i_clear),
                    .o_valid(w_valid[i]),
                    .o_shift_data(w_data[i]),
                    .o_shift_index(w_index[i]),
                    .o_data(o_sorted_data[i*DATA_WIDTH +: DATA_WIDTH]),
                    .o_index(o_sorted_index[i*INDEX_WIDTH +: INDEX_WIDTH]) // TODO
                );
            end
//            else if(i == K_NUMBER-1) begin
//                sort_pe #(
//                    .DATA_WIDTH(DATA_WIDTH),
//                    .INDEX_WIDTH(INDEX_WIDTH)
//                    ) U_sort_pe(
//                    .clk(clk),
//                    .rst_n(rst_n),
//                    .i_valid(w_valid[i-1]),
//                    .i_data(w_data[i-1]),
//                    .i_index(w_index[i-1]),
//                    .o_valid(w_valid[i]),
//                    .o_shift_data(w_data[i]),
//                    .o_shift_index(w_index[i]),
//                    .o_data(o_sorted_data[i*DATA_WIDTH +: DATA_WIDTH]),
//                    .o_index(o_sorted_index[i*INDEX_WIDTH +: INDEX_WIDTH]) // TODO
//                );
//            end
            else begin
                sort_pe #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .INDEX_WIDTH(INDEX_WIDTH)
                    ) U_sort_pe(
                    .clk(clk),
                    .rst_n(rst_n),
                    .i_valid(w_valid[i-1]),
                    .i_data(w_data[i-1]),
                    .i_index(w_index[i-1]),
                    .i_clear(i_clear),
                    .o_valid(w_valid[i]),
                    .o_shift_data(w_data[i]),
                    .o_shift_index(w_index[i]),
                    .o_data(o_sorted_data[i*DATA_WIDTH +: DATA_WIDTH]),
                    .o_index(o_sorted_index[i*INDEX_WIDTH +: INDEX_WIDTH]) // TODO
                );
            end
        end
    endgenerate
    
    assign o_valid = i_last_block && w_valid[K_NUMBER-2:0] == 'b0 && w_valid[K_NUMBER-1] == 1'b1;

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            o_count_valid <= 'b0;
        end
        else begin
            o_count_valid <= o_valid;
        end
    end

    generate
        for(i = 0; i < BLOCK_NUMBER; i = i+1) begin
            always @(posedge clk or negedge rst_n) begin
                if(rst_n == 1'b0) begin
                    o_row_block_count[i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)] <= 6'b100000;//6:LOG2_WIDTH+1 {(LOG2_WIDTH+1){1'b1}};
                end
                else if((w_index[K_NUMBER-1][(INDEX_WIDTH+1)-1:(INDEX_WIDTH+1)-1-LOG2_BLOCK_NUMBER] == i) && w_valid[K_NUMBER-1]) begin
                    o_row_block_count[i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)] <= o_row_block_count[i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)] - 1'b1;
                end
                else if(i_clear) begin // 清空计数器 right or not?
                    o_row_block_count[i*(LOG2_WIDTH+1) +: (LOG2_WIDTH+1)] <= 6'b100000;//6:LOG2_WIDTH+1 {(LOG2_WIDTH+1){1'b1}};
                end
            end
        end
    endgenerate
    
endmodule