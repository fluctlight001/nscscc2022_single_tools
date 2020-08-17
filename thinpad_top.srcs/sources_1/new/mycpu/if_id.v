`include "defines.v"
module if_id(
  input wire clk,
  input wire rst,
  input wire [`StallBus] stall,
  input wire flush,

  input wire [`InstAddrBus] if_pc,
  input wire [`InstBus] if_inst,

  output reg [`InstAddrBus] id_pc,
  output reg [`InstBus] id_inst,

  input wire [31:0] icache_excepttype,
  output reg [31:0] id_excepttype
);

  reg flag;
  reg [`InstAddrBus] pc;
  reg [`InstBus] inst;
  always @ (posedge clk) begin
    if (rst == `RstEnable) begin
      id_pc <= `ZeroWord;
      id_inst <= `ZeroWord;
      id_excepttype <= `ZeroWord;
      flag <= `False_v;
    end
    else if (flush == `True_v) begin
      id_pc <= `ZeroWord;
      id_inst <= `ZeroWord;
      id_excepttype <= `ZeroWord;
      flag <= `False_v;
    end
    else if (stall[2] == `Stop && stall[3] == `NoStop) begin
      id_pc <= `ZeroWord;
      id_inst <= `ZeroWord;
      id_excepttype <= `ZeroWord;
      flag <= `False_v;
    end
    else if (stall[2] == `NoStop) begin
      if (flag == `True_v) begin
        id_pc <= pc;
        id_inst <= inst;
        id_excepttype <= icache_excepttype;
        flag <= `False_v;
      end
      else begin  
        id_pc <= if_pc;
        id_inst <= if_inst;  
        id_excepttype <= icache_excepttype;
        flag <= `False_v;
      end
    end
    else if (flag == `False_v) begin
      pc <= if_pc;
      inst <= if_inst;
      flag <= `True_v;
    end
  end
endmodule