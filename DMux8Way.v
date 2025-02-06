
module DMux8Way(
     input wire in, 
     input wire [2:0] sel,
     output wire a, b, c, d, e, f, g, h   
     );
     
wire outNS, out1, x, x1, out2;
nand(outNS, sel[2], sel[2]);
nand(x, outNS,  in );
nand(out1, x, x );
		
nand(x1, sel[2],  in );
nand(out2, x1, x1 );	

DMux4Way dmux4way_0(.in(out1), .sel(sel), .a(a), .b(b), .c(c), .d(d));
DMux4Way dmux4way_1(.in(out2), .sel(sel), .a(e), .b(f), .c(g), .d(h));


endmodule
