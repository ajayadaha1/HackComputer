/**
 * The Hack CPU (Central Processing Unit), Nand2Tetris chapter 5.
 *
 * Executes the instruction stored in `instruction`:
 *  - If instruction[15]==0 it is an A-instruction: load its 15-bit value into A.
 *  - If instruction[15]==1 it is a C-instruction, decoded as
 *        1 1 1 a c1 c2 c3 c4 c5 c6 d1 d2 d3 j1 j2 j3
 *    where a selects A/M as the ALU y input, c1..c6 are the ALU control bits
 *    (zx,nx,zy,ny,f,no), d1..d3 are the destinations (A,D,M) and j1..j3 are the
 *    jump conditions (out<0, out==0, out>0).
 *
 * Outputs:
 *   outM      - value to write to memory M
 *   writeM    - 1 if M should be written this cycle
 *   addressM  - address of M in data memory (== A register)
 *   pc        - address of next instruction
 *
 * `clk` is added for the synchronous A/D/PC registers (abstracted away in HDL).
 */
module CPU(
    input  [15:0] inM,          // M value input  (RAM[A])
    input  [15:0] instruction,  // instruction to execute
    input         reset,        // reset==1 -> restart from ROM[0]
    input         en,           // step enable: CPU advances only when en==1
    input         clk,
    output [15:0] outM,         // M value output
    output        writeM,       // write to M?
    output [14:0] addressM,     // address of M in data memory
    output [14:0] pc            // address of next instruction
);

    wire isC =  instruction[15];   // 1 => C-instruction
    wire isA = ~instruction[15];   // 1 => A-instruction

    wire [15:0] aluOut;

    // ---------------- A register ----------------
    // Input: A-instruction value, else ALU result.
    wire [15:0] aRegIn;
    wire [15:0] aReg;
    Mux16 muxA(.a(instruction), .b(aluOut), .s(isC), .out(aRegIn));
    // Load A on any A-instruction, or a C-instruction whose d1 (dest A) bit is set.
    wire loadA = isA | (isC & instruction[5]);
    Register aRegister(.in(aRegIn), .load(loadA & en), .clk(clk), .out(aReg));

    assign addressM = aReg[14:0];

    // ---------------- ALU y input ----------------
    // a-bit (instruction[12]): 0 => A register, 1 => inM.
    wire [15:0] aluY;
    Mux16 muxY(.a(aReg), .b(inM), .s(instruction[12]), .out(aluY));

    // ---------------- D register ----------------
    // Load on a C-instruction whose d2 (dest D) bit is set.
    wire [15:0] dReg;
    wire loadD = isC & instruction[4];
    Register dRegister(.in(aluOut), .load(loadD & en), .clk(clk), .out(dReg));

    // ---------------- ALU ----------------
    wire zr, ng;
    ALU alu(
        .x(dReg), .y(aluY),
        .zx(instruction[11]), .nx(instruction[10]),
        .zy(instruction[9]),  .ny(instruction[8]),
        .f(instruction[7]),   .no(instruction[6]),
        .out(aluOut), .zr(zr), .ng(ng)
    );

    assign outM   = aluOut;
    assign writeM = isC & instruction[3];   // d3 (dest M)

    // ---------------- Jump logic ----------------
    wire pos    = ~ng & ~zr;                // out > 0
    wire jlt    = instruction[2] & ng;      // j1: out < 0
    wire jeq    = instruction[1] & zr;      // j2: out == 0
    wire jgt    = instruction[0] & pos;     // j3: out > 0
    wire doJump = isC & (jlt | jeq | jgt);

    // ---------------- Program counter ----------------
    // Jump loads A into PC; otherwise increment; reset has top priority.
    // The `en` gate freezes inc/jump between CPU steps; reset stays immediate.
    wire [15:0] pcOut;
    PC pc0(.in(aReg), .load(doJump & en), .inc(en), .reset(reset), .clk(clk), .out(pcOut));
    assign pc = pcOut[14:0];

endmodule
