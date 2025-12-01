`timescale 1ns/1ps

module tb_multiplier_16bit;

    // Inputs
    reg [15:0] a;
    reg [15:0] b;
    
    // Output
    wire [31:0] product;
    
    // Expected result
    reg [31:0] expected;
    
    // Error counter
    integer errors;
    integer test_num;
    
    // Instantiate the multiplier
    multiplier_16bit dut (
        .a(a),
        .b(b),
        .product(product)
    );
    
    // Task to check result
    task check_result;
        input [31:0] expected_val;
        input [31:0] actual_val;
        input integer test_number;
        begin
            if (expected_val !== actual_val) begin
                $display("ERROR: Test %0d Failed!", test_number);
                $display("  A = 0x%04h (%0d)", a, a);
                $display("  B = 0x%04h (%0d)", b, b);
                $display("  Expected = 0x%08h (%0d)", expected_val, expected_val);
                $display("  Got      = 0x%08h (%0d)", actual_val, actual_val);
                errors = errors + 1;
            end else begin
                $display("PASS: Test %0d - %0d × %0d = %0d", test_number, a, b, product);
            end
        end
    endtask
    
    // Test sequence
    initial begin
        errors = 0;
        test_num = 0;
        
        $display("\n=== 16-bit Multiplier Testbench ===\n");
        
        // Test 1: Zero multiplication
        test_num = test_num + 1;
        a = 16'd0;
        b = 16'd5;
        expected = 32'd0;
        #10;
        check_result(expected, product, test_num);
        
        // Test 2: Multiply by zero
        test_num = test_num + 1;
        a = 16'd100;
        b = 16'd0;
        expected = 32'd0;
        #10;
        check_result(expected, product, test_num);
        
        // Test 3: Multiply by one
        test_num = test_num + 1;
        a = 16'd42;
        b = 16'd1;
        expected = 32'd42;
        #10;
        check_result(expected, product, test_num);
        
        // Test 4: One times one
        test_num = test_num + 1;
        a = 16'd1;
        b = 16'd1;
        expected = 32'd1;
        #10;
        check_result(expected, product, test_num);
        
        // Test 5: Small numbers
        test_num = test_num + 1;
        a = 16'd5;
        b = 16'd7;
        expected = 32'd35;
        #10;
        check_result(expected, product, test_num);
        
        // Test 6: Powers of 2
        test_num = test_num + 1;
        a = 16'd16;
        b = 16'd16;
        expected = 32'd256;
        #10;
        check_result(expected, product, test_num);
        
        // Test 7: Larger power of 2
        test_num = test_num + 1;
        a = 16'd256;
        b = 16'd256;
        expected = 32'd65536;
        #10;
        check_result(expected, product, test_num);
        
        // Test 8: Maximum 8-bit values
        test_num = test_num + 1;
        a = 16'd255;
        b = 16'd255;
        expected = 32'd65025;
        #10;
        check_result(expected, product, test_num);
        
        // Test 9: Maximum 16-bit values
        test_num = test_num + 1;
        a = 16'd65535;
        b = 16'd65535;
        expected = 32'd4294836225;
        #10;
        check_result(expected, product, test_num);
        
        // Test 10: One operand at maximum
        test_num = test_num + 1;
        a = 16'd65535;
        b = 16'd2;
        expected = 32'd131070;
        #10;
        check_result(expected, product, test_num);
        
        // Test 11: Alternating bits
        test_num = test_num + 1;
        a = 16'hAAAA;
        b = 16'h5555;
        expected = 32'h38E38E8E;
        #10;
        check_result(expected, product, test_num);
        
        // Test 12: Pattern test
        test_num = test_num + 1;
        a = 16'hF0F0;
        b = 16'h0F0F;
        expected = 32'h0E1D19C0;
        #10;
        check_result(expected, product, test_num);
        
        // Test 13: Sequential numbers
        test_num = test_num + 1;
        a = 16'd100;
        b = 16'd200;
        expected = 32'd20000;
        #10;
        check_result(expected, product, test_num);
        
        // Test 14: Prime numbers
        test_num = test_num + 1;
        a = 16'd97;
        b = 16'd101;
        expected = 32'd9797;
        #10;
        check_result(expected, product, test_num);
        
        // Test 15: Large primes
        test_num = test_num + 1;
        a = 16'd251;
        b = 16'd257;
        expected = 32'd64507;
        #10;
        check_result(expected, product, test_num);
        
        // Test 16-20: Corner cases with specific bit patterns
        test_num = test_num + 1;
        a = 16'h8000;
        b = 16'h0002;
        expected = 32'h00010000;
        #10;
        check_result(expected, product, test_num);
        
        test_num = test_num + 1;
        a = 16'h0001;
        b = 16'hFFFF;
        expected = 32'h0000FFFF;
        #10;
        check_result(expected, product, test_num);
        
        test_num = test_num + 1;
        a = 16'h1234;
        b = 16'h5678;
        expected = 32'h06260060;
        #10;
        check_result(expected, product, test_num);
        
        test_num = test_num + 1;
        a = 16'hABCD;
        b = 16'hEF01;
        expected = 32'hA0E8ABCD;
        #10;
        check_result(expected, product, test_num);
        
        test_num = test_num + 1;
        a = 16'h7FFF;
        b = 16'h7FFF;
        expected = 32'h3FFF0001;
        #10;
        check_result(expected, product, test_num);
        
        // Test 21-35: Comprehensive random tests
        $display("\n--- Random Multiplication Tests ---");
        repeat(15) begin
            test_num = test_num + 1;
            a = $random & 16'hFFFF;
            b = $random & 16'hFFFF;
            expected = a * b;
            #10;
            check_result(expected, product, test_num);
        end
        
        // Test 36-50: Edge cases with systematic patterns
        $display("\n--- Systematic Pattern Tests ---");
        repeat(15) begin
            test_num = test_num + 1;
            a = test_num * 1000;
            b = test_num * 2;
            expected = a * b;
            #10;
            check_result(expected, product, test_num);
        end
        
        // Summary
        $display("\n=== Test Summary ===");
        $display("Total Tests: %0d", test_num);
        $display("Passed: %0d", test_num - errors);
        $display("Failed: %0d", errors);
        
        if (errors == 0) begin
            $display("\n*** ALL MULTIPLIER TESTS PASSED! ***\n");
        end else begin
            $display("\n*** %0d MULTIPLIER TESTS FAILED! ***\n", errors);
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
        $dumpfile("multiplier_16bit.vcd");
        $dumpvars(0, tb_multiplier_16bit);
    end

endmodule
