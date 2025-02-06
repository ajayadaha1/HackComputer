`timescale 1ns/1ps
module RAM512_tb;

  // Test bench signals
  reg  [15:0] in;
  reg         load;
  reg         clk;
  reg  [8:0]  address;
  wire [15:0] out;

  // Instantiate the RAM512 module
  RAM512 uut (
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
    $dumpfile("RAM512_tb.vcd");
    $dumpvars(0, RAM512_tb);
    
    // Monitor key signals
    $monitor("Time=%0t | Addr=%b | In=%h | Load=%b | Out=%h", 
             $time, address, in, load, out);

    // Initialize signals
    in = 16'h0000;
    load = 0;
    address = 6'b000000;
    #10;  // wait one clock cycle

    // --- Test 1: Write to address 6'b000000 ---
    // Write 16'hAAAA to block 000 (address[5:3]=000) at internal address 000 (address[2:0]=000)
    address = 6'b000000;
    in = 16'hAAAA;
    load = 1;
    #10; // Data written on rising edge
    load = 0;
    #10; // Allow outputs to settle

    // Read from address 6'b000000
    address = 6'b000000;
    #10;
    $display("Test 1 - Addr=000000: Expected=AAAA, Got=%h", out);

    // --- Test 2: Write to address 6'b010101 ---
    // Write 16'hBBBB to block 010 (address[5:3]=010) at internal address 101 (address[2:0]=101)
    address = 6'b010101;
    in = 16'hBBBB;
    load = 1;
    #10;
    load = 0;
    #10;

    // Read from address 6'b010101
    address = 6'b010101;
    #10;
    $display("Test 2 - Addr=010101: Expected=BBBB, Got=%h", out);

    // --- Test 3: Write to address 6'b101010 ---
    // Write 16'hCCCC to block 101 (address[5:3]=101) at internal address 010 (address[2:0]=010)
    address = 6'b101010;
    in = 16'hCCCC;
    load = 1;
    #10;
    load = 0;
    #10;

    // Read from address 6'b101010
    address = 6'b101010;
    #10;
    $display("Test 3 - Addr=101010: Expected=CCCC, Got=%h", out);

    // --- Test 4: Read from an unwritten address ---
    // Read from address 6'b111111 (block 111, internal address 111)
    address = 6'b111111;
    load = 0;
    #10;
    $display("Test 4 - Addr=111111: Expected=0000, Got=%h", out);

    $finish;
  end

endmodule
