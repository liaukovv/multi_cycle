module controller(input          clk,
                  input          reset,
                  input  [31:12] Instr,
                  input  [3:0]   ALUFlags,
                  output         PCWrite,
                  output         MemWrite,
                  output         RegWrite,
                  output         IRWrite,
                  output         AdrSrc,
                  output [1:0]   RegSrc,
                  output [1:0]   ALUSrcA,
                  output [1:0]   ALUSrcB,
                  output [1:0]   ResultSrc,
                  output [1:0]   ImmSrc,
                  output [3:0]   ALUControl);
                  
  wire [1:0] FlagW;
  wire       PCS, NextPC, RegW, MemW;
  
  decode dec(clk, reset, Instr[27:26], Instr[25:20], Instr[15:12],
             FlagW, PCS, NextPC, RegW, MemW,
             IRWrite, AdrSrc, ResultSrc, 
             ALUSrcA, ALUSrcB, ImmSrc, RegSrc, ALUControl);
  condlogic cl(clk, reset, Instr[31:28], ALUFlags,
               FlagW, PCS, NextPC, RegW, MemW,
               PCWrite, RegWrite, MemWrite);
endmodule