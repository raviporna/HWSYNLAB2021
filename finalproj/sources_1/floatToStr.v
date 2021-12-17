`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2021 07:33:42 PM
// Design Name: 
// Module Name: floatToStr
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


module floatToStr(
    input signed [63:0]  float,
    output       [7:0]   signbuffer,
    output       [47:0]  outputbufferBFD,
    output       [47:0]  outputbufferAFD,
    output reg           validout
    );
    
    reg signed  [63:0]  f1,f2;
    reg signed  [7:0]   a1,a2,a3,a4,a5,a6;
    wire        [15:0]  o1,o2,o3,o4,o5,o6;
    wire                negative;
    
    assign negative         = float[63];
    assign signbuffer       = (negative)? 8'h2D: 8'h2B;
    assign outputbufferBFD  = {o1,o2,o3};
    assign outputbufferAFD  = {o4,o5,o6};
    
    intToChar2 i2c1(a1, o1);
    intToChar2 i2c2(a2, o2);
    intToChar2 i2c3(a3, o3);
    intToChar2 i2c4(a4, o4);
    intToChar2 i2c5(a5, o5);
    intToChar2 i2c6(a6, o6);
    
    always @(float) begin
        f1 = float;
        if(negative) f1 = -float;
        
        f1 = f1/1000000;
        f2 = float - f1*1000000;
        if(negative) f2 = -float - f1*1000000;
        
        a1 = f1/10000; f1 = f1-a1*10000;
        a2 = f1/100;
        a3 = f1-a2*100;
        a4 = f2/10000; f2 = f2-a4*10000;
        a5 = f2/100;
        a6 = f2-a5*100;
        if(a1>=$signed(8'd100)) validout = 0;
        else validout = 1;
    end
endmodule

module intToChar2(input [7:0] i, output [15:0] c);
    reg [7:0] a;
    reg [3:0] i1,i2;
    
    intToChar i2c1(i1, c[15:8]);
    intToChar i2c2(i2, c[7:0]);
    
    always @(i) begin
        a = i;
        i1 = a/10;
        i2 = a-i1*10;
    end
endmodule

module intToChar(input [3:0] f, output reg [7:0] c);
    always @(f)
        case(f)
            0: c = 8'h30;
            1: c = 8'h31;
            2: c = 8'h32;
            3: c = 8'h33;
            4: c = 8'h34;
            5: c = 8'h35;
            6: c = 8'h36;
            7: c = 8'h37;
            8: c = 8'h38;
            9: c = 8'h39;
        endcase
endmodule