`include "alu_operations.sv"

typedef enum logic [2:0] {
	FETCH = 3'b000, 
	DECODE = 3'b001, 
	EXECUTE = 3'b010, 
	MEMORY = 3'b011, 
	WRITEBACK = 3'b100,
	ERROR = 3'b101
} phase_t;

module cpu_top
(
	input logic s_clk_i,                     //hodinový signál
	input logic s_resetn_i,                  //signál resetu, aktívny v 0
	input logic [31:0] s_boot_add_i,         //zavádzacia adresa
	output logic s_error_o,                  //signalizácia chyby

	input logic [31:0] s_ibus_val_i,         //hodnota z inštrukčnej pamäte
	output logic s_ibus_write_o,             //zápis do inštrukčnej pamäte, pripojiť k 0
	output logic [31:0] s_ibus_add_o,        //adresa pre inštrukčnú pamäť
	output logic [31:0] s_ibus_val_o,        //hodnota pre zápis do inštrukčnej pamäte, pripojiť k 0

	input logic [31:0] s_dbus_val_i,         //hodnota z dátovej pamäte
	output logic s_dbus_write_o,             //zápis do dátovej pamäte
	output logic [31:0] s_dbus_add_o,        //adresa pre dáovú pamäť
	output logic [31:0] s_dbus_val_o         //hodnota pre zápis do dátovej pamäte
);	
	
	// internal registers & status variables
	phase_t phase;
	logic [31:0] r_op_1, r_op_2;
	logic [4:0] r_d;
	logic [4:0] r_alu_op;
	logic [31:0] r_jump_add;
	logic [31:0] r_mem_access;
	logic s_cond_jmp, s_jmp;
	logic s_mem_rd, s_mem_wr;
	
	
	// decoder and its variables
	wire [31:0] d_s_instruction;
	wire [4:0] d_s_operation;
	wire [4:0] d_s_rs1, d_s_rs2, d_s_rd;
	wire [31:0] d_s_imm;
	wire d_s_use_rs1, d_s_use_rs2, d_s_use_imm, d_s_use_pc;
	wire d_s_err;
	cpu_decoder decoder(
		.instruction(s_ibus_val_i),
		.operation(d_s_operation),
		.rs1(d_s_rs1),
		.rs2(d_s_rs2),
		.rd(d_s_rd),
		.imm(d_s_imm),
		.use_rs1(d_s_use_rs1),
		.use_rs2(d_s_use_rs2),
		.use_imm(d_s_use_imm),
		.use_pc(d_s_use_pc),
		.s_err(d_s_err)
	);
	
	// alu and its variables
	wire [31:0] a_s_result;
	alu alu(
		.s_clk_i(s_clk_i),
		.s_resetn_i(s_resetn_i),
		.s_opcode_i(r_alu_op),
		.s_op_A_i(r_op_1),
		.s_op_B_i(r_op_2),
		.s_result_o(a_s_result)
	);
	
	
	// programmable registers
	logic [31:0] r_pc;
	logic [31:0] r_x [31:0];
	
	assign s_ibus_add_o = r_pc;
	
	always_ff @(negedge s_resetn_i) begin
		s_error_o = 1'b0;
		r_pc = s_boot_add_i;
		r_x <= '{default: '0};
		s_cond_jmp <= 0;
		s_jmp <= 0;
		r_alu_op <= `NOP;
		phase <= FETCH;
	end

	always_ff @(posedge s_clk_i) begin
		case(phase)
			FETCH: begin
				phase <= DECODE;
				
				for(int i=0; i<31; i++){
					$write("%d: 0x%x, ", i, r_x[i]);
				}
				$display("");
				$display("FETCH: Fetching instruction from address: 0x%x", r_pc);
				
				s_ibus_write_o <= '0; // read, not write
				s_ibus_val_o <= '0; // write value 0, because not writing
				
			end
			
			DECODE: begin	
				phase <= EXECUTE;
				
				$display("DECODE: Decoding instruction: 0x%x (0x%x)", s_ibus_val_i, {s_ibus_val_i[7:0], s_ibus_val_i[15:8], s_ibus_val_i[23:16], s_ibus_val_i[31:24]});
				$display("DECODE: Opcode: %b", decoder.opcode);	
				if(d_s_err) begin
					$display("DECODE: DECODER ERROR");
					phase <= ERROR;
				end
				
				if(d_s_use_rs1 && d_s_use_rs2 && !d_s_use_imm && !d_s_use_pc) begin
					r_op_1 <= r_x[d_s_rs1];
					r_op_2 <= r_x[d_s_rs2];
				end else if (d_s_use_rs1 && d_s_use_imm && !d_s_use_rs2 && !d_s_use_pc) begin
					r_op_1 <= r_x[d_s_rs1];
					r_op_2 <= d_s_imm;
				end else if(d_s_use_rs1 && d_s_use_rs2 && d_s_use_imm && !d_s_use_pc) begin
					r_op_1 <= r_x[d_s_rs1];
					r_op_2 <= r_x[d_s_rs2];
					r_jump_add <= d_s_imm + r_pc;
					if(d_s_operation != `SW) begin
						s_cond_jmp <= 1; // b type instruction - branch
					end
				end else if(d_s_use_imm && !d_s_use_rs1 && !d_s_use_rs2 && !d_s_use_pc) begin
					r_op_1 <= d_s_imm;
				end else if(d_s_use_imm && d_s_use_pc && !d_s_use_rs1 && !d_s_use_rs2) begin
					r_op_1 <= r_pc;
					r_jump_add <= r_pc + d_s_imm;
					s_jmp <= 1;
				end else if(d_s_use_rs1 && d_s_use_imm && d_s_use_pc && !d_s_use_rs2) begin
					r_op_1 <= r_pc;
					r_jump_add <= r_x[d_s_rs1] + d_s_imm;
					s_jmp <= 1;
				end else begin
					$display("INVALID OPERAND USAGE");
					phase <= ERROR;
				end 
				
				if(d_s_operation == `LW) begin
					r_mem_access <= r_x[d_s_rs1] + d_s_imm;
					s_mem_rd <= 1;
				end else if(d_s_operation == `SW) begin
					r_mem_access <= r_x[d_s_rs1] + d_s_imm;
					s_mem_wr <= 1;
				end
				
				r_d <= d_s_rd;
				r_alu_op <= d_s_operation;
				r_pc <= r_pc + 32'h4;
			end
			
			EXECUTE: begin
				phase <= MEMORY;
				
				$display("EXECUTE: alu operation: %b", r_alu_op);
				$display("EXECUTE: using operands reg1: %x, reg2: %x, imm: %x", d_s_use_rs1, d_s_use_rs2, d_s_use_imm);
				$display("EXECUTE: using registers reg1: %x, reg2: %x, rd: %x", d_s_rs1, d_s_rs2, d_s_rd);
				$display("EXECUTE: operands: 0x%x, 0x%x, 0x%x", r_op_1, r_op_2, r_jump_add);
				$display("EXECUTE: signals: memrd: %x, memwr: %x, cond_jump: %x, jump: %x", s_mem_rd, s_mem_wr, s_cond_jmp, s_jmp);
				$display("EXECUTE: Result from ALU: 0x%x", a_s_result);
				
				if(s_jmp && s_cond_jmp) begin
					$display("EXECUTE: Invalid branch and jump combination error.");
					phase <= ERROR;
				end else if(s_jmp) begin
					$display("EXECUTE: Jump to address 0x%x", r_jump_add);
					r_pc <= r_jump_add;
					s_jmp <= '0;
				end else if(s_cond_jmp) begin
					$display("EXECUTE: Possible branch");
					if(a_s_result == 32'b1) begin
						$display("EXECUTE: Branch jump to address 0x%x", r_jump_add);
						r_pc <= r_jump_add;
						s_cond_jmp <= '0;
					end
				end
				
				r_alu_op <= `NOP;
			end
			
			MEMORY: begin
				phase <= WRITEBACK;
				
				if(s_mem_rd && s_mem_wr) begin
					$display("MEMORY: Error: Memory RD & WR signals both active.");
					phase <= ERROR;
				end else if(s_mem_rd) begin
					$display("MEMORY: Reading from memory address 0x%x", r_mem_access);
					s_dbus_write_o <= '0;
					s_dbus_add_o <= r_mem_access;
				end else if(s_mem_wr) begin
					$display("MEMORY: Writing value 0x%x to memory at address 0x%x", r_op_2, r_mem_access);
					s_dbus_write_o <= 1'b1;
					s_dbus_add_o <= r_mem_access;
					s_dbus_val_o <= r_op_2;
				end
			end
			
			WRITEBACK: begin
				phase <= FETCH;
				
				if(s_mem_rd) begin
					$display("WRITEBACK: Writing value 0x%x from memory to register 0x%x", s_dbus_val_i, r_d);
					r_x[r_d] <= s_dbus_val_i;
				end else begin
					$display("WRITEBACK: Writing value 0x%x from alu to register 0x%x", a_s_result, r_d);
					r_x[r_d] <= a_s_result;
				end
				
				s_mem_rd <= '0;
				s_mem_wr <= '0;
				s_dbus_write_o <= '0;
			end
			


			// ERROR states
			ERROR: begin
				$display("ERROR");
				s_error_o <= 1'b1;
			end
			
			default: begin
				$display("UNKNOWN STATE");
				phase <= ERROR;
			end
		endcase
	end

endmodule
