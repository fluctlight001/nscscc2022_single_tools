`include "defines.v"
module pre_icache(
  input wire clk,
  input wire rst,
  input wire [`StallBus] stall,
  input wire flush,

  input wire [`RegBus] new_pc,
  input wire branch_flag_i,
  input wire [`RegBus] branch_target_address_i,

  input wire [`InstAddrBus] pc_pc,

  output reg [`InstAddrBus] icache_pc,

  input wire [31:0] pc_excepttype,
  output reg [31:0] icache_excepttype 
);

  always @ (posedge clk) begin
    if (rst == `RstEnable) begin
      icache_pc <= `ZeroWord;
      icache_excepttype <= `ZeroWord;
    end
    else if (flush == `True_v) begin
      icache_pc <= new_pc;
      if (new_pc[1:0] != 2'b00) begin
        icache_excepttype <= {15'b0,`True_v,16'b0};
      end
      else begin
        icache_excepttype <= `ZeroWord;
      end
    end
    else if (stall[1] == `Stop && stall[2] == `NoStop) begin
      icache_pc <= `ZeroWord;
      icache_excepttype <= `ZeroWord;
    end 
    else if (stall[1] == `NoStop) begin
      if (branch_flag_i == `Branch) begin
        icache_pc <= branch_target_address_i;
        if (branch_target_address_i[1:0] != 2'b00) begin
          icache_excepttype <= {15'b0,`True_v,16'b0};
        end
        else begin
          icache_excepttype <= pc_excepttype;
        end
      end
      else begin
        icache_pc <= pc_pc;
        icache_excepttype <= pc_excepttype;
      end
    end
  end

endmodule