`include "defines.v"

/* 實現資料記憶體，以便驗證載入、儲存指令是否實現正確 */
module data_ram(clk, ce, we, addr, sel, data_i, data_o);

	input wire							clk;				/* 時脈訊號 */
	input wire							ce;					/* 資料記憶體啟用訊號 */
	input wire							we;					/* 是否是寫入操作，為1表示是寫入操作 */
	input wire [`DataAddrBus]			addr;				/* 要存取的位址 */
	input wire [3:0]					sel;				/* 位元組選擇訊號 */
	input wire [`DataBus]				data_i;				/* 要寫入的資料 */
	
	output reg [`DataBus]				data_o;				/* 讀出的資料 */
	
	/* 定義四個位元組陣列 */
	reg [`ByteWidth] data_mem0[0:`DataMemNum - 1];
	reg [`ByteWidth] data_mem1[0:`DataMemNum - 1];
	reg [`ByteWidth] data_mem2[0:`DataMemNum - 1];
	reg [`ByteWidth] data_mem3[0:`DataMemNum - 1];
	
	/* 寫入操作 */	
	always @(posedge clk)
		begin
			if(ce == `ChipDisable)
				data_o <= `ZeroWord;
			else if(we == `WriteEnable)
				begin
					if(sel[3] == 1'b1)
						data_mem3[addr[`DataMemNumLog2 + 1:2]] <= data_i[31:24];
					if(sel[2] == 1'b1)
						data_mem2[addr[`DataMemNumLog2 + 1:2]] <= data_i[23:16];
					if(sel[1] == 1'b1)
						data_mem1[addr[`DataMemNumLog2 + 1:2]] <= data_i[15:8];
					if(sel[0] == 1'b1)
						data_mem0[addr[`DataMemNumLog2 + 1:2]] <= data_i[7:0];					
				end
		end
		
	/* 讀取操作 */
	always @( * )
		begin
			if(ce == `ChipDisable)
				data_o <= `ZeroWord;
			else if(we == `WriteDisable)
				begin
					data_o <= {data_mem3[addr[`DataMemNumLog2 + 1:2]],
							   data_mem2[addr[`DataMemNumLog2 + 1:2]],
							   data_mem1[addr[`DataMemNumLog2 + 1:2]],
							   data_mem0[addr[`DataMemNumLog2 + 1:2]]};
								
				end
			else
				data_o <= `ZeroWord;
		end
	
endmodule
