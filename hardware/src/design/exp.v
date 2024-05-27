`timescale 0.1ns / 0.1ns

module exp #(
    parameter IN_DATA_WIDTH = 32,
    parameter OUT_DATA_WIDTH = 16,
    parameter FRACTION_WIDTH = 10
)(
    input clk,
    input rst_n,
    input [IN_DATA_WIDTH-1:0] i_data,
    input i_exp_en,
    output reg o_valid,
    output [OUT_DATA_WIDTH-1:0] o_data
);

    // i_data * 0000010111000101
    wire [52:0] w_coefficient_mult_res;
    wire [52:0] w_coefficient_mult_res_2cmp;
    wire [52:0] w_temp_0;
    wire [52:0] w_temp_1;

    exp_mult_0 U_exp_mult_0 (
        .CLK(clk),
        .A(i_data),
        .CE(i_exp_en),
        .P(w_coefficient_mult_res)
    );

    // res = (o_data[10:0] + 0000001111001011) << o_data[15:11] else >> -o_data[15:11]
    assign w_coefficient_mult_res_2cmp = w_coefficient_mult_res[52] ? {~w_coefficient_mult_res[52], ~w_coefficient_mult_res[51:0]+1'b1} : w_coefficient_mult_res; 
    assign w_temp_0 = w_coefficient_mult_res[39:0] + 53'b00000000000001111001011000101000110111010111101100101;
    assign w_temp_1 = w_coefficient_mult_res[52] == 1'b0 ?  w_temp_0 << w_coefficient_mult_res_2cmp[51:40] : w_temp_0 >> (w_coefficient_mult_res_2cmp[51:40] + 1'b1); // 此处+1是向下取整，-1变成-2
    assign o_data =   w_temp_1 == 'b0 ? w_coefficient_mult_res[52] == 1'b0 ? 16'b0111111111111111 : 16'b0000000000000001
                                      : w_temp_1[52:45] > 0 ? 16'b0111111111111111 : w_temp_1[45:30];

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            o_valid <= 1'b0;
        end
        else if(i_exp_en == 1'b1) begin
            o_valid <= 1'b1;
        end
        else begin
            o_valid <= 1'b0;
        end
    end

endmodule //exp
