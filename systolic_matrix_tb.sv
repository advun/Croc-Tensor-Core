`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2025 05:12:13 PM
// Design Name: 
// Module Name: systolic_matrix_tb
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


module systolic_matrix_tb(

    );
    
    reg clk, reset, push11, pushedge, push22;
    reg signed [7:0] a1X, a2X, bX1, bX2;
    wire signed [31:0] c11, c12, c21, c22; //outputs of systolic array
    
    systolic_matrix s1(
    .clk(clk),
    .reset(reset),
    .push11(push11),
    .pushedge(pushedge),
    .push22(push22),
    .a1X(a1X), 
    .a2X(a2X),
    .bX1(bX1),
    .bX2(bX2),
    .c11(c11),
    .c12(c12),
    .c21(c21),
    .c22(c22)
    );
    
    initial clk = 0;
    always #25 clk = ~clk; // 50 nsec clock = 20Mhz
    
    initial begin
    reset = 1;
    push11 = 0;
    pushedge = 0;
    push22 = 0;
    #50;
    reset = 0;
    a1X = -6;
    a2X = 0;
    bX1 = -2;
    bX2 = 0;
    #50;
    
    a1X = 7;
    a2X = 1;
    bX1 = 9;
    bX2 = 0;
    #50;
    
    a1X = 0;
    a2X = -4;
    bX1 = 0;
    bX2 = 1;
    #50;
    
    a1X = 0;
    a2X = 0;
    bX1 = 0;
    bX2 = 0;
    #50;
    
    $finish;
    
    
    end
endmodule
