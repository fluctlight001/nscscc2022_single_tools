`include "defines.v"
module regfile(
  input wire clk,
  input wire rst,
// 回写阶段 正常回写
  input wire                we, //write enable positive
  input wire [`RegAddrBus]  waddr,
  input wire [`RegBus]      wdata,

  input wire                l2_we,
  input wire [`RegAddrBus]  l2_waddr,
  input wire [`RegBus]      l2_wdata,
// 读数据
  input wire                re1, //read enable positive
  input wire [`RegAddrBus]  raddr1,
  output reg [`RegBus]      rdata1,

  input wire                re2,
  input wire [`RegAddrBus]  raddr2,
  output reg [`RegBus]      rdata2,
// 执行阶段 数据前推
  input wire                ex_forwarding_we,
  input wire [`RegAddrBus]  ex_forwarding_waddr,
  input wire [`RegBus]      ex_forwarding_wdata,

// dcache forwarding 
  input wire                dcache_forwarding_we,
  input wire [`RegAddrBus]  dcache_forwarding_waddr,
  input wire [`RegBus]      dcache_forwarding_wdata,

// 访存阶段 数据前推
  input wire                mem_forwarding_we,
  input wire [`RegAddrBus]  mem_forwarding_waddr,
  input wire [`RegBus]      mem_forwarding_wdata,

// l2
  input wire                l2_re1,
  input wire [`RegAddrBus]  l2_raddr1,
  output reg [`RegBus]      l2_rdata1,

  input wire                l2_re2,
  input wire [`RegAddrBus]  l2_raddr2,
  output reg [`RegBus]      l2_rdata2,
  // 执行阶段 数据前推
  input wire                l2_ex_forwarding_we,
  input wire [`RegAddrBus]  l2_ex_forwarding_waddr,
  input wire [`RegBus]      l2_ex_forwarding_wdata,

  // dcache forwarding 
  input wire                l2_dcache_forwarding_we,
  input wire [`RegAddrBus]  l2_dcache_forwarding_waddr,
  input wire [`RegBus]      l2_dcache_forwarding_wdata,

  // 访存阶段 数据前推
  input wire                l2_mem_forwarding_we,
  input wire [`RegAddrBus]  l2_mem_forwarding_waddr,
  input wire [`RegBus]      l2_mem_forwarding_wdata
);

  reg [`RegBus] rf [31:0];


// write all rf
  always @ (posedge clk) begin
    if (rst == `RstEnable) begin
      rf[ 0] <= `ZeroWord;
      rf[ 1] <= `ZeroWord;
      rf[ 2] <= `ZeroWord;
      rf[ 3] <= `ZeroWord;
      rf[ 4] <= `ZeroWord;
      rf[ 5] <= `ZeroWord;
      rf[ 6] <= `ZeroWord;
      rf[ 7] <= `ZeroWord;
      rf[ 8] <= `ZeroWord;
      rf[ 9] <= `ZeroWord;
      rf[10] <= `ZeroWord;
      rf[11] <= `ZeroWord;
      rf[12] <= `ZeroWord;
      rf[13] <= `ZeroWord;
      rf[14] <= `ZeroWord;
      rf[15] <= `ZeroWord;
      rf[16] <= `ZeroWord;
      rf[17] <= `ZeroWord;
      rf[18] <= `ZeroWord;
      rf[19] <= `ZeroWord;
      rf[20] <= `ZeroWord;
      rf[21] <= `ZeroWord;
      rf[22] <= `ZeroWord;
      rf[23] <= `ZeroWord;
      rf[24] <= `ZeroWord;
      rf[25] <= `ZeroWord;
      rf[26] <= `ZeroWord;
      rf[27] <= `ZeroWord;
      rf[28] <= `ZeroWord;
      rf[29] <= `ZeroWord;
      rf[30] <= `ZeroWord;
      rf[31] <= `ZeroWord;
    end
    else begin
      if ((we == `WriteEnable) && (waddr >= 5'd1) && (waddr <= 5'd31)) begin
        rf[waddr] <= wdata;
      end
      if ((l2_we == `WriteEnable) && (l2_waddr >= 5'd1) && (l2_waddr <= 5'd31)) begin
        rf[l2_waddr] <= l2_wdata;
      end
    end 
  end

// read reg1
  always @ (*) begin
    if (rst == `RstEnable) begin
      rdata1 <= `ZeroWord;
    end
    else if (re1 == `ReadEnable) begin
      if (raddr1 == 5'd0) begin
        rdata1 <= `ZeroWord;
      end
      else if ((raddr1 == l2_ex_forwarding_waddr) && (l2_ex_forwarding_we == `WriteEnable)) begin
        rdata1 <= l2_ex_forwarding_wdata;
      end
      else if ((raddr1 == ex_forwarding_waddr) && (ex_forwarding_we == `WriteEnable)) begin
        rdata1 <= ex_forwarding_wdata;
      end
      else if ((raddr1 == l2_dcache_forwarding_waddr) && (l2_dcache_forwarding_we == `WriteEnable)) begin
        rdata1 <= l2_dcache_forwarding_wdata;
      end
      else if ((raddr1 == dcache_forwarding_waddr) && (dcache_forwarding_we == `WriteEnable)) begin
        rdata1 <= dcache_forwarding_wdata;
      end
      else if ((raddr1 == l2_mem_forwarding_waddr) && (l2_mem_forwarding_we == `WriteEnable)) begin
        rdata1 <= l2_mem_forwarding_wdata;
      end
      else if ((raddr1 == mem_forwarding_waddr) && (mem_forwarding_we == `WriteEnable)) begin
        rdata1 <= mem_forwarding_wdata;
      end
      else if ((raddr1 == l2_waddr) && (l2_we == `WriteEnable)) begin
        rdata1 <= l2_wdata;
      end
      else if ((raddr1 == waddr) && (we == `WriteEnable)) begin
        rdata1 <= wdata;
      end
      else begin
        rdata1 <= rf[raddr1];
      end
    end
    else begin
      rdata1 <= `ZeroWord;
    end
  end

// read reg2
  always @ (*) begin
    if (rst == `RstEnable) begin
      rdata2 <= `ZeroWord;
    end
    else if (re2 == `ReadEnable) begin
      if (raddr2 == 5'd0) begin
        rdata2 <= `ZeroWord;
      end
      else if ((raddr2 == l2_ex_forwarding_waddr) && (l2_ex_forwarding_we == `WriteEnable)) begin
        rdata2 <= l2_ex_forwarding_wdata;
      end
      else if ((raddr2 == ex_forwarding_waddr) && (ex_forwarding_we == `WriteEnable)) begin
        rdata2 <= ex_forwarding_wdata;
      end
      else if ((raddr2 == l2_dcache_forwarding_waddr) && (l2_dcache_forwarding_we == `WriteEnable)) begin
        rdata2 <= l2_dcache_forwarding_wdata;
      end
      else if ((raddr2 == dcache_forwarding_waddr) && (dcache_forwarding_we == `WriteEnable)) begin
        rdata2 <= dcache_forwarding_wdata;
      end
      else if ((raddr2 == l2_mem_forwarding_waddr) && (l2_mem_forwarding_we == `WriteEnable)) begin
        rdata2 <= l2_mem_forwarding_wdata;
      end
      else if ((raddr2 == mem_forwarding_waddr) && (mem_forwarding_we == `WriteEnable)) begin
        rdata2 <= mem_forwarding_wdata;
      end
      else if ((raddr2 == l2_waddr) && (l2_we == `WriteEnable)) begin
        rdata2 <= l2_wdata;
      end  
      else if ((raddr2 == waddr) && (we == `WriteEnable)) begin
        rdata2 <= wdata;
      end    
      else if (re2 == `ReadEnable) begin
        rdata2 <= rf[raddr2];
      end
    end
    else begin
      rdata2 <= `ZeroWord;
    end
  end  

// read l2_reg1
  always @ (*) begin
    if (rst == `RstEnable) begin
      l2_rdata1 <= `ZeroWord;
    end
    else if (l2_re1 == `ReadEnable) begin
      if (l2_raddr1 == 5'd0) begin
        l2_rdata1 <= `ZeroWord;
      end
      else if ((l2_raddr1 == l2_ex_forwarding_waddr) && (l2_ex_forwarding_we == `WriteEnable)) begin
        l2_rdata1 <= l2_ex_forwarding_wdata;
      end
      else if ((l2_raddr1 == ex_forwarding_waddr) && (ex_forwarding_we == `WriteEnable)) begin
        l2_rdata1 <= ex_forwarding_wdata;
      end
      else if ((l2_raddr1 == l2_dcache_forwarding_waddr) && (l2_dcache_forwarding_we == `WriteEnable)) begin
        l2_rdata1 <= l2_dcache_forwarding_wdata;
      end
      else if ((l2_raddr1 == dcache_forwarding_waddr) && (dcache_forwarding_we == `WriteEnable)) begin
        l2_rdata1 <= dcache_forwarding_wdata;
      end
      else if ((l2_raddr1 == l2_mem_forwarding_waddr) && (l2_mem_forwarding_we == `WriteEnable)) begin
        l2_rdata1 <= l2_mem_forwarding_wdata;
      end
      else if ((l2_raddr1 == mem_forwarding_waddr) && (mem_forwarding_we == `WriteEnable)) begin
        l2_rdata1 <= mem_forwarding_wdata;
      end
      else if ((l2_raddr1 == l2_waddr) && (l2_we == `WriteEnable)) begin
        l2_rdata1 <= l2_wdata;
      end
      else if ((l2_raddr1 == waddr) && (we == `WriteEnable)) begin
        l2_rdata1 <= wdata;
      end
      else begin
        l2_rdata1 <= rf[l2_raddr1];
      end
    end
    else begin
      l2_rdata1 <= `ZeroWord;
    end
  end
// read l2_reg2
  always @ (*) begin
    if (rst == `RstEnable) begin
      l2_rdata2 <= `ZeroWord;
    end
    else if (l2_re2 == `ReadEnable) begin
      if (l2_raddr2 == 5'd0) begin
        l2_rdata2 <= `ZeroWord;
      end
      else if ((l2_raddr2 == l2_ex_forwarding_waddr) && (l2_ex_forwarding_we == `WriteEnable)) begin
        l2_rdata2 <= l2_ex_forwarding_wdata;
      end
      else if ((l2_raddr2 == ex_forwarding_waddr) && (ex_forwarding_we == `WriteEnable)) begin
        l2_rdata2 <= ex_forwarding_wdata;
      end
      else if ((l2_raddr2 == l2_dcache_forwarding_waddr) && (l2_dcache_forwarding_we == `WriteEnable)) begin
        l2_rdata2 <= l2_dcache_forwarding_wdata;
      end
      else if ((l2_raddr2 == dcache_forwarding_waddr) && (dcache_forwarding_we == `WriteEnable)) begin
        l2_rdata2 <= dcache_forwarding_wdata;
      end
      else if ((l2_raddr2 == l2_mem_forwarding_waddr) && (l2_mem_forwarding_we == `WriteEnable)) begin
        l2_rdata2 <= l2_mem_forwarding_wdata;
      end
      else if ((l2_raddr2 == mem_forwarding_waddr) && (mem_forwarding_we == `WriteEnable)) begin
        l2_rdata2 <= mem_forwarding_wdata;
      end
      else if ((l2_raddr2 == l2_waddr) && (l2_we == `WriteEnable)) begin
        l2_rdata2 <= l2_wdata;
      end  
      else if ((l2_raddr2 == waddr) && (we == `WriteEnable)) begin
        l2_rdata2 <= wdata;
      end    
      else if (l2_re2 == `ReadEnable) begin
        l2_rdata2 <= rf[l2_raddr2];
      end
    end
    else begin
      l2_rdata2 <= `ZeroWord;
    end
  end  
endmodule