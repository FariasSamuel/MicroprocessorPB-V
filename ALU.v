`include "ALUcomponents.v"
`include "microprocessor.v"
`include "clock.v"

module alu(
  input [7:0] a, b, 
  input [5:0] op, 
  input wire clk,
  output reg [7:0] result,
  output reg busy
);

  wire g_out, p_out;
  reg cin;
  reg divstart;
  reg clrn;
  wire [7:0] addresult;
  wire [7:0] subresult;
  wire [31:0] divresult;
  wire [1:0] comresult;
  wire [7:0] mulresult;
  reg [7:0] diva,divb;

  reg [4:0] count;
  reg divbusy, ready;

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

  div_restoring DIVISOR (
    .a({24'b0, diva}),
    .b({8'b0, divb}),
    .start(divstart),
    .clk(clk),
    .clrn(clrn),
    .q(divresult),
    .busy(divbusy),
    .ready(ready),
    .count(count)
  );

  compare COMPARE (
    .a(a),
    .b(b),
    .result(comresult)
  );

  initial begin
    clrn = 1;
    busy = 0;
  end

  // Controle síncrono de busy e divstart
  always @(posedge clk or negedge clrn) begin
    if (!clrn) begin
      divstart <= 0;
      busy <= 0;
      clrn <= 1;
    end else if (op == 6'b000011 && busy == 0) begin
      busy <= 1;
      diva <= a;
      divb <= b;
      divstart <= 1;
    end else if (ready) begin
      result <= divresult[7:0];
      #1$display("%b",divresult[7:0]);
      busy <= 0;
      clrn <= 0;
    end if (busy == 1) begin
      divstart <= 0;
    end 
  end

  // Lógica combinacional para a ALU
  always @(*) begin
    result = 8'b0;
    case (op)
      6'b000000: result = addresult;  // Soma
      6'b000001: result = subresult; // Subtração
      6'b000010: result = mulresult; // Multiplicação
      6'b000011: result = divresult[7:0]; // Divisão (8 bits do quociente)
      6'b000100: result[1:0] = comresult; // Comparação
      6'b001000: result = ~a;             // NOT bit a bit
      6'b001001: result = a & b;          // AND bit a bit
      6'b001010: result = a | b;          // OR bit a bit
      6'b001011: result = a ^ b;          // XOR bit a bit
      6'b010000: result = a << b;         // Deslocamento à esquerda
      6'b010001: result = a >> b;         // Deslocamento à direita
    endcase
  end

endmodule
