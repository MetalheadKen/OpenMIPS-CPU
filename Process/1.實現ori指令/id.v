`include "defines.v"

/* 對指令進行解碼，得到最終運算的類型、子類型、來源運算元1、來源運算元2、要寫入的目的暫存器位址等資訊 */
module id(rst, pc_i, inst_i, reg1_data_i, reg2_data_i, reg1_read_o, reg2_read_o,
		  reg1_addr_o, reg2_addr_o, aluop_o, alusel_o, reg1_o, reg2_o, wd_o, wreg_o);

	input wire 							rst;					/* 重設訊號 */
	input wire [`InstAddrBus]			pc_i;					/* 解碼階段的指令對應的位址 */
	input wire [`InstBus]	 			inst_i;					/* 解碼階段的指令 */
	
	/* 讀取的Regfile的值 */
	input wire [`RegBus]				reg1_data_i;			/* 從Regfile輸入的第一個讀取暫存器連接埠的輸入 */
	input wire [`RegBus]				reg2_data_i;			/* 從Regfile輸入的第二個讀取暫存器連接埠的輸入 */
	
	/* 輸出到Regfile的資訊 */
	output reg 							reg1_read_o;			/* Regfile模組的第一個讀取暫存器連接埠的讀取啟用訊號 */
	output reg 							reg2_read_o;			/* Regfile模組的第二個讀取暫存器連接埠的讀取啟用訊號 */
	output reg [`RegAddrBus]			reg1_addr_o;			/* Regfile模組的第一個讀取暫存器連接埠的讀取位址訊號 */
	output reg [`RegAddrBus]			reg2_addr_o;			/* Regfile模組的第二個讀取暫存器連接埠的讀取位址訊號 */	
	
	/* 送到執行階段的資訊 */
	output reg [`AluOpBus]				aluop_o;				/* 解碼階段的指令要進行的運算的子類型 */
	output reg [`AluSelBus] 			alusel_o;				/* 解碼階段的指?O要進行的運算的類型 */
	output reg [`RegBus]				reg1_o;					/* 解碼階段的指令要進行的運算的來源運算元1 */
	output reg [`RegBus]				reg2_o;					/* 解碼階段的指令要進行的運算的來源運算元2 */
	output reg [`RegAddrBus] 			wd_o;					/* 解碼階段的指令要寫入的目的暫存器位址 */
	output reg 							wreg_o;					/* 解碼階段的指令是否有要寫入的目的暫存器 */
	
	/* 取得指令的指令碼、功能碼 */
	/* 對於ori指令只需透過判斷第26-31bit的值，即可判斷是否是ori指令 */
	wire [5:0] op 	= inst_i[31:26];
	wire [4:0] op2 	= inst_i[10:6];
	wire [5:0] op3 	= inst_i[5:0];
	wire [4:0] op4 	= inst_i[20:16];
	
	/* 保存指令需要的立即數 */		
	reg [`RegBus] imm;
	
	/* 指示指令是否有效 */
	reg instvalid;
	
	/* 對指令進行解碼 */	
	always @( * )
		begin
			if(rst == `RstEnable)
				begin
					aluop_o 			<= `EXE_NOP_OP;
					alusel_o 			<= `EXE_RES_NOP;
					wd_o 				<= `NOPRegAddr;
					wreg_o 				<= `WriteDisable;
					instvalid 			<= `InstValid;
					reg1_read_o 		<= 1'b0;
					reg2_read_o 		<= 1'b0;
					reg1_addr_o 		<= `NOPRegAddr;
					reg2_addr_o 		<= `NOPRegAddr;
					imm 				<= 32'h0;
				end
			else
				begin
					aluop_o 			<= `EXE_NOP_OP;
					alusel_o 			<= `EXE_RES_NOP;
					wd_o 				<= inst_i[15:11];
					wreg_o 				<= `WriteDisable;
					instvalid 			<= `InstInvalid;
					reg1_read_o 		<= 1'b0;
					reg2_read_o 		<= 1'b0;
					reg1_addr_o 		<= inst_i[25:21];
					reg2_addr_o 		<= inst_i[20:16];
					imm					<= `ZeroWord;
					
					case(op)
						/* 依據op的值判斷是否是ori指令 */
						`EXE_ORI:
							begin								
								wreg_o 			<=	`WriteEnable;				/* ori指令需要將結果寫入目的暫存器，所以wreg_o為WriteEnable */							
								aluop_o 		<=	`EXE_OR_OP;					/* 運算的子類型是邏輯 "或" 運算 */
								alusel_o 		<= 	`EXE_RES_LOGIC;				/* 運算的類型是邏輯運算 */
								reg1_read_o 	<= 	1'b1;						/* 需要透過Regfile的讀取連接埠1讀取暫存器 */
								reg2_read_o 	<= 	1'b0;						/* 因ori所需的另一個運算元是立即數，故不需要透過Regfile的讀取連接埠2讀取暫存器 */
								imm				<= 	{16'h0, inst_i[15:0]};		/* 指令執行需要的立即數 */
								wd_o			<=	inst_i[20:16];				/* 指令執行要寫入的目的暫存器位址 */
								instvalid		<=	`InstValid;					/* ori指令是有效指令 */
							end
						default:
							begin
							end
					endcase
				end
		end
	
	/* 確定進行運算的來源運算元1 */	
	always @ ( * )
		begin
			if(rst == `RstEnable)
				reg1_o <= `ZeroWord;
			else if(reg1_read_o == 1'b1)
				reg1_o <= reg1_data_i;		/* Regfile讀取連接埠1的輸出值 */
			else if(reg1_read_o == 1'b0)
				reg1_o <= imm;				/* 立即數 */
			else
				reg1_o <= `ZeroWord;
		end
		
	/* 確定進行運算的來源運算元2 */	
	always @ ( * )
		begin
			if(rst == `RstEnable)
				reg2_o <= `ZeroWord;
			else if(reg2_read_o == 1'b1)
				reg2_o <= reg2_data_i;		/* Regfile讀取連接埠2讀取的暫存器的值作為來源運算元2 */
			else if(reg2_read_o == 1'b0)
				reg2_o <= imm;				/* 將立即數作為來源運算元2 */
			else
				reg2_o <= `ZeroWord;
		end
		
endmodule
