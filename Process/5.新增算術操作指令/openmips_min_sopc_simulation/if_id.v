`include "defines.v"

/* 暫時保存取指令階段取得的指令，以及對應的指令位址，並在下一個時脈傳遞到解碼階段 */
module if_id(clk, rst, if_pc, if_inst, id_pc, id_inst);

	input wire 						clk;			/* 時脈訊號 */
	input wire 						rst;			/* 重設訊號 */
	input wire [`InstAddrBus] 		if_pc;			/* 取指令階段取得的指令對應的位址 */
	input wire [`InstBus]			if_inst;		/* 取指令階段取得的指令 */
	
	output reg [`InstAddrBus] 		id_pc;			/* 解碼階段的指令對應的位址 */
	output reg [`InstBus]			id_inst;		/* 解碼階段的指令 */
	
	always @(posedge clk)
		begin
			if(rst == `RstEnable)
				begin
					id_pc 		<= `ZeroWord;		/* 重設的時候pc為0 */
					id_inst 	<= `ZeroWord;		/* 重設的時候指令也為0，實際就是空指令 */
				end
			else
				begin
					id_pc 		<= if_pc;			/* 其餘時刻向下傳遞取指令階段的值 */
					id_inst 	<= if_inst;
				end
		end

endmodule
