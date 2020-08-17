`include "defines.v"
module line2_id_ex(
    input wire clk,
    input wire rst,
    input wire [`StallBus] stall,
    input wire flush,

    input wire [`InstAddrBus] id_pc,
    input wire id_reg1_read,
    input wire id_reg2_read,
    input wire [`RegAddrBus] id_reg1_addr,
    input wire [`RegAddrBus] id_reg2_addr,
    input wire [`AluOpBus] id_aluop,
    input wire [`AluSelBus] id_alusel,
    input wire [`RegAddrBus] id_waddr,
    input wire id_wreg,
    input wire [`RegBus] id_imm,
    input wire [`RegBus] id_reg1_rdata,
    input wire [`RegBus] id_reg2_rdata,

    output reg [`InstAddrBus] ex_pc,
    output reg ex_reg1_read,
    output reg ex_reg2_read,
    output reg [`RegAddrBus] ex_reg1_addr,
    output reg [`RegAddrBus] ex_reg2_addr,
    output reg [`AluOpBus] ex_aluop,
    output reg [`AluSelBus] ex_alusel,
    output reg [`RegAddrBus] ex_waddr,
    output reg ex_wreg,
    output reg [`RegBus] ex_imm,
    output reg [`RegBus] ex_reg1_rdata,
    output reg [`RegBus] ex_reg2_rdata
);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            ex_pc <= `ZeroWord;
            ex_reg1_read <= `False_v;
            ex_reg2_read <= `False_v;
            ex_reg1_addr <= `NOPRegAddr;
            ex_reg2_addr <= `NOPRegAddr;
            ex_aluop <= `NOP;
            ex_alusel <= `EXE_NOP;
            ex_waddr <= `NOPRegAddr;
            ex_wreg <= `WriteDisable;
            ex_imm <= `ZeroWord;
            ex_reg1_rdata <= `ZeroWord;
            ex_reg2_rdata <= `ZeroWord;
        end
        else if (flush == `True_v) begin
            ex_pc <= `ZeroWord;
            ex_reg1_read <= `False_v;
            ex_reg2_read <= `False_v;
            ex_reg1_addr <= `NOPRegAddr;
            ex_reg2_addr <= `NOPRegAddr;
            ex_aluop <= `NOP;
            ex_alusel <= `EXE_NOP;
            ex_waddr <= `NOPRegAddr;
            ex_wreg <= `WriteDisable;
            ex_imm <= `ZeroWord;
            ex_reg1_rdata <= `ZeroWord;
            ex_reg2_rdata <= `ZeroWord;
        end
        else if (stall[3] == `Stop && stall[4] == `NoStop) begin
            ex_pc <= `ZeroWord;
            ex_reg1_read <= `False_v;
            ex_reg2_read <= `False_v;
            ex_reg1_addr <= `NOPRegAddr;
            ex_reg2_addr <= `NOPRegAddr;
            ex_aluop <= `NOP;
            ex_alusel <= `EXE_NOP;
            ex_waddr <= `NOPRegAddr;
            ex_wreg <= `WriteDisable;
            ex_imm <= `ZeroWord;
            ex_reg1_rdata <= `ZeroWord;
            ex_reg2_rdata <= `ZeroWord;
        end
        else if (stall[3] == `NoStop) begin
            ex_pc <= id_pc;
            ex_reg1_read <= id_reg1_read;
            ex_reg2_read <= id_reg2_read;
            ex_reg1_addr <= id_reg1_addr;
            ex_reg2_addr <= id_reg2_addr;
            ex_aluop <= id_aluop;
            ex_alusel <= id_alusel;
            ex_waddr <= id_waddr;
            ex_wreg <= id_wreg;
            ex_imm <= id_imm;
            ex_reg1_rdata <= id_reg1_rdata;
            ex_reg2_rdata <= id_reg2_rdata;
        end
    end
endmodule