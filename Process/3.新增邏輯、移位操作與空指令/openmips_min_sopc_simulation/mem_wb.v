`include "defines.v"

/* 將存取記憶體階段的運算結果，在下一個時脈傳遞到回寫階段 */
module mem_wb(clk, rst, mem_wd, mem_wreg, mem_wdata, wb_wd, wb_wreg, wb_wdata);

	input wire							clk;				/* 時脈訊號 */
	input wire 							rst;				/* 重設訊號 */
	
	/* 存取記憶體階段的結果 */
	input wire [`RegAddrBus]			mem_wd;				/* 存取記憶體階段的指令最終要寫入的目的暫存器位址 */
	input wire					 		mem_wreg;			/* 存取記憶體階段的指令最終是否有要寫入的目的暫存器 */
	input wire [`RegBus]				mem_wdata;			/* 存取記憶體階段的指令最終要寫入目的暫存器的值 */
	
	/* 送到回寫階段的資訊 */
	output reg [`RegAddrBus]			wb_wd;				/* 回寫階段的指令要寫入的目的暫存器位址 */
	output reg 							wb_wreg;			/* 回寫階段的指令是否有要寫入的目的暫存器 */
	output reg [`RegBus]				wb_wdata;			/* 回寫階段的指令要寫入目的暫存器的值 */
	
	always @(posedge clk)
		begin
			if(rst == `RstEnable)
				begin
					wb_wd		<=	`NOPRegAddr;
					wb_wreg 	<=	`WriteDisable;
					wb_wdata	<=	`ZeroWord;
				end
			else
				begin
					wb_wd		<=	mem_wd;
					wb_wreg 	<=	mem_wreg;
					wb_wdata	<=	mem_wdata;
				end
		end
		
endmodule
