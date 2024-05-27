`timescale 0.1ns / 0.1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2024 03:24:22 PM
// Design Name: 
// Module Name: systolic_array
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


module systolic_array #(
    parameter IN_DATA_WIDTH = 4,
    parameter OUT_DATA_WIDTH = 8,
    parameter LOG2_WIDTH = 5,
    parameter ARRAY_WIDTH = 32,
    parameter ARRAY_HEIGHT = 16
    )(
    input clk,
    input rst_n,
    input [IN_DATA_WIDTH*ARRAY_WIDTH-1:0] i_data_v,
    input [IN_DATA_WIDTH*ARRAY_HEIGHT-1:0] i_data_h,
    input i_data_valid,
    output [ARRAY_HEIGHT-1:0] o_data_valid,
    output [OUT_DATA_WIDTH*ARRAY_HEIGHT-1:0] o_data_d,
    output [LOG2_WIDTH*ARRAY_HEIGHT-1:0] o_col_index
    );
    
    wire [IN_DATA_WIDTH-1:0] w_data_v_0;
    reg [IN_DATA_WIDTH*1-1:0] r_v_level_0;
    reg [IN_DATA_WIDTH*2-1:0] r_v_level_1;
    reg [IN_DATA_WIDTH*3-1:0] r_v_level_2;
    reg [IN_DATA_WIDTH*4-1:0] r_v_level_3;
    reg [IN_DATA_WIDTH*5-1:0] r_v_level_4;
    reg [IN_DATA_WIDTH*6-1:0] r_v_level_5;
    reg [IN_DATA_WIDTH*7-1:0] r_v_level_6;
    reg [IN_DATA_WIDTH*8-1:0] r_v_level_7;
    reg [IN_DATA_WIDTH*9-1:0] r_v_level_8;
    reg [IN_DATA_WIDTH*10-1:0] r_v_level_9;
    reg [IN_DATA_WIDTH*11-1:0] r_v_level_10;
    reg [IN_DATA_WIDTH*12-1:0] r_v_level_11;
    reg [IN_DATA_WIDTH*13-1:0] r_v_level_12;
    reg [IN_DATA_WIDTH*14-1:0] r_v_level_13;
    reg [IN_DATA_WIDTH*15-1:0] r_v_level_14;
    reg [IN_DATA_WIDTH*16-1:0] r_v_level_15;
    reg [IN_DATA_WIDTH*17-1:0] r_v_level_16;
    reg [IN_DATA_WIDTH*18-1:0] r_v_level_17;
    reg [IN_DATA_WIDTH*19-1:0] r_v_level_18;
    reg [IN_DATA_WIDTH*20-1:0] r_v_level_19;
    reg [IN_DATA_WIDTH*21-1:0] r_v_level_20;
    reg [IN_DATA_WIDTH*22-1:0] r_v_level_21;
    reg [IN_DATA_WIDTH*23-1:0] r_v_level_22;
    reg [IN_DATA_WIDTH*24-1:0] r_v_level_23;
    reg [IN_DATA_WIDTH*25-1:0] r_v_level_24;
    reg [IN_DATA_WIDTH*26-1:0] r_v_level_25;
    reg [IN_DATA_WIDTH*27-1:0] r_v_level_26;
    reg [IN_DATA_WIDTH*28-1:0] r_v_level_27;
    reg [IN_DATA_WIDTH*29-1:0] r_v_level_28;
    reg [IN_DATA_WIDTH*30-1:0] r_v_level_29;
    reg [IN_DATA_WIDTH*31-1:0] r_v_level_30;
    
    wire [IN_DATA_WIDTH-1:0] w_data_h_0;
    reg [IN_DATA_WIDTH*1-1:0] r_h_level_0;
    reg [IN_DATA_WIDTH*2-1:0] r_h_level_1;
    reg [IN_DATA_WIDTH*3-1:0] r_h_level_2;
    reg [IN_DATA_WIDTH*4-1:0] r_h_level_3;
    reg [IN_DATA_WIDTH*5-1:0] r_h_level_4;
    reg [IN_DATA_WIDTH*6-1:0] r_h_level_5;
    reg [IN_DATA_WIDTH*7-1:0] r_h_level_6;
    reg [IN_DATA_WIDTH*8-1:0] r_h_level_7;
    reg [IN_DATA_WIDTH*9-1:0] r_h_level_8;
    reg [IN_DATA_WIDTH*10-1:0] r_h_level_9;
    reg [IN_DATA_WIDTH*11-1:0] r_h_level_10;
    reg [IN_DATA_WIDTH*12-1:0] r_h_level_11;
    reg [IN_DATA_WIDTH*13-1:0] r_h_level_12;
    reg [IN_DATA_WIDTH*14-1:0] r_h_level_13;
    reg [IN_DATA_WIDTH*15-1:0] r_h_level_14;
    
    assign w_data_v_0 = i_data_v[IN_DATA_WIDTH-1:0];
    assign w_data_h_0 = i_data_h[IN_DATA_WIDTH-1:0];
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_v_level_0 <= 'b0;
            r_v_level_1 <= 'b0;
            r_v_level_2 <= 'b0;
            r_v_level_3 <= 'b0;
            r_v_level_4 <= 'b0;
            r_v_level_5 <= 'b0;
            r_v_level_6 <= 'b0;
            r_v_level_7 <= 'b0;
            r_v_level_8 <= 'b0;
            r_v_level_9 <= 'b0;
            r_v_level_10 <= 'b0;
            r_v_level_11 <= 'b0;
            r_v_level_12 <= 'b0;
            r_v_level_13 <= 'b0;
            r_v_level_14 <= 'b0;
            r_v_level_15 <= 'b0;
            r_v_level_16 <= 'b0;
            r_v_level_17 <= 'b0;
            r_v_level_18 <= 'b0;
            r_v_level_19 <= 'b0;
            r_v_level_20 <= 'b0;
            r_v_level_21 <= 'b0;
            r_v_level_22 <= 'b0;
            r_v_level_23 <= 'b0;
            r_v_level_24 <= 'b0;
            r_v_level_25 <= 'b0;
            r_v_level_26 <= 'b0;
            r_v_level_27 <= 'b0;
            r_v_level_28 <= 'b0;
            r_v_level_29 <= 'b0;
            r_v_level_30 <= 'b0;
        end
        else begin
            r_v_level_0[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-0)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-0-1)];
            r_v_level_1[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-1)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-1-1)];
            r_v_level_1[IN_DATA_WIDTH*2-1:IN_DATA_WIDTH] <= r_v_level_0;
            r_v_level_2[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-2)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-2-1)];
            r_v_level_2[IN_DATA_WIDTH*3-1:IN_DATA_WIDTH] <= r_v_level_1;
            r_v_level_3[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-3)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-3-1)];
            r_v_level_3[IN_DATA_WIDTH*4-1:IN_DATA_WIDTH] <= r_v_level_2;
            r_v_level_4[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-4)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-4-1)];
            r_v_level_4[IN_DATA_WIDTH*5-1:IN_DATA_WIDTH] <= r_v_level_3;
            r_v_level_5[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-5)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-5-1)];
            r_v_level_5[IN_DATA_WIDTH*6-1:IN_DATA_WIDTH] <= r_v_level_4;
            r_v_level_6[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-6)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-6-1)];
            r_v_level_6[IN_DATA_WIDTH*7-1:IN_DATA_WIDTH] <= r_v_level_5;
            r_v_level_7[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-7)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-7-1)];
            r_v_level_7[IN_DATA_WIDTH*8-1:IN_DATA_WIDTH] <= r_v_level_6;
            r_v_level_8[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-8)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-8-1)];
            r_v_level_8[IN_DATA_WIDTH*9-1:IN_DATA_WIDTH] <= r_v_level_7;
            r_v_level_9[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-9)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-9-1)];
            r_v_level_9[IN_DATA_WIDTH*10-1:IN_DATA_WIDTH] <= r_v_level_8;
            r_v_level_10[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-10)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-10-1)];
            r_v_level_10[IN_DATA_WIDTH*11-1:IN_DATA_WIDTH] <= r_v_level_9;
            r_v_level_11[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-11)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-11-1)];
            r_v_level_11[IN_DATA_WIDTH*12-1:IN_DATA_WIDTH] <= r_v_level_10;
            r_v_level_12[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-12)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-12-1)];
            r_v_level_12[IN_DATA_WIDTH*13-1:IN_DATA_WIDTH] <= r_v_level_11;
            r_v_level_13[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-13)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-13-1)];
            r_v_level_13[IN_DATA_WIDTH*14-1:IN_DATA_WIDTH] <= r_v_level_12;
            r_v_level_14[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-14)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-14-1)];
            r_v_level_14[IN_DATA_WIDTH*15-1:IN_DATA_WIDTH] <= r_v_level_13;
            r_v_level_15[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-15)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-15-1)];
            r_v_level_15[IN_DATA_WIDTH*16-1:IN_DATA_WIDTH] <= r_v_level_14;
            r_v_level_16[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-16)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-16-1)];
            r_v_level_16[IN_DATA_WIDTH*17-1:IN_DATA_WIDTH] <= r_v_level_15;
            r_v_level_17[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-17)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-17-1)];
            r_v_level_17[IN_DATA_WIDTH*18-1:IN_DATA_WIDTH] <= r_v_level_16;
            r_v_level_18[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-18)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-18-1)];
            r_v_level_18[IN_DATA_WIDTH*19-1:IN_DATA_WIDTH] <= r_v_level_17;
            r_v_level_19[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-19)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-19-1)];
            r_v_level_19[IN_DATA_WIDTH*20-1:IN_DATA_WIDTH] <= r_v_level_18;
            r_v_level_20[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-20)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-20-1)];
            r_v_level_20[IN_DATA_WIDTH*21-1:IN_DATA_WIDTH] <= r_v_level_19;
            r_v_level_21[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-21)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-21-1)];
            r_v_level_21[IN_DATA_WIDTH*22-1:IN_DATA_WIDTH] <= r_v_level_20;
            r_v_level_22[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-22)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-22-1)];
            r_v_level_22[IN_DATA_WIDTH*23-1:IN_DATA_WIDTH] <= r_v_level_21;
            r_v_level_23[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-23)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-23-1)];
            r_v_level_23[IN_DATA_WIDTH*24-1:IN_DATA_WIDTH] <= r_v_level_22;
            r_v_level_24[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-24)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-24-1)];
            r_v_level_24[IN_DATA_WIDTH*25-1:IN_DATA_WIDTH] <= r_v_level_23;
            r_v_level_25[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-25)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-25-1)];
            r_v_level_25[IN_DATA_WIDTH*26-1:IN_DATA_WIDTH] <= r_v_level_24;
            r_v_level_26[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-26)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-26-1)];
            r_v_level_26[IN_DATA_WIDTH*27-1:IN_DATA_WIDTH] <= r_v_level_25;
            r_v_level_27[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-27)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-27-1)];
            r_v_level_27[IN_DATA_WIDTH*28-1:IN_DATA_WIDTH] <= r_v_level_26;
            r_v_level_28[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-28)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-28-1)];
            r_v_level_28[IN_DATA_WIDTH*29-1:IN_DATA_WIDTH] <= r_v_level_27;
            r_v_level_29[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-29)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-29-1)];
            r_v_level_29[IN_DATA_WIDTH*30-1:IN_DATA_WIDTH] <= r_v_level_28;
            r_v_level_30[IN_DATA_WIDTH-1:0] <= i_data_v[IN_DATA_WIDTH*(ARRAY_WIDTH-30)-1:IN_DATA_WIDTH*(ARRAY_WIDTH-30-1)];
            r_v_level_30[IN_DATA_WIDTH*31-1:IN_DATA_WIDTH] <= r_v_level_29;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_h_level_0 <= 'b0;
            r_h_level_1 <= 'b0;
            r_h_level_2 <= 'b0;
            r_h_level_3 <= 'b0;
            r_h_level_4 <= 'b0;
            r_h_level_5 <= 'b0;
            r_h_level_6 <= 'b0;
            r_h_level_7 <= 'b0;
            r_h_level_8 <= 'b0;
            r_h_level_9 <= 'b0;
            r_h_level_10 <= 'b0;
            r_h_level_11 <= 'b0;
            r_h_level_12 <= 'b0;
            r_h_level_13 <= 'b0;
            r_h_level_14 <= 'b0;
        end
        else begin
            r_h_level_0[IN_DATA_WIDTH-1:0] <= i_data_h[IN_DATA_WIDTH*(ARRAY_HEIGHT-0)-1:IN_DATA_WIDTH*(ARRAY_HEIGHT-0-1)];
            r_h_level_1[IN_DATA_WIDTH-1:0] <= i_data_h[IN_DATA_WIDTH*(ARRAY_HEIGHT-1)-1:IN_DATA_WIDTH*(ARRAY_HEIGHT-1-1)];
            r_h_level_1[IN_DATA_WIDTH*2-1:IN_DATA_WIDTH] <= r_h_level_0;
            r_h_level_2[IN_DATA_WIDTH-1:0] <= i_data_h[IN_DATA_WIDTH*(ARRAY_HEIGHT-2)-1:IN_DATA_WIDTH*(ARRAY_HEIGHT-2-1)];
            r_h_level_2[IN_DATA_WIDTH*3-1:IN_DATA_WIDTH] <= r_h_level_1;
            r_h_level_3[IN_DATA_WIDTH-1:0] <= i_data_h[IN_DATA_WIDTH*(ARRAY_HEIGHT-3)-1:IN_DATA_WIDTH*(ARRAY_HEIGHT-3-1)];
            r_h_level_3[IN_DATA_WIDTH*4-1:IN_DATA_WIDTH] <= r_h_level_2;
            r_h_level_4[IN_DATA_WIDTH-1:0] <= i_data_h[IN_DATA_WIDTH*(ARRAY_HEIGHT-4)-1:IN_DATA_WIDTH*(ARRAY_HEIGHT-4-1)];
            r_h_level_4[IN_DATA_WIDTH*5-1:IN_DATA_WIDTH] <= r_h_level_3;
            r_h_level_5[IN_DATA_WIDTH-1:0] <= i_data_h[IN_DATA_WIDTH*(ARRAY_HEIGHT-5)-1:IN_DATA_WIDTH*(ARRAY_HEIGHT-5-1)];
            r_h_level_5[IN_DATA_WIDTH*6-1:IN_DATA_WIDTH] <= r_h_level_4;
            r_h_level_6[IN_DATA_WIDTH-1:0] <= i_data_h[IN_DATA_WIDTH*(ARRAY_HEIGHT-6)-1:IN_DATA_WIDTH*(ARRAY_HEIGHT-6-1)];
            r_h_level_6[IN_DATA_WIDTH*7-1:IN_DATA_WIDTH] <= r_h_level_5;
            r_h_level_7[IN_DATA_WIDTH-1:0] <= i_data_h[IN_DATA_WIDTH*(ARRAY_HEIGHT-7)-1:IN_DATA_WIDTH*(ARRAY_HEIGHT-7-1)];
            r_h_level_7[IN_DATA_WIDTH*8-1:IN_DATA_WIDTH] <= r_h_level_6;
            r_h_level_8[IN_DATA_WIDTH-1:0] <= i_data_h[IN_DATA_WIDTH*(ARRAY_HEIGHT-8)-1:IN_DATA_WIDTH*(ARRAY_HEIGHT-8-1)];
            r_h_level_8[IN_DATA_WIDTH*9-1:IN_DATA_WIDTH] <= r_h_level_7;
            r_h_level_9[IN_DATA_WIDTH-1:0] <= i_data_h[IN_DATA_WIDTH*(ARRAY_HEIGHT-9)-1:IN_DATA_WIDTH*(ARRAY_HEIGHT-9-1)];
            r_h_level_9[IN_DATA_WIDTH*10-1:IN_DATA_WIDTH] <= r_h_level_8;
            r_h_level_10[IN_DATA_WIDTH-1:0] <= i_data_h[IN_DATA_WIDTH*(ARRAY_HEIGHT-10)-1:IN_DATA_WIDTH*(ARRAY_HEIGHT-10-1)];
            r_h_level_10[IN_DATA_WIDTH*11-1:IN_DATA_WIDTH] <= r_h_level_9;
            r_h_level_11[IN_DATA_WIDTH-1:0] <= i_data_h[IN_DATA_WIDTH*(ARRAY_HEIGHT-11)-1:IN_DATA_WIDTH*(ARRAY_HEIGHT-11-1)];
            r_h_level_11[IN_DATA_WIDTH*12-1:IN_DATA_WIDTH] <= r_h_level_10;
            r_h_level_12[IN_DATA_WIDTH-1:0] <= i_data_h[IN_DATA_WIDTH*(ARRAY_HEIGHT-12)-1:IN_DATA_WIDTH*(ARRAY_HEIGHT-12-1)];
            r_h_level_12[IN_DATA_WIDTH*13-1:IN_DATA_WIDTH] <= r_h_level_11;
            r_h_level_13[IN_DATA_WIDTH-1:0] <= i_data_h[IN_DATA_WIDTH*(ARRAY_HEIGHT-13)-1:IN_DATA_WIDTH*(ARRAY_HEIGHT-13-1)];
            r_h_level_13[IN_DATA_WIDTH*14-1:IN_DATA_WIDTH] <= r_h_level_12;
            r_h_level_14[IN_DATA_WIDTH-1:0] <= i_data_h[IN_DATA_WIDTH*(ARRAY_HEIGHT-14)-1:IN_DATA_WIDTH*(ARRAY_HEIGHT-14-1)];
            r_h_level_14[IN_DATA_WIDTH*15-1:IN_DATA_WIDTH] <= r_h_level_13;
        end
    end
    
    reg r_data_valid;
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_data_valid <= 'b0;
        end
        else begin
            r_data_valid <= i_data_valid;
        end
    end
    
    reg [5:0] flow_counter;
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            flow_counter <= 'b0;
        end
        else if(r_data_valid) begin
            flow_counter <= flow_counter + 'b1;
        end
        else begin
            flow_counter <= 'b0;
        end
    end
    
    wire [ARRAY_HEIGHT+ARRAY_WIDTH-1-1:0] w_spe_en;
    
    wire [OUT_DATA_WIDTH-1:0] w_res [0:ARRAY_HEIGHT-1][0:ARRAY_WIDTH-1];
    
    wire [IN_DATA_WIDTH-1:0] w_pass_data_v [0:ARRAY_HEIGHT-1][0:ARRAY_WIDTH-1];
    wire [IN_DATA_WIDTH-1:0] w_pass_data_h [0:ARRAY_HEIGHT-1][0:ARRAY_WIDTH-1];
    
    reg [LOG2_WIDTH-1:0] counter [0:ARRAY_HEIGHT-1];
    reg r_out_en;
    
    localparam [LOG2_WIDTH*ARRAY_WIDTH-1:0] constant = {5'd31, 5'd30, 5'd29, 5'd28, 5'd27, 5'd26, 5'd25, 5'd24, 5'd23, 5'd22, 5'd21, 5'd20, 5'd19, 5'd18, 5'd17, 5'd16, 5'd15, 5'd14, 5'd13, 5'd12, 5'd11, 5'd10, 5'd9, 5'd8, 5'd7, 5'd6, 5'd5, 5'd4, 5'd3, 5'd2, 5'd1, 5'd0};
    
    genvar i, j;
    generate
        for(i = 0; i < ARRAY_HEIGHT; i = i+1) begin
            for(j = 0; j < ARRAY_WIDTH; j = j+1) begin
                if(i == 0 && j == 0) begin
                    systolic_pe #(
                        .IN_DATA_WIDTH(IN_DATA_WIDTH),
                        .OUT_DATA_WIDTH(OUT_DATA_WIDTH)
                    ) U_systolic_pe(
                        .clk(clk),
                        .rst_n(rst_n),
                        .i_data_up(i_data_v[IN_DATA_WIDTH-1:0]),
                        .i_data_left(i_data_h[IN_DATA_WIDTH-1:0]),
                        .i_spe_en(i_data_valid | r_data_valid),
                        .i_mult_clear(r_out_en == 1'b1 && counter[0] == 'b0),
                        .o_spe_en(w_spe_en[i]),
                        .o_data_right(w_pass_data_h[i][j]),
                        .o_data_down(w_pass_data_v[i][j]),
                        .o_data(w_res[i][j])
                    );
                end
                else if(i == 0) begin
                    systolic_pe #(
                        .IN_DATA_WIDTH(IN_DATA_WIDTH),
                        .OUT_DATA_WIDTH(OUT_DATA_WIDTH)
                    ) U_systolic_pe(
                        .clk(clk),
                        .rst_n(rst_n),
                        .i_data_up(r_v_level_30[IN_DATA_WIDTH*(j-1)+:IN_DATA_WIDTH]),
                        .i_data_left(w_pass_data_h[i][j-1]),
                        .i_spe_en(w_spe_en[i+j-1]),
                        .i_mult_clear(counter[0] == j),//constant[j*5+:5]),
                        .o_spe_en(w_spe_en[i+j]),
                        .o_data_right(w_pass_data_h[i][j]),
                        .o_data_down(w_pass_data_v[i][j]),
                        .o_data(w_res[i][j])
                    );
                end
                else if(j == 0) begin
                    systolic_pe #(
                        .IN_DATA_WIDTH(IN_DATA_WIDTH),
                        .OUT_DATA_WIDTH(OUT_DATA_WIDTH)
                    ) U_systolic_pe(
                        .clk(clk),
                        .rst_n(rst_n),
                        .i_data_up(w_pass_data_v[i-1][j]),
                        .i_data_left(r_h_level_14[IN_DATA_WIDTH*(i-1)+:IN_DATA_WIDTH]),
                        .i_spe_en(w_spe_en[i+j-1]),
                        .i_mult_clear(counter[0] == i),//constant[i*5+:5]),
                        .o_spe_en(),
                        .o_data_right(w_pass_data_h[i][j]),
                        .o_data_down(w_pass_data_v[i][j]),
                        .o_data(w_res[i][j])
                    );
                end
                else if(j == ARRAY_WIDTH-1) begin
                    systolic_pe #(
                        .IN_DATA_WIDTH(IN_DATA_WIDTH),
                        .OUT_DATA_WIDTH(OUT_DATA_WIDTH)
                    ) U_systolic_pe(
                        .clk(clk),
                        .rst_n(rst_n),
                        .i_data_up(w_pass_data_v[i-1][j]),
                        .i_data_left(w_pass_data_h[i][j-1]),
                        .i_spe_en(w_spe_en[i+j-1]),
                        .i_mult_clear(counter[i] == j),//constant[j*5+:5]),
                        .o_spe_en(w_spe_en[i+j]),
                        .o_data_right(w_pass_data_h[i][j]),
                        .o_data_down(w_pass_data_v[i][j]),
                        .o_data(w_res[i][j])
                    );
                end
                else begin
                    systolic_pe #(
                        .IN_DATA_WIDTH(IN_DATA_WIDTH),
                        .OUT_DATA_WIDTH(OUT_DATA_WIDTH)
                    ) U_systolic_pe(
                        .clk(clk),
                        .rst_n(rst_n),
                        .i_data_up(w_pass_data_v[i-1][j]),
                        .i_data_left(w_pass_data_h[i][j-1]),
                        .i_spe_en(w_spe_en[i+j-1]),
                        .i_mult_clear(counter[i] == j),//constant[j*5+:5]),
                        .o_spe_en(),
                        .o_data_right(w_pass_data_h[i][j]),
                        .o_data_down(w_pass_data_v[i][j]),
                        .o_data(w_res[i][j])
                    );
                end
            end
        end
    endgenerate


    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_out_en <= 'b0;
        end
        else if(flow_counter == 'd63) begin
            r_out_en <= 1'b1;
        end
        else if(counter[0] == 'd31) begin
            r_out_en <= 1'b0;
        end
        else begin
            r_out_en <= r_out_en;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            counter[0] <= 'b0;
        end
        else if(r_out_en == 1'b1) begin
            counter[0] <= counter[0] + 1;
        end
        else begin
            counter[0] <= 'b0;
        end
    end
    
    generate
        for(i = 1; i < ARRAY_HEIGHT; i = i+1) begin
            always @(posedge clk or negedge rst_n) begin
                if(rst_n == 1'b0) begin
                    counter[i] <= 'b0;
                end
                else if(counter[i-1] != 'b0) begin
                    counter[i] <= counter[i] + 1;
                end
                else begin
                    counter[i] <= 'b0;
                end
            end
        end
    endgenerate
    
    
    generate
        for(i = 0; i < ARRAY_HEIGHT; i = i+1) begin
            assign o_data_d[OUT_DATA_WIDTH*i+:OUT_DATA_WIDTH] = w_res[i][counter[i]];
        end
    endgenerate
    
    generate
        for(i = 0; i < ARRAY_HEIGHT; i = i+1) begin
            if(i == 0) begin
               assign  o_data_valid[i] = (r_out_en == 1'b1 && counter[0] == 'b0) || counter[i] != 'b0;
            end
            else begin
                assign o_data_valid[i] = counter[0] == constant[i*5+:5] || counter[i] != 'b0;
            end
        end
    endgenerate
    
    generate
        for(i = 0; i < ARRAY_HEIGHT; i = i+1) begin
            assign o_col_index[i*LOG2_WIDTH +: LOG2_WIDTH] = counter[i];
        end
    endgenerate
    
endmodule
