module arm(input         clk, reset,
           output        MemWrite,
           output [31:0] Adr, WriteData,
           input  [31:0] ReadData);

  wire [31:0] Instr;
  wire [3:0]  ALUFlags, ALUControl;
  wire        PCWrite, RegWrite, IRWrite;
  wire        AdrSrc;
  wire [1:0]  RegSrc, ALUSrcA, ALUSrcB, ImmSrc, ResultSrc;

  controller c(.clk(clk), 
               .reset(reset), 
               .Instr(Instr[31:12]), 
               .ALUFlags(ALUFlags), 
               .PCWrite(PCWrite), 
               .MemWrite(MemWrite), 
               .RegWrite(RegWrite), 
               .IRWrite(IRWrite), 
               .AdrSrc(AdrSrc), 
               .RegSrc(RegSrc), 
               .ALUSrcA(ALUSrcA), 
               .ALUSrcB(ALUSrcB), 
               .ResultSrc(ResultSrc), 
               .ImmSrc(ImmSrc), 
               .ALUControl(ALUControl));
  datapath dp(.clk(clk), 
              .reset(reset), 
              .Adr(Adr), 
              .WriteData(WriteData), 
              .ReadData(ReadData), 
              .Instr(Instr), 
              .ALUFlags(ALUFlags), 
              .PCWrite(PCWrite), 
              .RegWrite(RegWrite), 
              .IRWrite(IRWrite), 
              .AdrSrc(AdrSrc), 
              .RegSrc(RegSrc), 
              .ALUSrcA(ALUSrcA), 
              .ALUSrcB(ALUSrcB), 
              .ResultSrc(ResultSrc), 
              .ImmSrc(ImmSrc), 
              .ALUControl(ALUControl));
endmodule