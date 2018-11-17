`include "defines.v"

/* 時間單位是1ns，精度是1ps */
`timescale 1ns/1ps

/* 建立Test Bench檔案 */
module openmips_min_sopc_tb();
	
	reg 			CLOCK_50;		 /* 驅動訊號，此為時脈訊號 */
	reg 			rst;			 /* 驅動訊號，此為重設訊號 */
	
	/* 每隔10ns，CLOCK_50的值就翻轉一次，所以一個週期是20ns，對應50MHZ */
	initial begin
		CLOCK_50 = 1'b0;
		forever #10 CLOCK_50 = ~CLOCK_50;
	end
	
	/* 最初時刻，重設訊號有效，在第195ns，重設訊號無效，最小sopc開始執行，執行1000ns，暫停模擬 */
	initial begin
		rst = `RstEnable;
		#195 rst = `RstDisable;
		#1000 $stop;
	end
		
	/* 實體化最小sopc */
	openmips_min_sopc openmips_min_sopc0(.clk(CLOCK_50), .rst(rst));
		
endmodule
