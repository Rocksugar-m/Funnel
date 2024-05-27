`timescale 0.1ns / 0.1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2023/09/02 17:16:50
// Design Name:
// Module Name: crossbar
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


module crossbar # (
        parameter NUM_PES = 32,
        parameter IN_DATA_WIDTH = 16,
        parameter INDEX_WIDTH = 9
    )(
        input clk,
        input rst_n,
        input [NUM_PES*IN_DATA_WIDTH-1:0] i_data_bus,
        //    input i_k_data_bus
        input [NUM_PES*INDEX_WIDTH-1:0] i_index_bus,
        output reg [NUM_PES*IN_DATA_WIDTH-1:0] o_data_bus
    );

    genvar i;
    generate
        for(i=0; i<NUM_PES; i=i+1) begin:crossbar
            always @(posedge clk or negedge rst_n) begin
                if(rst_n == 1'b0) begin
                    o_data_bus[i*IN_DATA_WIDTH +: IN_DATA_WIDTH] <= 'b0;
                end
                else begin
                    o_data_bus[i*IN_DATA_WIDTH +: IN_DATA_WIDTH] <= i_data_bus[i_index_bus[i*INDEX_WIDTH +: INDEX_WIDTH]*IN_DATA_WIDTH +: IN_DATA_WIDTH];
                end
            end
        end
    endgenerate

endmodule
