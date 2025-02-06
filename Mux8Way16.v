module Mux8Way16(
    input wire [15:0] a, b, c, d, e, f, g, h,
    input wire [2:0] s,
    
    output wire [15:0] out
    
); 
wire [15:0]  abcdout, efghout;

Mux4Way16 mux4way16_0 (.a(a), .b(b), .c(c), .d(d), .s(s[1:0]), .out(abcdout));
Mux4Way16 mux4way16_1 (.a(e), .b(f), .c(g), .d(h), .s(s[1:0]), .out(efghout));

Mux16 mux16_0(.a(abcdout), .b(efghout), .s(s[2]), .out(out));

endmodule 