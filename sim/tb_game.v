`timescale 1ns/1ps
// Verifies the blocks.asm demo on the full Computer: after the screen clear +
// initial draw the block is present at its start column; after holding RIGHT it
// has moved away from that column and is still drawn on screen.
module tb_game;
    reg         clk = 0;
    reg         reset;
    reg  [15:0] keyboard;
    reg  [12:0] screen_addr;
    wire [15:0] screen_out;
    wire [14:0] pc_dbg;
    wire [15:0] instr_dbg, outM_dbg;
    wire [14:0] addressM_dbg;
    wire        writeM_dbg;

    // fast CPU enable (1-in-2) to keep the sim short
    reg div = 0;
    wire cpu_en = (div == 1'b0);
    always @(posedge clk) div <= ~div;

    Computer #(.ROM_ADDR_BITS(15), .ROM_INIT("blocks.hex")) dut(
        .clk(clk), .cpu_en(cpu_en), .reset(reset),
        .screen_addr(screen_addr), .screen_out(screen_out),
        .keyboard(keyboard),
        .pc_dbg(pc_dbg), .instr_dbg(instr_dbg), .outM_dbg(outM_dbg),
        .addressM_dbg(addressM_dbg), .writeM_dbg(writeM_dbg)
    );

    always #5 clk = ~clk;

    integer errors = 0;
    integer i;
    reg found;

    // block starts at bx=8, by=4 -> screen word index 4*512 + 8 = 2056
    localparam START = 2056;

    initial begin
        keyboard = 16'd0;
        screen_addr = 13'd0;
        reset = 1; repeat (10) @(posedge clk); reset = 0;

        // let it clear the screen and draw the initial block
        repeat (500000) @(posedge clk);

        if (dut.mem.scr[START] !== 16'hFFFF) begin
            errors = errors + 1;
            $display("FAIL initial draw: scr[%0d]=%04h exp FFFF", START, dut.mem.scr[START]);
        end else $display("ok   initial block drawn at word %0d", START);
        // a lower row of the same block (row 1 = START+32)
        if (dut.mem.scr[START+32] !== 16'hFFFF) begin
            errors = errors + 1;
            $display("FAIL initial draw row1: scr[%0d]=%04h", START+32, dut.mem.scr[START+32]);
        end else $display("ok   initial block row1 drawn");

        // hold RIGHT for a while -> block moves right
        keyboard = 16'd132;
        repeat (800000) @(posedge clk);
        keyboard = 16'd0;
        repeat (200000) @(posedge clk);   // settle inside a delay (block fully drawn)

        if (dut.mem.scr[START] !== 16'h0000) begin
            errors = errors + 1;
            $display("FAIL move: start column scr[%0d]=%04h exp 0000", START, dut.mem.scr[START]);
        end else $display("ok   start column cleared after moving right");

        // block should be drawn somewhere to the right on row 0
        found = 1'b0;
        for (i = START+1; i <= START + 20; i = i + 1)
            if (dut.mem.scr[i] === 16'hFFFF) found = 1'b1;
        if (!found) begin
            errors = errors + 1;
            $display("FAIL move: no block found right of start on row 0");
        end else $display("ok   block present to the right after moving");

        if (errors == 0) $display("TB_GAME: ALL PASS");
        else             $display("TB_GAME: %0d FAILURES", errors);
        $finish;
    end
endmodule
