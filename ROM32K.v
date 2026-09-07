/**
 * Instruction ROM for the Hack computer, inferred as block RAM.
 *
 * Synchronous read (one clock of latency) so it maps to Artix-7 block RAM.
 * The CPU steps at a much slower rate than `clk`, so this read latency is
 * fully hidden.  Contents are loaded from a hex memory-init file
 * (`$readmemh`, one 16-bit word per line) named by the INIT_FILE parameter.
 *
 * ADDR_BITS defaults to 15 (32K words), the full Hack instruction space.
 */
module ROM32K #(
    parameter        ADDR_BITS = 15,
    parameter        INIT_FILE = ""
)(
    input                    clk,
    input  [ADDR_BITS-1:0]   address,
    output reg [15:0]        out
);
    (* rom_style = "block" *)
    reg [15:0] mem [0:(1<<ADDR_BITS)-1];

    integer i;
    initial begin
        for (i = 0; i < (1<<ADDR_BITS); i = i + 1) mem[i] = 16'h0000;
        if (INIT_FILE != "") $readmemh(INIT_FILE, mem);
    end

    always @(posedge clk)
        out <= mem[address];

endmodule
