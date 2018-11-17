`include "defines.v"

/* 依據運算類型、運算子類型、來源運算元1、來源運算元2、要寫入的目的暫存器位址來進行運算 */
module ex(rst, alusel_i, aluop_i, reg1_i, reg2_i, wd_i, wreg_i, wd_o, wreg_o, wdata_o);

	input wire 							rst;				/* 重設訊號 */
	
	/* 解碼階段送到執行階段的資訊 */
	input wire [`AluOpBus]				aluop_i;			/* 執行階段要進行的運算的子類型 */
	input wire [`AluSelBus]	 			alusel_i;			/* 執行階段要進行的運算的類型 */
	input wire [`RegBus]				reg1_i;				/* 參與運算的來源運算元1 */
	input wire [`RegBus]				reg2_i;				/* 參與運算的來源運算元2 */
	input wire [`RegAddrBus] 			wd_i;				/* 指令執行要寫入的目的暫存器位址 */
	input wire							wreg_i;				/* 是否有要寫入的目的暫存器 */
	
	/* 執行的結果 */
	output reg [`RegAddrBus] 			wd_o;				/* 執行階段的指令最終要寫入的目的暫存器位址 */
	output reg 							wreg_o;				/* 執行階段的指令最終是否有要寫入的目的暫存器 */
	output reg [`RegBus]				wdata_o;			/* 執行階段的指令最終要寫入目的暫存器的值 */
	
	/* 保存邏輯運算結果 */
	reg [`RegBus] logicout;	
	
	/* 保存移位運算結果 */
	reg [`RegBus] shiftres;
	
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
	
	/* 依據alusel_i指示的運算類型，選擇一個運算結果作為最終結果 */
	always @( * )
		begin
			wd_o		<= wd_i;
			wreg_o	<= wreg_i;
			
			case(alusel_i)
				/* 選擇邏輯運算結果為最終運算結果 */
				`EXE_RES_LOGIC:
					wdata_o <= logicout;
				/* 選擇移位運算結果為最終運算結果 */
				`EXE_RES_SHIFT:
					wdata_o <= shiftres;
				default:
					wdata_o <= `ZeroWord;
			endcase
		end
		
endmodule
