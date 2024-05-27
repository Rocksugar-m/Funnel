`timescale 0.1ns / 0.1ns
/////////////////////////////////////////////////////////////////////////

// Design: adder_switch.v
// Author: Eric Qin

// Description: int32 Adder 

/////////////////////////////////////////////////////////////////////////
module adder32(clk, rst_n, A, B, O);

    input [31:0] A, B;
    input clk;
    input rst_n;
    output reg [31:0] O;

    always@(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0) begin
            O <= 'd0;
        end 
        else begin
            O <= A + B;
        end
    end
endmodule