
//`default_nettype none

module Mux16(
    input  [15:0] a, 
    input  [15:0] b,
    input  s,
    output  [15:0] out
);

//wire[15:0] out_temp;

 Mux mux_inst0 (
            .a(a[0]), 
            .b(b[0]), 
            .s(s), 
            .out(out[0])
        );

 Mux mux_inst1 (
            .a(a[1]), 
            .b(b[1]), 
            .s(s), 
            .out(out[1])
        );

 Mux mux_inst2 (
            .a(a[2]), 
            .b(b[2]), 
            .s(s), 
            .out(out[2])
        );

 Mux mux_inst3 (
            .a(a[3]), 
            .b(b[3]), 
            .s(s), 
            .out(out[3])
        );

 Mux mux_inst4 (
            .a(a[4]), 
            .b(b[4]), 
            .s(s), 
            .out(out[4])
        );

 Mux mux_inst15 (
            .a(a[15]), 
            .b(b[15]), 
            .s(s), 
            .out(out[15])
        );

 Mux mux_inst5 (
            .a(a[5]), 
            .b(b[5]), 
            .s(s), 
            .out(out[5])
        );

 Mux mux_inst6 (
            .a(a[6]), 
            .b(b[6]), 
            .s(s), 
            .out(out[6])
        );

 Mux mux_inst7 (
            .a(a[7]), 
            .b(b[7]), 
            .s(s), 
            .out(out[7])
        );

 Mux mux_inst8 (
            .a(a[8]), 
            .b(b[8]), 
            .s(s), 
            .out(out[8])
        );

 Mux mux_inst9 (
            .a(a[9]), 
            .b(b[9]), 
            .s(s), 
            .out(out[9])
        );

 Mux mux_inst10 (
            .a(a[10]), 
            .b(b[10]), 
            .s(s), 
            .out(out[10])
        );

 Mux mux_inst11 (
            .a(a[11]), 
            .b(b[11]), 
            .s(s), 
            .out(out[11])
        );

 Mux mux_inst12 (
            .a(a[12]), 
            .b(b[12]), 
            .s(s), 
            .out(out[12])
        );

 Mux mux_inst13 (
            .a(a[13]), 
            .b(b[13]), 
            .s(s), 
            .out(out[13])
        );

 Mux mux_inst14 (
            .a(a[14]), 
            .b(b[14]), 
            .s(s), 
            .out(out[14])
        );



 //assign out_mux = out_temp;

endmodule
