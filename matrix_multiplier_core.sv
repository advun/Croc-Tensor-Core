module matrix_multiplier_core(
    input reg [31:0] inA,
    input reg [31:0] inB,
    input wire signed [16:0] size,
    input wire reset_n,
    input wire clk,
    input wire start,
    output wire valid,
    output reg c11ready,
    output reg c12ready,
    output reg c21ready,
    output reg c22ready,
    output reg signed [31:0] C11,
    output reg signed [31:0] C12,
    output reg signed [31:0] C21,
    output reg signed [31:0] C22
    );
    
    
    wire reset = ~reset_n;
    
    wire [7:0] a1X, a2X, bX1, bX2; //inputs of systolic array
    
    wire [31:0] c11, c12, c21, c22; //outputs of systolic array
    
    wire push11, pushedge, push22; // determines when to wipe a systolic array so you can add in new
    
    state_machine s0(
    .inA(inA),
    .inB(inB),
    .size(size),
    .reset(reset),
    .clk(clk),
    .valid(valid),
    .start(start),
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
    
   //push logic
    always @(posedge clk) begin
        if (reset) begin
            C11 <= 32'd0;
            C12 <= 32'd0;
            C21 <= 32'd0;
            C22 <= 32'd0;
        end 
        
        else begin
            if (push11) begin
                C11 <= c11;
            end
            
            if (pushedge) begin
                C12 <= c12;
                C21 <= c21;
            end
            
            if (push22) begin
                C22 <= c22;
            end
        end
    end
    
    //save to memory logic
    always @(posedge clk) begin
        if (reset) begin
            c11ready <= 0;
            c12ready <= 0;
            c21ready <= 0;
            c22ready <= 0;
        end 
        else begin //shift ready signal
            c11ready <= push11;
            c12ready <= c11ready;
            c21ready <= c12ready;
            c22ready <= c21ready;
        end
    end
        
endmodule
