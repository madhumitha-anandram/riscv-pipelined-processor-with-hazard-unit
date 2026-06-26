`timescale 1ns/1ps

module fetch_cycle_tb();
reg clk = 0, rst=1,PCSrcE=1'b0;
reg [31:0] PCTargetE;
wire [31:0] InstrD;
wire [31:0] PCD,PCPlus4D;

fetch_cycle dut(.clk(clk),.rst(rst),.PCSrcE(PCSrcE),.PCTargetE(PCTargetE),.InstrD(InstrD),.PCD(PCD),.PCPlus4D(PCPlus4D));

always begin
clk = ~clk;
#50;
end

initial begin
rst=1'b0;
PCSrcE=1'b0;
PCTargetE=32'h00000000;
#200;
rst=1'b1; 
#2000;
$finish;
end

endmodule
