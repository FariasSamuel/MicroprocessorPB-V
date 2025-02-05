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

/*
    SOMA: A lógica do somador por look ahead carry (lac)
          se baseia no cálculo paralelo dos sinais de 
          propagação (p) e geração de carry (g) para determinar 
          quais bits podem gerar ou propagar um carry. Esses 
          sinais são combinados em grupos hierárquicos para 
          calcular os carries de forma simultânea, evitando a 
          propagação sequencial típica dos somadores convencionais.
*/
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

/*
    SUBTRAÇÃO: a subtração aqui é tratada como uma
               adição com o inverso aditivo, calculado
               por meio de complemento de dois.
*/
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

/*
MULTIPLICAÇÃO: a multiplicação é feita de maneira análoga ao
               algoritmo "à mão": são calculados os produtos
               entre o primeiro fator e as máscaras referentes
               a cada bit do segundo fator, após isso é feito
               o deslocamento de cada produto parcial para a
               sua posição adequada no número, e por fim a
               soma desses produtos parciais devidamente 
               posicionados nos dá o valor da multiplicação.
*/
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


//DIVISÃO NÃO FUNCIONA
module div_restoring (a, b, start, clk, clrn, q, r, busy, ready, count);
  input [31:0] a;   
  input [15:0] b;   
  input start;      
  input clk, clrn;  
  output [31:0] q;  
  output [15:0] r;  
  output reg busy;  
  output reg ready; 
  output reg [4:0] count; 

  reg [31:0] reg_q;
  reg [15:0] reg_r;
  reg [15:0] reg_b;

  wire [16:0] sub_out = {reg_r, reg_q[31]} - {1'b0, reg_b}; // subtraction
  wire [15:0] mux_out = sub_out[16] ? {reg_r[14:0], reg_q[31]} : sub_out[15:0];

  assign q = reg_q;
  assign r = reg_r;
 

  always @(posedge clk or negedge clrn) begin
     
    if (!clrn) begin
      busy <= 0;
      ready <= 0;
      reg_q <= 0;
      reg_r <= 0;
      reg_b <= 0;
      count <= 0;
    end else begin
      if (start) begin
        $display("inicio");
        reg_q <= a;     
        reg_b <= b;     
        reg_r <= 0;
        busy <= 1;
        ready <= 0;
        count <= 0;
      end else if (busy) begin
        reg_q <= {reg_q[30:0], ~sub_out[16]};
        reg_r <= mux_out; 
        count <= count + 5'b1;
        if (count == 5'b11111) begin 
          $display("%d",reg_q);
          busy <= 0;
          ready <= 1; // q, r ready
        end
      end
    end
  end
endmodule


/*
COMPARADOR: Determina o resultado da comparação 
            por meio da diferença entre as entradas
*/
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