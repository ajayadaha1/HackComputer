module Fulladder(
    input  a, b, c,
    output  sum, carry
);
wire asumb, acarryb, asumbsumccarry;
Halfadder halfadder_0(.a(a), .b(b), .sum(asumb), .carry(acarryb));
Halfadder halfadder_1(.a(asumb), .b(c), .sum(sum), .carry(asumbsumccarry));
or(carry, acarryb, asumbsumccarry);

endmodule