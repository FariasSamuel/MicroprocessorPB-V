module half_adder(output cout,sum,input a,b) ;
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
module twos_complement(input [3:0] a,output [3:0] a2);
  wire[3:0] negated;
  wire cout;
  wire cin;
  assign cin = 0;
  wire [3:0] b;
  assign b = 4'b0001;
  genvar i;
  generate
    for(i=0; i < 4; i = i+ 1) begin
      not(negated[i],a[i]);
    end
  endgenerate
  four_adder a5(.sum(a2),.cout(cout), .a(negated), .b(b), .cin(cin));
endmodule
module sub(input [3:0] a,input [3:0] b,output [3:0] result);
  wire[3:0] complement;
  twos_complement tc(.a(b),.a2(complement));
  wire cout;
  wire cin;
  assign cin = 0;
  four_adder a5(.sum(result),.cout(cout), .a(a), .b(complement), .cin(cin));
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
  output [15:0] result;
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

module div_restoring (a,b,start,clk,clrn,q,r,busy,ready,count);
  input [7:0] a;
  input [3:0] b;

  input start;
  input clk,clrn;
  output [7:0] q;
  output [4:0] r;
  output reg busy; 
  output reg ready;
  output [4:0] count; 
  reg [7:0] reg_q;
  reg [4:0] reg_r;
  reg [4:0] reg_b;
  reg [2:0] count;
endmodule