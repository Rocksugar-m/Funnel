`timescale 0.1ns / 0.1ns

module fan_reorder #(
    parameter DATA_WIDTH = 32,
    parameter NUM_PES = 32,
    parameter LOG2_PES = 5,
    parameter LOG2_HEIGHT = 4
) (
    input clk,
    input rst_n,
    input [NUM_PES*DATA_WIDTH-1:0] 	i_data,
    input [NUM_PES-1:0] 		    i_valid,
    input [NUM_PES*LOG2_HEIGHT-1:0] i_index,
    output reg [NUM_PES*DATA_WIDTH-1:0] o_data
);

    // binary search
    wire [DATA_WIDTH*NUM_PES-1:0] w_data;
    wire [NUM_PES-1:0] w_seq [0:NUM_PES-1];
    wire [LOG2_PES-1:0] w_pos [0:NUM_PES-1];
    wire [NUM_PES-1:0] w_one;
    genvar i, j;
    generate
        for (i = 0; i < NUM_PES; i = i + 1) begin
            for (j = 0; j < NUM_PES; j = j + 1) begin
                assign w_seq[i][j] = i_valid[j] & (i_index[j*LOG2_HEIGHT+:LOG2_HEIGHT]==i);
            end

            seq_head_detect #(
                .NUM_PES(NUM_PES),
                .LOG2_PES(LOG2_PES)
            ) u_seq_head_detect(
                .i_seq(w_seq[i]),
                .o_pos(w_pos[i]),
                .o_one(w_one[i])
            );

            assign w_data[i*DATA_WIDTH+:DATA_WIDTH] = w_one ? i_data[w_pos[i]*DATA_WIDTH+:DATA_WIDTH] : 'b0;
        end
    endgenerate

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            o_data <= 'b0;
        end
        else begin
            o_data <= w_data;
        end
    end

endmodule

module seq_head_detect #(
    parameter NUM_PES = 32,
    parameter LOG2_PES = 5
)(
    input [NUM_PES-1:0] i_seq,
    output [LOG2_PES-1:0] o_pos,
    output o_one
);
    wire [15:0] w_split_1;
    wire [7:0] w_split_2;
    wire [3:0] w_split_3;
    wire [1:0] w_split_4;
    
    assign o_pos[4] = | i_seq[31:16];
    assign w_split_1 = o_pos[4] ? i_seq[31:16] : i_seq[15:0];
    assign o_pos[3] = | w_split_1[15:8];
    assign w_split_2 = o_pos[3] ? w_split_1[15:8] : w_split_1[7:0];
    assign o_pos[2] = | w_split_2[7:4];
    assign w_split_3 = o_pos[2] ? w_split_2[7:4] : w_split_2[3:0];
    assign o_pos[1] = | w_split_3[3:2];
    assign w_split_4 = o_pos[1] ? w_split_3[3:2] : w_split_3[1:0];
    assign o_pos[0] = | w_split_4[1];

    assign o_one = | i_seq;
endmodule