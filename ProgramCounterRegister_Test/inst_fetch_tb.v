/* 把 pc_reg.v 與 rom.v 組合起來 */
module inst_fetch_tb;
	
	reg 			CLOCK;	 /* 驅動訊號，此為時脈訊號 */
	reg 			rst;		 /* 驅動訊號，此為重設訊號 */
	wire [31:0] inst;		 /* 顯示訊號，此為取出的指令 */
	
	/* 定義CLOCK訊號，每隔10個時間單位，CLOCK的值就翻轉，由此得到一個週期訊號。
	** 在模擬的時候，一個時間單位預設是1ns，所以CLOCK的值每10ns翻轉一次，
	** 對應就是50MHZ的時脈	*/
	initial begin
		CLOCK = 1'b0;
		forever #10 CLOCK = ~CLOCK;
	end
	
	/* 定義rst訊號，最一開始為0，表示重設訊號有效，過了195個時間單位，即195ns，
	** 設定rst訊號的值為1，重設訊號為無效，重設結束，在執行1000ns，暫停模擬 */
	initial begin
		rst = 1'b0;
		#195 rst = 1'b1;
		#1000 $stop;
	end
		
	/* 待測模組的實體化 */
	inst_fetch inst_fetch0(.clk(CLOCK), .rst(rst), .inst_o(inst));
		
endmodule
