module Bit(
    input in, 
    input load,
    input clk, 
    output reg out
        
);

always @(posedge clk) begin
    if (load ==1'b1)
        out <=in;
    else 
        out <=out;        
 end

endmodule

