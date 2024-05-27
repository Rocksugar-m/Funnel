`timescale 0.1ns / 0.1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2024 03:24:22 PM
// Design Name: 
// Module Name: systolic_pe
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


module systolic_pe #(
    parameter IN_DATA_WIDTH = 4,
    parameter OUT_DATA_WIDTH = 8
    )(
    input clk,
    input rst_n,
    input [IN_DATA_WIDTH-1:0] i_data_up,
    input [IN_DATA_WIDTH-1:0] i_data_left,
    input i_spe_en,
    input i_mult_clear,
    output reg o_spe_en,
    output reg [IN_DATA_WIDTH-1:0] o_data_right,
    output reg [IN_DATA_WIDTH-1:0] o_data_down,
    output [OUT_DATA_WIDTH-1:0] o_data
    );
    
    reg [OUT_DATA_WIDTH-1:0] r_partial_sum;
    wire [OUT_DATA_WIDTH-1:0] w_mult_res;
    
    systolic_mult_0 U_systolic_mult_0(
        .CLK(clk),
        .A(i_data_up),
        .B(i_data_left),
        .CE(i_spe_en),
        .SCLR(!i_spe_en),
        .P(w_mult_res)
    );
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_partial_sum <= 'b0;
        end
        else if(i_spe_en & ~i_mult_clear) begin
            r_partial_sum <= r_partial_sum + w_mult_res;
        end
        else if(i_mult_clear) begin
            r_partial_sum <= w_mult_res;
        end
        else begin
            r_partial_sum <= 'b0;
        end
    end 
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            o_data_right <= 'b0;
            o_data_down <= 'b0;
            o_spe_en <= 'b0;
        end
        else begin
            o_data_right <= i_data_left;
            o_data_down <= i_data_up;
            o_spe_en <= i_spe_en;
        end
    end
    
    assign o_data = r_partial_sum;
    
endmodule