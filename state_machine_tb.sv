`timescale 1ns / 1ps



module state_machine_tb(

    );
    
    localparam SIZER = 4; //ONLY EVEN NUMBERS
    
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
    wire valid;
    
    
    state_machine s0(
    .inA(inA),
    .inB(inB),
    .size(size),
    .reset(reset),
    .valid(valid),
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
    
    reg signed [31:0] A [((SIZER/2)-1):0][((SIZER/2)-1):0]; //[i] = row [j] = column
    reg signed [31:0] B [((SIZER/2)-1):0][((SIZER/2)-1):0];
    
    
    
    initial clk = 1;
    always #25 clk = ~clk; // 50 nsec clock = 20Mhz
    
    initial begin
    reset <= 1;
    inA <= 0;
    inB <= 0;
    size <= SIZER;
    start <= 0;
    A[0][0] <= 32'haabbccdd;
    A[1][0] <= 32'hbacadaee;
    A[0][1] <= 32'hafbdcada;
    A[1][1] <= 32'hbecedeed;
    
    B[0][0] <= 32'hfaeadaca;
    B[1][0] <= 32'hebdbcbba;
    B[0][1] <= 32'hffeeddcc;
    B[1][1] <= 32'heeddccbb;
    
    #50;
    reset <= 0;
    start <= 1;
    #50;
    start <= 0;
    
    // Stream in matrixes
    for (int i = 0; i < (SIZER/2); i++) begin      // For each output row block
        for (int j = 0; j < (SIZER/2); j++) begin  // For each output column block
            for (int k = 0; k < (SIZER/2); k++) begin  // For each block in the dot product
                inA <= A[i][k];
                #50;
                inB <= B[k][j];
                #50;
            end
        end
    end
 
    inA <= 0;
    inB <= 0;
    
    #10000;
    $finish;

    end
    
endmodule
