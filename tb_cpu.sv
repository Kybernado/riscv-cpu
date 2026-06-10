module tb_cpu;

    // Testbench signals
    logic s_clk_i;
    logic s_resetn_i;
    logic [31:0] s_boot_add_i;
    logic [31:0] s_ibus_val_i;
    logic s_ibus_write_o;
    logic [31:0] s_ibus_add_o;
    logic [31:0] s_ibus_val_o;
    logic [31:0] s_dbus_val_i;
    logic s_dbus_write_o;
    logic [31:0] s_dbus_add_o;
    logic [31:0] s_dbus_val_o;

    // Instantiate CPU
    cpu_top cpu_inst (
        .s_clk_i(s_clk_i),
        .s_resetn_i(s_resetn_i),
        .s_boot_add_i(s_boot_add_i),
        .s_error_o(),
        .s_ibus_val_i(s_ibus_val_i),
        .s_ibus_write_o(s_ibus_write_o),
        .s_ibus_add_o(s_ibus_add_o),
        .s_ibus_val_o(s_ibus_val_o),
        .s_dbus_val_i(s_dbus_val_i),
        .s_dbus_write_o(s_dbus_write_o),
        .s_dbus_add_o(s_dbus_add_o),
        .s_dbus_val_o(s_dbus_val_o)
    );

    // Instantiate program memory
    memory #(.SIZE(1024)) prog_mem (
        .s_clk_i(s_clk_i),
        .s_resetn_i(s_resetn_i),
        .s_add_i(s_ibus_add_o),
        .s_val_i(s_ibus_val_o),
        .s_write_i(s_ibus_write_o),
        .s_val_o(s_ibus_val_i)
    );

    // Instantiate data memory
    memory #(.SIZE(1024)) data_mem (
        .s_clk_i(s_clk_i),
        .s_resetn_i(s_resetn_i),
        .s_add_i(s_dbus_add_o),
        .s_val_i(s_dbus_val_o),
        .s_write_i(s_dbus_write_o),
        .s_val_o(s_dbus_val_i)
    );

    // Clock generation
    always #5 s_clk_i = ~s_clk_i; // 10-timeunit clock period

    // Testbench initialization
    initial begin
        // Initialize signals
        s_clk_i = 0;
        s_resetn_i = 0; // Active-low reset
        s_boot_add_i = 32'h00000000; // Start from address 0x0

        // Reset the system
        #10 s_resetn_i = 1;

        // Load random instructions into program memory
        prog_mem.r_buffer[0] = 32'h93010000; // Random instruction
		prog_mem.r_buffer[1] = 32'h6F000005; // Random instruction
		prog_mem.r_buffer[2] = 32'h23A08101; // Random instruction
		prog_mem.r_buffer[3] = 32'h23A29101; // Random instruction
		prog_mem.r_buffer[4] = 32'h23A4A101; // Random instruction
		prog_mem.r_buffer[5] = 32'h23A6B101; // Random instruction
		prog_mem.r_buffer[6] = 32'h23A8C101; // Random instruction
		prog_mem.r_buffer[7] = 32'h23AAD101; // Random instruction
		prog_mem.r_buffer[8] = 32'h23ACE101; // Random instruction
		prog_mem.r_buffer[9] = 32'h23AEF101; // Random instruction

        // Run the CPU for 10 clock cycles
        repeat (50) @(posedge s_clk_i);

        // End simulation
        $display("Simulation finished");
        $stop;
    end

endmodule