`timescale 1ns/1ps
// Self-checking CPU test: runs real Hack programs against an ideal memory
// model (combinational instruction/data read, clocked write) matching the
// Nand2Tetris emulator semantics. Select a program with +TEST=add|sum.
module tb_cpu;
    reg         clk = 0;
    reg         reset;
    wire [15:0] outM;
    wire        writeM;
    wire [14:0] addressM;
    wire [14:0] pc;
    reg  [15:0] inM;

    reg  [15:0] rom [0:255];   // instruction memory
    reg  [15:0] ram [0:255];   // data memory

    wire [15:0] instruction = rom[pc];

    CPU dut(
        .inM(inM), .instruction(instruction), .reset(reset), .en(1'b1), .clk(clk),
        .outM(outM), .writeM(writeM), .addressM(addressM), .pc(pc)
    );

    // combinational data read
    always @(*) inM = ram[addressM];

    // clocked data write (same edge the CPU registers update on)
    always @(posedge clk) if (writeM) ram[addressM] <= outM;

    always #5 clk = ~clk;

    integer i;
    integer errors = 0;
    reg [63:0] test;

    task load_add;
        begin
            // 2 + 3 -> RAM[0]
            rom[0]  = 16'b0000000000000010; // @2
            rom[1]  = 16'b1110110000010000; // D=A
            rom[2]  = 16'b0000000000000011; // @3
            rom[3]  = 16'b1110000010010000; // D=D+A
            rom[4]  = 16'b0000000000000000; // @0
            rom[5]  = 16'b1110001100001000; // M=D
            rom[6]  = 16'b0000000000000110; // @6   (END)
            rom[7]  = 16'b1110101010000111; // 0;JMP
        end
    endtask

    task load_sum;
        begin
            // sum = 1+2+...+10 = 55 -> RAM[0], loop counter i -> RAM[1]
            rom[0]  = 16'b0000000000000000; // @0
            rom[1]  = 16'b1110101010001000; // M=0        sum=0
            rom[2]  = 16'b0000000000000001; // @1
            rom[3]  = 16'b1110101010001000; // M=0        i=0
            // (LOOP=4)
            rom[4]  = 16'b0000000000000001; // @1
            rom[5]  = 16'b1111110111011000; // MD=M+1     i=i+1, D=i
            rom[6]  = 16'b0000000000000000; // @0
            rom[7]  = 16'b1111000010001000; // M=D+M      sum=sum+i
            rom[8]  = 16'b0000000000000001; // @1
            rom[9]  = 16'b1111110000010000; // D=M        D=i
            rom[10] = 16'b0000000000001010; // @10
            rom[11] = 16'b1110010011010000; // D=D-A      D=i-10
            rom[12] = 16'b0000000000000100; // @4  (LOOP)
            rom[13] = 16'b1110001100000100; // D;JLT      if (i-10)<0 goto LOOP
            // (END=14)
            rom[14] = 16'b0000000000001110; // @14
            rom[15] = 16'b1110101010000111; // 0;JMP
        end
    endtask

    task check(input [127:0] name, input [15:0] got, input [15:0] exp);
        begin
            if (got !== exp) begin
                errors = errors + 1;
                $display("FAIL %0s: got=%0d exp=%0d", name, got, exp);
            end else
                $display("ok   %0s = %0d", name, got);
        end
    endtask

    initial begin
        for (i = 0; i < 256; i = i + 1) begin rom[i] = 16'h0000; ram[i] = 16'h0000; end

        if (!$value$plusargs("TEST=%s", test)) test = "add";

        if (test == "sum") load_sum; else load_add;

        // reset for two cycles
        reset = 1; @(negedge clk); @(negedge clk);
        reset = 0;

        // run enough cycles
        repeat (400) @(negedge clk);

        if (test == "sum") begin
            check("RAM[0] sum", ram[0], 16'd55);
            check("RAM[1] i",   ram[1], 16'd10);
        end else begin
            check("RAM[0] add", ram[0], 16'd5);
        end

        if (errors == 0) $display("TB_CPU[%0s]: ALL PASS", test);
        else             $display("TB_CPU[%0s]: %0d FAILURES", test, errors);
        $finish;
    end
endmodule
