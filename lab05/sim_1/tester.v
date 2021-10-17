`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2021 10:28:58 PM
// Design Name: 
// Module Name: tester
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


module tester();

wire [31:0] S;
wire z;
wire Cout;
reg [31:0] A;
reg [31:0]  B;
reg Cin;
reg [2:0] alu_ops;

alu ALU(S, z, Cout, A, B, Cin, alu_ops);

initial
begin
    #0;
    Cin = 0;
    alu_ops = 0;
    A = 3;
    B = 8;
    #10 Cin = 1;
    #10 alu_ops = 1;
    #10 alu_ops = 2;
    #10 alu_ops = 3;
    #10 alu_ops = 4;
    #10 alu_ops = 5;
    #10 alu_ops = 6;
    #10 alu_ops = 7;
    
    #10;
    $finish;
end
endmodule
