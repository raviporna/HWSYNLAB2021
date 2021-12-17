`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2021 07:31:43 PM
// Design Name: 
// Module Name: calculator
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


module calculator(
    input clk, input reset,
    input wire signed [63:0]   inputval,
    input wire        [2:0]    op,
    input wire                 en,
    output reg signed [63:0]   outputval
    );
    
    //////////////////////////////////
    // ALU
    reg  signed [63:0] currentval;     // current val in the accumulator
    wire signed [63:0] aluval;
    alu alu1(currentval, inputval, op, aluval);
    
    reg state;

    initial begin state = 0; currentval = 0; end
    always @(posedge clk) begin
        if(reset)       begin currentval = 0;           state = 0; end
        case(state)
            0: if(en)   begin currentval = aluval;      state = 1; end
            1: if(~en)  begin outputval = currentval;   state = 0; end
        endcase
    end
endmodule

module alu(
    input       signed  [63:0]  A,
    input       signed  [63:0]  B,
    input               [2:0]   op,
    output reg  signed  [63:0]  S
    );
    
    always@(A or B or op)
        case(op)
            0: S = A+B;
            1: S = A-B;
            2: S = (A*B)/1000000;
            3: S = (A*1000000)/B;
            4: S = A;
            5: S = 0;
        endcase
endmodule