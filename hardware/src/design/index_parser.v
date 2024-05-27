`timescale 0.1ns / 0.1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/10 10:58:46
// Design Name: 
// Module Name: attention_top
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

module index_parser #(
    parameter PE_NUMBER = 32,
    parameter LOG2_HEIGHT = 4,
    parameter LOG2_PES = 4,
    parameter LOG2_K = 5
) (
    input [PE_NUMBER*LOG2_HEIGHT-1:0] i_row_index,
    input [PE_NUMBER*LOG2_PES-1:0] i_col_index,
    input [LOG2_HEIGHT+LOG2_K-1:0] i_remain_count,
    output reg [PE_NUMBER*LOG2_HEIGHT-1:0] o_row_index,
    output reg [PE_NUMBER*LOG2_PES-1:0] o_col_index,
    output reg [PE_NUMBER-1:0] o_pe_en
);
    always @(i_remain_count) begin
        if(i_remain_count[LOG2_HEIGHT+LOG2_K-1:LOG2_PES != 0]) begin
            o_row_index = i_row_index;
            o_col_index = i_col_index;
            o_pe_en = 32'hffffffff;
        end
        else begin
            case (i_remain_count[LOG2_PES-1:0])
                5'b00000: begin
                    o_row_index = 'b0;
                    o_col_index = 'b0;
                    o_pe_en = 32'b0;
                end
                5'b00001: begin
                    o_row_index = {32{i_row_index[0*LOG2_HEIGHT +: LOG2_HEIGHT]}};
                    o_col_index = {{31{5'b0000}}, i_col_index[0 +: 1*LOG2_PES]};
                    o_pe_en = 32'b00000000000000000000000000000001;
                end
                5'b00010: begin
                    o_row_index = {{31{i_row_index[1*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: LOG2_HEIGHT]};
                    o_col_index = {{30{5'b00000}}, {i_col_index[0 +: 2*LOG2_PES]}};
                    o_pe_en = 32'b00000000000000000000000000000011;
                end
                5'b00011: begin
                    o_row_index = {{30{i_row_index[2*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 2*LOG2_HEIGHT]};
                    o_col_index = {{29{5'b00000}}, {i_col_index[0 +: 3*LOG2_PES]}};
                    o_pe_en = 32'b00000000000000000000000000000111;
                end
                5'b00100: begin
                    o_row_index = {{29{i_row_index[3*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 3*LOG2_HEIGHT]};
                    o_col_index = {{28{5'b00000}}, {i_col_index[0 +: 4*LOG2_PES]}};
                    o_pe_en = 32'b00000000000000000000000000001111;
                end
                5'b00101: begin
                    o_row_index = {{28{i_row_index[4*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 4*LOG2_HEIGHT]};
                    o_col_index = {{27{5'b00000}}, {i_col_index[0 +: 5*LOG2_PES]}};
                    o_pe_en = 32'b00000000000000000000000000011111;
                end
                5'b00110: begin
                    o_row_index = {{27{i_row_index[5*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 5*LOG2_HEIGHT]};
                    o_col_index = {{26{5'b00000}}, {i_col_index[0 +: 6*LOG2_PES]}};
                    o_pe_en = 32'b00000000000000000000000000111111;
                end
                5'b00111: begin
                    o_row_index = {{26{i_row_index[6*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 6*LOG2_HEIGHT]};
                    o_col_index = {{25{5'b00000}}, {i_col_index[0 +: 7*LOG2_PES]}};
                    o_pe_en = 32'b00000000000000000000000001111111;
                end
                5'b01000: begin
                    o_row_index = {{25{i_row_index[7*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 7*LOG2_HEIGHT]};
                    o_col_index = {{24{5'b00000}}, {i_col_index[0 +: 8*LOG2_PES]}};
                    o_pe_en = 32'b00000000000000000000000011111111;
                end
                5'b01001: begin
                    o_row_index = {{24{i_row_index[8*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 8*LOG2_HEIGHT]};
                    o_col_index = {{23{5'b00000}}, {i_col_index[0 +: 9*LOG2_PES]}};
                    o_pe_en = 32'b00000000000000000000000111111111;
                end
                5'b01010: begin
                    o_row_index = {{23{i_row_index[9*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 9*LOG2_HEIGHT]};
                    o_col_index = {{22{5'b00000}}, {i_col_index[0 +: 10*LOG2_PES]}};
                    o_pe_en = 32'b00000000000000000000001111111111;
                end
                5'b01011: begin
                    o_row_index = {{22{i_row_index[10*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 10*LOG2_HEIGHT]};
                    o_col_index = {{21{5'b00000}}, {i_col_index[0 +: 11*LOG2_PES]}};
                    o_pe_en = 32'b00000000000000000000011111111111;
                end
                5'b01100: begin
                    o_row_index = {{21{i_row_index[11*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 11*LOG2_HEIGHT]};
                    o_col_index = {{20{5'b00000}}, {i_col_index[0 +: 12*LOG2_PES]}};
                    o_pe_en = 32'b00000000000000000000111111111111;
                end
                5'b01101: begin
                    o_row_index = {{20{i_row_index[12*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 12*LOG2_HEIGHT]};
                    o_col_index = {{19{5'b00000}}, {i_col_index[0 +: 13*LOG2_PES]}};
                    o_pe_en = 32'b00000000000000000001111111111111;
                end
                5'b01110: begin
                    o_row_index = {{19{i_row_index[13*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 13*LOG2_HEIGHT]};
                    o_col_index = {{18{5'b00000}}, {i_col_index[0 +: 14*LOG2_PES]}};
                    o_pe_en = 32'b00000000000000000011111111111111;
                end
                5'b01111: begin
                    o_row_index = {{18{i_row_index[14*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 14*LOG2_HEIGHT]};
                    o_col_index = {{17{5'b00000}}, {i_col_index[0 +: 15*LOG2_PES]}};
                    o_pe_en = 32'b00000000000000000111111111111111;
                end
                5'b10000: begin
                    o_row_index = {{17{i_row_index[15*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 15*LOG2_HEIGHT]};
                    o_col_index = {{16{5'b00000}}, {i_col_index[0 +: 16*LOG2_PES]}};
                    o_pe_en = 32'b00000000000000001111111111111111;
                end
                5'b10001: begin
                    o_row_index = {{16{i_row_index[16*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 16*LOG2_HEIGHT]};
                    o_col_index = {{15{5'b00000}}, {i_col_index[0 +: 17*LOG2_PES]}};
                    o_pe_en = 32'b00000000000000011111111111111111;
                end
                5'b10010: begin
                    o_row_index = {{15{i_row_index[17*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 17*LOG2_HEIGHT]};
                    o_col_index = {{14{5'b00000}}, {i_col_index[0 +: 18*LOG2_PES]}};
                    o_pe_en = 32'b00000000000000111111111111111111;
                end
                5'b10011: begin
                    o_row_index = {{14{i_row_index[18*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 18*LOG2_HEIGHT]};
                    o_col_index = {{13{5'b00000}}, {i_col_index[0 +: 19*LOG2_PES]}};
                    o_pe_en = 32'b00000000000001111111111111111111;
                end
                5'b10100: begin
                    o_row_index = {{13{i_row_index[19*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 19*LOG2_HEIGHT]};
                    o_col_index = {{12{5'b00000}}, {i_col_index[0 +: 20*LOG2_PES]}};
                    o_pe_en = 32'b00000000000011111111111111111111;
                end
                5'b10101: begin
                    o_row_index = {{12{i_row_index[20*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 20*LOG2_HEIGHT]};
                    o_col_index = {{11{5'b00000}}, {i_col_index[0 +: 21*LOG2_PES]}};
                    o_pe_en = 32'b00000000000111111111111111111111;
                end
                5'b10110: begin
                    o_row_index = {{11{i_row_index[21*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 21*LOG2_HEIGHT]};
                    o_col_index = {{10{5'b00000}}, {i_col_index[0 +: 22*LOG2_PES]}};
                    o_pe_en = 32'b00000000001111111111111111111111;
                end
                5'b10111: begin
                    o_row_index = {{10{i_row_index[22*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 22*LOG2_HEIGHT]};
                    o_col_index = {{9{5'b00000}}, {i_col_index[0 +: 23*LOG2_PES]}};
                    o_pe_en = 32'b00000000011111111111111111111111;
                end
                5'b11000: begin
                    o_row_index = {{9{i_row_index[23*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 23*LOG2_HEIGHT]};
                    o_col_index = {{8{5'b00000}}, {i_col_index[0 +: 24*LOG2_PES]}};
                    o_pe_en = 32'b00000000111111111111111111111111;
                end
                5'b11001: begin
                    o_row_index = {{8{i_row_index[24*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 24*LOG2_HEIGHT]};
                    o_col_index = {{7{5'b00000}}, {i_col_index[0 +: 25*LOG2_PES]}};
                    o_pe_en = 32'b00000001111111111111111111111111;
                end
                5'b11010: begin
                    o_row_index = {{7{i_row_index[25*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 25*LOG2_HEIGHT]};
                    o_col_index = {{6{5'b00000}}, {i_col_index[0 +: 26*LOG2_PES]}};
                    o_pe_en = 32'b00000011111111111111111111111111;
                end
                5'b11011: begin
                    o_row_index = {{6{i_row_index[26*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 26*LOG2_HEIGHT]};
                    o_col_index = {{5{5'b00000}}, {i_col_index[0 +: 27*LOG2_PES]}};
                    o_pe_en = 32'b00000111111111111111111111111111;
                end
                5'b11100: begin
                    o_row_index = {{5{i_row_index[27*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 27*LOG2_HEIGHT]};
                    o_col_index = {{4{5'b00000}}, {i_col_index[0 +: 28*LOG2_PES]}};
                    o_pe_en = 32'b00001111111111111111111111111111;
                end
                5'b11101: begin
                    o_row_index = {{4{i_row_index[28*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 28*LOG2_HEIGHT]};
                    o_col_index = {{3{5'b00000}}, {i_col_index[0 +: 29*LOG2_PES]}};
                    o_pe_en = 32'b00011111111111111111111111111111;
                end
                5'b11110: begin
                    o_row_index = {{3{i_row_index[29*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 29*LOG2_HEIGHT]};
                    o_col_index = {{2{5'b00000}}, {i_col_index[0 +: 30*LOG2_PES]}};
                    o_pe_en = 32'b00111111111111111111111111111111;
                end
                default: begin
                    o_row_index = {{2{i_row_index[30*LOG2_HEIGHT +: LOG2_HEIGHT]}}, i_row_index[0 +: 30*LOG2_HEIGHT]};
                    o_col_index = {{1{5'b00000}}, i_col_index[0 +: 31*LOG2_PES]};
                    o_pe_en = 32'b01111111111111111111111111111111;
                end
            endcase
        end
    end
endmodule