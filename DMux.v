module DMux(
    input wire in, sel,
    output wire a, b
);
wire s_not;
not (sel, s_not);

and(in, s_not, a);
and(in, sel, b); 


endmodule