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
`define Stop					1'b1				/* 管線暫停 */
`define NoStop					1'b0				/* 管線繼續 */



/******************** 與具體指令有關的巨集定義 ********************************/
/* OP Code */
`define EXE_AND					6'b100100			/* and指令的功能碼 */
`define EXE_OR					6'b100101			/* or指令的功能碼 */
`define EXE_XOR					6'b100110			/* xor指令的功能碼 */
`define EXE_NOR					6'b100111			/* nor指令的功能碼 */
`define EXE_ANDI				6'b001100			/* andi指令的指令碼 */
`define EXE_ORI					6'b001101			/* ori指令的指令碼 */
`define EXE_XORI				6'b001110			/* xori指令的指令碼 */
`define EXE_LUI					6'b001111			/* lui指令的指令碼 */

`define EXE_SLL					6'b000000			/* sll指令的功能碼 */
`define EXE_SLLV				6'b000100			/* sllv指令的功能碼 */
`define EXE_SRL					6'b000010			/* srl指令的功能碼 */
`define EXE_SRLV				6'b000110			/* srlv指令的功能碼 */
`define EXE_SRA					6'b000011			/* sra指令的功能碼 */
`define EXE_SRAV				6'b000111			/* srav指令的功能碼 */

`define EXE_MOVZ				6'b001010			/* movz指令的功能碼 */
`define EXE_MOVN				6'b001011			/* movn指令的功能碼 */
`define EXE_MFHI				6'b010000			/* mfhi指令的功能碼 */
`define EXE_MTHI				6'b010001			/* mthi指令的功能碼 */
`define EXE_MFLO				6'b010010			/* mflo指令的功能碼 */
`define EXE_MTLO				6'b010011			/* mtlo指令的功能碼 */

`define EXE_SLT					6'b101010			/* slt指令的功能碼 */
`define EXE_SLTU				6'b101011			/* sltu指令的功能碼 */
`define EXE_SLTI				6'b001010			/* slti指令的指令碼 */
`define EXE_SLTIU				6'b001011			/* sltiu指令的指令碼 */
`define EXE_ADD					6'b100000			/* add指令的功能碼 */
`define EXE_ADDU				6'b100001			/* addu指令的功能碼 */
`define EXE_SUB					6'b100010			/* sub指令的功能碼 */
`define EXE_SUBU				6'b100011			/* subu指令的功能碼 */
`define EXE_ADDI				6'b001000			/* addi指令的指令碼 */
`define EXE_ADDIU				6'b001001			/* addiu指令的指令碼 */
`define EXE_CLZ					6'b100000			/* clz指令的功能碼 */
`define EXE_CLO					6'b100001			/* clo指令的功能碼 */

`define EXE_MULT				6'b011000			/* mult指令的功能碼 */
`define EXE_MULTU				6'b011001			/* multu指令的功能碼 */
`define EXE_MUL					6'b000010			/* mul指令的功能碼 */
`define EXE_MADD				6'b000000			/* madd指令的功能碼 */
`define EXE_MADDU				6'b000001			/* maddu指令的功能碼 */
`define EXE_MSUB				6'b000100			/* msub指令的功能碼 */
`define EXE_MSUBU				6'b000101			/* msubu指令的功能碼 */

`define EXE_DIV					6'b011010			/* div指令的功能碼 */
`define EXE_DIVU				6'b011011			/* divu指令的功能碼 */

`define EXE_SYNC				6'b001111			/* sync指令的功能碼 */
`define EXE_PREF				6'b110011			/* pref指令的指令碼 */

`define EXE_SPECIAL_INST		6'b000000			/* SPECIAL類指令的指令碼 */
`define EXE_REGIMM_INST			6'b000001			/* REGIMM類指令的指令碼 */
`define EXE_SPECIAL2_INST		6'b011100			/* SPECIAL2類指令的指令碼 */

`define EXE_NOP					6'b000000			/* nop指令的指令碼 */
`define SSNOP					32'b00000000000000000000000001000000

/* AluOp */
`define EXE_AND_OP				8'b00100100
`define EXE_OR_OP				8'b00100101
`define EXE_XOR_OP				8'b00100110
`define EXE_NOR_OP				8'b00100111
`define EXE_ANDI_OP				8'b01011001
`define EXE_ORI_OP				8'b01011010
`define EXE_XORI_OP				8'b01011011
`define EXE_LUI_OP				8'b01011100

`define EXE_SLL_OP				8'b01111100
`define EXE_SLLV_OP				8'b00000100
`define EXE_SRL_OP				8'b00000010
`define EXE_SRLV_OP				8'b00000110
`define EXE_SRA_OP				8'b00000011
`define EXE_SRAV_OP				8'b00000111

`define EXE_MOVZ_OP				8'b00001010
`define EXE_MOVN_OP				8'b00001011
`define EXE_MFHI_OP				8'b00010000
`define EXE_MTHI_OP				8'b00010001
`define EXE_MFLO_OP				8'b00010010
`define EXE_MTLO_OP				8'b00010011

`define EXE_SLT_OP				8'b00101010
`define EXE_SLTU_OP				8'b00101011
`define EXE_SLTI_OP				8'b01010111
`define EXE_SLTIU_OP			8'b01011000
`define EXE_ADD_OP				8'b00100000
`define EXE_ADDU_OP				8'b00100001
`define EXE_SUB_OP				8'b00100010
`define EXE_SUBU_OP				8'b00100011
`define EXE_ADDI_OP				8'b01010101
`define EXE_ADDIU_OP			8'b01010110
`define EXE_CLZ_OP				8'b10110000
`define EXE_CLO_OP				8'b10110001

`define EXE_MULT_OP				8'b00011000
`define EXE_MULTU_OP			8'b00011001
`define EXE_MUL_OP				8'b10101001
`define EXE_MADD_OP				8'b10100110
`define EXE_MADDU_OP			8'b10101000
`define EXE_MSUB_OP				8'b10101010
`define EXE_MSUBU_OP			8'b10101011

`define EXE_DIV_OP				8'b00011010
`define EXE_DIVU_OP				8'b00011011

`define EXE_NOP_OP				8'b00000000

/* AluSel */
`define EXE_RES_LOGIC			3'b001
`define EXE_RES_SHIFT			3'b010
`define EXE_RES_MOVE			3'b011
`define EXE_RES_ARITHMETIC		3'b100
`define EXE_RES_MUL				3'b101
		
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



/******************** 與除法模組DIV有關的巨集指令 ******************************/
`define DivFree					2'b00
`define DivByZero				2'b01
`define DivOn					2'b10
`define DivEnd					2'b11
`define DivResultReady			1'b1
`define DivResultNotReady		1'b0
`define DivStart				1'b1
`define DivStop					1'b0
