`include "defines.v"

/* 接收來自ID、EX模組傳遞過來的管線暫停請求訊號，從而控制管線各階段的執行 */
module ctrl(rst, stallreq_from_id, stallreq_from_ex, stall);

	input wire 					rst;					/* 重設訊號 */
	input wire					stallreq_from_id;		/* 處於解碼階段的指令是否請求管線暫停 */
	input wire					stallreq_from_ex;		/* 處於執行階段的指令是否請求管線暫停 */
	
	output reg [5:0]			stall;					/* 管線暫停控制訊號 */
	
	always @( * )
		begin
			if(rst == `RstEnable)
				stall <= 6'b000000;
			else if(stallreq_from_ex == `Stop)			/* 若管線執行階段的指令請求暫停時 */
				stall <= 6'b001111;						/* 要求取指令、解碼、執行階段暫停，而存取記憶體、回寫階段繼續 */
			else if(stallreq_from_id == `Stop)			/* 若管線解碼階段的指令請求暫停時 */
				stall <= 6'b000111;						/* 要求取指令、解碼階段暫停，而執行、存取記憶體、回寫階段繼續 */
			else
				stall <= 6'b000000;						/* 不暫停管線 */
		end
		
endmodule
