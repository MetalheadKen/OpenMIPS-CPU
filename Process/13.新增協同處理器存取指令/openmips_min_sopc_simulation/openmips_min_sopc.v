`include "defines.v"

/* 為了驗證，需要建立一個SOPC，OpenMIPS從指令記憶體中讀取指令，指令進入OpenMIPS開始執行 */
module openmips_min_sopc(clk, rst);

	input wire							clk;				/* 時脈訊號 */
	input wire 							rst;				/* 重設訊號 */
	
	/* 連接指令記憶體 */
	wire [`InstAddrBus]					inst_addr;
	wire [`InstBus] 					inst;
	wire 								rom_ce;
	wire								mem_we_i;
	wire [`RegBus]						mem_addr_i;
	wire [`RegBus]						mem_data_i;
	wire [`RegBus]						mem_data_o;
	wire [3:0]							mem_sel_i;
	wire								mem_ce_i;
	wire [5:0]							intr;
	wire								timer_int;
	
	assign intr = {5'b00000, timer_int};
	
	/* 實體化處理器OpenMIPS */
	openmips openmips0(.clk(clk), 				 .rst(rst),
	
					   /* 連接處理器OpenMIPS與指令記憶體ROM */
					   .rom_addr_o(inst_addr),   .rom_data_i(inst),
					   .rom_ce_o(rom_ce),		 .int_i(intr),
					   
					   /* 連接處理器OpenMIPS與資料記憶體RAM */
					   .ram_we_o(mem_we_i),		 .ram_addr_o(mem_addr_i),
					   .ram_sel_o(mem_sel_i),	 .ram_data_o(mem_data_i),
					   .ram_data_i(mem_data_o),  .ram_ce_o(mem_ce_i),
					   .timer_int_o(timer_int)
	);
	
	/* 實體化指令記憶體ROM */	
	inst_rom inst_rom0(.ce(rom_ce),
					   .addr(inst_addr),		 .inst(inst)
	);
	
	/* 實體化資料記憶體RAM */
	data_ram data_ram0(.clk(clk), 
					   .we(mem_we_i), 			 .addr(mem_addr_i),
					   .sel(mem_sel_i),			 .data_i(mem_data_i),
					   .data_o(mem_data_o),		 .ce(mem_ce_i)
	);
			
endmodule
