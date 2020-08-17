`include "defines.v"
module decoder(
  input wire rst,
  output wire stallreq,
  input wire [`InstAddrBus] pc_i,
  input wire [`InstBus] inst_i,
  output wire [`InstAddrBus] pc_o,
  output wire [`InstBus] inst_o,

  output reg reg1_read_o, // reg1 read enable
  output reg reg2_read_o, // reg2 read enable
  output reg [`RegAddrBus] reg1_addr_o, // reg1 read addr
  output reg [`RegAddrBus] reg2_addr_o, // reg2 read addr

  input wire [`RegBus] reg1_data_i, // reg1 data from rf 
  input wire [`RegBus] reg2_data_i, // reg2 data from rf

  output reg [`AluOpBus] aluop_o, // 需要运行的指令代码
  output reg [`AluSelBus] alusel_o, // 需要运行的指令的类型
  output reg [`RegBus] reg1_o, // 指令需要的源操作数1
  output reg [`RegBus] reg2_o, // 指令需要的源操作数2
  output reg [`RegAddrBus] waddr_o, //指令需要写入的目的寄存器地址
  output reg wreg_o, // 指令是否需要写入寄存器

// jump and branch
  input wire is_in_delayslot_i,
  output reg next_inst_in_delayslot_o,
  output reg branch_flag_o,
  output reg [`RegBus] branch_target_address_o,
  output reg [`RegBus] link_addr_o,
  output reg is_in_delayslot_o,

// load 相关
  input wire [`RegAddrBus] ex_waddr_i,
  input wire [`AluOpBus] ex_aluop_i,
  input wire [`RegBus] ex_mem_addr_i,
  // input wire [`RegAddrBus] premem_waddr_i,
  // input wire [`AluOpBus] premem_aluop_i,
  input wire [`RegAddrBus] dcache_waddr_i,
  input wire [`AluOpBus] dcache_aluop_i,
  input wire [`RegBus] dcache_wdata_i,

// excepttype
  input wire [31:0] excepttype_i,
  output wire [31:0] excepttype_o
);
  wire [5:0] opcode;
  wire [4:0] rs;
  wire [4:0] rt;
  wire [4:0] rd;
  wire [4:0] sa;
  wire [5:0] func;
  wire [15:0] imm;
  wire [25:0] instr_index;
  wire [19:0] code;
  wire [4:0] base;
  wire [15:0] offset;
  wire [2:0] sel;

  assign opcode = inst_i[31:26];
  assign rs = inst_i[25:21];
  assign rt = inst_i[20:16];
  assign rd = inst_i[15:11];
  assign sa = inst_i[10: 6];
  assign func = inst_i[5:0];
  assign imm = inst_i[15:0];
  assign instr_index = inst_i[25:0];
  assign code = inst_i[25:6];
  assign base = inst_i[25:21];
  assign offset = inst_i[15:0];
  assign sel = inst_i[2:0];

  reg [`RegBus] imm_o; // imm_o - 32bit  imm - 16bit 记得补充完整
  reg instvalid;

// jump and branch
  wire [`RegBus] pc_plus_8;
  wire [`RegBus] pc_plus_4;
  wire [`RegBus] imm_sll2_signedext;
  assign pc_plus_8 = pc_i + 8;
  assign pc_plus_4 = pc_i + 4;
  assign imm_sll2_signedext = {{14{inst_i[15]}},inst_i[15:0],2'b00};

// pc & inst
  assign pc_o = pc_i;
  assign inst_o = inst_i;

// excepttype
  reg excepttype_is_syscall;
  reg excepttype_is_eret;
  reg excepttype_is_break;
  assign excepttype_o = {15'b0,excepttype_i[16],2'b0,excepttype_is_break,excepttype_is_eret,2'b00,instvalid,excepttype_is_syscall,8'b0};
  
// decoder
  always @ (*) begin
    if (rst == `RstEnable) begin
      reg1_read_o <= `False_v;
      reg2_read_o <= `False_v;
      reg1_addr_o <= `NOPRegAddr;
      reg2_addr_o <= `NOPRegAddr;
      aluop_o <= `NOP;
      alusel_o <= `EXE_NOP;
      waddr_o <= `NOPRegAddr;
      wreg_o <= `WriteDisable;
      imm_o <= `ZeroWord;
      excepttype_is_break <= `False_v;
      excepttype_is_syscall <= `False_v;
      excepttype_is_eret <= `False_v;
      instvalid <= `InstValid; // 可能是为了避免异常触发，所以这里用的是valid
      // stallreq <= `NoStop;

      link_addr_o <= `ZeroWord;
      branch_target_address_o <= `ZeroWord;
      branch_flag_o <= `NotBranch;
      next_inst_in_delayslot_o <= `NotInDelaySlot;
    end
    else begin
      //统一赋值区域
      reg1_read_o <= `False_v;
      reg2_read_o <= `False_v;
      reg1_addr_o <= rs;
      reg2_addr_o <= rt;
      aluop_o <= `NOP;
      alusel_o <= `EXE_NOP;
      waddr_o <= rd;
      wreg_o <= `WriteDisable;
      imm_o <= `ZeroWord;
      excepttype_is_break <= `False_v;
      excepttype_is_syscall <= `False_v;
      excepttype_is_eret <= `False_v;
      instvalid <= `InstInvalid; // 默认可能找不到这个指令，于是这个指令invalid
      // stallreq <= `NoStop;

      link_addr_o <= `ZeroWord;
      branch_target_address_o <= `ZeroWord;
      branch_flag_o <= `NotBranch;
      next_inst_in_delayslot_o <= `NotInDelaySlot;
      //统一赋值区域
      case (opcode)
        6'b000000:begin
          case (func)
            6'b100000:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_ARITHMETIC;
              aluop_o <= `ADD;

              reg1_read_o <= `True_v;
              reg2_read_o <= `True_v;
              reg1_addr_o <= rs;
              reg2_addr_o <= rt;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b100001:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_ARITHMETIC;
              aluop_o <= `ADDU;

              reg1_read_o <= `True_v;
              reg2_read_o <= `True_v;
              reg1_addr_o <= rs;
              reg2_addr_o <= rt;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b100010:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_ARITHMETIC;
              aluop_o <= `SUB;

              reg1_read_o <= `True_v;
              reg2_read_o <= `True_v;
              reg1_addr_o <= rs;
              reg2_addr_o <= rt;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b100011:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_ARITHMETIC;
              aluop_o <= `SUBU;
              
              reg1_read_o <= `True_v;
              reg2_read_o <= `True_v;
              reg1_addr_o <= rs;
              reg2_addr_o <= rt;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b101010:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_ARITHMETIC;
              aluop_o <= `SLT;

              reg1_read_o <= `True_v;
              reg2_read_o <= `True_v;
              reg1_addr_o <= rs;
              reg2_addr_o <= rt;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b101011:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_ARITHMETIC;
              aluop_o <= `SLTU;

              reg1_read_o <= `True_v;
              reg2_read_o <= `True_v;
              reg1_addr_o <= rs;
              reg2_addr_o <= rt;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b011010:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_NOP;
              aluop_o <= `DIV;

              reg1_read_o <= `True_v;
              reg2_read_o <= `True_v;
              reg1_addr_o <= rs;
              reg2_addr_o <= rt;

              wreg_o <= `WriteDisable;
            end
            6'b011011:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_NOP;
              aluop_o <= `DIVU;

              reg1_read_o <= `True_v;
              reg2_read_o <= `True_v;
              reg1_addr_o <= rs;
              reg2_addr_o <= rt;

              wreg_o <= `WriteDisable;
            end
            6'b011000:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_ARITHMETIC;
              aluop_o <= `MULT;

              reg1_read_o <= `True_v;
              reg2_read_o <= `True_v;
              reg1_addr_o <= rs;
              reg2_addr_o <= rt;

              wreg_o <= `WriteDisable;
            end
            6'b011001:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_ARITHMETIC;
              aluop_o <= `MULTU;

              reg1_read_o <= `True_v;
              reg2_read_o <= `True_v;
              reg1_addr_o <= rs;
              reg2_addr_o <= rt;

              wreg_o <= `WriteDisable;
            end
            6'b100100:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_LOGIC;
              aluop_o <= `AND;

              reg1_read_o <= `True_v;
              reg2_read_o <= `True_v;
              reg1_addr_o <= rs;
              reg2_addr_o <= rt;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b100111:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_LOGIC;
              aluop_o <= `NOR;

              reg1_read_o <= `True_v;
              reg2_read_o <= `True_v;
              reg1_addr_o <= rs;
              reg2_addr_o <= rt;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b100101:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_LOGIC;
              aluop_o <= `OR;

              reg1_read_o <= `True_v;
              reg2_read_o <= `True_v;
              reg1_addr_o <= rs;
              reg2_addr_o <= rt;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b100110:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_LOGIC;
              aluop_o <= `XOR;

              reg1_read_o <= `True_v;
              reg2_read_o <= `True_v;
              reg1_addr_o <= rs;
              reg2_addr_o <= rt;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b000100:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_SHIFT;
              aluop_o <= `SLLV;

              reg1_read_o <= `True_v;
              reg2_read_o <= `True_v;
              reg1_addr_o <= rs;
              reg2_addr_o <= rt;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b000000:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_SHIFT;
              aluop_o <= `SLL;

              reg1_read_o <= `False_v;
              reg2_read_o <= `True_v;
              imm_o <= {27'b0,sa};
              reg2_addr_o <= rt;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b000111:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_SHIFT;
              aluop_o <= `SRAV;

              reg1_read_o <= `True_v;
              reg2_read_o <= `True_v;
              reg1_addr_o <= rs;
              reg2_addr_o <= rt;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b000011:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_SHIFT;
              aluop_o <= `SRA;

              reg1_read_o <= `False_v;
              reg2_read_o <= `True_v;
              imm_o <= {27'b0,sa};
              reg2_addr_o <= rt;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b000110:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_SHIFT;
              aluop_o <= `SRLV;

              reg1_read_o <= `True_v;
              reg2_read_o <= `True_v;
              reg1_addr_o <= rs;
              reg2_addr_o <= rt;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b000010:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_SHIFT;
              aluop_o <= `SRL;

              reg1_read_o <= `False_v;
              reg2_read_o <= `True_v;
              imm_o <= {27'b0,sa};
              reg2_addr_o <= rt;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b010000:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_MOVE;
              aluop_o <= `MFHI;

              reg1_read_o <= `False_v;
              reg2_read_o <= `False_v;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b010010:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_MOVE;
              aluop_o <= `MFLO;

              reg1_read_o <= `False_v;
              reg2_read_o <= `False_v;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b010001:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_MOVE;
              aluop_o <= `MTHI;

              reg1_read_o <= `True_v;
              reg2_read_o <= `False_v;
              reg1_addr_o <= rs;

              wreg_o <= `WriteDisable;
            end
            6'b010011:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_MOVE;
              aluop_o <= `MTLO;

              reg1_read_o <= `True_v;
              reg2_read_o <= `False_v;
              reg1_addr_o <= rs;

              wreg_o <= `WriteDisable;
            end
            6'b001000:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_JUMP_BRANCH;
              aluop_o <= `JR;

              reg1_read_o <= `True_v;
              reg2_read_o <= `False_v;
              reg1_addr_o <= rs;

              wreg_o <= `WriteDisable;

              branch_target_address_o <= reg1_data_i;
              branch_flag_o <= `Branch;
              next_inst_in_delayslot_o <= `InDelaySlot;
            end
            6'b001001:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_JUMP_BRANCH;
              aluop_o <= `JALR;

              reg1_read_o <= `True_v;
              reg2_read_o <= `False_v;
              reg1_addr_o <= rs;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
              link_addr_o <= pc_plus_8;

              branch_target_address_o <= reg1_data_i;
              branch_flag_o <= `Branch;
              next_inst_in_delayslot_o <= `InDelaySlot;
            end
            6'b001100:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_NOP;
              aluop_o <= `SYSCALL;

              reg1_read_o <= `False_v;
              reg2_read_o <= `False_v;

              wreg_o <= `WriteDisable;

              excepttype_is_syscall <= `True_v;
            end
            6'b001101:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_NOP;
              aluop_o <= `BREAK ;

              reg1_read_o <= `False_v;
              reg2_read_o <= `False_v;

              wreg_o <= `WriteDisable;

              excepttype_is_break <= `True_v;
            end
            default:begin
              
            end
          endcase // func
        end
        6'b001000:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_ARITHMETIC;
          aluop_o <= `ADDI;

          reg1_read_o <= `True_v;
          reg2_read_o <= `False_v;
          reg1_addr_o <= rs;
          imm_o <= {{16{imm[15]}},imm};
          
          wreg_o <= `WriteEnable;
          waddr_o <= rt;
        end
        6'b001001:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_ARITHMETIC;
          aluop_o <= `ADDIU;

          reg1_read_o <= `True_v;
          reg2_read_o <= `False_v;
          reg1_addr_o <= rs;
          imm_o <= {{16{imm[15]}},imm};

          wreg_o <= `WriteEnable;
          waddr_o <= rt;
        end
        6'b011100:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_MUL;
          aluop_o <= `MUL;

          reg1_read_o <= `True_v;
          reg2_read_o <= `True_v;
          reg1_addr_o <= rs;
          reg2_addr_o <= rt;

          wreg_o <= `WriteEnable;
          waddr_o <= rd;
        end
        6'b001010:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_ARITHMETIC;
          aluop_o <= `SLTI;

          reg1_read_o <= `True_v;
          reg2_read_o <= `False_v;
          reg1_addr_o <= rs;
          imm_o <= {{16{imm[15]}},imm};

          wreg_o <= `WriteEnable;
          waddr_o <= rt;
        end
        6'b001011:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_ARITHMETIC;
          aluop_o <= `SLTIU;

          reg1_read_o <= `True_v;
          reg2_read_o <= `False_v;
          reg1_addr_o <= rs;
          imm_o <= {{16{imm[15]}},imm};

          wreg_o <= `WriteEnable;
          waddr_o <= rt;
        end
        6'b001100:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOGIC;
          aluop_o <= `ANDI;

          reg1_read_o <= `True_v;
          reg2_read_o <= `False_v;
          reg1_addr_o <= rs;
          imm_o <= {16'b0,imm};

          wreg_o <= `WriteEnable;
          waddr_o <= rt;
        end
        6'b001111:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOGIC;
          aluop_o <= `LUI;

          reg1_read_o <= `False_v;
          reg2_read_o <= `False_v;
          imm_o <= {imm,16'b0};

          wreg_o <= `WriteEnable;
          waddr_o <= rt;
        end
        6'b001101:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOGIC;
          aluop_o <= `ORI;

          reg1_read_o <= `True_v;
          reg2_read_o <= `False_v;
          reg1_addr_o <= rs;
          imm_o <= {16'b0,imm};

          wreg_o <= `WriteEnable;
          waddr_o <= rt;
        end
        6'b001110:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOGIC;
          aluop_o <= `XORI;

          reg1_read_o <= `True_v;
          reg2_read_o <= `False_v;
          reg1_addr_o <= rs;
          imm_o <= {16'b0,imm};

          wreg_o <= `WriteEnable;
          waddr_o <= rt;
        end
        6'b000100:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_JUMP_BRANCH;
          aluop_o <= `BEQ;

          reg1_read_o <= `True_v;
          reg2_read_o <= `True_v;
          reg1_addr_o <= rs;
          reg2_addr_o <= rt;
          
          if (reg1_data_i == reg2_data_i) begin
            branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
            branch_flag_o <= `Branch;
          end
          next_inst_in_delayslot_o <= `InDelaySlot;
        end
        6'b000101:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_JUMP_BRANCH;
          aluop_o <= `BNE;

          reg1_read_o <= `True_v;
          reg2_read_o <= `True_v;
          reg1_addr_o <= rs;
          reg2_addr_o <= rt;

          if (reg1_data_i != reg2_data_i) begin
            branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
            branch_flag_o <= `Branch;
          end
          next_inst_in_delayslot_o <= `InDelaySlot;
        end
        6'b000001:begin
          case (rt)
            5'b00001:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_JUMP_BRANCH;
              aluop_o <= `BGEZ;

              reg1_read_o <= `True_v;
              reg2_read_o <= `False_v;
              reg1_addr_o <= rs;

              if (reg1_data_i[31] == 1'b0 || reg1_data_i == `ZeroWord) begin
                branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                branch_flag_o <= `Branch; 
              end
              next_inst_in_delayslot_o <= `InDelaySlot;
            end
            5'b00000:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_JUMP_BRANCH;
              aluop_o <= `BLTZ;

              reg1_read_o <= `True_v;
              reg2_read_o <= `False_v;
              reg1_addr_o <= rs;

              if (reg1_data_i[31] == 1'b1) begin
                branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                branch_flag_o <= `Branch;
              end
              next_inst_in_delayslot_o <= `InDelaySlot;
            end
            5'b10001:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_JUMP_BRANCH;
              aluop_o <= `BGEZAL;

              reg1_read_o <= `True_v;
              reg2_read_o <= `False_v;
              reg1_addr_o <= rs;

              wreg_o <= `WriteEnable;
              waddr_o <= 5'd31;
              link_addr_o <= pc_plus_8;

              if (reg1_data_i[31] == 1'b0) begin
                branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                branch_flag_o <= `Branch;
              end
              next_inst_in_delayslot_o <= `InDelaySlot;
            end
            5'b10000:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_JUMP_BRANCH;
              aluop_o <= `BLTZAL;

              reg1_read_o <= `True_v;
              reg2_read_o <= `False_v;
              reg1_addr_o <= rs;

              wreg_o <= `WriteEnable;
              waddr_o <= 5'd31;
              link_addr_o <= pc_plus_8;

              if (reg1_data_i[31] == 1'b1) begin
                branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                branch_flag_o <= `Branch;
              end
              next_inst_in_delayslot_o <= `InDelaySlot;
            end
          endcase
        end
        6'b000111:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_JUMP_BRANCH;
          aluop_o <= `BGTZ;

          reg1_read_o <= `True_v;
          reg2_read_o <= `False_v;
          reg1_addr_o <= rs;
          
          if (reg1_data_i[31] == 1'b0 && reg1_data_i != `ZeroWord) begin
            branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
            branch_flag_o <= `Branch;
          end
          next_inst_in_delayslot_o <= `InDelaySlot;
        end
        6'b000110:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_JUMP_BRANCH;
          aluop_o <= `BLEZ;

          reg1_read_o <= `True_v;
          reg2_read_o <= `False_v;
          reg1_addr_o <= rs;

          if (reg1_data_i[31] == 1'b1 || reg1_data_i == `ZeroWord) begin
            branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
            branch_flag_o <= `Branch;
          end
          next_inst_in_delayslot_o <= `InDelaySlot;
        end
        6'b000010:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_JUMP_BRANCH;
          aluop_o <= `J;

          reg1_read_o <= `False_v;
          reg2_read_o <= `False_v;

          branch_target_address_o <= {pc_plus_4[31:28],instr_index,2'b0};
          branch_flag_o <= `Branch;
          next_inst_in_delayslot_o <= `InDelaySlot;
        end
        6'b000011:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_JUMP_BRANCH;
          aluop_o <= `JAL;

          reg1_read_o <= `False_v;
          reg2_read_o <= `False_v;

          wreg_o <= `WriteEnable;
          waddr_o <= 5'd31;
          link_addr_o <= pc_plus_8;

          branch_target_address_o <= {pc_plus_4[31:28],instr_index,2'b0};
          branch_flag_o <= `Branch;
          next_inst_in_delayslot_o <= `InDelaySlot;
        end
        6'b100000:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOAD_STORE;
          aluop_o <= `LB;

          reg1_read_o <= `True_v;
          reg2_read_o <= `False_v;
          reg1_addr_o <= base;

          wreg_o <= `WriteEnable;
          waddr_o <= rt;
        end
        6'b100100:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOAD_STORE;
          aluop_o <= `LBU;

          reg1_read_o <= `True_v;
          reg2_read_o <= `False_v;
          reg1_addr_o <= base;

          wreg_o <= `WriteEnable;
          waddr_o <= rt;
        end
        6'b100001:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOAD_STORE;
          aluop_o <= `LH;

          reg1_read_o <= `True_v;
          reg2_read_o <= `False_v;
          reg1_addr_o <= base;

          wreg_o <= `WriteEnable;
          waddr_o <= rt;
        end
        6'b100101:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOAD_STORE;
          aluop_o <= `LHU;

          reg1_read_o <= `True_v;
          reg2_read_o <= `False_v;
          reg1_addr_o <= base;
          
          wreg_o <= `WriteEnable;
          waddr_o <= rt;
        end
        6'b100011:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOAD_STORE;
          aluop_o <= `LW;

          reg1_read_o <= `True_v;
          reg2_read_o <= `False_v;
          reg1_addr_o <= base;
          
          wreg_o <= `WriteEnable;
          waddr_o <= rt;
        end
        6'b101000:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOAD_STORE;
          aluop_o <= `SB;

          reg1_read_o <= `True_v;
          reg2_read_o <= `True_v;
          reg1_addr_o <= base;
          reg2_addr_o <= rt;

          wreg_o <= `WriteDisable;
        end
        6'b101001:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOAD_STORE;
          aluop_o <= `SH;

          reg1_read_o <= `True_v;
          reg2_read_o <= `True_v;
          reg1_addr_o <= base;
          reg2_addr_o <= rt;

          wreg_o <= `WriteDisable;
        end
        6'b101011:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOAD_STORE;
          aluop_o <= `SW;

          reg1_read_o <= `True_v;
          reg2_read_o <= `True_v;
          reg1_addr_o <= base;
          reg2_addr_o <= rt;

          wreg_o <= `WriteDisable;
        end
        6'b010000:begin
          case (rs)
            5'b00000:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_MOVE;
              aluop_o <= `MFC0;

              reg1_read_o <= `False_v;
              reg2_read_o <= `False_v;

              wreg_o <= `WriteEnable;
              waddr_o <= rt;
            end
            5'b00100:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_MOVE;
              aluop_o <= `MTC0;

              reg1_read_o <= `True_v;
              reg2_read_o <= `False_v;
              reg1_addr_o <= rt;

              wreg_o <= `WriteDisable;
            end
            5'b10000:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_NOP;
              aluop_o <= `ERET;

              reg1_read_o <= `False_v;
              reg2_read_o <= `False_v;

              wreg_o <= `WriteDisable;
              excepttype_is_eret <= `True_v;
            end
          endcase
        end
        default:begin
          
        end
      endcase // opcode
    end
  end

// load 相关
  reg stallreq_for_reg1_loadrelate;
  reg stallreq_for_reg2_loadrelate;
  wire ex_inst_is_load;
  wire premem_inst_is_load;
  wire dcache_inst_is_load;
  assign ex_inst_is_load = ((ex_aluop_i == `LB) ||
                            (ex_aluop_i == `LBU) ||
                            (ex_aluop_i == `LH) ||
                            (ex_aluop_i == `LHU) ||
                            (ex_aluop_i == `LW)) ? `True_v : `False_v;
  // assign premem_inst_is_load = ((premem_aluop_i == `LB) ||
  //                               (premem_aluop_i == `LBU) ||
  //                               (premem_aluop_i == `LH) ||
  //                               (premem_aluop_i == `LHU) ||
  //                               (premem_aluop_i == `LW)) ? `True_v : `False_v;
  assign dcache_inst_is_load = ((dcache_aluop_i == `LB) ||
                                (dcache_aluop_i == `LBU) ||
                                (dcache_aluop_i == `LH) ||
                                (dcache_aluop_i == `LHU) ||
                                (dcache_aluop_i == `LW)) ? `True_v : `False_v;
  assign stallreq = stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate;

// reg1 read
  always @ (*) begin
    if (rst == `RstEnable) begin
      reg1_o <= `ZeroWord;
      stallreq_for_reg1_loadrelate <= `NoStop;
    end
    else if (ex_inst_is_load && ex_mem_addr_i >= 32'h80000000 && ex_mem_addr_i <= 32'h803fffff) begin //|| premem_inst_is_load || dcache_inst_is_load
      reg1_o <= `ZeroWord;
      stallreq_for_reg1_loadrelate <= `Stop;
    end
    else if (ex_inst_is_load == `True_v && ex_waddr_i == reg1_addr_o && reg1_read_o == `True_v) begin
      reg1_o <= `ZeroWord;
      stallreq_for_reg1_loadrelate <= `Stop;
    end
    // else if (premem_inst_is_load == `True_v && premem_waddr_i == reg1_addr_o && reg1_read_o == `True_v) begin
    //   reg1_o <= `ZeroWord;
    //   stallreq_for_reg1_loadrelate <= `Stop;
    // end
    else if (dcache_inst_is_load == `True_v && dcache_waddr_i == reg1_addr_o && reg1_read_o == `True_v && alusel_o == `EXE_JUMP_BRANCH) begin
      reg1_o <= `ZeroWord;
      stallreq_for_reg1_loadrelate <= `Stop;
    end
    else if (dcache_inst_is_load == `True_v && dcache_waddr_i == reg1_addr_o && reg1_read_o == `True_v) begin
      reg1_o <= dcache_wdata_i;
      stallreq_for_reg1_loadrelate <= `NoStop;
    end
    else if (reg1_read_o == `True_v) begin
      reg1_o <= reg1_data_i;
      stallreq_for_reg1_loadrelate <= `NoStop;
    end
    else if (reg1_read_o == `False_v) begin
      reg1_o <= imm_o;
      stallreq_for_reg1_loadrelate <= `NoStop;
    end
    else begin
      reg1_o <= `ZeroWord;
      stallreq_for_reg1_loadrelate <= `NoStop;
    end
  end

// reg2 read
  always @ (*) begin
    if (rst == `RstEnable) begin
      reg2_o <= `ZeroWord;
      stallreq_for_reg2_loadrelate <= `NoStop;
    end
    else if (ex_inst_is_load && ex_mem_addr_i >= 32'h80000000 && ex_mem_addr_i <= 32'h803fffff) begin // || premem_inst_is_load || dcache_inst_is_load
      reg2_o <= `ZeroWord;
      stallreq_for_reg2_loadrelate <= `Stop;
    end
    else if (ex_inst_is_load == `True_v && ex_waddr_i == reg2_addr_o && reg2_read_o == `True_v) begin
      reg2_o <= `ZeroWord;
      stallreq_for_reg2_loadrelate <= `Stop;
    end
    // else if (premem_inst_is_load == `True_v && premem_waddr_i == reg2_addr_o && reg2_read_o == `True_v) begin
    //   reg2_o <= `ZeroWord;
    //   stallreq_for_reg2_loadrelate <= `Stop;
    // end
    else if (dcache_inst_is_load == `True_v && dcache_waddr_i == reg2_addr_o && reg2_read_o == `True_v && alusel_o == `EXE_JUMP_BRANCH) begin
      reg2_o <= `ZeroWord;
      stallreq_for_reg2_loadrelate <= `Stop;
    end
    else if (dcache_inst_is_load == `True_v && dcache_waddr_i == reg2_addr_o && reg2_read_o == `True_v) begin
      reg2_o <= dcache_wdata_i;
      stallreq_for_reg2_loadrelate <= `NoStop;
    end
    else if (reg2_read_o == `True_v) begin
      reg2_o <= reg2_data_i;
      stallreq_for_reg2_loadrelate <= `NoStop;
    end
    else if (reg2_read_o == `False_v) begin
      reg2_o <= imm_o;
      stallreq_for_reg2_loadrelate <= `NoStop;
    end
    else begin
      reg2_o <= `ZeroWord;
      stallreq_for_reg2_loadrelate <= `NoStop;
    end
  end

// 延迟槽判断
  always @ (*) begin
    if (rst == `RstEnable) begin
      is_in_delayslot_o <= `NotInDelaySlot;
    end
    else begin
      is_in_delayslot_o <= is_in_delayslot_i;
    end
  end


endmodule