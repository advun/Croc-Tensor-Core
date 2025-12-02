`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025 06:20:15 PM
// Design Name: 
// Module Name: SYSalttb
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


module SYSalttb(

    );
    //++++++++++++++++++++++++++++++++++++
    //USED FOR TESTING PUSHES, NOT WORKING RN BECAUSE I MOVED REGS FROM SYSTOLIC_MATRIX TO MATRIX_MULTIPLIER_CORE
    //++++++++++++++++++++++++++++++++++++

    
    
    reg clk, reset, push11, pushedge, push22;
    reg signed [7:0] a1X, a2X, bX1, bX2;
    wire signed [31:0] Oc11, Oc12, Oc21, Oc22; //outputs of systolic array
    
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
    .Oc11(Oc11),
    .Oc12(Oc12),
    .Oc21(Oc21),
    .Oc22(Oc22)
    );
    
    initial clk = 1;
    always #25 clk = ~clk; // 50 nsec clock = 20Mhz
    
    initial begin
    reset <= 1;
    push11 <= 0;
    pushedge <= 0;
    push22 <= 0;
    
    #50;
    reset <= 0;
    a1X <= -6;
    a2X <= 0;
    bX1 <= -2;
    bX2 <= 0;
    
    #50; 
    a1X <= 7;
    a2X <= 1;
    bX1 <= 9;
    bX2 <= 0;
    
    #50; //new matrix
    a1X <= 4;
    a2X <= -4;
    bX1 <= 1;
    bX2 <= 1;
    
    //push11 <= 1;
    
    #50;
    a1X <= 8;
    a2X <= 2;
    bX1 <= 5;
    bX2 <= 2;
    
    //push11 <= 0;
    //pushedge <= 1;
    
    #50;
    a1X <= 0;
    a2X <= -7;
    bX1 <= 0;
    bX2 <= -12;
    
    //pushedge <= 0;
    //push22 <= 1;
    
    push11 <= 1;
    
    #50;
    a1X <= 0;
    a2X <= 0;
    bX1 <= 0;
    bX2 <= 0;
    
    //push22 <= 0;
    
    push11 <= 0;
    pushedge <= 1;
    
    #50;
    a1X <= 0;
    a2X <= 0;
    bX1 <= 0;
    bX2 <= 0;
    
    pushedge <= 0;
    push22 <= 1;
    
    #50;
    a1X <= 0;
    a2X <= 0;
    bX1 <= 0;
    bX2 <= 0;
    push22 <= 0;
    
    #50;
    $finish;
    
    
    end
endmodule
