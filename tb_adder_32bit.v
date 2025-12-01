`timescale 1ns/1ps

module tb_adder_32bit;

    // Inputs
    reg [31:0] a;
    reg [31:0] b;
    
    // Output
    wire [31:0] sum;
    
    // Expected result
    reg [31:0] expected;
    
    // Error counter
    integer errors;
    integer test_num;
    
    // Instantiate the adder
    adder_32bit dut (
        .a(a),
        .b(b),
        .sum(sum)
    );
    
    // Task to check result
    task check_result;
        input [31:0] expected_val;
        input [31:0] actual_val;
        input integer test_number;
        begin
            if (expected_val !== actual_val) begin
                $display("ERROR: Test %0d Failed!", test_number);
                $display("  A = 0x%08h (%0d)", a, a);
                $display("  B = 0x%08h (%0d)", b, b);
                $display("  Expected = 0x%08h (%0d)", expected_val, expected_val);
                $display("  Got      = 0x%08h (%0d)", actual_val, actual_val);
                errors = errors + 1;
            end else begin
                $display("PASS: Test %0d - %0d + %0d = %0d", test_number, a, b, sum);
            end
        end
    endtask
    
    // Test sequence
    initial begin
        errors = 0;
        test_num = 0;
        
        $display("\n=== 32-bit Adder Testbench ===\n");
        
        // Test 1: Simple addition
        test_num = test_num + 1;
        a = 32'd5;
        b = 32'd3;
        expected = 32'd8;
        #10;
        check_result(expected, sum, test_num);
        
        // Test 2: Zero addition
        test_num = test_num + 1;
        a = 32'd100;
        b = 32'd0;
        expected = 32'd100;
        #10;
        check_result(expected, sum, test_num);
        
        // Test 3: Adding zeros
        test_num = test_num + 1;
        a = 32'd0;
        b = 32'd0;
        expected = 32'd0;
        #10;
        check_result(expected, sum, test_num);
        
        // Test 4: Large numbers
        test_num = test_num + 1;
        a = 32'd65535;
        b = 32'd65535;
        expected = 32'd131070;
        #10;
        check_result(expected, sum, test_num);
        
        // Test 5: Maximum value (overflow test)
        test_num = test_num + 1;
        a = 32'hFFFFFFFF;
        b = 32'h00000001;
        expected = 32'h00000000; // Wraps around
        #10;
        check_result(expected, sum, test_num);
        
        // Test 6: Powers of 2
        test_num = test_num + 1;
        a = 32'h00010000;
        b = 32'h00010000;
        expected = 32'h00020000;
        #10;
        check_result(expected, sum, test_num);
        
        // Test 7: Carry propagation test
        test_num = test_num + 1;
        a = 32'h0FFFFFFF;
        b = 32'h00000001;
        expected = 32'h10000000;
        #10;
        check_result(expected, sum, test_num);
        
        // Test 8: Multiple carry propagation
        test_num = test_num + 1;
        a = 32'hAAAAAAAA;
        b = 32'h55555555;
        expected = 32'hFFFFFFFF;
        #10;
        check_result(expected, sum, test_num);
        
        // Test 9: Random test 1
        test_num = test_num + 1;
        a = 32'h12345678;
        b = 32'h9ABCDEF0;
        expected = 32'hADF13568;
        #10;
        check_result(expected, sum, test_num);
        
        // Test 10: Random test 2
        test_num = test_num + 1;
        a = 32'hDEADBEEF;
        b = 32'hCAFEBABE;
        expected = 32'hA9AC79AD;
        #10;
        check_result(expected, sum, test_num);
        
        // Test 11: Alternating bits
        test_num = test_num + 1;
        a = 32'hF0F0F0F0;
        b = 32'h0F0F0F0F;
        expected = 32'hFFFFFFFF;
        #10;
        check_result(expected, sum, test_num);
        
        // Test 12: Sequential carries
        test_num = test_num + 1;
        a = 32'h7FFFFFFF;
        b = 32'h7FFFFFFF;
        expected = 32'hFFFFFFFE;
        #10;
        check_result(expected, sum, test_num);
        
        // Test 13-20: Random comprehensive tests
        repeat(8) begin
            test_num = test_num + 1;
            a = $random;
            b = $random;
            expected = a + b;
            #10;
            check_result(expected, sum, test_num);
        end
        
        // Summary
        $display("\n=== Test Summary ===");
        $display("Total Tests: %0d", test_num);
        $display("Passed: %0d", test_num - errors);
        $display("Failed: %0d", errors);
        
        if (errors == 0) begin
            $display("\n*** ALL ADDER TESTS PASSED! ***\n");
        end else begin
            $display("\n*** %0d ADDER TESTS FAILED! ***\n", errors);
        end
        
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #10000;
        $display("\nERROR: Simulation timeout!");
        $finish;
    end
    
    // Optional: Waveform dump
    initial begin
        $dumpfile("adder_32bit.vcd");
        $dumpvars(0, tb_adder_32bit);
    end

endmodule
