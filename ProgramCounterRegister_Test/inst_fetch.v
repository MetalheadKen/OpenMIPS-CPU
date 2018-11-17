/* 把 pc_reg.v 與 rom.v 組合起來 */
module inst_fetch(clk, rst, inst_o);

	input wire 			clk; 	 	/* 時脈訊號 */
	input wire 			rst;  	/* 重設訊號 */
	output wire [31:0]	inst_o;  /* 讀出的指令 */
	
	wire [5:0] pc;	 /* 內部接線 */
	wire rom_ce;	 /* 內部接線 */
	
	/* PC模組的實體化 */
	pc_reg pc_reg0(.clk(clk), .rst(rst), .pc(pc), .ce(rom_ce));
	
	/* 指令記憶體ROM的實體化 */
	rom rom0(.ce(rom_ce), .addr(pc), .inst(inst_o));
		
endmodule
