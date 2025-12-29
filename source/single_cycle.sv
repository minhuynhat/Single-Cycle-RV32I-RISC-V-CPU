module single_cycle(
	input  logic        i_clk      , i_reset   ,
	input  logic [31:0] i_io_sw    ,
	output logic        o_insn_vld ,
	output logic [31:0] o_pc_debug ,
	output logic [31:0] o_io_ledr  , o_io_ledg , o_io_lcd  ,
	output logic [6:0]  o_io_hex0  , o_io_hex1 , o_io_hex2 , o_io_hex3 , 
	output logic [6:0]  o_io_hex4  , o_io_hex5 , o_io_hex6 , o_io_hex7
);

	logic [31:0] instr, wb_data, rs1_data, rs2_data, imm_data, ld_data;
	logic [31:0] pc, pc_four, pc_next;
	logic [31:0] alu_op_a, alu_op_b, alu_data;
	logic 		 RegWEn, BrUn, BrLT, BrEq, PCSel, ASel, BSel, MemRW;
	logic [2:0]	 ImmSel, LSUSel;
	logic [3:0]  ALUSel;
	logic [1:0]  WBSel;
	
	assign pc_four = pc + 32'h0000_0004						;
	assign pc_next = (PCSel == 1'b1) ? alu_data : pc_four;
	
	// MUX 2-1 PC.
	always_ff @(posedge i_clk or negedge i_reset) begin
		if (!i_reset) begin
			pc <= 32'h0000_0000 ;
		end else begin
			pc <= pc_next;
		end
	end
	
	//MUX 2-1 op_a and op_b
	assign alu_op_a = (ASel) ? pc 		: rs1_data	;
	assign alu_op_b = (BSel) ? imm_data : rs2_data	;
	
	//MUX 4-1 Write Back
	always_comb begin
		unique case (WBSel)
			2'b00: 	wb_data = ld_data			;
			2'b01: 	wb_data = alu_data		;
			2'b10: 	wb_data = pc_four			;
			default: wb_data = 32'h0000_0000	;
		endcase
	end
	
	imem mem1(
		.i_pc			(pc)				,
		.o_instr		(instr)
	);
	
	regfile mem2(
		.i_clk		(i_clk)			,
		.i_reset		(i_reset)		,
		.i_rd_wren	(RegWEn)			,
		.i_rs1_addr	(instr[19:15])	,
		.i_rs2_addr	(instr[24:20])	,
		.i_rd_addr	(instr[11:7])	,
		.i_rd_data	(wb_data)		,
		.o_rs1_data	(rs1_data)		,
		.o_rs2_data	(rs2_data)		
	);
	
	ImmGen immgen(
		.i_instr		(instr)			,
		.i_immsel	(ImmSel)			,
		.o_immdata	(imm_data)
	);
	
	brc BRC(
		.i_rs1_data	(rs1_data)		,
		.i_rs2_data	(rs2_data)		,
		.i_br_un		(BrUn)			,
		.o_br_less	(BrLT)			,
		.o_br_equal	(BrEq)
	);
	
	ALU alu(
		.i_op_a		(alu_op_a)		,
		.i_op_b		(alu_op_b)		,
		.i_alu_op	(ALUSel)			,
		.o_alu_data	(alu_data)
	);
	
	lsu mem3(
		.i_clk		(i_clk)			,
		.i_reset		(i_reset)		,
		.i_lsu_wren	(MemRW)			,
		.i_type		(LSUSel)			,
		.i_lsu_addr	(alu_data)		,
		.i_st_data	(rs2_data)		,
		.i_io_sw		(i_io_sw)		,
		.o_ld_data	(ld_data)		,
		.o_io_ledr	(o_io_ledr)		,
		.o_io_ledg	(o_io_ledg)    ,
		.o_io_lcd   (o_io_lcd)		,
		.o_io_hex0  (o_io_hex0)		,
		.o_io_hex1  (o_io_hex1)		,
		.o_io_hex2  (o_io_hex2)		,
		.o_io_hex3  (o_io_hex3)		,
		.o_io_hex4  (o_io_hex4)		,
		.o_io_hex5  (o_io_hex5)		,
		.o_io_hex6  (o_io_hex6)		,
		.o_io_hex7  (o_io_hex7)
	);
	
	controlunit CU(
		.i_instr		(instr)		,
		.i_BrEq		(BrEq)		,
		.i_BrLT		(BrLT)		,
		.o_PCSel		(PCSel)		,
		.o_RegWEn	(RegWEn)		,
		.o_BrUn		(BrUn)		,
		.o_Bsel		(BSel)		,
		.o_Asel		(ASel)		,
		.o_MemRW		(MemRW)		,
		.o_insn_vld	(o_insn_vld),
		.o_ImmSel	(ImmSel)		,
		.o_WBSel		(WBSel)		,
		.o_ALUSel	(ALUSel)		,
		.o_lsu_sel	(LSUSel)
	);
	
	always_ff @(posedge i_clk) begin
		o_pc_debug <= pc ;
	end


	
endmodule
