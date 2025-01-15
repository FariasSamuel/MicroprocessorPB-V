`include "clock.v"
`include "ALU.v"

module microprocessor(
    input wire [7:0] memory [0:1023],
    input wire enable,
    output wire [7:0] result,
    output wire running
);

    // Register declarations
    reg [7:0] ar1, ar2;          // ALU's first and second register
    reg [7:0] arr;               // ALU's result register
    reg [5:0] operation_alu;     // ALU operation register
    reg [7:0] reader;            // Register to read bytecode
    reg enable_clk;              // Clock enable signal
    reg clk;                     // Clock signal
    
    // Division control signals
    reg div_start;
    reg div_reset;
    wire [7:0] div_result;
    wire div_done;

    wire fusion_enable;          // Combined enable signal
    wire alu_done;               // Signal indicating ALU operation completion
    
    integer line;                // Current line in the memory

    // Wire assignments
    assign fusion_enable = enable & enable_clk;
    assign running = enable_clk;
    assign result = arr;

    // Clock generator instance
    clock_gen CLOCK_GEN(
        .enable(fusion_enable),
        .clk(clk)
    );

    // Divider instance at module level
    div_restoring DIV (
        .clk(clk),
        .reset(div_reset),
        .start(div_start),
        .a(ar1),
        .b(ar2),
        .result(div_result),
        .done(div_done)
    );

    // Initialization
    initial begin
        enable_clk = 1;
        line = 0;
        div_start = 0;
        div_reset = 0;
    end

    // Main operation logic
    always @(posedge clk) begin
        if (line == -1) begin
            enable_clk <= 0;
            $finish;
        end else begin
            reader = memory[line];
            case (reader)
                8'b00000010, 8'b00000001: begin
                    line = line + 1;
                    operation_alu = memory[line];
                    line = line + 1;
                    ar1 = memory[line];
                    if (reader == 8'b00000010) begin
                        line = line + 1;
                        ar2 = memory[line];
                    end
                    case (operation_alu)
                        6'b000000: arr <= ar1 + ar2;
                        6'b000001: arr <= ar1 - ar2;
                        6'b000010: arr <= ar1 * ar2;
                        6'b000011: begin
                            div_start <= 1;
                            if (div_done) begin
                                arr <= div_result;
                                div_start <= 0;
                            end
                        end
                        6'b000100: arr <= ar1 & ar2;
                        6'b000101: arr <= ar1 | ar2;
                        6'b000110: arr <= ar1 ^ ar2;
                        6'b000111: arr <= ~ar1;
                        6'b001000: arr <= (ar1 == ar2) ? 8'b00 : ((ar1 < ar2) ? 8'b01 : 8'b10);
                        default: arr <= 8'b0;
                    endcase
                end
                8'b11111111: begin
                    line = -2;
                end
            endcase
            line = line + 1;
        end
    end

endmodule