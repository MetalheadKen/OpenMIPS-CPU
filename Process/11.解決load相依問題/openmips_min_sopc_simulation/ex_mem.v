`include "defines.v"

/* 將執行階段取得的運算結果，在下一個時脈傳遞到管線存取記憶體階段 */
module ex_mem(clk, rst, stall, ex_wd, ex_wreg, ex_wdata, ex_hi, ex_lo, ex_whilo, ex_aluop, ex_mem_addr, ex_reg2, hilo_i, cnt_i,
			  mem_wd, mem_wreg, mem_wdata, mem_hi, mem_lo, mem_whilo, mem_aluop, mem_mem_addr, mem_reg2, hilo_o, cnt_o);

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
	
	/* 用於實現載入、存取記憶體指令 */
	input wire [`AluOpBus]				ex_aluop;			/* 執行階段的指令要進行的運算的子類型 */
	input wire [`RegBus]				ex_mem_addr;		/* 執行階段的載入、儲存指令對應的記憶體位址 */
	input wire [`RegBus]				ex_reg2;			/* 執行階段的儲存指令要儲存的資料，或者lwl、lwr指令要寫入的目的暫存器的原始值 */
	
	input wire [`DoubleRegBus]			hilo_i;				/* 保存的乘法結果 */
	input wire [1:0]					cnt_i;				/* 下一個時脈週期是執行階段的第幾個時脈週期 */
		
	/* 送到存取記憶體階段的資訊 */
	output reg [`RegAddrBus]			mem_wd;				/* 存取記憶體階段的指令要寫入的目的暫存器位址 */
	output reg 							mem_wreg;			/* 存取記憶體階段的指令是否有要寫入的目的暫存器 */
	output reg [`RegBus]				mem_wdata;			/* 存取記憶體階段的指令要寫入目的暫存器的值 */
	output reg [`RegBus]				mem_hi;				/* 存取記憶體階段的指令要寫入HI暫存器的值 */
	output reg [`RegBus]				mem_lo;				/* 存取記憶體階段的指令要寫入LO暫存器的值 */
	output reg							mem_whilo;			/* 存取記憶體階段的指令是否要寫入HI、LO暫存器 */
	
	/* 用於實現載入、存取記憶體指令 */
	output reg [`AluOpBus]				mem_aluop;			/* 存取記憶體階段的指令要進行的運算的子類型 */
	output reg [`RegBus]				mem_mem_addr;		/* 存取記憶體階段的載入、儲存指令對應的記憶體位址 */
	output reg [`RegBus]				mem_reg2;			/* 存取記憶體階段的儲存指令要儲存的資料，或者lwl、lwr指令要寫入的目的暫存器的原始值 */
	
	/* 送到執行階段的資訊 */
	output reg [`DoubleRegBus]			hilo_o;				/* 保存的乘法結果 */
	output reg [1:0]					cnt_o;				/* 目前處於執行階段的第幾個時脈週期 */
	
	/* 在管線執行階段暫停的時候，將輸出訊號hilo_i透過輸出介面hilo_o送出，輸入訊號cnt_i透過輸出介面cnt_o送出。
	** 其餘時刻，hilo_o為0，cnt_o也為0 */
	always @(posedge clk)
		begin
			if(rst == `RstEnable)
				begin
					mem_wd			<=	`NOPRegAddr;
					mem_wreg 		<=	`WriteDisable;
					mem_wdata		<=	`ZeroWord;
					mem_hi			<=	`ZeroWord;
					mem_lo			<=	`ZeroWord;
					mem_whilo		<=	`WriteDisable;
					hilo_o			<=	{`ZeroWord, `ZeroWord};
					cnt_o			<=	2'b00;
					mem_aluop		<=	`EXE_NOP_OP;
					mem_mem_addr	<=	`ZeroWord;
					mem_reg2		<=	`ZeroWord;
				end
			else if(stall[3] == `Stop && stall[4] == `NoStop)
				begin
					mem_wd			<=	`NOPRegAddr;
					mem_wreg 		<=	`WriteDisable;
					mem_wdata		<=	`ZeroWord;
					mem_hi			<=	`ZeroWord;
					mem_lo			<=	`ZeroWord;
					mem_whilo		<=	`WriteDisable;
					hilo_o			<=	hilo_i;
					cnt_o			<=	cnt_i;
					mem_aluop		<=	`EXE_NOP_OP;
					mem_mem_addr	<=	`ZeroWord;
					mem_reg2		<=	`ZeroWord;
				end
			else if(stall[3] == `NoStop)
				begin
					mem_wd			<=	ex_wd;
					mem_wreg 		<=	ex_wreg;
					mem_wdata		<=	ex_wdata;
					mem_hi			<=	ex_hi;
					mem_lo			<=	ex_lo;
					mem_whilo		<=	ex_whilo;
					hilo_o			<=	{`ZeroWord, `ZeroWord};
					cnt_o			<=	2'b00;
					mem_aluop		<=	ex_aluop;
					mem_mem_addr	<=	ex_mem_addr;
					mem_reg2		<=	ex_reg2;
				end
			else
				begin
					hilo_o		<=	hilo_i;
					cnt_o		<=	cnt_i;
				end
		end
		
endmodule
