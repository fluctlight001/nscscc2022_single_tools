`include "defines.v"
module dcache_mem(
  input wire clk,
  input wire rst,
  input wire [`StallBus]stall,
  input wire flush,

  input wire [`RegAddrBus] dcache_waddr,
  input wire dcache_wreg,
  input wire [`RegBus] dcache_wdata,

  output reg [`RegAddrBus] mem_waddr,
  output reg mem_wreg,
  output reg [`RegBus] mem_wdata,

  input wire [`RegBus] dcache_hi,
  input wire [`RegBus] dcache_lo,
  input wire dcache_whilo,

  output reg [`RegBus] mem_hi,
  output reg [`RegBus] mem_lo,
  output reg mem_whilo,

  input wire [`AluOpBus] dcache_aluop,
  output reg [`AluOpBus] mem_aluop,
  input wire [`RegBus] dcache_addr,
  output reg [`RegBus] mem_addr,
  input wire [`RegBus] dcache_data,
  output reg [`RegBus] mem_data,

// cp0_reg
  input wire dcache_cp0_reg_we,
  input wire [4:0] dcache_cp0_reg_write_addr,
  input wire [`RegBus] dcache_cp0_reg_data,

  output reg mem_cp0_reg_we,
  output reg [4:0] mem_cp0_reg_write_addr,
  output reg [`RegBus] mem_cp0_reg_data,

// pc 
  input wire [`InstAddrBus] dcache_pc,
  output reg [`InstAddrBus] mem_pc,

// excepttype
  input wire [31:0] dcache_excepttype,
  input wire dcache_is_in_delayslot,
  input wire [`RegBus] dcache_badvaddr,

  output reg [31:0] mem_excepttype,
  output reg mem_is_in_delayslot,
  output reg [`RegBus] mem_badvaddr  
);
  always @ (posedge clk) begin
    if (rst == `RstEnable) begin
      mem_waddr <= `NOPRegAddr;
      mem_wreg <= `WriteDisable;
      mem_wdata <= `ZeroWord;
      mem_hi <= `ZeroWord;
      mem_lo <= `ZeroWord;
      mem_whilo <= `WriteDisable;
      
      mem_aluop <= `NOP;
      mem_addr <= `ZeroWord;
      mem_data <= `ZeroWord;

      mem_cp0_reg_we <= `WriteDisable;
      mem_cp0_reg_write_addr <= 5'b00000;
      mem_cp0_reg_data <= `ZeroWord;
      
      mem_pc <= `ZeroWord;

      mem_excepttype <= `ZeroWord;
      mem_is_in_delayslot <= `NotInDelaySlot;
      mem_badvaddr <= `ZeroWord;
    end 
    else if (flush == `True_v) begin
      mem_waddr <= `NOPRegAddr;
      mem_wreg <= `WriteDisable;
      mem_wdata <= `ZeroWord;
      mem_hi <= `ZeroWord;
      mem_lo <= `ZeroWord;
      mem_whilo <= `WriteDisable;
      
      mem_aluop <= `NOP;
      mem_addr <= `ZeroWord;
      mem_data <= `ZeroWord;

      mem_cp0_reg_we <= `WriteDisable;
      mem_cp0_reg_write_addr <= 5'b00000;
      mem_cp0_reg_data <= `ZeroWord;
      
      mem_pc <= `ZeroWord;

      mem_excepttype <= `ZeroWord;
      mem_is_in_delayslot <= `NotInDelaySlot;
      mem_badvaddr <= `ZeroWord;
    end
    else if (stall[6] == `Stop && stall[7] == `NoStop) begin
      mem_waddr <= `NOPRegAddr;
      mem_wreg <= `WriteDisable;
      mem_wdata <= `ZeroWord;
      mem_hi <= `ZeroWord;
      mem_lo <= `ZeroWord;
      mem_whilo <= `WriteDisable;
      
      mem_aluop <= `NOP;
      mem_addr <= `ZeroWord;
      mem_data <= `ZeroWord;
      
      mem_cp0_reg_we <= `WriteDisable;
      mem_cp0_reg_write_addr <= 5'b00000;
      mem_cp0_reg_data <= `ZeroWord;
      
      mem_pc <= `ZeroWord;

      mem_excepttype <= `ZeroWord;
      mem_is_in_delayslot <= `NotInDelaySlot;
      mem_badvaddr <= `ZeroWord;
    end
    else if (stall[6] == `NoStop) begin
      mem_waddr <= dcache_waddr;
      mem_wreg <= dcache_wreg;
      mem_wdata <= dcache_wdata;
      mem_hi <= dcache_hi;
      mem_lo <= dcache_lo;
      mem_whilo <= dcache_whilo;

      mem_aluop <= dcache_aluop;
      mem_addr <= dcache_addr;
      mem_data <= dcache_data;
      
      mem_cp0_reg_we <= dcache_cp0_reg_we;
      mem_cp0_reg_write_addr <= dcache_cp0_reg_write_addr;
      mem_cp0_reg_data <= dcache_cp0_reg_data;

      mem_pc <= dcache_pc;

      mem_excepttype <= dcache_excepttype;
      mem_is_in_delayslot <= dcache_is_in_delayslot;
      mem_badvaddr <= dcache_badvaddr;
    end
  end
endmodule 