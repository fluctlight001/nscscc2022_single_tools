`include "defines.v"
module cp0_reg(
  input wire clk,
  input wire rst,

  input wire we_i,
  input wire [4:0] waddr_i,
  input wire [4:0] raddr_i,
  input wire [`RegBus] data_i,
  
  input wire [5:0] int_i,
  
  output reg [`RegBus] data_o,
  output reg [`RegBus] badvaddr_o,
  output reg [`RegBus] count_o,
  output reg [`RegBus] compare_o,
  output reg [`RegBus] status_o,
  output reg [`RegBus] cause_o,
  output reg [`RegBus] epc_o,
  output reg [`RegBus] config_o,
  // output reg [`RegBus] prid_o, 

  output reg timer_int_o,

// excepttype
  input wire [31:0] excepttype_i,
  input wire [`RegBus] pc_i,
  input wire is_in_delayslot_i,
  input wire [`RegBus] badvaddr_i
);
  
// write
  always @ (posedge clk) begin
    if (rst == `RstEnable) begin
      badvaddr_o <= `ZeroWord;
      count_o <= `ZeroWord;
      compare_o <= `ZeroWord;
      status_o <= {4'b0001,28'd0};
      cause_o <= `ZeroWord;
      epc_o <= `ZeroWord;
      config_o <= `ZeroWord; // 这个处理器是小端的
      timer_int_o <= `InterruptNotAssert;
    end
    else begin
      count_o <= count_o + 1'b1;
      cause_o[15:10] <= int_i;
      if (compare_o != `ZeroWord && count_o == compare_o) begin
        timer_int_o <= `InterruptAssert;
      end
      if (we_i == `WriteEnable) begin
        case (waddr_i)
          `CP0_REG_COUNT:begin
            count_o <= data_i;
          end
          `CP0_REG_COMPARE:begin
            compare_o <= data_i;
          end
          `CP0_REG_STATUS:begin
            status_o <= data_i;
          end
          `CP0_REG_EPC:begin
            epc_o <= data_i;
          end
          `CP0_REG_CAUSE:begin
            cause_o[9:8] <= data_i[9:8];
            cause_o[23] <= data_i[23];
            cause_o[22] <= data_i[22];
          end
          default:begin
            
          end
        endcase
      end
      case (excepttype_i)
        32'h00000001:begin // interrupt
          if (is_in_delayslot_i == `InDelaySlot) begin
            epc_o <= pc_i - 4;
            cause_o[31] <= 1'b1;
          end
          else begin
            epc_o <= pc_i;
            cause_o[31] <= 1'b0;
          end
          status_o[1] <= 1'b1;
          cause_o[6:2] <= 5'b00000;
        end
        32'h00000004:begin // loadassert
          if (status_o[1] == 1'b0) begin
            if (is_in_delayslot_i == `InDelaySlot) begin
              epc_o <= pc_i - 4;
              cause_o[31] <= 1'b1;
            end
            else begin
              epc_o <= pc_i;
              cause_o[31] <= 1'b0;
            end
          end
          status_o[1] <= 1'b1;
          cause_o[6:2] <= 5'b00100;
          badvaddr_o <= badvaddr_i;
        end
        32'h00000005:begin // storeassert
          if (status_o[1] == 1'b0) begin
            if (is_in_delayslot_i == `InDelaySlot) begin
              epc_o <= pc_i - 4;
              cause_o[31] <= 1'b1;
            end
            else begin
              epc_o <= pc_i;
              cause_o[31] <= 1'b0;
            end
          end
          status_o[1] <= 1'b1;
          cause_o[6:2] <= 5'b00101;
          badvaddr_o <= badvaddr_i;
        end
        32'h00000008:begin // syscall
          if (status_o[1] == 1'b0) begin
            if (is_in_delayslot_i == `InDelaySlot) begin
              epc_o <= pc_i - 4;
              cause_o[31] <= 1'b1;
            end
            else begin
              epc_o <= pc_i;
              cause_o[31] <= 1'b0;
            end            
          end
          status_o[1] <= 1'b1;
          cause_o[6:2] <= 5'b01000;
        end
        32'h00000009:begin // break
          if (status_o[1] == 1'b0) begin
            if (is_in_delayslot_i == `InDelaySlot) begin
              epc_o <= pc_i - 4;
              cause_o[31] <= 1'b1;
            end
            else begin
              epc_o <= pc_i;
              cause_o[31] <= 1'b0;
            end
          end
          status_o[1] <= 1'b1;
          cause_o[6:2] <= 5'b01001;
        end
        32'h0000000a:begin // inst_invalid
          if (status_o[1] == 1'b0) begin
            if (is_in_delayslot_i == `InDelaySlot) begin
              epc_o <= pc_i - 4;
              cause_o[31] <= 1'b1; 
            end
            else begin
              epc_o <= pc_i;
              cause_o[31] <= 1'b0;
            end
          end
          status_o[1] <= 1'b1;
          cause_o[6:2] <= 5'b01010;
        end
        32'h0000000d:begin // trap
          if (status_o[1] == 1'b0) begin
            if (is_in_delayslot_i == `InDelaySlot) begin
              epc_o <= pc_i - 4;
              cause_o[31] <= 1'b1;
            end
            else begin
              epc_o <= pc_i;
              cause_o[31] <= 1'b0;
            end
          end
          status_o[1] <= 1'b1;
          cause_o[6:2] <= 5'b01101;
        end
        32'h0000000c:begin // ov
          if (status_o[1] == 1'b0) begin
            if (is_in_delayslot_i == `InDelaySlot) begin
              epc_o <= pc_i - 4;
              cause_o[31] <= 1'b1;
            end
            else begin
              epc_o <= pc_i;
              cause_o[31] <= 1'b0;
            end
          end
          status_o[1] <= 1'b1;
          cause_o[6:2] <= 5'b01100; 
        end
        32'h0000000e:begin // 
          status_o[1] <= 1'b0;
        end
        default:begin
          
        end
      endcase
    end
  end

  always @ (*) begin
    if (rst == `RstEnable) begin
      data_o <= `ZeroWord;
    end
    else begin
      case (raddr_i)
        `CP0_REG_COUNT:begin
          data_o <= count_o;
        end
        `CP0_REG_COMPARE:begin
          data_o <= compare_o;
        end
        `CP0_REG_STATUS:begin
          data_o <= status_o;
        end
        `CP0_REG_CAUSE:begin
          data_o <= cause_o;
        end
        `CP0_REG_EPC:begin
          data_o <= epc_o;
        end
        `CP0_REG_CONFIG:begin
          data_o <= config_o;
        end
        `CP0_REG_BADADDR:begin
          data_o <= badvaddr_o;
        end
        default:begin
          data_o <= `ZeroWord;
        end
      endcase 
    end
  end
endmodule