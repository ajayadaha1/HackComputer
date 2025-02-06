`timescale 1ns/1ps
module RAM8_tb;

  // Test bench signals
  reg  [15:0] in;
  reg         load;
  reg         clk;
  reg  [2:0]  address;
  wire [15:0] out;

  // Instantiate the RAM8 module
  RAM8 uut (
    .in(in),
    .load(load),
    .clk(clk),
    .address(address),
    .out(out)
  );

  // Clock generation: 10 ns period (5 ns high, 5 ns low)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test stimulus
  initial begin
    // Dump simulation waveform to a VCD file (optional)
    $dumpfile("RAM8_tb.vcd");
    $dumpvars(0, RAM8_tb);
    
    // Monitor key signals
    $monitor("Time=%0t | Addr=%b | Load=%b | In=%h | Out=%h", 
             $time, address, load, in, out);

    // Initialize signals
    in      = 16'h0000;
    load    = 0;
    address = 3'b000;
    #10;  // wait for one clock cycle

    // --- Test 1: Write to address 0 ---
    // Write 0x1234 to register at address 0
    address = 3'b000;
    in      = 16'h1234;
    load    = 1;      
    #10; // Wait for positive edge: data is written to register 0
    load    = 0;  // Disable writing
    #10;        // Wait for output to settle

    // Read from address 0
    address = 3'b000;
    #10;
    $display("Test 1 - Read from address 0: Out = %h (expected 1234)", out);

    // --- Test 2: Write to address 3 ---
    // Write 0xFFFF to register at address 3
    address = 3'b011;
    in      = 16'hFFFF;
    load    = 1;
    #10; // Data is written to register 3 at the clock edge
    load    = 0;
    #10; // Wait for output to settle

    // Read from address 3
    address = 3'b011;
    #10;
    $display("Test 2 - Read from address 3: Out = %h (expected FFFF)", out);

    // --- Test 3: Write to address 5 ---
    // Write 0xABCD to register at address 5
    address = 3'b101;
    in      = 16'hABCD;
    load    = 1;
    #10; // Data is written to register 5
    load    = 0;
    #10; // Wait for output to settle

    // Read from address 5
    address = 3'b101;
    #10;
    $display("Test 3 - Read from address 5: Out = %h (expected ABCD)", out);

    // --- Test 4: Verify previous data remains ---
    // Read from address 0 again; it should still contain 0x1234
    address = 3'b000;
    #10;
    $display("Test 4 - Read from address 0 again: Out = %h (expected 1234)", out);

    $finish;
  end

endmodule
