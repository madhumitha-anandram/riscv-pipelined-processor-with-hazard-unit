module fetch_cycle(clk,rst,PCSrcE,PCTargetE,InstrD,PCD,PCPlus4D);

input clk, rst,PCSrcE;
input [31:0] PCTargetE;

output [31:0] PCD, PCPlus4D, InstrD;
wire [31:0] PC_F,PCF,PCPlus4F,InstrF;

//initiation of modules

Mux PC_Mux (.a(PCPlus4F),
            .b(PCTargetE),
            .s(PCSrcE),.c(PC_F));

PC program_counter(.clk(clk),.rst(rst),.PC(PCF),.PC_Next(PC_F));

Instruction_Memory IMEM(.rst(rst),.A(PCF),.RD(InstrF));

PC_Adder adder(.a(PCF),.b(32'h00000004),.c(PCPlus4F));

//declaration of registers 
reg[31:0] InstrF_r,PCF_r,PCPlus4F_r;

always@(posedge clk or negedge rst)begin
 if(rst==1'b0) begin
InstrF_r<=32'd0;
PCF_r<=32'd0;
PCPlus4F_r<=32'd0;
end
else begin
InstrF_r<=InstrF;
PCF_r<=PCF;
PCPlus4F_r<=PCPlus4F;
end
end

assign PCD = (rst==1'b0)?32'd0:PCF_r;
assign PCPlus4D = (rst==1'b0)?32'd0:PCPlus4F_r;
assign InstrD = (rst==1'b0)?32'd0:InstrF_r;
endmodule
