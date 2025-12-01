// True Gate-Level Full Adder using Verilog primitives
module full_adder (
    input wire a,
    input wire b,
    input wire c_in,
    output wire sum,
    output wire c_out
);

    wire xor_ab, and_ab, and_xor_cin;

    // sum = a XOR b XOR c_in
    xor xor1 (xor_ab, a, b);
    xor xor2 (sum, xor_ab, c_in);

    // c_out = (a AND b) OR ((a XOR b) AND c_in)
    and and1 (and_ab, a, b);
    and and2 (and_xor_cin, xor_ab, c_in);
    or or1 (c_out, and_ab, and_xor_cin);

endmodule

// Half Adder using primitives
module half_adder (
    input wire a,
    input wire b,
    output wire sum,
    output wire carry
);

    xor xor1 (sum, a, b);
    and and1 (carry, a, b);

endmodule

// 32-bit Carry-Save Adder using primitives
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

// Basic 2-input AND gate example
module and_gate_2 (
    input wire a,
    input wire b,
    output wire out
);
    and a1 (out, a, b);
endmodule

// Basic 2-input OR gate example
module or_gate_2 (
    input wire a,
    input wire b,
    output wire out
);
    or o1 (out, a, b);
endmodule

// Basic 2-input XOR gate example
module xor_gate_2 (
    input wire a,
    input wire b,
    output wire out
);
    xor x1 (out, a, b);
endmodule

// Basic NOT gate example
module not_gate (
    input wire a,
    output wire out
);
    not n1 (out, a);
endmodule

// 4-input AND gate using primitives
module and_gate_4 (
    input wire [3:0] in,
    output wire out
);
    wire and_01, and_23;

    and a1 (and_01, in[0], in[1]);
    and a2 (and_23, in[2], in[3]);
    and a3 (out, and_01, and_23);
endmodule

// Example: Using primitives directly in partial product generation
module partial_product_gen (
    input wire [15:0] a,
    input wire b_bit,
    output wire [15:0] pp
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : pp_gen
            and pp_and (pp[i], a[i], b_bit);
        end
    endgenerate

endmodule