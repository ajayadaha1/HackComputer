module RAM8(

    input[15:0] in, 
    input load, 
    input clk,
    input[2:0] address,
    
    output [15:0] out
);
wire load0, load1, load2, load3, load4, load5, load6, load7;
wire [15:0] out0, out1, out2, out3, out4, out5, out6, out7, out_temp;

DMux8Way dumx8way_0(.in(load),.sel(address),.a(load0),.b(load1),.c(load2),.d(load3),.e(load4),.f(load5),.g(load6),.h(load7));

Register reg0 (.in(in),.load(load0),.clk(clk),.out(out0));
Register reg1 (.in(in),.load(load1),.clk(clk),.out(out1));
Register reg2 (.in(in),.load(load2),.clk(clk),.out(out2));
Register reg3 (.in(in),.load(load3),.clk(clk),.out(out3));
Register reg4 (.in(in),.load(load4),.clk(clk),.out(out4));
Register reg5 (.in(in),.load(load5),.clk(clk),.out(out5));
Register reg6 (.in(in),.load(load6),.clk(clk),.out(out6));
Register reg7 (.in(in),.load(load7),.clk(clk),.out(out7));

Mux8Way16 mux8way16_0(.a(out0),.b(out1),.c(out2),.d(out3),.e(out4),.f(out5),.g(out6),.h(out7),.s(address),.out(out));


endmodule