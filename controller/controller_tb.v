module controller_tb();
    // test inputs
    reg [31:0] Instr;
    reg [3:0] ALUFlags;

    // test outputs
    wire PCWrite, MemWrite, RegWrite, IRWrite, AdrSrc;
    // expected
    reg PCWrite_e, MemWrite_e, RegWrite_e, IRWrite_e, AdrSrc_e;
    
    wire [1:0] RegSrc, ALUSrcA, ALUSrcB, ResultSrc, ImmSrc;
    wire [3:0] ALUControl;
    
    reg  [1:0] RegSrc_e, ALUSrcA_e, ALUSrcB_e, ResultSrc_e, ImmSrc_e;
    reg  [3:0] ALUControl_e;
    
    reg clk, reset;
    reg [31:0] errors;


    controller dut(
        .clk(clk),
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
        .ALUControl(ALUControl)
    );

    always begin
        clk = 1; #5; clk = 0; #5;
    end

    initial begin
        errors = 0;
        reset = 1; #27; reset = 0; 
    end

    initial begin
        wait(reset);
        wait(~reset);
        
        // SUB reg
        Instr = 32'hE04F000F; ALUFlags = 4'b0000;
        
        // fetch
        if(ALUSrcA    !==   2'b01) begin $error("00_0_0 failed."); errors = errors + 1; end
        if(ALUSrcB    !==   2'b10) begin $error("00_0_1 failed."); errors = errors + 1; end
        if(AdrSrc     !==       0) begin $error("00_0_2 failed."); errors = errors + 1; end
        if(ALUControl !== 4'b0000) begin $error("00_0_3 failed."); errors = errors + 1; end
        if(ResultSrc  !==   2'b10) begin $error("00_0_4 failed."); errors = errors + 1; end
        if(IRWrite    !==       1) begin $error("00_0_5 failed."); errors = errors + 1; end
        if(PCWrite    !==       1) begin $error("00_0_6 failed."); errors = errors + 1; end
        #10;
        
        // decode
        if(ALUSrcA    !==   2'b01) begin $error("00_1_0 failed."); errors = errors + 1; end
        if(ALUSrcB    !==   2'b10) begin $error("00_1_1 failed."); errors = errors + 1; end
        if(ALUControl !== 4'b0000) begin $error("00_1_2 failed."); errors = errors + 1; end
        if(ResultSrc  !==   2'b10) begin $error("00_1_3 failed."); errors = errors + 1; end
        #10;
        
        // execute reg
        if(ALUSrcA    !==   2'b00) begin $error("00_2_0 failed."); errors = errors + 1; end
        if(ALUSrcB    !==   2'b00) begin $error("00_2_1 failed."); errors = errors + 1; end
        if(ALUControl !== 4'b0010) begin $error("00_2_2 failed."); errors = errors + 1; end
        #10;
        
        // aluwb
        if(ResultSrc  !==   2'b00) begin $error("00_3_0 failed."); errors = errors + 1; end
        if(RegWrite   !==       1) begin $error("00_3_1 failed."); errors = errors + 1; end
        #10;

        // LDR
        Instr = 32'hE5902060; ALUFlags = 4'b0000;
        
        // fetch
        if(ALUSrcA    !==   2'b01) begin $error("01_0_0 failed."); errors = errors + 1; end
        if(ALUSrcB    !==   2'b10) begin $error("01_0_1 failed."); errors = errors + 1; end
        if(AdrSrc     !==       0) begin $error("01_0_2 failed."); errors = errors + 1; end
        if(ALUControl !== 4'b0000) begin $error("01_0_3 failed."); errors = errors + 1; end
        if(ResultSrc  !==   2'b10) begin $error("01_0_4 failed."); errors = errors + 1; end
        if(IRWrite    !==       1) begin $error("01_0_5 failed."); errors = errors + 1; end
        if(PCWrite    !==       1) begin $error("01_0_6 failed."); errors = errors + 1; end
        #10;

        // decode
        if(ALUSrcA    !==   2'b01) begin $error("01_1_0 failed."); errors = errors + 1; end
        if(ALUSrcB    !==   2'b10) begin $error("01_1_1 failed."); errors = errors + 1; end
        if(ALUControl !== 4'b0000) begin $error("01_1_2 failed."); errors = errors + 1; end
        if(ResultSrc  !==   2'b10) begin $error("01_1_3 failed."); errors = errors + 1; end
        #10;

        // mem adr
        if(ALUSrcA    !==   2'b00) begin $error("01_2_0 failed."); errors = errors + 1; end
        if(ALUSrcB    !==   2'b01) begin $error("01_2_1 failed."); errors = errors + 1; end
        if(ALUControl !== 4'b0000) begin $error("01_2_2 failed."); errors = errors + 1; end
        #10;

        // mem read
        if(ResultSrc  !==   2'b00) begin $error("01_3_0 failed."); errors = errors + 1; end
        if(AdrSrc     !==       1) begin $error("01_3_1 failed."); errors = errors + 1; end
        #10;

        // mem wb
        if(ResultSrc  !==   2'b01) begin $error("01_4_0 failed."); errors = errors + 1; end
        if(RegWrite   !==       1) begin $error("01_4_1 failed."); errors = errors + 1; end
        #10;

        // STR
        Instr = 32'hE5837054; ALUFlags = 4'b0000;

        // fetch
        if(ALUSrcA    !==   2'b01) begin $error("02_0_0 failed."); errors = errors + 1; end
        if(ALUSrcB    !==   2'b10) begin $error("02_0_1 failed."); errors = errors + 1; end
        if(AdrSrc     !==       0) begin $error("02_0_2 failed."); errors = errors + 1; end
        if(ALUControl !== 4'b0000) begin $error("02_0_3 failed."); errors = errors + 1; end
        if(ResultSrc  !==   2'b10) begin $error("02_0_4 failed."); errors = errors + 1; end
        if(IRWrite    !==       1) begin $error("02_0_5 failed."); errors = errors + 1; end
        if(PCWrite    !==       1) begin $error("02_0_6 failed."); errors = errors + 1; end
        #10;

        // decode
        if(ALUSrcA    !==   2'b01) begin $error("02_1_0 failed."); errors = errors + 1; end
        if(ALUSrcB    !==   2'b10) begin $error("02_1_1 failed."); errors = errors + 1; end
        if(ALUControl !== 4'b0000) begin $error("02_1_2 failed."); errors = errors + 1; end
        if(ResultSrc  !==   2'b10) begin $error("02_1_3 failed."); errors = errors + 1; end
        #10;

        // mem adr
        if(ALUSrcA    !==   2'b00) begin $error("02_2_0 failed."); errors = errors + 1; end
        if(ALUSrcB    !==   2'b01) begin $error("02_2_1 failed."); errors = errors + 1; end
        if(ALUControl !== 4'b0000) begin $error("02_2_2 failed."); errors = errors + 1; end
        #10;

        // mem write
        if(ResultSrc  !==   2'b00) begin $error("02_3_0 failed."); errors = errors + 1; end
        if(AdrSrc     !==       1) begin $error("02_3_1 failed."); errors = errors + 1; end
        if(MemWrite   !==       1) begin $error("02_3_2 failed."); errors = errors + 1; end
        #10;

        // ADD imm
        Instr = 32'hE2802005; ALUFlags = 4'b0000;
        
        // fetch
        if(ALUSrcA    !==   2'b01) begin $error("03_0_0 failed."); errors = errors + 1; end
        if(ALUSrcB    !==   2'b10) begin $error("03_0_1 failed."); errors = errors + 1; end
        if(AdrSrc     !==       0) begin $error("03_0_2 failed."); errors = errors + 1; end
        if(ALUControl !== 4'b0000) begin $error("03_0_3 failed."); errors = errors + 1; end
        if(ResultSrc  !==   2'b10) begin $error("03_0_4 failed."); errors = errors + 1; end
        if(IRWrite    !==       1) begin $error("03_0_5 failed."); errors = errors + 1; end
        if(PCWrite    !==       1) begin $error("03_0_6 failed."); errors = errors + 1; end
        #10;
        
        // decode
        if(ALUSrcA    !==   2'b01) begin $error("03_1_0 failed."); errors = errors + 1; end
        if(ALUSrcB    !==   2'b10) begin $error("03_1_1 failed."); errors = errors + 1; end
        if(ALUControl !== 4'b0000) begin $error("03_1_2 failed."); errors = errors + 1; end
        if(ResultSrc  !==   2'b10) begin $error("03_1_3 failed."); errors = errors + 1; end
        #10;
        
        // execute imm
        if(ALUSrcA    !==   2'b00) begin $error("03_2_0 failed."); errors = errors + 1; end
        if(ALUSrcB    !==   2'b01) begin $error("03_2_1 failed."); errors = errors + 1; end
        if(ALUControl !== 4'b0000) begin $error("03_2_2 failed."); errors = errors + 1; end
        #10;
        
        // aluwb
        if(ResultSrc  !==   2'b00) begin $error("03_3_0 failed."); errors = errors + 1; end
        if(RegWrite   !==       1) begin $error("03_3_1 failed."); errors = errors + 1; end
        #10;

        // B
        Instr = 32'hEA000001; ALUFlags = 4'b0000;
        
        // fetch
        if(ALUSrcA    !==   2'b01) begin $error("04_0_0 failed."); errors = errors + 1; end
        if(ALUSrcB    !==   2'b10) begin $error("04_0_1 failed."); errors = errors + 1; end
        if(AdrSrc     !==       0) begin $error("04_0_2 failed."); errors = errors + 1; end
        if(ALUControl !== 4'b0000) begin $error("04_0_3 failed."); errors = errors + 1; end
        if(ResultSrc  !==   2'b10) begin $error("04_0_4 failed."); errors = errors + 1; end
        if(IRWrite    !==       1) begin $error("04_0_5 failed."); errors = errors + 1; end
        if(PCWrite    !==       1) begin $error("04_0_6 failed."); errors = errors + 1; end
        #10;
        
        // decode
        if(ALUSrcA    !==   2'b01) begin $error("04_1_0 failed."); errors = errors + 1; end
        if(ALUSrcB    !==   2'b10) begin $error("04_1_1 failed."); errors = errors + 1; end
        if(ALUControl !== 4'b0000) begin $error("04_1_2 failed."); errors = errors + 1; end
        if(ResultSrc  !==   2'b10) begin $error("04_1_3 failed."); errors = errors + 1; end
        #10;

        // branch
        if(ALUSrcA    !==   2'b10) begin $error("04_2_0 failed."); errors = errors + 1; end
        if(ALUSrcB    !==   2'b01) begin $error("04_2_1 failed."); errors = errors + 1; end
        if(ALUControl !== 4'b0000) begin $error("04_2_3 failed."); errors = errors + 1; end
        if(ResultSrc  !==   2'b10) begin $error("04_2_4 failed."); errors = errors + 1; end
        if(PCWrite    !==       1) begin $error("04_2_6 failed."); errors = errors + 1; end
        #10;

        // fetch
        if(ALUSrcA    !==   2'b01) begin $error("05_0_0 failed."); errors = errors + 1; end
        if(ALUSrcB    !==   2'b10) begin $error("05_0_1 failed."); errors = errors + 1; end
        if(AdrSrc     !==       0) begin $error("05_0_2 failed."); errors = errors + 1; end
        if(ALUControl !== 4'b0000) begin $error("05_0_3 failed."); errors = errors + 1; end
        if(ResultSrc  !==   2'b10) begin $error("05_0_4 failed."); errors = errors + 1; end
        if(IRWrite    !==       1) begin $error("05_0_5 failed."); errors = errors + 1; end
        if(PCWrite    !==       1) begin $error("05_0_6 failed."); errors = errors + 1; end
        #10;

        $display("Simulation ended with %d errors", errors);
        $finish;
    end

endmodule