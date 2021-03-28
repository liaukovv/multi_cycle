module decode(input        clk, reset,
              input  [1:0] Op,
              input  [5:0] Funct,
              input  [3:0] Rd,
              output reg [1:0] FlagW,
              output       PCS, NextPC, RegW, MemW,
              output       IRWrite, AdrSrc,
              output [1:0] ResultSrc, ALUSrcA, ALUSrcB, 
              output [1:0] ImmSrc, RegSrc, 
              output reg [3:0] ALUControl);

  wire Branch, ALUOp;

  // Main FSM
  mainfsm fsm(clk, reset, Op, Funct, 
              IRWrite, AdrSrc, 
              ALUSrcA, ALUSrcB, ResultSrc,
              NextPC, RegW, MemW, Branch, ALUOp);

  // ALU Decoder
  always @(*)
    if (ALUOp) begin                 // which DP Instr?
      case(Funct[4:1]) 
  	    4'b0100: ALUControl = 4'b0000; // ADD
  	    4'b0010: ALUControl = 4'b0010; // SUB
        4'b0000: ALUControl = 4'b0100; // AND
  	    4'b1100: ALUControl = 4'b0101; // ORR
        4'b0001: ALUControl = 4'b0110; // EOR  
  	    default: ALUControl = 4'bx;  // unimplemented
      endcase
  // update flags if S bit is set 
	// (C & V only updated for arith instructions)
      FlagW[1] = Funct[0]; // FlagW[1] = S-bit
	// FlagW[0] = S-bit & (ADD | SUB)
      FlagW[0] = Funct[0] & 
                 (ALUControl == 4'b0000 | ALUControl == 4'b0010); 
    end else begin
      ALUControl = 4'b0000; // add for non-DP instructions
      FlagW      = 2'b00; // don't update Flags
    end

  // PC Logic
  assign PCS = ((Rd == 4'b1111) & RegW) | Branch; 

  // Instr Decoder
  assign ImmSrc = Op;
  
  assign RegSrc = (Op == 2'b01) ? 2'b10 :
                  (Op == 2'b00) ? 2'b00 :
                                  2'b01 ;

endmodule