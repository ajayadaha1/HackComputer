`timescale 1ns/1ps
// Verifies the tetris.asm falling-blocks logic on the full Computer:
//  - a block falls straight down and locks at the bottom of column 16, growing
//    height[16] and filling the bottom screen row of that column;
//  - a second block stacks on top (height[16] >= 2);
//  - holding LEFT makes new blocks slide to column 0 and stack there.
module tb_tetris;
    reg         clk = 0;
    reg         reset;
    reg  [15:0] keyboard;
    reg  [12:0] screen_addr;
    wire [15:0] screen_out;
    wire [14:0] pc_dbg;
    wire [15:0] instr_dbg, outM_dbg;
    wire [14:0] addressM_dbg;
    wire        writeM_dbg;

    reg div = 0;
    wire cpu_en = (div == 1'b0);
    always @(posedge clk) div <= ~div;

    Computer #(.ROM_ADDR_BITS(15), .ROM_INIT("tetris.hex")) dut(
        .clk(clk), .cpu_en(cpu_en), .reset(reset),
        .screen_addr(screen_addr), .screen_out(screen_out),
        .keyboard(keyboard),
        .pc_dbg(pc_dbg), .instr_dbg(instr_dbg), .outM_dbg(outM_dbg),
        .addressM_dbg(addressM_dbg), .writeM_dbg(writeM_dbg)
    );

    always #5 clk = ~clk;

    integer errors = 0;
    // height[c] lives at RAM 100+c -> dut.mem.dram[100+c]
    // bottom screen word of column c = 15*512 + c = 7680 + c
    localparam H16 = 116;
    localparam H0  = 100;
    localparam BOT16 = 7680 + 16;
    localparam BOT0  = 7680 + 0;

    initial begin
        keyboard = 16'd0;
        screen_addr = 13'd0;
        reset = 1; repeat (10) @(posedge clk); reset = 0;

        // let the screen clear + a couple of blocks fall straight down in col 16
        repeat (1500000) @(posedge clk);

        if (dut.mem.dram[H16] < 16'd2) begin
            errors = errors + 1;
            $display("FAIL stack col16: height[16]=%0d exp >=2", dut.mem.dram[H16]);
        end else $display("ok   col16 stacked: height[16]=%0d", dut.mem.dram[H16]);

        if (dut.mem.scr[BOT16] !== 16'hFFFF) begin
            errors = errors + 1;
            $display("FAIL bottom col16 not filled: scr[%0d]=%04h", BOT16, dut.mem.scr[BOT16]);
        end else $display("ok   col16 bottom row filled");

        // now hold LEFT: new blocks slide to column 0 and stack there
        keyboard = 16'd130;
        repeat (1200000) @(posedge clk);
        keyboard = 16'd0;
        repeat (100000) @(posedge clk);

        if (dut.mem.dram[H0] < 16'd1) begin
            errors = errors + 1;
            $display("FAIL stack col0: height[0]=%0d exp >=1", dut.mem.dram[H0]);
        end else $display("ok   col0 stacked after LEFT: height[0]=%0d", dut.mem.dram[H0]);

        if (dut.mem.scr[BOT0] !== 16'hFFFF) begin
            errors = errors + 1;
            $display("FAIL bottom col0 not filled: scr[%0d]=%04h", BOT0, dut.mem.scr[BOT0]);
        end else $display("ok   col0 bottom row filled after LEFT");

        if (errors == 0) $display("TB_TETRIS: ALL PASS");
        else             $display("TB_TETRIS: %0d FAILURES", errors);
        $finish;
    end
endmodule
