`include "decoder_instructions.sv"
`include "alu_operations.sv"

module cpu_decoder
(
    input logic [31:0] instruction,
    output logic [4:0] operation,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [4:0] rd,
    output logic [31:0] imm,
    output logic use_rs1,
    output logic use_rs2,
    output logic use_imm,
	output logic use_pc,
    output logic s_err
);
	
	logic s_operands_err;
	logic s_opcode_err;
	
	wire [6:0] opcode;
	wire [2:0] f3;
	wire [6:0] f7;
	
	assign opcode = instruction[6:0];
	assign f3 = instruction[14:12];
	assign f7 = instruction[31:25];
	
	// get register numbers or immediate values
	always_comb begin
		s_operands_err = 1'b0;
				
		case(opcode)
			`TYPE_B, `SW_OPCODE: begin // instructions for comparing numbers
				use_rs1 = 1'b1;
				use_rs2 = 1'b1;
				use_imm = 1'b1;
				use_pc = 1'b0;
				
				rs1 = instruction[19:15];
				rs2 = instruction[24:20];
				if(opcode == `SW_OPCODE) begin
					imm = {20'b0, instruction[31:25], instruction[11:7]};
				end else begin
					imm = {19'b0, instruction[31], 1'b0, instruction[30:25], 5'b0};
				end
				rd = 5'b00000;
			end
			
			`TYPE_R: begin // instructions working with registers only
				use_rs1 = 1'b1;
				use_rs2 = 2'b1;
				use_imm = 1'b0;
				use_pc = 1'b0;
				
				rs1 = instruction[19:15];
				rs2 = instruction[24:20];
				rd = instruction[11:7];
				imm = '0;
			end
			
			`TYPE_I, `LW_OPCODE: begin // instructions working with immediate values				
				use_rs1 = 1'b1;
				use_rs2 = 1'b0;
				use_imm = 1'b1;
				use_pc = 1'b0;
				
				rs1 = instruction[19:15];
				if(opcode == 7'b0010011 && f3 != 3'b001 && f3 != 3'b101 || opcode == 7'b1100111 || opcode == 7'b0000011) begin
					imm = {20'b0, instruction[31:20]};
				end else begin
					imm = {27'b0, instruction[24:20]};
				end
				rd = instruction[11:7];
			end
			
			`LUI_OPCODE, `AUIPC_OPCODE: begin // load upper intermediate / add upper intermediate to pc
				use_rs1 = 1'b0;
				use_rs2 = 1'b0;
				use_imm = 1'b1;
				use_pc = 1'b0;
				
				imm = {12'b0, instruction[31:12]};
				rd = instruction[11:7];
			end
			
			`JAL_OPCODE: begin // jump and link
				use_rs1 = 1'b0;
				use_rs2 = 1'b0;
				use_imm = 1'b1;
				use_pc = 1'b1;
				
				imm = {10'b0, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
			end
			
			`JALR_OPCODE: begin // jump and link register
				use_rs1 = 1'b1;
				use_rs2 = 1'b0;
				use_imm = 1'b1;
				use_pc = 1'b1;
				
				imm = {20'b0, instruction[31:20]};
			end
			
			default: begin
				s_operands_err = 1'b1;
			end
		endcase
	end

	// get operation
	always_comb begin
		s_opcode_err = 1'b0;
		if (opcode == `ADD_OPCODE && f3 == `ADD_F3 && f7 == `ADD_F7) begin
			operation = `ADD;
		end else if (opcode == `SUB_OPCODE && f3 == `SUB_F3 && f7 == `SUB_F7) begin
			operation = `SUB;
		end else if (opcode == `SLL_OPCODE && f3 == `SLL_F3 && f7 == `SLL_F7) begin
			operation = `SLL;
		end else if (opcode == `SLT_OPCODE && f3 == `SLT_F3 && f7 == `SLT_F7) begin
			operation = `SLT;
		end else if (opcode == `SLTU_OPCODE && f3 == `SLTU_F3 && f7 == `SLTU_F7) begin
			operation = `SLTU;
		end else if (opcode == `XOR_OPCODE && f3 == `XOR_F3 && f7 == `XOR_F7) begin
			operation = `XOR;
		end else if (opcode == `SRL_OPCODE && f3 == `SRL_F3 && f7 == `SRL_F7) begin
			operation = `SRL;
		end else if (opcode == `SRA_OPCODE && f3 == `SRA_F3 && f7 == `SRA_F7) begin
			operation = `SRA;
		end else if (opcode == `OR_OPCODE && f3 == `OR_F3 && f7 == `OR_F7) begin
			operation = `OR;
		end else if (opcode == `AND_OPCODE && f3 == `AND_F3 && f7 == `AND_F7) begin
			operation = `AND;
		end else if (opcode == `MUL_OPCODE && f3 == `MUL_F3 && f7 == `MUL_F7) begin
			operation = `MUL;
		end else if (opcode == `MULH_OPCODE && f3 == `MULH_F3 && f7 == `MULH_F7) begin
			operation = `MULH;
		end else if (opcode == `MULHSU_OPCODE && f3 == `MULHSU_F3 && f7 == `MULHSU_F7) begin
			operation = `MULHSU;
		end else if (opcode == `MULHU_OPCODE && f3 == `MULHU_F3 && f7 == `MULHU_F7) begin
			operation = `MULHU;
		end else if (opcode == `DIV_OPCODE && f3 == `DIV_F3 && f7 == `DIV_F7) begin
			operation = `DIV;
		end else if (opcode == `DIVU_OPCODE && f3 == `DIVU_F3 && f7 == `DIVU_F7) begin
			operation = `DIVU;
		end else if (opcode == `REM_OPCODE && f3 == `REM_F3 && f7 == `REM_F7) begin
			operation = `REM;
		end else if (opcode == `REMU_OPCODE && f3 == `REMU_F3 && f7 == `REMU_F7) begin
			operation = `REMU;
		end else if (opcode == `ADDI_OPCODE && f3 == `ADDI_F3) begin
			operation = `ADD;
		end else if (opcode == `SLTI_OPCODE && f3 == `SLTI_F3) begin
			operation = `SLT;
		end else if (opcode == `SLTIU_OPCODE && f3 == `SLTIU_F3) begin
			operation = `SLTU;
		end else if (opcode == `XORI_OPCODE && f3 == `XORI_F3) begin
			operation = `XOR;
		end else if (opcode == `ORI_OPCODE && f3 == `ORI_F3) begin
			operation = `OR;
		end else if (opcode == `ANDI_OPCODE && f3 == `ANDI_F3) begin
			operation = `AND;
		end else if (opcode == `SLLI_OPCODE && f3 == `SLLI_F3 && f7 == `SLLI_F7) begin
			operation = `SLL;
		end else if (opcode == `SRLI_OPCODE && f3 == `SRLI_F3 && f7 == `SRLI_F7) begin
			operation = `SRL;
		end else if (opcode == `SRAI_OPCODE && f3 == `SRAI_F3 && f7 == `SRAI_F7) begin
			operation = `SRA;
		end else if (opcode == `BEQ_OPCODE && f3 == `BEQ_F3) begin
			operation = `BEQ;
		end else if (opcode == `BNE_OPCODE && f3 == `BNE_F3) begin
			operation = `BNE;
		end else if (opcode == `BLT_OPCODE && f3 == `BLT_F3) begin
			operation = `BLT;
		end else if (opcode == `BGE_OPCODE && f3 == `BGE_F3) begin
			operation = `BGE;
		end else if (opcode == `BLTU_OPCODE && f3 == `BLTU_F3) begin
			operation = `BLTU;
		end else if (opcode == `GBEU_OPCODE && f3 == `GBEU_F3) begin
			operation = `GBEU;
		end else if (opcode == `LUI_OPCODE) begin
			operation = `LUI;
		end else if (opcode == `AUIPC_OPCODE) begin
			operation = `AUIPC;
		end else if (opcode == `JAL_OPCODE) begin
			operation = `JAL;
		end else if (opcode == `JALR_OPCODE && f3 == `JALR_F3) begin
			operation = `JAL;
		end else if (opcode == `SW_OPCODE && f3 == `SW_F3) begin
			operation = `SW;
		end else if (opcode == `LW_OPCODE && f3 == `LW_F3) begin
			operation = `LW;
		end else begin
			s_opcode_err = 1'b1;
		end
	end
	
	assign s_err = s_operands_err || s_opcode_err;
	
endmodule;