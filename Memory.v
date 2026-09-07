/**
 * Hack data memory with memory-mapped I/O, implemented with inferred block RAM
 * (the structural RAM16K chip is register-based and will not fit on the FPGA).
 *
 * Address map (15-bit addressM):
 *   0x0000 .. 0x3FFF (0..16383)     : main data RAM   (16K words)
 *   0x4000 .. 0x5FFF (16384..24575) : Screen          (8K words, 512x256 mono)
 *   0x6000           (24576)        : Keyboard        (read-only)
 *
 * CPU side reads are synchronous (1 clock latency) and the address decode is
 * pipelined by one clock so the output mux lines up with the RAM read data.
 * This matches the ROM latency and is hidden by the slow CPU step rate.
 * Writes happen only on a CPU step (`en`).
 *
 * The Screen is dual-ported: port A serves the CPU (read/write), port B is a
 * read-only port for the VGA controller.
 */
module Memory(
    input             clk,
    input             en,            // CPU step enable (gates writes)
    input      [15:0] in,            // outM from CPU
    input             load,          // writeM from CPU
    input      [14:0] address,       // addressM
    output     [15:0] out,           // inM to CPU

    // VGA read port into the screen buffer
    input      [12:0] screen_addr,   // word index 0..8191
    output reg [15:0] screen_out,

    // keyboard register (current Hack key code, 0 = none)
    input      [15:0] keyboard
);
    // ---- storage (inferred block RAM) ----
    (* ram_style = "block" *) reg [15:0] dram [0:16383];  // main data RAM
    (* ram_style = "block" *) reg [15:0] scr  [0:8191];   // screen buffer

    // ---- decode (combinational) ----
    wire sel_ram = ~address[14];                 // 0x0000..0x3FFF
    wire sel_scr =  address[14] & ~address[13];  // 0x4000..0x5FFF
    wire sel_kbd =  address[14] &  address[13];  // 0x6000

    // ---- CPU-side synchronous read ----
    reg [15:0] dram_rd;
    reg [15:0] scr_rd_cpu;
    always @(posedge clk) begin
        dram_rd    <= dram[address[13:0]];
        scr_rd_cpu <= scr[address[12:0]];
    end

    // ---- CPU-side write (only on a CPU step) ----
    always @(posedge clk) begin
        if (en & load & sel_ram) dram[address[13:0]] <= in;
        if (en & load & sel_scr) scr [address[12:0]] <= in;
    end

    // ---- pipeline the decode + keyboard to align with the registered reads ----
    reg sel_scr_d, sel_kbd_d;
    reg [15:0] kbd_d;
    always @(posedge clk) begin
        sel_scr_d <= sel_scr;
        sel_kbd_d <= sel_kbd;
        kbd_d     <= keyboard;
    end

    assign out = sel_kbd_d ? kbd_d :
                 sel_scr_d ? scr_rd_cpu :
                             dram_rd;

    // ---- VGA read port (port B of the screen block RAM) ----
    always @(posedge clk)
        screen_out <= scr[screen_addr];

endmodule
