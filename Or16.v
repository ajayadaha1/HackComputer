/**
 * 16-bit bitwise Or: out[i] = a[i] | b[i].
 */
module Or16(
    input wire [15:0] a, b,
    output wire [15:0] out
);
assign out = a | b;

endmodule
