`include "defines.v"

/* 解碼的工作主要內容是：確定要讀取的暫存器情況、要執行的運算和要寫入的目的暫存器三方面的資訊 */
/* 對指令進行解碼，得到最終運算的類型、子類型、來源運算元1、來源運算元2、要寫入的目的暫存器位址等資訊 */
module id(rst, pc_i, inst_i, reg1_data_i, reg2_data_i, ex_wreg_i, ex_wdata_i, ex_wd_i, mem_wreg_i, mem_wdata_i, mem_wd_i,
		  reg1_read_o, reg2_read_o, reg1_addr_o, reg2_addr_o, aluop_o, alusel_o, reg1_o, reg2_o, wd_o, wreg_o, stallreq);

	input wire 							rst;					/* 重設訊號 */
	input wire [`InstAddrBus]			pc_i;					/* 解碼階段的指令對應的位址 */
	input wire [`InstBus]	 			inst_i;					/* 解碼階段的指令 */
	
	/* 讀取的Regfile的值 */
	input wire [`RegBus]				reg1_data_i;			/* 從Regfile輸入的第一個讀取暫存器連接埠的輸入 */
	input wire [`RegBus]				reg2_data_i;			/* 從Regfile輸入的第二個讀取暫存器連接埠的輸入 */
	
	/* 處於執行階段的指令的運算結果 */
	input wire							ex_wreg_i;				/* 處於執行階段的指令是否要寫入目的暫存器 */
	input wire [`RegBus]				ex_wdata_i;				/* 處於執行階段的指令要寫入的目的暫存器位址 */
	input wire [`RegAddrBus]			ex_wd_i;				/* 處於執行階段的指令要寫入目的暫存器的資料 */
	
	/* 處於存取記憶體階段的指令的運算結果 */
	input wire							mem_wreg_i;				/* 處於存取記憶體階段的指令是否要寫入目的暫存器 */
	input wire [`RegBus]				mem_wdata_i;			/* 處於存取記憶體階段的指令要寫入的目的暫存器位址 */
	input wire [`RegAddrBus]			mem_wd_i;				/* 處於存取記憶體階段的指令要寫入目的暫存器的資料 */
	
	/* 輸出到Regfile的資訊 */
	output reg 							reg1_read_o;			/* Regfile模組的第一個讀取暫存器連接埠的讀取啟用訊號 */
	output reg 							reg2_read_o;			/* Regfile模組的第二個讀取暫存器連接埠的讀取啟用訊號 */
	output reg [`RegAddrBus]			reg1_addr_o;			/* Regfile模組的第一個讀取暫存器連接埠的讀取位址訊號 */
	output reg [`RegAddrBus]			reg2_addr_o;			/* Regfile模組的第二個讀取暫存器連接埠的讀取位址訊號 */	
	
	/* 送到執行階段的資訊 */
	output reg [`AluOpBus]				aluop_o;				/* 解碼階段的指令要進行的運算的子類型 */
	output reg [`AluSelBus] 			alusel_o;				/* 解碼階段的指令要進行的運算的類型 */
	output reg [`RegBus]				reg1_o;					/* 解碼階段的指令要進行的運算的來源運算元1 */
	output reg [`RegBus]				reg2_o;					/* 解碼階段的指令要進行的運算的來源運算元2 */
	output reg [`RegAddrBus] 			wd_o;					/* 解碼階段的指令要寫入的目的暫存器位址 */
	output reg 							wreg_o;					/* 解碼階段的指令是否有要寫入的目的暫存器 */
	
	/* 送到控制模組的資訊 */
	output wire							stallreq;				/* 管線暫停訊號 */
	
	/* 取得指令的指令碼、功能碼 */
	wire [5:0] op 	= inst_i[31:26];	/* 指令碼 */
	wire [4:0] op2 	= inst_i[10:6];
	wire [5:0] op3 	= inst_i[5:0];		/* 功能碼 */
	wire [4:0] op4 	= inst_i[20:16];
	
	/* 保存指令需要的立即數 */		
	reg [`RegBus] imm;
	
	/* 指示指令是否有效 */
	reg instvalid;
	
	assign stallreq = `NoStop;
	
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
					wd_o 				<= inst_i[15:11];	/* 預設的目的暫存器位址wd_o */
					wreg_o 				<= `WriteDisable;
					instvalid 			<= `InstInvalid;
					reg1_read_o 		<= 1'b0;
					reg2_read_o 		<= 1'b0;
					reg1_addr_o 		<= inst_i[25:21];	/* 預設的reg1_addr_o */
					reg2_addr_o 		<= inst_i[20:16];	/* 預設的reg2_addr_o */
					imm					<= `ZeroWord;
					
					case(op)
						`EXE_SPECIAL_INST:
							begin
								case(op2)
									5'b00000:
										begin
											/* 依據功能碼判斷是哪種指令 */
											case(op3)
												/* or指令 */
												`EXE_OR:
													begin								
														wreg_o 			<=	`WriteEnable;				
														aluop_o 		<=	`EXE_OR_OP;					
														alusel_o 		<= 	`EXE_RES_LOGIC;				
														reg1_read_o 	<= 	1'b1;
														reg2_read_o 	<= 	1'b1;		
														instvalid		<=	`InstValid;					
													end													
												/* and指令 */
												`EXE_AND:
													begin								
														wreg_o 			<=	`WriteEnable;				
														aluop_o 		<=	`EXE_AND_OP;					
														alusel_o 		<= 	`EXE_RES_LOGIC;		/* 進行邏輯 "與" 操作 */		
														reg1_read_o 	<= 	1'b1;				/* 讀取rs暫存器的值 */
														reg2_read_o 	<= 	1'b1;				/* 讀取rt暫存器的值 */
														instvalid		<=	`InstValid;
													end													
												/* xor指令 */
												`EXE_XOR:
													begin								
														wreg_o 			<=	`WriteEnable;
														aluop_o 		<=	`EXE_XOR_OP;
														alusel_o 		<= 	`EXE_RES_LOGIC;				
														reg1_read_o 	<= 	1'b1;						
														reg2_read_o 	<= 	1'b1;		
														instvalid		<=	`InstValid;					
													end
												/* nor指令 */
												`EXE_NOR:
													begin								
														wreg_o 			<=	`WriteEnable;				
														aluop_o 		<=	`EXE_NOR_OP;					
														alusel_o 		<= 	`EXE_RES_LOGIC;				
														reg1_read_o 	<= 	1'b1;						
														reg2_read_o 	<= 	1'b1;		
														instvalid		<=	`InstValid;					
													end
												/* sllv指令 */
												`EXE_SLLV:
													begin								
														wreg_o 			<=	`WriteEnable;				
														aluop_o 		<=	`EXE_SLL_OP;					
														alusel_o 		<= 	`EXE_RES_SHIFT;				
														reg1_read_o 	<= 	1'b1;						
														reg2_read_o 	<= 	1'b1;		
														instvalid		<=	`InstValid;					
													end
												/* srlv指令 */
												`EXE_SRLV:
													begin								
														wreg_o 			<=	`WriteEnable;				
														aluop_o 		<=	`EXE_SRL_OP;					
														alusel_o 		<= 	`EXE_RES_SHIFT;				
														reg1_read_o 	<= 	1'b1;						
														reg2_read_o 	<= 	1'b1;		
														instvalid		<=	`InstValid;					
													end
												/* srav指令 */
												`EXE_SRAV:
													begin								
														wreg_o 			<=	`WriteEnable;				
														aluop_o 		<=	`EXE_SRA_OP;					
														alusel_o 		<= 	`EXE_RES_SHIFT;				
														reg1_read_o 	<= 	1'b1;						
														reg2_read_o 	<= 	1'b1;		
														instvalid		<=	`InstValid;					
													end
												/* sync指令 */
												`EXE_SYNC:
													begin								
														wreg_o 			<=	`WriteEnable;				
														aluop_o 		<=	`EXE_NOP_OP;					
														alusel_o 		<= 	`EXE_RES_NOP;				
														reg1_read_o 	<= 	1'b0;						
														reg2_read_o 	<= 	1'b1;		
														instvalid		<=	`InstValid;					
													end
												/* mfhi指令 */
												`EXE_MFHI:
													begin								
														wreg_o 			<=	`WriteEnable;				
														aluop_o 		<=	`EXE_MFHI_OP;					
														alusel_o 		<= 	`EXE_RES_MOVE;				
														reg1_read_o 	<= 	1'b0;						
														reg2_read_o 	<= 	1'b0;		
														instvalid		<=	`InstValid;					
													end
												/* mflo指令 */
												`EXE_MFLO:
													begin								
														wreg_o 			<=	`WriteEnable;				
														aluop_o 		<=	`EXE_MFLO_OP;					
														alusel_o 		<= 	`EXE_RES_MOVE;				
														reg1_read_o 	<= 	1'b0;						
														reg2_read_o 	<= 	1'b0;		
														instvalid		<=	`InstValid;					
													end
												/* mthi指令 */
												`EXE_MTHI:
													begin								
														wreg_o 			<=	`WriteDisable;				
														aluop_o 		<=	`EXE_MTHI_OP;					
														reg1_read_o 	<= 	1'b1;						
														reg2_read_o 	<= 	1'b0;		
														instvalid		<=	`InstValid;					
													end
												/* mtlo指令 */
												`EXE_MTLO:
													begin								
														wreg_o 			<=	`WriteDisable;				
														aluop_o 		<=	`EXE_MTLO_OP;					
														reg1_read_o 	<= 	1'b1;						
														reg2_read_o 	<= 	1'b0;		
														instvalid		<=	`InstValid;					
													end
												/* movn指令 */
												`EXE_MOVN:
													begin								
														aluop_o 		<=	`EXE_MOVN_OP;					
														alusel_o 		<= 	`EXE_RES_MOVE;				
														reg1_read_o 	<= 	1'b1;						
														reg2_read_o 	<= 	1'b1;		
														instvalid		<=	`InstValid;
														
														/* reg2_o的值就是位址為rt的通用暫存器 */
														if(reg2_o != `ZeroWord)
															wreg_o <= `WriteEnable;
														else
															wreg_o <= `WriteDisable;
													end
												/* movz指令 */
												`EXE_MOVZ:
													begin								
														aluop_o 		<=	`EXE_MOVZ_OP;					
														alusel_o 		<= 	`EXE_RES_MOVE;				
														reg1_read_o 	<= 	1'b1;						
														reg2_read_o 	<= 	1'b1;		
														instvalid		<=	`InstValid;
																	
														/* reg2_o的值就是位址為rt的通用暫存器 */
														if(reg2_o == `ZeroWord)
															wreg_o <= `WriteEnable;
														else
															wreg_o <= `WriteDisable;
													end
												/* slt指令 */
												`EXE_SLT:
													begin								
														wreg_o 			<=	`WriteEnable;				
														aluop_o 		<=	`EXE_SLT_OP;					
														alusel_o 		<= 	`EXE_RES_ARITHMETIC;				
														reg1_read_o 	<= 	1'b1;
														reg2_read_o 	<= 	1'b1;		
														instvalid		<=	`InstValid;					
													end
												/* sltu指令 */
												`EXE_SLTU:
													begin								
														wreg_o 			<=	`WriteEnable;
														aluop_o 		<=	`EXE_SLTU_OP;					
														alusel_o 		<= 	`EXE_RES_ARITHMETIC;				
														reg1_read_o 	<= 	1'b1;
														reg2_read_o 	<= 	1'b1;		
														instvalid		<=	`InstValid;					
													end
												/* add指令 */
												`EXE_ADD:
													begin								
														wreg_o 			<=	`WriteEnable;				
														aluop_o 		<=	`EXE_ADD_OP;					
														alusel_o 		<= 	`EXE_RES_ARITHMETIC;				
														reg1_read_o 	<= 	1'b1;
														reg2_read_o 	<= 	1'b1;		
														instvalid		<=	`InstValid;					
													end	
												/* addu指令 */
												`EXE_ADDU:
													begin								
														wreg_o 			<=	`WriteEnable;				
														aluop_o 		<=	`EXE_ADDU_OP;					
														alusel_o 		<= 	`EXE_RES_ARITHMETIC;				
														reg1_read_o 	<= 	1'b1;
														reg2_read_o 	<= 	1'b1;		
														instvalid		<=	`InstValid;					
													end
												/* sub指令 */
												`EXE_SUB:
													begin								
														wreg_o 			<=	`WriteEnable;				
														aluop_o 		<=	`EXE_SUB_OP;					
														alusel_o 		<= 	`EXE_RES_ARITHMETIC;				
														reg1_read_o 	<= 	1'b1;
														reg2_read_o 	<= 	1'b1;		
														instvalid		<=	`InstValid;					
													end
												/* subu指令 */
												`EXE_SUBU:
													begin								
														wreg_o 			<=	`WriteEnable;				
														aluop_o 		<=	`EXE_SUBU_OP;					
														alusel_o 		<= 	`EXE_RES_ARITHMETIC;				
														reg1_read_o 	<= 	1'b1;
														reg2_read_o 	<= 	1'b1;		
														instvalid		<=	`InstValid;					
													end
												/* mult指令 */
												`EXE_MULT:
													begin								
														wreg_o 			<=	`WriteDisable;				
														aluop_o 		<=	`EXE_MULT_OP;					
														reg1_read_o 	<= 	1'b1;
														reg2_read_o 	<= 	1'b1;		
														instvalid		<=	`InstValid;					
													end
												/* multu指令 */
												`EXE_MULTU:
													begin								
														wreg_o 			<=	`WriteDisable;				
														aluop_o 		<=	`EXE_MULTU_OP;					
														reg1_read_o 	<= 	1'b1;
														reg2_read_o 	<= 	1'b1;		
														instvalid		<=	`InstValid;					
													end
												/* div指令 */
												`EXE_DIV:
													begin								
														wreg_o 			<=	`WriteDisable;				
														aluop_o 		<=	`EXE_DIV_OP;					
														reg1_read_o 	<= 	1'b1;
														reg2_read_o 	<= 	1'b1;		
														instvalid		<=	`InstValid;					
													end
												/* divu指令 */
												`EXE_DIVU:
													begin								
														wreg_o 			<=	`WriteDisable;				
														aluop_o 		<=	`EXE_DIVU_OP;
														reg1_read_o 	<= 	1'b1;
														reg2_read_o 	<= 	1'b1;		
														instvalid		<=	`InstValid;					
													end
												default:
													begin
													end
											endcase /* case op3 */
										end
									default:
										begin
										end
								endcase /* case op2 */
							end
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
						/* andi指令 */
						`EXE_ANDI:
							begin								
								wreg_o 			<=	`WriteEnable;				
								aluop_o 		<=	`EXE_AND_OP;					
								alusel_o 		<= 	`EXE_RES_LOGIC;				
								reg1_read_o 	<= 	1'b1;						
								reg2_read_o 	<= 	1'b0;						
								imm				<= 	{16'h0, inst_i[15:0]};		
								wd_o			<=	inst_i[20:16];				
								instvalid		<=	`InstValid;					
							end
						/* xori指令 */
						`EXE_XORI:
							begin								
								wreg_o 			<=	`WriteEnable;				
								aluop_o 		<=	`EXE_XOR_OP;					
								alusel_o 		<= 	`EXE_RES_LOGIC;				
								reg1_read_o 	<= 	1'b1;						
								reg2_read_o 	<= 	1'b0;						
								imm				<= 	{16'h0, inst_i[15:0]};		
								wd_o			<=	inst_i[20:16];				
								instvalid		<=	`InstValid;					
							end
						/* lui指令 */
						`EXE_LUI:
							begin								
								wreg_o 			<=	`WriteEnable;				
								aluop_o 		<=	`EXE_OR_OP;					
								alusel_o 		<= 	`EXE_RES_LOGIC;				
								reg1_read_o 	<= 	1'b1;						
								reg2_read_o 	<= 	1'b0;						
								imm				<= 	{inst_i[15:0], 16'h0};		
								wd_o			<=	inst_i[20:16];				
								instvalid		<=	`InstValid;					
							end
						/* pref指令 */
						`EXE_PREF:
							begin								
								wreg_o 			<=	`WriteDisable;				
								aluop_o 		<=	`EXE_NOP_OP;					
								alusel_o 		<= 	`EXE_RES_NOP;				
								reg1_read_o 	<= 	1'b0;						
								reg2_read_o 	<= 	1'b0;								
								instvalid		<=	`InstValid;					
							end
						/* slti指令 */
						`EXE_SLTI:
							begin								
								wreg_o 			<=	`WriteEnable;				
								aluop_o 		<=	`EXE_SLT_OP;					
								alusel_o 		<= 	`EXE_RES_ARITHMETIC;				
								reg1_read_o 	<= 	1'b1;						
								reg2_read_o 	<= 	1'b0;						
								imm				<= 	{{16{inst_i[15]}}, inst_i[15:0]};	/* 帶符號擴充立即數 */	
								wd_o			<=	inst_i[20:16];				
								instvalid		<=	`InstValid;					
							end
						/* sltiu指令 */
						`EXE_SLTIU:
							begin								
								wreg_o 			<=	`WriteEnable;				
								aluop_o 		<=	`EXE_SLTU_OP;					
								alusel_o 		<= 	`EXE_RES_ARITHMETIC;				
								reg1_read_o 	<= 	1'b1;						
								reg2_read_o 	<= 	1'b0;						
								imm				<= 	{{16{inst_i[15]}}, inst_i[15:0]};		
								wd_o			<=	inst_i[20:16];				
								instvalid		<=	`InstValid;					
							end
						/* addi指令 */
						`EXE_ADDI:
							begin								
								wreg_o 			<=	`WriteEnable;				
								aluop_o 		<=	`EXE_ADDI_OP;					
								alusel_o 		<= 	`EXE_RES_ARITHMETIC;				
								reg1_read_o 	<= 	1'b1;						
								reg2_read_o 	<= 	1'b0;						
								imm				<= 	{{16{inst_i[15]}}, inst_i[15:0]};		
								wd_o			<=	inst_i[20:16];				
								instvalid		<=	`InstValid;					
							end
						/* addiu指令 */
						`EXE_ADDIU:
							begin								
								wreg_o 			<=	`WriteEnable;				
								aluop_o 		<=	`EXE_ADDIU_OP;					
								alusel_o 		<= 	`EXE_RES_ARITHMETIC;				
								reg1_read_o 	<= 	1'b1;						
								reg2_read_o 	<= 	1'b0;						
								imm				<= 	{{16{inst_i[15]}}, inst_i[15:0]};		
								wd_o			<=	inst_i[20:16];				
								instvalid		<=	`InstValid;					
							end
						/* SPECIAL2類指令 */
						`EXE_SPECIAL2_INST:
							begin
								case(op3)
									/* clz指令 */
									`EXE_CLZ:
										begin								
											wreg_o 			<=	`WriteEnable;				
											aluop_o 		<=	`EXE_CLZ_OP;					
											alusel_o 		<= 	`EXE_RES_ARITHMETIC;				
											reg1_read_o 	<= 	1'b1;						
											reg2_read_o 	<= 	1'b0;						
											instvalid		<=	`InstValid;					
										end
									/* clo指令 */
									`EXE_CLO:
										begin								
											wreg_o 			<=	`WriteEnable;				
											aluop_o 		<=	`EXE_CLO_OP;					
											alusel_o 		<= 	`EXE_RES_ARITHMETIC;				
											reg1_read_o 	<= 	1'b1;						
											reg2_read_o 	<= 	1'b0;						
											instvalid		<=	`InstValid;					
										end
									/* mul指令 */
									`EXE_MUL:
										begin								
											wreg_o 			<=	`WriteEnable;				
											aluop_o 		<=	`EXE_MUL_OP;					
											alusel_o 		<= 	`EXE_RES_MUL;				
											reg1_read_o 	<= 	1'b1;						
											reg2_read_o 	<= 	1'b1;						
											instvalid		<=	`InstValid;					
										end
									/* madd指令 */
									`EXE_MADD:
										begin								
											wreg_o 			<=	`WriteDisable;	/* 因是寫入HI、LO暫存器，而不是寫入通用暫存器 */		
											aluop_o 		<=	`EXE_MADD_OP;					
											alusel_o 		<= 	`EXE_RES_MUL;				
											reg1_read_o 	<= 	1'b1;						
											reg2_read_o 	<= 	1'b1;						
											instvalid		<=	`InstValid;					
										end
									/* maddu指令 */
									`EXE_MADDU:
										begin								
											wreg_o 			<=	`WriteDisable;				
											aluop_o 		<=	`EXE_MADDU_OP;					
											alusel_o 		<= 	`EXE_RES_MUL;				
											reg1_read_o 	<= 	1'b1;						
											reg2_read_o 	<= 	1'b1;						
											instvalid		<=	`InstValid;					
										end
									/* msub指令 */
									`EXE_MSUB:
										begin								
											wreg_o 			<=	`WriteDisable;				
											aluop_o 		<=	`EXE_MSUB_OP;					
											alusel_o 		<= 	`EXE_RES_MUL;				
											reg1_read_o 	<= 	1'b1;						
											reg2_read_o 	<= 	1'b1;						
											instvalid		<=	`InstValid;					
										end
									/* msubu指令 */
									`EXE_MSUBU:
										begin								
											wreg_o 			<=	`WriteDisable;				
											aluop_o 		<=	`EXE_MSUBU_OP;					
											alusel_o 		<= 	`EXE_RES_MUL;				
											reg1_read_o 	<= 	1'b1;						
											reg2_read_o 	<= 	1'b1;						
											instvalid		<=	`InstValid;					
										end
									default:
										begin
										end
								endcase /* case EXE_SPECIAL2_INST */
							end
						default:
							begin
							end
					endcase /* case op */
					
					if(inst_i[31:21] == 11'b00000000000)
						begin
							/* sll指令 */
							if(op3 == `EXE_SLL)
								begin								
									wreg_o 			<=	`WriteEnable;				
									aluop_o 		<=	`EXE_SLL_OP;					
									alusel_o 		<= 	`EXE_RES_SHIFT;				
									reg1_read_o 	<= 	1'b0;						
									reg2_read_o 	<= 	1'b1;						
									imm[4:0]		<= 	inst_i[10:6];		
									wd_o			<=	inst_i[15:11];				
									instvalid		<=	`InstValid;					
								end
							/* srl指令 */
							else if(op3 == `EXE_SRL)
								begin								
									wreg_o 			<=	`WriteEnable;				
									aluop_o 		<=	`EXE_SRL_OP;					
									alusel_o 		<= 	`EXE_RES_SHIFT;				
									reg1_read_o 	<= 	1'b0;						
									reg2_read_o 	<= 	1'b1;						
									imm[4:0]		<= 	inst_i[10:6];		
									wd_o			<=	inst_i[15:11];				
									instvalid		<=	`InstValid;					
								end
							/* sra指令 */
							else if(op3 == `EXE_SRA)
								begin								
									wreg_o 			<=	`WriteEnable;				
									aluop_o 		<=	`EXE_SRA_OP;					
									alusel_o 		<= 	`EXE_RES_SHIFT;				
									reg1_read_o 	<= 	1'b0;						
									reg2_read_o 	<= 	1'b1;						
									imm[4:0]		<= 	inst_i[10:6];		
									wd_o			<=	inst_i[15:11];				
									instvalid		<=	`InstValid;					
								end
						end /* if inst_i[31:21] */
				end /* if rst */
		end /* always */
	
	/* 確定進行運算的來源運算元1 */	
	always @ ( * )
		begin
			if(rst == `RstEnable)
				reg1_o <= `ZeroWord;
			else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o))
				reg1_o <= ex_wdata_i;
			else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o))
				reg1_o <= mem_wdata_i;
			else if(reg1_read_o == 1'b1)
				reg1_o <= reg1_data_i;		/* Regfile讀取連接埠1(inst_i[25:21])的輸出值 */
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
			else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o))
				reg2_o <= ex_wdata_i;
			else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o))
				reg2_o <= mem_wdata_i;
			else if(reg2_read_o == 1'b1)
				reg2_o <= reg2_data_i;		/* Regfile讀取連接埠2讀取的暫存器的值作為來源運算元2 */
			else if(reg2_read_o == 1'b0)
				reg2_o <= imm;				/* 將立即數作為來源運算元2 */
			else
				reg2_o <= `ZeroWord;
		end
		
endmodule
