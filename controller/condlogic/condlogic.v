module condlogic(input        clk, reset,
                 input  [3:0] Cond,
                 input  [3:0] ALUFlags,
                 input  [1:0] FlagW,
                 input        PCS, NextPC, RegW, MemW,
                 output       PCWrite, RegWrite, MemWrite);

  wire [1:0] FlagWrite;
  wire [3:0] Flags;
  wire       CondEx, CondExR;


  // Delay writing flags until ALUWB state
  assign FlagWrite = FlagW&{2{CondEx}};
  
  ff_resen #(2)flagreg1(.clk(clk), 
                       .reset(reset), 
                       .en(FlagWrite[1]), 
                       .d(ALUFlags[3:2]), 
                       .q(Flags[3:2]));
  ff_resen #(2)flagreg0(.clk(clk),
                       .reset(reset),
                       .en(FlagWrite[0]),
                       .d(ALUFlags[1:0]),
                       .q(Flags[1:0]));

  // write controls are conditional
  condcheck cc(Cond, Flags, CondEx);

  ff_res #(1)condexreg(clk, reset, CondEx, CondExR);

  assign RegWrite  = RegW   & CondExR;
  assign MemWrite  = MemW   & CondExR;
  assign PCWrite   = (PCS   & CondExR) | NextPC;

endmodule    

module condcheck(input  [3:0] Cond,
                 input  [3:0] Flags,
                 output reg   CondEx);

  wire neg, zero, carry, overflow, ge;
  
  assign {neg, zero, carry, overflow} = Flags;
  assign ge = (neg == overflow);
                  
  always @(*)
    case(Cond)
      4'b0000: CondEx = zero;             // EQ
      4'b0001: CondEx = ~zero;            // NE
      4'b0010: CondEx = carry;            // CS
      4'b0011: CondEx = ~carry;           // CC
      4'b0100: CondEx = neg;              // MI
      4'b0101: CondEx = ~neg;             // PL
      4'b0110: CondEx = overflow;         // VS
      4'b0111: CondEx = ~overflow;        // VC
      4'b1000: CondEx = carry & ~zero;    // HI
      4'b1001: CondEx = ~(carry & ~zero); // LS
      4'b1010: CondEx = ge;               // GE
      4'b1011: CondEx = ~ge;              // LT
      4'b1100: CondEx = ~zero & ge;       // GT
      4'b1101: CondEx = ~(~zero & ge);    // LE
      4'b1110: CondEx = 1'b1;             // Always
      default: CondEx = 1'bx;             // undefined
    endcase

endmodule