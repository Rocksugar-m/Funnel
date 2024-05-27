`timescale 0.1ns / 0.1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2023/09/26 16:15:27
// Design Name:
// Module Name: block_pe
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
// TODO:如果输入的数据和PE数量不相同，则fan网络规约还需要修改

module cu #(
        parameter NUM_PES = 32,
        parameter IN_DATA_WIDTH = 16,
        parameter OUT_DATA_WIDTH = 32,
        parameter INDEX_WIDTH = 9,
        parameter LOG2_PES = 5,
        parameter ARRAY_HEIGHT = 16,
        parameter LOG2_HEIGHT = 4
    )(
        input clk,
        input rst_n,
        input [NUM_PES*IN_DATA_WIDTH-1:0] i_q_data_bus,
        input [NUM_PES*IN_DATA_WIDTH-1:0] i_kv_data_bus,
        input [NUM_PES*LOG2_HEIGHT-1:0] i_q_index_bus,
        input [NUM_PES*LOG2_PES-1:0] i_kv_index_bus,
        input [NUM_PES-1:0] i_pe_en,
        input i_index_valid,
        input i_data_valid, // V矩阵也要有个valid信号
        output o_qk_over,
        output o_v_data_request,
        output [ARRAY_HEIGHT*IN_DATA_WIDTH-1:0] o_data_bus,
        output o_data_valid,
        output o_over
    );

    reg [6:0] r_counter;

    /*******************************************************************************
    * cu_status
    * 00:wait 
    * 01:Q*transpose(K)=S 
    * 10:exp(S) 
    * 11:S*V & accumulate exp(S) & ruduce S*V
    *******************************************************************************/
    localparam WAIT = 3'b000;
    localparam Q_K = 3'b001;
    localparam EXP = 3'b010;
    localparam S_V_AND_REDUCE = 3'b011;

    reg [2:0] r_cu_status;

    wire w_accu_en;
    wire w_qk_part_last;
    wire w_mult_en;
    wire w_sv_part_last;
    reg r_mult_clear;
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_counter <= 7'b0;
        end
        else if(w_qk_part_last || w_sv_part_last) begin
            r_counter <= 7'b000_0000;
        end
        else if(r_cu_status == Q_K || r_cu_status == S_V_AND_REDUCE) begin
            r_counter <= r_counter + 1;
        end

    end

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_cu_status <= WAIT;
        end
        else if(r_cu_status == WAIT & i_data_valid & i_index_valid) begin
            r_cu_status <= Q_K;
        end
        else if(r_cu_status == Q_K & w_qk_part_last) begin
            r_cu_status <= EXP;
        end
        else if(r_cu_status == EXP & w_exp_valid) begin // 还需要加上V矩阵数据有效信号
            r_cu_status <= S_V_AND_REDUCE;
        end
        else if(r_cu_status == S_V_AND_REDUCE & w_sv_part_last & i_data_valid & i_index_valid) begin
            r_cu_status <= Q_K;
        end
        else if(r_cu_status == S_V_AND_REDUCE & w_sv_part_last & (~i_data_valid | ~i_index_valid)) begin
            r_cu_status <= WAIT;
        end
        else begin
            r_cu_status <= r_cu_status;
        end
    end

    assign w_accu_en = r_cu_status == Q_K ? 1'b1 : 1'b0;
    assign w_qk_part_last = r_cu_status == Q_K & r_counter == 7'b100_0000 ? 1'b1 : 1'b0;
    assign w_mult_en = r_cu_status == S_V_AND_REDUCE ? 1'b1 : 1'b0;
    assign w_sv_part_last = r_cu_status == S_V_AND_REDUCE & r_counter == 7'b100_0000 ? 1'b1 : 1'b0;
    assign w_mult_clear = r_cu_status == S_V_AND_REDUCE & w_sv_part_last == 1'b1 ? 1'b1 : 1'b0;
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_mult_clear <= 1'b0;
        end
        else begin
            r_mult_clear <= r_cu_status == S_V_AND_REDUCE & w_sv_part_last == 1'b1;
        end
    end

    wire [NUM_PES*IN_DATA_WIDTH-1:0] w_q_dist_bus;
    wire [NUM_PES*IN_DATA_WIDTH-1:0] w_kv_dist_bus;

    crossbar #(
                 .NUM_PES(NUM_PES),
                 .IN_DATA_WIDTH(IN_DATA_WIDTH),
                 .INDEX_WIDTH(LOG2_HEIGHT)
             ) U_crossbar_q(
                 .clk(clk),
                 .rst_n(rst_n),
                 .i_data_bus(i_q_data_bus),
                 .i_index_bus(i_q_index_bus),
                 .o_data_bus(w_q_dist_bus)
             );

    crossbar #(
                 .NUM_PES(NUM_PES),
                 .IN_DATA_WIDTH(IN_DATA_WIDTH),
                 .INDEX_WIDTH(LOG2_PES)
             ) U_crossbar_kv(
                 .clk(clk),
                 .rst_n(rst_n),
                 .i_data_bus(i_kv_data_bus),
                 .i_index_bus(i_kv_index_bus),
                 .o_data_bus(w_kv_dist_bus)
             );
    // outports wire
    wire                                w_exp_valid;
    wire [NUM_PES*OUT_DATA_WIDTH-1:0] 	w_pe_result;

    pe_array #(
                 .NUM_PES(NUM_PES),
                 .IN_DATA_WIDTH(IN_DATA_WIDTH),
                 .OUT_DATA_WIDTH(OUT_DATA_WIDTH)
             ) U_pe_array(
                 .clk          	(clk         ),
                 .rst_n        	(rst_n       ),
                 .i_q_data     	(w_q_dist_bus    ),
                 .i_kv_data     (w_kv_dist_bus    ),
                 .i_pe_en      	(i_pe_en     ),
                 .i_accu_en    	(w_accu_en   ),
                 .i_part_last  	(w_qk_part_last ),
                 .i_mult_en    	(w_mult_en   ),
                 .i_mult_clear 	(r_mult_clear),
                 .o_exp_valid  	(w_exp_valid ),
                 .o_result     	(w_pe_result    )
             );

    // reg r_reduce_valid;
    // always @(posedge clk or negedge rst_n) begin
    //     if(rst_n == 1'b0) begin
    //         r_reduce_valid <= 1'b0;
    //     end
    //     else begin
    //         r_reduce_valid <= w_mult_en;
    //     end
    // end
    wire w_reduction_en;
    assign w_reduction_en = r_cu_status == EXP | (r_cu_status == S_V_AND_REDUCE & r_counter < 63);

    // outports wire
    wire [(NUM_PES-1)-1:0]      	w_reduction_add;
    wire [3*(NUM_PES-1)-1:0]    	w_reduction_cmd;
    wire [19:0]                 	w_reduction_sel;
    wire                        	w_reduction_valid;

    fan_ctrl #(
        .DATA_WIDTH(OUT_DATA_WIDTH),
	    .NUM_PES(NUM_PES),
	    .LOG2_PES(LOG2_HEIGHT)
    ) u_fan_ctrl(
                 .clk               	( clk                ),
                 .rst_n             	( rst_n              ),
                 .i_vn              	( i_q_index_bus      ),
                 .i_data_valid      	( w_reduction_en     ), // TODO:提前启动得到fan的配置，如果V矩阵不能按时传入则这里还需要修改
                 .o_reduction_add   	( w_reduction_add    ),
                 .o_reduction_cmd   	( w_reduction_cmd    ),
                 .o_reduction_sel   	( w_reduction_sel    ),
                 .o_reduction_valid 	( w_reduction_valid  )
             );

    // outports wire
    wire                        	w_fan_valid;
    wire [NUM_PES-1:0]            	w_fan_valid_bus;
    wire [NUM_PES*OUT_DATA_WIDTH-1:0] 	w_fan_data_bus;

    fan_network u_fan_network(
                    .clk          	( clk           ),
                    .rst_n        	( rst_n         ),
                    .i_valid      	( w_reduction_valid       ),
                    .i_data_bus   	( w_pe_result    ),
                    .i_add_en_bus 	( w_reduction_add  ),
                    .i_cmd_bus    	( w_reduction_cmd     ),
                    .i_sel_bus    	( w_reduction_sel     ),
                    .o_valid        ( w_fan_valid),
                    .o_valid_bus    ( w_fan_valid_bus       ),
                    .o_data_bus   	( w_fan_data_bus    )
                );

    wire [NUM_PES*IN_DATA_WIDTH-1:0] 	w_reorder_data_bus;
    genvar i;
    generate
        for(i = 0; i < NUM_PES; i = i+1) begin
            assign w_reorder_data_bus[i*IN_DATA_WIDTH+:IN_DATA_WIDTH] = w_fan_data_bus[i*OUT_DATA_WIDTH+25 : i*OUT_DATA_WIDTH+10];
        end
    endgenerate
    // outports wire
    wire [NUM_PES*IN_DATA_WIDTH-1:0]  	w_reorder_data;

    fan_reorder #(
        .DATA_WIDTH(IN_DATA_WIDTH),
        .NUM_PES(NUM_PES),
        .LOG2_PES(LOG2_PES),
        .LOG2_HEIGHT(LOG2_HEIGHT)
    ) u_fan_reorder(
                    .clk     	( clk      ),
                    .rst_n   	( rst_n    ),
                    .i_data  	( w_reorder_data_bus   ),
                    .i_valid 	( w_fan_valid_bus  ),
                    .i_index 	( i_q_index_bus  ),
                    .o_data  	( w_reorder_data   )
                );
    // wire [NUM_PES*OUT_DATA_WIDTH-1:0] w_s_sum;

    // loop_reduction #(
    //                    .ADDER_DATA_WIDTH(OUT_DATA_WIDTH),
    //                    .INDEX_WIDTH(INDEX_WIDTH),
    //                    .NUM_PES(NUM_PES),
    //                    .LOG2_PES(LOG2_PES)
    //                ) U_loop_reduction(
    //                    .clk(clk),
    //                    .rst_n(rst_n),
    //                    .i_part_last((r_cu_status == Q_K) & w_qk_part_last),
    //                    .i_q_index_bus(i_q_index_bus),
    //                    .i_data_bus(w_pe_result),
    //                    .o_data_bus(w_s_sum)
    //                );

    reg r_reorder_valid;
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            r_reorder_valid <= 1'b0;
        end
        else begin
            r_reorder_valid <= w_fan_valid;
        end
    end

    assign o_qk_over = w_qk_part_last;
    assign o_v_data_request = r_cu_status == S_V_AND_REDUCE & r_counter == 7'b011_1111 ? 1'b1 : 1'b0;
    assign o_data_bus = w_reorder_data[ARRAY_HEIGHT*IN_DATA_WIDTH-1:0];
    assign o_data_valid = r_reorder_valid;
    assign o_over = w_sv_part_last;

endmodule
