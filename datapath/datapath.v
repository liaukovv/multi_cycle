module datapath(input         clk, reset,
                output [31:0] Adr, WriteData,
                input  [31:0] ReadData,
                output [31:0] Instr,
                output [3:0]  ALUFlags,
                input         PCWrite, RegWrite,
                input         IRWrite,
                input         AdrSrc, 
                input  [1:0]  RegSrc, 
                input  [1:0]  ALUSrcA, ALUSrcB, ResultSrc,
                input  [1:0]  ImmSrc, 
                input  [3:0]  ALUControl);

    wire [31:0] PCNext, PC;
    wire [31:0] ExtImm, SrcA, SrcB, Result;
    wire [31:0] Data, RD1, RD2, A, ALUResult, ALUOut;
    wire [3:0]  RA1, RA2;
    
    // this flip-flop holds current PC value
    ff_resen #(32) pcreg(.clk(clk), .reset(reset), .en(PCWrite), .d(Result), .q(PC));
    
    // select next adr source, either pc for instr fetch or alu result for branches/mem ops
    mux2 #(32)  pcmux(.a(PC), .b(Result), .sel(AdrSrc), .y(Adr));
    
    // this flip-flop holds fetched instruction for decoding
    ff_resen #(32) instreg(.clk(clk), .reset(reset), .en(IRWrite), .d(ReadData), .q(Instr));
  
    // holds read data for writebacks
    ff_res #(32) datareg(.clk(clk), .reset(reset), .d(ReadData), .q(Data));
  
    // select address for first port of reg file
    mux2 #(4) ra1mux(.a(Instr[19:16]), .b(4'b1111), .sel(RegSrc[0]), .y(RA1));
    // select address for second port of reg file
    mux2 #(4) ra2mux(.a(Instr[3:0]), .b(Instr[15:12]), .sel(RegSrc[1]), .y(RA2));
    // register file, for r15 always outputs pc+8
    regs register_file(.clk(clk),
                       .reset(reset),
                       .we3(RegWrite),
                       .ra1(RA1),
                       .ra2(RA2),
                       .wa3(Instr[15:12]),
                       .wd3(Result),
                       .r15(Result),
                       .rd1(RD1),
                       .rd2(RD2));
    
    // holds read register data from port 1
    ff_res #(32) rd1reg(.clk(clk), .reset(reset), .d(RD1), .q(A));
    // holds read register data from port 2
    ff_res #(32) rd2reg(.clk(clk), .reset(reset), .d(RD2), .q(WriteData));

    // extends immediate in different modes
    extender ext(.x(Instr[23:0]), 
                 .src(ImmSrc), 
                 .y(ExtImm));

    // alu operand selection
    mux3 #(32) alusrc1mux(.d0(A), 
                          .d1(PC), 
                          .d2(ALUOut), 
                          .sel(ALUSrcA), 
                          .y(SrcA));

    mux3 #(32) alusrc2mux(.d0(WriteData), 
                          .d1(ExtImm), 
                          .d2(32'd4), 
                          .sel(ALUSrcB), 
                          .y(SrcB));

    // ALU
    alu alu(.a(SrcA), // alu
            .b(SrcB), // alu
            .ctrl(ALUControl), // alu
            .res(ALUResult), // alu
            .flags(ALUFlags)); // alu
    // end ALU

    // holds alu result for next cycle
    ff_res #(32) alureg(.clk(clk), .reset(reset), .d(ALUResult), .q(ALUOut));

    // selects result for memory/reg writes
    mux3 #(32) resmux(.d0(ALUOut), 
                          .d1(Data), 
                          .d2(ALUResult), 
                          .sel(ResultSrc), 
                          .y(Result));


endmodule