module testbench;
  integer file,code;
  integer i = 0;
  reg [1023:0][7:0] memory;
  reg [7:0] t;
  reg [7:0] result;
  reg enable;
  reg running;
  // Instantiate the ALU module
  microprocessor MICROPROCESSOR(memory,enable,result,running);

  // Test sequence
  initial begin
    enable = 0;
    file = $fopen("note.txt", "r");
    if (file) begin
      while (!$feof(file)) begin
        code = $fscanf(file, "%b", t);
        memory[i] = t;
        i = i +1;
      end
    end
    memory[i] = 8'b11111111;
    #5enable = 1;
    $monitor("%b %d",result, running);
  end
endmodule

