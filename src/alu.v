module ALU (
    input [31:0] in1, in2,
    input zero,
    output [31:0] alu_result,
    output [31:0] alu_op,
    input clk
);

and(alu_result, in1, in2);

endmodule