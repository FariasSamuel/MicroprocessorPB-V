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
  reg busy;
  wire fusion_enable = enable & enable_clk;
  integer line = 0;
  alu ALU (
    .a(memoria[0]),
    .b(memoria[1]),
    .op(operation_alu),
    .clk(clk),
    .result(arr),
    .busy(busy)
  );
  clock_gen CLOCK_GEN(.enable(fusion_enable),.clk(clk));

  assign running = enable_clk;
  assign a = memoria[0];
  assign b = memoria[1];
  always@(posedge clk)begin
    if(line == -1)begin
        assign enable_clk = 0;
        $finish;
    end else begin
        $display("%b",busy);
        if(!busy)begin
        reader = memory[line];
        case(reader)
            8'b00000010:
            begin
                line = line + 1;
                operation_alu = memory[line];
                //$display("%b",operation_alu);
                line = line + 1;
                memoria[0] = memory[line];
                //$display("%b",memoria[0]);
                line = line + 1;
                memoria[1] = memory[line];
                //$display("%b",memoria[1]);
                memoria[2] = arr;
                result = memoria[2];
                //#5$display("%b",busy);
            end
            8'b11000010:
            begin
                line = line + 1;
                memoria[0] = memory[line];
                line = line + 1;
                memoria[1] = memory[line];
                memoria[memoria[0]] = memoria[1];
                result = memoria[memoria[0]];
            end
            8'b00000001:
            begin
                line = line + 1;
                operation_alu = memory[line];
                line = line + 1;
                memoria[0] = memory[line];
                memoria[2] = arr;
                result = memoria[2];
            end
            8'b10000001:
            begin
                line = line + 1;
                memoria[0] = memory[line];
                memoria[1] = memoria[0];
                result = memoria[memoria[0]];
            end
            8'b11111111:
            begin
                line = -2;
            end
        endcase
        #1$display("%b %b %b %b",result,operation_alu,a,b);
        line = line + 1;
        end
    end
  end
endmodule