`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025 10:00:19 PM
// Design Name: 
// Module Name: state_machine_tb_one
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

module state_machine_tb_one(

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
    wire valid;
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
    .valid(valid),
    .a1X(a1X), 
    .a2X(a2X),
    .bX1(bX1),
    .bX2(bX2)
    );
    
    reg signed [31:0] A [((SIZER/2)-1):0][((SIZER/2)-1):0]; //[i] = row [j] = column
    reg signed [31:0] B [((SIZER/2)-1):0][((SIZER/2)-1):0];
    
    // Counters to track behavior
    int push11_count = 0;
    int pushedge_count = 0;
    int push22_count = 0;
    int cycle_count = 0;
    
    initial clk = 1;
    always #25 clk = ~clk; // 50 nsec clock = 20Mhz

initial begin
    $display("=========================================");
    $display("Matrix Multiplication State Machine Test");
    $display("=========================================");
    $display("SIZER = %0d, Total 2x2 blocks = %0d", SIZER, (SIZER/2)*(SIZER/2));
    $display("");
    
    reset <= 1;
    inA <= 0;
    inB <= 0;
    size <= SIZER;
    start <= 0;
    
    // Initialize matrices
    A[0][0] <= 32'haabbccdd;
    A[1][0] <= 32'hbacadaee;
    A[0][1] <= 32'hafbdcada;
    A[1][1] <= 32'hbecedeed;
    
    B[0][0] <= 32'hfaeadaca;
    B[1][0] <= 32'hebdbcbba;
    B[0][1] <= 32'hffeeddcc;
    B[1][1] <= 32'heeddccbb;
    
    // Display input matrices
    $display("Input Matrix A:");
    for (int j = 0; j < (SIZER/2); j++) begin
        for (int i = 0; i < (SIZER/2); i++) begin
            $display("  A[%0d][%0d] = %h", i, j, A[i][j]);
        end
    end
    $display("");
    
    $display("Input Matrix B:");
    for (int j = 0; j < (SIZER/2); j++) begin
        for (int i = 0; i < (SIZER/2); i++) begin
            $display("  B[%0d][%0d] = %h", i, j, B[i][j]);
        end
    end
    $display("");
    
    #50;
    reset <= 0;
    $display("@%0t ns (cycle %0d): Reset deasserted", $time, cycle_count);
    
    start <= 1;
    #50;
    start <= 0;
    $display("@%0t ns (cycle %0d): Start pulsed, beginning operation", $time, cycle_count);
    $display("");
    
    // Stream in matrices with monitoring
    $display("--- Beginning Data Streaming ---");
    for (int j = 0; j < (SIZER/2); j++) begin
        for (int i = 0; i < (SIZER/2); i++) begin
            inA <= A[i][j];
            $display("@%0t ns (cycle %0d): Streaming A[%0d][%0d] = %h", $time, cycle_count, i, j, A[i][j]);
            #50;
            inB <= B[j][i];
            $display("@%0t ns (cycle %0d): Streaming B[%0d][%0d] = %h", $time, cycle_count, j, i, B[j][i]);
            #50;
        end
    end
    $display("--- Data Streaming Complete ---");
    $display("");
    
    #1000;
    
    $display("=========================================");
    $display("Final Statistics:");
    $display("  Total cycles: %0d", cycle_count);
    $display("  PUSH11 count: %0d (expected: %0d)", push11_count, (SIZER/2)*(SIZER/2));
    $display("  PUSHEDGE count: %0d (expected: %0d)", pushedge_count, (SIZER/2)*(SIZER/2));
    $display("  PUSH22 count: %0d (expected: %0d)", push22_count, (SIZER/2)*(SIZER/2));
    $display("  Valid signal: %b", valid);
    if (valid)
        $display("  STATUS: PASSED - Operation completed successfully");
    else
        $display("  STATUS: FAILED - Valid signal not asserted");
    $display("=========================================");
    
    $finish;
end

// Count cycles
always @(posedge clk) begin
    if (!reset)
        cycle_count <= cycle_count + 1;
end

// Monitor push signals and output values
always @(posedge clk) begin
    if (push11) begin
        push11_count <= push11_count + 1;
        $display("@%0t ns (cycle %0d): PUSH11 #%0d | a1X=%h (%d), bX1=%h (%d)", 
                 $time, cycle_count, push11_count, a1X, $signed(a1X), bX1, $signed(bX1));
    end
    
    if (pushedge) begin
        pushedge_count <= pushedge_count + 1;
        $display("@%0t ns (cycle %0d): PUSHEDGE #%0d | a1X=%h, bX2=%h | a2X=%h, bX1=%h", 
                 $time, cycle_count, pushedge_count, a1X, bX2, a2X, bX1);
    end
    
    if (push22) begin
        push22_count <= push22_count + 1;
        $display("@%0t ns (cycle %0d): PUSH22 #%0d | a2X=%h (%d), bX2=%h (%d)", 
                 $time, cycle_count, push22_count, a2X, $signed(a2X), bX2, $signed(bX2));
    end
    
    if (valid) begin
        $display("@%0t ns (cycle %0d): VALID asserted - Operation complete!", $time, cycle_count);
    end
end

// Track when outputs change (useful for debugging shift register timing)
always @(posedge clk) begin
    if (!reset && !push11 && !pushedge && !push22) begin
        // Only display during non-push cycles if values change
        static logic [7:0] last_a1X, last_a2X, last_bX1, last_bX2;
        if (a1X !== last_a1X || a2X !== last_a2X || bX1 !== last_bX1 || bX2 !== last_bX2) begin
            $display("@%0t ns (cycle %0d): Output change | a1X=%h, a2X=%h, bX1=%h, bX2=%h", 
                     $time, cycle_count, a1X, a2X, bX1, bX2);
        end
        last_a1X = a1X;
        last_a2X = a2X;
        last_bX1 = bX1;
        last_bX2 = bX2;
    end
end

// Error detection based on observable signals
always @(posedge clk) begin
    // Check for unexpected push signal combinations
    if ((push11 && pushedge) || (push11 && push22) || (pushedge && push22)) begin
        $display("ERROR @%0t: Multiple push signals active simultaneously!", $time);
    end
    
    // Check if we get expected number of push sequences
    if (valid && push11_count != (SIZER/2)*(SIZER/2)) begin
        $display("ERROR @%0t: Valid asserted but push11_count=%0d, expected=%0d", 
                 $time, push11_count, (SIZER/2)*(SIZER/2));
    end
end

endmodule