module mainfsm(input          clk,
               input          reset,
               input  [1:0]   Op,
               input  [5:0]   Funct,
               output         IRWrite,
               output         AdrSrc,
               output [1:0]   ALUSrcA, ALUSrcB, ResultSrc,
               output         NextPC, RegW, MemW, Branch, ALUOp);  
              
  localparam [3:0] FETCH = 4'd0,
                   DECODE = 4'd1,
                   MEMADR = 4'd2,
                   MEMRD = 4'd3,
                   MEMWB = 4'd4,
                   MEMWR = 4'd5,
                   EXECUTER = 4'd6,
                   EXECUTEI = 4'd7,
                   ALUWB = 4'd8,
                   BRANCH = 4'd9,
				   UNKNOWN = 4'd10;

  reg [3:0] state, nextstate;
  reg [12:0] controls;
  
  // state register
  always @(posedge clk or posedge reset)
    if (reset) state <= FETCH;
    else state <= nextstate;
  
  // next state logic
  always @(*)
    casex(state)
      FETCH:                    nextstate = DECODE;
      DECODE: case(Op)
                2'b00: 
                  if (Funct[5]) nextstate = EXECUTEI;
                  else          nextstate = EXECUTER;
                2'b01:          nextstate = MEMADR;
                2'b10:          nextstate = BRANCH;
                default:        nextstate = UNKNOWN;
              endcase
      EXECUTER:
                                nextstate = ALUWB;                  
      EXECUTEI:
                                nextstate = ALUWB;                  
      MEMADR: 
                if (Funct[0] == 1) 
                                nextstate = MEMRD;
                else
                                nextstate = MEMWR;
      MEMRD:
                                nextstate = MEMWB;                     
      default:                  nextstate = FETCH; 
    endcase
    
  // state-dependent output logic
  always @(*)
    case(state)
      FETCH: 	controls = 13'b10001_010_01100; 
      DECODE:  	controls = 13'b00000_010_01100;      
      MEMADR:   controls = 13'b00000_000_00010;      
      MEMRD:    controls = 13'h0080;
      MEMWB:    controls = 13'h0220;
      MEMWR:    controls = 13'h0480;
      EXECUTER: controls = 13'h0001;
      EXECUTEI: controls = 13'h0003;
      ALUWB:    controls = 13'h0200;
      BRANCH:   controls = 13'h0852;
      default: 	controls = 13'bxxxxx_xxx_xxxxx;
    endcase

  assign {NextPC, Branch, MemW, RegW, IRWrite,
          AdrSrc, ResultSrc,   
          ALUSrcA, ALUSrcB, ALUOp} = controls;
endmodule