`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2021 07:27:04 PM
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

module system(output wire RsTx, input wire RsRx,input clk, input btnC);

    //////////////////////////////////
    // uart
    wire                baud;           // baudrate
    baudrate_gen baudrate(clk, baud);
    
    wire    [7:0]       data_out;       // 1 char from receive
    wire                received;       // = received 8 bits successfully
    reg                 last_rec;       // = check if received is new
    wire                new_input;
    assign new_input = ~last_rec & received;
    uart_rx receiver(baud, RsRx, received, data_out);
    
    reg     [7:0]       data_in;        // 1 char to transmit
    wire                sent;           // = sent 8 bits successfully
    reg                 wr_en;          // = enable transmitter
    uart_tx transmitter(baud, data_in, wr_en, sent, RsTx);
    
    //////////////////////////////////
    // push button
    wire                reset;
    singlePulser resetButton(reset, btnC, baud);
    
    //////////////////////////////////
    // r/w buffer
    reg     [159:0]     writebuffer;    // 20 chars
    reg     [47:0]      readbufferBFD;  // 6 chars
    reg     [47:0]      readbufferAFD;  // 6 chars
    reg     [3:0]       AFDidx;         // index of readbufferAFD from 6 to 1
    
    //////////////////////////////////
    // casting i/o
    reg     [95:0]      inputbuffer;
    wire    [63:0]      inputval;
    strToFloat inputCast(inputbuffer, inputval);
    
    wire    [159:0]     outputbuffer;
    wire    [63:0]      outputval;
    wire                validOutput;    // for invalid output (NaN)
    wire    [7:0]       signbuffer;
    wire    [47:0]      bufferBFD, bufferAFD;
    assign outputbuffer = {16'h0D0A,signbuffer,bufferBFD,8'h2E,bufferAFD,32'h203E3E20};
    
    floatToStr outputCast(outputval, signbuffer, bufferBFD, bufferAFD, validOutput);
    
    //////////////////////////////////
    // calculation
    reg     [2:0]       op;             // 0+ 1- 2* 3/ 4s 5c
    reg                 enterkey;
    reg                 calculate;
    calculator cal(baud, reset, inputval, op, calculate, outputval);

    //////////////////////////////////
    // state
    reg     [2:0]       state;
    parameter STATE_OPERATOR        = 3'd0;
    parameter STATE_BEFOREPOINT    	= 3'd1;
    parameter STATE_AFTERPOINT      = 3'd2;
    parameter STATE_SENDMORE    	= 3'd3;
    parameter STATE_DELAY           = 3'd4;
    parameter STATE_ENTERKEY        = 3'd5;
    parameter STATE_CALCULATE       = 3'd6;
    
    reg     [7:0]       sendlen;        // length of sending sting
    reg     [7:0]       counter;        // for delay state
    
    reg beforePoint;                    // state of input 1 = BFD, 0 = AFD
    reg operator;                       // 1 = need new operator , 0 = no more operator needs
    
    initial begin
        sendlen = 20; counter = 0; enterkey = 1; op = 5; beforePoint = 1; operator = 1; AFDidx = 6;
        readbufferBFD   = 48'h303030303030;
        readbufferAFD   = 48'h303030303030;
        writebuffer     = {24'h0D0A2B,readbufferBFD,8'h2E,readbufferAFD,32'h203E3E20};
        state = STATE_ENTERKEY;
    end

    always @(posedge baud) begin
        if(wr_en) wr_en=0;
        if(reset) begin
            sendlen = 0; counter = 0; enterkey = 1; op = 5; beforePoint = 1; operator = 1; AFDidx = 6;
            readbufferBFD   = 48'h303030303030;
            readbufferAFD   = 48'h303030303030;
            writebuffer     = {24'h0D0A2B,readbufferBFD,8'h2E,readbufferAFD,32'h203E3E20};
            state = STATE_ENTERKEY;
        end
        case(state)
            STATE_OPERATOR:
                if(new_input) begin
                    case(data_out)
                        8'h63: op = 5; // c
                        8'h73: op = 4; // s
                        8'h2F: op = 3; // /
                        8'h2A: op = 2; // *
                        8'h2D: op = 1; // -
                        default: op = 0;
                    endcase
                    if(data_out == 13) begin enterkey = 1; inputbuffer = {readbufferBFD,readbufferAFD}; end
                    else if(data_out == 8'h08) ;
                    else begin
                        if(data_out >= 8'h30 && data_out <=8'h39) begin
                            readbufferBFD[47:8] = readbufferBFD[39:0];
                            readbufferBFD[7:0] = data_out;
                        end
                        if(data_out == 8'h2E) beforePoint = 0;
                        sendlen = 1;
                        writebuffer[159:152] = data_out;
                    end
                    operator = 0;
                    state = STATE_ENTERKEY;
                end
            STATE_BEFOREPOINT:
                if(new_input) begin
                    case(data_out)
                        13: begin enterkey = 1; inputbuffer = {readbufferBFD,readbufferAFD}; end
                        8'h2E: begin // dot
                            beforePoint             = 0;
                            writebuffer[159:152]    = data_out;
                            sendlen                 = 1;
                        end
                        default: 
                            if(data_out >= 8'h30 && data_out <=8'h39) begin // 0-9
                                readbufferBFD[47:8] = readbufferBFD[39:0];
                                readbufferBFD[7:0]  = data_out;
                                writebuffer[159:152]= data_out;
                                sendlen             = 1;
                            end
                    endcase
                    state = STATE_ENTERKEY;
                end
            STATE_AFTERPOINT:
                if(new_input) begin
                    case(data_out)
                        13: begin enterkey = 1; inputbuffer = {readbufferBFD,readbufferAFD}; end
                        default: 
                            if(data_out >= 8'h30 && data_out <=8'h39) begin
                                readbufferAFD[(AFDidx)*8 - 1 -: 8] = data_out;
                                AFDidx = AFDidx - 1;
                                writebuffer[159:152] = data_out;
                                sendlen = 1;
                            end
                    endcase
                    state = STATE_ENTERKEY;
                end
            STATE_ENTERKEY: begin
                if(enterkey) begin
                    readbufferBFD   = 48'h303030303030;
                    readbufferAFD   = 48'h303030303030;
                    enterkey        = 0;
                    calculate       = 1;
                    state = STATE_CALCULATE;
                end
                else state = STATE_SENDMORE;
            end
            STATE_CALCULATE: begin
                calculate = 0;
                if(counter < 32) counter = counter+1;
                else begin 
                    if(validOutput) writebuffer = outputbuffer;
                    else writebuffer = 160'h0D0A4E614E_2020202020_2020202020_20203E3E20;
                    sendlen = 20;
                    beforePoint = 1; operator = 1; AFDidx = 6; 
                    state = STATE_SENDMORE;
                    counter = 0;
                end
            end
            STATE_SENDMORE: begin
                if(sent & sendlen != 0) begin
                    wr_en       = 1;
                    data_in     = writebuffer[159:152];
                    writebuffer = writebuffer << 8;
                    sendlen     = sendlen - 1;
                    state       = STATE_DELAY;
                end
                else if(sendlen == 0) begin
                    if(operator)            state = STATE_OPERATOR;
                    else if(beforePoint)    state = STATE_BEFOREPOINT;
                    else                    state = STATE_AFTERPOINT;
                end
            end
            STATE_DELAY: begin
                if(counter < 20) counter = counter+1;
                else begin state = STATE_SENDMORE; counter = 0; end
            end
        endcase
        last_rec = received;
    end
endmodule