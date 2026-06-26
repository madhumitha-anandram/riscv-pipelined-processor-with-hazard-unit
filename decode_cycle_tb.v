`timescale 1ns/1ps
module decode_cycle_tb();

// Inputs
reg clk = 0, rst = 0;
reg RegWriteW = 0;
reg [4:0] RDW = 5'b0;
reg [31:0] InstrD = 32'b0;
reg [31:0] PCD = 32'b0;
reg [31:0] PCPlus4D = 32'b0;
reg [31:0] ResultW = 32'b0;

// Outputs
wire RegWriteE, ALUSrcE, MemWriteE, ResultSrcE, BranchE;
wire [2:0] ALUControlE;
wire [31:0] RD1_E, RD2_E, Imm_Ext_E;
wire [4:0] RD_E;
wire [31:0] PCE, PCPlus4E;

// Instantiate
decode_cycle dut(
    .clk(clk),
    .rst(rst),
    .InstrD(InstrD),
    .PCD(PCD),
    .PCPlus4D(PCPlus4D),
    .RegWriteW(RegWriteW),
    .RDW(RDW),
    .ResultW(ResultW),
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
    .PCPlus4E(PCPlus4E)
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

    // Test 1 ? ADD instruction (R-type)
    // add x6, x5, x6 ? 0062E233 (from your memfile)
    InstrD = 32'h0062E233;
    PCD = 32'h00000000;
    PCPlus4D = 32'h00000004;
    #100;

    // Test 2 ? ADDI instruction (I-type)
    // addi x5, x0, 5 ? 00500293
    InstrD = 32'h00500293;
    PCD = 32'h00000004;
    PCPlus4D = 32'h00000008;
    #100;

    // Test 3 ? SW instruction (S-type)
    // sw x6, 8(x5) ? 0062A423
    InstrD = 32'h0062A423;
    PCD = 32'h00000008;
    PCPlus4D = 32'h0000000C;
    #100;

    // Test 4 ? LW instruction (I-type)
    // lw x8, 0(x5) ? 00002403  
    InstrD = 32'h00002403;
    PCD = 32'h0000000C;
    PCPlus4D = 32'h00000010;
    #100;

    // Test 5 ? Write back to register file
    // Write 32'hDEADBEEF to register x5
    RegWriteW = 1;
    RDW = 5'd5;
    ResultW = 32'hDEADBEEF;
    #100;
    RegWriteW = 0;

    #500;
    $finish;
end

endmodule
