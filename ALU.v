module half_adder(output cout,sum,input a,b);
  xor (sum,a,b);
  and (cout,a,b);
endmodule
module full_adder(output wire sum, cout, input wire a, b, cin);
  wire suma1, couta1, couta2;
  half_adder u1 (.sum(suma1), .cout(couta1), .a(a), .b(b));
  half_adder u2(.sum(sum),.cout(couta2), .a(suma1), .b(cin)); 
  or u3(cout, couta1, couta2);
endmodule
module four_adder(input [3:0] a,b,input cin,output cout,output [3:0] sum);
  wire [2:0] c;
  full_adder a1(.sum(sum[0]),.cout(c[0]),.a(a[0]),.b(b[0]),.cin(cin));
  full_adder a2(.sum(sum[1]),.cout(c[1]),.a(a[1]),.b(b[1]),.cin(c[0]));
  full_adder a3(.sum(sum[2]),.cout(c[2]),.a(a[2]),.b(b[2]),.cin(c[1]));
  full_adder a4(.sum(sum[3]),.cout(cout),.a(a[3]),.b(b[3]),.cin(c[2]));
endmodule
module eight_adder(input [7:0] a,b,input cin,output cout,output [7:0] sum);
  wire c;
  four_adder f1(.sum(sum[3:0]),.cout(c),.a(a[3:0]),.b(b[3:0]),.cin(cin));
  four_adder f2(.sum(sum[7:4]),.cout(cout),.a(a[7:4]),.b(b[7:4]),.cin(c));
endmodule
module twos_complement(input [7:0] a,output [7:0] a2);
  wire[7:0] negated;
  wire g_out,p_out;
  wire cin;
  assign cin = 0;
  wire [7:0] b;
  assign b = 8'b00000001;
  genvar i;
  generate
    for(i=0; i < 8; i = i+ 1) begin
      not(negated[i],a[i]);
    end
  endgenerate
  lac_8 EIGHT_ADDER (
    .a(negated),
    .b(b),
    .cin(cin),
    .g_out(g_out),
    .p_out(p_out),
    .s(a2)
  );
endmodule
module sub(input [7:0] a,input [7:0] b,output [7:0] result);
  wire[7:0] complement;
  twos_complement tc(.a(b),.a2(complement));
  wire cout;
  wire cin;
  assign cin = 0;
  wire g_out,p_out;
  lac_8 EIGHT_ADDER (
    .a(a),
    .b(complement),
    .cin(cin),
    .g_out(g_out),
    .p_out(p_out),
    .s(result)
  );
endmodule

module add(a,b,c,g,p,s);
  input a,b,c;
  output g,p,s;
  assign s = a ^ b ^ c;
  assign g = a & b;
  assign p = a | b;
endmodule

module gp(g,p,c_in,g_out,p_out,c_out);
  input [1:0] g,p;
  input c_in;
  output g_out,p_out,c_out;
  assign g_out = g[1] | p[1] & g[0];
  assign p_out = p[1] & p[0];
  assign c_out = g[0] | p[0] & c_in;
endmodule

module lac_2(a,b,cin,g_out,p_out,s);
  input [1:0] a,b;
  input cin;
  output g_out,p_out;
  output [1:0] s;
  wire [1:0] g,p;
  wire cout;
  add a0(a[0],b[0],cin,g[0],p[0],s[0]);
  add a1(a[1],b[1],cout,g[1],p[1],s[1]);
  gp gp0(g,p,cin,g_out,p_out,cout);
endmodule

module lac_4(a,b,cin,g_out,p_out,s);
  input [3:0] a,b;
  input cin;
  output g_out,p_out;
  output [3:0] s;
  wire [1:0] g,p;
  wire cout;
  lac_2 l1(a[1:0],b[1:0],cin,g[0],p[0],s[1:0]);
  lac_2 l2(a[3:2],b[3:2],cout,g[1],p[1],s[3:2]);
  gp gp1(g,p,cin,g_out,p_out,cout);
endmodule

module lac_8(a,b,cin,g_out,p_out,s);
  input [7:0] a,b;
  input cin;
  output g_out,p_out;
  output [7:0] s;
  wire [1:0] g,p;
  wire cout;
  lac_4 l1(a[3:0],b[3:0],cin,g[0],p[0],s[3:0]);
  lac_4 l2(a[7:4],b[7:4],cout,g[1],p[1],s[7:4]);
  gp gp1(g,p,cin,g_out,p_out,cout);
endmodule

module multiplier(a,b,result);
  input [7:0] a,b;
  output [7:0] result;
  wire[7:0] ab0 = a & {8{b[0]}};
  wire[7:0] ab1 = a & {8{b[1]}};
  wire[7:0] ab2 = a & {8{b[2]}};
  wire[7:0] ab3 = a & {8{b[3]}};
  wire[7:0] ab4 = a & {8{b[4]}};
  wire[7:0] ab5 = a & {8{b[5]}}; 
  wire[7:0] ab6 = a & {8{b[6]}};
  wire[7:0] ab7 = a & {8{b[7]}};
  assign result = (({8'b1,~ab0[7], ab0[6:0]} + 
              {7'b0,~ab1[7], ab1[6:0],1'b0}) +
              ({6'b0,~ab2[7], ab2[6:0],2'b0} + 
              {5'b0,~ab3[7], ab3[6:0],3'b0})) + 
              (({4'b0,~ab4[7], ab4[6:0],4'b0} + 
              {3'b0,~ab5[7], ab5[6:0],5'b0}) + 
              ({2'b0,~ab6[7], ab6[6:0],6'b0} +
              {1'b1, ab7[7],~ab7[6:0],7'b0}));
endmodule

module div_restoring_debug(
  input [7:0] a, 
  input [7:0] b, 
  output reg [7:0] result
);
  reg [15:0] remainder;
  reg [7:0] quotient;
  integer i;

  always @(*) begin
    remainder = 16'd0;
    quotient = 8'd0;

    for (i = 7; i >= 0; i = i - 1) begin
      remainder = {remainder[14:0], a[i]}; // Shift left and bring in next bit of dividend

      if (remainder[15:8] >= b) begin
        remainder[15:8] = remainder[15:8] - b;
        quotient[i] = 1;
      end else begin
        quotient[i] = 0;
      end
    end

    result = quotient;
  end
endmodule


module div_restoring(
  input clk,
  input reset,
  input start,
  input [7:0] a,      // Dividend
  input [7:0] b,      // Divisor
  output reg [7:0] result, // Quotient
  output reg done    // Indicates when division is complete
);
  reg [15:0] remainder;
  reg [7:0] quotient;
  reg [3:0] count;   // Keeps track of the current iteration (0 to 7)
  reg running;       // Indicates if division is in progress

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      remainder <= 16'd0;
      quotient <= 8'd0;
      result <= 8'd0;
      count <= 4'd0;
      done <= 0;
      running <= 0;
    end else if (start && !running) begin
      // Initialize division
      remainder <= 16'd0;
      quotient <= 8'd0;
      count <= 4'd7;
      done <= 0;
      running <= 1;
    end else if (running) begin
      // Perform one iteration of restoring division
      remainder <= {remainder[14:0], a[count]};
      if (remainder[15:8] >= b) begin
        remainder[15:8] <= remainder[15:8] - b;
        quotient[count] <= 1;
      end else begin
        quotient[count] <= 0;
      end

      if (count == 0) begin
        result <= quotient;
        done <= 1;
        running <= 0;  // Stop after all bits processed
      end else begin
        count <= count - 1;  // Move to the next bit
      end
    end
  end
endmodule




module compare(a,b,result);
  input [7:0] a,b;
  output reg [1:0] result;
  
  wire [7:0] dif;

  sub SUB(.a(a),.b(b),.result(dif));
  always @(*)begin
    if(dif == 8'b0)begin
    result = 2'b00;
    end else if(dif[7])begin
      result = 2'b01;
    end else begin
      result = 2'b10;
    end
  end
endmodule;