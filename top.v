module top(input         clk, reset, 
           output [31:0] WriteData, Adr, 
           output        MemWrite);

  wire [31:0] PC, Instr, ReadData;
  
  // instantiate processor and shared memory
  arm arm(.clk(clk), 
          .reset(reset), 
          .MemWrite(MemWrite), 
          .Adr(Adr), 
          .WriteData(WriteData), 
          .ReadData(ReadData));
  mem mem(.clk(clk), 
          .we(MemWrite), 
          .a(Adr), 
          .wd(WriteData), 
          .rd(ReadData));

endmodule