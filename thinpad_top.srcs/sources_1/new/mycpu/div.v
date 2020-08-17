`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/25 13:51:28
// Design Name: 
// Module Name: div
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module div(
	input wire rst,							//复位
	input wire clk,							//时钟
	input wire signed_div_i,						//是否为有符号除法运算，1位有符号
	input wire[`RegBus] opdata1_i,				//被除数
	input wire[`RegBus] opdata2_i,				//除数
	input wire start_i,						//是否开始除法运算
	input wire annul_i,						//是否取消除法运算，1位取消
	output reg[`DoubleRegBus] result_o,		//除法运算结果
	output reg ready_o		//除法运算是否结束
	
);
	
	wire [32:0] div_temp;
	reg [5:0] cnt;							//记录试商法进行了几轮
	reg[64:0] dividend;						//低32位保存除数、中间结果，第k次迭代结束的时候dividend[k:0]保存的就是当前得到的中间结果，
											//dividend[31:k+1]保存的是被除数没有参与运算的部分，dividend[63:32]是每次迭代时的被减数
	reg [1:0] state;						//除法器处于的状态	
	reg[31:0] divisor;
	reg[31:0] temp_op1;
	reg[31:0] temp_op2;
	
	assign div_temp = {1'b0, dividend[63: 32]} - {1'b0, divisor};
	
	
	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			state <= `DivFree;
			result_o <= {`ZeroWord,`ZeroWord};
			ready_o <= `DivResultNotReady;
		end else begin
			case(state)
			
				`DivFree: begin			//除法器空闲
					if (start_i == `DivStart && annul_i == 1'b0) begin
						if(opdata2_i == `ZeroWord) begin			//如果除数为0
							state <= `DivByZero;
						end else begin
							state <= `DivOn;					//除数不为0
							cnt <= 6'b000000;
							if(signed_div_i == 1'b1 && opdata1_i[31] == 1'b1) begin			//被除数为负数
								temp_op1 = ~opdata1_i + 1;
							end else begin
								temp_op1 = opdata1_i;
							end
							if (signed_div_i == 1'b1 && opdata2_i[31] == 1'b1 ) begin			//除数为负数
								temp_op2 = ~opdata2_i + 1;
							end else begin
								temp_op2 = opdata2_i;
							end
							dividend <= {`ZeroWord, `ZeroWord};
							dividend[32: 1] <= temp_op1;
							divisor <= temp_op2;
						end
					end else begin
						ready_o <= `DivResultNotReady;
						result_o <= {`ZeroWord, `ZeroWord};
					end
				end
				
				`DivByZero: begin			//除数为0
					dividend <= {`ZeroWord, `ZeroWord};
					state <= `DivEnd;
				end
				
				`DivOn: begin				//除数不为0
					if(annul_i == 1'b0) begin			//进行除法运算
						if(cnt != 6'b100000) begin
							if (div_temp[32] == 1'b1) begin
								dividend <= {dividend[63:0],1'b0};
							end else begin
								dividend <= {div_temp[31:0],dividend[31:0], 1'b1};
							end
							cnt <= cnt +1;		//除法运算次数
						end	else begin
							if ((signed_div_i == 1'b1) && ((opdata1_i[31] ^ opdata2_i[31]) == 1'b1)) begin
								dividend[31:0] <= (~dividend[31:0] + 1);
							end
							if ((signed_div_i == 1'b1) && ((opdata1_i[31] ^ dividend[64]) == 1'b1)) begin
								dividend[64:33] <= (~dividend[64:33] + 1);
							end
							state <= `DivEnd;
							cnt <= 6'b000000;
						end
					end else begin	
						state <= `DivFree;
					end
				end
				
				`DivEnd: begin			//除法结束
					result_o <= {dividend[64:33], dividend[31:0]};
					ready_o <= `DivResultReady;
					if (start_i == `DivStop) begin
						state <= `DivFree;
						ready_o <= `DivResultNotReady;
						result_o <= {`ZeroWord, `ZeroWord};
					end
				end
				
			endcase
		end
	end


endmodule