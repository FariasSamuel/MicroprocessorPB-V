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
  reg [7:0] add1, add2, addresult;
  reg [7:0] sub1, sub2, subresult;
  reg [7:0] mul1, mul2;
  reg [7:0] div1, div2,divresult;
  reg [7:0] com1, com2;
  reg [1:0] comresult;
  reg [7:0] mulresult;
  assign cin = 0;
  integer i;
  // Instantiate the 8-bit suber

  sub SUB (
    .a(sub1),
    .b(sub2),
    .result(subresult)
  );

  lac_8 EIGHT_ADDER (
    .a(add1),
    .b(add2),
    .cin(cin),
    .g_out(g_out),
    .p_out(p_out),
    .s(addresult)
  );

  multiplier MULTIPLIER (
    .a(mul1),
    .b(mul2),
    .result(mulresult)
  );

  div_restoring DIVISOR (
    .a(div1),
    .b(div2),
    .result(divresult)
  );

  compare COMPARE (
    .a(com1),
    .b(com2),
    .result(comresult)
  );

  always @(*) begin
    add1 = 8'b0;
    add2 = 8'b0;
    result = 8'b0; 

    if(op == 6'b000000) begin  
      add1 = a;
      add2 = b;
      result[7:0] = addresult;  
    end
    if(op == 6'b000001) begin  
      sub1 = a;
      sub2 = b;
      result[7:0] = subresult;  
    end
    if(op == 6'b000010) begin  
      mul1 = a;
      mul2 = b;
      result =mulresult;  
    end
    if(op == 6'b000011) begin  
      div1 = a;
      div2 = b;
      result =divresult;  
    end
    if(op == 6'b000100) begin  
      com1 = a;
      com2 = b;
      result[1:0] =comresult;  
    end
    if(op == 6'b001000) begin  
      for(i = 0; i < 8; i++)begin
        result[i] = ~a[i];
      end
    end
    if(op == 6'b001001) begin  
      for(i = 0; i < 8; i++)begin
        result[i] = a[i]&b[i];
      end
    end
    if(op == 6'b001010) begin  
      for(i = 0; i < 8; i++)begin
        result[i] = a[i]|b[i];
      end 
    end
    if(op == 6'b001011) begin  
      for(i = 0; i < 8; i++)begin
        result[i] = a[i]^b[i];
      end
    end
    if(op == 6'b010000) begin  
      for(i = 0; i < 8-b; i++)begin
        result[i+b] = a[i];
      end
    end
    if(op == 6'b010001) begin  
      for(i = b; i < 8; i++)begin
        result[i-b] = a[i];
      end
    end

  end

endmodule


