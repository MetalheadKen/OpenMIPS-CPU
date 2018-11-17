`include "defines.v"

/* 由於ori指令不需要存取資料記憶體，所以在存取記憶體階段不做任何事，只是簡單地將執行階段的結果向回寫階段傳遞 */
module mem(rst, wd_i, wreg_i, wdata_i, hi_i, lo_i, whilo_i, aluop_i, mem_addr_i, reg2_i, mem_data_i,
		   wd_o, wreg_o, wdata_o, hi_o, lo_o, whilo_o, mem_addr_o, mem_we_o, mem_sel_o, mem_data_o, mem_ce_o);

	input wire 							rst;				/* 重設訊號 */
	
	/* 來自執行階段的資訊 */
	input wire [`RegAddrBus]			wd_i;				/* 存取記憶體階段的指令要寫入的目的暫存器位址 */
	input wire					 		wreg_i;				/* 存取記憶體階段的指令是否有要寫入的目的暫存器 */
	input wire [`RegBus]				wdata_i;			/* 存取記憶體階段的指令要寫入目的暫存器的值*/
	input wire [`RegBus]				hi_i;				/* 存取記憶體階段的指令要寫入HI暫存器的值 */
	input wire [`RegBus]				lo_i;				/* 存取記憶體階段的指令要寫入LO暫存器的值 */
	input wire							whilo_i;			/* 存取記憶體階段的指令是否要寫入HI、LO暫存器 */
	
	/* 新增的介面，來自執行階段的資訊 */
	input wire [`AluOpBus]				aluop_i;			/* 存取記憶體階段的指令要進行運算的子類型 */
	input wire [`RegBus]				mem_addr_i;			/* 存取記憶體階段的載入、儲存指令對應的記憶體位址 */
	input wire [`RegBus]				reg2_i;				/* 存取記憶體階段的儲存指令否儲存的資料，或者lwl、lwr指令要寫入的目的暫存器的原始值 */
	
	/* 來自外部資料記憶體RAM的資訊 */
	input wire [`RegBus]				mem_data_i;			/* 從資料記憶體讀取的資料 */
	
	/* 存取記憶體階段的結果 */
	output reg [`RegAddrBus]			wd_o;				/* 存取記憶體階段的指令最終要寫入的目的暫存器位址 */
	output reg 							wreg_o;				/* 存取記憶體階段的指令最終是否有要寫入的目的暫存器 */
	output reg [`RegBus]				wdata_o;			/* 存取記憶體階段的指令最終要寫入目的暫存器的值 */
	output reg [`RegBus]				hi_o;				/* 存取記憶體階段的指令最終要寫入HI暫存器的值 */
	output reg [`RegBus]				lo_o;				/* 存取記憶體階段的指令最終要寫入LO暫存器的值 */
	output reg							whilo_o;			/* 存取記憶體階段的指令最終是否要寫入HI、LO暫存器 */
	
	/* 送到外部資料記憶體RAM的資訊 */
	output reg [`RegBus]				mem_addr_o;			/* 要存取的資料記憶體的位址 */
	output wire							mem_we_o;			/* 是否是寫入操作，為1表示是寫入操作 */
	output reg [3:0]					mem_sel_o;			/* 位元組選擇訊號 */
	output reg [`RegBus]				mem_data_o;			/* 要寫入資料記憶體的資料 */
	output reg							mem_ce_o;			/* 資料記憶體啟用訊號 */
	
	wire [`RegBus] zero32;
	reg			   mem_we;
	
	assign mem_we_o = mem_we;		/* 外部資料記憶體RAM的讀取、寫入訊號 */
	assign zero32	= `ZeroWord;
	
	always @(*)
		begin
			if(rst == `RstEnable)
				begin
					wd_o		<=	`NOPRegAddr;
					wreg_o 		<=	`WriteDisable;
					wdata_o		<=	`ZeroWord;
					hi_o		<=	`ZeroWord;
					lo_o		<=	`ZeroWord;
					whilo_o		<=	`WriteDisable;
					mem_addr_o	<=	`ZeroWord;
					mem_we		<=	`WriteDisable;
					mem_sel_o	<=	4'b0000;
					mem_data_o	<=	`ZeroWord;
					mem_ce_o	<=	`ChipDisable;
				end
			else
				begin
					wd_o		<=	wd_i;
					wreg_o 		<=	wreg_i;
					wdata_o		<=	wdata_i;
					hi_o		<=	hi_i;
					lo_o		<=	lo_i;
					whilo_o		<=	whilo_i;
					mem_we		<=	`WriteDisable;
					mem_addr_o	<=	`ZeroWord;
					mem_sel_o	<=	4'b1111;
					mem_ce_o	<=	`ChipDisable;
					
					case(aluop_i)
						/* lb指令 */
						`EXE_LB_OP:
							begin
								mem_addr_o	<=	mem_addr_i;
								mem_we		<=	`WriteDisable;
								mem_ce_o	<=	`ChipEnable;
								
								case(mem_addr_i[1:0])
									2'b00:
										begin
											wdata_o		<=	{{24{mem_data_i[31]}}, mem_data_i[31:24]};
											mem_sel_o	<=	4'b1000;
										end
									2'b01:
										begin
											wdata_o		<=	{{24{mem_data_i[23]}}, mem_data_i[23:16]};
											mem_sel_o	<=	4'b0100;
										end
									2'b10:
										begin
											wdata_o		<=	{{24{mem_data_i[15]}}, mem_data_i[15:8]};
											mem_sel_o	<=	4'b0010;
										end
									2'b11:
										begin
											wdata_o		<=	{{24{mem_data_i[7]}}, mem_data_i[7:0]};
											mem_sel_o	<=	4'b0001;
										end
									default:
										begin
											wdata_o		<=	`ZeroWord;
										end
								endcase
							end
						/* lbu指令 */
						`EXE_LBU_OP:
							begin
								mem_addr_o	<=	mem_addr_i;
								mem_we		<=	`WriteDisable;
								mem_ce_o	<=	`ChipEnable;
								
								case(mem_addr_i[1:0])
									2'b00:
										begin
											wdata_o		<=	{{24{1'b0}}, mem_data_i[31:24]};
											mem_sel_o	<=	4'b1000;
										end
									2'b01:
										begin
											wdata_o		<=	{{24{1'b0}}, mem_data_i[23:16]};
											mem_sel_o	<=	4'b0100;
										end
									2'b10:
										begin
											wdata_o		<=	{{24{1'b0}}, mem_data_i[15:8]};
											mem_sel_o	<=	4'b0010;
										end
									2'b11:
										begin
											wdata_o		<=	{{24{1'b0}}, mem_data_i[7:0]};
											mem_sel_o	<=	4'b0001;
										end
									default:
										begin
											wdata_o		<=	`ZeroWord;
										end
								endcase
							end
						/* lh指令 */
						`EXE_LH_OP:
							begin
								mem_addr_o	<=	mem_addr_i;
								mem_we		<=	`WriteDisable;
								mem_ce_o	<=	`ChipEnable;
								
								case(mem_addr_i[1:0])
									2'b00:
										begin
											wdata_o		<=	{{16{mem_data_i[31]}}, mem_data_i[31:16]};
											mem_sel_o	<=	4'b1100;
										end
									2'b10:
										begin
											wdata_o		<=	{{16{mem_data_i[15]}}, mem_data_i[15:0]};
											mem_sel_o	<=	4'b0011;
										end
									default:
										begin
											wdata_o		<=	`ZeroWord;
										end
								endcase
							end
						/* lhu指令 */
						`EXE_LHU_OP:
							begin
								mem_addr_o	<=	mem_addr_i;
								mem_we		<=	`WriteDisable;
								mem_ce_o	<=	`ChipEnable;
								
								case(mem_addr_i[1:0])
									2'b00:
										begin
											wdata_o		<=	{{16{1'b0}}, mem_data_i[31:16]};
											mem_sel_o	<=	4'b1100;
										end
									2'b10:
										begin
											wdata_o		<=	{{16{1'b0}}, mem_data_i[15:0]};
											mem_sel_o	<=	4'b0011;
										end
									default:
										begin
											wdata_o		<=	`ZeroWord;
										end
								endcase
							end
						/* lw指令 */
						`EXE_LW_OP:
							begin
								mem_addr_o	<=	mem_addr_i;
								mem_we		<=	`WriteDisable;
								wdata_o		<=	mem_data_i;
								mem_sel_o	<=	4'b1111;
								mem_ce_o	<=	`ChipEnable;
							end
						/* lwl指令 */
						`EXE_LWL_OP:
							begin
								mem_addr_o	<=	{mem_addr_i[31:2], 2'b00};
								mem_we		<=	`WriteDisable;
								mem_sel_o	<=	4'b1111;
								mem_ce_o	<=	`ChipEnable;
								
								case(mem_addr_i[1:0])
									2'b00:
										begin
											wdata_o	<=	mem_data_i[31:0];
										end
									2'b01:
										begin
											wdata_o	<=	{mem_data_i[23:0], reg2_i[7:0]};
										end
									2'b10:
										begin
											wdata_o	<=	{mem_data_i[15:0], reg2_i[15:0]};
										end
									2'b11:
										begin
											wdata_o	<=	{mem_data_i[7:0], reg2_i[23:0]};
										end
									default:
										begin
											wdata_o	<=	`ZeroWord;
										end
								endcase
							end
						/* lwr指令 */
						`EXE_LWR_OP:
							begin
								mem_addr_o	<=	{mem_addr_i[31:2], 2'b00};
								mem_we		<=	`WriteDisable;
								mem_sel_o	<=	4'b1111;
								mem_ce_o	<=	`ChipEnable;
								
								case(mem_addr_i[1:0])
									2'b00:
										begin
											wdata_o	<=	{reg2_i[31:8], mem_data_i[31:24]};
										end
									2'b01:
										begin
											wdata_o	<=	{reg2_i[31:16], mem_data_i[31:16]};
										end
									2'b10:
										begin
											wdata_o	<=	{reg2_i[31:24], mem_data_i[31:8]};
										end
									2'b11:
										begin
											wdata_o	<=	mem_data_i;
										end
									default:
										begin
											wdata_o	<=	`ZeroWord;
										end
								endcase
							end
						/* sb指令 */
						`EXE_SB_OP:
							begin
								mem_addr_o	<=	mem_addr_i;
								mem_we		<=	`WriteEnable;
								mem_data_o	<=	{reg2_i[7:0], reg2_i[7:0], reg2_i[7:0], reg2_i[7:0]};
								mem_ce_o	<=	`ChipEnable;
								
								case(mem_addr_i[1:0])
									2'b00:
										begin
											mem_sel_o	<=	4'b1000;
										end
									2'b01:
										begin
											mem_sel_o	<=	4'b0100;
										end
									2'b10:
										begin
											mem_sel_o	<=	4'b0010;
										end
									2'b11:
										begin
											mem_sel_o	<=	4'b0001;
										end
									default:
										begin
											mem_sel_o	<=	4'b0000;
										end
								endcase
							end
						/* sh指令 */
						`EXE_SH_OP:
							begin
								mem_addr_o	<=	mem_addr_i;
								mem_we		<=	`WriteEnable;
								mem_data_o	<=	{reg2_i[15:0], reg2_i[15:0]};
								mem_ce_o	<=	`ChipEnable;
								
								case(mem_addr_i[1:0])
									2'b00:
										begin
											mem_sel_o	<=	4'b1100;
										end
									2'b10:
										begin
											mem_sel_o	<=	4'b0011;
										end
									default:
										begin
											mem_sel_o	<=	4'b0000;
										end
								endcase
							end
						/* sw指令 */
						`EXE_SW_OP:
							begin
								mem_addr_o	<=	mem_addr_i;
								mem_we		<=	`WriteEnable;
								mem_data_o	<=	reg2_i;
								mem_sel_o	<=	4'b1111;
								mem_ce_o	<=	`ChipEnable;
							end
						/* swl指令 */
						`EXE_SWL_OP:
							begin
								mem_addr_o	<=	{mem_addr_i[31:2], 2'b00};
								mem_we		<=	`WriteEnable;
								mem_ce_o	<=	`ChipEnable;
								
								case(mem_addr_i[1:0])
									2'b00:
										begin
											mem_sel_o	<=	4'b1111;
											mem_data_o	<=	reg2_i;
										end
									2'b01:
										begin
											mem_sel_o	<=	4'b0111;
											mem_data_o	<=	{zero32[7:0], reg2_i[31:8]};
										end
									2'b10:
										begin
											mem_sel_o	<=	4'b0011;
											mem_data_o	<=	{zero32[15:0], zero32[31:16]};
										end
									2'b11:
										begin
											mem_sel_o	<=	4'b0001;
											mem_data_o	<=	{zero32[31:0], reg2_i[31:24]};
										end
									default:
										begin
											mem_sel_o	<=	4'b0000;
										end
								endcase
							end
						/* swr指令 */
						`EXE_SWR_OP:
							begin
								mem_addr_o	<=	{mem_addr_i[31:2], 2'b00};
								mem_we		<=	`WriteEnable;
								mem_ce_o	<=	`ChipEnable;
								
								case(mem_addr_i[1:0])
									2'b00:
										begin
											mem_sel_o	<=	4'b1000;
											mem_data_o	<=	{reg2_i[7:0], zero32[23:0]};
										end
									2'b01:
										begin
											mem_sel_o	<=	4'b1100;
											mem_data_o	<=	{reg2_i[15:0], zero32[15:0]};
										end
									2'b10:
										begin
											mem_sel_o	<=	4'b1110;
											mem_data_o	<=	{reg2_i[23:0], zero32[7:0]};
										end
									2'b11:
										begin
											mem_sel_o	<=	4'b1111;
											mem_data_o	<=	reg2_i[31:0];
										end
									default:
										begin
											mem_sel_o	<=	4'b0000;
										end
								endcase
							end
						default:
							begin
							end
					endcase /* case by aluop_i */
				end
		end
		
endmodule
