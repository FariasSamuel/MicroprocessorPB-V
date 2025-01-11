module testbench;
  integer file,code,t;
  reg [7:0] a, b,l;
  reg [5:0] op;
  wire [15:0] result;
  // Instantiate the ALU module
  alu ALU (
    .a(a),
    .b(b),
    .op(op),
    .result(result)
  );

  // Test sequence
  initial begin
    file = $fopen("note.txt", "r");
    if (file) begin
      while (!$feof(file)) begin
        code = $fscanf(file, "%b", l);
        if(l == 8'b00000000)begin // add
          op =32'b00;
          code = $fscanf(file, "%b", a);
          
          code = $fscanf(file, "%b", b);
          
        end
        if(l == 8'b00000010)begin
          op = 4'b0010;
          code = $fscanf(file, "%b", a);
          
          code = $fscanf(file, "%b", b);
          
        end
        if(l == 8'b00000001)begin
          op = 4'b0001;
          code = $fscanf(file, "%b", a);
          
          code = $fscanf(file, "%b", b);
          
        end
        if(l == 8'b00000011)begin
          op = 4'b0011;
          code = $fscanf(file, "%b", a);
          
          code = $fscanf(file, "%b", b);
          
        end

        if(l == 8'b00000100)begin
          op = 4'b0100;
          code = $fscanf(file, "%b", a);
          
          code = $fscanf(file, "%b", b);
          
        end
        
        if(l == 8'b00001000)begin
          op = 4'b1000;
          code = $fscanf(file, "%b", a);
          
          code = $fscanf(file, "%b", b);
          
        end

        #5
        $display("%d, %d, %d, %d,",result,l,a,b);
      end
    end
  end
endmodule

