module ImmGen(
	input  logic [31:0] i_instr,
	input  logic [2:0]  i_immsel,
	output logic [31:0] o_immdata);
	
	localparam [2:0]
		I_TYPE = 3'b000,
		S_TYPE = 3'b001,
		B_TYPE = 3'b010,
		J_TYPE = 3'b011;
	
	
	assign o_immdata[31:20] = (i_immsel[2] == 1'b1) ? i_instr[31:20] : {12{i_instr[31]}}																	;
	
	assign o_immdata[19:12] = ((i_immsel == I_TYPE) || (i_immsel == S_TYPE) ||(i_immsel == B_TYPE)) ? {8{i_instr[31]}} : i_instr[19:12] 	;
	
   assign o_immdata[11]    = (i_immsel == B_TYPE ) ? i_instr[7]  :
									  (i_immsel == J_TYPE ) ? i_instr[20] :
									  (i_immsel[2] == 1'b1) ? 1'b0		  : i_instr[31]																				;
									  
	assign o_immdata[10:5]  = (i_immsel[2] == 1'b1) ? 6'b0        : i_instr[30:25]																			;
	
	assign o_immdata[4:1]   = ((i_immsel == S_TYPE) || i_immsel == B_TYPE) ? i_instr[11:8] :
									  (i_immsel[2] == 1'b1)                        ? 4'h0          : i_instr[24:21]											;
									
	assign o_immdata[0]     = (i_immsel == I_TYPE) ? i_instr[20] :
									  (i_immsel == S_TYPE) ? i_instr[7]  : 1'b0																							;
	
endmodule
