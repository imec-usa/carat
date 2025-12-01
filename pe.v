// Processing Element (PE) with 16-bit integer MAC
// Implements: accumulator = accumulator + (input_a * input_b)
// Output Stationary: partial sum stays in PE

module pe (
    input wire clk,
    input wire rst_n,
    input wire en,
    input wire [15:0] a_in,      // Input operand A
    input wire [15:0] b_in,      // Input operand B
    input wire [31:0] partial_sum_in,  // For loading initial value
    input wire load_acc,         // Load accumulator signal
    output reg [15:0] a_out,     // Passthrough for systolic flow
    output reg [15:0] b_out,     // Passthrough for systolic flow
    output wire [31:0] acc_out   // Accumulated result
);

    wire [31:0] mult_result;
    wire [31:0] add_result;
    reg [31:0] accumulator;

    // High-performance 16x16 bit multiplier
    multiplier_16bit mult_inst (
        .a(a_in),
        .b(b_in),
        .product(mult_result)
    );

    // High-performance 32-bit adder
    adder_32bit add_inst (
        .a(accumulator),
        .b(mult_result),
        .sum(add_result)
    );

    // Accumulator register with load capability
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accumulator <= 32'd0;
        end else if (load_acc) begin
            accumulator <= partial_sum_in;
        end else if (en) begin
            accumulator <= add_result;
        end
    end

    // Systolic passthrough registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_out <= 16'd0;
            b_out <= 16'd0;
        end else if (en) begin
            a_out <= a_in;
            b_out <= b_in;
        end
    end

    assign acc_out = accumulator;

endmodule
