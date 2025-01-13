module alu_tb();
  reg [7:0] a, b;
  reg [5:0] op;
  reg clk, rst, alu_start;
  wire [15:0] result;
  wire alu_done;
  reg [15:0] expected_result;

  // Instantiate the ALU
  alu DUT (
    .a(a),
    .b(b),
    .op(op),
    .clk(clk),
    .reset(rst),
    .alu_start(alu_start),
    .result(result),
    .alu_done(alu_done)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test sequence
  initial begin
    // Initialize inputs
    a = 8'd0;
    b = 8'd0;
    op = 6'd0;
    rst = 1;
    alu_start = 0;

    // Apply reset
    #20 rst = 0; // Increased delay for proper initialization

    // Test addition
    a = 8'd15;
    b = 8'd10;
    op = 6'b000000;
    expected_result = 15 + 10;
    #10 alu_start = 1;
    #20 alu_start = 0;
    wait (alu_done);
    #10;
    if (result !== expected_result) $display("Addition failed: Expected %d, Got %d", expected_result, result);

    // Test subtraction
    a = 8'd20;
    b = 8'd5;
    op = 6'b000001;
    expected_result = 20 - 5;
    #10 alu_start = 1;
    #20 alu_start = 0;
    wait (alu_done);
    #10;
    if (result !== expected_result) $display("Subtraction failed: Expected %d, Got %d", expected_result, result);

    // Test multiplication
    a = 8'd4;
    b = 8'd3;
    op = 6'b000010;
    expected_result = 4 * 3;
    #10 alu_start = 1;
    #20 alu_start = 0;
    wait (alu_done);
    #10;
    if (result !== expected_result) $display("Multiplication failed: Expected %d, Got %d", expected_result, result);

    // Test division
    a = 8'd16;
    b = 8'd4;
    op = 6'b000011;
    expected_result = 16 / 4;
    #10 alu_start = 1;
    #20 alu_start = 0;
    wait (alu_done);
    #10;
    if (result !== expected_result) $display("Division failed: Expected %d, Got %d", expected_result, result);

    // Division by zero test
    a = 8'd16;
    b = 8'd0;
    op = 6'b000011;
    #10 alu_start = 1;
    #20 alu_start = 0;
    wait (alu_done);
    #10;
    $display("Division by zero test: Result = %h (Expected behavior depends on implementation)", result);

    // Test bitwise AND
    a = 8'b10101010;
    b = 8'b11001100;
    op = 6'b001000;
    expected_result = a & b;
    #10 alu_start = 1;
    #20 alu_start = 0;
    wait (alu_done);
    #10;
    if (result !== expected_result) $display("AND operation failed: Expected %b, Got %b", expected_result, result);

    // End simulation
    $display("All tests completed");
    $finish;
  end
endmodule
