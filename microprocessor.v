module microprocessor(instrucoes,enable,result,a,b);
input reg [1023:0][7:0]instrucoes;
input reg enable;
output reg [7:0]result;
output wire running;
output wire [7:0] a;
output wire [7:0] b;
integer file,code,t;
  reg [7:0] ar1, ar2;// ALU's first register,ALU's second register,
  reg [7:0] arr; //ALU's result register
  reg [5:0] operation_alu;//register used to select ALU's operation
  reg [7:0]reader;//register used to read the bytecode 
  reg [7:0] memoria[1023:0]; 
  reg enable_clk = 1;
  reg clk;
  reg busy;
  wire fusion_enable = enable & enable_clk;
  reg [7:0] line = 8'b0;
  alu ALU (
    .a(memoria[0]),
    .b(memoria[1]),
    .op(memoria[3]),
    .result(arr)
  );
  clock_gen CLOCK_GEN(.enable(fusion_enable),.clk(clk));

  initial begin
    memoria[6] = 8'b0;
    memoria[7] = 8'b0;
  end

  assign running = enable_clk;
  assign a = memoria[0];
  assign b = memoria[1];
  always@(posedge clk)begin
    if(line == 8'b11111111)begin
        assign enable_clk = 0;
        $finish;
    end else begin
        //$display("%b",busy);
        reader = instrucoes[line];
        case(reader)
            8'b00000010:
            begin
                line = line + 8'b1;
                memoria[3] = instrucoes[line];
                //$display("%b",memoria[3]);
                line = line + 8'b1;
                memoria[0] = instrucoes[line];
                //$display("%b",memoria[0]);
                line = line + 8'b1;
                memoria[1] = instrucoes[line];
                //$display("%b",memoria[1]);
                #2 memoria[2] = arr;
                result = memoria[2];
                //#5$display("%b",busy);
            end
            8'b11000010:
            begin
                line = line + 8'b1;
                memoria[4] = instrucoes[line];
                line = line + 8'b1;
                memoria[5] = instrucoes[line];
                memoria[memoria[4]] = memoria[5];
                result = memoria[memoria[4]];
            end
            8'b11100010:
            begin
                line = line + 8'b1;
                memoria[4] = instrucoes[line];
                line = line + 8'b1;
                memoria[5] = instrucoes[line];
                memoria[memoria[4]] = memoria[memoria[5]];
                result = memoria[memoria[4]];
            end
            8'b00000001:
            begin
                line = line + 8'b1;
                memoria[3] = instrucoes[line];
                line = line + 8'b1;
                memoria[0] = instrucoes[line];
                memoria[2] = arr;
                result = memoria[2];
            end
            8'b10000001:
            begin
                line = line + 8'b1;
                memoria[4] = instrucoes[line];
                memoria[5] = memoria[4];
                if(memoria[4] != 8'b00000010)begin
                  #5$display("%d",memoria[memoria[4]]);
                end else begin
                  #5$display("%d",arr);
                end
            end
            8'b10101010:
            begin
                line = line + 8'b1;
                memoria[6] = instrucoes[line]-8'b1;
                memoria[7] = line;
                line = memoria[6];
            end
            8'b01010101:
            begin
              if(memoria[7] != 8'b0)begin
                line = memoria[7];
                memoria[7] = 8'b0;
              end
            end
            8'b11111111:
            begin
                line = 8'b11111110;
            end
        endcase
        line = line + 8'b1;

        end
    end
endmodule