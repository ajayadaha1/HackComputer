/**
 * Demultiplexor:
 * {a, b} = {in, 0} if sel == 0
 *          {0, in} if sel == 1
 */
module DMux(
    input wire in, sel,
    output wire a, b
);
assign a = in & ~sel;
assign b = in &  sel;

endmodule
