`timescale 1ns/1ps
// Top-level integration test for hack_top.
// Feeds PS/2 scancodes (left-arrow make/break) and checks:
//   - the PS/2 decoder produces the Hack key code (130) / releases to 0
//   - the running CPU copies the key code into the screen buffer (io_test.hex)
module tb_top;
    reg clk = 0;
    reg btnC;
    reg PS2Clk = 1'b1;
    reg PS2Data = 1'b1;
    wire [3:0] vgaRed, vgaGreen, vgaBlue;
    wire Hsync, Vsync;
    wire [15:0] led;

    hack_top #(.ROM_INIT("io_test.hex")) dut(
        .clk(clk), .btnC(btnC),
        .PS2Clk(PS2Clk), .PS2Data(PS2Data),
        .vgaRed(vgaRed), .vgaGreen(vgaGreen), .vgaBlue(vgaBlue),
        .Hsync(Hsync), .Vsync(Vsync), .led(led)
    );

    always #5 clk = ~clk;   // 100 MHz

    localparam THALF = 1000; // ns per PS/2 clock half-period (fast for sim)

    task send_bit(input b);
        begin
            PS2Data = b;
            PS2Clk  = 1'b1; #THALF;
            PS2Clk  = 1'b0; #THALF;   // falling edge with data stable
        end
    endtask

    task send_byte(input [7:0] d);
        integer i;
        reg par;
        begin
            par = ~(^d);              // odd parity
            send_bit(1'b0);           // start
            for (i = 0; i < 8; i = i + 1) send_bit(d[i]);
            send_bit(par);            // parity
            send_bit(1'b1);           // stop
            PS2Clk = 1'b1; PS2Data = 1'b1;
            #(THALF*4);               // idle between frames
        end
    endtask

    integer errors = 0;

    // monitor what the embedded PS/2 decoder sees
    always @(posedge clk)
        if (dut.kbd.byte_valid)
            $display("KBD scancode=0x%02h ext=%b rel=%b key_code=%0d",
                     dut.kbd.scancode, dut.kbd.extended, dut.kbd.release_f, dut.key_code);

    task chk(input [255:0] name, input [15:0] got, input [15:0] exp);
        begin
            if (got !== exp) begin
                errors = errors + 1;
                $display("FAIL %0s: got=%0d exp=%0d", name, got, exp);
            end else
                $display("ok   %0s = %0d", name, got);
        end
    endtask

    initial begin
        btnC = 1'b0;
        // wait for the on-board power-on reset (255 cycles) to fully clear
        repeat (400) @(posedge clk);

        // ---- press LEFT arrow: E0 6B ----
        send_byte(8'hE0);
        send_byte(8'h6B);
        repeat (4000) @(posedge clk);      // let CPU loop run
        chk("key_code (left)", dut.key_code, 16'd130);
        chk("screen[0] (left)", dut.hack.mem.scr[0], 16'd130);

        // ---- release LEFT arrow: E0 F0 6B ----
        send_byte(8'hE0);
        send_byte(8'hF0);
        send_byte(8'h6B);
        repeat (4000) @(posedge clk);
        chk("key_code (release)", dut.key_code, 16'd0);
        chk("screen[0] (release)", dut.hack.mem.scr[0], 16'd0);

        // ---- press SPACE: 29 ----
        send_byte(8'h29);
        repeat (4000) @(posedge clk);
        chk("key_code (space)", dut.key_code, 16'd32);
        chk("screen[0] (space)", dut.hack.mem.scr[0], 16'd32);

        // sanity: pc is advancing (CPU running)
        if (led === 16'd0) begin
            // pc==0 the whole time would be suspicious but not necessarily an error
            $display("note: led(pc)=%0d", led);
        end

        if (errors == 0) $display("TB_TOP: ALL PASS");
        else             $display("TB_TOP: %0d FAILURES", errors);
        $finish;
    end
endmodule
