`timescale 1ns/1ps
module RAM4K_tb;

  // Test bench signals
  reg  [15:0] in;
  reg         load;
  reg         clk;
  reg  [11:0] address;
  wire [15:0] out;

  // Instantiate the RAM4K module
  RAM4K uut (
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
    // Dump simulation waveforms to a VCD file (optional)
    $dumpfile("RAM4K_tb.vcd");
    $dumpvars(0, RAM4K_tb);
    
    // Monitor key signals
    $monitor("Time=%0t | Addr=%b | In=%h | Load=%b | Out=%h", 
             $time, address, in, load, out);

    // Initialize signals
    in = 16'h0000;
    load = 0;
    address = 12'b000000000000;
    #10;  // Wait one clock cycle

    // --- Test 1: Write to address 000_000000000 (Block 000, Offset 000000000) ---
    address = 12'b000000000000;
    in = 16'h1234;
    load = 1;       // Enable write
    #10;           // Data written on rising clock edge
    load = 0;       // Disable write
    #10;           // Wait for outputs to settle
    address = 12'b000000000000;  // Read back the same address
    #10;
    $display("Test 1 - Addr=000_000000000: Expected=1234, Got=%h", out);

    // --- Test 2: Write to address 001_000000000 (Block 001, Offset 000000000) ---
    address = 12'b001000000000;
    in = 16'hAAAA;
    load = 1;
    #10;
    load = 0;
    #10;
    address = 12'b001000000000;  // Read back the same address
    #10;
    $display("Test 2 - Addr=001_000000000: Expected=AAAA, Got=%h", out);

    // --- Test 3: Write to address 111_111111111 (Block 111, Offset 111111111) ---
    address = 12'b111111111111;
    in = 16'hDEAD;
    load = 1;
    #10;
    load = 0;
    #10;
    address = 12'b111111111111;  // Read back the same address
    #10;
    $display("Test 3 - Addr=111_111111111: Expected=DEAD, Got=%h", out);

    // --- Test 4: Write to address 011_101010101 (Block 011, Offset 101010101) ---
    address = 12'b011101010101;
    in = 16'hBEEF;
    load = 1;
    #10;
    load = 0;
    #10;
    address = 12'b011101010101;  // Read back the same address
    #10;
    $display("Test 4 - Addr=011_101010101: Expected=BEEF, Got=%h", out);
    
    // --- Test 5: Write to address 011_101010101 (Block 011, Offset 101010101) ---
    address = 12'b010001010101;
    in = 16'hBEEB;
    load = 1;
    #10;
    load = 0;
    #10;
    address = 12'b000001010101;  // Read back the same address
    #10;
    $display("Test 5 - Addr=011_101010101: Expected=XXXX, Got=%h", out);

    $finish;
  end

endmodule
