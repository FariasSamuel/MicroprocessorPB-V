`include "ALUcomponents.v"
`include "microprocessor.v"
`include "clock.v"

module alu(
  input [7:0] a, b, 
  input [7:0] op, 
  output reg [7:0] flags,
  output reg [7:0] result
);
  
  wire g_out, p_out;
  wire [7:0] addresult;
  wire [7:0] subresult;
  wire [1:0] comresult;
  wire [7:0] mulresult;

  

  sub SUB (
    .a(a),
    .b(b),
    .result(subresult)
  );

  lac_8 EIGHT_ADDER (
    .a(a),
    .b(b),
    .cin(flags[1]),
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
  

  always @(*) begin
    result = 8'b0;
    flags[0] = 0;
    flags[1] = 0;
    case (op)
      8'b00000000: result = addresult;  
      8'b00000001: result = subresult; 
      8'b00000010: result = mulresult; 
      8'b00000011: result = a/b; 
      8'b00010011: result = a%b;
      8'b00000100: result[1:0] = comresult;
      8'b00000101: result[1:0] = comresult;
      8'b00000110: result[1:0] = comresult; 
      8'b00001000: result = ~a;            
      8'b00001001: result = a & b;        
      8'b00001010: result = a | b;          
      8'b00001011: result = a ^ b;         
      8'b00010000: result = a << b;        
      8'b00010001: result = a >> b;         
    endcase
    flags[2] = result[7];
    flags[3] = 0;
    for(integer i = 0; i < 8; i+= 1)begin
      flags[3] += result[i];
    end
  end

endmodule
