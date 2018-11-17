/* 儲存位址，並依據輸入的位址，給出對應位址的指令 */
module rom(ce, addr, inst);

	input wire 			ce; 	 /* 啟用訊號 */
	input wire [5:0]	addr;  /* 要讀取的指令位址 */
	output reg [31:0]	inst;  /* 讀出的指令 */
	
	reg [31:0] rom[63:0];	 /* 使用二維向量：有64個，每個皆32位元 */
	
	/* 讀入檔案rom.data的資料到rom中 */
	initial $readmemh ("rom.data", rom);
	
	/* 啟用訊號無效時，給出的資料為0，反之則給出位址addr對應的指令 */
	always @( ce, addr )
		begin
			if(!ce)
				inst <= 32'h00000000;
			else
				inst <= rom[addr]; /* 2 ^ 6(->addr) = 64(->rom[]) */
		end
		
endmodule
