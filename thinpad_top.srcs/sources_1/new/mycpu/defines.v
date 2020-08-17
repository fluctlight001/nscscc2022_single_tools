//inside_op 处理器内部指令识别编码
// arithmetic 算术
`define ADD   6'd0
`define ADDI  6'd1
`define ADDU  6'd2
`define ADDIU 6'd3
`define SUB   6'd4
`define SUBU  6'd5
`define SLT   6'd6
`define SLTI  6'd7
`define SLTU  6'd8
`define SLTIU 6'd9

// div 除法（通过hilo寄存器输出数据）
`define DIV   6'd10
`define DIVU  6'd11

// mul 乘法
`define MULT  6'd12
`define MULTU 6'd13

// logic 逻辑
`define AND   6'd14
`define ANDI  6'd15
`define LUI   6'd16
`define NOR   6'd17
`define OR    6'd18
`define ORI   6'd19
`define XOR   6'd20
`define XORI  6'd21

// shift 移位
`define SLLV  6'd22
`define SLL   6'd23
`define SRAV  6'd24
`define SRA   6'd25
`define SRLV  6'd26
`define SRL   6'd27

// branch & jump 分支跳转
`define BEQ   6'd28
`define BNE   6'd29
`define BGEZ  6'd30
`define BGTZ  6'd31
`define BLEZ  6'd32
`define BLTZ  6'd33
`define BGEZAL  6'd34
`define BLTZAL  6'd35
`define J     6'd36
`define JAL   6'd37
`define JR    6'd38
`define JALR  6'd39

// move 数据移动
`define MFHI  6'd40
`define MFLO  6'd41
`define MTHI  6'd42
`define MTLO  6'd43

// 自陷指令
`define BREAK 6'd44
`define SYSCALL 6'd45

// load & store 访存
`define LB    6'd46
`define LBU   6'd47
`define LH    6'd48
`define LHU   6'd49
`define LW    6'd50
`define SB    6'd51
`define SH    6'd52
`define SW    6'd53

// special 特权
`define ERET  6'd54
`define MFC0  6'd55
`define MTC0  6'd56

// NOP 空指令
`define NOP 6'd57
// MUL
`define MUL 6'd58
// `define 6'd59
// `define 6'd60
// `define 6'd61
// `define 6'd62
// `define 6'd63
// `define 6'd64

//AluSel
`define EXE_NOP 3'b000
`define EXE_LOGIC 3'b001
`define EXE_SHIFT 3'b010
`define EXE_MOVE 3'b011	
`define EXE_ARITHMETIC 3'b100	
`define EXE_MUL 3'b101
`define EXE_JUMP_BRANCH 3'b110
`define EXE_LOAD_STORE 3'b111	



// 全局
`define RstEnable 1'b1
`define RstDisable 1'b0
`define ZeroWord 32'h00000000
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0
`define AluOpBus 5:0
`define AluSelBus 2:0
`define InstValid 1'b0
`define InstInvalid 1'b1
`define Stop 1'b1
`define NoStop 1'b0
`define InDelaySlot 1'b1
`define NotInDelaySlot 1'b0
`define Branch 1'b1
`define NotBranch 1'b0
`define InterruptAssert 1'b1
`define InterruptNotAssert 1'b0
`define TrapAssert 1'b1
`define TrapNotAssert 1'b0
`define True_v 1'b1
`define False_v 1'b0
`define ChipEnable 1'b1
`define ChipDisable 1'b0
`define Cache 1'b1
`define UnCache 1'b0
`define StallBus 8:0

//指令存储器inst_rom
`define InstAddrBus 31:0
`define InstBus 31:0
`define InstMemNum 131071
`define InstMemNumLog2 17

//数据存储器data_ram
`define DataAddrBus 31:0
`define DataBus 31:0
`define DataMemNum 131071
`define DataMemNumLog2 17
`define ByteWidth 7:0

//通用寄存器regfile
`define RegAddrBus 4:0
`define RegBus 31:0
`define RegWidth 32
`define DoubleRegWidth 64
`define DoubleRegBus 63:0
`define RegNum 32
`define RegNumLog2 5
`define NOPRegAddr 5'b00000

//除法div
`define DivFree 2'b00
`define DivByZero 2'b01
`define DivOn 2'b10
`define DivEnd 2'b11
`define DivResultReady 1'b1
`define DivResultNotReady 1'b0
`define DivStart 1'b1
`define DivStop 1'b0

//axi 状态机
`define TEST1 4'd0
`define TEST2 4'd1
`define TEST3 4'd2

`define READ1 4'd3
`define READ2 4'd4
`define READ3 4'd5
`define READ4 4'd6
`define READ5 4'd7
`define READ6 4'd8
`define READ7 4'd9

`define WRITE1 4'd10
`define WRITE2 4'd11
`define WRITE3 4'd12
`define WRITE4 4'd13
`define WRITE5 4'd14

//CP0寄存器地址
`define CP0_REG_COUNT    5'b01001        //可读写
`define CP0_REG_COMPARE    5'b01011      //可读写
`define CP0_REG_STATUS    5'b01100       //可读写
`define CP0_REG_CAUSE    5'b01101        //只读
`define CP0_REG_EPC    5'b01110          //可读写
`define CP0_REG_CONFIG    5'b10000       //只读
`define CP0_REG_BADADDR    5'b01000
