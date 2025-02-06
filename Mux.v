//`default_nettype none

//module Mux(
//    input wire a, 
//    input wire b, 
//    input wire s,
//    output wire out
//);
//wire s_not, a_s_not, b_s, out_temp;

//not (s_not, s);
//and (a_s_not, a, s_not);
//and (b_s, b, s);
//or (out_temp, a_s_not, b_s);

//assign out = out_temp;

//endmodule

/** 
 * Multiplexor:
 * out = a if sel == 0
 *       b otherwise
 */
//`default_nettype none

module Mux(
    input  a,
    input  b,
    input  s,
    output  out
);

// your implementation comes here:

//wire nots, anandnots, bnands;

//not(nots, s);
//nand(anandnots , a , nots);
//nand(bnands, b , sel);
//nand(out, anandnots , bnands);
assign out = s? b:a;

endmodule
