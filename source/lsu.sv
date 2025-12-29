module lsu(
	input  logic        i_clk      , i_reset   , i_lsu_wren ,
	input  logic [2:0]  i_type		 , 
	input  logic [31:0] i_lsu_addr , i_st_data , i_io_sw    ,
	output logic [31:0] o_ld_data  , o_io_ledr , o_io_ledg  ,
	output logic [31:0] o_io_lcd	 ,
	output logic [6:0 ] o_io_hex0	 , o_io_hex1 , o_io_hex2  ,
	output logic [6:0 ] o_io_hex3	 , o_io_hex4 , o_io_hex5  ,
	output logic [6:0 ] o_io_hex6	 , o_io_hex7  
);

	logic [31:0] ledr_buffer, ledg_buffer, swt_buffer, ram_data;
	logic [31:0] lcd_buffer, hex_low_buffer, hex_high_buffer;
	logic [3:0]  ram_mask;
	logic 		 ram_wren, ledr_wren, ledg_wren, lcd_wren;
	logic 		 hex_low_wren, hex_high_wren;
	
	localparam [2:0] 	LW  = 3'b000,
							SW  = 3'b001,
							LB  = 3'b010,
							LBU = 3'b011,
							LH  = 3'b100,
							LHU = 3'b101,
							SB  = 3'b110,
							SH  = 3'b111;
							
	assign o_io_ledr = ledr_buffer 					;
	assign o_io_ledg = ledg_buffer 					;
	assign o_io_lcd  = lcd_buffer  					;
	assign o_io_hex0 = hex_low_buffer  [6:0]		;
	assign o_io_hex1 = hex_low_buffer  [14:8]		;
	assign o_io_hex2 = hex_low_buffer  [22:16]	;
	assign o_io_hex3 = hex_low_buffer  [30:24]	;
	assign o_io_hex4 = hex_high_buffer [6:0]		;
	assign o_io_hex5 = hex_high_buffer [14:8]		;
	assign o_io_hex6 = hex_high_buffer [22:16]	;
	assign o_io_hex7 = hex_high_buffer [30:24]	;
	
//===== LOGIC WRITE =====
	always_comb begin
		unique case (i_type)
			SW: ram_mask = 4'b1111 ;
			SB: begin
				unique case (i_lsu_addr[1:0])
					2'b00:   ram_mask = 4'b0001	;
					2'b01:   ram_mask = 4'b0010	;
					2'b10:   ram_mask = 4'b0100;
					default: ram_mask = 4'b1000	;
				endcase
			end
			SH: ram_mask = (i_lsu_addr[1]) ? 4'b1100 : 4'b0011 ;
			default: ram_mask = 4'b0000;
		endcase
	end

   //Can chinh lai data
	logic [31:0] ram_wdata;
	always_comb begin
		unique case (i_type)
			SW: ram_wdata = i_st_data		;
			SB: ram_wdata = {4{i_st_data[7:0]}}	;
			SH: ram_wdata = {2{i_st_data[15:0]}}	;
			default: ram_wdata = 32'h0000_0000;
		endcase
	end
	
	//Write in RAM
	assign ram_wren = (i_lsu_wren) && (i_lsu_addr[31:11] == 21'b0); 
	
	memory RAM(
		.i_clk	(i_clk)		  ,
		.i_reset (i_reset)	  ,
		.i_wren 	(ram_wren)	  ,
		.i_bmask	(ram_mask)	  ,
		.i_wdata	(ram_wdata)   ,
		.i_addr	(i_lsu_addr)  ,
		.o_rdata	(ram_data)		
	);
	
	//Write in LEDR buffer
	assign ledr_wren = (i_lsu_wren) && (i_lsu_addr[31:12] == 20'h1000_0) ;
	
	always_ff @(posedge i_clk or negedge i_reset) begin
		if (!i_reset) begin
			ledr_buffer <= 32'h0000_0000 ;
		end else begin
			if (ledr_wren) begin
				if(ram_mask[0]) ledr_buffer[7:0]   <= ram_wdata[7:0]   ;
				if(ram_mask[1]) ledr_buffer[15:8]  <= ram_wdata[15:8]  ;
				if(ram_mask[2]) ledr_buffer[23:16] <= ram_wdata[23:16] ;
				if(ram_mask[3]) ledr_buffer[31:24] <= ram_wdata[31:24] ;
			end else begin
				ledr_buffer <= ledr_buffer ;
			end
		end
	end
	
	//Write in LEDG buffer
	assign ledg_wren = (i_lsu_wren) && (i_lsu_addr[31:12] == 20'h1000_1) ;
	
	always_ff @(posedge i_clk or negedge i_reset) begin
		if (!i_reset) begin
			ledg_buffer <= 32'h0000_0000 ;
		end else begin
			if (ledg_wren) begin
				if(ram_mask[0]) ledg_buffer[7:0]   <= ram_wdata[7:0]   ;
				if(ram_mask[1]) ledg_buffer[15:8]  <= ram_wdata[15:8]  ;
				if(ram_mask[2]) ledg_buffer[23:16] <= ram_wdata[23:16] ;
				if(ram_mask[3]) ledg_buffer[31:24] <= ram_wdata[31:24] ;
			end else begin
				ledg_buffer <= ledg_buffer ;
			end
		end
	end
	
	//Write in LCD buffer
	assign lcd_wren = (i_lsu_wren) && (i_lsu_addr[31:12] == 20'h1000_4)	;
	
	always_ff @(posedge i_clk or negedge i_reset) begin
		if (!i_reset) begin
			lcd_buffer <= 32'h0000_0000	;
		end else begin
			if (lcd_wren) begin
				if(ram_mask[0]) lcd_buffer[7:0]   <= ram_wdata[7:0]   ;
				if(ram_mask[1]) lcd_buffer[15:8]  <= ram_wdata[15:8]  ;
				if(ram_mask[2]) lcd_buffer[23:16] <= ram_wdata[23:16] ;
				if(ram_mask[3]) lcd_buffer[31:24] <= ram_wdata[31:24] ;
			end else begin
			end
		end
	end
	
	//Write in low hex buffer
	assign hex_low_wren = (i_lsu_wren) && (i_lsu_addr[31:12] == 20'h1000_2)	;
	
	always_ff @(posedge i_clk or negedge i_reset) begin
		if (!i_reset) begin
			hex_low_buffer <= 32'h0000_0000	;
		end else begin
			if (hex_low_wren) begin
				if(ram_mask[0]) hex_low_buffer[7:0]   <= ram_wdata[7:0]   ;
				if(ram_mask[1]) hex_low_buffer[15:8]  <= ram_wdata[15:8]  ;
				if(ram_mask[2]) hex_low_buffer[23:16] <= ram_wdata[23:16] ;
				if(ram_mask[3]) hex_low_buffer[31:24] <= ram_wdata[31:24] ;
			end else begin
			end
		end
	end
	
	//Write in high hex buffer
	assign hex_high_wren = (i_lsu_wren) && (i_lsu_addr[31:12] == 20'h1000_3)	;
	
	always_ff @(posedge i_clk or negedge i_reset) begin
		if (!i_reset) begin
			hex_high_buffer <= 32'h0000_0000	;
		end else begin
			if (hex_high_wren) begin
				if(ram_mask[0]) hex_high_buffer[7:0]   <= ram_wdata[7:0]   ;
				if(ram_mask[1]) hex_high_buffer[15:8]  <= ram_wdata[15:8]  ;
				if(ram_mask[2]) hex_high_buffer[23:16] <= ram_wdata[23:16] ;
				if(ram_mask[3]) hex_high_buffer[31:24] <= ram_wdata[31:24] ;
			end else begin
			end
		end
	end
	
	//Write in switches buffer
	always_ff @(posedge i_clk or negedge i_reset) begin
		if (!i_reset) swt_buffer <= 32'h0000_0000	;
		else         swt_buffer <= i_io_sw		 	;
	end 
	
// ===== Logic read =====
	logic sel_ram, sel_ledr, sel_ledg, sel_sw;
	logic sel_lcd, sel_hex_low, sel_hex_high;
	logic [31:0] rdata_word;
	logic [7:0]  rdata_byte;
	logic [15:0] rdata_half;
	
	assign sel_ram  		= (i_lsu_addr[31:11] == 21'b0)		;
	assign sel_ledr 		= (i_lsu_addr[31:12] == 20'h1000_0) ;
	assign sel_ledg 		= (i_lsu_addr[31:12] == 20'h1000_1) ;
	assign sel_sw   		= (i_lsu_addr[31:12] == 20'h1001_0) ;
	assign sel_lcd  		= (i_lsu_addr[31:12] == 20'h1000_4)	;
	assign sel_hex_low   = (i_lsu_addr[31:12] == 20'h1000_2)	;
	assign sel_hex_high  = (i_lsu_addr[31:12] == 20'h1000_3)	;
	
	always_comb begin
		unique case (1'b1)
			sel_ram:  		rdata_word = ram_data	     ;
			sel_ledr: 		rdata_word = ledr_buffer     ;
			sel_ledg: 		rdata_word = ledg_buffer     ;
			sel_sw:   		rdata_word = swt_buffer   	  ; 
			sel_lcd:  		rdata_word = lcd_buffer   	  ;
			sel_hex_low:   rdata_word = hex_low_buffer  ;
			sel_hex_high:  rdata_word = hex_high_buffer ;
			default:       rdata_word = 32'h0000_0000   ;
		endcase
	end
	
	always_comb begin
		unique case (i_lsu_addr[1:0])
			2'b00:    rdata_byte = rdata_word[7:0]   ;
			2'b01:    rdata_byte = rdata_word[15:8]  ;
			2'b10:    rdata_byte = rdata_word[23:16] ;
			default:  rdata_byte = rdata_word[31:24] ;
		endcase
	end
	
	assign  rdata_half = (i_lsu_addr[1] == 1'b1) ? rdata_word[31:16] : rdata_word[15:0];

   //Result load
   always_comb begin
		unique case (i_type)
			LW     : o_ld_data = rdata_word									;
			LB     : o_ld_data = {{24{rdata_byte[7]}}, rdata_byte}	;
			LBU    : o_ld_data = {24'h0, rdata_byte}						;
			LH     : o_ld_data = {{16{rdata_half[15]}}, rdata_half}	;
			LHU	 : o_ld_data = {16'h0, rdata_half}						;
			default: o_ld_data = 32'h0000_0000								;
		endcase
	end

endmodule
