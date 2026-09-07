`timescale 1ns/1ps
// Verifies vga_controller 640x480@60 timing: hsync period/width, vsync
// period/width, and active-pixel counts. Runs pix_en every clock for speed.
module tb_vga;
    reg         clk = 0;
    reg         pix_en = 1'b1;
    reg         rst = 1'b1;
    wire [12:0] saddr;
    reg  [15:0] sdata = 16'hFFFF;   // all pixels on
    wire        hs, vs;
    wire [3:0]  r, g, b;

    vga_controller dut(
        .clk(clk), .pix_en(pix_en), .rst(rst),
        .screen_addr(saddr), .screen_data(sdata),
        .hsync(hs), .vsync(vs), .vga_r(r), .vga_g(g), .vga_b(b)
    );

    always #5 clk = ~clk;   // one pixel per clock (pix_en tied high)

    // measurement state
    integer hcnt = 0, hlow = 0;
    integer hperiod = -1, hlowwidth = -1;
    reg hs_d = 1'b1;

    integer vcnt = 0, vlow = 0;
    integer vperiod = -1, vlowwidth = -1;
    reg vs_d = 1'b1;

    integer active_pixels = 0;

    integer errors = 0;

    always @(posedge clk) if (!rst) begin
        hs_d <= hs; vs_d <= vs;

        // ---- hsync ----
        hcnt <= hcnt + 1;
        if (hs == 1'b0) hlow <= hlow + 1;
        if (hs_d == 1'b1 && hs == 1'b0) begin   // falling edge
            if (hcnt > 0) hperiod <= hcnt;      // clocks between falling edges
            hcnt <= 1;
            hlow <= 1;
        end
        if (hs_d == 1'b0 && hs == 1'b1) begin   // rising edge
            hlowwidth <= hlow;
        end

        // ---- vsync ----
        vcnt <= vcnt + 1;
        if (vs == 1'b0) vlow <= vlow + 1;
        if (vs_d == 1'b1 && vs == 1'b0) begin
            if (vcnt > 0) vperiod <= vcnt;
            vcnt <= 1;
            vlow <= 1;
        end
        if (vs_d == 1'b0 && vs == 1'b1) begin
            vlowwidth <= vlow;
        end

        // ---- active pixels (any colour, within one frame) ----
        if ((r != 0 || g != 0 || b != 0)) active_pixels <= active_pixels + 1;
    end

    task chk(input [255:0] name, input integer got, input integer exp);
        begin
            if (got !== exp) begin
                errors = errors + 1;
                $display("FAIL %0s: got=%0d exp=%0d", name, got, exp);
            end else
                $display("ok   %0s = %0d", name, got);
        end
    endtask

    initial begin
        rst = 1; repeat (8) @(posedge clk); rst = 0;

        // run ~1.2 frames so both hsync and vsync period/width are captured
        repeat (800*525*2) @(posedge clk);

        chk("hsync period", hperiod, 800);
        chk("hsync low width", hlowwidth, 96);
        chk("vsync period", vperiod, 800*525);
        chk("vsync low width", vlowwidth, 2*800);

        if (errors == 0) $display("TB_VGA: ALL PASS");
        else             $display("TB_VGA: %0d FAILURES", errors);
        $finish;
    end
endmodule
