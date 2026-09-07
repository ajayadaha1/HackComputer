/**
 * Basys3 top level for the Hack computer.
 *
 * Single 100 MHz clock domain.  Two derived enables:
 *   pix_en : 1-in-4  (25 MHz) drives the VGA pixel pipeline (640x480@60).
 *   cpu_en : 1-in-16 (~6.25 MHz) steps the Hack CPU one instruction at a time.
 * Block RAMs read every 100 MHz clock, so their 1-cycle latency is hidden.
 *
 * I/O:
 *   clk       - 100 MHz oscillator (W5)
 *   btnC      - reset (center button)
 *   PS2Clk/Data - USB-HID keyboard (PS/2 protocol)
 *   vgaRed/Green/Blue, Hsync, Vsync - VGA connector
 *   led       - debug: {writeM, pc[14:0]}
 */
module hack_top #(
    parameter ROM_INIT = ""
)(
    input             clk,
    input             btnC,
    input             PS2Clk,
    input             PS2Data,
    output     [3:0]  vgaRed,
    output     [3:0]  vgaGreen,
    output     [3:0]  vgaBlue,
    output            Hsync,
    output            Vsync,
    output     [15:0] led
);
    // ---------------- clock enables ----------------
    reg [3:0] div = 4'd0;
    always @(posedge clk) div <= div + 4'd1;
    wire pix_en = (div[1:0] == 2'b00);   // 25 MHz
    wire cpu_en = (div       == 4'd0);   // ~6.25 MHz

    // ---------------- reset (power-on + button) ----------------
    reg [7:0] por = 8'hFF;
    always @(posedge clk) if (por != 8'd0) por <= por - 8'd1;
    wire por_rst = (por != 8'd0);

    reg [1:0] btn_s = 2'b00;
    always @(posedge clk) btn_s <= {btn_s[0], btnC};
    wire reset = por_rst | btn_s[1];

    // ---------------- interconnect ----------------
    wire [12:0] screen_addr;
    wire [15:0] screen_data;
    wire [15:0] key_code;

    wire [14:0] pc_dbg;
    wire [15:0] instr_dbg, outM_dbg;
    wire [14:0] addressM_dbg;
    wire        writeM_dbg;

    // ---------------- Hack computer core ----------------
    Computer #(.ROM_ADDR_BITS(15), .ROM_INIT(ROM_INIT)) hack(
        .clk(clk), .cpu_en(cpu_en), .reset(reset),
        .screen_addr(screen_addr), .screen_out(screen_data),
        .keyboard(key_code),
        .pc_dbg(pc_dbg), .instr_dbg(instr_dbg), .outM_dbg(outM_dbg),
        .addressM_dbg(addressM_dbg), .writeM_dbg(writeM_dbg)
    );

    // ---------------- VGA ----------------
    vga_controller vga(
        .clk(clk), .pix_en(pix_en), .rst(por_rst),
        .screen_addr(screen_addr), .screen_data(screen_data),
        .hsync(Hsync), .vsync(Vsync),
        .vga_r(vgaRed), .vga_g(vgaGreen), .vga_b(vgaBlue)
    );

    // ---------------- Keyboard ----------------
    ps2_keyboard kbd(
        .clk(clk), .rst(por_rst),
        .ps2_clk(PS2Clk), .ps2_data(PS2Data),
        .key_code(key_code)
    );

    // ---------------- debug (ILA taps) ----------------
    // dont_touch keeps these driven through opt_design so the ILA can probe them
    (* mark_debug = "true", dont_touch = "true" *) wire [14:0] dbg_pc       = pc_dbg;
    (* mark_debug = "true", dont_touch = "true" *) wire [15:0] dbg_instr    = instr_dbg;
    (* mark_debug = "true", dont_touch = "true" *) wire        dbg_writeM   = writeM_dbg;
    (* mark_debug = "true", dont_touch = "true" *) wire [14:0] dbg_addressM = addressM_dbg;
    (* mark_debug = "true", dont_touch = "true" *) wire [15:0] dbg_outM     = outM_dbg;
    (* mark_debug = "true", dont_touch = "true" *) wire [15:0] dbg_key      = key_code;

    assign led = {writeM_dbg, pc_dbg};

endmodule
