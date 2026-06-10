`include "alu_operations.sv" // Include your ALU operations definitions

module tb_alu;

    // Testbench signals
    logic s_clk_i;
    logic s_resetn_i;
    logic [4:0] s_opcode_i;
    logic [31:0] s_op_A_i;
    logic [31:0] s_op_B_i;
    logic [31:0] s_result_o;

    // Instantiate the ALU
    alu dut (
        .s_clk_i(s_clk_i),
        .s_resetn_i(s_resetn_i),
        .s_opcode_i(s_opcode_i),
        .s_op_A_i(s_op_A_i),
        .s_op_B_i(s_op_B_i),
        .s_result_o(s_result_o)
    );

    // Clock generation
    always #5 s_clk_i = ~s_clk_i;

    // Testbench logic
    initial begin
        // Initialize clock and reset
        s_clk_i = 0;
        s_resetn_i = 0;

        // Hold reset low for a few cycles
        #10;
        s_resetn_i = 1;

        // Test each operation
        test_operation(`LUI, 32'h0000_1234, 0, 32'h0000_1234);
        test_operation(`AUIPC, 32'h0000_1234, 32'h0000_5678, 32'h0000_68AC);
        test_operation(`JAL, 0, 32'h0000_5678, 32'h0000_567C);
        test_operation(`BEQ, 32'h1234, 32'h1234, 1);
        test_operation(`BNE, 32'h1234, 32'h5678, 1);
        test_operation(`BLT, -5, 5, 1);
        test_operation(`BGE, 5, -5, 1);
        test_operation(`BLTU, 5, 10, 1);
        test_operation(`GBEU, 15, 10, 1);
        test_operation(`ADD, 32'h1234, 32'h5678, 32'h68AC);
        test_operation(`SUB, 32'h5678, 32'h1234, 32'h4444);
        test_operation(`SLL, 32'h0000_0001, 4, 32'h0000_0010);
        test_operation(`SLT, -5, 5, 1);
        test_operation(`SLTU, 5, 10, 1);
        test_operation(`XOR, 32'hAAAA_AAAA, 32'h5555_5555, 32'hFFFF_FFFF);
        test_operation(`SRL, 32'h8000_0000, 1, 32'h4000_0000);
        test_operation(`SRA, 32'h8000_0000, 1, 32'hC000_0000);
        test_operation(`OR, 32'hAAAA_AAAA, 32'h5555_5555, 32'hFFFF_FFFF);
        test_operation(`AND, 32'hAAAA_AAAA, 32'h5555_5555, 32'h0000_0000);
        test_operation(`MUL, 32'h0000_1234, 32'h0000_5678, 32'h0004_87F8);
        test_operation(`MULH, -32'd1234, 32'd5678, -1); // Example signed multiplication
        test_operation(`MULHSU, -32'd1234, 32'd5678, -1); // Example mixed signed/unsigned
        test_operation(`MULHU, 32'd1234, 32'd5678, 0); // Example unsigned multiplication
        test_operation(`DIV, -32'd20, 32'd5, -4);
        test_operation(`DIVU, 32'd20, 32'd5, 4);
        test_operation(`REM, -32'd20, 32'd3, -2);
        test_operation(`REMU, 32'd20, 32'd3, 2);
		
		#10
		test_operation(`ADD, 32'h1234, 32'h5678, 32'h68AC);
		
		#100
		$display("Keeping result: 0x%x", s_result_o);
		#100
		$display("Still keeping result: 0x%x", s_result_o);
		
        // End simulation
        $stop;
    end

    // Task to test a single ALU operation
    task test_operation(input [4:0] opcode, input [31:0] opA, input [31:0] opB, input [31:0] expected);
        begin
            s_opcode_i = opcode;
            s_op_A_i = opA;
            s_op_B_i = opB;
            #10; // Wait for one clock cycle
            if (s_result_o !== expected) begin
                $display("ERROR: Opcode %b, opA: 0x%x, opB: 0x%x, result: 0x%x (expected: 0x%x)",
                         opcode, opA, opB, s_result_o, expected);
            end else begin
                $display("PASS: Opcode %b, opA: 0x%x, opB: 0x%x, result: 0x%x",
                         opcode, opA, opB, s_result_o);
            end
        end
    endtask

endmodule
