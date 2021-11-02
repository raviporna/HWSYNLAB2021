`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2021 12:18:07 AM
// Design Name: 
// Module Name: system
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


module system(
    output [6:0] seg,
    output dp,
    output [3:0] an,
    input [7:0] sw, // [7:4] for Higher num hex, [3:0] for Lower num hex
    input btnU, // push stack
    input btnC, // pop stack -> display top value in num3,num2 and stack size in num1,num0
    input btnD, // reset
    input clk
    );
    
    wire [3:0] num3,num2,num1,num0; // left to right

    wire an0,an1,an2,an3;
    assign an={an3,an2,an1,an0};
    
    ////////////////////////////////////////
    // Clock
    wire targetClk;
    wire [18:0] tclk;
    
    assign tclk[0]=clk;
    
    genvar c;
    generate for(c=0;c<18;c=c+1) begin
        clockDiv fDiv(tclk[c+1],tclk[c]);
    end endgenerate
    
    clockDiv fdivTarget(targetClk,tclk[18]);
    
    ////////////////////////////////////////
    // Display
    quadSevenSeg q7seg(seg,dp,an0,an1,an2,an3,num0,num1,num2,num3,targetClk);
    
    ////////////////////////////////////////
    // Single Pulser
    wire push,pop,reset;
    singlePulser(push, btnU, targetClk);
    singlePulser(pop, btnC, targetClk);
    singlePulser(reset, btnD, targetClk);
    
    ////////////////////////////////////////
    // RAM
    SinglePortRAM stack({num1,num0},{num3,num2},sw[7:0],pop,targetClk,push,reset);
    

endmodule
