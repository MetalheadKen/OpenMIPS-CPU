/******************** 全域的巨集定義 *************************************/
`define RstEnable				1'b1				/* 啟用訊號有效 */
`define RstDisable				1'b0				/* 啟用訊號無效 */
`define ZeroWord				32'h00000000		/* 32位元的數值0 */
`define WriteEnable				1'b1				/* 啟用寫入 */
`define WriteDisable			1'b0				/* 停用寫入 */
`define ReadEnable				1'b1				/* 啟用讀取 */
`define ReadDisable				1'b0				/* 停用讀取 */
`define AluOpBus				7:0					/* 解碼階段的輸出aluop_o的寬度 */
`define AluSelBus				2:0					/* 解碼階段的輸出alusel_o的寬度 */
`define InstValid				1'b0				/* 指令有效 */
`define InstInvalid				1'b1				/* 指令無效 */
`define True_v					1'b1				/* 邏輯"真" */
`define False_v					1'b0				/* 邏輯"假" */
`define ChipEnable				1'b1				/* 晶片啟用 */
`define ChipDisable				1'b0				/* 晶片停用 */



/******************** 與具體指令有關的巨集定義 ********************************/
/* OP Code */
`define EXE_ORI					6'b001101			/* 指令ori的指令碼 */
`define EXE_NOP					6'b000000			/* 指令nop的指令碼 */

/* AluOp */
`define EXE_OR_OP				8'b00100101
`define EXE_ORI_OP				8'b01011010
`define EXE_NOP_OP				8'b00000000				

/* AluSel */
`define EXE_RES_LOGIC			3'b001				
`define EXE_RES_NOP				3'b000	


			
/******************** 與指令記憶體ROM有關的巨集定義 ****************************/
`define InstAddrBus				31:0				/* ROM的位址匯流排寬度 */
`define InstBus					31:0				/* ROM的資料匯流排寬度 */
`define InstMemNum				131071				/* ROM的實際大小為128KB */
`define InstMemNumLog2			17					/* ROM實際使用的位址線寬度 */



/******************** 與通用暫存器Regfile有關的巨集定義 ************************/
`define RegAddrBus				4:0					/* Regfile模組的位址線寬度 */
`define RegBus					31:0				/* Regfile模組的資料線寬度 */
`define RegWidth				32					/* 通用暫存器的寬度 */
`define DoubleRegWidth			64					/* 兩倍的通用暫存器寬度 */
`define DoubleRegBus			63:0				/* 兩倍的通用暫存器的資料線寬度 */
`define RegNum					32					/* 通用暫存器的數量 */
`define RegNumLog2				5					/* 定址通用暫存器使用的位址位數 */
`define NOPRegAddr				5'b00000			
