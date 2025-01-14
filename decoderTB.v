`timescale 1ns / 1ps

module testbench;
  reg [7:0] memory [0:1023];  // Memory to hold instructions and data
  reg enable;                // Enable signal for the microprocessor
  wire [7:0] result;        // Output result from the microprocessor
  wire running;             // Indicates if the microprocessor is running

  // Instantiate the microprocessor
  microprocessor uut (
    .memory(memory),
    .enable(enable),
    .result(result),
    .running(running)
  );

  // Test stimulus
  initial begin
    $dumpfile("microprocessor.vcd");
    $dumpvars(0, testbench);

    // Initialize memory with a program
    // Instruction format:
    // 8'b00000010: Two-operand instruction
    // 8'b00000001: Single-operand instruction
    // 8'b11111111: Termination

    memory[0] = 8'b00000010;  // Two-operand instruction
    memory[1] = 6'b000000;    // ADD operation
    memory[2] = 8'd15;        // Operand 1
    memory[3] = 8'd10;        // Operand 2

    memory[4] = 8'b00000001;  // Single-operand instruction
    memory[5] = 6'b000111;    // NOT operation
    memory[6] = 8'd240;       // Operand

    memory[7] = 8'b11111111;  // Termination instruction

    enable = 1;               // Enable the microprocessor

    // Wait for the program to complete
    wait(!running);           // Wait until running goes low
    #10;                      // Additional delay to ensure stability
    $display("Final result: %d", result);
    $finish;
  end

endmodule