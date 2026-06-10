module tb_memory;

	logic s_clk_i;
	logic s_resetn_i;
	logic [31:0] s_val;
	logic [31:0] s_add;
	logic s_write;

	memory #(.SIZE(1024)) mem (
		.s_clk_i(s_clk_i),
		.s_resetn_i(s_resetn_i),
		.s_add_i(s_add),
		.s_val_i(0),
		.s_write_i(s_write),
		.s_val_o(s_val)
	);
	
	always #5 s_clk_i = ~s_clk_i;
	 
	initial begin
		s_clk_i = 0;
	
		mem.r_buffer[0] = 32'h93010000;
		mem.r_buffer[1] = 32'h6F000005;
		mem.r_buffer[2] = 32'h23A08101;
		mem.r_buffer[3] = 32'h23A29101;
		mem.r_buffer[4] = 32'h23A4A101;
		mem.r_buffer[5] = 32'h23A6B101;
		mem.r_buffer[6] = 32'h23A8C101;
		mem.r_buffer[7] = 32'h23AAD101;
		mem.r_buffer[8] = 32'h23ACE101;
		mem.r_buffer[9] = 32'h23AEF101;
		s_resetn_i = 1'b0;
		#10
		
		s_resetn_i = 1'b1;
		
		s_add = 32'h00000000; s_write = '0;
		#10
		$display("Data from addr 0x%x: 0x%x", s_add, s_val);
		
		s_add = 32'h00000004; s_write = '0;
		#10
		$display("Data from addr 0x%x: 0x%x", s_add, s_val);
		
		s_add = 32'h00000008; s_write = '0;
		#10
		$display("Data from addr 0x%x: 0x%x", s_add, s_val);
		#100
		$display("Data from addr 0x%x: 0x%x", s_add, s_val);
		
		s_add = 32'h0000000C; s_write = '0;
		#10
		$display("Data from addr 0x%x: 0x%x", s_add, s_val);
		
		s_add = 32'h00000010; s_write = '0;
		#10
		$display("Data from addr 0x%x: 0x%x", s_add, s_val);
		
		s_add = 32'h00000014; s_write = '0;
		#10
		$display("Data from addr 0x%x: 0x%x", s_add, s_val);
		
		s_add = 32'h00000018; s_write = '0;
		#10
		$display("Data from addr 0x%x: 0x%x", s_add, s_val);
		
		s_add = 32'h0000001C; s_write = '0;
		#10
		$display("Data from addr 0x%x: 0x%x", s_add, s_val);
		
		#100
		$display("Data from addr 0x%x: 0x%x", s_add, s_val);
		
		$stop;
	end

endmodule