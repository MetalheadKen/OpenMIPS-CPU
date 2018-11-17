`include "defines.v"

/* 將執行階段取得的運算結果，在下一個時脈傳遞到管線存取記憶體階段 */
module ex_mem(clk, rst, stall, ex_wd, ex_wreg, ex_wdata, ex_hi, ex_lo, ex_whilo,
			  mem_wd, mem_wreg, mem_wdata, mem_hi, mem_lo, mem_whilo);

	input wire							clk;				/* 時脈訊號 */
	input wire 							rst;				/* 重設訊號 */
	
	/* 來自控制模組的資訊 */
	input wire [5:0]					stall;				/* 管線暫停訊號 */
	
	/* 來自執行階段的資訊 */
	input wire [`RegAddrBus]			ex_wd;				/* 執行階段的指令執行後要寫入的目的暫存器位址 */
	input wire					 		ex_wreg;			/* 執行階段的指令執行後是否有要寫入的目的暫存器 */
	input wire [`RegBus]				ex_wdata;			/* 執行階段的指令執行後要寫入目的暫存器的值 */
	input wire [`RegBus]				ex_hi;				/* 執行階段的指令要寫入HI暫存器的值 */
	input wire [`RegBus]				ex_lo;				/* 執行階段的指令要寫入LO暫存器的值 */
	input wire							ex_whilo;			/* 執行階段的指令是否要寫入HI、LO暫存器 */
		
	/* 送到存取記憶體階段的資訊 */
	output reg [`RegAddrBus]			mem_wd;				/* 存取記憶體階段的指令要寫入的目的暫存器位址 */
	output reg 							mem_wreg;			/* 存取記憶體階段的指令是否有要寫入的目的暫存器 */
	output reg [`RegBus]				mem_wdata;			/* 存取記憶體階段的指令要寫入目的暫存器的值 */
	output reg [`RegBus]				mem_hi;				/* 存取記憶體階段的指令要寫入HI暫存器的值 */
	output reg [`RegBus]				mem_lo;				/* 存取記憶體階段的指令要寫入LO暫存器的值 */
	output reg							mem_whilo;			/* 存取記憶體階段的指令是否要寫入HI、LO暫存器 */
	
	/* (1)當stall[3]為Stop，stall[4]為NoStop時，表示執行階段暫停，而存取記憶體階段繼續，
	**    所以使用空指令作為下一個周期進入存取記憶體階段的指令
	** (2)當stall[3]為NoStop時，表示執行階段繼續，執行後的指令進入存取記憶體階段
	** (3)其餘情況下，保持存取記憶體階段的暫存器mem_wd、mem_wreg、mem_wdata、mem_hi、mem_lo、mem_whilo不變 */
	always @(posedge clk)
		begin
			if(rst == `RstEnable)
				begin
					mem_wd		<=	`NOPRegAddr;
					mem_wreg 	<=	`WriteDisable;
					mem_wdata	<=	`ZeroWord;
					mem_hi		<=	`ZeroWord;
					mem_lo		<=	`ZeroWord;
					mem_whilo	<=	`WriteDisable;
				end
			else if(stall[3] == `Stop && stall[4] == `NoStop)
				begin
					mem_wd		<=	`NOPRegAddr;
					mem_wreg 	<=	`WriteDisable;
					mem_wdata	<=	`ZeroWord;
					mem_hi		<=	`ZeroWord;
					mem_lo		<=	`ZeroWord;
					mem_whilo	<=	`WriteDisable;
				end
			else if(stall[3] == `NoStop)
				begin
					mem_wd		<=	ex_wd;
					mem_wreg 	<=	ex_wreg;
					mem_wdata	<=	ex_wdata;
					mem_hi		<=	ex_hi;
					mem_lo		<=	ex_lo;
					mem_whilo	<=	ex_whilo;
				end
		end
		
endmodule
