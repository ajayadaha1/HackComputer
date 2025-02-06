module DMux4Way(
    input wire in, 
    input wire [1:0] sel,
    output wire a, b, c, d
);
wire outNS0, outNS1, x0, x1, x2, x3, t4, t3, t2, t1, t0, y0, y1, y2, y3;
nand(outNS0, sel[0], sel[0]);
nand(outNS1, sel[1], sel[1]);
	
nand(x0, outNS0, outNS1);
nand(t1, x0, x0 );
		
nand(x1, outNS1,   sel[0] );
nand(t2, x1, x1);	
		
nand(x2,  sel[1],   outNS0);
nand(t3, x2, x2);
		
nand(x3, sel[0],  sel[1]);
nand(t4, x3, x3);
		
nand(y0, t1,   in);
nand(a, y0, y0);
		
nand(y1, t2,   in);
nand(b, y1, y1);
		
nand(y2, t3,   in);
nand(c, y2, y2);
		
nand(y3, t4,   in);
nand(d, y3, y3);


endmodule