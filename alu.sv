`include "alu_operations.sv"

module alu(
    input logic s_clk_i,
    input logic s_resetn_i,
    input logic [4:0] s_opcode_i,
    input logic [31:0] s_op_A_i,
    input logic [31:0] s_op_B_i,
    output logic [31:0] s_result_o
);

    logic signed [31:0] A_signed;
    logic signed [31:0] B_signed;
	assign A_signed = s_op_A_i;
	assign B_signed = s_op_B_i;
	
	always_ff @(negedge s_resetn_i) begin
        s_result_o <= 32'b0;
	end

    always_ff @(posedge s_clk_i) begin
		logic signed [63:0] mul_result;
		case (s_opcode_i)
			`NOP: begin
				// pass, do no operation
			end
			`LUI: begin
				s_result_o <= s_op_A_i;
			end
			`AUIPC: begin
				s_result_o <= s_op_A_i + s_op_B_i;
			end
			`JAL: begin
				s_result_o <= s_op_A_i + 32'h4;
			end
			`LW: begin
				s_result_o <= s_result_o;
			end
			`SW: begin
				s_result_o <= s_result_o;
			end
			`BEQ: begin
				s_result_o <= (s_op_A_i == s_op_B_i) ? 32'b1 : 32'b0;
			end
			`BNE: begin
				s_result_o <= (s_op_A_i != s_op_B_i) ? 32'b1 : 32'b0;
			end
			`BLT: begin
				s_result_o <= (A_signed < B_signed) ? 32'b1 : 32'b0;
			end
			`BGE: begin
				s_result_o <= (A_signed >= B_signed) ? 32'b1 : 32'b0;
			end
			`BLTU: begin
				s_result_o <= (s_op_A_i < s_op_B_i) ? 32'b1 : 32'b0;
			end
			`GBEU: begin
				s_result_o <= (s_op_A_i >= s_op_B_i) ? 32'b1 : 32'b0;
			end
			`ADD: begin
				s_result_o <= A_signed + B_signed;
			end
			`SUB: begin
				s_result_o <= A_signed - B_signed;
			end
			`SLL: begin
				s_result_o <= s_op_A_i << s_op_B_i;
			end
			`SLT: begin
				s_result_o <= (A_signed < B_signed) ? 32'b1 : 32'b0;
			end
			`SLTU: begin
				s_result_o <= (s_op_A_i < s_op_B_i) ? 32'b1 : 32'b0;
			end
			`XOR: begin
				s_result_o <= s_op_A_i ^ s_op_B_i;
			end
			`SRL: begin
				s_result_o <= s_op_A_i >> s_op_B_i;
			end
			`SRA: begin
				s_result_o <= s_op_A_i >>> s_op_B_i;
			end
			`OR: begin
				s_result_o <= s_op_A_i | s_op_B_i;
			end
			`AND: begin
				s_result_o <= s_op_A_i & s_op_B_i;
			end
			`MUL: begin
				mul_result = (A_signed * B_signed);
				s_result_o <=  mul_result[31:0];
			end
			`MULH: begin
				mul_result = (A_signed * B_signed);
				s_result_o <=  mul_result[63:32];
			end
			`MULHSU: begin
				mul_result = (A_signed * s_op_B_i);
				s_result_o <=  mul_result[63:32];
			end
			`MULHU: begin
				mul_result = (s_op_A_i * s_op_B_i);
				s_result_o <=  mul_result[63:32];
			end
			`DIV: begin
				s_result_o <= A_signed / B_signed;
			end
			`DIVU: begin
				s_result_o <= s_op_A_i / s_op_B_i;
			end
			`REM: begin
				s_result_o <= A_signed % B_signed;
			end
			`REMU: begin
				s_result_o <= s_op_A_i % s_op_B_i;
			end

			default: begin
				s_result_o <= 32'b0;
			end
		endcase
    end
endmodule
