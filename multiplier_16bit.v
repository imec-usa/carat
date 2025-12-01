
module and_gate (
    input wire a,
    input wire b,
    output wire out
);
    and(out,a,b);
endmodule


module xor_gate (
    input wire a,
    input wire b,
    output wire out
);
    xor(out,a,b);
endmodule

module or_gate (
    input wire a,
    input wire b,
    output wire out
);
    or(out,a,b);
endmodule


// High-performance 16x16 bit multiplier using simplified array structure
// Gate-level implementation with proper partial product alignment

module multiplier_16bit (
    input wire [15:0] a,
    input wire [15:0] b,
    output wire [31:0] product
);

    // Partial products - properly aligned
    wire [31:0] pp [15:0];

    // Generate partial products with proper shifting
    genvar i, j;
    generate
        for (i = 0; i < 16; i = i + 1) begin : pp_row
            for (j = 0; j < 16; j = j + 1) begin : pp_col
                wire pp_bit;
                and pp_and (pp_bit, a[j], b[i]);
                assign pp[i][j+i] = pp_bit;
            end
            // Fill lower bits with zeros
            if (i > 0) begin : lower_zeros
                for (j = 0; j < i; j = j + 1) begin : lz
                    assign pp[i][j] = 1'b0;
                end
            end
            // Fill upper bits with zeros
            if (i + 16 < 32) begin : upper_zeros
                for (j = i + 16; j < 32; j = j + 1) begin : uz
                    assign pp[i][j] = 1'b0;
                end
            end
        end
    endgenerate

    // Stage 1: Reduce 16 partial products using CSAs
    wire [31:0] s1_sum[5:0], s1_carry[5:0];

    csa_32bit csa1_0 (.a(pp[0]), .b(pp[1]), .c(pp[2]), .sum(s1_sum[0]), .carry(s1_carry[0]));
    csa_32bit csa1_1 (.a(pp[3]), .b(pp[4]), .c(pp[5]), .sum(s1_sum[1]), .carry(s1_carry[1]));
    csa_32bit csa1_2 (.a(pp[6]), .b(pp[7]), .c(pp[8]), .sum(s1_sum[2]), .carry(s1_carry[2]));
    csa_32bit csa1_3 (.a(pp[9]), .b(pp[10]), .c(pp[11]), .sum(s1_sum[3]), .carry(s1_carry[3]));
    csa_32bit csa1_4 (.a(pp[12]), .b(pp[13]), .c(pp[14]), .sum(s1_sum[4]), .carry(s1_carry[4]));
    assign s1_sum[5] = pp[15];
    assign s1_carry[5] = 32'd0;

    // Stage 2: Reduce to fewer rows (12 rows -> 4 rows)
    wire [31:0] s2_sum[3:0], s2_carry[3:0];

    csa_32bit csa2_0 (.a(s1_sum[0]), .b({s1_carry[0][30:0], 1'b0}), .c(s1_sum[1]),
                      .sum(s2_sum[0]), .carry(s2_carry[0]));
    csa_32bit csa2_1 (.a({s1_carry[1][30:0], 1'b0}), .b(s1_sum[2]), .c({s1_carry[2][30:0], 1'b0}),
                      .sum(s2_sum[1]), .carry(s2_carry[1]));
    csa_32bit csa2_2 (.a(s1_sum[3]), .b({s1_carry[3][30:0], 1'b0}), .c(s1_sum[4]),
                      .sum(s2_sum[2]), .carry(s2_carry[2]));
    csa_32bit csa2_3 (.a({s1_carry[4][30:0], 1'b0}), .b(s1_sum[5]), .c({s1_carry[5][30:0], 1'b0}),
                      .sum(s2_sum[3]), .carry(s2_carry[3]));

    // Stage 3: Reduce to 3 rows (8 rows -> 3 rows)
    wire [31:0] s3_sum[2:0], s3_carry[2:0];

    csa_32bit csa3_0 (.a(s2_sum[0]), .b({s2_carry[0][30:0], 1'b0}), .c(s2_sum[1]),
                      .sum(s3_sum[0]), .carry(s3_carry[0]));
    csa_32bit csa3_1 (.a({s2_carry[1][30:0], 1'b0}), .b(s2_sum[2]), .c({s2_carry[2][30:0], 1'b0}),
                      .sum(s3_sum[1]), .carry(s3_carry[1]));
    assign s3_sum[2] = s2_sum[3];
    assign s3_carry[2] = {s2_carry[3][30:0], 1'b0};

    // Stage 4: Reduce to 2 rows (6 rows -> 2 rows)
    wire [31:0] s4_sum[1:0], s4_carry[1:0];

    csa_32bit csa4_0 (.a(s3_sum[0]), .b({s3_carry[0][30:0], 1'b0}), .c(s3_sum[1]),
                      .sum(s4_sum[0]), .carry(s4_carry[0]));
    csa_32bit csa4_1 (.a({s3_carry[1][30:0], 1'b0}), .b(s3_sum[2]), .c(s3_carry[2]),
                      .sum(s4_sum[1]), .carry(s4_carry[1]));

    // Stage 5: Final reduction to 2 rows
    wire [31:0] final_sum, final_carry;

    csa_32bit csa_final (.a(s4_sum[0]), .b({s4_carry[0][30:0], 1'b0}), .c(s4_sum[1]),
                         .sum(final_sum), .carry(final_carry));

    // Final carry-propagate addition
    wire [31:0] shifted_carry;
    assign shifted_carry = {final_carry[30:0], 1'b0};

    wire [31:0] temp_sum;
    adder_32bit final_adder1 (.a(final_sum), .b(shifted_carry), .sum(temp_sum));

    wire [31:0] shifted_carry2;
    assign shifted_carry2 = {s4_carry[1][30:0], 1'b0};

    adder_32bit final_adder2 (.a(temp_sum), .b(shifted_carry2), .sum(product));

endmodule