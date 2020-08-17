`include "defines.v"
module mem(
  input wire rst,

  input wire [`RegAddrBus] waddr_i,
  input wire wreg_i,
  input wire [`RegBus] wdata_i,

  output reg [`RegAddrBus] waddr_o,
  output reg wreg_o,
  output reg [`RegBus] wdata_o,

// HI LO 
  input wire [`RegBus] hi_i,
  input wire [`RegBus] lo_i,
  input wire whilo_i,

  output reg [`RegBus] hi_o,
  output reg [`RegBus] lo_o,
  output reg whilo_o,

// dcache
  input wire [`AluOpBus] aluop_i,
  input wire [`RegBus] mem_addr_i,
  input wire [`RegBus] mem_data_i,

// pc
  input wire [`InstAddrBus] pc_i,
  output wire [`InstAddrBus] pc_o,

// excepttype
  input wire [31:0] excepttype_i,
  input wire is_in_delayslot_i,
  input wire [`RegBus] badvaddr_i,
  // from cp0
  input wire [`RegBus] cp0_status_i,
  input wire [`RegBus] cp0_cause_i,
  input wire [`RegBus] cp0_epc_i,
  // wb forwarding
  // input wire wb_cp0_reg_we,
  // input wire [4:0] wb_cp0_reg_write_addr,
  // input wire [`RegBus] wb_cp0_reg_data,

  output reg [31:0] excepttype_o,
  output wire [`RegBus] cp0_epc_o,
  output wire is_in_delayslot_o,
  output wire [`RegBus] badvaddr_o
);

assign pc_o = pc_i;
assign badvaddr_o = (excepttype_i[16] == 1'b1) ? pc_i : badvaddr_i;
// HI LO 可能可以不在mem这部分出现
  always @ (*) begin
    if (rst == `RstEnable) begin
      hi_o <= `ZeroWord;
      lo_o <= `ZeroWord;
      whilo_o <= `WriteDisable;
    end
    else begin
      hi_o <= hi_i;
      lo_o <= lo_i;
      whilo_o <= whilo_i;
    end
  end // always

// mem main
  always @ (*) begin
    if (rst == `RstEnable) begin
      waddr_o <= `NOPRegAddr;
      wreg_o <= `WriteDisable;
      wdata_o <= `ZeroWord;
    end
    else begin
      waddr_o <= waddr_i;
      wreg_o <= wreg_i;
      wdata_o <= wdata_i;
      case (aluop_i)
        `LB:begin
          case (mem_addr_i[1:0])
            2'b00:begin wdata_o <= {{24{mem_data_i[ 7]}},mem_data_i[ 7: 0]}; end
            2'b01:begin wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15: 8]}; end
            2'b10:begin wdata_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]}; end
            2'b11:begin wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]}; end
            default:begin wdata_o <= `ZeroWord; end
          endcase
        end
        `LBU:begin
          case(mem_addr_i[1:0])
            2'b00:begin wdata_o <= {{24{1'b0}},mem_data_i[ 7: 0]}; end
            2'b01:begin wdata_o <= {{24{1'b0}},mem_data_i[15: 8]}; end
            2'b10:begin wdata_o <= {{24{1'b0}},mem_data_i[23:16]}; end
            2'b11:begin wdata_o <= {{24{1'b0}},mem_data_i[31:24]}; end
            default:begin wdata_o <= `ZeroWord; end
          endcase
        end
        `LH:begin
          case(mem_addr_i[1:0])
            2'b00:begin wdata_o <= {{16{mem_data_i[15]}},mem_data_i[15: 0]}; end
            2'b10:begin wdata_o <= {{16{mem_data_i[31]}},mem_data_i[31:16]}; end
            default:begin wdata_o <= `ZeroWord; end
          endcase                    
        end
        `LHU:begin
          case(mem_addr_i[1:0])
            2'b00:begin wdata_o <= {{16{1'b0}},mem_data_i[15: 0]}; end
            2'b10:begin wdata_o <= {{16{1'b0}},mem_data_i[31:16]}; end
            default:begin wdata_o <= `ZeroWord; end
          endcase
        end
        `LW:begin
          wdata_o <= mem_data_i;
        end
        default:begin
          
        end
      endcase
    end
  end

// excepttype
  reg [`RegBus] cp0_status;
  reg [`RegBus] cp0_cause;
  reg [`RegBus] cp0_epc;
  
  assign is_in_delayslot_o = is_in_delayslot_i;
  
  // status
  always @ (*) begin
    if (rst == `RstEnable) begin
      cp0_status <= `ZeroWord;
    end
    // else if ((wb_cp0_reg_we == `WriteEnable) && (wb_cp0_reg_write_addr == `CP0_REG_STATUS)) begin
    //   cp0_status <= wb_cp0_reg_data;
    // end
    else begin
      cp0_status <= cp0_status_i;
    end
  end

  // epc
  always @ (*) begin
    if (rst == `RstEnable) begin
      cp0_epc <= `ZeroWord;
    end
    // else if ((wb_cp0_reg_we == `WriteEnable) && (wb_cp0_reg_write_addr == `CP0_REG_EPC)) begin
    //   cp0_epc <= wb_cp0_reg_data;
    // end
    else begin
      cp0_epc <= cp0_epc_i;
    end
  end
  assign cp0_epc_o = cp0_epc;
  
  //cause
  always @ (*) begin
    if (rst == `RstEnable) begin
      cp0_cause <= `ZeroWord;
    end
    // else if ((wb_cp0_reg_we == `WriteEnable) && (wb_cp0_reg_write_addr == `CP0_REG_CAUSE)) begin
    //   cp0_cause[9:8] <= wb_cp0_reg_data[9:8];
    //   cp0_cause[22] <= wb_cp0_reg_data[22];
    //   cp0_cause[23] <= wb_cp0_reg_data[23];
    // end
    else begin
      cp0_cause <= cp0_cause_i;
    end
  end

  //excepttype_o
  always @ (*) begin
    if (rst == `RstEnable) begin
      excepttype_o <= `ZeroWord;
    end
    else begin
      excepttype_o <= `ZeroWord;
      if (pc_i != `ZeroWord) begin
        if (((cp0_cause[15:8] & cp0_status[15:8]) != 8'b0) && (cp0_status[1] == 1'b0) && (cp0_status[0] == 1'b1)) begin
          excepttype_o <= 32'h00000001;         //interrupt
        end
        else if (excepttype_i[8] == 1'b1) begin // syscall
          excepttype_o <= 32'h00000008;
        end
        else if (excepttype_i[13] == 1'b1) begin // break
          excepttype_o <= 32'h00000009;
        end
        else if (excepttype_i[9] == 1'b1) begin // inst_invalid
          excepttype_o <= 32'h0000000a;
        end
        else if (excepttype_i[10] == 1'b1) begin // trap
          excepttype_o <= 32'h0000000d;
        end
        else if (excepttype_i[11] == 1'b1) begin // ov
          excepttype_o <= 32'h0000000c;
        end
        else if (excepttype_i[12] == 1'b1) begin // eret
          excepttype_o <= 32'h0000000e;
        end
        else if (excepttype_i[14] == 1'b1) begin // storeassert
          excepttype_o <= 32'h00000005;
        end
        else if (excepttype_i[15] == 1'b1) begin // loadassert
          excepttype_o <= 32'h00000004;
        end
        else if (excepttype_i[16] == 1'b1) begin // ft_adel
          excepttype_o <= 32'h00000004;
        end
      end
    end
  end
endmodule