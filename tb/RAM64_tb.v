`timescale 1ns/1ps
module RAM64_tb;

  // Test bench signals
  reg  [15:0] in;
  reg         load;
  reg         clk;
  reg  [5:0]  address;
  wire [15:0] out;

  // Instantiate the RAM64 module
  RAM64 uut (
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
    $dumpfile("RAM64_tb.vcd");
    $dumpvars(0, RAM64_tb);
    
    // Monitor key signals
    $monitor("Time=%0t | Addr=%b | In=%h | Load=%b | Out=%h", 
             $time, address, in, load, out);

    // Initialize signals
    in = 16'h0000;
    load = 0;
    address = 6'b000000;
    #10;  // wait for one clock cycle

    // --- Test 1: Write to address 6'b000000 ---
    // Write value 16'hAAAA to block 000, index 000.
    address = 6'b000000;  // Upper 3 bits (000) select RAM8 block, lower 3 bits (000) select register within block.
    in = 16'hAAAA;
    load = 1;
    #10; // Data is written on the rising edge.
    load = 0;
    #10; // Allow signals to settle.

    // Read back from address 6'b000000
    address = 6'b000000;
    #10;
    $display("Test 1 - Addr=000000: Expected=AAAA, Got=%h", out);

    // --- Test 2: Write to address 6'b001010 ---
    // Write value 16'hBBBB to block 001, index 010.
    address = 6'b001010;  
    in = 16'hBBBB;
    load = 1;
    #10; // Write on clock edge.
    load = 0;
    #10;

    // Read from address 6'b001010
    address = 6'b001010;
    #10;
    $display("Test 2 - Addr=001010: Expected=BBBB, Got=%h", out);

    // --- Test 3: Write to address 6'b101101 ---
    // Write value 16'hCCCC to block 101, index 101.
    address = 6'b101101;  
    in = 16'hCCCC;
    load = 1;
    #10; // Write on clock edge.
    load = 0;
    #10;

    // Read from address 6'b101101
    address = 6'b101101;
    #10;
    $display("Test 3 - Addr=101101: Expected=CCCC, Got=%h", out);

    // --- Test 4: Read from an unwritten address ---
    // Expect a default value (typically 0) if not previously written.
    address = 6'b010101;  
    load = 0;
    #10;
    $display("Test 4 - Addr=010101: Expected=XXXX, Got=%h", out);

    $finish;
  end

endmodule
