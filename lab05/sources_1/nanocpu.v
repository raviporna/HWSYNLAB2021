`timescale 10ns/10ns
//-------------------------------------------------------
// File name    : nanocpu.v
// Title        : nanoCPU.
// Library      : nanoLADA
// Purpose      : Computer Architecture
// Developers   : Krerk Piromsopa, Ph. D.
//              : Chulalongkorn University.

module nanocpu(
    output [31:0] p_address,
    input  [31:0] p_data,
    output [31:0] d_address,
    inout  [31:0] d_data,
    output mem_wr,
    input  clock,
    input  nreset
    );

    /////////////////////////////////////
    wire	[31:0]	instruction;
    // instruction fields
    wire	[5:0]	opcode;
    wire	[4:0]	rs, rt, rd;
    wire	[10:0]	reserved;
    wire	[15:0]	imm;
    wire	[25:0]	addr;
    assign {opcode,rs,rt,rd,reserved} = instruction;
    assign imm=instruction[15:0];
    assign addr=instruction[25:0];
    
    /////////////////////////////////////
    reg	    [31:0]	pc;
    wire	sel_addpc, sel_pc, pc_cout;
    wire 	[29:0] 	pc_add, pc_add_b, addr_zeroext, pc_new;
    assign p_address=pc;
    assign instruction=p_data;
    assign addr_zeroext={{4{1'b0}},addr};
    
    adder	#(.WIDTH(30)) PCADDER(pc_add,pc_cout,pc[31:2],pc_add_b,1'b1);
    mux2_1	#(.WIDTH(30)) MUXADDPC(pc_add_b,{30{1'b0}},imm_ext[29:0],sel_addpc);
    mux2_1	#(.WIDTH(30)) MUXSELPC(pc_new,pc_add,addr_zeroext,sel_pc);
    
    // PC register
    always @(posedge clock) begin
        if (nreset==0) pc=0;
        else begin pc={pc_new,2'b00}; end
    end
    
    wire	[31:0]	imm_ext;
    wire	[1:0]	ext_ops;
    extender EXTENDER(imm_ext, imm, ext_ops);
    
    wire	reg_wr, sel_wr, sel_data, sel_b, z_new, c_new;
    wire	[2:0]	alu_ops;
    
    wire	[31:0]	A, B, data_selected, data_S, data_M, B_selected;
    wire	[4:0]	rw;
    
    assign d_address=data_S;
    assign data_M=d_data;
    assign d_data=(mem_wr==1)?B:32'bz;
    
    mux2_1		#(.WIDTH(5)) MUXRW(rw,rd,rt,sel_wr);
    regfile		REGFILE(A, B, data_selected, rs, rt, rw, ~reg_wr, clock);
    mux2_1		MUXDATA(data_selected,data_S,data_M,sel_data);
    mux2_1		MUXB(B_selected,B,imm_ext,sel_b);
    alu		    ALU(data_S,z_new,c_new,A,B_selected,c_flag,alu_ops);
    
    /////////////////////////////////////
    // control unit
    control	CONTROLUNIT(sel_pc, sel_addpc, sel_wr, sel_b, sel_data,
        reg_wr, mem_wr, ext_ops, alu_ops,
        opcode, reserved[2:0], z_new
        );
    
    /////////////////////////////////////
    // flag
    reg		z_flag, c_flag;
    always @(posedge clock) begin
        if (nreset==0) begin z_flag=0; c_flag=0; end
        else begin z_flag=z_new; c_flag=c_new; end
    end

endmodule