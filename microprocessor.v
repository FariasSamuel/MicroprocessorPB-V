module microprocessor(instrucoes,enable);
  input reg [7:0] instrucoes[1023:0];
  input reg enable;

  reg [7:0]reader;
  reg [7:0] line = 8'b0;
  reg [7:0] memoria[1023:0]; 

  reg [7:0] arr,flags;

  reg enable_clk = 1;
  reg start = 0;
  reg clk;
  wire fusion_enable = enable & enable_clk;

  alu ALU (
  .a(memoria[0]),
  .b(memoria[1]),
  .op(memoria[3]),
  .flags(flags),
  .result(arr)
  );

  clock_gen CLOCK_GEN(.enable(fusion_enable),.clk(clk));

  initial begin
    memoria[6] = 8'b0;
    memoria[7] = 8'b0;
  end

  always@(posedge clk)begin
    if(line == 8'b11111111)begin
      assign enable_clk = 0;
      $finish;
    end else begin
      reader = instrucoes[line];
      if(start)begin
        case(reader)
          8'b00000010:
          begin
            line = line + 8'b1;
            memoria[3] = instrucoes[line];
            line = line + 8'b1;
            memoria[0] = instrucoes[line];
            line = line + 8'b1;
            memoria[1] = instrucoes[line];
            #2 memoria[2] = arr;
          end
          8'b11000010:
          begin
            line = line + 8'b1;
            memoria[4] = instrucoes[line];
            line = line + 8'b1;
            memoria[5] = instrucoes[line];
            memoria[memoria[4]] = memoria[5];
          end
          8'b11100010:
          begin
            line = line + 8'b1;
            memoria[4] = instrucoes[line];
            line = line + 8'b1;
            memoria[5] = instrucoes[line];
            if(memoria[5] != 8'b00000010)begin
              memoria[memoria[4]] = memoria[memoria[5]];
            end else begin
              memoria[memoria[4]] = arr;
            end
          end
          8'b00000001:
          begin
            line = line + 8'b1;
            memoria[3] = instrucoes[line];
            line = line + 8'b1;
            memoria[0] = instrucoes[line];
            memoria[2] = arr;
          end
          8'b10000001:
          begin
            line = line + 8'b1;
            memoria[4] = instrucoes[line];
            memoria[5] = memoria[4];
            if(memoria[4] == 8'b00000010)begin
              #5$display("%d",arr);
            end else if(memoria[4] == 8'b00001000)begin
              #5$display("%d",flags[memoria[5]]);             
            end else begin
              #5$display("%d",memoria[memoria[4]]);

            end
          end
          8'b10011001:
          begin
            line = line + 8'b1;
            memoria[4] = instrucoes[line];
            line = line + 8'b1;
            memoria[5] = instrucoes[line];
            if(memoria[4] == 8'b00000010)begin
              #5$display("%d",arr[memoria[5]]);             
            end else if(memoria[4] == 8'b00001000)begin
              #5$display("%d",flags[memoria[5]]);             
            end else begin
              #5$display("%d",memoria[memoria[4]][memoria[5]]);
            end
          end
          8'b10101010:
          begin
            line = line + 8'b1;
            memoria[6] = instrucoes[line]-8'b1;
            memoria[7] = line;
            line = memoria[6];
          end
          8'b11011010:
          begin
            if(arr == 1)begin
              line = line + 8'b1;
              memoria[6] = instrucoes[line]-8'b1;
              memoria[7] = line;
              line = memoria[6];
            end
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
        end else begin
        if(reader == 8'b01111110)begin
          start = 1;
        end
      end
      line = line + 8'b1;
    end
  end
endmodule