module add_sub(
	input  logic [31:0] rs1, rs2,
	input  logic		  c_in,
	output logic [31:0] add_sub,
	output logic		  c_out);
	
	logic [32:0] c_trans; 
	
	assign c_trans[0] = c_in;
	assign c_out      = c_trans[32];
	
	genvar i;
	generate 
		for (i = 0; i < 32; i++) begin: gen_add_sub_32bit
			full_adder FA (.a(rs1[i]), .b(rs2[i] ^ c_in), .c_in(c_trans[i]), .s(add_sub[i]), .c_out(c_trans[i+1]));
		end
	endgenerate
    	
endmodule
