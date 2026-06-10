`include "alu_operations.sv";

module tb_decoder;
	logic [31:0] instructions[16];
	
	logic [31:0] s_instruction_i;
	logic s_use_rs1, s_use_rs2, s_use_imm;
	logic [4:0] s_rs1, s_rs2, s_rd;
	logic [31:0] s_imm;
	logic [6:0] s_operation;
	logic s_err;
	
	cpu_decoder decoder(
		.instruction({s_instruction_i[7:0], s_instruction_i[15:8], s_instruction_i[23:16], s_instruction_i[31:24]}),
		.operation(s_operation),
		.rs1(s_rs1),
		.rs2(s_rs2),
		.rd(s_rd),
		.imm(s_imm),
		.use_rs1(s_use_rs1),
		.use_rs2(s_use_rs2),
		.use_imm(s_use_imm),
		.s_err(s_err)
	);
	
	initial begin
		instructions[0] = 32'h93010000; // Random instruction
		instructions[1] = 32'h6F000005; // Random instruction
		instructions[2] = 32'h23A08101; // Random instruction
		instructions[3] = 32'h23A29101; // Random instruction
		instructions[4] = 32'h23A4A101; // Random instruction
		instructions[5] = 32'h23A6B101; // Random instruction
		instructions[6] = 32'h23A8C101; // Random instruction
		instructions[7] = 32'h23AAD101; // Random instruction
		instructions[8] = 32'h23ACE101; // Random instruction
		instructions[9] = 32'h23AEF101; // Random instruction
	
		s_instruction_i = instructions[0];
		#10;
		$display("ALU Operation: %b", s_operation);
		$display("Use rs1: %b, rs2: %b, imm: %b", s_use_rs1, s_use_rs2, s_use_imm);
		$display("Operands/registers rs1: 0x%x, rs2: 0x%x, rd: 0x%x, imm: 0x%x", s_rs1, s_rs2, s_rd, s_imm);
		$display("Error: %b", s_err);
		
		s_instruction_i = instructions[1];
		#10;
		$display("ALU Operation: %b", s_operation);
		$display("Use rs1: %b, rs2: %b, imm: %b", s_use_rs1, s_use_rs2, s_use_imm);
		$display("Operands/registers rs1: 0x%x, rs2: 0x%x, rd: 0x%x, imm: 0x%x", s_rs1, s_rs2, s_rd, s_imm);
		$display("Error: %b", s_err);

		s_instruction_i = instructions[2];
		#10;
		$display("ALU Operation: %b", s_operation);
		$display("Use rs1: %b, rs2: %b, imm: %b", s_use_rs1, s_use_rs2, s_use_imm);
		$display("Operands/registers rs1: 0x%x, rs2: 0x%x, rd: 0x%x, imm: 0x%x", s_rs1, s_rs2, s_rd, s_imm);
		$display("Error: %b", s_err);

		s_instruction_i = instructions[3];
		#10;
		$display("ALU Operation: %b", s_operation);
		$display("Use rs1: %b, rs2: %b, imm: %b", s_use_rs1, s_use_rs2, s_use_imm);
		$display("Operands/registers rs1: 0x%x, rs2: 0x%x, rd: 0x%x, imm: 0x%x", s_rs1, s_rs2, s_rd, s_imm);
		$display("Error: %b", s_err);

		s_instruction_i = instructions[4];
		#10;
		$display("ALU Operation: %b", s_operation);
		$display("Use rs1: %b, rs2: %b, imm: %b", s_use_rs1, s_use_rs2, s_use_imm);
		$display("Operands/registers rs1: 0x%x, rs2: 0x%x, rd: 0x%x, imm: 0x%x", s_rs1, s_rs2, s_rd, s_imm);
		$display("Error: %b", s_err);

		s_instruction_i = instructions[5];
		#10;
		$display("ALU Operation: %b", s_operation);
		$display("Use rs1: %b, rs2: %b, imm: %b", s_use_rs1, s_use_rs2, s_use_imm);
		$display("Operands/registers rs1: 0x%x, rs2: 0x%x, rd: 0x%x, imm: 0x%x", s_rs1, s_rs2, s_rd, s_imm);
		$display("Error: %b", s_err);

		s_instruction_i = instructions[6];
		#10;
		$display("ALU Operation: %b", s_operation);
		$display("Use rs1: %b, rs2: %b, imm: %b", s_use_rs1, s_use_rs2, s_use_imm);
		$display("Operands/registers rs1: 0x%x, rs2: 0x%x, rd: 0x%x, imm: 0x%x", s_rs1, s_rs2, s_rd, s_imm);
		$display("Error: %b", s_err);

		s_instruction_i = instructions[7];
		#10;
		$display("ALU Operation: %b", s_operation);
		$display("Use rs1: %b, rs2: %b, imm: %b", s_use_rs1, s_use_rs2, s_use_imm);
		$display("Operands/registers rs1: 0x%x, rs2: 0x%x, rd: 0x%x, imm: 0x%x", s_rs1, s_rs2, s_rd, s_imm);
		$display("Error: %b", s_err);

		s_instruction_i = instructions[8];
		#10;
		$display("ALU Operation: %b", s_operation);
		$display("Use rs1: %b, rs2: %b, imm: %b", s_use_rs1, s_use_rs2, s_use_imm);
		$display("Operands/registers rs1: 0x%x, rs2: 0x%x, rd: 0x%x, imm: 0x%x", s_rs1, s_rs2, s_rd, s_imm);
		$display("Error: %b", s_err);

		s_instruction_i = instructions[9];
		#10;
		$display("ALU Operation: %b", s_operation);
		$display("Use rs1: %b, rs2: %b, imm: %b", s_use_rs1, s_use_rs2, s_use_imm);
		$display("Operands/registers rs1: 0x%x, rs2: 0x%x, rd: 0x%x, imm: 0x%x", s_rs1, s_rs2, s_rd, s_imm);
		$display("Error: %b", s_err);
		
		//$display("PASSED");
		$stop;
	end
	// zapisat instrukcie
	
	// kazdych 5 nieco a vypisat result

endmodule