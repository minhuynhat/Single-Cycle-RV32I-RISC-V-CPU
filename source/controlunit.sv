module controlunit(
	input  logic [31:0] i_instr,
	input  logic i_BrEq, i_BrLT,
	output logic o_PCSel,o_RegWEn, o_BrUn, o_Bsel, o_Asel, o_MemRW, o_insn_vld,
	output logic [2:0] o_ImmSel,
	output logic [1:0] o_WBSel,
	output logic [3:0] o_ALUSel,
	output logic [2:0] o_lsu_sel);
	
	localparam [3:0]
		ALU_ADD  = 4'b0_000,
		ALU_SUB  = 4'b1_000,
		ALU_SLT  = 4'b0_001,
		ALU_SLTU = 4'b0_010,
		ALU_XOR  = 4'b0_011,
		ALU_OR   = 4'b0_100,
		ALU_AND  = 4'b0_101,
		ALU_SLL  = 4'b0_110,
		ALU_SRL  = 4'b0_111,
		ALU_SRA  = 4'b1_101,
		ALU_LUI  = 4'b1_110;
		
	logic [6:0] opcode, funct7 	   ;
	logic [2:0] funct3          		;
	
	assign opcode = i_instr[6:0]		;
	assign funct3 = i_instr[14:12]	;
	assign funct7 = i_instr[31:25]	;
	
	always_comb begin
		unique case (opcode)
			7'b0110_011: 
			begin //R-Format
				o_PCSel   = 1'b0			;
				o_ImmSel  = 3'b000		;
				o_RegWEn  = 1'b1			;
				o_BrUn    = 1'b0			;
			   o_Asel    = 1'b0			;
				o_Bsel    = 1'b0			;
				o_MemRW   = 1'b0			;
				o_WBSel   = 2'b01			;
				o_lsu_sel = 3'b000		;
				
				if (funct7 == 7'b0000_000) begin
					unique case (funct3)
						3'b000:  {o_ALUSel, o_insn_vld} = {ALU_ADD , 1'b1};
						3'b001:  {o_ALUSel, o_insn_vld} = {ALU_SLL , 1'b1};
						3'b010:  {o_ALUSel, o_insn_vld} = {ALU_SLT , 1'b1};
						3'b011:  {o_ALUSel, o_insn_vld} = {ALU_SLTU, 1'b1};
						3'b100:  {o_ALUSel, o_insn_vld} = {ALU_XOR , 1'b1};
						3'b101:  {o_ALUSel, o_insn_vld} = {ALU_SRL , 1'b1};
						3'b110:  {o_ALUSel, o_insn_vld} = {ALU_OR  , 1'b1};
						default: {o_ALUSel, o_insn_vld} = {ALU_AND , 1'b1};
					endcase
				end else if (funct7 == 7'b0100_000) begin
					unique case (funct3)
						3'b000:  {o_ALUSel, o_insn_vld} = {ALU_SUB, 1'b1};
						3'b101:  {o_ALUSel, o_insn_vld} = {ALU_SRA, 1'b1};
						default: begin
									 o_RegWEn              = 1'b0           ;
					            {o_ALUSel, o_insn_vld} = {4'hF, 1'b0}   ;
						end
					endcase
				end else begin
					 o_RegWEn               = 1'b0         ;
					{o_ALUSel, o_insn_vld} = {4'hF, 1'b0}  ;
				end
			end
			
			7'b0010_011: //I - Format
			begin
				o_PCSel   = 1'b0		;
				o_ImmSel  = 3'b000	;
				o_RegWEn  = 1'b1		;
				o_BrUn    = 1'b0		;
			   o_Asel    = 1'b0		;
				o_Bsel    = 1'b1		;
				o_MemRW   = 1'b0		;
				o_WBSel   = 2'b01		;
				o_lsu_sel = 3'b000	;
				
				if (funct7 == 7'b0000_000) begin
					unique case (funct3)
						3'b000 : {o_ALUSel, o_insn_vld} = {ALU_ADD , 1'b1};
						3'b001 : {o_ALUSel, o_insn_vld} = {ALU_SLL , 1'b1};
						3'b010 : {o_ALUSel, o_insn_vld} = {ALU_SLT , 1'b1};
						3'b011 : {o_ALUSel, o_insn_vld} = {ALU_SLTU, 1'b1};
						3'b100 : {o_ALUSel, o_insn_vld} = {ALU_XOR , 1'b1};
						3'b101 : {o_ALUSel, o_insn_vld} = {ALU_SRL , 1'b1};
						3'b110 : {o_ALUSel, o_insn_vld} = {ALU_OR  , 1'b1};
						default: {o_ALUSel, o_insn_vld} = {ALU_AND , 1'b1};
					endcase
				end else if (funct7 == 7'b0100_000) begin
					unique case (funct3)
						3'b000 : {o_ALUSel, o_insn_vld} = {ALU_ADD , 1'b1};
						3'b010 : {o_ALUSel, o_insn_vld} = {ALU_SLT , 1'b1};
						3'b011 : {o_ALUSel, o_insn_vld} = {ALU_SLTU, 1'b1};
						3'b100 : {o_ALUSel, o_insn_vld} = {ALU_XOR , 1'b1};
						3'b101 : {o_ALUSel, o_insn_vld} = {ALU_SRA , 1'b1};
						3'b110 : {o_ALUSel, o_insn_vld} = {ALU_OR  , 1'b1};
						3'b111 : {o_ALUSel, o_insn_vld} = {ALU_AND , 1'b1};
						default: begin  //3'b001
									 o_RegWEn               = 1'b0           ;
								   {o_ALUSel, o_insn_vld} = {4'hF, 1'b0}    ;
						end
					endcase
				end else begin
					unique case (funct3)
						3'b000 : {o_ALUSel, o_insn_vld} = {ALU_ADD , 1'b1};
						3'b010 : {o_ALUSel, o_insn_vld} = {ALU_SLT , 1'b1};
						3'b011 : {o_ALUSel, o_insn_vld} = {ALU_SLTU, 1'b1};
						3'b100 : {o_ALUSel, o_insn_vld} = {ALU_XOR , 1'b1};
						3'b110 : {o_ALUSel, o_insn_vld} = {ALU_OR  , 1'b1};
						3'b111 : {o_ALUSel, o_insn_vld} = {ALU_AND , 1'b1};
						default: begin  //3'b001, 3'b101
									 o_RegWEn               = 1'b0           ;
								   {o_ALUSel, o_insn_vld} = {4'hF, 1'b0}    ;
						end
					endcase
				end
			end
			
			7'b0000_011: //Load Type
			begin
				o_PCSel   = 1'b0		;
				o_ImmSel  = 3'b000	;
				o_RegWEn  = 1'b1		;
				o_BrUn    = 1'b0		;
			   o_Asel    = 1'b0		;
				o_Bsel    = 1'b1		;
				o_MemRW   = 1'b0		;
				o_WBSel   = 2'b00		;
				o_ALUSel  = ALU_ADD	;
				
				unique case (funct3)
					3'b000: {o_lsu_sel, o_insn_vld} = {3'b010, 1'b1}	; //LB
					3'b001: {o_lsu_sel, o_insn_vld} = {3'b100, 1'b1}	; //LH
					3'b010: {o_lsu_sel, o_insn_vld} = {3'b000, 1'b1}	; //LW
					3'b100: {o_lsu_sel, o_insn_vld} = {3'b011, 1'b1}	; //LBU
					3'b101: {o_lsu_sel, o_insn_vld} = {3'b101, 1'b1}	; //LHU
					default: begin
							  {o_lsu_sel, o_insn_vld} = {3'b000, 1'b0}	; 
							  o_RegWEn					  = 1'b0					;
					end
				endcase
			end
			
			7'b0100_011: // Store - Type
			begin
				o_PCSel   = 1'b0		;
				o_ImmSel  = 3'b001	; 
				o_RegWEn  = 1'b0		;
				o_BrUn    = 1'b0		;
			   o_Asel    = 1'b0		;
				o_Bsel    = 1'b1		;
				o_MemRW   = 1'b1		;
				o_WBSel   = 2'b00		;
				o_ALUSel  = ALU_ADD	;

				unique case (funct3)
					3'b000: {o_lsu_sel, o_insn_vld} = {3'b110, 1'b1}	; //SB
					3'b001: {o_lsu_sel, o_insn_vld} = {3'b111, 1'b1}	; //SH
					3'b010: {o_lsu_sel, o_insn_vld} = {3'b001, 1'b1}	; //SW
					default: begin
							  {o_lsu_sel, o_insn_vld} = {3'b001, 1'b0}	; 
							   o_MemRW                = 1'b0             ;
					end
				endcase
			end
	
			7'b1100_011: // Branch - Type 
			begin
				o_ImmSel  = 3'b010	; 
				o_RegWEn  = 1'b0		;
			   o_Asel    = 1'b1		;
				o_Bsel    = 1'b1		;
				o_MemRW   = 1'b0		;
				o_WBSel   = 2'b00		;
				o_ALUSel  = ALU_ADD	;
				o_lsu_sel = 3'b000	;
				
				unique case (funct3)
					3'b000: begin //BEQ
						o_BrUn 	  			  = 1'b1		;
						o_insn_vld          = 1'b1		;
						if (i_BrEq) o_PCSel = 1'b1		;
						else 			o_PCSel = 1'b0		;
					end
					3'b001: begin //BNE
						o_BrUn 	  			   = 1'b1	;
						o_insn_vld           = 1'b1	;
						if (!i_BrEq) o_PCSel = 1'b1	;
						else 			 o_PCSel = 1'b0	;
					end
					3'b100: begin //BLT
						o_BrUn 	  			   = 1'b1	;
						o_insn_vld           = 1'b1	;
						if (i_BrLT)  o_PCSel = 1'b1	;
						else 			 o_PCSel = 1'b0	;
					end
					3'b101: begin //BGE
						o_BrUn 	  			   = 1'b1	;
						o_insn_vld           = 1'b1	;
						if (!i_BrLT) o_PCSel = 1'b1	;
						else 			 o_PCSel = 1'b0	;
					end
					3'b110: begin //BLTU
						o_BrUn 	  			   = 1'b0	;
						o_insn_vld           = 1'b1	;
						if (i_BrLT)  o_PCSel = 1'b1	;
						else 			 o_PCSel = 1'b0	;
					end
					3'b111: begin //BGEU
						o_BrUn 	  			   = 1'b0	;
						o_insn_vld           = 1'b1	;
						if (!i_BrLT) o_PCSel = 1'b1	;
						else 			 o_PCSel = 1'b0	;
					end
					default: begin
						o_insn_vld 				= 1'b0	;
						o_BrUn					= 1'b0	;
						o_PCSel					= 1'b0	;
					end
				endcase
			end
			
			7'b1101_111: //JAL 
			begin
				o_insn_vld = 1'b1    ; 
				o_PCSel    = 1'b1		;
				o_ImmSel   = 3'b011	; 
				o_RegWEn   = 1'b1		;
				o_BrUn     = 1'b0		;
			   o_Asel     = 1'b1		;
				o_Bsel     = 1'b1		;
				o_MemRW    = 1'b0		;
				o_lsu_sel  = 3'b000  ; 
				o_WBSel    = 2'b10	;
				o_ALUSel   = ALU_ADD	;
			end
			
			7'b1100_111: //JALR
			begin
				o_ImmSel   = 3'b000	  ;  
				o_BrUn     = 1'b0		  ;
			   o_Asel     = 1'b0		  ;
				o_Bsel     = 1'b1		  ;
				o_MemRW    = 1'b0		  ;
				o_lsu_sel  = 3'b000    ; 
				o_WBSel    = 2'b10	  ;
				o_ALUSel   = ALU_ADD	  ;

				if (funct3 == 3'b000) begin
					o_insn_vld = 1'b1   ; 
					o_PCSel    = 1'b1	  ;
					o_RegWEn   = 1'b1	  ;
				end else begin
					o_insn_vld = 1'b0   ;  
					o_PCSel    = 1'b0	  ;
					o_RegWEn   = 1'b0	  ;
				end
			end
			
			7'b0110_111: //LUI
			begin
				o_insn_vld    = 1'b1   ;
				o_PCSel       = 1'b0   ;
				o_ImmSel      = 3'b111 ;
				o_RegWEn		  = 1'b1   ;
				o_BrUn        = 1'b0	  ;
			   o_Asel        = 1'b0	  ;
				o_Bsel        = 1'b1	  ;
            o_ALUSel      = ALU_LUI;	
				o_MemRW       = 1'b0	  ;
				o_lsu_sel     = 3'b000 ; 
				o_WBSel       = 2'b01  ;
			end
			
			7'b0010_111: //AUIPC
			begin
				o_insn_vld    = 1'b1   ;
				o_PCSel       = 1'b0   ;
				o_ImmSel      = 3'b111 ;
				o_RegWEn		  = 1'b1   ;
				o_BrUn        = 1'b0	  ;
			   o_Asel        = 1'b1	  ;
				o_Bsel        = 1'b1	  ;
            o_ALUSel      = ALU_ADD;	
				o_MemRW       = 1'b0	  ;
				o_lsu_sel     = 3'b000 ; 
				o_WBSel       = 2'b01  ;				
			end
			
			default: begin //Invalid instruction
				o_insn_vld    = 1'b0   ;
				o_PCSel       = 1'b0   ; //PC = PC + 4
				o_ImmSel      = 3'b111 ;
				o_RegWEn		  = 1'b0   ;
				o_BrUn        = 1'b0	  ;
			   o_Asel        = 1'b0	  ;
				o_Bsel        = 1'b1	  ;
            o_ALUSel      = ALU_ADD;	
				o_MemRW       = 1'b0	  ;
				o_lsu_sel     = 3'b000 ; 
				o_WBSel       = 2'b01  ;
			end
			
		endcase
	end
	
	
endmodule
