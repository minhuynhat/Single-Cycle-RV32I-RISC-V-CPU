module memory(
	input  logic        i_clk   ,  i_reset, i_wren,
	input  logic [3:0]  i_bmask ,
	input  logic [31:0] i_wdata ,
	input  logic [31:0] i_addr  ,
	output logic [31:0] o_rdata
);

	logic [31:0] RAM [0:511]; //2KiB = 2048 Bytes = 512 Words.
	
	initial begin
		$readmemh("io_test_ledr.hex", RAM);
	end
	
	//Addr aligned
	logic [8:0] addr_align		      ;
	assign addr_align = i_addr[10:2] ; //10
	
	//Write in RAM
	always_ff @(posedge i_clk) begin
	  /*if (!i_reset) begin
		for (int i = 0; i < 512; i++) begin
			RAM[i] <= 32'h0000_0000;
		end
 	  end else begin*/
		if (i_wren ) begin
			if (i_bmask[0]) RAM[addr_align][7:0]   <= i_wdata[7:0]	;
			if (i_bmask[1]) RAM[addr_align][15:8]  <= i_wdata[15:8]	;
			if (i_bmask[2]) RAM[addr_align][23:16] <= i_wdata[23:16]	;
			if (i_bmask[3]) RAM[addr_align][31:24] <= i_wdata[31:24]	;
		end
	  //end
	end
	
	//Read RAM
	assign o_rdata = RAM[addr_align]	;
	
endmodule
	
