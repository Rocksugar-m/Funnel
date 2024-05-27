`timescale 0.1ns / 0.1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 
// Design Name:
// Module Name: 
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

module attention_top_tb();

    localparam clkp = 50;
    real start_time;
    real total_time;
    real workload = 512 * 512 * 64 * 2 * 2; // OPS
    real theoretical_throughput = 32 * 2 * 0.2 * 8; // GOP/s, 
    real theoretical_time = (512 * 512 * 64 * 2 * 2) / (32 * 2 * 0.2 * 8); // ns

    reg clk;
    reg rst_n;
    reg [511:0] dina;
    reg [511:0] dinb;
    wire [11:0] addra;
    wire [11:0] addrb;
    
    wire [11:0] addrc;
    wire [255:0] doutc;

    reg [511:0] mem [0:4096-1];
    
    initial begin
        start_time = $realtime * 0.1;

        clk <= 0;
        rst_n <= 0;
        dina <= 0;
        dinb <= 0;
        $readmemb("../../../../data.txt", mem);

        #(clkp+25);
        rst_n <= 1;

    end

    always #(clkp/2) clk = ~clk;

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            dina <= 'b0;
            dinb <= 'b0;
        end
        else begin
            dina <= mem[addra];
            dinb <= mem[addrb];
        end
    end

    reg [5:0] count;
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            count <= 0;
        end
        else if(U_attention_top.U_attention_acc.r_last_block & ~U_attention_top.U_attention_acc.w_last_block & ~U_attention_top.U_attention_acc.r_data_valid) begin
            count <= count + 1;
        end
    end

    always @(*) begin
        if(count == 32) begin
            total_time = $realtime * 0.1 - start_time;
            $display("Simulation Time: %f ns", total_time);
            $display("Throughput: %f GOP/s", (workload / total_time) * 4);
            $display("Hardware Efficiency: %f %%", (theoretical_time / total_time) * 100);
            $finish;
        end
    end
    
    attention_top U_attention_top(
        .clk(clk),
        .rst_n(rst_n),
        .dina(dina),
        .dinb(dinb),
        .addra(addra),
        .addrb(addrb),
        .addrc(addrc),
        .doutc(doutc)
    );

endmodule
