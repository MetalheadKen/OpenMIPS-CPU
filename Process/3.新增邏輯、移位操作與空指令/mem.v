`include "defines.v"

/* 由於ori指令不需要存取資料記憶體，所以在存取記憶體階段不做任何事，只是簡單地將執行階段的結果向回寫階段傳遞 */
module mem(rst, wd_i, wreg_i, wdata_i, wd_o, wreg_o, wdata_o);

	input wire 							rst;				/* 重設訊號 */
	
	/* 來自執行階段的資訊 */
	input wire [`RegAddrBus]			wd_i;				/* 存取記憶體階段的指令要寫入的目的暫存器位址 */
	input wire					 		wreg_i;				/* 存取記憶體階段的指令是否有要寫入的目的暫存器 */
	input wire [`RegBus]				wdata_i;			/* 存取記憶體階段的指令要寫入目的暫存器的值*/
	
	/* 存取記憶體階段的結果 */
	output reg [`RegAddrBus]			wd_o;				/* 存取記憶體階段的指令最終要寫入的目的暫存器位址 */
	output reg 							wreg_o;				/* 存取記憶體階段的指令最終是否有要寫入的目的暫存器 */
	output reg [`RegBus]				wdata_o;			/* 存取記憶體階段的指令最終要寫入目的暫存器的值 */
	
	always @(*)
		begin
			if(rst == `RstEnable)
				begin
					wd_o		<=	`NOPRegAddr;
					wreg_o 	<=	`WriteDisable;
					wdata_o	<=	`ZeroWord;
				end
			else
				begin
					wd_o		<=	wd_i;
					wreg_o 	<=	wreg_i;
					wdata_o	<=	wdata_i;
				end
		end
		
endmodule
