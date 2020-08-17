`include "defines.v"
module line2_mem_wb(
    input wire clk,
    input wire rst,
    input wire [`StallBus] stall,
    input wire flush,

    input wire [31:0] mem_pc, 
    input wire mem_wreg,
    input wire [`RegAddrBus] mem_waddr,
    input wire [`RegBus] mem_wdata,

    output reg [31:0] wb_pc,
    output reg wb_wreg,
    output reg [`RegAddrBus] wb_waddr,
    output reg [`RegBus] wb_wdata
);
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            wb_pc <= `ZeroWord;
            wb_wreg <= `WriteDisable;
            wb_waddr <= `NOPRegAddr;
            wb_wdata <= `ZeroWord;
        end
        else if (flush == `True_v) begin
            wb_pc <= `ZeroWord;
            wb_wreg <= `WriteDisable;
            wb_waddr <= `NOPRegAddr;
            wb_wdata <= `ZeroWord;
        end
        else if (stall[7] == `Stop && stall[8] == `NoStop) begin
            wb_pc <= `ZeroWord;
            wb_wreg <= `WriteDisable;
            wb_waddr <= `NOPRegAddr;
            wb_wdata <= `ZeroWord;
        end
        else if (stall[7] == `NoStop) begin
            wb_pc <= mem_pc;
            wb_wreg <= mem_wreg;
            wb_waddr <= mem_waddr;
            wb_wdata <= mem_wdata;
        end
    end
endmodule