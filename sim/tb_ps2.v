`timescale 1ns/1ps
// Focused PS/2 receiver debug: sends bytes and prints decoded scancode/key_code.
module tb_ps2;
    reg clk = 0, rst = 1;
    reg PS2Clk = 1'b1, PS2Data = 1'b1;
    wire [15:0] key_code;

    ps2_keyboard dut(.clk(clk), .rst(rst), .ps2_clk(PS2Clk), .ps2_data(PS2Data), .key_code(key_code));

    always #5 clk = ~clk;
    localparam THALF = 1000;

    task send_bit(input b);
        begin
            PS2Data = b;
            PS2Clk  = 1'b1; #THALF;
            PS2Clk  = 1'b0; #THALF;
        end
    endtask
    task send_byte(input [7:0] d);
        integer i; reg par;
        begin
            par = ~(^d);
            send_bit(1'b0);
            for (i = 0; i < 8; i = i + 1) send_bit(d[i]);
            send_bit(par);
            send_bit(1'b1);
            PS2Clk = 1'b1; PS2Data = 1'b1; #(THALF*4);
        end
    endtask

    // print whenever the receiver latches a byte
    always @(posedge clk)
        if (dut.byte_valid)
            $display("byte_valid: scancode=0x%02h frame=0x%03h key_code=%0d", dut.scancode, dut.frame, key_code);

    initial begin
        rst = 1; repeat (10) @(posedge clk); rst = 0;
        // reproduce tb_top order exactly
        send_byte(8'hE0); send_byte(8'h6B);        // left make
        repeat (200) @(posedge clk);
        $display("after left: key_code=%0d", key_code);
        send_byte(8'hE0); send_byte(8'hF0); send_byte(8'h6B); // left break
        repeat (200) @(posedge clk);
        $display("after release: key_code=%0d", key_code);
        send_byte(8'h29);   // space
        repeat (200) @(posedge clk);
        $display("after space: key_code=%0d", key_code);
        $finish;
    end
endmodule
