module testbench;
  integer file,code;
  integer i = 0;
  reg [1023:0] [7:0]memory;
  reg [7:0] t;
  reg [7:0] result;
  reg [7:0] a,b;
  reg enable;
  reg running;
  // Instantiate the ALU module
  microprocessor MICROPROCESSOR(memory,enable,result,a,b);

  // Test sequence
  initial begin
    enable = 0;
    file = $fopen("bytecode.bin", "r");
    if (file) begin
      while (!$feof(file)) begin
        code = $fscanf(file, "%b", t);
        memory[i] = t;
        i = i +1;
      end
    end
    memory[i] = 8'b11111111;
    #5enable = 1;
    #1000 $finish;
  end
endmodule

