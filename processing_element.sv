`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2025 11:23:58 PM
// Design Name: 
// Module Name: processing_element
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


module processing_element import matrix_pkg::indata_size; (
    input wire clk,
    input wire reset,
    input wire push,
    input wire signed [indata_size-1:0] in_a, 
    input wire signed [indata_size-1:0] in_b,
    output reg signed [4*indata_size-1:0] out_c,
    output reg signed [indata_size-1:0] out_a, 
    output reg signed [indata_size-1:0] out_b
    ); 
    
    always_ff @ (posedge clk) begin
        if (reset) begin
        out_a <= '0;
        out_b <= '0;
        out_c <= '0;
        end
        else begin
        out_c <= (push ? 0 : out_c) + in_a*in_b;
        out_a <= in_a;
        out_b <= in_b;
        end
    end
   
endmodule

module processing_element_rightedge import matrix_pkg::indata_size; (
    input wire clk,
    input wire reset,
    input wire push,
    input wire signed [indata_size-1:0] in_a, 
    input wire signed [indata_size-1:0] in_b,
    output reg signed [4*indata_size-1:0] out_c,
    output reg signed [indata_size-1:0] out_b
    ); 
    
    always_ff @ (posedge clk) begin
        if (reset) begin
        out_b <= '0;
        out_c <= '0;
        end
        else begin
        out_c <= (push ? 0 : out_c) + in_a*in_b;
        out_b <= in_b;
        end
    end
   
endmodule


module processing_element_bottomedge import matrix_pkg::indata_size; (
    input wire clk,
    input wire reset,
    input wire push,
    input wire signed [indata_size-1:0] in_a, 
    input wire signed [indata_size-1:0] in_b,
    output reg signed [4*indata_size-1:0] out_c,
    output reg signed [indata_size-1:0] out_a 
    ); 
    
    always_ff @ (posedge clk) begin
        if (reset) begin
        out_a <= '0;
        out_c <= '0;
        end
        else begin
        out_c <= (push ? 0 : out_c) + in_a*in_b;
        out_a <= in_a;
        end
    end
   
endmodule


module processing_element_rightbottomcorner import matrix_pkg::indata_size; (
    input wire clk,
    input wire reset,
    input wire push,
    input wire signed [indata_size-1:0] in_a, 
    input wire signed [indata_size-1:0] in_b,
    output reg signed [4*indata_size-1:0] out_c
    ); 
    
    always_ff @ (posedge clk) begin
        if (reset) begin
        out_c <= '0;
        end
        else begin
        out_c <= (push ? 0 : out_c) + in_a*in_b;
        end
    end
   
endmodule
