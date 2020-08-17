`include "defines.v"
module line2_dcache_mem(
    input wire clk,
    input wire rst,
    input wire [`StallBus] stall,
    input wire flush,

    input wire [`InstAddrBus] dcache_pc,
    input wire dcache_wreg,
    input wire [`RegAddrBus] dcache_waddr,
    input wire [`RegBus] dcache_wdata,

    output reg [`InstAddrBus] mem_pc,
    output reg mem_wreg,
    output reg [`RegAddrBus] mem_waddr,
    output reg [`RegBus] mem_wdata
);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            mem_pc <= `ZeroWord;
            mem_wreg <= `WriteDisable;
            mem_waddr <= `NOPRegAddr;
            mem_wdata <= `ZeroWord;
        end
        else if (flush == `True_v) begin
            mem_pc <= `ZeroWord;
            mem_wreg <= `WriteDisable;
            mem_waddr <= `NOPRegAddr;
            mem_wdata <= `ZeroWord;
        end
        else if (stall[6] == `Stop && stall[7] == `NoStop) begin
            mem_pc <= `ZeroWord;
            mem_wreg <= `WriteDisable;
            mem_waddr <= `NOPRegAddr;
            mem_wdata <= `ZeroWord;
        end
        else if (stall[6] == `NoStop) begin
            mem_pc <= dcache_pc;
            mem_wreg <= dcache_wreg;
            mem_waddr <= dcache_waddr;
            mem_wdata <= dcache_wdata;
        end  
    end
endmodule