`include "ALUcomponents.v"
`include "microprocessor.v"
`include "clock.v"

module alu(
  input [7:0] a, b, 
  input [7:0] op, 
  output reg [7:0] result
);

  wire g_out, p_out;
  reg cin;
  wire [7:0] addresult;
  wire [7:0] subresult;
  wire [1:0] comresult;
  wire [7:0] mulresult;

  assign cin = 0;
  
  // Instanciar os módulos auxiliares
  sub SUB (
    .a(a),
    .b(b),
    .result(subresult)
  );

  lac_8 EIGHT_ADDER (
    .a(a),
    .b(b),
    .cin(cin),
    .g_out(g_out),
    .p_out(p_out),
    .s(addresult)
  );

  multiplier MULTIPLIER (
    .a(a),
    .b(b),
    .result(mulresult)
  );

  compare COMPARE (
    .a(a),
    .b(b),
    .op(op),
    .result(comresult)
  );


  // Lógica combinacional para a ALU
  always @(*) begin
    result = 8'b0;
    //$display("op:%b",op);
    case (op)
      8'b00000000: result = addresult;  // Soma
      8'b00000001: result = subresult; // Subtração
      8'b00000010: result = mulresult; // Multiplicação
      8'b00000011: result = a/b; // Divisão (8 bits do quociente)
      8'b00010011: result = a%b;
      8'b00000100: result[1:0] = comresult;
      8'b00000101: result[1:0] = comresult;
      8'b00000110: result[1:0] = comresult; 
      8'b00001000: result = ~a;             // NOT bit a bit
      8'b00001001: result = a & b;          // AND bit a bit
      8'b00001010: result = a | b;          // OR bit a bit
      8'b00001011: result = a ^ b;          // XOR bit a bit
      8'b00010000: result = a << b;         // Deslocamento à esquerda
      8'b00010001: result = a >> b;         // Deslocamento à direita
    endcase
  end

endmodule
