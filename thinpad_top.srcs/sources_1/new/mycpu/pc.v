`include "defines.v"
module pc(
  input wire clk,
  input wire rst,
  input wire [`StallBus] stall,

  input wire flush,
  input wire [`RegBus] new_pc,

  input wire branch_flag_i,
  input wire [`RegBus] branch_target_address_i,

  input wire l2_pc_plus_4_req,

  output reg [`InstAddrBus] pc,
  output reg ce,

  output wire [31:0] excepttype_o
);

  reg excepttype_is_ft_adel;
  assign excepttype_o = {15'b0,excepttype_is_ft_adel,16'b0};
  
  always @ (posedge clk) begin
    if (rst == `RstEnable) begin
      ce <= `ChipDisable;
    end
    else begin
      ce <= `ChipEnable;
    end
  end

  always @ (posedge clk) begin
    if (rst == `RstEnable) begin
      pc <= 32'h80000000;
    end
    else if (ce == `ChipEnable) begin
      if (flush == `True_v) begin
        pc <= new_pc + 32'd4;
      end
      else if (stall [0] == `NoStop) begin
        if (branch_flag_i == `Branch) begin
          pc <= branch_target_address_i + 32'd4;
        end
        else if (l2_pc_plus_4_req) begin
          pc <= pc + 32'h8;
        end
        else begin
          pc <= pc + 32'h4;
        end
      end  
    end
  end
  
  always @ (*) begin
    excepttype_is_ft_adel <= (pc[1:0] != 2'b00) ? `True_v : `False_v;  
  end
endmodule
