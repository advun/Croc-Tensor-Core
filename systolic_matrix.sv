`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2025 12:16:34 AM
// Design Name: 
// Module Name: systolic_matrix
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


module systolic_matrix(
    input wire clk,
    input wire reset,
    input wire push11,
    input wire pushedge,
    input wire push22,
    input wire signed [7:0] a1X, 
    input wire signed [7:0] a2X,
    input wire signed [7:0] bX1,
    input wire signed [7:0] bX2,
    output wire signed [31:0] c11,
    output wire signed [31:0] c12,
    output wire signed [31:0] c21,
    output wire signed [31:0] c22
    );
    
    // A * B = C, C = [c11, c12; c21, c22]
    
    wire [7:0] p11_aout, p11_bout, p21_aout, p12_bout;
    
    processing_element p11 (
    .clk(clk),
    .reset(reset),
    .push(push11),
    .in_a(a1X),
    .in_b(bX1),
    .out_c(c11),
    .out_a(p11_aout),
    .out_b(p11_bout)
    );
    
    processing_element_rightedge p12 (
    .clk(clk),
    .reset(reset),
    .push(pushedge),
    .in_a(p11_aout),
    .in_b(bX2),
    .out_c(c12),
    .out_b(p12_bout)
    );
    
    processing_element_bottomedge p21 (
    .clk(clk),
    .reset(reset),
    .push(pushedge),
    .in_a(a2X),
    .in_b(p11_bout),
    .out_c(c21),
    .out_a(p21_aout)
    );
    
    processing_element_rightbottomcorner p22 (
    .clk(clk),
    .reset(reset),
    .push(push22),
    .in_a(p21_aout),
    .in_b(p12_bout),
    .out_c(c22)
    );
    
    
    
endmodule
