`timescale 1ns/1ps
module RAM16K_tb;

  // Test bench signals
  reg  [15:0] in;
  reg         load;
  reg         clk;
  reg  [14:0] address;
  wire [15:0] out;

  // Instantiate the RAM16K module
  RAM16K uut (
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
    $dumpfile("RAM16K_tb.vcd");
    $dumpvars(0, RAM16K_tb);
    
    // Monitor key signals
    $monitor("Time=%0t | Addr=%b | In=%h | Load=%b | Out=%h", 
             $time, address, in, load, out);

    // Initialize signals
    in = 16'h0000;
    load = 0;
    address = 15'b0;
    #10;  // Wait one clock cycle

    // --- Test 1: Write to address 15'b000_000000000000 ---
    // Block selection = 000, offset = 000000000000
    address = 15'b000_000000000000;
    in = 16'h1234;
    load = 1;       // Enable write
    #10;           // Data is written on rising clock edge
    load = 0;       // Disable write
    #10;           // Allow signals to settle

    // Read back from the same address
    address = 15'b000_000000000000;
    #10;
    $display("Test 1 - Addr=000_000000000000: Expected=1234, Got=%h", out);

    // --- Test 2: Write to address 15'b001_000000000001 ---
    // Block selection = 001, offset = 000000000001
    address = 15'b001_000000000001;
    in = 16'hAAAA;
    load = 1;
    #10;
    load = 0;
    #10;

    // Read back from the same address
    address = 15'b001_000000000001;
    #10;
    $display("Test 2 - Addr=001_000000000001: Expected=AAAA, Got=%h", out);

    // --- Test 3: Write to address 15'b010_000000000010 ---
    // Block selection = 010, offset = 000000000010
    address = 15'b010_000000000010;
    in = 16'hDEAD;
    load = 1;
    #10;
    load = 0;
    #10;

    // Read back from the same address
    address = 15'b010_000000000010;
    #10;
    $display("Test 3 - Addr=010_000000000010: Expected=DEAD, Got=%h", out);

    // --- Test 4: Write to address 15'b111_111111111111 ---
    // Block selection = 111, offset = 111111111111
    address = 15'b111_111111111111;
    in = 16'hBEEF;
    load = 1;
    #10;
    load = 0;
    #10;

    // Read back from the same address
    address = 15'b111_111111111111;
    #10;
    $display("Test 4 - Addr=111_111111111111: Expected=BEEF, Got=%h", out);

    $finish;
  end

endmodule
