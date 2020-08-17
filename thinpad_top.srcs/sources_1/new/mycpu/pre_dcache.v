`include "defines.v"
// write back regfile & HILO 从本模块直接连接到mem模块
// MEM 从本模块连接至dcache模块，然后从dcache模块连接至mem模块
// 所有信号在mem模块再次整合输出
module pre_dcache(
  input wire clk,
  input wire rst,
  input wire [`StallBus] stall,
  input wire flush,

// write back regfile
  input wire [`RegAddrBus] premem_waddr,
  input wire premem_wreg,
  input wire [`RegBus] premem_wdata,

  output reg [`RegAddrBus] dcache_waddr,
  output reg dcache_wreg,
  output reg [`RegBus] dcache_wdata,

// HI LO 
  input wire [`RegBus] premem_hi,
  input wire [`RegBus] premem_lo,
  input wire premem_whilo,

  output reg [`RegBus] dcache_hi,
  output reg [`RegBus] dcache_lo,
  output reg dcache_whilo,

  input wire [`AluOpBus] premem_aluop,
  output reg [`AluOpBus] dcache_aluop,

// PREMEM
  input wire [`RegBus] premem_addr,
  input wire premem_we,
  input wire [3:0] premem_sel,
  input wire [`RegBus] premem_data,
  input wire premem_ce,
  input wire premem_cache,

  output reg [`RegBus] dcache_addr,
  output reg dcache_we,
  output reg [3:0] dcache_sel,
  output reg [`RegBus] dcache_data,
  output reg dcache_ce,
  output reg dcache_cache,

// cp0_reg
  input wire premem_cp0_reg_we,
  input wire [4:0] premem_cp0_reg_write_addr,
  input wire [`RegBus] premem_cp0_reg_data,

  output reg dcache_cp0_reg_we,
  output reg [4:0] dcache_cp0_reg_write_addr,
  output reg [`RegBus] dcache_cp0_reg_data,

// pc
  input wire [`InstAddrBus] premem_pc,
  output reg [`InstAddrBus] dcache_pc,

// excepttype
  input wire [31:0] premem_excepttype,
  input wire premem_is_in_delayslot,
  input wire [`RegBus] premem_badvaddr,

  output reg [31:0] dcache_excepttype,
  output reg dcache_is_in_delayslot,
  output reg [`RegBus] dcache_badvaddr
);
  always @ (posedge clk) begin
    if (rst == `RstEnable) begin
      dcache_waddr <= `NOPRegAddr;
      dcache_wreg <= `WriteDisable;
      dcache_wdata <= `ZeroWord;
      dcache_hi <= `ZeroWord;
      dcache_lo <= `ZeroWord;
      dcache_whilo <= `WriteDisable;

      dcache_aluop <= `NOP;

      dcache_addr <= `ZeroWord;
      dcache_we <= `False_v;
      dcache_sel <= 4'b0000;
      dcache_data <= `ZeroWord;
      dcache_ce <= `ChipDisable;
      dcache_cache <= `Cache;

      dcache_cp0_reg_we <= `WriteDisable;
      dcache_cp0_reg_write_addr <= 5'b00000;
      dcache_cp0_reg_data <= `ZeroWord;

      dcache_pc <= `ZeroWord;

      dcache_excepttype <= `ZeroWord;
      dcache_is_in_delayslot <= `NotInDelaySlot;
      dcache_badvaddr <= `ZeroWord;
    end
    else if (flush == `True_v) begin
      dcache_waddr <= `NOPRegAddr;
      dcache_wreg <= `WriteDisable;
      dcache_wdata <= `ZeroWord;
      dcache_hi <= `ZeroWord;
      dcache_lo <= `ZeroWord;
      dcache_whilo <= `WriteDisable;

      dcache_aluop <= `NOP;

      dcache_addr <= `ZeroWord;
      dcache_we <= `False_v;
      dcache_sel <= 4'b0000;
      dcache_data <= `ZeroWord;
      dcache_ce <= `ChipDisable;
      dcache_cache <= `Cache;

      dcache_cp0_reg_we <= `WriteDisable;
      dcache_cp0_reg_write_addr <= 5'b00000;
      dcache_cp0_reg_data <= `ZeroWord;

      dcache_pc <= `ZeroWord;

      dcache_excepttype <= `ZeroWord;
      dcache_is_in_delayslot <= `NotInDelaySlot;
      dcache_badvaddr <= `ZeroWord;
    end
    else if (stall[5] == `Stop && stall[6] == `NoStop) begin
      dcache_waddr <= `NOPRegAddr;
      dcache_wreg <= `WriteDisable;
      dcache_wdata <= `ZeroWord;
      dcache_hi <= `ZeroWord;
      dcache_lo <= `ZeroWord;
      dcache_whilo <= `WriteDisable;

      dcache_aluop <= `NOP;

      dcache_addr <= `ZeroWord;
      dcache_we <= `False_v;
      dcache_sel <= 4'b0000;
      dcache_data <= `ZeroWord;
      dcache_ce <= `ChipDisable;
      dcache_cache <= `Cache;

      dcache_cp0_reg_we <= `WriteDisable;
      dcache_cp0_reg_write_addr <= 5'b00000;
      dcache_cp0_reg_data <= `ZeroWord;

      dcache_pc <= `ZeroWord;

      dcache_excepttype <= `ZeroWord;
      dcache_is_in_delayslot <= `NotInDelaySlot;
      dcache_badvaddr <= `ZeroWord;
    end
    else if (stall[5] == `NoStop) begin
      dcache_waddr <= premem_waddr;
      dcache_wreg <= premem_wreg;
      dcache_wdata <= premem_wdata;
      dcache_hi <= premem_hi;
      dcache_lo <= premem_lo;
      dcache_whilo <= premem_whilo;

      dcache_aluop <= premem_aluop;

      dcache_addr <= premem_addr;
      dcache_we <= premem_we;
      dcache_sel <= premem_sel;
      dcache_data <= premem_data;
      dcache_ce <= premem_ce;
      dcache_cache <= premem_cache;

      dcache_cp0_reg_we <= premem_cp0_reg_we;
      dcache_cp0_reg_write_addr <= premem_cp0_reg_write_addr;
      dcache_cp0_reg_data <= premem_cp0_reg_data;

      dcache_pc <= premem_pc;

      dcache_excepttype <= premem_excepttype;
      dcache_is_in_delayslot <= premem_is_in_delayslot;
      dcache_badvaddr <= premem_badvaddr;
    end
  end

endmodule 
