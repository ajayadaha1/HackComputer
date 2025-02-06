/**
 * The ALU (Arithmetic Logic Unit).
 * Computes one of the following functions:
 * x+y, x-y, y-x, 0, 1, -1, x, y, -x, -y, !x, !y,
 * x+1, y+1, x-1, y-1, x&y, x|y on two 16-bit inputs, 
 * according to 6 input bits denoted zx,nx,zy,ny,f,no.
 * In addition, the ALU computes two 1-bit outputs:
 * if the ALU output == 0, zr is set to 1; otherwise zr is set to 0;
 * if the ALU output < 0, ng is set to 1; otherwise ng is set to 0.
 */

// Implementation: the ALU logic manipulates the x and y inputs
// and operates on the resulting values, as follows:
// if (zx == 1) set x = 0        // 16-bit constant
// if (nx == 1) set x = !x       // bitwise not
// if (zy == 1) set y = 0        // 16-bit constant
// if (ny == 1) set y = !y       // bitwise not
// if (f == 1)  set out = x + y  // integer 2's complement addition
// if (f == 0)  set out = x & y  // bitwise and
// if (no == 1) set out = !out   // bitwise not
// if (out == 0) set zr = 1
// if (out < 0) set ng = 1

//`default_nettype wire
module ALU(
	input  [15:0] x,		// input x (16 bit)
	input  [15:0] y,		// input y (16 bit)
    input  zx, 				// zero the x input?
    input  nx, 				// negate the x input?
    input  zy, 				// zero the y input?
    input  ny, 				// negate the y input?
    input  f,  				// compute out = x + y (if 1) or x & y (if 0)
    input  no, 				// negate the out output?
    output  [15:0] out, 	// 16-bit output
    output  zr, 			// 1 if (out == 0), 0 otherwise
    output  ng 			    // 1 if (out < 0),  0 otherwise
);

// your implementation comes here:

wire [15:0] inzx;
wire [15:0] notx; 
wire [15:0] inzxnx; 
wire [15:0] inzy;
wire [15:0] noty; 
wire [15:0] inzyny; 
wire [15:0] addxy;
wire [15:0] andxy; 
wire [15:0] outzxnxzynyf; 
wire [15:0] notoutzxnxzynyf;
wire [7:0] finalOutLow;
wire [7:0] finalOutHigh;
wire zr1;
wire zr2;
wire nzr;
wire [15:0] sout;
wire[15:0] out_temp;

Mux16 Mux16_0(.a(x), .b(16'b0), .s(zx), .out(inzx));
Not16 Not16_0(.a(inzx), .out(notx));
Mux16 Mux16_1(.a(inzx), .b(notx), .s(nx), .out(inzxnx));

Mux16 Mux16_2(.a(y), .b(16'b0), .s(zy), .out(inzy));
Not16 Not16_1(.a(inzy), .out(noty));
Mux16 Mux16_3(.a(inzy), .b(noty), .s(ny), .out(inzyny));

Add16 Add16_0(.a(inzxnx), .b(inzyny), .sum(addxy));
And16 And16_0(.a(inzxnx), .b(inzyny), .out(andxy));

Mux16 Mux16_4(.a(andxy), .b(addxy), .s(f), .out(outzxnxzynyf));

Not16 Not16_2(.a(outzxnxzynyf), .out(notoutzxnxzynyf));
Mux16 Mux16_5(.a(outzxnxzynyf), .b(notoutzxnxzynyf), .s(no), .out(sout));

And16 And16_2(.a(sout), .b(16'b1111111111111111), .out(out_temp));
assign finalOutLow = out_temp[7:0];
assign finalOutHigh = out_temp[15:8];

Or8Way Or8Way_0(.a(finalOutLow),  .out(zr1));
Or8Way Or8Way_1(.a(finalOutHigh), .out(zr2));
assign nzr = zr1 | zr2;
assign zr = ~nzr;

wire[15:0] ng_temp;
And16 And16_3(.a(sout), .b(16'b1111111111111111), .out(ng_temp));
assign ng = ng_temp[15];

And16 And16_4(.a(sout), .b(16'b1111111111111111), .out(out));

endmodule