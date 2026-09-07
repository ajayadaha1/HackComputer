/**
 * 16-bit incrementer: out = in + 1 (2's complement, overflow wraps).
 * Built from the existing Add16 ripple-carry adder to stay in the
 * Nand2Tetris chip-composition style.
 */
module Inc16(
    input  [15:0] in,
    output [15:0] out
);

Add16 add16_0(.a(in), .b(16'b0000000000000001), .sum(out));

endmodule
