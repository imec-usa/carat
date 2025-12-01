`timescale 1ns/1ps

module tb_pe;

    // Clock and control signals
    reg clk;
    reg rst_n;
    reg en;
    reg load_acc;

    // Inputs
    reg [15:0] a_in;
    reg [15:0] b_in;
    reg [31:0] partial_sum_in;

    // Outputs
    wire [15:0] a_out;
    wire [15:0] b_out;
    wire [31:0] acc_out;

    // Expected result
    reg [31:0] expected_acc;

    // Error counter
    integer errors;
    integer test_num;

    // Random values
    reg [15:0] rand_a, rand_b;
    reg [31:0] current_acc;


    // Instantiate the PE
    pe dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .a_in(a_in),
        .b_in(b_in),
        .partial_sum_in(partial_sum_in),
        .load_acc(load_acc),
        .a_out(a_out),
        .b_out(b_out),
        .acc_out(acc_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Task to check result
    task check_result;
        input [31:0] expected_val;
        input [31:0] actual_val;
        input integer test_number;
        input [255:0] description;
        begin
            if (expected_val !== actual_val) begin
                $display("ERROR: Test %0d Failed! (%0s)", test_number, description);
                $display("  Expected = %0d (0x%08h)", expected_val, expected_val);
                $display("  Got      = %0d (0x%08h)", actual_val, actual_val);
                errors = errors + 1;
            end else begin
                $display("PASS: Test %0d - %0s = %0d", test_number, description, actual_val);
            end
        end
    endtask

    // Task to perform MAC operation
    task do_mac;
        input [15:0] a_val;
        input [15:0] b_val;
        begin
            a_in = a_val;
            b_in = b_val;
            @(posedge clk);
            @(posedge clk); // Wait for computation
        end
    endtask

    // Test sequence
    initial begin
        errors = 0;
        test_num = 0;

        $display("\n=== MAC PE Testbench ===\n");

        // Initialize
        rst_n = 0;
        en = 0;
        load_acc = 0;
        a_in = 16'd0;
        b_in = 16'd0;
        partial_sum_in = 32'd0;

        // Reset
        repeat(3) @(posedge clk);
        rst_n = 1;
        repeat(2) @(posedge clk);

        $display("--- Basic MAC Operations ---\n");

        // Test 1: Simple MAC operation
        test_num = test_num + 1;
        en = 1;
        do_mac(16'd2, 16'd3);
        expected_acc = 32'd6;
        check_result(expected_acc, acc_out, test_num, "2 × 3");

        // Test 2: Accumulation - add another MAC
        test_num = test_num + 1;
        do_mac(16'd4, 16'd5);
        expected_acc = 32'd6 + 32'd20;
        check_result(expected_acc, acc_out, test_num, "Accumulated: 6 + (4 × 5)");

        // Test 3: Continue accumulation
        test_num = test_num + 1;
        do_mac(16'd10, 16'd10);
        expected_acc = 32'd26 + 32'd100;
        check_result(expected_acc, acc_out, test_num, "Accumulated: 26 + (10 × 10)");

        // Test 4: Reset accumulator
        test_num = test_num + 1;
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        expected_acc = 32'd0;
        check_result(expected_acc, acc_out, test_num, "After reset");

        $display("\n--- Load Accumulator Test ---\n");

        // Test 5: Load partial sum
        test_num = test_num + 1;
        partial_sum_in = 32'd1000;
        load_acc = 1;
        @(posedge clk);
        load_acc = 0;
        expected_acc = 32'd1000;
        check_result(expected_acc, acc_out, test_num, "Load 1000 into accumulator");

        // Test 6: MAC with preloaded value
        test_num = test_num + 1;
        do_mac(16'd5, 16'd5);
        expected_acc = 32'd1000 + 32'd25;
        check_result(expected_acc, acc_out, test_num, "1000 + (5 × 5)");

        $display("\n--- Enable Control Test ---\n");

        // Test 7: Disable PE
        test_num = test_num + 1;
        en = 0;
        a_in = 16'd100;
        b_in = 16'd100;
        @(posedge clk);
        @(posedge clk);
        expected_acc = 32'd1025; // Should remain unchanged
        check_result(expected_acc, acc_out, test_num, "PE disabled (no change)");

        // Test 8: Re-enable PE
        test_num = test_num + 1;
        en = 1;
        do_mac(16'd2, 16'd2);
        expected_acc = 32'd1025 + 32'd4;
        check_result(expected_acc, acc_out, test_num, "PE re-enabled: 1025 + (2 × 2)");

        $display("\n--- Passthrough Test ---\n");

        // Test 9: Check A passthrough
        test_num = test_num + 1;
        a_in = 16'hABCD;
        b_in = 16'd1;
        @(posedge clk);
        @(posedge clk);
        if (a_out !== 16'hABCD) begin
            $display("ERROR: Test %0d - A passthrough failed!", test_num);
            $display("  Expected a_out = 0x%04h, Got = 0x%04h", 16'hABCD, a_out);
            errors = errors + 1;
        end else begin
            $display("PASS: Test %0d - A passthrough = 0x%04h", test_num, a_out);
        end

        // Test 10: Check B passthrough
        test_num = test_num + 1;
        a_in = 16'd1;
        b_in = 16'h1234;
        @(posedge clk);
        @(posedge clk);
        if (b_out !== 16'h1234) begin
            $display("ERROR: Test %0d - B passthrough failed!", test_num);
            $display("  Expected b_out = 0x%04h, Got = 0x%04h", 16'h1234, b_out);
            errors = errors + 1;
        end else begin
            $display("PASS: Test %0d - B passthrough = 0x%04h", test_num, b_out);
        end

        $display("\n--- Edge Cases ---\n");

        // Test 11: Multiply by zero
        test_num = test_num + 1;
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        do_mac(16'd100, 16'd0);
        expected_acc = 32'd0;
        check_result(expected_acc, acc_out, test_num, "100 × 0");

        // Test 12: Multiply by one
        test_num = test_num + 1;
        do_mac(16'd42, 16'd1);
        expected_acc = 32'd42;
        check_result(expected_acc, acc_out, test_num, "0 + (42 × 1)");

        // Test 13: Maximum 16-bit values
        test_num = test_num + 1;
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        do_mac(16'd65535, 16'd65535);
        expected_acc = 32'd4294836225;
        check_result(expected_acc, acc_out, test_num, "65535 × 65535");

        $display("\n--- Dot Product Test ---\n");

        // Test 14-17: Compute dot product of two vectors
        // Vector A: [1, 2, 3, 4]
        // Vector B: [5, 6, 7, 8]
        // Dot product = 1*5 + 2*6 + 3*7 + 4*8 = 5 + 12 + 21 + 32 = 70

        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        test_num = test_num + 1;
        do_mac(16'd1, 16'd5);
        expected_acc = 32'd5;
        check_result(expected_acc, acc_out, test_num, "Dot product step 1: 1×5");

        test_num = test_num + 1;
        do_mac(16'd2, 16'd6);
        expected_acc = 32'd5 + 32'd12;
        check_result(expected_acc, acc_out, test_num, "Dot product step 2: +2×6");

        test_num = test_num + 1;
        do_mac(16'd3, 16'd7);
        expected_acc = 32'd17 + 32'd21;
        check_result(expected_acc, acc_out, test_num, "Dot product step 3: +3×7");

        test_num = test_num + 1;
        do_mac(16'd4, 16'd8);
        expected_acc = 32'd38 + 32'd32;
        check_result(expected_acc, acc_out, test_num, "Dot product step 4: +4×8 = 70");

        $display("\n--- Large Accumulation Test ---\n");

        // Test 18: Many accumulations
        test_num = test_num + 1;
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        expected_acc = 32'd0;
        repeat(10) begin
            do_mac(16'd100, 16'd100);
            expected_acc = expected_acc + 32'd10000;
        end
        check_result(expected_acc, acc_out, test_num, "10 accumulations of 100×100");

        $display("\n--- Random MAC Operations ---\n");

        // Test 19-25: Random MAC operations
        repeat(7) begin
            test_num = test_num + 1;
            rand_a = $random & 16'hFFFF;
            rand_b = $random & 16'hFFFF;
            current_acc = acc_out;

                do_mac(rand_a, rand_b);
                expected_acc = current_acc + (rand_a * rand_b);
                check_result(expected_acc, acc_out, test_num, "Random MAC");
            end
        //end

        // Summary
        $display("\n=== Test Summary ===");
        $display("Total Tests: %0d", test_num);
        $display("Passed: %0d", test_num - errors);
        $display("Failed: %0d", errors);

        if (errors == 0) begin
            $display("\n*** ALL PE/MAC TESTS PASSED! ***\n");
        end else begin
            $display("\n*** %0d PE/MAC TESTS FAILED! ***\n", errors);
        end

        $finish;
    end

    // Timeout watchdog
    initial begin
        #50000;
        $display("\nERROR: Simulation timeout!");
        $finish;
    end

    // Optional: Waveform dump
    initial begin
        $dumpfile("pe.vcd");
        $dumpvars(0, tb_pe);
    end

endmodule