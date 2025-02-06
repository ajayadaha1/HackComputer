//`default_nettype none

module Not16(
    input  [15:0] a,
    output [15:0] out
    );
    
    assign out[0] = !a[0] ;
    assign out[1] = !a[1] ;
    assign out[2] = !a[2] ;
    assign out[3] = !a[3] ;
    assign out[4] = !a[4] ;
    assign out[5] = !a[5] ;
    assign out[6] = !a[6] ;
    assign out[7] = !a[7] ;
    assign out[8] = !a[8] ;
    assign out[9] = !a[9] ;
    assign out[10] = !a[10] ;
    assign out[11] = !a[11] ; 
    assign out[12] = !a[12] ;
    assign out[13] = !a[13] ;
    assign out[14] = !a[14] ; 
    assign out[15] = !a[15] ;
    
    
endmodule
