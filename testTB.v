`timescale 1ns / 1ps
module testTB () ;
  reg [7:0] a , b;
  reg cin;
  wire [7:0] sum;
  wire cout;
  wire [7:0] neg;
  wire [7:0] result;
  wire g_out,p_out;
  wire [15:0] c;
  eight_adder EIGHT_ADDER(.sum(sum),.cout(cout), .a(a), .b(b), .cin(cin));
  lac_8 CLA_8(.a(a),.b(b),.cin(cin),.g_out(g_out),.p_out(p_out),.s(result));
  multiplier MULTIPLIER(a,b,c);
  //twos_complement TWOS_COMPLEMENT(.a(a),.a2(neg));
  //sub SUB(.a(a),.b(b),.result(result));
  initial begin
	$dumpfile("testTB.vcd");
	$dumpvars(0,testTB);
    $monitor("a=%b,b=%b,cin=%b,cout=%b,c=%b",a,b,cin,cout,c);
	a = 8'b00001010;b = 8'b00000111;cin = 0;#10
	a = 8'b00000001;b = 8'b00000101;cin = 0;#10
	a = 8'b00000010;b = 8'b00001001;cin = 0;#10
	a = 8'b00000011;b = 8'b00000110;cin = 0;#10
	a = 8'b00000100;b = 8'b00001101;cin = 0;#10
	a = 8'b00000101;b = 8'b00001111;cin = 0;#10
	a = 8'b00000110;b = 8'b00000000;cin = 0;#10
	$finish;
  end
endmodule

