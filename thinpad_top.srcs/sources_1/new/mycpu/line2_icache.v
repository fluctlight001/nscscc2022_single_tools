`include "defines.v"
module line2_icache(
    input wire clk,
    input wire rst,

    input wire [31:0] pc_i,
    input wire [31:0] inst_i,

    output reg [31:0] l1_pc_o,
    output reg [31:0] l1_inst_o,
    output reg l1_is_ok,
    output reg [31:0] l2_pc_o,
    output reg [31:0] l2_inst_o,
    output wire l2_is_ok_o
);

    reg [`RegBus] icache [31:0];
    reg [`RegBus] pc [31:0];
    reg l2_is_ok;
    wire [`RegBus] l2_pc_plus_4;
    assign l2_pc_plus_4 = pc_i + 32'h4;

    always @ (posedge clk) begin
        if (rst == `RstEnable)begin
            icache[ 0] <= `ZeroWord;
            icache[ 1] <= `ZeroWord;
            icache[ 2] <= `ZeroWord;
            icache[ 3] <= `ZeroWord;
            icache[ 4] <= `ZeroWord;
            icache[ 5] <= `ZeroWord;
            icache[ 6] <= `ZeroWord;
            icache[ 7] <= `ZeroWord;
            icache[ 8] <= `ZeroWord;
            icache[ 9] <= `ZeroWord;
            icache[10] <= `ZeroWord;
            icache[11] <= `ZeroWord;
            icache[12] <= `ZeroWord;
            icache[13] <= `ZeroWord;
            icache[14] <= `ZeroWord;
            icache[15] <= `ZeroWord;
            icache[16] <= `ZeroWord;
            icache[17] <= `ZeroWord;
            icache[18] <= `ZeroWord;
            icache[19] <= `ZeroWord;
            icache[20] <= `ZeroWord;
            icache[21] <= `ZeroWord;
            icache[22] <= `ZeroWord;
            icache[23] <= `ZeroWord;
            icache[24] <= `ZeroWord;
            icache[25] <= `ZeroWord;
            icache[26] <= `ZeroWord;
            icache[27] <= `ZeroWord;
            icache[28] <= `ZeroWord;
            icache[29] <= `ZeroWord;
            icache[30] <= `ZeroWord;
            icache[31] <= `ZeroWord;
            pc[ 0] <= `ZeroWord;
            pc[ 1] <= `ZeroWord;
            pc[ 2] <= `ZeroWord;
            pc[ 3] <= `ZeroWord;
            pc[ 4] <= `ZeroWord;
            pc[ 5] <= `ZeroWord;
            pc[ 6] <= `ZeroWord;
            pc[ 7] <= `ZeroWord;
            pc[ 8] <= `ZeroWord;
            pc[ 9] <= `ZeroWord;
            pc[10] <= `ZeroWord;
            pc[11] <= `ZeroWord;
            pc[12] <= `ZeroWord;
            pc[13] <= `ZeroWord;
            pc[14] <= `ZeroWord;
            pc[15] <= `ZeroWord;
            pc[16] <= `ZeroWord;
            pc[17] <= `ZeroWord;
            pc[18] <= `ZeroWord;
            pc[19] <= `ZeroWord;
            pc[20] <= `ZeroWord;
            pc[21] <= `ZeroWord;
            pc[22] <= `ZeroWord;
            pc[23] <= `ZeroWord;
            pc[24] <= `ZeroWord;
            pc[25] <= `ZeroWord;
            pc[26] <= `ZeroWord;
            pc[27] <= `ZeroWord;
            pc[28] <= `ZeroWord;
            pc[29] <= `ZeroWord;
            pc[30] <= `ZeroWord;
            pc[31] <= `ZeroWord;
        end
        else begin
            icache[pc_i[5:2]] <= inst_i;
            pc[pc_i[5:2]] <= pc_i;
        end
    end

    always @ (*) begin
        if (rst == `RstEnable) begin
            l1_pc_o <= `ZeroWord;
            l1_inst_o <= `ZeroWord;
            l1_is_ok <= `False_v;
        end
        else begin
            case (pc_i)
                pc[pc_i[5:2]]:begin
                    l1_pc_o <= pc_i;
                    l1_inst_o <= icache[pc_i[5:2]];
                    l1_is_ok <= `True_v;
                end
                default: begin
                    l1_pc_o <= `ZeroWord;
                    l1_inst_o <= `ZeroWord;
                    l1_is_ok <= `False_v;
                end
            endcase
        end
    end

    always @ (*) begin
        if (rst == `RstEnable) begin
            l2_pc_o <= `ZeroWord;
            l2_inst_o <= `ZeroWord;
            l2_is_ok <= `False_v;            
        end
        else begin
            case (l2_pc_plus_4)
                pc[l2_pc_plus_4[5:2]]:begin
                    l2_pc_o <= l2_pc_plus_4;
                    l2_inst_o <= icache[l2_pc_plus_4[5:2]];
                    l2_is_ok <= `True_v;
                end
                default:begin
                    l2_pc_o <= `ZeroWord;
                    l2_inst_o <= `ZeroWord;
                    l2_is_ok <= `False_v;  
                end
            endcase 
        end
    end

    assign l2_is_ok_o = l2_inst_o == 32'b0 ? `False_v : l2_is_ok;

endmodule