module Register(
    input[15:0] in,
    input load,
    input clk,
    output [15:0] out
);
Bit bit0(.in(in[0]), .load(load), .clk(clk), .out(out[0]));
Bit bit1(.in(in[1]), .load(load), .clk(clk), .out(out[1]));
Bit bit2(.in(in[2]), .load(load), .clk(clk), .out(out[2]));
Bit bit3(.in(in[3]), .load(load), .clk(clk), .out(out[3]));
Bit bit4(.in(in[4]), .load(load), .clk(clk), .out(out[4]));
Bit bit5(.in(in[5]), .load(load), .clk(clk), .out(out[5]));
Bit bit6(.in(in[6]), .load(load), .clk(clk), .out(out[6]));
Bit bit7(.in(in[7]), .load(load), .clk(clk), .out(out[7]));
Bit bit8(.in(in[8]), .load(load), .clk(clk), .out(out[8]));
Bit bit9(.in(in[9]), .load(load), .clk(clk), .out(out[9]));
Bit bit10(.in(in[10]), .load(load), .clk(clk), .out(out[10]));
Bit bit11(.in(in[11]), .load(load), .clk(clk), .out(out[11]));
Bit bit12(.in(in[12]), .load(load), .clk(clk), .out(out[12]));
Bit bit13(.in(in[13]), .load(load), .clk(clk), .out(out[13]));
Bit bit14(.in(in[14]), .load(load), .clk(clk), .out(out[14]));
Bit bit15(.in(in[15]), .load(load), .clk(clk), .out(out[15]));

endmodule