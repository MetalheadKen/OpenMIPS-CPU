`include "defines.v"

/* 為了實現ll、sc指令，新增了一個LLbit暫存器，其中儲存的就是連結狀態位元 */
module cp0_reg(clk, rst, we_i, waddr_i, raddr_i, data_i, int_i,
			   data_o, count_o, compare_o, status_o, cause_o, epc_o, config_o, prid_o, timer_int_o);

	input wire					clk;					/* 時脈訊號 */
	input wire 					rst;					/* 重設訊號 */
	
	/* 來自EX的資訊 */
	input wire [4:0]			raddr_i;				/* 要讀取的CP0中暫存器的位址 */
	
	/* 來自MEM/WB的資訊 */
	input wire					we_i;					/* 是否要寫入CP0中的暫存器 */
	input wire [4:0]			waddr_i;				/* 要寫入的CP0中暫存器的位址 */
	input wire [`RegBus]		data_i;					/* 要寫入的CP0中暫存器的資料 */
	
	/* OpenMIPS其中之一的輸入介面 */
	input wire [5:0]			int_i;					/* 6個外部硬體中斷輸入 */
	
	output reg [`RegBus]		data_o;					/* 讀出的CP0中某個暫存器的值 */
	output reg [`RegBus]		count_o;				/* Count暫存器的值 */
	output reg [`RegBus]		compare_o;				/* Compare暫存器的值 */			
	output reg [`RegBus]		status_o;				/* Status暫存器的值 */
	output reg [`RegBus]		cause_o;				/* Cause暫存器的值 */
	output reg [`RegBus]		epc_o;					/* EPC暫存器的值 */
	output reg [`RegBus]		config_o;				/* Config暫存器的值 */
	output reg [`RegBus]		prid_o;					/* PRId暫存器的值 */
	
	/* OpenMIPS其中之一的輸出介面 */
	output reg					timer_int_o;			/* 是否有定時中斷發生 */
	
	/* 對CP0中暫存器的寫入操作 */
	always @(posedge clk)
		begin
			if(rst == `RstEnable)
				begin
					/* Count暫存器的初始值，為0 */
					count_o		<=	`ZeroWord;
					/* Compare暫存器的初始值，為0 */
					compare_o	<=	`ZeroWord;
					/* Status暫存器的初始值，其中CU的欄位為4'b0001，表示協同處理器CP0存在 */
					status_o	<=	32'b00010000000000000000000000000000;
					/* Cause暫存器的初始值 */
					cause_o		<=	`ZeroWord;
					/* EPC暫存器的初始值 */
					epc_o		<=	`ZeroWord;
					/* Config暫存器的初始值，其中BE欄位為1，表示工作在Big-Endian模式（MSB） */
					config_o	<=	32'b00000000000000001000000000000000;
					/* PRId暫存器的初始值，其中製作者是L，對應的是0x48（自行定義的），
					** 類型是0X1，表示是基本類型，版本編號是1.0*/
					prid_o		<=	32'b00000000010011000000000100000010;
					timer_int_o	<=	`InterruptNotAssert;
				end
			else
				begin
					count_o			<=	count_o + 1;
					cause_o[15:10]	<=	int_i;
					
					/* 當Compare暫存器不為0，且Count暫存器的值等於Compare暫存器的值時，
					** 將輸出訊號timer_int_o設定為1，表示時脈中斷產生 */
					if(compare_o != `ZeroWord && count_o == compare_o)
						timer_int_o	<=	`InterruptAssert;
					
					if(we_i == `WriteEnable)
						begin
							case(waddr_i)
								/* 寫入Count暫存器 */
								`CP0_REG_COUNT:
									begin
										count_o			<=	data_i;
									end
								/* 寫入Compare暫存器 */
								`CP0_REG_COMPARE:
									begin
										compare_o		<=	data_i;
										timer_int_o		<=	`InterruptNotAssert;
									end
								/* 寫入Status暫存器 */
								`CP0_REG_STATUS:
									begin
										status_o		<=	data_i;
									end
								/* 寫入EPC暫存器 */
								`CP0_REG_EPC:
									begin
										epc_o			<=	data_i;
									end
								/* 寫入Cause暫存器 */
								`CP0_REG_CAUSE:
									begin
										/* Cause暫存器只有IP[1:0]、IV、WP欄位是可寫入的 */
										cause_o[9:8]	<=	data_i[9:8];
										cause_o[23]		<=	data_i[23];
										cause_o[22]		<=	data_i[22];
									end
							endcase
						end
				end
		end
	
	/* 對CP0中暫存器的讀取操作，此處是組合電路 */
	always @( * )
		begin
			if(rst == `RstEnable)
				data_o	<=	`ZeroWord;
			else
				begin
					case(raddr_i)
						/* 讀取Count暫存器 */
						`CP0_REG_COUNT:
							data_o	<=	count_o;
							
						/* 讀取Compare暫存器 */
						`CP0_REG_COMPARE:
							data_o	<=	compare_o;
							
						/* 讀取Status暫存器 */
						`CP0_REG_STATUS:
							data_o	<=	status_o;
							
						/* 讀取Cause暫存器 */
						`CP0_REG_CAUSE:
							data_o	<=	cause_o;
							
						/* 讀取EPC暫存器 */
						`CP0_REG_EPC:
							data_o	<=	epc_o;
							
						/* 讀取PRId暫存器 */
						`CP0_REG_PRId:
							data_o	<=	prid_o;
							
						/* 讀取Config暫存器 */
						`CP0_REG_CONFIG:
							data_o	<=	config_o;
						
						default:
							begin
							end							
					endcase
				end
		end
		
endmodule
