// 32-bit Carry-Lookahead Adder (CLA)
// High-performance adder using gate-level logic

// Basic logic gates





module adder_32bit (
    input wire [31:0] a,
    input wire [31:0] b,
    output wire [31:0] sum
);

    wire [31:0] p, g;  // Propagate and generate
    wire [32:0] c;     // Carry chain

    assign c[0] = 1'b0;

    // Generate propagate and generate signals
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : pg_gen
            xor_gate xor_p (.a(a[i]), .b(b[i]), .out(p[i]));
            and_gate and_g (.a(a[i]), .b(b[i]), .out(g[i]));
        end
    endgenerate

    // 4-bit CLA blocks
    wire [7:0] block_p, block_g;
    wire [8:0] block_c;

    assign block_c[0] = c[0];

    generate
        for (i = 0; i < 8; i = i + 1) begin : cla_blocks
            cla_4bit cla_inst (
                .p(p[i*4+3:i*4]),
                .g(g[i*4+3:i*4]),
                .c_in(block_c[i]),
                .c_out(c[i*4+4:i*4+1]),
                .block_p(block_p[i]),
                .block_g(block_g[i])
            );
        end
    endgenerate

    // Second level CLA for block carries
    cla_block_8 block_cla (
        .p(block_p),
        .g(block_g),
        .c_in(block_c[0]),
        .c_out(block_c[8:1])
    );

    // Generate final sum
    generate
        for (i = 0; i < 32; i = i + 1) begin : sum_gen
            xor_gate xor_sum (.a(p[i]), .b(c[i]), .out(sum[i]));
        end
    endgenerate

endmodule

// 4-bit CLA block
module cla_4bit (
    input wire [3:0] p,
    input wire [3:0] g,
    input wire c_in,
    output wire [4:1] c_out,
    output wire block_p,
    output wire block_g
);

    wire [3:0] c;
    assign c[0] = c_in;

    // Carry generation logic
    wire g0, g1, g2;
    wire p0_c0, p1_c1, p2_c2;

    and_gate a1 (.a(p[0]), .b(c[0]), .out(p0_c0));
    or_gate o1 (.a(g[0]), .b(p0_c0), .out(c[1]));

    and_gate a2 (.a(p[1]), .b(c[1]), .out(p1_c1));
    or_gate o2 (.a(g[1]), .b(p1_c1), .out(c[2]));

    and_gate a3 (.a(p[2]), .b(c[2]), .out(p2_c2));
    or_gate o3 (.a(g[2]), .b(p2_c2), .out(c[3]));

    wire p3_c3;
    and_gate a4 (.a(p[3]), .b(c[3]), .out(p3_c3));
    or_gate o4 (.a(g[3]), .b(p3_c3), .out(c_out[4]));

    assign c_out[3:1] = c[3:1];

    // Block propagate and generate
    wire p01, p012, p0123;
    and_gate ap1 (.a(p[0]), .b(p[1]), .out(p01));
    and_gate ap2 (.a(p01), .b(p[2]), .out(p012));
    and_gate ap3 (.a(p012), .b(p[3]), .out(block_p));

    // block_g = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0])
    wire p3_g2, p32, p3_p2_g1, p321, p3_p2_p1_g0;
    wire bg1, bg2, bg3;

    and_gate bg_a1 (.a(p[3]), .b(g[2]), .out(p3_g2));
    and_gate bg_a2 (.a(p[3]), .b(p[2]), .out(p32));
    and_gate bg_a3 (.a(p32), .b(g[1]), .out(p3_p2_g1));
    and_gate bg_a4 (.a(p32), .b(p[1]), .out(p321));
    and_gate bg_a5 (.a(p321), .b(g[0]), .out(p3_p2_p1_g0));

    or_gate bg_o1 (.a(g[3]), .b(p3_g2), .out(bg1));
    or_gate bg_o2 (.a(bg1), .b(p3_p2_g1), .out(bg2));
    or_gate bg_o3 (.a(bg2), .b(p3_p2_p1_g0), .out(block_g));

endmodule

// 8-block CLA for second level
module cla_block_8 (
    input wire [7:0] p,
    input wire [7:0] g,
    input wire c_in,
    output wire [8:1] c_out
);

    wire [8:0] c;
    assign c[0] = c_in;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : carry_chain
            wire p_c;
            and_gate a (.a(p[i]), .b(c[i]), .out(p_c));
            or_gate o (.a(g[i]), .b(p_c), .out(c[i+1]));
        end
    endgenerate

    assign c_out = c[8:1];

endmodule

