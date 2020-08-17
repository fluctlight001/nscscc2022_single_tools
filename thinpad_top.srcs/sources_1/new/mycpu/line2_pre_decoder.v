`include "defines.v"
module line2_pre_decoder(
  input wire rst,
  // output wire stallreq,
  input wire [`InstAddrBus] pc_i,
  input wire [`InstBus] inst_i,
  output wire [`InstAddrBus] pc_o,
  // output wire [`InstBus] inst_o, 

  output reg reg1_read_o, // reg1 read enable
  output reg reg2_read_o, // reg2 read enable
  output reg [`RegAddrBus] reg1_addr_o, // reg1 read addr
  output reg [`RegAddrBus] reg2_addr_o, // reg2 read addr

  // input wire [`RegBus] reg1_data_i, // reg1 data from rf 
  // input wire [`RegBus] reg2_data_i, // reg2 data from rf

  output reg [`AluOpBus] aluop_o, // 需要运行的指令代码
  output reg [`AluSelBus] alusel_o, // 需要运行的指令的类型
  // output reg [`RegBus] reg1_o, // 指令需要的源操作数1
  // output reg [`RegBus] reg2_o, // 指令需要的源操作数2
  output reg [`RegAddrBus] waddr_o, //指令需要写入的目的寄存器地址
  output reg wreg_o, // 指令是否需要写入寄存器

// jump and branch
  // input wire is_in_delayslot_i,
  // output reg next_inst_in_delayslot_o,
  // output reg branch_flag_o,
  // output reg [`RegBus] branch_target_address_o,
  // output reg [`RegBus] link_addr_o,
  // output reg is_in_delayslot_o,

// load 相关
  // input wire [`RegAddrBus] ex_waddr_i,
  // input wire [`AluOpBus] ex_aluop_i,
  // input wire [`RegBus] ex_mem_addr_i,
  // // input wire [`RegAddrBus] premem_waddr_i,
  // // input wire [`AluOpBus] premem_aluop_i,
  // input wire [`RegAddrBus] dcache_waddr_i,
  // input wire [`AluOpBus] dcache_aluop_i,
  // input wire [`RegBus] dcache_wdata_i,

// excepttype
  // input wire [31:0] excepttype_i,
  // output wire [31:0] excepttype_o
  output reg [`RegBus] imm_o, // imm_o - 32bit  imm - 16bit 记得补充完整
  output reg l1_run,
  output reg l2_run
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

  
  reg instvalid;

// jump and branch
  // wire [`RegBus] pc_plus_8;
  // wire [`RegBus] pc_plus_4;
  // wire [`RegBus] imm_sll2_signedext;
  // assign pc_plus_8 = pc_i + 8;
  // assign pc_plus_4 = pc_i + 4;
  // assign imm_sll2_signedext = {{14{inst_i[15]}},inst_i[15:0],2'b00};

// pc & inst
  assign pc_o = pc_i;
  // assign inst_o = inst_i;

// excepttype
  // reg excepttype_is_syscall;
  // reg excepttype_is_eret;
  // reg excepttype_is_break;
  // assign excepttype_o = {15'b0,excepttype_i[16],2'b0,excepttype_is_break,excepttype_is_eret,2'b00,instvalid,excepttype_is_syscall,8'b0};
  
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
      // excepttype_is_break <= `False_v;
      // excepttype_is_syscall <= `False_v;
      // excepttype_is_eret <= `False_v;
      instvalid <= `InstValid; // 可能是为了避免异常触发，所以这里用的是valid
      // stallreq <= `NoStop;

      // link_addr_o <= `ZeroWord;
      // branch_target_address_o <= `ZeroWord;
      // branch_flag_o <= `NotBranch;
      // next_inst_in_delayslot_o <= `NotInDelaySlot;
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
      // excepttype_is_break <= `False_v;
      // excepttype_is_syscall <= `False_v;
      // excepttype_is_eret <= `False_v;
      instvalid <= `InstInvalid; // 默认可能找不到这个指令，于是这个指令invalid
      // stallreq <= `NoStop;

      // link_addr_o <= `ZeroWord;
      // branch_target_address_o <= `ZeroWord;
      // branch_flag_o <= `NotBranch;
      // next_inst_in_delayslot_o <= `NotInDelaySlot;
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

              // reg1_read_o <= `False_v;
              // reg2_read_o <= `False_v;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b010010:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_MOVE;
              aluop_o <= `MFLO;

              // reg1_read_o <= `False_v;
              // reg2_read_o <= `False_v;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
            end
            6'b010001:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_MOVE;
              aluop_o <= `MTHI;

              // reg1_read_o <= `True_v;
              // reg2_read_o <= `False_v;
              // reg1_addr_o <= rs;

              wreg_o <= `WriteDisable;
            end
            6'b010011:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_MOVE;
              aluop_o <= `MTLO;

              // reg1_read_o <= `True_v;
              // reg2_read_o <= `False_v;
              // reg1_addr_o <= rs;

              wreg_o <= `WriteDisable;
            end
            6'b001000:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_JUMP_BRANCH;
              aluop_o <= `JR;

              // reg1_read_o <= `True_v;
              // reg2_read_o <= `False_v;
              // reg1_addr_o <= rs;

              wreg_o <= `WriteDisable;

              // branch_target_address_o <= reg1_data_i;
              // branch_flag_o <= `Branch;
              // next_inst_in_delayslot_o <= `InDelaySlot;
            end
            6'b001001:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_JUMP_BRANCH;
              aluop_o <= `JALR;

              // reg1_read_o <= `True_v;
              // reg2_read_o <= `False_v;
              // reg1_addr_o <= rs;

              wreg_o <= `WriteEnable;
              waddr_o <= rd;
              // link_addr_o <= pc_plus_8;

              // branch_target_address_o <= reg1_data_i;
              // branch_flag_o <= `Branch;
              // next_inst_in_delayslot_o <= `InDelaySlot;
            end
            6'b001100:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_NOP;
              aluop_o <= `SYSCALL;

              // reg1_read_o <= `False_v;
              // reg2_read_o <= `False_v;

              wreg_o <= `WriteDisable;

              // excepttype_is_syscall <= `True_v;
            end
            6'b001101:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_NOP;
              aluop_o <= `BREAK ;

              // reg1_read_o <= `False_v;
              // reg2_read_o <= `False_v;

              wreg_o <= `WriteDisable;

              // excepttype_is_break <= `True_v;
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

          // reg1_read_o <= `True_v;
          // reg2_read_o <= `True_v;
          // reg1_addr_o <= rs;
          // reg2_addr_o <= rt;
          
          // if (reg1_data_i == reg2_data_i) begin
          //   branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
          //   branch_flag_o <= `Branch;
          // end
          // next_inst_in_delayslot_o <= `InDelaySlot;
        end
        6'b000101:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_JUMP_BRANCH;
          aluop_o <= `BNE;

          // reg1_read_o <= `True_v;
          // reg2_read_o <= `True_v;
          // reg1_addr_o <= rs;
          // reg2_addr_o <= rt;

          // if (reg1_data_i != reg2_data_i) begin
          //   branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
          //   branch_flag_o <= `Branch;
          // end
          // next_inst_in_delayslot_o <= `InDelaySlot;
        end
        6'b000001:begin
          case (rt)
            5'b00001:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_JUMP_BRANCH;
              aluop_o <= `BGEZ;

              // reg1_read_o <= `True_v;
              // reg2_read_o <= `False_v;
              // reg1_addr_o <= rs;

              // if (reg1_data_i[31] == 1'b0 || reg1_data_i == `ZeroWord) begin
              //   branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
              //   branch_flag_o <= `Branch; 
              // end
              // next_inst_in_delayslot_o <= `InDelaySlot;
            end
            5'b00000:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_JUMP_BRANCH;
              aluop_o <= `BLTZ;

              // reg1_read_o <= `True_v;
              // reg2_read_o <= `False_v;
              // reg1_addr_o <= rs;

              // if (reg1_data_i[31] == 1'b1) begin
              //   branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
              //   branch_flag_o <= `Branch;
              // end
              // next_inst_in_delayslot_o <= `InDelaySlot;
            end
            5'b10001:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_JUMP_BRANCH;
              aluop_o <= `BGEZAL;

              // reg1_read_o <= `True_v;
              // reg2_read_o <= `False_v;
              // reg1_addr_o <= rs;

              wreg_o <= `WriteEnable;
              waddr_o <= 5'd31;
              // link_addr_o <= pc_plus_8;

              // if (reg1_data_i[31] == 1'b0) begin
              //   branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
              //   branch_flag_o <= `Branch;
              // end
              // next_inst_in_delayslot_o <= `InDelaySlot;
            end
            5'b10000:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_JUMP_BRANCH;
              aluop_o <= `BLTZAL;

              // reg1_read_o <= `True_v;
              // reg2_read_o <= `False_v;
              // reg1_addr_o <= rs;

              wreg_o <= `WriteEnable;
              waddr_o <= 5'd31;
              // link_addr_o <= pc_plus_8;

              // if (reg1_data_i[31] == 1'b1) begin
              //   branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
              //   branch_flag_o <= `Branch;
              // end
              // next_inst_in_delayslot_o <= `InDelaySlot;
            end
          endcase
        end
        6'b000111:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_JUMP_BRANCH;
          aluop_o <= `BGTZ;

          // reg1_read_o <= `True_v;
          // reg2_read_o <= `False_v;
          // reg1_addr_o <= rs;
          
          // if (reg1_data_i[31] == 1'b0 && reg1_data_i != `ZeroWord) begin
          //   branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
          //   branch_flag_o <= `Branch;
          // end
          // next_inst_in_delayslot_o <= `InDelaySlot;
        end
        6'b000110:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_JUMP_BRANCH;
          aluop_o <= `BLEZ;

          // reg1_read_o <= `True_v;
          // reg2_read_o <= `False_v;
          // reg1_addr_o <= rs;

          // if (reg1_data_i[31] == 1'b1 || reg1_data_i == `ZeroWord) begin
          //   branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
          //   branch_flag_o <= `Branch;
          // end
          // next_inst_in_delayslot_o <= `InDelaySlot;
        end
        6'b000010:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_JUMP_BRANCH;
          aluop_o <= `J;

          // reg1_read_o <= `False_v;
          // reg2_read_o <= `False_v;

          // branch_target_address_o <= {pc_plus_4[31:28],instr_index,2'b0};
          // branch_flag_o <= `Branch;
          // next_inst_in_delayslot_o <= `InDelaySlot;
        end
        6'b000011:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_JUMP_BRANCH;
          aluop_o <= `JAL;

          // reg1_read_o <= `False_v;
          // reg2_read_o <= `False_v;

          wreg_o <= `WriteEnable;
          waddr_o <= 5'd31;
          // link_addr_o <= pc_plus_8;

          // branch_target_address_o <= {pc_plus_4[31:28],instr_index,2'b0};
          // branch_flag_o <= `Branch;
          // next_inst_in_delayslot_o <= `InDelaySlot;
        end
        6'b100000:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOAD_STORE;
          aluop_o <= `LB;

          // reg1_read_o <= `True_v;
          // reg2_read_o <= `False_v;
          // reg1_addr_o <= base;

          wreg_o <= `WriteEnable;
          waddr_o <= rt;
        end
        6'b100100:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOAD_STORE;
          aluop_o <= `LBU;

          // reg1_read_o <= `True_v;
          // reg2_read_o <= `False_v;
          // reg1_addr_o <= base;

          wreg_o <= `WriteEnable;
          waddr_o <= rt;
        end
        6'b100001:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOAD_STORE;
          aluop_o <= `LH;

          // reg1_read_o <= `True_v;
          // reg2_read_o <= `False_v;
          // reg1_addr_o <= base;

          wreg_o <= `WriteEnable;
          waddr_o <= rt;
        end
        6'b100101:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOAD_STORE;
          aluop_o <= `LHU;

          // reg1_read_o <= `True_v;
          // reg2_read_o <= `False_v;
          // reg1_addr_o <= base;
          
          wreg_o <= `WriteEnable;
          waddr_o <= rt;
        end
        6'b100011:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOAD_STORE;
          aluop_o <= `LW;

          // reg1_read_o <= `True_v;
          // reg2_read_o <= `False_v;
          // reg1_addr_o <= base;
          
          wreg_o <= `WriteEnable;
          waddr_o <= rt;
        end
        6'b101000:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOAD_STORE;
          aluop_o <= `SB;

          // reg1_read_o <= `True_v;
          // reg2_read_o <= `True_v;
          // reg1_addr_o <= base;
          // reg2_addr_o <= rt;

          wreg_o <= `WriteDisable;
        end
        6'b101001:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOAD_STORE;
          aluop_o <= `SH;

          // reg1_read_o <= `True_v;
          // reg2_read_o <= `True_v;
          // reg1_addr_o <= base;
          // reg2_addr_o <= rt;

          wreg_o <= `WriteDisable;
        end
        6'b101011:begin
          instvalid <= `InstValid;
          alusel_o <= `EXE_LOAD_STORE;
          aluop_o <= `SW;

          // reg1_read_o <= `True_v;
          // reg2_read_o <= `True_v;
          // reg1_addr_o <= base;
          // reg2_addr_o <= rt;

          wreg_o <= `WriteDisable;
        end
        6'b010000:begin
          case (rs)
            5'b00000:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_MOVE;
              aluop_o <= `MFC0;

              // reg1_read_o <= `False_v;
              // reg2_read_o <= `False_v;

              wreg_o <= `WriteEnable;
              waddr_o <= rt;
            end
            5'b00100:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_MOVE;
              aluop_o <= `MTC0;

              // reg1_read_o <= `True_v;
              // reg2_read_o <= `False_v;
              // reg1_addr_o <= rt;

              wreg_o <= `WriteDisable;
            end
            5'b10000:begin
              instvalid <= `InstValid;
              alusel_o <= `EXE_NOP;
              aluop_o <= `ERET;

              // reg1_read_o <= `False_v;
              // reg2_read_o <= `False_v;

              wreg_o <= `WriteDisable;
              // excepttype_is_eret <= `True_v;
            end
          endcase
        end
        default:begin
          
        end
      endcase // opcode
    end
  end


// pc ctrl
  always @ (*) begin // 从l1来判断l2是否适合运行，不代表l1跑了没
    if (rst == `RstEnable) begin
      l1_run <= `False_v;
    end
    else begin
      case (alusel_o)
        `EXE_JUMP_BRANCH:l1_run <= `False_v;
        default:l1_run <= `True_v;
      endcase
    end
  end

  always @ (*) begin
    if (rst == `RstEnable) begin
      l2_run <= `False_v;
    end
    else begin
      case (alusel_o)
        `EXE_NOP,`EXE_LOGIC,`EXE_SHIFT,`EXE_ARITHMETIC,`EXE_MUL:l2_run <= `True_v;
        `EXE_MOVE,`EXE_JUMP_BRANCH,`EXE_LOAD_STORE:l2_run <= `False_v;
        default:l2_run <= `False_v;
      endcase
    end
  end

endmodule