/**
 * VGA controller for 640x480 @ 60 Hz (25 MHz pixel rate) on the Basys3.
 *
 * Runs in the 100 MHz clock domain and advances one pixel per `pix_en` pulse
 * (pix_en is a 1-in-4 enable -> 25 MHz).  The 512x256 monochrome Hack screen is
 * shown in the top-left of the frame; the rest of the frame is a border colour.
 *
 * The screen buffer read (screen_data) has one clock of block-RAM latency, but
 * because a pixel lasts four 100 MHz clocks the data is always settled.  Colour
 * and sync are both registered on `pix_en`, giving a uniform one-pixel pipeline
 * delay (an invisible 1-pixel shift) with no sync/data skew.
 *
 * Sync polarity for 640x480@60 is active-low on both hsync and vsync.
 */
module vga_controller(
    input             clk,
    input             pix_en,       // 25 MHz pixel enable
    input             rst,

    output     [12:0] screen_addr,  // word index into the 8K screen buffer
    input      [15:0] screen_data,  // registered read data from the screen RAM

    output reg        hsync,
    output reg        vsync,
    output reg [3:0]  vga_r,
    output reg [3:0]  vga_g,
    output reg [3:0]  vga_b
);
    // 640x480@60 timing (pixels)
    localparam H_VISIBLE = 640, H_FRONT = 16, H_SYNC = 96, H_BACK = 48;
    localparam H_TOTAL   = H_VISIBLE + H_FRONT + H_SYNC + H_BACK; // 800
    localparam V_VISIBLE = 480, V_FRONT = 10, V_SYNC = 2,  V_BACK = 33;
    localparam V_TOTAL   = V_VISIBLE + V_FRONT + V_SYNC + V_BACK; // 525

    reg [9:0] hc = 0;
    reg [9:0] vc = 0;

    always @(posedge clk) begin
        if (rst) begin
            hc <= 0; vc <= 0;
        end else if (pix_en) begin
            if (hc == H_TOTAL-1) begin
                hc <= 0;
                if (vc == V_TOTAL-1) vc <= 0;
                else                 vc <= vc + 10'd1;
            end else begin
                hc <= hc + 10'd1;
            end
        end
    end

    wire        active    = (hc < H_VISIBLE) && (vc < V_VISIBLE);
    wire        in_screen = active && (hc < 512) && (vc < 256);

    // word index = y*32 + x/16  == {y[7:0], x[8:4]}
    assign screen_addr = {vc[7:0], hc[8:4]};
    wire pix_on = screen_data[hc[3:0]];   // Hack: bit 0 is the leftmost pixel

    // active-low sync
    wire hs = ~((hc >= H_VISIBLE + H_FRONT) && (hc < H_VISIBLE + H_FRONT + H_SYNC));
    wire vs = ~((vc >= V_VISIBLE + V_FRONT) && (vc < V_VISIBLE + V_FRONT + V_SYNC));

    reg [3:0] r_n, g_n, b_n;
    always @(*) begin
        if (!active) begin
            r_n = 4'h0; g_n = 4'h0; b_n = 4'h0;             // blanking
        end else if (in_screen) begin
            r_n = pix_on ? 4'hF : 4'h0;
            g_n = pix_on ? 4'hF : 4'h0;
            b_n = pix_on ? 4'hF : 4'h0;                     // white on black
        end else begin
            r_n = 4'h1; g_n = 4'h1; b_n = 4'h3;             // dark blue border
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            hsync <= 1'b1; vsync <= 1'b1;
            vga_r <= 4'h0; vga_g <= 4'h0; vga_b <= 4'h0;
        end else if (pix_en) begin
            hsync <= hs; vsync <= vs;
            vga_r <= r_n; vga_g <= g_n; vga_b <= b_n;
        end
    end

endmodule
