/**
 * The Hack computer: CPU + instruction ROM + data Memory (with mapped I/O).
 *
 * This is the synthesizable core used on the FPGA.  It runs in a single clock
 * domain: `clk` clocks all block RAMs every cycle, while `cpu_en` is a slow
 * enable pulse that advances the CPU one instruction at a time.  Because the
 * memories read every `clk` while pc/addressM only change on a `cpu_en` step,
 * the one-cycle block-RAM read latency is fully hidden.
 *
 * The screen buffer is exposed as a read port for a VGA controller and the
 * keyboard code is provided by an external PS/2 decoder.
 */
module Computer #(
    parameter ROM_ADDR_BITS = 15,
    parameter ROM_INIT      = ""
)(
    input             clk,
    input             cpu_en,        // CPU step enable
    input             reset,

    // VGA read port into the screen buffer
    input      [12:0] screen_addr,
    output     [15:0] screen_out,

    // current keyboard code (0 = no key)
    input      [15:0] keyboard,

    // debug / ILA taps
    output     [14:0] pc_dbg,
    output     [15:0] instr_dbg,
    output     [15:0] outM_dbg,
    output     [14:0] addressM_dbg,
    output            writeM_dbg
);
    wire [15:0] instruction;
    wire [15:0] inM;
    wire [15:0] outM;
    wire        writeM;
    wire [14:0] addressM;
    wire [14:0] pc;

    // ---- CPU ----
    CPU cpu(
        .inM(inM), .instruction(instruction), .reset(reset), .en(cpu_en), .clk(clk),
        .outM(outM), .writeM(writeM), .addressM(addressM), .pc(pc)
    );

    // ---- instruction ROM ----
    ROM32K #(.ADDR_BITS(ROM_ADDR_BITS), .INIT_FILE(ROM_INIT)) rom(
        .clk(clk),
        .address(pc[ROM_ADDR_BITS-1:0]),
        .out(instruction)
    );

    // ---- data memory + memory-mapped I/O ----
    Memory mem(
        .clk(clk), .en(cpu_en),
        .in(outM), .load(writeM), .address(addressM), .out(inM),
        .screen_addr(screen_addr), .screen_out(screen_out),
        .keyboard(keyboard)
    );

    // ---- debug taps ----
    assign pc_dbg       = pc;
    assign instr_dbg    = instruction;
    assign outM_dbg     = outM;
    assign addressM_dbg = addressM;
    assign writeM_dbg   = writeM;

endmodule
