`include "defines.v"

/* 為了驗證，需要建立一個SOPC，OpenMIPS從指令記憶體中讀取指令，指令進入OpenMIPS開始執行 */
module openmips_min_sopc(clk, rst);

	input wire							clk;				/* 時脈訊號 */
	input wire 							rst;				/* 重設訊號 */
	
	/* 連接指令記憶體 */
	wire [`InstAddrBus]					inst_addr;
	wire [`InstBus] 					inst;
	wire 								rom_ce;
	
	/* 實體化處理器OpenMIPS */
	openmips openmips0(.clk(clk), 				 .rst(rst),
					   .rom_addr_o(inst_addr),   .rom_data_i(inst),
					   .rom_ce_o(rom_ce)
	);
	
	/* 實體化指令記憶體ROM */	
	inst_rom inst_rom0(.ce(rom_ce),
					   .addr(inst_addr),		 .inst(inst)
	);
		
endmodule
