`include "defines.v"
module line2_ex(
	input wire rst,
	input wire [`InstAddrBus] pc_i,
	output wire [`InstAddrBus] pc_o,

	input wire reg1_read_i,
	input wire reg2_read_i,
	input wire [`RegAddrBus] reg1_addr_i,
	input wire [`RegAddrBus] reg2_addr_i,
	input wire [`AluOpBus] aluop_i,
	input wire [`AluSelBus] alusel_i,
	input wire [`RegAddrBus] waddr_i,
	input wire wreg_i,
	input wire [`RegBus] imm_i,
	input wire [`RegBus] reg1_rdata_i,
	input wire [`RegBus] reg2_rdata_i,

	// input wire l1_ex_we,
	// input wire [`RegAddrBus] l1_ex_waddr,
	// input wire [`RegBus] l1_ex_wdata,

	output reg [`RegAddrBus] waddr_o,
	output reg wreg_o,
	output reg [`RegBus] wdata_o
);
	wire [`RegBus] reg1_i;
	wire [`RegBus] reg2_i;

	// assign reg1_i = (reg1_addr_i == l1_ex_waddr) && (l1_ex_we == `WriteEnable) ? l1_ex_wdata : reg1_read_i ? reg1_rdata_i : imm_i;
	// assign reg2_i = (reg2_addr_i == l1_ex_waddr) && (l1_ex_we == `WriteEnable) ? l1_ex_wdata : reg2_read_i ? reg2_rdata_i : imm_i;

	assign reg1_i = reg1_read_i ? reg1_rdata_i : imm_i;
	assign reg2_i = reg2_read_i ? reg2_rdata_i : imm_i;
	reg [`RegBus] logic_o;
	reg [`RegBus] shift_o;
	reg [`RegBus] move_o;
	reg [`RegBus] HI;
	reg [`RegBus] LO;
	reg [`RegBus] arithmetic_o;
	reg [`DoubleRegBus] result_mul; // 保存乘法结果，宽度64bit

	assign pc_o = pc_i;
// arithmetic_o

	wire reg1_eq_reg2; // 第一个操作数是否等于第二个操作数 
	wire reg1_lt_reg2; // 第一个操作数是否小于第二个操作数
	wire [`RegBus] reg2_i_mux; // 保存输入的第二个操作数的补码
	wire [`RegBus] reg1_i_not; // 保存输入的第一个操作数取反后的值
	wire [`RegBus] result_sum; // 保存加法结果
	assign reg2_i_mux = ((aluop_i == `SUB) || (aluop_i == `SUBU) || (aluop_i == `SLT) || (aluop_i == `SLTI)) ? (~reg2_i)+1 : reg2_i;
	assign result_sum = reg1_i + reg2_i_mux;
	assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31] && result_sum[31]) || (reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));
	assign reg1_lt_reg2 = ((aluop_i == `SLT) || (aluop_i == `SLTI)) ? 
							((reg1_i[31] && !reg2_i[31]) || 
							(!reg1_i[31] && !reg2_i[31] && result_sum[31]) || 
							(reg1_i[31] && reg2_i[31] && result_sum[31])) : (reg1_i < reg2_i);
	assign reg1_i_not = ~reg1_i;

	always @ (*) begin
		if (rst == `RstEnable) begin
			arithmetic_o <= `ZeroWord;
		end
		else begin
			case (aluop_i)
				`ADD,`ADDU,`ADDI,`ADDIU:begin
					arithmetic_o <= result_sum;
				end
				`SUB,`SUBU:begin
					arithmetic_o <= result_sum;
				end
				`SLT,`SLTI,`SLTU,`SLTIU:begin
					arithmetic_o <= reg1_lt_reg2;
				end
				default:begin
					arithmetic_o <= `ZeroWord;
				end
			endcase
		end
	end

// result_mul
	always @ (*) begin
		if (rst == `RstEnable) begin
			result_mul <= {`ZeroWord,`ZeroWord};
		end
		else begin
		case (aluop_i)
			`MUL:begin
				result_mul <= $signed(reg1_i) * $signed(reg2_i);
			end
			`MULT:begin
				result_mul <= $signed(reg1_i) * $signed(reg2_i);
			end
			`MULTU:begin
				result_mul <= $unsigned(reg1_i) * $unsigned(reg2_i);
			end
			default:begin
				result_mul <= {`ZeroWord,`ZeroWord};
			end
		endcase
		end
	end // always 

// logic_o
	always @ (*) begin
		if (rst == `RstEnable) begin
			logic_o <= `ZeroWord;
		end
		else begin
			case (aluop_i)
				`OR,`ORI:begin
					logic_o <= reg1_i | reg2_i;
				end // OR
				`AND,`ANDI:begin
					logic_o <= reg1_i & reg2_i;
				end // AND
				`NOR:begin
					logic_o <= ~(reg1_i | reg2_i);
				end
				`XOR,`XORI:begin
					logic_o <= reg1_i ^ reg2_i;
				end
				`LUI:begin
					logic_o <= reg1_i;
				end
				default:begin
					logic_o <= `ZeroWord;
				end // default
			endcase
		end // if
	end //always

// shift_o
	always @ (*) begin
		if (rst == `RstEnable) begin
			shift_o <= `ZeroWord;
		end
		else begin
			case (aluop_i)
				`SLLV:begin
					shift_o <= reg2_i << reg1_i[4:0];
				end
				`SLL:begin
					shift_o <= reg2_i << reg1_i;
				end
				`SRAV:begin
					shift_o <= ({32{reg2_i[31]}} << (6'd32 - {1'b0, reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
				end
				`SRA:begin
					shift_o <= ({32{reg2_i[31]}} << (6'd32 - {1'b0, reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
				end
				`SRLV:begin
					shift_o <= reg2_i >> reg1_i[4:0];
				end
				`SRL:begin
					shift_o <= reg2_i >> reg1_i;
				end
				default:begin
					shift_o <= `ZeroWord;
				end
			endcase
		end
	end

// wdata_o & ovassert
	always @ (*) begin
		waddr_o <= waddr_i;
		wreg_o <= wreg_i;
		case (alusel_i)
			`EXE_LOGIC:begin
				wdata_o <= logic_o;
			end // EXE_LOGIC
			`EXE_SHIFT:begin
				wdata_o <= shift_o;
			end // EXE_SHIFT
			`EXE_ARITHMETIC:begin
				wdata_o <= arithmetic_o;
			end
			`EXE_MUL:begin
				wdata_o <= result_mul[31:0];
			end
			default:begin
				wdata_o <= `ZeroWord;
			end
		endcase
	end // always
endmodule