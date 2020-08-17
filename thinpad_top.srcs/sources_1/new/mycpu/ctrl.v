`include "defines.v"
module ctrl (
  input wire rst,
  input wire stallreq_from_id,
  input wire stallreq_from_ex,
  input wire stallreq_from_icache,
  input wire stallreq_from_dcache,

  input wire [31:0] excepttype_i,
  input wire [`RegBus] cp0_epc_i,

  output reg [`RegBus] new_pc,
  output reg flush,
  output reg [`StallBus] stall
);

  always @ (*) begin
    if(rst == `RstEnable) begin
      stall <= 9'b000000000;
      flush <= `False_v;
      new_pc <= `ZeroWord;
    end
    else if (excepttype_i != `ZeroWord) begin
      stall <= 9'b000000000;
      flush <= `True_v;
      new_pc <= `ZeroWord;
      case (excepttype_i)
        32'h00000001:begin
          new_pc <= 32'hbfc00380;
        end
        32'h00000004:begin
          new_pc <= 32'hbfc00380;
        end
        32'h00000005:begin
          new_pc <= 32'hbfc00380;
        end
        32'h00000008:begin
          new_pc <= 32'hbfc00380;
        end
        32'h00000009:begin
          new_pc <= 32'hbfc00380;
        end
        32'h0000000a:begin
          new_pc <= 32'hbfc00380;
        end
        32'h0000000d:begin
          new_pc <= 32'hbfc00380;
        end
        32'h0000000c:begin
          new_pc <= 32'hbfc00380;
        end
        32'h0000000e:begin
          new_pc <= cp0_epc_i;
        end
        default:begin
          
        end
      endcase
    end
    else if (stallreq_from_dcache == `Stop || stallreq_from_icache == `Stop) begin
      stall <= 9'b011111111;
      flush <= `False_v;
      new_pc <= `ZeroWord;
    end
    else if (stallreq_from_ex == `Stop) begin
      stall <= 9'b000011111;
      flush <= `False_v;
      new_pc <= `ZeroWord;
    end
    else if (stallreq_from_id == `Stop) begin
      stall <= 6'b000001111;
      flush <= `False_v;
      new_pc <= `ZeroWord;
    end
    else begin
      stall <= 6'b000000;
      flush <= `False_v;
      new_pc <= `ZeroWord;
    end
  end
endmodule