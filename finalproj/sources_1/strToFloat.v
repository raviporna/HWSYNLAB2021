`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2021 07:32:57 PM
// Design Name: 
// Module Name: strToFloat
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module strToFloat(input [95:0] buffer, output [63:0] val);
    wire    [31:0]  val1,val2;
    strToFloat2 s2f1(buffer[95:48],val1);
    strToFloat2 s2f2(buffer[47:0],val2);
    assign val = val1*1000000 + val2;
endmodule

module strToFloat2(input [47:0] buffer, output [31:0] val);
    wire    [3:0]   a1,a2,a3,a4,a5,a6;
    wire    [7:0]   i1,i2,i3,i4,i5,i6;
    assign {i1,i2,i3,i4,i5,i6} = buffer;
    
    charToInt c1(i1, a1);
    charToInt c2(i2, a2);
    charToInt c3(i3, a3);
    charToInt c4(i4, a4);
    charToInt c5(i5, a5);
    charToInt c6(i6, a6);
    
    wire    [19:0]  v1,v2,v3,v4,v5,v6;
    assign v1 = a1*100*1000;
    assign v2 = a2*10*1000;
    assign v3 = a3*1000;
    assign v4 = a4*100;
    assign v5 = a5*10;
    assign v6 = a6;
    assign val = v1+v2+v3+v4+v5+v6;
endmodule

module charToInt(input wire [7:0] c, output reg [3:0] i);
    always @(c)
        case(c)
            8'h30: i=0;
            8'h31: i=1;
            8'h32: i=2;
            8'h33: i=3;
            8'h34: i=4;
            8'h35: i=5;
            8'h36: i=6;
            8'h37: i=7;
            8'h38: i=8;
            8'h39: i=9;
        endcase
endmodule