module test_div_restoring;
  reg clk, reset, start;
  reg [7:0] a, b;
  wire [7:0] result;
  wire done;

  div_restoring_debug uut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .a(a),
    .b(b),
    .result(result),
    .done(done)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10-time unit clock period
  end

  // Test cases
  initial begin
    reset = 1; start = 0; a = 0; b = 0;
    #10 reset = 0; a = 8'd16; b = 8'd4; start = 1;  // Test case 1
    #100 start = 0;  // Wait for division to complete

    #10 a = 8'd10; b = 8'd2; start = 1;  // Test case 2
    #100 start = 0;  // Wait for division to complete

    #10 a = 8'd15; b = 8'd3; start = 1;  // Test case 3
    #100 $finish;  // End simulation
  end
endmodule
