//author:advun

module matrix_multiplier_core_tb_multiple();
    
    // Test multiple matrix sizes
    localparam NUM_TESTS = 8;
    localparam int TEST_SIZES [NUM_TESTS] = '{4, 6, 8, 10, 12, 14, 16, 20};
    
    reg [31:0] inA, inB;
    reg [16:0] size;
    reg reset_n, clk, start;
    
    wire valid, c11ready, c12ready, c21ready, c22ready;
    wire signed [31:0] C11, C12, C21, C22;
    
    matrix_multiplier_core dut(.*);
    
    initial clk = 1;
    always #25 clk = ~clk;
    
    // Dynamic arrays for current test
    reg signed [31:0] A [];
    reg signed [31:0] B [];
    reg signed [31:0] expected_results [];
    
    int blocks_checked = 0;
    int blocks_passed = 0;
    int output_queue_i[$], output_queue_j[$];
    
    // Current test parameters
    int SIZER;
    int NUM_BLOCKS;
    int BLOCK_DIM;
    
    // Overall test statistics
    int total_tests_run = 0;
    int total_tests_passed = 0;
    int total_blocks_checked = 0;
    int total_blocks_passed = 0;
    
    // Timing tracking
    time start_time = 0;
    time first_output_time = 0;
    time last_output_time = 0;
    
    // Helper functions to access matrices as 2D arrays
    function int get_index(int i, int j, int dim);
        return i * dim + j;
    endfunction
    
    function int get_result_index(int i, int j, int elem);
        return (i * BLOCK_DIM + j) * 4 + elem;
    endfunction
    
    // Track start time
    always @(posedge start) begin
        start_time = $time;
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
            
            if (!pass) begin
                $display("\n========================================");
                $display("BLOCK C[%0d][%0d]: FAIL (Time: %0t ns)", i, j, $time - start_time);
                $display("Expected: [%8d %8d; %8d %8d]", 
                         $signed(expected_results[idx + 0]), $signed(expected_results[idx + 1]),
                         $signed(expected_results[idx + 2]), $signed(expected_results[idx + 3]));
                $display("Hardware: [%8d %8d; %8d %8d]", 
                         $signed(C11), $signed(C12), $signed(C21), $signed(C22));
                $display("========================================");
            end
        end
    end
    
    // Compute expected result for one block
    function void compute_expected_block(int out_i, int out_j);
        logic signed [7:0] a11, a12, a21, a22, b11, b12, b21, b22;
        logic signed [31:0] acc11, acc12, acc21, acc22;
        int a_idx, b_idx, result_idx;
        
        acc11 = 0;
        acc12 = 0;
        acc21 = 0;
        acc22 = 0;
        
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
        
        result_idx = get_result_index(out_i, out_j, 0);
        expected_results[result_idx + 0] = acc11;
        expected_results[result_idx + 1] = acc12;
        expected_results[result_idx + 2] = acc21;
        expected_results[result_idx + 3] = acc22;
    endfunction
    
    // Task to run one test
    task run_test(int test_size);
        begin
            // Set up test parameters
            SIZER = test_size;
            BLOCK_DIM = SIZER / 2;
            NUM_BLOCKS = BLOCK_DIM * BLOCK_DIM;
            
            // Reset counters
            blocks_checked = 0;
            blocks_passed = 0;
            output_queue_i = {};
            output_queue_j = {};
            start_time = 0;
            first_output_time = 0;
            last_output_time = 0;
            
            // Allocate dynamic arrays
            A = new[NUM_BLOCKS];
            B = new[NUM_BLOCKS];
            expected_results = new[NUM_BLOCKS * 4];
            
            // Generate new random values for this test (mix of positive and negative)
            for (int i = 0; i < NUM_BLOCKS; i++) begin
                A[i] = $random;
                B[i] = $random;
                
                // Optionally force some variety by making random bytes negative
                // This ensures we test with negative numbers
                if ($random % 2) A[i][31:24] = -$signed(A[i][31:24]);
                if ($random % 2) A[i][23:16] = -$signed(A[i][23:16]);
                if ($random % 2) A[i][15:8]  = -$signed(A[i][15:8]);
                if ($random % 2) A[i][7:0]   = -$signed(A[i][7:0]);
                
                if ($random % 2) B[i][31:24] = -$signed(B[i][31:24]);
                if ($random % 2) B[i][23:16] = -$signed(B[i][23:16]);
                if ($random % 2) B[i][15:8]  = -$signed(B[i][15:8]);
                if ($random % 2) B[i][7:0]   = -$signed(B[i][7:0]);
            end
            
            $display("=============================================");
            $display("TEST %0d: Matrix Size %0dx%0d (%0dx%0d blocks)", 
                     total_tests_run + 1, SIZER, SIZER, BLOCK_DIM, BLOCK_DIM);
            $display("=============================================");
            
            // Display all input blocks
            $display("\nInput Blocks:");
            for (int i = 0; i < BLOCK_DIM; i++) begin
                for (int j = 0; j < BLOCK_DIM; j++) begin
                    automatic int idx = get_index(i, j, BLOCK_DIM);
                    automatic logic signed [7:0] a11 = A[idx][31:24];
                    automatic logic signed [7:0] a12 = A[idx][23:16];
                    automatic logic signed [7:0] a21 = A[idx][15:8];
                    automatic logic signed [7:0] a22 = A[idx][7:0];
                    automatic logic signed [7:0] b11 = B[idx][31:24];
                    automatic logic signed [7:0] b12 = B[idx][23:16];
                    automatic logic signed [7:0] b21 = B[idx][15:8];
                    automatic logic signed [7:0] b22 = B[idx][7:0];
                    $display("A[%0d][%0d] = [%4d %4d; %4d %4d]  B[%0d][%0d] = [%4d %4d; %4d %4d]", 
                             i, j, a11, a12, a21, a22,
                             i, j, b11, b12, b21, b22);
                end
            end
            
            // Pre-compute expected results
            for (int i = 0; i < BLOCK_DIM; i++)
                for (int j = 0; j < BLOCK_DIM; j++)
                    compute_expected_block(i, j);
            
            // Reset hardware
            reset_n = 0;
            inA = 0;
            inB = 0;
            size = SIZER;
            start = 0;
            #100;
            
            // Start test
            reset_n = 1;
            #50 start = 1;
            #50 start = 0;
            
            // Stream inputs for all block multiplications
            for (int i = 0; i < BLOCK_DIM; i++) begin
                for (int j = 0; j < BLOCK_DIM; j++) begin
                    output_queue_i.push_back(i);
                    output_queue_j.push_back(j);
                    
                    for (int k = 0; k < BLOCK_DIM; k++) begin
                        inA = A[get_index(i, k, BLOCK_DIM)]; #50;
                        inB = B[get_index(k, j, BLOCK_DIM)]; #50;
                    end
                end
            end
            
            // Wait for completion
            wait(blocks_checked == NUM_BLOCKS || $time > (start_time + 50000 + NUM_BLOCKS * 1000));
            #500;
            
            // Update statistics
            total_tests_run++;
            total_blocks_checked += blocks_checked;
            total_blocks_passed += blocks_passed;
            
            // Test result
            if (blocks_passed == NUM_BLOCKS) begin
                total_tests_passed++;
                $display("\n TEST PASSED: %0d/%0d blocks correct", blocks_passed, NUM_BLOCKS);
            end else begin
                $display("\n TEST FAILED: %0d/%0d blocks correct", blocks_passed, NUM_BLOCKS);
            end
            
            // Timing summary
            if (first_output_time > 0) begin
                $display("\nTiming:");
                $display("  Latency: %0d cycles", (first_output_time - start_time) / 50);
                $display("  Total: %0d cycles", (last_output_time - start_time) / 50);
                $display("  Throughput: %0.2f blocks/cycle", 
                         real'(NUM_BLOCKS) / real'((last_output_time - start_time) / 50));
            end
        end
    endtask
    
    initial begin
        $display("=========================================");
        $display("Multi-Size Matrix Multiplier Testbench");
        $display("Testing %0d different matrix sizes", NUM_TESTS);
        $display("=========================================");
        
        // Seed random number generator with time for variety
        $srandom($time);
        
        // Run all tests
        for (int test_idx = 0; test_idx < NUM_TESTS; test_idx++) begin
            run_test(TEST_SIZES[test_idx]);
        end
        
        // Final summary
        $display("\n\n=========================================");
        $display("         FINAL TEST SUMMARY");
        $display("=========================================");
        $display("Tests Run:    %0d/%0d", total_tests_run, NUM_TESTS);
        $display("Tests Passed: %0d/%0d", total_tests_passed, NUM_TESTS);
        $display("Total Blocks: %0d checked, %0d passed", 
                 total_blocks_checked, total_blocks_passed);
        $display("");
        
        if (total_tests_passed == NUM_TESTS) begin
            $display("                       ,, ,,, ,,,, ,,,,,,,,");
            $display("          /\        /;; ;;;;;;;;;;;;;; ;;;/ ,;`.   ,,,,");
            $display("         ;  `-.    /// //////// /////  // ,','`;. ///;;;;,.");
            $display("        ,'   ,,`-.;;;;;; ;;;;;;; ;;;;// ,' ,'  `.`. ///;;//;,");
            $display("       ,'   ;;;//////// ////// ///////,'  ,'     ; : ;;// ;//,");
            $display("       `.  ;`;;;;;;;: ;;;;:;; ;:;:;;:;:  ,'     ,' : ;;;;;;;;/,");
            $display("        `. `; :!::::!;;;;;!::::!;!;;!;:  `.   ,'  ,'///!!;;;;;;");
            $display("          `._!!;!!!!;!!!!!;!!!!;!;!!;!!`.  `;'  ,'-.!!!//;;;////");
            $display("             ;   .   .               ,        ,'    ::-!_///;;;;");
            $display("           .' ,%'  ,%'     `%.   `%.;;   `%.   ;;   ,::  `! ////");
            $display("          .', '    '    `%,  `:.   `::.   ::  :;    %::    `! ;;");
            $display("         ,';;        `%, `;;.         `::. `.;;;    `:%   %:///");
            $display("        ,';;'  ;      ;;  `::;   `%,    ;%:.  ::     ::     %`!/");
            $display("      ,' ;.'  .%.    ;;    `;;     ;;   ' `;   %     ::    %  :");
            $display("      :  `;;  %%%    `::   ;;     ;;;      `    `    ::     % `");
            $display("      ;    ' .%%'  `%  ;   '  ,., `;;         `%,   ::'   %::%");
            $display("     ;`. `.  %%%%   ;;   .___;;;;  '     `:    `;   ::     :::");
            $display("     : :  ;  %%%%   ;: ,:' _ `.`.        ;;;   ;;   `::    :::.");
            $display("     `.;  ;  `%%'  ;;' :: (0) ; :       ::'    ;      ::   `:::");
            $display("      ,' ;'  %%'  ;;'  ;;.___,',;       ;;    ;;       ;   ,:::");
            $display("    ,  ;'  :%:   ;;  ,'------''      ;;;'  .;;            :::'");
            $display("    ,' ;;   ;%;   ;;  '             ::'    ,;;;            :::");
            $display("    :  :'   :%:   `;             ;;;;'      ;;             ::%");
            $display("    :  ;;   :%'   ;;   ;...,,;;''         ;;'    ;     ;   :::");
            $display("    ;  `;   ::   ;;' ,:::'     .        .;;     ,'    ;;   `;;");
            $display("    ;  ;'   :: .;;' ,:::'   ,::%.      ;;;    ,'     ;;    ,;;");
            $display("    : ;;.  .:' ;;' ,:::' ;;:::' ;;    ;;'    ,'    ;;;    ;;;'");
            $display("     :`;;  ::  ;;  ;;;' '  .    ;;    '  _,-'     ;;;     `;'");
            $display("     : ;' .:'  ;; .::: ,%'`;   ;;;   _,-'       .;;;'     ;'");
            $display("    ,' ;; ;;  ;;' :::' ,, .;  ;;  _,' ;      ,;;;'     ,;;'");
            $display("   .'~~~~~~~~~._ ,;' ,',' ;;  ',-'   ,'    ,';;       ;;;'   ;;;");
            $display(" ,'             `-.,' .'  ;; ,'     ,' ;;;;;;'       ,;;    ;;;");
            $display(".';           .    `.,   ;; ,'      ;              ,;;%    ;;;");
            $display(": ..       _.';     ;   '_,'       .'       ,,,,,,,%;;'    `;;;");
            $display("`.  .     (_.' .  ;'  ,-'          :  ,,,,,;;;;;;;;;'      .;;;");
            $display("  `-._        ___,' ,'             :..\"\"\"\"`", "````'  ,;;;;");
            $display("      `------'____.'               :                   ..;;;;");
            $display("");
            $display("");
            $display("                                                  _    _                     ");
            $display("     /\\                                          | |  | |                    ");
            $display("    /  \\__      _____  ___  ___  _ __ ___   ___  | |__| | ___  _ __ ___  ___ ");
            $display("   / /\\ \\ \\ /\\ / / _ \\/ __|/ _ \\| '_ ` _ \\ / _ \\ |  __  |/ _ \\| '__/ __|/ _ \\ ");
            $display("  / ____ \\ V  V /  __/\\__ \\ (_) | | | | | |  __/ | |  | | (_) | |  \\__ \\  __/");
            $display(" /_/    \\_\\_/\\_/ \\___||___/\\___/|_| |_| |_|\\___| |_|  |_|\\___/|_|  |___/\\___|");
            $display("");
            $display("");
            $display("");
            $display("   ALL TESTS PASSED! ");
            
        end else begin
            $display("   SOME TESTS FAILED :(((((");
            $display("   Failed: %0d test(s)", NUM_TESTS - total_tests_passed);
        end
        $display("=========================================");
        
        $finish;
    end
    
endmodule
