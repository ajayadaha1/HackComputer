`timescale 1ns / 1ps

module Mux_tb;
    reg a, b, s;
    wire out;

    // Instantiate the Mux module
    Mux uut (
        .a(a),
        .b(b),
        .s(s),
        .out(out)
    );

    // Test sequence
    initial begin
        $monitor("a=%b, b=%b, s=%b, out=%b", a, b, s, out);

        // Apply all possible input combinations
        a = 0; b = 0; s = 0; #10;
        a = 0; b = 0; s = 1; #10;
        a = 0; b = 1; s = 0; #10;
        a = 0; b = 1; s = 1; #10;
        a = 1; b = 0; s = 0; #10;
        a = 1; b = 0; s = 1; #10;
        a = 1; b = 1; s = 0; #10;
        a = 1; b = 1; s = 1; #10;
        
        $finish;
    end
endmodule
