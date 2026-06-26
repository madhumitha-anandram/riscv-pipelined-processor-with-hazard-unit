`timescale 1ns/1ps
module memory_cycle_tb();

// Inputs
reg clk = 0, rst = 0;
reg RegWriteM = 0, MemWriteM = 0, ResultSrcM = 0;
reg [4:0] RD_M = 5'b0;
reg [31:0] PCPlus4M = 32'b0, WriteDataM = 32'b0, ALU_ResultM = 32'b0;

// Outputs
wire RegWriteW, ResultSrcW;
wire [4:0] RD_W;
wire [31:0] PCPlus4W, ALU_ResultW, ReadDataW;

// Instantiate
memory_cycle dut(
    .clk(clk),
    .rst(rst),
    .RegWriteM(RegWriteM),
    .MemWriteM(MemWriteM),
    .ResultSrcM(ResultSrcM),
    .RD_M(RD_M),
    .PCPlus4M(PCPlus4M),
    .WriteDataM(WriteDataM),
    .ALU_ResultM(ALU_ResultM),
    .RegWriteW(RegWriteW),
    .ResultSrcW(ResultSrcW),
    .RD_W(RD_W),
    .PCPlus4W(PCPlus4W),
    .ALU_ResultW(ALU_ResultW),
    .ReadDataW(ReadDataW)
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

    // Test 1 ? SW (store word)
    // Write 32'hDEADBEEF to address 0x00000008
    RegWriteM = 0;
    MemWriteM = 1;          // write to memory
    ResultSrcM = 0;
    RD_M = 5'd0;
    ALU_ResultM = 32'h00000008;   // address
    WriteDataM = 32'hDEADBEEF;    // data to write
    PCPlus4M = 32'h00000004;
    #100;

    // Test 2 ? LW (load word)
    // Read from address 0x00000008 ? should get 32'hDEADBEEF
    RegWriteM = 1;
    MemWriteM = 0;          // read from memory
    ResultSrcM = 1;         // result comes from memory
    RD_M = 5'd8;
    ALU_ResultM = 32'h00000008;   // same address as store
    WriteDataM = 32'h00000000;
    PCPlus4M = 32'h00000008;
    #100;

    // Test 3 ? ALU result passthrough (R-type/I-type)
    // No memory access, just pass ALU result
    RegWriteM = 1;
    MemWriteM = 0;
    ResultSrcM = 0;         // result comes from ALU
    RD_M = 5'd5;
    ALU_ResultM = 32'h00000009;   // ALU result e.g add x5+x6
    WriteDataM = 32'h00000000;
    PCPlus4M = 32'h0000000C;
    #100;

    // Test 4 ? Store then Load different address
    // SW: write 32'hCAFEBABE to address 0x00000010
    RegWriteM = 0;
    MemWriteM = 1;
    ResultSrcM = 0;
    RD_M = 5'd0;
    ALU_ResultM = 32'h00000010;
    WriteDataM = 32'hCAFEBABE;
    PCPlus4M = 32'h00000010;
    #100;

    // LW: read back from address 0x00000010
    RegWriteM = 1;
    MemWriteM = 0;
    ResultSrcM = 1;
    RD_M = 5'd6;
    ALU_ResultM = 32'h00000010;
    WriteDataM = 32'h00000000;
    PCPlus4M = 32'h00000014;
    #100;

    // Test 5 ? Reset check
    // Apply reset and verify all outputs go to 0
    rst = 0;
    #100;
    rst = 1;
    #100;

    #500;
    $finish;
end

endmodule
