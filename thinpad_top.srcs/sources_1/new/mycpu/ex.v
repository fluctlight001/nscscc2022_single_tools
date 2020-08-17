`include "defines.v"
module ex(
	input wire rst,
	output reg stallreq,

	input wire [`InstAddrBus] pc_i,
	output wire [`InstAddrBus] pc_o,
	input wire [`RegBus] inst_i,

	input wire [`AluOpBus] aluop_i,
	input wire [`AluSelBus] alusel_i,
	input wire [`RegBus] reg1_i,
	input wire [`RegBus] reg2_i,
	input wire [`RegAddrBus] waddr_i,
	input wire wreg_i,

	output reg [`RegAddrBus] waddr_o,
	output reg wreg_o,
	output reg [`RegBus] wdata_o,

	// hilo
	input wire [`RegBus] hi_i,
	input wire [`RegBus] lo_i,

	input wire [`RegBus] wb_hi_i,
	input wire [`RegBus] wb_lo_i,
	input wire           wb_whilo_i,

	input wire [`RegBus] mem_hi_i,
	input wire [`RegBus] mem_lo_i,
	input wire           mem_whilo_i,

	input wire [`RegBus] dcache_hi_i,
	input wire [`RegBus] dcache_lo_i,
	input wire           dcache_whilo_i,

	// input wire [`RegBus] premem_hi_i,
	// input wire [`RegBus] premem_lo_i,
	// input wire           premem_whilo_i,

	output reg [`RegBus] hi_o,
	output reg [`RegBus] lo_o,
	output reg           whilo_o,

// // MUL
//  input wire [`DoubleRegBus] result_mul,
//  input wire result_is_ok,

//  output reg [`RegBus] mul_opdata1_o,
//  output reg [`RegBus] mul_opdata2_o,
//  output reg mul_start_o,
//  output reg signed_mul_o,

// DIV
	input wire [`DoubleRegBus] div_result_i,
	input wire div_ready_i,

	output reg [`RegBus] div_opdata1_o,
	output reg [`RegBus] div_opdata2_o,
	output reg div_start_o,
	output reg signed_div_o,

// jump & branch
	input wire [`RegBus] link_address_i,
	input wire is_in_delayslot_i,

// mem
	output reg [`AluOpBus] aluop_o,
	output reg [`RegBus] mem_addr_o,
	output reg [`RegBus] reg2_o,

// cp0_reg
	// premem_forwarding
	// input wire premem_cp0_reg_we,
	// input wire [4:0] premem_cp0_reg_write_addr,
	// input wire [`RegBus] premem_cp0_reg_data,
	// dcache_forwarding
	input wire dcache_cp0_reg_we,
	input wire [4:0] dcache_cp0_reg_write_addr,
	input wire [`RegBus] dcache_cp0_reg_data,
	// mem_forwarding
	input wire mem_cp0_reg_we,
	input wire [4:0] mem_cp0_reg_write_addr,
	input wire [`RegBus] mem_cp0_reg_data,
	// // wb_forwarding
	// input wire wb_cp0_reg_we,
	// input wire [4:0] wb_cp0_reg_write_addr,
	// input wire [`RegBus] wb_cp0_reg_data,
	// with cp0
	input wire [`RegBus] cp0_reg_data_i,
	output reg [4:0] cp0_reg_read_addr_o,
	// out
	output reg cp0_reg_we_o,
	output reg [4:0] cp0_reg_write_addr_o,
	output reg [`RegBus] cp0_reg_data_o,

// excepttype
	input wire [31:0] excepttype_i,
	output wire [31:0] excepttype_o,
	output wire is_in_delayslot_o,
	output wire [`RegBus] badvaddr_o
);
	assign pc_o = pc_i;
	reg [`RegBus] logic_o;
	reg [`RegBus] shift_o;
	reg [`RegBus] move_o;
	reg [`RegBus] HI;
	reg [`RegBus] LO;
	reg [`RegBus] arithmetic_o;

	wire ov_sum; // 保存溢出情况
	wire reg1_eq_reg2; // 第一个操作数是否等于第二个操作数 
	wire reg1_lt_reg2; // 第一个操作数是否小于第二个操作数
	wire [`RegBus] reg2_i_mux; // 保存输入的第二个操作数的补码
	wire [`RegBus] reg1_i_not; // 保存输入的第一个操作数取反后的值
	wire [`RegBus] result_sum; // 保存加法结果
	// wire [`RegBus] opdata1_mult; // 被乘数
	// wire [`RegBus] opdata2_mult; // 乘数
	// wire [`DoubleRegBus] hilo_temp; // 临时保存乘法结果，宽度64bit
	reg [`DoubleRegBus] result_mul; // 保存乘法结果，宽度64bit
	reg stallreq_for_div; // 是否由于除法运算导致流水线暂停
	reg stallreq_for_mul; // 是否由于乘法运算导致流水线暂停

	reg trapassert;
	reg ovassert;
	reg loadassert;
	reg storeassert;

	assign excepttype_o = {excepttype_i[31:16],loadassert,storeassert,excepttype_i[13:12],ovassert,trapassert,excepttype_i[9:8],8'b0};
	assign is_in_delayslot_o = is_in_delayslot_i;

// arithmetic_o
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

// trapassert
	always @ (*) begin
		if (rst == `RstEnable) begin
			trapassert <= `TrapNotAssert;
		end
		else begin
			trapassert <= `TrapNotAssert;
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

// DIV
	always @ (*) begin
		if (rst == `RstEnable) begin
			stallreq_for_div <= `NoStop;
			div_opdata1_o <= `ZeroWord;
			div_opdata2_o <= `ZeroWord;
			div_start_o <= `DivStop;
			signed_div_o <= 1'b0;
		end
		else begin
			stallreq_for_div <= `NoStop;
			div_opdata1_o <= `ZeroWord;
			div_opdata2_o <= `ZeroWord;
			div_start_o <= `DivStop;
			signed_div_o <= 1'b0;
			case (aluop_i)
				`DIV:begin
					if (div_ready_i == `DivResultNotReady) begin
						div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStart;
						signed_div_o <= 1'b1;
						stallreq_for_div <= `Stop;
					end
					else if (div_ready_i == `DivResultReady) begin
						div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b1;
						stallreq_for_div <= `NoStop;
					end
					else begin
						div_opdata1_o <= `ZeroWord;
						div_opdata2_o <= `ZeroWord;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b0;
						stallreq_for_div <= `NoStop;
					end
				end
				`DIVU:begin
					if (div_ready_i == `DivResultNotReady) begin
						div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStart;
						signed_div_o <= 1'b0;
						stallreq_for_div <= `Stop;
					end
					else if (div_ready_i == `DivResultReady) begin
						div_opdata1_o <= reg1_i;
						div_opdata2_o <= reg2_i;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b0;
						stallreq_for_div <= `NoStop;
					end
					else begin
						div_opdata1_o <= `ZeroWord;
						div_opdata2_o <= `ZeroWord;
						div_start_o <= `DivStop;
						signed_div_o <= 1'b0;
						stallreq_for_div <= `NoStop;
					end
				end
				default:begin
				end
			endcase
		end
	end

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

// HI LO
	always @ (*) begin
		if (rst == `RstEnable) begin
			{HI,LO} <= {`ZeroWord,`ZeroWord};
		end
		// else if (premem_whilo_i == `WriteEnable) begin
		//   {HI,LO} <= {premem_hi_i,premem_lo_i};
		// end
		else if (dcache_whilo_i == `WriteEnable) begin
			{HI,LO} <= {dcache_hi_i,dcache_lo_i};
		end
		else if (mem_whilo_i == `WriteEnable) begin
			{HI,LO} <= {mem_hi_i,mem_lo_i};
		end  
		else if (wb_whilo_i == `WriteEnable) begin
			{HI,LO} <= {wb_hi_i,wb_lo_i};
		end
		else begin
			{HI,LO} <= {hi_i,lo_i};
		end
	end // always

// move_o
	always @ (*) begin
		if (rst == `RstEnable) begin
			move_o <= `ZeroWord;
			cp0_reg_read_addr_o <= 5'b00000;
			cp0_reg_write_addr_o <= 5'b00000;
			cp0_reg_we_o <= `WriteDisable;
			cp0_reg_data_o <= `ZeroWord;
		end  
		else begin
			move_o <= `ZeroWord;
			cp0_reg_read_addr_o <= 5'b00000;
			cp0_reg_write_addr_o <= 5'b00000;
			cp0_reg_we_o <= `WriteDisable;
			cp0_reg_data_o <= `ZeroWord;
			case (aluop_i)
				`MFHI:begin
					move_o <= HI;
				end
				`MFLO:begin
					move_o <= LO;
				end
				`MFC0:begin
					cp0_reg_read_addr_o <= inst_i[15:11];
					if (dcache_cp0_reg_we == `WriteEnable && dcache_cp0_reg_write_addr == inst_i[15:1]) begin
						move_o <= dcache_cp0_reg_data;
					end
					else if (mem_cp0_reg_we == `WriteEnable && mem_cp0_reg_write_addr == inst_i[15:11]) begin
						move_o <= mem_cp0_reg_data;
					end
					else begin
						move_o <= cp0_reg_data_i;
					end
					// else if (wb_cp0_reg_we == `WriteEnable && wb_cp0_reg_write_addr == inst_i[15:11]) begin
					//   move_o <= wb_cp0_reg_data;
					// end
				end
				`MTC0:begin // wreg == `writedisable 所以没输出也没事
					cp0_reg_write_addr_o <= inst_i[15:11];
					cp0_reg_we_o <= `WriteEnable;
					cp0_reg_data_o <= reg1_i;
					move_o <= `ZeroWord; // 避免锁存器产生
				end
				default:begin
					move_o <= `ZeroWord;
					cp0_reg_read_addr_o <= 5'b00000;
					cp0_reg_write_addr_o <= 5'b00000;
					cp0_reg_we_o <= `WriteDisable;
					cp0_reg_data_o <= `ZeroWord;
				end
			endcase
		end
	end // always

// MTHI MTLO
	always @ (*) begin
		if (rst == `RstEnable) begin
			whilo_o <= `WriteDisable;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;
		end
		else begin
			case (aluop_i)
				`MULT,`MULTU:begin
					whilo_o <= `WriteEnable;
					hi_o <= result_mul[63:32];
					lo_o <= result_mul[31: 0];
				end
				`DIV,`DIVU:begin
					whilo_o <= `WriteEnable;
					hi_o <= div_result_i[63:32];
					lo_o <= div_result_i[31: 0];
				end
				`MTHI:begin
					whilo_o <= `WriteEnable;
					hi_o <= reg1_i;
					lo_o <= LO;
				end
				`MTLO:begin
					whilo_o <= `WriteEnable;
					hi_o <= HI;
					lo_o <= reg1_i;
				end
				default:begin
					whilo_o <= `WriteDisable;
					hi_o <= `ZeroWord;
					lo_o <= `ZeroWord;
				end
			endcase
		end
	end // always

// wdata_o & ovassert
	always @ (*) begin
		waddr_o <= waddr_i;
		if (((aluop_i == `ADD) || (aluop_i == `ADDI) || (aluop_i == `SUB)) && (ov_sum == 1'b1)) begin
			wreg_o <= `WriteDisable;
			ovassert <= `True_v;
		end
		else begin
			wreg_o <= wreg_i;  
			ovassert <= `False_v;
		end
		case (alusel_i)
			`EXE_LOGIC:begin
				wdata_o <= logic_o;
			end // EXE_LOGIC
			`EXE_SHIFT:begin
				wdata_o <= shift_o;
			end // EXE_SHIFT
			`EXE_MOVE:begin
				wdata_o <= move_o;
			end
			`EXE_ARITHMETIC:begin
				wdata_o <= arithmetic_o;
			end
			`EXE_MUL:begin
				wdata_o <= result_mul[31:0];
			end
			`EXE_JUMP_BRANCH:begin
				wdata_o <= link_address_i;
			end
			default:begin
				wdata_o <= `ZeroWord;
			end
		endcase
	end // always
	
// loadassert & storeassert
	// assign aluop_o = aluop_i;
	// assign mem_addr_o = reg1_i + {{16{inst_i[15]}},inst_i[15:0]};
	// assign reg2_o = reg2_i;
	wire [`RegBus] mem_addr;
	assign mem_addr = reg1_i + {{16{inst_i[15]}},inst_i[15:0]};
	always @ (*) begin
		aluop_o <= aluop_i;
		mem_addr_o <= mem_addr;
		reg2_o <= reg2_i;
		loadassert <= `False_v;
		storeassert <= `False_v;
		if (((aluop_i == `LH || aluop_i == `LHU) && (mem_addr[0] != 1'b0)) || ((aluop_i == `LW) && (mem_addr[1:0] != 2'b00))) begin
				 aluop_o <=`NOP;
				 mem_addr_o <= `ZeroWord;
				 reg2_o <= `ZeroWord;
				 loadassert <= `True_v;
		end 
		else if (((aluop_i == `SH) && (mem_addr[0] != 1'b0)) || ((aluop_i == `SW) && (mem_addr[1:0] != 2'b00))) begin
				 aluop_o <=`NOP;
				 mem_addr_o <= `ZeroWord;
				 reg2_o <= `ZeroWord;
				 storeassert <= `True_v;
		 end
	end
	assign badvaddr_o = reg1_i + {{16{inst_i[15]}},inst_i[15:0]};

// stallreq
	always @ (*) begin
		if (rst == `RstEnable) begin
			stallreq <= `NoStop;
		end
		else begin
			stallreq <= stallreq_for_div;
		end
	end
endmodule 