`timescale 1ns/1ps
// Self-checking unit test for the M1 core chips: Inc16 and PC.
module tb_core;
    integer errors = 0;

    // ---- Inc16 ----
    reg  [15:0] inc_in;
    wire [15:0] inc_out;
    Inc16 dut_inc(.in(inc_in), .out(inc_out));

    task check16(input [127:0] name, input [15:0] got, input [15:0] exp);
        begin
            if (got !== exp) begin
                errors = errors + 1;
                $display("FAIL %0s: got=%0d (0x%04h) exp=%0d (0x%04h)", name, got, got, exp, exp);
            end
        end
    endtask

    // ---- PC ----
    reg         clk = 0;
    reg  [15:0] pc_in;
    reg         pc_load, pc_inc, pc_reset;
    wire [15:0] pc_out;
    PC dut_pc(.in(pc_in), .load(pc_load), .inc(pc_inc), .reset(pc_reset), .clk(clk), .out(pc_out));

    // clock
    always #5 clk = ~clk;

    task tick; begin @(negedge clk); #1; end endtask

    initial begin
        // ---- Inc16 exhaustive-ish checks ----
        inc_in = 16'd0;    #1; check16("Inc16(0)",    inc_out, 16'd1);
        inc_in = 16'd41;   #1; check16("Inc16(41)",   inc_out, 16'd42);
        inc_in = 16'hFFFF; #1; check16("Inc16(FFFF)", inc_out, 16'd0);   // wrap
        inc_in = 16'h7FFF; #1; check16("Inc16(7FFF)", inc_out, 16'h8000);

        // ---- PC behavior ----
        pc_in = 16'd0; pc_load = 0; pc_inc = 0; pc_reset = 1;
        tick; check16("PC reset", pc_out, 16'd0);

        // increment a few times
        pc_reset = 0; pc_inc = 1;
        tick; check16("PC inc1", pc_out, 16'd1);
        tick; check16("PC inc2", pc_out, 16'd2);
        tick; check16("PC inc3", pc_out, 16'd3);

        // hold (no inc, no load, no reset)
        pc_inc = 0;
        tick; check16("PC hold", pc_out, 16'd3);

        // load a value
        pc_in = 16'd12345; pc_load = 1;
        tick; check16("PC load", pc_out, 16'd12345);

        // load has priority over inc
        pc_in = 16'd100; pc_load = 1; pc_inc = 1;
        tick; check16("PC load>inc", pc_out, 16'd100);

        // inc after load
        pc_load = 0; pc_inc = 1;
        tick; check16("PC inc after load", pc_out, 16'd101);

        // reset has highest priority
        pc_reset = 1; pc_load = 1; pc_inc = 1; pc_in = 16'd777;
        tick; check16("PC reset>all", pc_out, 16'd0);

        if (errors == 0) $display("TB_CORE: ALL PASS");
        else             $display("TB_CORE: %0d FAILURES", errors);
        $finish;
    end
endmodule
