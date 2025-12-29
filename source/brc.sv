module brc(
	input  logic [31:0] i_rs1_data, i_rs2_data,
	input  logic        i_br_un,                       //1 if signed, 0 if unsigned
	output logic        o_br_less, o_br_equal);
	
	logic [31:0] xor_equal, sub_result;
	logic 		 c_out_sub, less_signed, less_unsigned;
	
	add_sub SUB (.rs1(i_rs1_data), .rs2(i_rs2_data), .c_in(1'b1), .add_sub(sub_result), .c_out(c_out_sub));
	
	// Check equal 
   assign xor_equal  = (i_rs1_data ^ i_rs2_data)	;
	assign o_br_equal = ~(|xor_equal)					;
	
	// Logic less unsigned
	assign less_unsigned = ~c_out_sub               ; // unsigned(rs1) < unsigned(rs2) => c_out_sub = 1'b0;
	
	// Logic less signed
	always_comb begin
			if (i_rs1_data[31] ^ i_rs2_data[31]) begin             //A > 0, B < 0 || A < 0, B > 0. (Tranh bi tran`)
				less_signed = i_rs1_data[31]			   ;
			end else begin
				less_signed = sub_result[31]	         ;
			end 			
	end
	
	//Check less than
	assign o_br_less = (i_br_un) ? less_signed : less_unsigned ;
	
endmodule
