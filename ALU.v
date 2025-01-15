`include "ALUcomponents.v"
`include "microprocessor.v"
`include "clock.v"
module alu(
  input reg [7:0] a, b, 
  input reg [5:0] op, 
  output reg [7:0] result
);

  wire g_out, p_out;
  reg cin;
  wire [7:0] addresult;
  wire [7:0] subresult;
  wire [7:0] divresult;

  wire [1:0] comresult;
  wire [7:0] mulresult;
  assign cin = 0;
  integer i;
  // Instantiate the 8-bit suber

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
    .a(a),
    .b(b),
    .result(divresult)
  );

  compare COMPARE (
    .a(a),
    .b(b),
    .result(comresult)
  );

  always @(*) begin
    result <= 16'b0;
    if(op == 6'b000000) begin  
      result[7:0] <= addresult;  
    end
    if(op == 6'b000001) begin  
      result[7:0] <= subresult;  
    end
    if(op == 6'b000010) begin  
      result <=mulresult;  
    end
    if(op == 6'b000011) begin  
      result <=divresult;  
    end
    if(op == 6'b000100) begin  
      result[1:0] <=comresult;  
    end
    if(op == 6'b001000) begin  
      for(i = 0; i < 8; i++)begin
        result[i] <= ~a[i];
      end
    end
    if(op == 6'b001001) begin  
      for(i = 0; i < 8; i++)begin
        result[i] <= a[i]&b[i];
      end
    end
    if(op == 6'b001010) begin  
      for(i = 0; i < 8; i++)begin
        result[i] <= a[i]|b[i];
      end 
    end
    if(op == 6'b001011) begin  
      for(i = 0; i < 8; i++)begin
        result[i] <= a[i]^b[i];
      end
    end
    if(op == 6'b010000) begin  
      for(i = 0; i < 8-b; i++)begin
        result[i+b] <= a[i];
      end
    end
    if(op == 6'b010001) begin  
      for(i = b; i < 8; i++)begin
        result[i-b] <= a[i];
      end
    end

  end

endmodule


