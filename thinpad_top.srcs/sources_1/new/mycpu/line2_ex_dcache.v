`include "defines.v"
module line2_ex_dcache(
    input wire clk,
    input wire rst,
    input wire [`StallBus] stall,
    input wire flush,

    input wire [`InstAddrBus] ex_pc,
    input wire ex_wreg,
    input wire [`RegAddrBus] ex_waddr,
    input wire [`RegBus] ex_wdata,

    output reg [`InstAddrBus] dcache_pc,
    output reg dcache_wreg,
    output reg [`RegAddrBus] dcache_waddr,
    output reg [`RegBus] dcache_wdata
);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            dcache_pc <= `ZeroWord;
            dcache_wreg <= `WriteDisable;
            dcache_waddr <= `NOPRegAddr;
            dcache_wdata <= `ZeroWord;
        end
        else if (flush == `True_v) begin
            dcache_pc <= `ZeroWord;
            dcache_wreg <= `WriteDisable;
            dcache_waddr <= `NOPRegAddr;
            dcache_wdata <= `ZeroWord;
        end
        else if (stall[5] == `Stop && stall[6] == `NoStop) begin
            dcache_pc <= `ZeroWord;
            dcache_wreg <= `WriteDisable;
            dcache_waddr <= `NOPRegAddr;
            dcache_wdata <= `ZeroWord;
        end
        else if (stall[5] == `NoStop) begin
            dcache_pc <= ex_pc;
            dcache_waddr <= ex_waddr;
            dcache_wreg <= ex_wreg;
            dcache_wdata <= ex_wdata;
        end
    end
endmodule