module Mux4Way16(
    input wire [15:0]a, b, c, d,
    input wire [1:0] s,
    
    output wire [15:0] out
    
); 
wire [15:0]  about, cdout;
Mux16 mux16_0 (.a(a), .b(b), .s(s[0]), .out(about));
Mux16 mux16_1 (.a(c), .b(d), .s(s[0]), .out(cdout));

Mux16 mux16_2 (.a(about), .b(cdout), .s(s[1]), .out(out));


endmodule 