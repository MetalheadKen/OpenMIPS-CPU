`include "defines.v"

/* 將解碼階段的結果在時脈週期的上升緣傳遞到執行階段 */
module id_ex(clk, rst, id_alusel, id_aluop, id_reg1, id_reg2, id_wd, id_wreg,
				 ex_alusel, ex_aluop, ex_reg1, ex_reg2, ex_wd, ex_wreg);

	input wire							clk;				/* 時脈訊號 */
	input wire 							rst;				/* 重設訊號 */
	
	/* 從解碼階段傳遞過來的資訊 */
	input wire [`AluOpBus]				id_aluop;			/* 解碼階段的指令要進行的運算的子類型 */
	input wire [`AluSelBus]	 			id_alusel;			/* 解碼階段的指令要進行的運算的類型 */
	input wire [`RegBus]				id_reg1;			/* 解碼階段的指令要進行的運算的來源運算元1 */
	input wire [`RegBus]				id_reg2;			/* 解碼階段的指令要進行的運算的來源運算元2 */
	input wire [`RegAddrBus] 			id_wd;				/* 解碼階段的指令要寫入的目的暫存器位址 */
	input wire							id_wreg;			/* 解碼階段的指令是否有要寫入的目的暫存器 */
	
	/* 傳送到執行階段的資訊 */
	output reg [`AluOpBus]				ex_aluop;			/* 執行階段的指令要進行的運算的子類型 */
	output reg [`AluSelBus]				ex_alusel;			/* 執行階段的指令要進行的運算的類型 */	
	output reg [`RegBus]				ex_reg1;			/* 執行階段的指令要進行的運算的來源運算元1 */
	output reg [`RegBus]				ex_reg2;			/* 執行階段的指令要進行的運算的來源運算元2 */
	output reg [`RegAddrBus] 			ex_wd;				/* 執行階段的指令要寫入的目的暫存器位址 */
	output reg 							ex_wreg;			/* 執行階段的指令是否有要寫入的目的暫存器 */
	
	always @(posedge clk)
		begin
			if(rst == `RstEnable)
				begin
					ex_aluop	<=	`EXE_NOP_OP;
					ex_alusel 	<=	`EXE_RES_NOP;
					ex_reg1		<=	`ZeroWord;
					ex_reg2		<=	`ZeroWord;
					ex_wd		<=	`NOPRegAddr;
					ex_wreg		<=	`WriteDisable;
				end
			else
				begin
					ex_aluop	<=	id_aluop;
					ex_alusel 	<=	id_alusel;
					ex_reg1		<=	id_reg1;
					ex_reg2		<=	id_reg2;
					ex_wd		<=	id_wd;
					ex_wreg		<=	id_wreg;
				end
		end
		
endmodule
