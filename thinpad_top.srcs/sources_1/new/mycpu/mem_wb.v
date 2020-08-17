`include "defines.v"
module mem_wb(
  input wire clk,
  input wire rst,
  input wire [`StallBus] stall,
  input wire flush,

  input wire [`RegAddrBus] mem_waddr,
  input wire mem_wreg,
  input wire [`RegBus] mem_wdata,

  output reg [`RegAddrBus] wb_waddr,
  output reg wb_wreg,
  output reg [`RegBus] wb_wdata,

// HI LO 
  input wire [`RegBus] mem_hi,
  input wire [`RegBus] mem_lo,
  input wire mem_whilo,

  output reg [`RegBus] wb_hi,
  output reg [`RegBus] wb_lo,
  output reg wb_whilo,

// cp0_reg
  // input wire mem_cp0_reg_we,
  // input wire [4:0] mem_cp0_reg_write_addr,
  // input wire [`RegBus] mem_cp0_reg_data,

  // output reg wb_cp0_reg_we,
  // output reg [4:0] wb_cp0_reg_write_addr,
  // output reg [`RegBus] wb_cp0_reg_data,

// pc
  input wire [`InstAddrBus] pc_i,
  output reg [`InstAddrBus] pc_o
);

  always @ (posedge clk) begin
    if (rst == `RstEnable) begin
      wb_waddr <= `NOPRegAddr;
      wb_wreg <= `WriteDisable;
      wb_wdata <= `ZeroWord;
      wb_hi <= `ZeroWord;
      wb_lo <= `ZeroWord;
      wb_whilo <= `WriteDisable;

      // wb_cp0_reg_we <= `WriteDisable;
      // wb_cp0_reg_write_addr <= 5'b00000;
      // wb_cp0_reg_data <= `ZeroWord;
      
      pc_o <= `ZeroWord;
    end
    else if (flush == `True_v) begin
      wb_waddr <= `NOPRegAddr;
      wb_wreg <= `WriteDisable;
      wb_wdata <= `ZeroWord;
      wb_hi <= `ZeroWord;
      wb_lo <= `ZeroWord;
      wb_whilo <= `WriteDisable;

      // wb_cp0_reg_we <= `WriteDisable;
      // wb_cp0_reg_write_addr <= 5'b00000;
      // wb_cp0_reg_data <= `ZeroWord;
      
      pc_o <= `ZeroWord;
    end
    else if (stall[7] == `Stop && stall[8] == `NoStop) begin
      wb_waddr <= `NOPRegAddr;
      wb_wreg <= `WriteDisable;
      wb_wdata <= `ZeroWord;
      wb_hi <= `ZeroWord;
      wb_lo <= `ZeroWord;
      wb_whilo <= `WriteDisable;
      
      // wb_cp0_reg_we <= `WriteDisable;
      // wb_cp0_reg_write_addr <= 5'b00000;
      // wb_cp0_reg_data <= `ZeroWord;
      
      pc_o <= `ZeroWord;
    end
    else if (stall[7] == `NoStop) begin
      wb_waddr <= mem_waddr;
      wb_wreg <= mem_wreg;
      wb_wdata <= mem_wdata;
      wb_hi <= mem_hi;
      wb_lo <= mem_lo;
      wb_whilo <= mem_whilo;
      
      // wb_cp0_reg_we <= mem_cp0_reg_we;
      // wb_cp0_reg_write_addr <= mem_cp0_reg_write_addr;
      // wb_cp0_reg_data <= mem_cp0_reg_data;

      pc_o <= pc_i;
    end // if
  end // always
endmodule