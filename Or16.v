module Or16(
    input wire [15:0] a, b, 
    output wire [15:0] out
);

or(a[0], b[0], out[0]);
or(a[1], b[1], out[1]);
or(a[2], b[2], out[2]);
or(a[3], b[3], out[3]);
or(a[4], b[4], out[4]);
or(a[5], b[5], out[5]);
or(a[6], b[6], out[6]);
or(a[7], b[7], out[7]);
or(a[8], b[8], out[8]);
or(a[9], b[9], out[9]);
or(a[10], b[10], out[10]);
or(a[11], b[11], out[11]);
or(a[12], b[12], out[12]);
or(a[13], b[13], out[13]);
or(a[14], b[14], out[14]);
or(a[15], b[15], out[15]);

endmodule 
