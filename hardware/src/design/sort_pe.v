`timescale 0.1ns / 0.1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/24/2024 04:01:52 PM
// Design Name: 
// Module Name: sort_pe
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


module sort_pe #(
//    parameter TOP_K_NUMBER = 30,
    parameter DATA_WIDTH = 4,
    parameter INDEX_WIDTH = 9
    )(
    input clk,
    input rst_n,
    input i_valid,
    input [DATA_WIDTH-1:0] i_data,
    input [(INDEX_WIDTH+1)-1:0] i_index,
    input i_clear,
    output reg o_valid,
    output reg [DATA_WIDTH-1:0] o_shift_data,
    output reg [(INDEX_WIDTH+1)-1:0] o_shift_index,
    output [DATA_WIDTH-1:0] o_data,
    output [INDEX_WIDTH-1:0] o_index
    );
//    localparam signed BOUNDARY = 4'b0;
    localparam signed BOUNDARY = 4'b1001;
    reg [DATA_WIDTH-1:0] r_data; // temporary max value
    reg [(INDEX_WIDTH+1)-1:0] r_index;
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            o_valid <= 'b0;
        end
        else begin
            o_valid <= i_valid;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_data <= BOUNDARY; // 应该初始化为数据范围的下界
            r_index <= {(INDEX_WIDTH+1){1'b1}};
            o_shift_data <= 'b0;
            o_shift_index <= 'b0;
        end
        else if(i_clear) begin
            r_data <= BOUNDARY; // 应该初始化为数据范围的下界
            r_index <= {(INDEX_WIDTH+1){1'b1}};
            o_shift_data <= 'b0;
            o_shift_index <= 'b0;
        end
        else if(i_valid & ($signed(i_data) > $signed(r_data))) begin
            r_data <= i_data;
            r_index <= i_index;
            o_shift_data <= r_data;
            o_shift_index <= r_index;
        end
        else if(i_valid) begin
            r_data <= r_data;
            r_index <= r_index;
            o_shift_data <= i_data;
            o_shift_index <= i_index;
        end
    end
    
    assign o_data = r_data;
    assign o_index = r_index[INDEX_WIDTH-1:0];
    
endmodule
