`include "defines.v"
module pre_mem(
  input wire rst,

  // input wire [`RegAddrBus] waddr_i,
  // input wire wreg_i,
  // input wire [`RegBus] wdata_i,

  // output reg [`RegAddrBus] waddr_o,
  // output reg wreg_o,
  // output reg [`RegBus] wdata_o,

// HI LO 
  // input wire [`RegBus] hi_i,
  // input wire [`RegBus] lo_i,
  // input wire whilo_i,

  // output reg [`RegBus] hi_o,
  // output reg [`RegBus] lo_o,
  // output reg whilo_o,

// MEM
  input wire [`AluOpBus] aluop_i,
  input wire [`RegBus] mem_addr_i,
  input wire [`RegBus] reg2_i,

  // output reg [`AluOpBus] aluop_o,

// cache
  output reg [`RegBus] mem_addr_o, // 同时作为MEM的输出传给mem段
  output reg mem_we_o,
  output reg [3:0] mem_sel_o,
  output reg [`RegBus] mem_data_o,
  output reg mem_ce_o,

// pc
  input wire [`InstAddrBus] pc_i,
  output wire [`InstAddrBus] pc_o,

// excepttype
  input wire [31:0] excepttype_i
);

assign pc_o = pc_i;

// HI LO 可能可以不在mem这部分出现
  // always @ (*) begin
  //   if (rst == `RstEnable) begin
  //     hi_o <= `ZeroWord;
  //     lo_o <= `ZeroWord;
  //     whilo_o <= `WriteDisable;
  //   end
  //   else begin
  //     hi_o <= hi_i;
  //     lo_o <= lo_i;
  //     whilo_o <= whilo_i;
  //   end
  // end // always

// mem main
  reg mem_we;

  always @ (*) begin
    if (rst == `RstEnable) begin
      // waddr_o <= `NOPRegAddr;
      // wreg_o <= `WriteDisable;
      // wdata_o <= `ZeroWord;
      // aluop_o <= `NOP;
      mem_addr_o <= `ZeroWord;
      mem_we <= `WriteDisable;
      mem_sel_o <= 4'b0000;
      mem_data_o <= `ZeroWord;
      mem_ce_o <= `ChipDisable;
    end
    else begin
      // waddr_o <= waddr_i;
      // wreg_o <= wreg_i;
      // wdata_o <= wdata_i;
      // aluop_o <= aluop_i;
      mem_addr_o <= `ZeroWord;
      mem_we <= `WriteDisable;
      mem_sel_o <= 4'b0000;
      mem_data_o <= `ZeroWord;
      mem_ce_o <= `ChipDisable;
      case (aluop_i)
        `LB:begin
          mem_addr_o <= mem_addr_i;
          mem_we <= `WriteDisable;
          mem_ce_o <= `ChipEnable;
          // case (mem_addr_i[1:0])
          //   2'b00:begin
          //     // wdata_o <= {{24{mem_data_i[7]}},mem_data_i[7:0]};
          //     mem_sel_o <= 4'b0001;
          //   end
          //   2'b01:begin
          //     // wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15:8]};
          //     mem_sel_o <= 4'b0010;
          //   end
          //   2'b10:begin
          //     // wdata_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]};
          //     mem_sel_o <= 4'b0100;
          //   end
          //   2'b11:begin
          //     // wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};
          //     mem_sel_o <= 4'b1000;
          //   end
          //   default:begin
          //     // wdata_o <= `ZeroWord;
          //     mem_sel_o <= 4'b0000;
          //   end
          // endcase
        end
        `LBU:begin
          mem_addr_o <= mem_addr_i;
          mem_we <= `WriteDisable;
          mem_ce_o <= `ChipEnable;
          // case(mem_addr_i[1:0])
          //   2'b00:begin
          //     // wdata_o <= {{24{1'b0}},mem_data_i[7:0]};
          //     mem_sel_o <= 4'b0001;
          //   end
          //   2'b01:begin
          //     // wdata_o <= {{24{1'b0}},mem_data_i[15:8]};
          //     mem_sel_o <= 4'b0010;
          //   end
          //   2'b10:begin
          //     // wdata_o <= {{24{1'b0}},mem_data_i[23:16]};
          //     mem_sel_o <= 4'b0100;
          //   end
          //   2'b11:begin
          //     // wdata_o <= {{24{1'b0}},mem_data_i[31:24]};
          //     mem_sel_o <= 4'b1000;
          //   end
          //   default:begin
          //     // wdata_o <= `ZeroWord;
          //     mem_sel_o <= 4'b0000;
          //   end
          // endcase
        end
        `LH:begin
          mem_addr_o <= mem_addr_i;
          mem_we <= `WriteDisable;
          mem_ce_o <= `ChipEnable;
          // case(mem_addr_i[1:0])
          //   2'b00:begin
          //     // wdata_o <= {{16{mem_data_i[15]}},mem_data_i[15:0]};
          //     mem_sel_o <= 4'b0011;
          //   end
          //   2'b10:begin
          //     // wdata_o <= {{16{mem_data_i[31]}},mem_data_i[31:16]};
          //     mem_sel_o <= 4'b1100;
          //   end
          //   default:begin
          //     // wdata_o <= `ZeroWord;
          //     mem_sel_o <= 4'b0000;
          //   end
          // endcase                    
        end
        `LHU:begin
          mem_addr_o <= mem_addr_i;
          mem_we <= `WriteDisable;
          mem_ce_o <= `ChipEnable;
          // case(mem_addr_i[1:0])
          //   2'b00:begin
          //     // wdata_o <= {{16{1'b0}},mem_data_i[15:0]};
          //     mem_sel_o <= 4'b0011;
          //   end
          //   2'b10:begin
          //     // wdata_o <= {{16{1'b0}},mem_data_i[31:16]};
          //     mem_sel_o <= 4'b1100;
          //   end
          //   default:begin
          //     // wdata_o <= `ZeroWord;
          //     mem_sel_o <= 4'b0000;
          //   end
          // endcase
        end
        `LW:begin
          mem_addr_o <= mem_addr_i;
          mem_we <= `WriteDisable;
          mem_ce_o <= `ChipEnable;
          // wdata_o <= mem_data_i;
          // mem_sel_o <= 4'b1111;
        end
        `SB:begin
          mem_addr_o <= mem_addr_i;
          mem_we <= `WriteEnable;
          mem_ce_o <= `ChipEnable;
          mem_data_o <= {reg2_i[7:0],reg2_i[7:0],reg2_i[7:0],reg2_i[7:0]};
          case(mem_addr_i[1:0])
            2'b00:begin
              mem_sel_o <= 4'b0001;
            end
            2'b01:begin
              mem_sel_o <= 4'b0010;
            end
            2'b10:begin
              mem_sel_o <= 4'b0100;
            end
            2'b11:begin
              mem_sel_o <= 4'b1000;
            end
            default: begin
              mem_sel_o <= 4'b0000;
            end
          endcase              
        end
        `SH:begin
          mem_addr_o <= mem_addr_i;
          mem_we <= `WriteEnable;
          mem_ce_o <= `ChipEnable;
          mem_data_o <= {reg2_i[15:0],reg2_i[15:0]};
          case(mem_addr_i[1:0])
            2'b00:begin
              mem_sel_o <= 4'b0011;
            end
            2'b10:begin
              mem_sel_o <= 4'b1100;
            end
            default begin
              mem_sel_o <= 4'b0000;
            end
          endcase
        end
        `SW:begin
          mem_addr_o <= mem_addr_i;
          mem_ce_o <= `ChipEnable;
          mem_we <= `WriteEnable;
          mem_sel_o <= 4'b1111;
          mem_data_o <= reg2_i;
        end
        default:begin
          
        end
      endcase
    end
  end

  always @ (*) begin
    if (rst == `RstEnable) begin
      mem_we_o <= `WriteDisable;
    end
    else begin
      mem_we_o <= mem_we & (~(|excepttype_i));
    end
  end
endmodule