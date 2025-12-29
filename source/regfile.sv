module regfile(
	input  logic        i_clk,      i_reset,    i_rd_wren,
	input  logic [4:0]  i_rs1_addr, i_rs2_addr, i_rd_addr,
	input  logic [31:0] i_rd_data,
	output logic [31:0] o_rs1_data, o_rs2_data);
	
	logic [31:0] regs [0:31];
	
	// Write logic
	always_ff @(posedge i_clk or negedge i_reset) begin
		if (!i_reset) begin
			for (int i = 0; i < 32; i++) begin
				regs[i] <= 32'h0000_0000;
			end
		end else begin
			if ((i_rd_wren == 1'b1) && (i_rd_addr != 5'h0)) begin 
					regs[i_rd_addr] <= i_rd_data			;
			end else begin          
					regs[i_rd_addr] <= regs[i_rd_addr]	;
			end
		end 
	end
	
	// Read logic
	assign o_rs1_data = (i_rs1_addr == 5'b0_0000) ? 32'h0000_0000 : regs[i_rs1_addr];
	assign o_rs2_data = (i_rs2_addr == 5'b0_0000) ? 32'h0000_0000 : regs[i_rs2_addr];
	
endmodule
