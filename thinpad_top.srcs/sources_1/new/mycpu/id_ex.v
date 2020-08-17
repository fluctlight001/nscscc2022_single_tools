`include "defines.v"
module id_ex(
  input wire clk,
  input wire rst,
  input wire [`StallBus] stall,
  input wire flush,

  input wire [`InstAddrBus] id_pc,
  output reg [`InstAddrBus] ex_pc,
  input wire [`RegBus] id_inst,
  output reg [`RegBus] ex_inst,

  input wire [`AluOpBus] id_aluop,
  input wire [`AluSelBus] id_alusel,
  input wire [`RegBus] id_reg1,
  input wire [`RegBus] id_reg2,
  input wire [`RegAddrBus] id_waddr,
  input wire id_wreg,

  output reg [`AluOpBus] ex_aluop,
  output reg [`AluSelBus] ex_alusel,
  output reg [`RegBus] ex_reg1,
  output reg [`RegBus] ex_reg2,
  output reg [`RegAddrBus] ex_waddr,
  output reg ex_wreg,

// jump & branch
  input wire [`RegBus] id_link_address,
  input wire id_is_in_delayslot,
  input wire next_inst_in_delayslot_i,

  output reg [`RegBus] ex_link_addrss,
  output reg ex_is_in_delayslot,
  output reg is_in_delayslot_o,

// excepttype
  input wire [31:0] id_excepttype,
  output reg [31:0] ex_excepttype
);
  reg [31:0] excepttype_temp;
  always @ (posedge clk) begin
    if (rst == `RstEnable) begin
      ex_pc <= `ZeroWord;
      ex_inst <= `ZeroWord;
      ex_aluop <= `NOP;
      ex_alusel <= `EXE_NOP;
      ex_reg1 <= `ZeroWord;
      ex_reg2 <= `ZeroWord;
      ex_waddr <= `NOPRegAddr;
      ex_wreg <= `WriteDisable;

      ex_link_addrss <= `ZeroWord;
      ex_is_in_delayslot <= `NotInDelaySlot;
      is_in_delayslot_o <= `NotInDelaySlot;

      ex_excepttype <= `ZeroWord;
      excepttype_temp <= `ZeroWord;
    end
    else if (flush == `True_v) begin
      ex_pc <= `ZeroWord;
      ex_inst <= `ZeroWord;
      ex_aluop <= `NOP;
      ex_alusel <= `EXE_NOP;
      ex_reg1 <= `ZeroWord;
      ex_reg2 <= `ZeroWord;
      ex_waddr <= `NOPRegAddr;
      ex_wreg <= `WriteDisable;

      ex_link_addrss <= `ZeroWord;
      ex_is_in_delayslot <= `NotInDelaySlot;
      is_in_delayslot_o <= `NotInDelaySlot;

      ex_excepttype <= `ZeroWord;
      excepttype_temp <= `ZeroWord;
    end
    else if (stall[3] == `Stop && stall[4] == `NoStop) begin
      ex_pc <= `ZeroWord;
      ex_inst <= `ZeroWord;
      ex_aluop <= `NOP;
      ex_alusel <= `EXE_NOP;
      ex_reg1 <= `ZeroWord;
      ex_reg2 <= `ZeroWord;
      ex_waddr <= `NOPRegAddr;
      ex_wreg <= `WriteDisable;

      ex_link_addrss <= `ZeroWord;
      ex_is_in_delayslot <= `NotInDelaySlot;

      ex_excepttype <= `ZeroWord;
    end
    else if (stall[3] == `NoStop) begin
      ex_pc <= id_pc;
      ex_inst <= id_inst;
      ex_aluop <= id_aluop;
      ex_alusel <= id_alusel;
      ex_reg1 <= id_reg1;
      ex_reg2 <= id_reg2;
      ex_waddr <= id_waddr;
      ex_wreg <= id_wreg;

      ex_link_addrss <= id_link_address;
      ex_is_in_delayslot <= id_is_in_delayslot;
      is_in_delayslot_o <= next_inst_in_delayslot_i;

      if (|excepttype_temp) begin
        ex_excepttype <= excepttype_temp;
      end
      else begin
        ex_excepttype <= id_excepttype;
        excepttype_temp <= id_excepttype;
      end
    end
  end
endmodule 