`include "defines.v"

/* 依據運算類型、運算子類型、來源運算元1、來源運算元2、要寫入的目的暫存器位址來進行運算 */
module ex(rst, alusel_i, aluop_i, reg1_i, reg2_i, wd_i, wreg_i, hi_i, lo_i, wb_hi_i, wb_lo_i, wb_whilo_i, mem_hi_i, mem_lo_i, mem_whilo_i,
		  wd_o, wreg_o, wdata_o, hi_o, lo_o, whilo_o);

	input wire 							rst;				/* 重設訊號 */
	
	/* 解碼階段送到執行階段的資訊 */
	input wire [`AluOpBus]				aluop_i;			/* 執行階段要進行的運算的子類型 */
	input wire [`AluSelBus]	 			alusel_i;			/* 執行階段要進行的運算的類型 */
	input wire [`RegBus]				reg1_i;				/* 參與運算的來源運算元1 */
	input wire [`RegBus]				reg2_i;				/* 參與運算的來源運算元2 */
	input wire [`RegAddrBus] 			wd_i;				/* 指令執行要寫入的目的暫存器位址 */
	input wire							wreg_i;				/* 是否有要寫入的目的暫存器 */
	
	/* HILO模組給出的HI、LO暫存器的值 */
	input wire [`RegBus]				hi_i;				/* HILO模組給出的HI暫存器的值 */
	input wire [`RegBus]				lo_i;				/* HILO模組給出的LO暫存器的值 */
	
	/* 回寫階段的指令是否要寫入HI、LO，用於檢測HI、LO暫存器帶來的資料相依問題 */
	input wire [`RegBus]				wb_hi_i;			/* 處於回寫階段的指令要寫入HI暫存器的值 */
	input wire [`RegBus]				wb_lo_i;			/* 處於回寫階段的指令要寫入LO暫存器的值 */
	input wire							wb_whilo_i;			/* 處於回寫階段的指令是否要寫入HI、LO暫存器 */
	
	/* 存取記憶體階段的指令是否要寫入HI、LO，用於檢測HI、LO暫存器帶來的資料相依問題 */
	input wire [`RegBus]				mem_hi_i;			/* 處於存取記憶體階段的指令要寫入HI暫存器的值 */
	input wire [`RegBus]				mem_lo_i;			/* 處於存取記憶體階段的指令要寫入LO暫存器的值 */
	input wire							mem_whilo_i;		/* 處於存取記憶體階段的指令是否要寫入HI、LO暫存器 */
	
	/* 執行的結果 */
	output reg [`RegAddrBus] 			wd_o;				/* 執行階段的指令最終要寫入的目的暫存器位址 */
	output reg 							wreg_o;				/* 執行階段的指令最終是否有要寫入的目的暫存器 */
	output reg [`RegBus]				wdata_o;			/* 執行階段的指令最終要寫入目的暫存器的值 */
	
	/* 處於執行階段的指令對HI、LO暫存器的寫入操作請求 */
	output reg [`RegBus]				hi_o;				/* 執行階段的指令要寫入HI暫存器的值 */
	output reg [`RegBus]				lo_o;				/* 執行階段的指令要寫入LO暫存器的值 */
	output reg							whilo_o;			/* 執行階段的指令是否要寫入HI、LO暫存器 */
	
	/* 保存邏輯運算結果 */
	reg [`RegBus] logicout;	
	
	/* 保存移位運算結果 */
	reg [`RegBus] shiftres;
	
	/* 移動操作結果 */
	reg [`RegBus] moveres;
	
	/* 保存HI暫存器的最新值 */
	reg [`RegBus] HI;
	
	/* 保存LO暫存器的最新值 */
	reg [`RegBus] LO;
	
	/* 得到最新的HI、LO暫存器的值，此處要解決資料相依問題 */
	always @( * )
		begin
			if(rst == `RstEnable)
				{HI, LO} <= {`ZeroWord, `ZeroWord};
			/* 存取記憶體階段的指令要寫入HI、LO暫存器 */
			else if(mem_whilo_i == `WriteEnable)
				{HI, LO} <= {mem_hi_i, mem_lo_i};
			/* 回寫階段的指令要寫入HI、LO暫存器 */
			else if(wb_whilo_i == `WriteEnable)
				{HI, LO} <= {wb_hi_i, wb_lo_i};
			else
				{HI, LO} <= {hi_i, lo_i};
		end
	
	/* 依據aluop_i指示的運算子類型進行邏輯運算 */
	always @( * )
		begin
			if(rst == `RstEnable)
				logicout <= `ZeroWord;
			else
				begin
					case(aluop_i)
						/* 邏輯 "或" 運算 */
						`EXE_OR_OP:
							logicout <= reg1_i | reg2_i;
						/* 邏輯 "與" 運算 */
						`EXE_AND_OP:
							logicout <= reg1_i & reg2_i;
						/* 邏輯 "或非" 運算 */
						`EXE_NOR_OP:
							logicout <= ~(reg1_i | reg2_i);
						/* 邏輯 "異或" 運算 */
						`EXE_XOR_OP:
							logicout <= reg1_i ^ reg2_i;
						default:
							logicout <= `ZeroWord;
					endcase
				end /* if rst */
		end /* always */
		
	/* 依據aluop_i指示的運算子類型進行移位運算 */
	always @( * )
		begin
			if(rst == `RstEnable)
				shiftres <= `ZeroWord;
			else
				begin
					case(aluop_i)
						/* 邏輯左移 */
						`EXE_SLL_OP:
							shiftres <= reg2_i << reg1_i[4:0];
						/* 邏輯右移 */
						`EXE_SRL_OP:
							shiftres <= reg2_i >> reg1_i[4:0];
						/* 算術右移 */
						`EXE_SRA_OP:
							shiftres <= ({32{reg2_i[31]}} << (6'd32 - {1'b0, reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
						default:
							shiftres <= `ZeroWord;
					endcase
				end /* if rst */
		end /* always */
	
	/* MFHI、MFLO、MOVN、MOVZ指令 */
	always @( * )
		begin
			if(rst == `RstEnable)
				moveres <= `ZeroWord;
			else
				begin
					moveres <= `ZeroWord;
					
					case(aluop_i)
						/* 如果是mfhi指令，那麼將HI的值作為移動操作的結果 */
						`EXE_MFHI_OP:
							moveres <= HI;
						/* 如果是mflo指令，那麼將LO的值作為移動操作的結果 */
						`EXE_MFLO_OP:
							moveres <= LO;
						/* 如果是movz指令，那麼將reg1_i的值作為移動操作的結果 */
						`EXE_MOVZ_OP:
							moveres <= reg1_i;
						/* 如果是movn指令，那麼將reg1_i的值作為移動操作的結果 */
						`EXE_MOVN_OP:
							moveres <= reg1_i;
						default:
							begin
							end						
					endcase /* case aluop_i*/
				end				
		end
	
	/* 依據alusel_i指示的運算類型，選擇一個運算結果作為最終結果 */
	always @( * )
		begin
			wd_o	<= wd_i;
			wreg_o	<= wreg_i;
			
			case(alusel_i)
				/* 選擇邏輯運算結果為最終運算結果 */
				`EXE_RES_LOGIC:
					wdata_o <= logicout;
				/* 選擇移位運算結果為最終運算結果 */
				`EXE_RES_SHIFT:
					wdata_o <= shiftres;
				/* 選擇移動操作結果為最終運算結果 */
				`EXE_RES_MOVE:
					wdata_o <= moveres;
				default:
					wdata_o <= `ZeroWord;
			endcase /* case alusel_i */
		end
	
	/* 如果是MTHI、MTLO指令，那麼需要給出whilo_o、hi_o、lo_o的值 */
	always @( * )
		begin
			if(rst == `RstEnable)
				begin
					whilo_o <= `WriteDisable;
					hi_o 	<= `ZeroWord;
					lo_o	<= `ZeroWord;
				end
			else if(aluop_i == `EXE_MTHI_OP)
				begin
					whilo_o <= `WriteEnable;
					hi_o	<= reg1_i;
					lo_o	<= LO;				/* 寫入HI暫存器，所以LO保持不變 */
				end
			else if(aluop_i == `EXE_MTLO_OP)
				begin
					whilo_o <= `WriteEnable;
					hi_o	<= HI;				/* 寫入LO暫存器，所以HI保持不變 */
					lo_o	<= reg1_i;
				end
			else
				begin
					whilo_o <= `WriteDisable;
					hi_o	<= `ZeroWord;
					lo_o	<= `ZeroWord;
				end
		end	
		
endmodule
