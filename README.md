## What this project does

Extends the single-cycle RISC-V processor into a 5-stage pipeline — the same structure used in real processors like ARM Cortex-A and RISC-V cores. Pipelining allows multiple instructions to execute simultaneously in different stages, dramatically increasing throughput. This project also implements a hazard unit that handles data hazards through forwarding, eliminating the need for pipeline stalls.

## The 5 stages

[FETCH] → [DECODE] → [EXECUTE] → [MEMORY] → [WRITEBACK]

F           D           E           M           W

While instruction N is in EXECUTE, instruction N+1 is in DECODE and instruction N+2 is in FETCH — all at the same time.

Pipeline registers

Between each stage, there is a set of registers that capture the outputs of that stage and hold them for the next clock cycle. These are the inter-stage pipeline registers:

F/D register: InstrD, PCD, PCPlus4D

D/E register: RD1_E, RD2_E, Imm_Ext_E, PCE, PCPlus4E, RD_E, all control signals

E/M register: ALU_ResultM, WriteDataM, RD_M, PCPlus4M, all control signals

M/W register: ALU_ResultW, ReadDataW, RD_W, PCPlus4W, all control signals

Each stage only sees the values in its input register — it cannot directly observe what earlier stages are doing.

The data hazard problem

Consider this sequence:

ADD x1, x2, x3    # instruction 1 — computes x1 = x2 + x3

SUB x4, x1, x5    # instruction 2 — needs x1, but it's not written yet!

When SUB is in the EXECUTE stage, ADD is in the MEMORY stage — x1 has been computed in the ALU but hasn't been written to the register file yet. If SUB reads from the register file, it gets the old (wrong) value of x1.

The hazard unit — how forwarding solves this

Instead of stalling the pipeline (inserting empty cycles), the hazard unit forwards the correct value directly from where it was computed to where it is needed.

// ForwardAE — selects the correct value for ALU input A in the Execute stage

assign ForwardAE =

(RegWriteM && RD_M != 0 && RD_M == Rs1_E) ? 2'b10 :  // forward from MEM stage

(RegWriteW && RD_W != 0 && RD_W == Rs1_E) ? 2'b01 :  // forward from WB stage

2'b00;                                                  // use register file value

ForwardAE = 2'b10 → use the value currently in the MEMORY stage (one instruction back) ForwardAE = 2'b01 → use the value currently in the WRITEBACK stage (two instructions back) ForwardAE = 2'b00 → no hazard, use the value from the register file normally

The same logic applies to ForwardBE for ALU input B. Both forwarding paths are checked simultaneously in combinational logic — no clock cycle is wasted.

Before and after the hazard unit

Without the hazard unit, the processor reads stale register values:

Instruction 2's ALU computes with old x1 → wrong result

With the hazard unit, the forwarding mux in the EXECUTE stage selects the fresh ALU result from the MEMORY stage:

Instruction 2's ALU gets the correct x1 value → correct result

The simulation waveforms in this repository show exactly this — screenshots before insertion of the hazard unit (wrong values) and after (correct values).

Instruction memory — loading a program

Instructions are loaded from memfile.hex into the instruction memory at simulation start. The testbench runs the pipeline with this program and you can observe all 5 stages executing instructions simultaneously in the waveform.

Stage-by-stage module breakdown

| Module | File | What it does |
| --- | --- | --- |
| Fetch | fetch_cycle.v | PC register, instruction memory read, PC+4 |
| Decode | decode_cycle.v / decode_cycle_hazard.v | Register file, control unit, immediate extension, pipeline register |
| Execute | execute_cycle.v / execute_cycle_hazard.v | ALU, branch target, forwarding muxes |
| Memory | memory_cycle.v | Data memory read/write, pipeline register |
| Writeback | writeback_cycle.v | Selects result (ALU / memory / PC+4) to write back |
| Hazard Unit | hazard_unit.v | Computes ForwardAE and ForwardBE for data forwarding |
| Pipeline Top (no hazard) | pipeline_top.v | Full 5-stage pipeline without forwarding |
| Pipeline Top (with hazard) | pipeline_top_hazard.v | Full 5-stage pipeline with hazard unit inserted |

## File structure

fetch_cycle.v / fetch_cycle_tb.v

decode_cycle.v / decode_cycle_hazard.v / decode_cycle_tb.v

execute_cycle.v / execute_cycle_hazard.v / execute_cycle_tb.v

memory_cycle.v / memory_cycle_tb.v

writeback_cycle.v / writeback_cycle_tb.v

hazard_unit.v

pipeline_top.v / pipeline_top_tb.v

pipeline_top_hazard.v / pipeline_top_hazard_tb.v

ALU.v / ALU_Decoder.v / Control_Unit_Top.v / Main_Decoder.v

Instruction_Memory.v / Data_Memory.v

Register_File.v / PC.v / PC_Adder.v / Sign_Extend.v

Mux.v / Mux_3_by_1.v

memfile.hex
