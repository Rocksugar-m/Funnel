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
    
    reg clk;
    reg rst_n;
    reg [511:0] dina;
    reg [511:0] dinb;
    wire [11:0] addra;
    wire [11:0] addrb;
    
    wire [11:0] addrc;
    wire [511:0] doutc;

    reg [511:0] mem [0:4096-1];
    
    initial begin
        clk <=0;
        rst_n <= 0;
        dina <= 0;
        dinb <= 0;
        
        #(clkp+25);
        rst_n <= 1;
//        $readmemh("./DATA.HEX", mem);
        $readmemb("./data_cloth_b.txt", mem);

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