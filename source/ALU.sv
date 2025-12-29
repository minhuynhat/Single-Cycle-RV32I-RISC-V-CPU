module ALU(
	input  logic [31:0] i_op_a, i_op_b,
	input  logic [3:0]  i_alu_op,
	output logic [31:0] o_alu_data);
	
	logic [31:0] add_result, sub_result, slt_result;
	logic c_out_sub, c_out_add;
	
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
	
	add_sub ADD (.rs1(i_op_a), .rs2(i_op_b), .c_in(1'b0), .add_sub(add_result), .c_out(c_out_add));
	add_sub SUB (.rs1(i_op_a), .rs2(i_op_b), .c_in(1'b1), .add_sub(sub_result), .c_out(c_out_sub));
	
	// Logic SLT
	always_comb begin
			if (i_op_a[31] ^ i_op_b[31]) begin             //A > 0, B < 0 || A < 0, B > 0. (Tranh bi tran`)
				slt_result = {31'b0, i_op_a[31]}			;
			end else begin
				slt_result = {31'b0, sub_result[31]}	;
			end 			
	end
	
	// Logic SLL
	logic [31:0] sll_result, tmp0, tmp1, tmp2, tmp3                      ;
	
	assign tmp0       = (i_op_b[0]) ? {i_op_a[30:0], 1'b0    } : i_op_a	;
	assign tmp1       = (i_op_b[1]) ? {tmp0  [29:0], 2'b00   } : tmp0  	;
	assign tmp2       = (i_op_b[2]) ? {tmp1  [27:0], 4'h0    } : tmp1		;
	assign tmp3 	   = (i_op_b[3]) ? {tmp2  [23:0], 8'h00   } : tmp2		;
	assign sll_result = (i_op_b[4]) ? {tmp3  [15:0], 16'h0000} : tmp3		;
	
	// Logic SRL
	logic [31:0] srl_result, tmp5, tmp6, tmp7, tmp8                      ;
	
	assign tmp5       = (i_op_b[0]) ? {1'b0     ,i_op_a[31:1]}  : i_op_a	   ;
	assign tmp6       = (i_op_b[1]) ? {2'b00    ,tmp5  [31:2]}  : tmp5  	   ;
	assign tmp7       = (i_op_b[2]) ? {4'h0     ,tmp6  [31:4]}  : tmp6		;
	assign tmp8 	   = (i_op_b[3]) ? {8'h00    ,tmp7  [31:8]}  : tmp7		;
	assign srl_result = (i_op_b[4]) ? {16'h0000 ,tmp8  [31:16]} : tmp8		;
	
	// Logic SRA
	logic [31:0] sra_result, tmp9, tmp10, tmp11, tmp12                               ;
	
	assign tmp9       = (i_op_b[0]) ? {{1 {i_op_a[31]}}   ,i_op_a[31:1]}  : i_op_a	;
	assign tmp10      = (i_op_b[1]) ? {{2 {tmp9  [31]}}   ,tmp9  [31:2]}  : tmp9  	;
	assign tmp11      = (i_op_b[2]) ? {{4 {tmp10 [31]}}   ,tmp10 [31:4]}  : tmp10	   ;
	assign tmp12 	   = (i_op_b[3]) ? {{8 {tmp11 [31]}}   ,tmp11 [31:8]}  : tmp11		;
	assign sra_result = (i_op_b[4]) ? {{16{tmp12 [31]}}   ,tmp12 [31:16]} : tmp12		;
	
	
	always_comb begin
		case(i_alu_op)
			ALU_ADD:  o_alu_data = add_result               ;
			ALU_SUB:  o_alu_data = sub_result               ; 
			ALU_SLTU: o_alu_data = {31'b0, ~c_out_sub}      ; //unsigned(A) < unsigned(B) => c_out_sub = 1'b0
			ALU_SLT:	 o_alu_data = slt_result					;
			ALU_XOR:  o_alu_data = i_op_a ^ i_op_b          ;
			ALU_OR :  o_alu_data = i_op_a | i_op_b          ;
			ALU_AND:  o_alu_data = i_op_a & i_op_b          ;
			ALU_SLL:  o_alu_data = sll_result					;
			ALU_SRL:  o_alu_data = srl_result					;
			ALU_SRA:  o_alu_data = sra_result					;
			ALU_LUI:  o_alu_data = 32'h0000_0000 | i_op_b   ; 
			default:	 o_alu_data = 32'h0000_0000				;
		endcase
	end
		
endmodule
