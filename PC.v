/**
 * A 16-bit program counter with load, increment and reset.
 * Priority (highest first) on each clock rising edge:
 *   if (reset==1) out = 0
 *   else if (load==1) out = in
 *   else if (inc==1)  out = out + 1
 *   else              out = out   (hold)
 * Composed from Inc16, Mux16 and Register, matching the course design.
 */
module PC(
    input  [15:0] in,
    input  load,
    input  inc,
    input  reset,
    input  clk,
    output [15:0] out
);

wire [15:0] incOut;
wire [15:0] muxInc;
wire [15:0] muxLoad;
wire [15:0] muxReset;
wire [15:0] regOut;

Inc16  inc16_0 (.in(regOut),  .out(incOut));
Mux16  muxI    (.a(regOut),   .b(incOut),  .s(inc),   .out(muxInc));
Mux16  muxL    (.a(muxInc),   .b(in),      .s(load),  .out(muxLoad));
Mux16  muxR    (.a(muxLoad),  .b(16'b0),   .s(reset), .out(muxReset));
Register reg0  (.in(muxReset), .load(1'b1), .clk(clk), .out(regOut));

assign out = regOut;

endmodule
