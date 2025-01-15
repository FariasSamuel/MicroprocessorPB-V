module microprocessor(memory,enable,result,a,b);
input reg [1023:0][7:0]memory;
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
  wire fusion_enable = enable & enable_clk;
  integer line = 0;
  alu ALU (
    .a(ar1),
    .b(ar2),
    .op(operation_alu),
    .result(arr)
  );
  clock_gen CLOCK_GEN(.enable(fusion_enable),.clk(clk));

  assign running = enable_clk;
  assign a = ar1;
  assign b = ar2;
  always@(posedge clk)begin
    if(line == -1)begin
        assign enable_clk = 0;
        $finish;
    end else begin
        reader = memory[line];
        case(reader)
            8'b00000010:
            begin
                line = line + 1;
                operation_alu = memory[line];
                line = line + 1;
                ar1 = memory[line];
                line = line + 1;
                ar2 = memory[line];
                result = arr;
            end
            8'b11000010:
            begin
                line = line + 1;
                ar1 = memory[line];
                line = line + 1;
                ar2 = memory[line];
                memoria[ar1] = ar2;
               
                result = memoria[ar1];
            end
            8'b00000001:
            begin
                line = line + 1;
                operation_alu = memory[line];
                line = line + 1;
                ar1 = memory[line];
                result = arr;
            end
            8'b10000001:
            begin
                line = line + 1;
                ar1 = memory[line];
                ar2 = ar1;
                result = memoria[ar1];
            end
            8'b11111111:
            begin
                line = -2;
            end
        endcase
        line = line + 1;
    end
  end
endmodule