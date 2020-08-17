`include "defines.v"
module line2_if_id(
    input wire clk,
    input wire rst,
    input wire [`StallBus] stall,
    input wire flush,

    input wire [`InstAddrBus] if_pc,
    input wire if_reg1_read,
    input wire if_reg2_read,
    input wire [`RegAddrBus] if_reg1_addr,
    input wire [`RegAddrBus] if_reg2_addr,
    input wire [`AluOpBus] if_aluop,
    input wire [`AluSelBus] if_alusel,
    input wire [`RegAddrBus] if_waddr,
    input wire if_wreg,
    input wire [`RegBus] if_imm,

    output reg [`InstAddrBus] id_pc,
    output reg id_reg1_read,
    output reg id_reg2_read,
    output reg [`RegAddrBus] id_reg1_addr,
    output reg [`RegAddrBus] id_reg2_addr,
    output reg [`AluOpBus] id_aluop,
    output reg [`AluSelBus] id_alusel,
    output reg [`RegAddrBus] id_waddr,
    output reg id_wreg,
    output reg [`RegBus] id_imm
);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            id_pc <= `ZeroWord;
            id_reg1_read <= `False_v;
            id_reg2_read <= `False_v;
            id_reg1_addr <= `NOPRegAddr;
            id_reg2_addr <= `NOPRegAddr;
            id_aluop <= `NOP;
            id_alusel <= `EXE_NOP;
            id_waddr <= `NOPRegAddr;
            id_wreg <= `WriteDisable;
            id_imm <= `ZeroWord; 
        end
        else if (flush == `True_v) begin
            id_pc <= `ZeroWord;
            id_reg1_read <= `False_v;
            id_reg2_read <= `False_v;
            id_reg1_addr <= `NOPRegAddr;
            id_reg2_addr <= `NOPRegAddr;
            id_aluop <= `NOP;
            id_alusel <= `EXE_NOP;
            id_waddr <= `NOPRegAddr;
            id_wreg <= `WriteDisable; 
            id_imm <= `ZeroWord; 
        end
        else if (stall[2] == `Stop && stall[3] == `NoStop) begin
            id_pc <= `ZeroWord;
            id_reg1_read <= `False_v;
            id_reg2_read <= `False_v;
            id_reg1_addr <= `NOPRegAddr;
            id_reg2_addr <= `NOPRegAddr;
            id_aluop <= `NOP;
            id_alusel <= `EXE_NOP;
            id_waddr <= `NOPRegAddr;
            id_wreg <= `WriteDisable; 
            id_imm <= `ZeroWord; 
        end
        else if (stall[2] == `NoStop) begin
            id_pc <= if_pc;
            id_reg1_read <= if_reg1_read;
            id_reg2_read <= if_reg2_read;
            id_reg1_addr <= if_reg1_addr;
            id_reg2_addr <= if_reg2_addr;
            id_aluop <= if_aluop;
            id_alusel <= if_alusel;
            id_waddr <= if_waddr;
            id_wreg <= if_wreg;
            id_imm <= if_imm;
        end
    end
endmodule