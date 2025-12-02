`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025 07:53:11 PM
// Design Name: 
// Module Name: matrix_multiplier_core_tb
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


module matrix_multiplier_core_tb(

    );
    
    
    reg [31:0] inA;
    reg [31:0] inB;
    reg [16:0] size;
    reg reset_n;
    reg clk;
    reg start;
    
    wire valid;
    wire c11ready;
    wire c12ready;
    wire c21ready;
    wire c22ready;
    wire signed [31:0] C11;
    wire signed [31:0] C12;
    wire signed [31:0] C21;
    wire signed [31:0] C22;
    
    
    matrix_multiplier_core dut(
    .inA(inA),
    .inB(inB),
    .size(size),
    .reset_n(reset_n),
    .clk(clk),
    .start(start),
    .valid(valid),
    .c11ready(c11ready),
    .c12ready(c12ready),
    .c21ready(c21ready),
    .c22ready(c22ready),
    .C11(C11),
    .C12(C12),
    .C21(C21),
    .C22(C22)
    );
    
    
    initial clk = 1;
    always #25 clk = ~clk; // 50 nsec clock = 20Mhz
    
    initial begin
    reset_n <= 0;
    inA <= 0;
    inB <= 0;
    size <= 17'd4;
    start <= 0;
    #50;
    
    end
    
    
endmodule
