`include "defines.v"

/* 將管線模組實體化、連接 */
module openmips(clk, rst, rom_data_i, rom_addr_o, rom_ce_o);

	input wire							clk;				/* 時脈訊號 */
	input wire 							rst;				/* 重設訊號 */
	input wire 	[`RegBus]				rom_data_i;			/* 從指令記憶體取得的指令 */
	
	output wire	[`RegBus]				rom_addr_o;			/* 輸出到指令記憶體的位址 */
	output wire							rom_ce_o;			/* 指令記憶體啟用訊號 */
	
	/* 連接IF/ID模組與解碼階段ID模組的變數 */
	wire [`InstAddrBus] 	pc;
	wire [`InstAddrBus] 	id_pc_i;
	wire [`InstBus]	  		id_inst_i;
	
	/* 連接解碼階段ID模組輸出與ID/EX模組的輸入的變數 */
	wire [`AluOpBus]	  	id_aluop_o;
	wire [`AluSelBus]	  	id_alusel_o;
	wire [`RegBus]		  	id_reg1_o;
	wire [`RegBus]		  	id_reg2_o;
	wire					id_wreg_o;
	wire [`RegAddrBus] 		id_wd_o;
	
	/* 連接ID/EX模組輸出與執行階段EX模組的輸入的變數 */
	wire [`AluOpBus]	  	ex_aluop_i;
	wire [`AluSelBus]	  	ex_alusel_i;
	wire [`RegBus]		  	ex_reg1_i;
	wire [`RegBus]		  	ex_reg2_i;
	wire					ex_wreg_i;
	wire [`RegAddrBus]  	ex_wd_i;
	
	/* 連接執行階段EX模組的輸出與EX/MEM模組的輸入的變數 */
	wire					ex_wreg_o;
	wire [`RegAddrBus]  	ex_wd_o;
	wire [`RegBus]		  	ex_wdata_o;
	wire [`RegBus]			ex_hi_o;
	wire [`RegBus]			ex_lo_o;
	wire					ex_whilo_o;
	
	/* 連接EX/MEM模組的輸出與存取記憶體階段MEM模組的輸入的變數 */
	wire					mem_wreg_i;
	wire [`RegAddrBus] 		mem_wd_i;
	wire [`RegBus]		  	mem_wdata_i;
	wire [`RegBus]			mem_hi_i;
	wire [`RegBus]			mem_lo_i;
	wire					mem_whilo_i;
	
	/* 連接存取記憶體階段MEM模組的輸出與MEM/WB模組的輸入的變數 */
	wire					mem_wreg_o;
	wire [`RegAddrBus]  	mem_wd_o;
	wire [`RegBus]		  	mem_wdata_o;
	wire [`RegBus]			mem_hi_o;
	wire [`RegBus]			mem_lo_o;
	wire					mem_whilo_o;
	
	/* 連接MEM/WB模組的輸出與回寫階段的輸入 */
	wire					wb_wreg_i;
	wire [`RegAddrBus]  	wb_wd_i;
	wire [`RegBus]		  	wb_wdata_i;
	wire [`RegBus]			wb_hi_i;
	wire [`RegBus]			wb_lo_i;
	wire					wb_whilo_i;
	
	/* 連接解碼階段ID模組與通用暫存器Regfile模組的變數 */
	wire					reg1_read;
	wire					reg2_read;
	wire [`RegBus]		  	reg1_data;
	wire [`RegBus]		  	reg2_data;
	wire [`RegAddrBus]  	reg1_addr;
	wire [`RegAddrBus]  	reg2_addr;
	
	/* 連接執行階段與HILO模組的輸出，讀取HI、LO暫存器 */
	wire [`RegBus]			hi;
	wire [`RegBus]			lo;
	
	/* pc_reg實體化 */
	pc_reg pc_reg0(.clk(clk), .rst(rst), .pc(pc), .ce(rom_ce_o));
	
	assign rom_addr_o = pc; /* 指令記憶體的輸入位址就是pc的值 */
	
	/* IF/ID模組實體化 */
	if_id if_id0(.clk(clk), .rst(rst), .if_pc(pc), .if_inst(rom_data_i), .id_pc(id_pc_i), .id_inst(id_inst_i));
	
	/* 解碼階段ID模組實體化 */
	id id0(.rst(rst), .pc_i(id_pc_i), .inst_i(id_inst_i),
		   /* 來自Regfile模組的輸入 */
		   .reg1_data_i(reg1_data),   .reg2_data_i(reg2_data),
		   /* 處於執行階段的指令要寫入目的暫存器資訊 */
		   .ex_wreg_i(ex_wreg_o),	  .ex_wdata_i(ex_wdata_o),    .ex_wd_i(ex_wd_o),
		   /* 處於存取記憶體階段的指令要寫入目的暫存器資訊 */
		   .mem_wreg_i(mem_wreg_o),	  .mem_wdata_i(mem_wdata_o),  .mem_wd_i(mem_wd_o),
		   /* 送到Regfile模組的資訊 */
		   .reg1_read_o(reg1_read),   .reg2_read_o(reg2_read),
		   .reg1_addr_o(reg1_addr),   .reg2_addr_o(reg2_addr),
		   /* 送到ID/EX模組的資訊 */
		   .aluop_o(id_aluop_o), 	  .alusel_o(id_alusel_o),
		   .reg1_o(id_reg1_o), 	  	  .reg2_o(id_reg2_o), 
		   .wd_o(id_wd_o), 			  .wreg_o(id_wreg_o)
	);
	
	/* 通用暫存器Regfile模組實體化 */
	regfile regfile1(.clk(clk), 	  .rst(rst),
					 .we(wb_wreg_i),  .waddr(wb_wd_i),    .wdata(wb_wdata_i),
					 .re1(reg1_read), .raddr1(reg1_addr), .rdata1(reg1_data),
					 .re2(reg2_read), .raddr2(reg2_addr), .rdata2(reg2_data)
	);
						  
	/* ID/EX模組實體化 */
	id_ex id_ex0(.clk(clk), 			.rst(rst),
				 /* 從解碼階段ID模組傳遞過來的資訊 */
				 .id_aluop(id_aluop_o), .id_alusel(id_alusel_o),
				 .id_reg1(id_reg1_o), 	.id_reg2(id_reg2_o),
				 .id_wd(id_wd_o), 		.id_wreg(id_wreg_o),
				 /* 傳遞到執行階段EX模組的資訊 */
				 .ex_aluop(ex_aluop_i), .ex_alusel(ex_alusel_i),
				 .ex_reg1(ex_reg1_i), 	.ex_reg2(ex_reg2_i),
				 .ex_wd(ex_wd_i), 		.ex_wreg(ex_wreg_i)
	);
	
	/* EX模組的實體化 */
	ex ex0(.rst(rst),
		   /* 從ID/EX模組傳遞過來的資訊 */
		   .aluop_i(ex_aluop_i), .alusel_i(ex_alusel_i),
		   .reg1_i(ex_reg1_i),   .reg2_i(ex_reg2_i),
		   .wd_i(ex_wd_i), 		 .wreg_i(ex_wreg_i),
		   
		   .hi_i(hi), 			 .lo_i(lo),
		   /* 從MEM/WB模組傳遞過來的資訊 */
		   .wb_hi_i(wb_hi_i),  	 .wb_lo_i(wb_lo_i),	  .wb_whilo_i(wb_whilo_i),
		   /* 從MEM模組傳遞過來的資訊 */
		   .mem_hi_i(mem_hi_o),	 .mem_lo_i(mem_lo_o), .mem_whilo_i(mem_whilo_o),
		   /* 輸出到EX/MEM模組的資訊 */
		   .wd_o(ex_wd_o), 		 .wreg_o(ex_wreg_o),  .wdata_o(ex_wdata_o),
		   .hi_o(ex_hi_o),		 .lo_o(ex_lo_o),	  .whilo_o(ex_whilo_o)
	);
	
	/* EX/MEM模組實體化 */
	ex_mem ex_mem0(.clk(clk), 		   .rst(rst),
				   /* 來自執行序階段EX模組的資訊 */
				   .ex_wd(ex_wd_o),    .ex_wreg(ex_wreg_o),   .ex_wdata(ex_wdata_o),
				   .ex_hi(ex_hi_o),    .ex_lo(ex_lo_o),		  .ex_whilo(ex_whilo_o),
				   /* 送到存取記憶體階段MEM模組的資訊 */
				   .mem_wd(mem_wd_i),  .mem_wreg(mem_wreg_i), .mem_wdata(mem_wdata_i),
				   .mem_hi(mem_hi_i),  .mem_lo(mem_lo_i),	  .mem_whilo(mem_whilo_i)
	);
	
	/* MEM模組實體化 */
	mem mem0(.rst(rst),
			 /* 來自EX/MEM模組的資訊 */
			 .wd_i(mem_wd_i), .wreg_i(mem_wreg_i), .wdata_i(mem_wdata_i),
			 .hi_i(mem_hi_i), .lo_i(mem_lo_i),	   .whilo_i(mem_whilo_i),
			 /* 送到MEM/WB模組的資訊 */
			 .wd_o(mem_wd_o), .wreg_o(mem_wreg_o), .wdata_o(mem_wdata_o),
			 /* 送到EX和MEM/WB模組的資訊 */
			 .hi_o(mem_hi_o), .lo_o(mem_lo_o),	   .whilo_o(mem_whilo_o)
	);
	
	/* MEM/WB模組實體化 */
	mem_wb mem_wb0(.clk(clk), .rst(rst),
				   /* 來自存取記憶體階段MEM模組的資訊 */
				   .mem_wd(mem_wd_o), .mem_wreg(mem_wreg_o), .mem_wdata(mem_wdata_o),
				   .mem_hi(mem_hi_o), .mem_lo(mem_lo_o),	 .mem_whilo(mem_whilo_o),
				   /* 送到回寫階段的資訊 */
				   .wb_wd(wb_wd_i),   .wb_wreg(wb_wreg_i), 	 .wb_wdata(wb_wdata_i),
				   /* 送到HI/LO暫存器模組和回寫階段的資訊 */
				   .wb_hi(wb_hi_i),	  .wb_lo(wb_lo_i),		 .wb_whilo(wb_whilo_i)
	);
	
	/* HI、LO暫存器模組實體化 */
	hilo_reg hilo_reg0(.clk(clk), 		.rst(rst),
					   /* 寫入連接埠 */
					   .we(wb_whilo_i), .hi_i(wb_hi_i), 	 .lo_i(wb_lo_i),
					   /* 讀取連接埠1 */
					   .hi_o(hi), 		.lo_o(lo)
	);
			
endmodule
