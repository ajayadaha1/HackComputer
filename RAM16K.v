module RAM16K(
    input[15:0] in, 
    input load, 
    input clk,
    input[14:0] address,
    
    output [15:0] out
);
wire load0, load1, load2, load3, load4, load5, load6, load7;
wire [15:0] out0, out1, out2, out3, out4, out5, out6, out7, out_temp;

DMux8Way dumx8way_0(.in(load),.sel(address[14:12]),.a(load0),.b(load1),.c(load2),.d(load3),.e(load4),.f(load5),.g(load6),.h(load7));

RAM4K ram8_0(.in(in),.load(load0),.clk(clk),.address(address[11:0]),.out(out0));
RAM4K ram8_01(.in(in),.load(load1),.clk(clk),.address(address[11:0]),.out(out1));
RAM4K ram8_02(.in(in),.load(load2),.clk(clk),.address(address[11:0]),.out(out2));
RAM4K ram8_03(.in(in),.load(load3),.clk(clk),.address(address[11:0]),.out(out3));
RAM4K ram8_04(.in(in),.load(load4),.clk(clk),.address(address[11:0]),.out(out4));
RAM4K ram8_05(.in(in),.load(load5),.clk(clk),.address(address[11:0]),.out(out5));
RAM4K ram8_06(.in(in),.load(load6),.clk(clk),.address(address[11:0]),.out(out6));
RAM4K ram8_07(.in(in),.load(load7),.clk(clk),.address(address[11:0]),.out(out7));

Mux8Way16 mux8way16_0(.a(out0),.b(out1),.c(out2),.d(out3),.e(out4),.f(out5),.g(out6),.h(out7),.s(address[14:12]),.out(out));


endmodule