`timescale 1ns / 1ps

module Mux16_tb;
    reg [15:0] a, b;
    reg s;
    wire [15:0] out;
    
    Mux16 uut (
        .a(a),
        .b(b),
        .s(s),
        .out(out)
    );
    
    initial begin
        $monitor("Time=%0t | a=%b | b=%b | s=%b | out=%b", $time, a, b, s, out);
        
        // Test case 1
        a = 16'b0000000000000000;
        b = 16'b0000000000000000;
        s = 0;
        #10;
        
        // Test case 2
        s = 1;
        #10;
        
        // Test case 3
        a = 16'b0000000000000000;
        b = 16'b0001001000110100;
        s = 0;
        #10;
        
        // Test case 4
        s = 1;
        #10;
        
        // Test case 5
        a = 16'b1001100001110110;
        b = 16'b0000000000000000;
        s = 0;
        #10;
        
        // Test case 6
        s = 1;
        #10;
        
        // Test case 7
        a = 16'b1010101010101010;
        b = 16'b0101010101010101;
        s = 0;
        #10;
        
        // Test case 8
        s = 1;
        #10;
        
        $finish;
    end
endmodule
