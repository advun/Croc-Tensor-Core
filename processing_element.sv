//author:advun
module processing_element(
    input wire clk,
    input wire reset,
    input wire push,
    input wire start,
    input wire enable,
    input wire signed [7:0] in_a, 
    input wire signed [7:0] in_b,
    output reg signed [31:0] out_c,
    output reg signed [7:0] out_a, 
    output reg signed [7:0] out_b
    ); 
    
    always_ff @ (posedge clk) begin
        if (reset|start) begin
        out_a <= '0;
        out_b <= '0;
        out_c <= '0;
        end
        else if (enable) begin
        out_c <= (push ? 0 : out_c) + in_a*in_b;
        out_a <= in_a;
        out_b <= in_b;
        end
    end
   
endmodule

module processing_element_rightedge(
    input wire clk,
    input wire reset,
    input wire push,
    input wire start,
    input wire enable,
    input wire signed [7:0] in_a, 
    input wire signed [7:0] in_b,
    output reg signed [31:0] out_c,
    output reg signed [7:0] out_b
    ); 
    
    always_ff @ (posedge clk) begin
        if (reset|start) begin
        out_b <= '0;
        out_c <= '0;
        end
        else if (enable) begin
        out_c <= (push ? 0 : out_c) + in_a*in_b;
        out_b <= in_b;
        end
    end
   
endmodule


module processing_element_bottomedge(
    input wire clk,
    input wire reset,
    input wire push,
    input wire start,
    input wire enable,
    input wire signed [7:0] in_a, 
    input wire signed [7:0] in_b,
    output reg signed [31:0] out_c,
    output reg signed [7:0] out_a 
    ); 
    
    always_ff @ (posedge clk) begin
        if (reset|start) begin
        out_a <= '0;
        out_c <= '0;
        end
        else if (enable) begin
        out_c <= (push ? 0 : out_c) + in_a*in_b;
        out_a <= in_a;
        end
    end
   
endmodule


module processing_element_rightbottomcorner (
    input wire clk,
    input wire reset,
    input wire push,
    input wire start,
    input wire enable,
    input wire signed [7:0] in_a, 
    input wire signed [7:0] in_b,
    output reg signed [31:0] out_c
    ); 
    
    always_ff @ (posedge clk) begin
        if (reset|start) begin
        out_c <= '0;
        end
        else if (enable) begin
        out_c <= (push ? 0 : out_c) + in_a*in_b;
        end
    end
   
endmodule
