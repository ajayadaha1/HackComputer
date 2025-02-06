//`default_nettype none
module Or8Way(
    input [7:0] a, 
    output  out
);
wire a01, a0123, a01234, a012345, a0123456, a01234567;
assign a01 = (a[0] | a[1]);
assign a0123 = (a[2] | a01);
assign a01234 = (a[3] | a0123);
assign a012345 = (a[4] | a01234);
assign a0123456 = (a[5] | a012345);
assign a01234567 = (a[6] | a0123456);
assign out = (a[7] | a01234567);

endmodule