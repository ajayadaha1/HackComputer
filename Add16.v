//`default_nettype none
module Add16(
    input  [15:0] a, b,
    output  [15:0] sum
);

wire carry0, carry1, carry2, carry3, carry4, carry5, carry6, carry7, carry8, carry9, carry10, carry11, carry12, carry13, carry14 ;

Halfadder halfadder_0 (.a(a[0]), .b(b[0]), .sum(sum[0]), .carry(carry0));
Fulladder fulladder_1 (.a(a[1]), .b(b[1]), .c(carry0), .sum(sum[1]), .carry(carry1));
Fulladder fulladder_2(.a(a[2]), .b(b[2]), .c(carry1), .sum(sum[2]), .carry(carry2));
Fulladder fulladder_3(.a(a[3]), .b(b[3]), .c(carry2), .sum(sum[3]), .carry(carry3));
Fulladder fulladder_4(.a(a[4]), .b(b[4]), .c(carry3), .sum(sum[4]), .carry(carry4));
Fulladder fulladder_5(.a(a[5]), .b(b[5]), .c(carry4), .sum(sum[5]), .carry(carry5));
Fulladder fulladder_6(.a(a[6]), .b(b[6]), .c(carry5), .sum(sum[6]), .carry(carry6));
Fulladder fulladder_7(.a(a[7]), .b(b[7]), .c(carry6), .sum(sum[7]), .carry(carry7));
Fulladder fulladder_8(.a(a[8]), .b(b[8]), .c(carry7), .sum(sum[8]), .carry(carry8));
Fulladder fulladder_9(.a(a[9]), .b(b[9]), .c(carry8), .sum(sum[9]), .carry(carry9));
Fulladder fulladder_10(.a(a[10]), .b(b[10]), .c(carry9), .sum(sum[10]), .carry(carry10));
Fulladder fulladder_11(.a(a[11]), .b(b[11]), .c(carry10), .sum(sum[11]), .carry(carry11));
Fulladder fulladder_12(.a(a[12]), .b(b[12]), .c(carry11), .sum(sum[12]), .carry(carry12));
Fulladder fulladder_13(.a(a[13]), .b(b[13]), .c(carry12), .sum(sum[13]), .carry(carry13));
Fulladder fulladder_14(.a(a[14]), .b(b[14]), .c(carry13), .sum(sum[14]), .carry(carry14));
Fulladder fulladder_15(.a(a[15]), .b(b[15]), .c(carry14), .sum(sum[15]), .carry(carry15));


endmodule 