a`timescale 1ns/1ps

module tb_mac_array_4x4;

    // Clock and reset
    reg clk;
    reg rst_n;
    reg en;
    reg load_acc;
    
    // Input matrices
    reg [15:0] a_in_0, a_in_1, a_in_2, a_in_3;
    reg [15:0] b_in_0, b_in_1, b_in_2, b_in_3;
    
    // Partial sum initialization
    reg [31:0] partial_sum_init [0:3][0:3];
    
    // Output results
    wire [31:0] result_0_0, result_0_1, result_0_2, result_0_3;
    wire [31:0] result_1_0, result_1_1, result_1_2, result_1_3;
    wire [31:0] result_2_0, result_2_1, result_2_2, result_2_3;
    wire [31:0] result_3_0, result_3_1, result_3_2, result_3_3;
    
    // Test matrices
    reg [15:0] matrix_a [0:3][0:3];
    reg [15:0] matrix_b [0:3][0:3];
    reg [31:0] expected_result [0:3][0:3];
    
    // Instantiate MAC array
    mac_array_4x4 dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .load_acc(load_acc),
        .a_in_0(a_in_0),
        .a_in_1(a_in_1),
        .a_in_2(a_in_2),
        .a_in_3(a_in_3),
        .b_in_0(b_in_0),
        .b_in_1(b_in_1),
        .b_in_2(b_in_2),
        .b_in_3(b_in_3),
        .partial_sum_init(partial_sum_init),
        .result_0_0(result_0_0), .result_0_1(result_0_1), .result_0_2(result_0_2), .result_0_3(result_0_3),
        .result_1_0(result_1_0), .result_1_1(result_1_1), .result_1_2(result_1_2), .result_1_3(result_1_3),
        .result_2_0(result_2_0), .result_2_1(result_2_1), .result_2_2(result_2_2), .result_2_3(result_2_3),
        .result_3_0(result_3_0), .result_3_1(result_3_1), .result_3_2(result_3_2), .result_3_3(result_3_3)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Initialize test matrices
    task init_matrices;
        begin
            // Matrix A: 4x4
            matrix_a[0][0] = 16'd1;  matrix_a[0][1] = 16'd2;  matrix_a[0][2] = 16'd3;  matrix_a[0][3] = 16'd4;
            matrix_a[1][0] = 16'd5;  matrix_a[1][1] = 16'd6;  matrix_a[1][2] = 16'd7;  matrix_a[1][3] = 16'd8;
            matrix_a[2][0] = 16'd9;  matrix_a[2][1] = 16'd10; matrix_a[2][2] = 16'd11; matrix_a[2][3] = 16'd12;
            matrix_a[3][0] = 16'd13; matrix_a[3][1] = 16'd14; matrix_a[3][2] = 16'd15; matrix_a[3][3] = 16'd16;
            
            // Matrix B: 4x4
            matrix_b[0][0] = 16'd2;  matrix_b[0][1] = 16'd0;  matrix_b[0][2] = 16'd1;  matrix_b[0][3] = 16'd0;
            matrix_b[1][0] = 16'd0;  matrix_b[1][1] = 16'd2;  matrix_b[1][2] = 16'd0;  matrix_b[1][3] = 16'd1;
            matrix_b[2][0] = 16'd1;  matrix_b[2][1] = 16'd0;  matrix_b[2][2] = 16'd2;  matrix_b[2][3] = 16'd0;
            matrix_b[3][0] = 16'd0;  matrix_b[3][1] = 16'd1;  matrix_b[3][2] = 16'd0;  matrix_b[3][3] = 16'd2;
            
            // Calculate expected results (C = A * B)
            expected_result[0][0] = 32'd7;   expected_result[0][1] = 32'd8;   expected_result[0][2] = 32'd9;   expected_result[0][3] = 32'd10;
            expected_result[1][0] = 32'd19;  expected_result[1][1] = 32'd24;  expected_result[1][2] = 32'd29;  expected_result[1][3] = 32'd34;
            expected_result[2][0] = 32'd31;  expected_result[2][1] = 32'd40;  expected_result[2][2] = 32'd49;  expected_result[2][3] = 32'd58;
            expected_result[3][0] = 32'd43;  expected_result[3][1] = 32'd56;  expected_result[3][2] = 32'd69;  expected_result[3][3] = 32'd82;
        end
    endtask
    
    // Feed data into systolic array (diagonal wavefront pattern)
    task feed_systolic_data;
        integer cycle;
        integer row, col;
        begin
            // Initialize all inputs to zero
            a_in_0 = 16'd0; a_in_1 = 16'd0; a_in_2 = 16'd0; a_in_3 = 16'd0;
            b_in_0 = 16'd0; b_in_1 = 16'd0; b_in_2 = 16'd0; b_in_3 = 16'd0;
            
            // Feed data in diagonal wavefront pattern
            // Total cycles needed: 4 (rows) + 4 (cols) - 1 = 7
            for (cycle = 0; cycle < 7; cycle = cycle + 1) begin
                // Feed A matrix (horizontal input)
                if (cycle < 4) a_in_0 = matrix_a[0][cycle];
                else a_in_0 = 16'd0;
                
                if (cycle >= 1 && cycle < 5) a_in_1 = matrix_a[1][cycle-1];
                else a_in_1 = 16'd0;
                
                if (cycle >= 2 && cycle < 6) a_in_2 = matrix_a[2][cycle-2];
                else a_in_2 = 16'd0;
                
                if (cycle >= 3 && cycle < 7) a_in_3 = matrix_a[3][cycle-3];
                else a_in_3 = 16'd0;
                
                // Feed B matrix (vertical input)
                if (cycle < 4) b_in_0 = matrix_b[cycle][0];
                else b_in_0 = 16'd0;
                
                if (cycle >= 1 && cycle < 5) b_in_1 = matrix_b[cycle-1][1];
                else b_in_1 = 16'd0;
                
                if (cycle >= 2 && cycle < 6) b_in_2 = matrix_b[cycle-2][2];
                else b_in_2 = 16'd0;
                
                if (cycle >= 3 && cycle < 7) b_in_3 = matrix_b[cycle-3][3];
                else b_in_3 = 16'd0;
                
                @(posedge clk);
            end
        end
    endtask
    
    // Check results
    task check_results;
        integer errors;
        begin
            errors = 0;
            
            $display("\n=== Checking Results ===");
            $display("Expected vs Actual:");
            
            if (result_0_0 !== expected_result[0][0]) begin
                $display("ERROR: [0][0] Expected=%0d, Got=%0d", expected_result[0][0], result_0_0);
                errors = errors + 1;
            end else $display("PASS: [0][0] = %0d", result_0_0);
            
            if (result_0_1 !== expected_result[0][1]) begin
                $display("ERROR: [0][1] Expected=%0d, Got=%0d", expected_result[0][1], result_0_1);
                errors = errors + 1;
            end else $display("PASS: [0][1] = %0d", result_0_1);
            
            if (result_0_2 !== expected_result[0][2]) begin
                $display("ERROR: [0][2] Expected=%0d, Got=%0d", expected_result[0][2], result_0_2);
                errors = errors + 1;
            end else $display("PASS: [0][2] = %0d", result_0_2);
            
            if (result_0_3 !== expected_result[0][3]) begin
                $display("ERROR: [0][3] Expected=%0d, Got=%0d", expected_result[0][3], result_0_3);
                errors = errors + 1;
            end else $display("PASS: [0][3] = %0d", result_0_3);
            
            if (result_1_0 !== expected_result[1][0]) begin
                $display("ERROR: [1][0] Expected=%0d, Got=%0d", expected_result[1][0], result_1_0);
                errors = errors + 1;
            end else $display("PASS: [1][0] = %0d", result_1_0);
            
            if (result_1_1 !== expected_result[1][1]) begin
                $display("ERROR: [1][1] Expected=%0d, Got=%0d", expected_result[1][1], result_1_1);
                errors = errors + 1;
            end else $display("PASS: [1][1] = %0d", result_1_1);
            
            if (result_1_2 !== expected_result[1][2]) begin
                $display("ERROR: [1][2] Expected=%0d, Got=%0d", expected_result[1][2], result_1_2);
                errors = errors + 1;
            end else $display("PASS: [1][2] = %0d", result_1_2);
            
            if (result_1_3 !== expected_result[1][3]) begin
                $display("ERROR: [1][3] Expected=%0d, Got=%0d", expected_result[1][3], result_1_3);
                errors = errors + 1;
            end else $display("PASS: [1][3] = %0d", result_1_3);
            
            if (result_2_0 !== expected_result[2][0]) begin
                $display("ERROR: [2][0] Expected=%0d, Got=%0d", expected_result[2][0], result_2_0);
                errors = errors + 1;
            end else $display("PASS: [2][0] = %0d", result_2_0);
            
            if (result_2_1 !== expected_result[2][1]) begin
                $display("ERROR: [2][1] Expected=%0d, Got=%0d", expected_result[2][1], result_2_1);
                errors = errors + 1;
            end else $display("PASS: [2][1] = %0d", result_2_1);
            
            if (result_2_2 !== expected_result[2][2]) begin
                $display("ERROR: [2][2] Expected=%0d, Got=%0d", expected_result[2][2], result_2_2);
                errors = errors + 1;
            end else $display("PASS: [2][2] = %0d", result_2_2);
            
            if (result_2_3 !== expected_result[2][3]) begin
                $display("ERROR: [2][3] Expected=%0d, Got=%0d", expected_result[2][3], result_2_3);
                errors = errors + 1;
            end else $display("PASS: [2][3] = %0d", result_2_3);
            
            if (result_3_0 !== expected_result[3][0]) begin
                $display("ERROR: [3][0] Expected=%0d, Got=%0d", expected_result[3][0], result_3_0);
                errors = errors + 1;
            end else $display("PASS: [3][0] = %0d", result_3_0);
            
            if (result_3_1 !== expected_result[3][1]) begin
                $display("ERROR: [3][1] Expected=%0d, Got=%0d", expected_result[3][1], result_3_1);
                errors = errors + 1;
            end else $display("PASS: [3][1] = %0d", result_3_1);
            
            if (result_3_2 !== expected_result[3][2]) begin
                $display("ERROR: [3][2] Expected=%0d, Got=%0d", expected_result[3][2], result_3_2);
                errors = errors + 1;
            end else $display("PASS: [3][2] = %0d", result_3_2);
            
            if (result_3_3 !== expected_result[3][3]) begin
                $display("ERROR: [3][3] Expected=%0d, Got=%0d", expected_result[3][3], result_3_3);
                errors = errors + 1;
            end else $display("PASS: [3][3] = %0d", result_3_3);
            
            if (errors == 0) begin
                $display("\n*** ALL TESTS PASSED! ***\n");
            end else begin
                $display("\n*** %0d ERRORS FOUND! ***\n", errors);
            end
        end
    endtask
    
    // Main test sequence
    initial begin
        integer i, j;
        
        $display("\n=== 4x4 MAC Array Testbench ===");
        $display("Testing Output Stationary Dataflow");
        
        // Initialize
        rst_n = 0;
        en = 0;
        load_acc = 0;
        a_in_0 = 0; a_in_1 = 0; a_in_2 = 0; a_in_3 = 0;
        b_in_0 = 0; b_in_1 = 0; b_in_2 = 0; b_in_3 = 0;
        
        // Initialize partial sums to zero
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                partial_sum_init[i][j] = 32'd0;
            end
        end
        
        // Initialize test matrices
        init_matrices();
        
        // Reset sequence
        repeat(5) @(posedge clk);
        rst_n = 1;
        repeat(2) @(posedge clk);
        
        $display("\nMatrix A:");
        $display("%0d %0d %0d %0d", matrix_a[0][0], matrix_a[0][1], matrix_a[0][2], matrix_a[0][3]);
        $display("%0d %0d %0d %0d", matrix_a[1][0], matrix_a[1][1], matrix_a[1][2], matrix_a[1][3]);
        $display("%0d %0d %0d %0d", matrix_a[2][0], matrix_a[2][1], matrix_a[2][2], matrix_a[2][3]);
        $display("%0d %0d %0d %0d", matrix_a[3][0], matrix_a[3][1], matrix_a[3][2], matrix_a[3][3]);
        
        $display("\nMatrix B:");
        $display("%0d %0d %0d %0d", matrix_b[0][0], matrix_b[0][1], matrix_b[0][2], matrix_b[0][3]);
        $display("%0d %0d %0d %0d", matrix_b[1][0], matrix_b[1][1], matrix_b[1][2], matrix_b[1][3]);
        $display("%0d %0d %0d %0d", matrix_b[2][0], matrix_b[2][1], matrix_b[2][2], matrix_b[2][3]);
        $display("%0d %0d %0d %0d", matrix_b[3][0], matrix_b[3][1], matrix_b[3][2], matrix_b[3][3]);
        
        // Enable array
        en = 1;
        
        // Feed data through systolic array
        $display("\nFeeding data into systolic array...");
        feed_systolic_data();
        
        // Wait for computation to complete (additional pipeline delay)
        repeat(10) @(posedge clk);
        
        // Check results
        check_results();
        
        // Additional test: accumulation test
        $display("\n=== Testing Accumulation ===");
        load_acc = 1;
        @(posedge clk);
        load_acc = 0;
        
        // Feed data again to test accumulation
        feed_systolic_data();
        repeat(10) @(posedge clk);
        
        $display("\nAfter accumulation (results should be 2x original):");
        $display("Result[0][0] = %0d (expected %0d)", result_0_0, expected_result[0][0] * 2);
        $display("Result[1][1] = %0d (expected %0d)", result_1_1, expected_result[1][1] * 2);
        $display("Result[2][2] = %0d (expected %0d)", result_2_2, expected_result[2][2] * 2);
        $display("Result[3][3] = %0d (expected %0d)", result_3_3, expected_result[3][3] * 2);
        
        // Finish simulation
        repeat(10) @(posedge clk);
        $display("\nSimulation completed.");
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #100000;
        $display("\nERROR: Simulation timeout!");
        $finish;
    end
    
    // Optional: Waveform dump
    initial begin
        $dumpfile("mac_array_4x4.vcd");
        $dumpvars(0, tb_mac_array_4x4);
    end

endmodule
