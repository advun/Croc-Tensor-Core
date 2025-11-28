`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2025 01:30:12 AM
// Design Name: 
// Module Name: state_machine
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


module state_machine import matrix_pkg::indata_size;(
    input wire [31:0] inA,
    input wire [31:0] inB,
    input wire reset,
    input wire clk,
    output wire push11,
    output wire pushedge,
    output wire push22,
    output wire signed [7:0] a1X, 
    output wire signed [7:0] a2X,
    output wire signed [7:0] bX1,
    output wire signed [7:0] bX2
    );

    
    reg [7:0] hold1a1X;
    reg [7:0] hold1a2X;
    reg [7:0] hold1bX1;
    reg [7:0] hold1bX2;




    
    
endmodule
