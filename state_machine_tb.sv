`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025 08:05:55 PM
// Design Name: 
// Module Name: state_machine_tb
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


module state_machine_tb(

    );
    
    
    reg [31:0] inA;
    reg [31:0] inB;
    reg [16:0] size;
    reg reset;
    reg clk;
    reg start;
    
    wire push11;
    wire pushedge;
    wire push22;
    wire signed [7:0] a1X;
    wire signed [7:0] a2X;
    wire signed [7:0] bX1;
    wire signed [7:0] bX2;
    
    
    state_machine s0(
    .inA(inA),
    .inB(inB),
    .size(size),
    .reset(reset),
    .clk(clk),
    .start(start),
    .push11(push11),
    .pushedge(pushedge),
    .push22(push22),
    .a1X(a1X), 
    .a2X(a2X),
    .bX1(bX1),
    .bX2(bX2)
    );
    
    initial clk = 1;
    always #25 clk = ~clk; // 50 nsec clock = 20Mhz
    
    initial begin
    reset <= 1;
    inA <= 0;
    inB <= 0;
    size <= 17'd4;
    start <= 0;
    #50;
    
    reset <= 0;
    start <= 1;
    
    
    $finish;
    end
    
endmodule
