`include "defines.v"

/* 實現指令記憶體，以便OpenMIPS從中讀取指令 */
module inst_rom(ce, addr, inst);

	input wire							ce;					/* 啟用訊號 */
	input wire [`InstAddrBus]			addr;				/* 要讀取的指令位址 */
	
	output reg [`InstBus]				inst;				/* 讀出的指令 */
	
	/* 定義一個陣列，大小是InstMemNum，元素寬度是InstBus */
	reg [`InstBus] inst_mem[0:`InstMemNum - 1];
	
	/* 使用檔案inst_rom.data初始化記憶體 */
	initial $readmemh ("inst_rom.data", inst_mem);
	
	/* 當重設訊號無效時，依據輸入的位址，給出指令記憶體ROM中對應的元素 */	
	always @(*)
		begin
			if(ce == `ChipDisable)
				inst <= `ZeroWord;
			else
				/* 因指令記憶體每個位址是一個32bi，即4Byte的字組，所以要將OpenMIPS給出的指令位址除以4再使用，
				** 除以4也就是將指令右移2位，所以在讀取的時候給出的位址是addr[`InstMemNumLog2 + 1:2]*/
				inst <= inst_mem[addr[`InstMemNumLog2 + 1:2]];
		end
		
endmodule
