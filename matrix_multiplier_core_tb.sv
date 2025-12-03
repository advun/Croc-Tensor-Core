//author:advun
module matrix_multiplier_core_tb();
    
    // Parameterizable matrix size
    localparam SIZER = 4;  // Can be changed to any size
    localparam NUM_BLOCKS = (SIZER/2) * (SIZER/2);
    localparam BLOCK_DIM = SIZER/2;  // Number of 2x2 blocks per dimension
    
    reg [31:0] inA, inB;
    reg [16:0] size;
    reg reset_n, clk, start;
    
    wire valid, c11ready, c12ready, c21ready, c22ready;
    wire signed [31:0] C11, C12, C21, C22;
    
    matrix_multiplier_core dut(.*);
    
    initial clk = 1;
    always #25 clk = ~clk;
    
    // Dynamic arrays for any matrix size
    reg signed [31:0] A [];
    reg signed [31:0] B [];
    reg signed [31:0] expected_results [];
    
    int blocks_checked = 0;
    int blocks_passed = 0;
    int output_queue_i[$], output_queue_j[$];
    
    // Timing tracking
    time start_time = 0;
    time first_output_time = 0;
    time last_output_time = 0;
    int cycle_count = 0;
    
    // Helper functions to access matrices as 2D arrays
    function int get_index(int i, int j, int dim);
        return i * dim + j;
    endfunction
    
    function int get_result_index(int i, int j, int elem);
        // Each block has 4 elements (C11, C12, C21, C22)
        return (i * BLOCK_DIM + j) * 4 + elem;
    endfunction
    
    // Track start time
    always @(posedge start) begin
        start_time = $time;
        cycle_count = 0;
    end
    
    // Count cycles after start
    always @(posedge clk) begin
        if (start_time > 0 && last_output_time == 0)
            cycle_count++;
    end
    
    // Monitor and compare outputs
    always @(posedge clk) begin
        if (c22ready && output_queue_i.size() > 0) begin
            automatic int i = output_queue_i.pop_front();
            automatic int j = output_queue_j.pop_front();
            automatic int idx = get_result_index(i, j, 0);
            automatic bit pass = (C11 == expected_results[idx + 0] && 
                                  C12 == expected_results[idx + 1] && 
                                  C21 == expected_results[idx + 2] && 
                                  C22 == expected_results[idx + 3]);
            
            // Track timing
            if (blocks_checked == 0)
                first_output_time = $time;
            last_output_time = $time;
            
            blocks_checked++;
            if (pass) blocks_passed++;
            
            $display("\n========================================");
            $display("BLOCK C[%0d][%0d]: %s (Time: %0t ns, Cycles: %0d)", 
                     i, j, pass ? "PASS" : "FAIL", 
                     $time - start_time, (($time - start_time) / 50));
            $display("Expected: [%8d %8d; %8d %8d]", 
                     $signed(expected_results[idx + 0]), $signed(expected_results[idx + 1]),
                     $signed(expected_results[idx + 2]), $signed(expected_results[idx + 3]));
            $display("Hardware: [%8d %8d; %8d %8d]", 
                     $signed(C11), $signed(C12), $signed(C21), $signed(C22));
            $display("========================================");
        end
    end
    
    // Compute expected result for one block
    function void compute_expected_block(int out_i, int out_j);
        logic signed [7:0] a11, a12, a21, a22, b11, b12, b21, b22;
        logic signed [31:0] acc11, acc12, acc21, acc22;
        int a_idx, b_idx, result_idx;
        
        // Initialize accumulators to zero
        acc11 = 0;
        acc12 = 0;
        acc21 = 0;
        acc22 = 0;
        
        // Multiply across all k blocks
        for (int k = 0; k < BLOCK_DIM; k++) begin
            a_idx = get_index(out_i, k, BLOCK_DIM);
            b_idx = get_index(k, out_j, BLOCK_DIM);
            
            {a11, a12, a21, a22} = A[a_idx];
            {b11, b12, b21, b22} = B[b_idx];
            
            acc11 += (a11 * b11) + (a12 * b21);
            acc12 += (a11 * b12) + (a12 * b22);
            acc21 += (a21 * b11) + (a22 * b21);
            acc22 += (a21 * b12) + (a22 * b22);
        end
        
        // Store results
        result_idx = get_result_index(out_i, out_j, 0);
        expected_results[result_idx + 0] = acc11;
        expected_results[result_idx + 1] = acc12;
        expected_results[result_idx + 2] = acc21;
        expected_results[result_idx + 3] = acc22;
    endfunction
    
    initial begin
        // Allocate dynamic arrays
        A = new[NUM_BLOCKS];
        B = new[NUM_BLOCKS];
        expected_results = new[NUM_BLOCKS * 4];  // 4 elements per block
        
        // Initialize matrices with random values
        for (int i = 0; i < NUM_BLOCKS; i++) begin
            A[i] = $random;
            B[i] = $random;
        end
        
        // Initialize control signals
        reset_n = 0;
        inA = 0;
        inB = 0;
        size = SIZER;
        start = 0;
        
        $display("=========================================");
        $display("Matrix Multiplier Core Testbench");
        $display("SIZER = %0d, Block Dimension = %0dx%0d, Total Blocks = %0d\n", 
                 SIZER, BLOCK_DIM, BLOCK_DIM, NUM_BLOCKS);
        
        // Display all input blocks
        $display("Input Blocks:");
        for (int i = 0; i < BLOCK_DIM; i++) begin
            for (int j = 0; j < BLOCK_DIM; j++) begin
                automatic int idx = get_index(i, j, BLOCK_DIM);
                $display("A[%0d][%0d] = [%4d %4d; %4d %4d]  B[%0d][%0d] = [%4d %4d; %4d %4d]", 
                         i, j, $signed(A[idx][31:24]), $signed(A[idx][23:16]),
                         $signed(A[idx][15:8]), $signed(A[idx][7:0]),
                         i, j, $signed(B[idx][31:24]), $signed(B[idx][23:16]),
                         $signed(B[idx][15:8]), $signed(B[idx][7:0]));
            end
        end
        $display("");
        
        // Pre-compute expected results
        for (int i = 0; i < BLOCK_DIM; i++)
            for (int j = 0; j < BLOCK_DIM; j++)
                compute_expected_block(i, j);
        
        // Run test
        #50 reset_n = 1;
        #50 start = 1;
        #50 start = 0;
        
        // Stream inputs for all block multiplications
        for (int i = 0; i < BLOCK_DIM; i++) begin
            for (int j = 0; j < BLOCK_DIM; j++) begin
                output_queue_i.push_back(i);
                output_queue_j.push_back(j);
                
                // Stream the row of A and column of B
                for (int k = 0; k < BLOCK_DIM; k++) begin
                    inA = A[get_index(i, k, BLOCK_DIM)]; #50;
                    inB = B[get_index(k, j, BLOCK_DIM)]; #50;
                end
            end
        end
        
        // Wait for completion with timeout scaled to matrix size
        wait(blocks_checked == NUM_BLOCKS || $time > (50000 + NUM_BLOCKS * 1000));
        #500;
        
        // Summary
        $display("\n=========================================");
        $display("TEST SUMMARY");
        $display("=========================================");
        $display("Matrix Size: %0dx%0d (%0dx%0d blocks)", SIZER, SIZER, BLOCK_DIM, BLOCK_DIM);
        $display("Checked: %0d/%0d | Passed: %0d | Failed: %0d", 
                 blocks_checked, NUM_BLOCKS, blocks_passed, NUM_BLOCKS - blocks_passed);
        $display("Valid: %b | Queue remaining: %0d", valid, output_queue_i.size());
        $display("");
        
        if (first_output_time > 0) begin
            $display("TIMING ANALYSIS:");
            $display("  Start time: %0t ns", start_time);
            $display("  First output: %0t ns (latency: %0t ns, %0d cycles)", 
                     first_output_time, first_output_time - start_time, 
                     (first_output_time - start_time) / 50);
            $display("  Last output: %0t ns (total time: %0t ns, %0d cycles)", 
                     last_output_time, last_output_time - start_time,
                     (last_output_time - start_time) / 50);
            $display("  Throughput: %0.2f blocks/cycle", 
                     real'(NUM_BLOCKS) / real'((last_output_time - start_time) / 50));
            $display("");
        end
        
        if (blocks_passed == NUM_BLOCKS) begin
            $display("ALL TESTS PASSED! :^)");
            end
        else if (output_queue_i.size() > 0)
            $display("INCOMPLETE - Some outputs never appeared!");
        else
            $display("TESTS FAILED!");
        $display("=========================================");
        
        $finish;
    end
    
endmodule
