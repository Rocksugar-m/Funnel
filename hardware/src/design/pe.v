`timescale 0.1ns / 0.1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/04 09:22:18
// Design Name: 
// Module Name: multiplier
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


module pe #(
    parameter IN_DATA_WIDTH = 16,
    parameter OUT_DATA_WIDTH = 32
    )(
    input clk,
    input rst_n,
    input [IN_DATA_WIDTH-1:0] i_operand_q,
    input [IN_DATA_WIDTH-1:0] i_operand_kv,
    input i_pe_en, // 输入数据个数不足PE数目，把PE关闭
    input i_accu_en, // Q*K阶段，不断累加乘积
    input i_part_last, // 最后一个乘积累加到部分和上
    input i_mult_en, // S*V阶段，不进行累加，乘积输出到FAN规约
    input i_mult_clear, // S*V阶段乘积结束，清零部分和
    output o_exp_valid, // 指数运算结束标志，开始进行S*V阶段
    output [OUT_DATA_WIDTH-1:0] o_result
    );
    
    reg [OUT_DATA_WIDTH-1:0] r_partial_sum;
    
    wire [OUT_DATA_WIDTH-1:0] w_temp_sum;
    wire [IN_DATA_WIDTH-1:0] w_exp_result;

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_partial_sum <= 'b0;
        end
        else if(i_mult_clear) begin
            r_partial_sum <= 'b0;
        end
        else if(i_accu_en) begin // TODO:如果将r_counter+1，则将i_part_last加上可以控制正确的输出
            r_partial_sum <= r_partial_sum + w_temp_sum;
        end
        else if(o_exp_valid) begin
            r_partial_sum[IN_DATA_WIDTH-1:0] <= w_exp_result;
        end        
        else begin
            r_partial_sum <= r_partial_sum;
        end
    end

    reg r_exp_en;
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_exp_en <= 1'b0;
        end
        else if(i_accu_en & i_part_last & i_pe_en) begin
            r_exp_en <= 1'b1;
        end
        else begin
            r_exp_en <= 1'b0;
        end
    end

    wire [IN_DATA_WIDTH-1:0] w_A;
    assign w_A = i_accu_en ? i_operand_q : r_partial_sum[IN_DATA_WIDTH-1:0]; // 
    
    wire w_mult_en;
    assign w_mult_en = (i_accu_en | i_mult_en) & i_pe_en;

    mult_gen_0 U_mult_gen_0(
        .CLK(clk),
        .A(w_A),
        .B(i_operand_kv),
        .CE(w_mult_en),
        .P(w_temp_sum)
    );

    exp U_exp(
        .clk(clk),
        .rst_n(rst_n),
        .i_data(r_partial_sum), // 将输入或者输出截断
        .i_exp_en(r_exp_en),
        .o_valid(o_exp_valid),
        .o_data(w_exp_result) // 需要对指数运算结果进行截断，截断结果存入部分和寄存器低16位
    );

    reg r_exp_valid;
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_exp_valid <= 1'b0;
        end
        else begin
            r_exp_valid <= o_exp_valid;
        end
    end

    assign o_result = r_exp_valid ? r_partial_sum : w_temp_sum;
    
endmodule
