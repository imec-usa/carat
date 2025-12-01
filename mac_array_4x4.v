// 4x4 MAC Array with Output Stationary Dataflow
// Each PE accumulates its result locally

module mac_array_4x4 (
    input wire clk,
    input wire rst_n,
    input wire en,
    input wire load_acc,
    
    // Input matrix A (fed from left, flows right)
    input wire [15:0] a_in_0,
    input wire [15:0] a_in_1,
    input wire [15:0] a_in_2,
    input wire [15:0] a_in_3,
    
    // Input matrix B (fed from top, flows down)
    input wire [15:0] b_in_0,
    input wire [15:0] b_in_1,
    input wire [15:0] b_in_2,
    input wire [15:0] b_in_3,
    
    // Partial sum inputs for initialization
    input wire [31:0] partial_sum_init [0:3][0:3],
    
    // Output accumulated results from all PEs
    output wire [31:0] result_0_0, result_0_1, result_0_2, result_0_3,
    output wire [31:0] result_1_0, result_1_1, result_1_2, result_1_3,
    output wire [31:0] result_2_0, result_2_1, result_2_2, result_2_3,
    output wire [31:0] result_3_0, result_3_1, result_3_2, result_3_3
);

    // Internal interconnect wires for systolic flow
    wire [15:0] a_wire [0:3][0:4];  // Horizontal A data flow
    wire [15:0] b_wire [0:4][0:3];  // Vertical B data flow
    
    // Connect inputs to array edges
    assign a_wire[0][0] = a_in_0;
    assign a_wire[1][0] = a_in_1;
    assign a_wire[2][0] = a_in_2;
    assign a_wire[3][0] = a_in_3;
    
    assign b_wire[0][0] = b_in_0;
    assign b_wire[0][1] = b_in_1;
    assign b_wire[0][2] = b_in_2;
    assign b_wire[0][3] = b_in_3;

    // Accumulator outputs
    wire [31:0] acc_out [0:3][0:3];

    // Instantiate 4x4 PE array
    genvar row, col;
    generate
        for (row = 0; row < 4; row = row + 1) begin : pe_row
            for (col = 0; col < 4; col = col + 1) begin : pe_col
                pe pe_inst (
                    .clk(clk),
                    .rst_n(rst_n),
                    .en(en),
                    .a_in(a_wire[row][col]),
                    .b_in(b_wire[row][col]),
                    .partial_sum_in(partial_sum_init[row][col]),
                    .load_acc(load_acc),
                    .a_out(a_wire[row][col+1]),
                    .b_out(b_wire[row+1][col]),
                    .acc_out(acc_out[row][col])
                );
            end
        end
    endgenerate

    // Connect outputs
    assign result_0_0 = acc_out[0][0];
    assign result_0_1 = acc_out[0][1];
    assign result_0_2 = acc_out[0][2];
    assign result_0_3 = acc_out[0][3];
    
    assign result_1_0 = acc_out[1][0];
    assign result_1_1 = acc_out[1][1];
    assign result_1_2 = acc_out[1][2];
    assign result_1_3 = acc_out[1][3];
    
    assign result_2_0 = acc_out[2][0];
    assign result_2_1 = acc_out[2][1];
    assign result_2_2 = acc_out[2][2];
    assign result_2_3 = acc_out[2][3];
    
    assign result_3_0 = acc_out[3][0];
    assign result_3_1 = acc_out[3][1];
    assign result_3_2 = acc_out[3][2];
    assign result_3_3 = acc_out[3][3];

endmodule
