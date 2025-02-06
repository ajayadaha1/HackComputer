`timescale 1ns/1ps
module Bit_tb;

  // Declare test bench signals
  reg in;
  reg load;
  reg clk;
  wire out;
  
  // Instantiate the Bit module
  Bit uut (
    .in(in),
    .load(load),
    .clk(clk),
    .out(out)
  );

  // Clock generation: 10 ns period (5 ns high, 5 ns low)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test stimulus
  initial begin
    // Create a VCD file for waveform viewing (optional)
    $dumpfile("Bit_tb.vcd");
    $dumpvars(0, Bit_tb);
    
    // Monitor signal changes
    $monitor("Time = %t | in = %b, load = %b, out = %b", $time, in, load, out);

    // Initialize inputs
    in = 0;
    load = 0;
    #10; // wait for one clock cycle

    // Apply stimulus:
    // 1. Enable load: out should update to 'in'
    load = 1;
    in = 0;  // out should become 0 at the next rising edge
    #10;

    // 2. Change 'in' to 1 with load still high: out should update to 1
    in = 1;
    #10;
    
    // 3. Disable load: even if 'in' changes, out should hold its value (1)
    load = 0;
    in = 0; // out should remain 1
    #10;
    
    // 4. Re-enable load: out should update to the new value of 'in'
    load = 1;
    in = 0;  // out should become 0
    #10;
    
    // End simulation
    $finish;
  end

endmodule
