`include "defines.v"

/* 給出指令的位址，因一條指令為32位元，且OpenMIPS是可以按照位元組定址的，故一條指令對應4個位元組 */
module pc_reg(clk, rst, pc, ce);

	input wire 						clk;		/* 時脈訊號 */
	input wire 						rst;		/* 重設訊號 */
	output reg [`InstAddrBus] 		pc;			/* 要讀取的指令位址 */
	output reg 						ce;			/* 指令記憶體啟用訊號 */
	
	always @(posedge clk)
		begin
			if(rst == `RstEnable)
				ce <= `ChipDisable;			/* 重設的時候指令記憶體停用 */
			else
				ce <= `ChipEnable;			/* 重設結束後，指令記憶體啟用 */
		end
		
	always @(posedge clk)
		begin
			if(ce == `ChipDisable)
				pc <= 32'h00000000;			/* 指令記憶體停用的時候，pc為0 */
			else
				pc <= pc + 4'h4;			/* 指令記憶體啟用的時候，pc的值每個時脈週期加4 */
		end

endmodule
