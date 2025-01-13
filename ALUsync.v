`include "ALUcomponents.v"

module alu(
  input [7:0] a,
  input [7:0] b,
  input [5:0] op,
  input clk,
  input reset,
  input alu_start,
  output reg [15:0] result,
  output reg alu_done
);

  wire [7:0] sum_result, sub_result, mul_result, div_result;
  wire [1:0] cmp_result;
  wire [7:0] and_result, or_result, xor_result, not_result;

  // Instantiate addition module
  eight_adder ADD (
    .a(a),
    .b(b),
    .cin(1'b0),
    .cout(),
    .sum(sum_result)
  );

  // Instantiate subtraction module
  sub SUB (
    .a(a),
    .b(b),
    .result(sub_result)
  );

  // Instantiate multiplication module
  multiplier MUL (
    .a(a),
    .b(b),
    .result(mul_result)
  );

  // Instantiate division module
  div_restoring DIV (
    .a(a),
    .b(b),
    .result(div_result)
  );

  // Instantiate comparison module
  compare CMP (
    .a(a),
    .b(b),
    .result(cmp_result)
  );

  // Bitwise operations
  
 
  assign and_result = a & b;
  assign or_result = a | b;
  assign xor_result = a ^ b;

  // NOT operation
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin
      not(not_result[i], a[i]);
    end
  endgenerate

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      result <= 0;
      alu_done <= 0;
    end else if (alu_start) begin
      alu_done <= 0;
      case (op)
        6'b000000: result <= sum_result;
        6'b000001: result <= sub_result;
        6'b000010: result <= mul_result;
        6'b000011: result <= div_result;
        6'b000100: result <= and_result;
        6'b000101: result <= {8'b0, or_result};
        6'b000110: result <= {8'b0, xor_result};
        6'b000111: result <= {8'b0, not_result};
        6'b001000: result <= {14'b0, cmp_result};
        default: result <= 16'b0;
      endcase
      alu_done <= 1;
    end else begin
      alu_done <= 0;
    end
  end

endmodule
