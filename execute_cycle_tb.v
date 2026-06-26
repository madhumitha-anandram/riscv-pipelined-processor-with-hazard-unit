`timescale 1ns/1ps
module execute_cycle_tb();

// Inputs
reg clk = 0, rst = 0;
reg RegWriteE = 0, ALUSrcE = 0, MemWriteE = 0, ResultSrcE = 0, BranchE = 0;
reg [2:0] ALUControlE = 3'b000;
reg [31:0] RD1_E = 32'b0, RD2_E = 32'b0, Imm_Ext_E = 32'b0;
reg [4:0] RD_E = 5'b0;
reg [31:0] PCE = 32'b0, PCPlus4E = 32'b0;

// Outputs
wire PCSrcE, RegWriteM, MemWriteM, ResultSrcM;
wire [4:0] RD_M;
wire [31:0] PCPlus4M, WriteDataM, ALU_ResultM, PCTargetE;

// Instantiate
execute_cycle dut(
    .clk(clk),
    .rst(rst),
    .RegWriteE(RegWriteE),
    .ALUSrcE(ALUSrcE),
    .MemWriteE(MemWriteE),
    .ResultSrcE(ResultSrcE),
    .BranchE(BranchE),
    .ALUControlE(ALUControlE),
    .RD1_E(RD1_E),
    .RD2_E(RD2_E),
    .Imm_Ext_E(Imm_Ext_E),
    .RD_E(RD_E),
    .PCE(PCE),
    .PCPlus4E(PCPlus4E),
    .PCSrcE(PCSrcE),
    .PCTargetE(PCTargetE),
    .RegWriteM(RegWriteM),
    .MemWriteM(MemWriteM),
    .ResultSrcM(ResultSrcM),
    .RD_M(RD_M),
    .PCPlus4M(PCPlus4M),
    .WriteDataM(WriteDataM),
    .ALU_ResultM(ALU_ResultM)
);

// Clock
always begin
    clk = ~clk;
    #50;
end

initial begin
    // Release reset
    rst = 0;
    #200;
    rst = 1;

    // Test 1 ? ADD (R-type)
    // add x6, x5, x6 ? RD1=5, RD2=4, expect Result=9
    RegWriteE = 1;
    ALUSrcE = 0;        // use RD2 not immediate
    MemWriteE = 0;
    ResultSrcE = 0;
    BranchE = 0;
    ALUControlE = 3'b000; // ADD
    RD1_E = 32'h00000005;
    RD2_E = 32'h00000004;
    Imm_Ext_E = 32'h00000000;
    RD_E = 5'd6;
    PCE = 32'h00000000;
    PCPlus4E = 32'h00000004;
    #100;

    // Test 2 ? ADDI (I-type)
    // addi x5, x0, 5 ? RD1=0, Imm=5, expect Result=5
    RegWriteE = 1;
    ALUSrcE = 1;        // use immediate
    MemWriteE = 0;
    ResultSrcE = 0;
    BranchE = 0;
    ALUControlE = 3'b000; // ADD
    RD1_E = 32'h00000000;
    RD2_E = 32'h00000000;
    Imm_Ext_E = 32'h00000005;
    RD_E = 5'd5;
    PCE = 32'h00000004;
    PCPlus4E = 32'h00000008;
    #100;

    // Test 3 ? SUB
    // sub x1, x5, x6 ? RD1=9, RD2=4, expect Result=5
    RegWriteE = 1;
    ALUSrcE = 0;
    MemWriteE = 0;
    ResultSrcE = 0;
    BranchE = 0;
    ALUControlE = 3'b001; // SUB
    RD1_E = 32'h00000009;
    RD2_E = 32'h00000004;
    Imm_Ext_E = 32'h00000000;
    RD_E = 5'd1;
    PCE = 32'h00000008;
    PCPlus4E = 32'h0000000C;
    #100;

    // Test 4 ? SW (S-type)
    // sw x6, 8(x5) ? MemWrite=1, ALUSrc=1, Imm=8
    RegWriteE = 0;
    ALUSrcE = 1;        // use immediate for address
    MemWriteE = 1;      // write to memory
    ResultSrcE = 0;
    BranchE = 0;
    ALUControlE = 3'b000; // ADD for address calc
    RD1_E = 32'h00000005; // base address
    RD2_E = 32'h00000004; // data to store
    Imm_Ext_E = 32'h00000008; // offset
    RD_E = 5'd0;
    PCE = 32'h0000000C;
    PCPlus4E = 32'h00000010;
    #100;

    // Test 5 ? BEQ taken
    // beq x5, x5 ? RD1=RD2, Zero=1, Branch=1, PCSrcE should be 1
    RegWriteE = 0;
    ALUSrcE = 0;
    MemWriteE = 0;
    ResultSrcE = 0;
    BranchE = 1;        // branch enabled
    ALUControlE = 3'b001; // SUB to compare
    RD1_E = 32'h00000005;
    RD2_E = 32'h00000005; // equal ? Zero=1
    Imm_Ext_E = 32'h00000008; // branch offset
    RD_E = 5'd0;
    PCE = 32'h00000010;
    PCPlus4E = 32'h00000014;
    #100;

    // Test 6 ? BEQ not taken
    // beq x5, x6 ? RD1!=RD2, Zero=0, PCSrcE should be 0
    BranchE = 1;
    ALUControlE = 3'b001; // SUB
    RD1_E = 32'h00000005;
    RD2_E = 32'h00000004; // not equal ? Zero=0
    #100;

    #500;
    $finish;
end

endmodule
