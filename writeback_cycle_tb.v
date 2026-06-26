`timescale 1ns/1ps
module writeback_cycle_tb();

// Inputs
reg clk = 0, rst = 0;
reg ResultSrcW = 0;
reg [31:0] PCPlus4W = 32'b0, ALU_ResultW = 32'b0, ReadDataW = 32'b0;

// Outputs
wire [31:0] ResultW;

// Instantiate
writeback_cycle dut(
    .clk(clk),
    .rst(rst),
    .ResultSrcW(ResultSrcW),
    .PCPlus4W(PCPlus4W),
    .ALU_ResultW(ALU_ResultW),
    .ReadDataW(ReadDataW),
    .ResultW(ResultW)
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

    // Test 1 ? ALU result selected (R-type/I-type)
    // ResultSrcW=0 ? ResultW should be ALU_ResultW
    ResultSrcW = 0;
    ALU_ResultW = 32'h00000009;   // add result
    ReadDataW   = 32'hDEADBEEF;   // memory data (ignored)
    PCPlus4W    = 32'h00000004;
    #100;

    // Test 2 ? Memory result selected (LW)
    // ResultSrcW=1 ? ResultW should be ReadDataW
    ResultSrcW = 1;
    ALU_ResultW = 32'h00000009;   // ALU result (ignored)
    ReadDataW   = 32'hDEADBEEF;   // memory data selected
    PCPlus4W    = 32'h00000008;
    #100;

    // Test 3 ? Switch back to ALU result
    ResultSrcW = 0;
    ALU_ResultW = 32'hCAFEBABE;
    ReadDataW   = 32'h00000000;
    PCPlus4W    = 32'h0000000C;
    #100;

    // Test 4 ? Zero values
    ResultSrcW = 0;
    ALU_ResultW = 32'h00000000;
    ReadDataW   = 32'h00000000;
    #100;

    // Test 5 ? Toggle ResultSrcW rapidly
    ALU_ResultW = 32'hAAAAAAAA;
    ReadDataW   = 32'h55555555;
    ResultSrcW = 0;   // expect ResultW = AAAAAAAA
    #100;
    ResultSrcW = 1;   // expect ResultW = 55555555
    #100;
    ResultSrcW = 0;   // back to AAAAAAAA
    #100;

    #500;
    $finish;
end

endmodule
