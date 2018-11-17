/* 給出取指令位址，並在每個CLOCK取指令位址遞增 */
module pc_reg(clk, rst, pc, ce);

	input wire 			clk; /* 時脈訊號 */
	input wire 			rst; /* 重設訊號 */
	output reg [5:0]	pc;  /* 要讀取的指令位址 */
	output reg			ce;  /* 指令記憶體啟用訊號 */
	
	/* 在時脈訊號上升緣觸發 */
	always @(posedge clk or negedge rst)
		begin
			/* rst觸發且有效時，指令記憶體啟用訊號則無效 */
			if(!rst)
				ce <= 1'b0;
			else
				ce <= 1'b1;
		end
		
	always @(posedge clk)
		begin
			if(ce == 1'b0)
				pc <= 6'o00;
			else
				pc <= pc + 1'b1;
		end
		
endmodule
