// 32-bit Carry-Save Adder (3:2 compressor)
// Reduces 3 inputs to 2 outputs (sum and carry)

module csa_32bit (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [31:0] c,
    output wire [31:0] sum,
    output wire [31:0] carry
);

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : csa_bit
            full_adder fa (
                .a(a[i]),
                .b(b[i]),
                .c_in(c[i]),
                .sum(sum[i]),
                .c_out(carry[i])
            );
        end
    endgenerate

endmodule

// Full adder gate-level implementation
module full_adder (
    input wire a,
    input wire b,
    input wire c_in,
    output wire sum,
    output wire c_out
);

    wire xor_ab, and_ab, and_xor_cin;

    // sum = a XOR b XOR c_in
    xor_gate xor1 (.a(a), .b(b), .out(xor_ab));
    xor_gate xor2 (.a(xor_ab), .b(c_in), .out(sum));

    // c_out = (a AND b) OR ((a XOR b) AND c_in)
    and_gate and1 (.a(a), .b(b), .out(and_ab));
    and_gate and2 (.a(xor_ab), .b(c_in), .out(and_xor_cin));
    or_gate or1 (.a(and_ab), .b(and_xor_cin), .out(c_out));

endmodule


