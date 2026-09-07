`timescale 1ns/1ps
// Computer-level test: runs a program from ROM that copies the keyboard code
// into screen words 0 and 1, through the full CPU + block-RAM memory map with
// the slow cpu_en step.  Verifies memory-mapped I/O and read-latency hiding.
//
// Program (sim/io_test.hex):
//   (LOOP=0)
//   @24576  ; KBD
//   D=M
//   @16384  ; SCREEN[0]
//   M=D
//   @16385  ; SCREEN[1]
//   M=D
//   @0
//   0;JMP
module tb_computer;
    reg         clk = 0;
    reg         reset;
    reg  [15:0] keyboard;
    reg  [12:0] screen_addr;
    wire [15:0] screen_out;
    wire [14:0] pc_dbg;
    wire [15:0] instr_dbg, outM_dbg;
    wire [14:0] addressM_dbg;
    wire        writeM_dbg;

    // CPU step enable: 1-in-4 (mimics the on-board slow enable)
    reg [1:0] div = 0;
    wire cpu_en = (div == 2'd0);
    always @(posedge clk) div <= div + 2'd1;

    Computer #(.ROM_ADDR_BITS(15), .ROM_INIT("io_test.hex")) dut(
        .clk(clk), .cpu_en(cpu_en), .reset(reset),
        .screen_addr(screen_addr), .screen_out(screen_out),
        .keyboard(keyboard),
        .pc_dbg(pc_dbg), .instr_dbg(instr_dbg), .outM_dbg(outM_dbg),
        .addressM_dbg(addressM_dbg), .writeM_dbg(writeM_dbg)
    );

    always #5 clk = ~clk;

    integer errors = 0;
    reg [15:0] d;

    task read_screen(input [12:0] a);
        begin
            screen_addr = a;
            @(posedge clk); @(posedge clk);
            d = screen_out;
        end
    endtask

    task expect_screen(input [12:0] a, input [15:0] exp);
        begin
            read_screen(a);
            if (d !== exp) begin
                errors = errors + 1;
                $display("FAIL screen[%0d]=%04h exp %04h", a, d, exp);
            end else
                $display("ok   screen[%0d]=%04h", a, d);
        end
    endtask

    initial begin
        keyboard    = 16'h1234;
        screen_addr = 13'd0;
        reset = 1; repeat (10) @(posedge clk);
        reset = 0;

        repeat (400) @(posedge clk);
        expect_screen(13'd0, 16'h1234);
        expect_screen(13'd1, 16'h1234);

        // press a different key, let it propagate
        keyboard = 16'h55AA;
        repeat (400) @(posedge clk);
        expect_screen(13'd0, 16'h55AA);
        expect_screen(13'd1, 16'h55AA);

        if (errors == 0) $display("TB_COMPUTER: ALL PASS");
        else             $display("TB_COMPUTER: %0d FAILURES", errors);
        $finish;
    end
endmodule
