`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2021 01:34:09 PM
// Design Name: 
// Module Name: testPulser
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


module testPulser();

    wire [3:0] outputs;
    wire d2, cout, bout;
    reg clk, pushed, set9, set0, inc, dec;

    singlePulser sp(d2,pushed,clk);
    BCDCounter bcd(outputs,cout,bout,set9,set0,inc,dec,clk);
    
    // clock
    always
        #10 clk=~clk;

    // testPulser
    initial begin
        #0  clk=0;
        #20
        #5  pushed = 1;
        #10 pushed = 0;
        #5  pushed = 1;
        #20 pushed = 0;
            
        #600 $finish;
    end
    
    // testBCDcounter
    initial begin
        #0 inc=0;dec=0;set9=0;set0=0;
        #20
        #10 inc = 1;
        #310
        #10 inc=0; dec=0; set0 = 1;
        #10 set0=0; set9 = 1;
        #10 set9=0; dec = 1;
        #310
        #10 inc=0; dec=0; set0 = 1;
        #10 set0=0; set9 = 1;
    end

endmodule
