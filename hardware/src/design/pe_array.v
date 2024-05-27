`timescale 0.1ns / 0.1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/04 09:22:39
// Design Name: 
// Module Name: mult_array
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


module pe_array #(
    parameter NUM_PES = 32,
    parameter IN_DATA_WIDTH = 16,
    parameter OUT_DATA_WIDTH = 32
    )(
    input clk,
    input rst_n,
    input [NUM_PES*IN_DATA_WIDTH-1:0] i_q_data,
    input [NUM_PES*IN_DATA_WIDTH-1:0] i_kv_data,
    input [NUM_PES-1:0] i_pe_en,
    input i_accu_en,
    input i_part_last,
    input i_mult_en,
    input i_mult_clear,
    output o_exp_valid,
    output [NUM_PES*OUT_DATA_WIDTH-1:0] o_result
    );
    
    genvar i;
    generate
        for(i=0; i<NUM_PES; i=i+1) begin: pe_units
            if (i == 0) begin
                pe #(
                    .IN_DATA_WIDTH(IN_DATA_WIDTH),
                    .OUT_DATA_WIDTH(OUT_DATA_WIDTH)
                ) U_pe(
                    .clk(clk),
                    .rst_n(rst_n),
                    .i_operand_q(i_q_data[i*IN_DATA_WIDTH+:IN_DATA_WIDTH]),
                    .i_operand_kv(i_kv_data[i*IN_DATA_WIDTH+:IN_DATA_WIDTH]),
                    .i_pe_en(i_pe_en[i]),
                    .i_accu_en(i_accu_en),
                    .i_part_last(i_part_last),
                    .i_mult_en(i_mult_en),
                    .i_mult_clear(i_mult_clear),
                    .o_exp_valid(o_exp_valid),
                    .o_result(o_result[i*OUT_DATA_WIDTH+:OUT_DATA_WIDTH])
                );
            end
            else begin
                pe #(
                    .IN_DATA_WIDTH(IN_DATA_WIDTH),
                    .OUT_DATA_WIDTH(OUT_DATA_WIDTH)
                ) U_pe(
                    .clk(clk),
                    .rst_n(rst_n),
                    .i_operand_q(i_q_data[i*IN_DATA_WIDTH+:IN_DATA_WIDTH]),
                    .i_operand_kv(i_kv_data[i*IN_DATA_WIDTH+:IN_DATA_WIDTH]),
                    .i_pe_en(i_pe_en[i]),
                    .i_accu_en(i_accu_en),
                    .i_part_last(i_part_last),
                    .i_mult_en(i_mult_en),
                    .i_mult_clear(i_mult_clear),
                    .o_exp_valid(),
                    .o_result(o_result[i*OUT_DATA_WIDTH+:OUT_DATA_WIDTH])
                );
            end
        end
    endgenerate
    
endmodule
