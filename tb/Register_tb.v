`timescale 1ns/1ps
module Register_tb;

  // Declare test bench signals
  reg  [15:0] in;
  reg         load;
  reg         clk;
  wire [15:0] out;
  
  // Instantiate the Register module
  Register uut (
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
    $dumpfile("Register_tb.vcd");
    $dumpvars(0, Register_tb);
    
    // Monitor signal changes
    $monitor("Time = %t | in = %h, load = %b, out = %h", $time, in, load, out);

    // Initialize inputs
    in   = 16'h0000;
    load = 0;
    #10; // wait for a clock cycle

    // 1. Enable load and provide a new value
    load = 1;
    in   = 16'hA5A5; // 1010_0101_1010_0101 in binary
    #10; // At the next rising edge, out should update to 16'hA5A5

    // 2. Disable load and change input; out should hold its previous value
    load = 0;
    in   = 16'h5A5A; // 0101_1010_0101_1010 in binary
    #10; // out remains 16'hA5A5

    // 3. Re-enable load to update the register with the new value
    load = 1;
    #10; // out updates to 16'h5A5A on the next rising edge

    // End simulation
    $finish;
  end

endmodule
