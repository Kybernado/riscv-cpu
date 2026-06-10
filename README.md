# riscv-cpu

- 32bit RISC-V CPU (RV32I subset + multiplication) done as a project on SPRO subject at Faculty of Informatics and Information Technologies, STU
- Harvard architecture - separate program memory and data memory buses
- multicycle design - one instruction takes 5 clock cycles (CPI = 5)
- asynchronous active-low reset, boot address configurable via input port
- written in SystemVerilog

## How it works

The core is a 5-state FSM (`cpu_top.sv`) that every instruction passes through:

```
FETCH -> DECODE -> EXECUTE -> MEMORY -> WRITEBACK
```

- **FETCH** - program counter (`r_pc`) is presented on the instruction bus, memory latches the address
- **DECODE** - the fetched instruction is decoded combinationally by `decoder`, operands are loaded into ALU input registers (`r_op_1`, `r_op_2`), jump target / memory address is precomputed, PC is incremented
- **EXECUTE** - ALU computes the result, unconditional/conditional jumps update the PC
- **MEMORY** - address phase of LW/SW on the data bus
- **WRITEBACK** - result from ALU or data memory is written into the destination register

### Modules

| file | description |
|---|---|
| `cpu_top.sv` | top module - FSM, program counter, register file (x0-x31), bus handling |
| `decoder.sv` | combinational instruction decoder - extracts opcode/funct3/funct7, register numbers, immediate value and operand-usage flags (`use_rs1/rs2/imm/pc`) used to distinguish instruction formats (R/I/S/B/U/J) |
| `decoder_instructions.sv` | defines of opcodes, funct3 and funct7 values for all instructions |
| `alu.sv` | sequential ALU - arithmetic, logic, shifts, comparisons for branches, multiplication |
| `alu_operations.sv` | defines of internal ALU operation codes |
| `memory.sv` | simple synchronous memory model used as both program and data memory in testbenches |

### Supported instructions

- **control flow:** JAL, JALR, BEQ, BNE, BLT, BGE, BLTU, BGEU
- **ALU (register):** ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
- **ALU (immediate):** ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
- **multiplication:** MUL, MULH, MULHSU, MULHU (+ DIV/DIVU/REM/REMU implemented in ALU as extra)
- **memory:** LW, SW (32-bit, 4-byte aligned only)
- **other:** LUI, AUIPC

An instruction that cannot be decoded stops execution and raises the `ERROR` output.

### Memory bus protocol

Two-phase access: in the first (address) cycle the address is presented together with the write signal, in the second (data) cycle data is either written or read back. Data is stored little-endian. Address and data phases of consecutive transfers may overlap.

## Testing

> TODO: describe simulation setup and test programs

- `tb_cpu.sv`, `tb_alu.sv`, `tb_decoder.sv`, `tb_memory.sv` - unit testbenches for individual modules
- `testbench.sv` - full system testbench that loads a program from `test.vh`, runs it and compares data memory contents against `reference.vh`

## Known issues

- **jump/branch instructions do not work correctly** - control flow instructions may transfer execution to a wrong address or misbehave in other ways; the rest of the instruction set is not affected by this
- alignment checks required by the assignment (misaligned jump target / misaligned memory access -> ERROR) are not implemented
- debug `$display` output is printed every cycle, which makes longer simulations noisy
- debug $display present also in files that should be synthesizable

## Notes

- this was a semester assignment, the design favors simplicity and readability over performance - no pipelining, no hazard handling needed thanks to the multicycle FSM
- register x0 is implemented as a regular register in the register file
