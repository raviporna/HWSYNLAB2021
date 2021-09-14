`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2021 10:16:23 PM
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
    input [7:0] sw, // [7:4] for inputA, [3:0] for inputB
    input btnU, btnL, btnD, btnR,
    input clk
    );
    
    reg [3:0] num3,num2,num1,num0; // left to right
    
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
    // ROM and control
    reg [15:0] rom[2**10-1:0];
    initial $readmemb("rom4.data", rom);
    
    reg [1:0] mode;
    
    always @(posedge targetClk && (btnU || btnL || btnD || btnR)) begin
        case({btnU, btnL, btnD, btnR})
            4'b1000: mode = 0; //plus
            4'b0100: mode = 1; //subtract
            4'b0010: mode = 2; //multiply
            4'b0001: mode = 3; //divide
        endcase
        {num3,num2, num1, num0} = rom[{mode,sw[7:0]}];
    end
    
    
endmodule
