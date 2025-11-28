`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2025 01:04:33 AM
// Design Name: 
// Module Name: matrix_multiplier_core
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


module matrix_multiplier_core import matrix_pkg::indata_size;(
    input reg [31:0] inA,
    input reg [31:0] inB,
    input wire reset_n,
    input wire clk,
    output reg signed [4*indata_size-1:0] z11,
    output reg signed [4*indata_size-1:0] z12,
    output reg signed [4*indata_size-1:0] z21,
    output reg signed [4*indata_size-1:0] z22
    );
    
    
    wire reset = ~reset_n;
    
    wire [3:0] out; //determines when to save output of systolic to module output
    
    wire [7:0] a1X, a2X, bX1, bX2; //inputs of systolic array
    
    wire [31:0] c11, c12, c21, c22; //outputs of systolic array
    
    wire push11, pushedge, push22; // determines when to wipe a systolic array so you can add in new
    
    state_machine s0(
    .inA(inA),
    .inB(inB),
    .clk(clk),
    .reset(reset),
    .push11(push11),
    .pushedge(pushedge),
    .push22(push22),
    .a1X(a1X), 
    .a2X(a2X),
    .bX1(bX1),
    .bX2(bX2)
    );
    
    
    
    
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
    
    always_ff @(posedge clk) begin
        if (reset) begin
            z11 <= '0;
            z12 <= '0;
            z21 <= '0;
            z22 <= '0;
        end else begin
            if (out[0]) z11 <= c11;
            if (out[1]) z12 <= c12;
            if (out[2]) z21 <= c21;
            if (out[3]) z22 <= c22;
        end
   end
        
endmodule
