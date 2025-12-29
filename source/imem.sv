module imem(
	input  logic [31:0] i_pc,
	output logic [31:0] o_instr
);
	
	parameter size_rom    = 511	;
	parameter bit_aligned = 8		;   

	logic [31:0] ROM [0:size_rom]	; //2KiB = 2048 Bytes = 512 Words.
	
	initial begin
		$readmemh("io_test_ledr.hex", ROM);
	end 
	
	// Addr aligned
	logic [bit_aligned : 0] addr_align	;
	assign addr_align = i_pc[10:2]		;
	
	// Read logic
	assign o_instr = ROM[addr_align]		;
	
endmodule
