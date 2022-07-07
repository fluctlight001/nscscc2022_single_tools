`default_nettype none

module thinpad_top(
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入（备用，可不用）

    input wire clock_btn,         //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input wire reset_btn,         //BTN6手动复位按钮开关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到“ON”时为1
    output wire[15:0] leds,       //16位LED，输出时1点亮
    output wire[7:0]  dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,       //数码管高位信号，包括小数点，输出1点亮

    //BaseRAM信号
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire base_ram_ce_n,       //BaseRAM片选，低有效
    output wire base_ram_oe_n,       //BaseRAM读使能，低有效
    output wire base_ram_we_n,       //BaseRAM写使能，低有效

    //ExtRAM信号
    inout wire[31:0] ext_ram_data,  //ExtRAM数据
    output wire[19:0] ext_ram_addr, //ExtRAM地址
    output wire[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire ext_ram_ce_n,       //ExtRAM片选，低有效
    output wire ext_ram_oe_n,       //ExtRAM读使能，低有效
    output wire ext_ram_we_n,       //ExtRAM写使能，低有效

    //直连串口信号
    output wire txd,  //直连串口发送端
    input  wire rxd,  //直连串口接收端

    //Flash存储器信号，参考 JS28F640 芯片手册
    output wire [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效，16bit模式无意义
    inout  wire [15:0]flash_d,      //Flash数据
    output wire flash_rp_n,         //Flash复位信号，低有效
    output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧写
    output wire flash_ce_n,         //Flash片选信号，低有效
    output wire flash_oe_n,         //Flash读使能信号，低有效
    output wire flash_we_n,         //Flash写使能信号，低有效
    output wire flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1

    //图像输出信号
    output wire[2:0] video_red,    //红色像素，3位
    output wire[2:0] video_green,  //绿色像素，3位
    output wire[1:0] video_blue,   //蓝色像素，2位
    output wire video_hsync,       //行同步（水平同步）信号
    output wire video_vsync,       //场同步（垂直同步）信号
    output wire video_clk,         //像素时钟输出
    output wire video_de,           //行数据有效信号，用于区分消隐区
    
    output wire [31:0] debug_wb_pc,
    output wire [3:0] debug_wb_rf_wen,
    output wire [4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
);

/* =========== Demo code begin =========== */

// PLL分频示例
wire locked, clk_10M, clk_20M, cpu_clk, soc_clk;
pll_example clock_gen 
 (
  // Clock in ports
  .clk_in1(clk_50M),  // 外部时钟输入
  // Clock out ports
  .clk_out1(cpu_clk), // 时钟输出1，频率在IP配置界面中设置
  .clk_out2(soc_clk), // 时钟输出2，频率在IP配置界面中设置
  // Status and control signals
  .reset(reset_btn), // PLL复位输入
  .locked(locked)    // PLL锁定指示输出，"1"表示时钟稳定，
                     // 后级电路复位信号应当由它生成（见下）
 );

reg reset_of_clk10M;
// 异步复位，同步释放，将locked信号转为后级电路的复位reset_of_clk10M
always@(posedge soc_clk or negedge locked) begin
    if(~locked) reset_of_clk10M <= 1'b1;
    else        reset_of_clk10M <= 1'b0;
end

// always@(posedge clk_10M or posedge reset_of_clk10M) begin
//     if(reset_of_clk10M)begin
//         // Your Code
//     end
//     else begin
//         // Your Code
//     end
// end
wire clk, resetn;
assign clk = clk_50M;
assign resetn = ~reset_of_clk10M;

//reg for base ram
reg [31:0] base_ram_data_r;
reg [19:0] base_ram_addr_r;
reg [3:0] base_ram_be_n_r;
reg base_ram_ce_n_r;
reg base_ram_oe_n_r;
reg base_ram_we_n_r;
//reg for ext ram
reg [31:0] ext_ram_data_r;
reg [19:0] ext_ram_addr_r;
reg [3:0] ext_ram_be_n_r;
reg ext_ram_ce_n_r;
reg ext_ram_oe_n_r;
reg ext_ram_we_n_r;

//cpu inst sram
wire        cpu_inst_en;
wire [3 :0] cpu_inst_wen;
wire [31:0] cpu_inst_addr;
wire [31:0] cpu_inst_wdata;
wire [31:0] cpu_inst_rdata;
//cpu data sram
wire        cpu_data_en;
wire [3 :0] cpu_data_wen;
wire [31:0] cpu_data_addr;
wire [31:0] cpu_data_wdata;
wire [31:0] cpu_data_rdata;

assign base_ram_data = ~base_ram_we_n_r ? base_ram_data_r : 32'bz;
assign ext_ram_data  = ~ext_ram_we_n_r  ? ext_ram_data_r  : 32'bz;

assign base_ram_addr = base_ram_addr_r;
assign base_ram_be_n = base_ram_be_n_r;
assign base_ram_ce_n = base_ram_ce_n_r;
assign base_ram_oe_n = base_ram_oe_n_r;
assign base_ram_we_n = base_ram_we_n_r;

assign ext_ram_addr = ext_ram_addr_r;
assign ext_ram_be_n = ext_ram_be_n_r;
assign ext_ram_ce_n = ext_ram_ce_n_r;
assign ext_ram_oe_n = ext_ram_oe_n_r;
assign ext_ram_we_n = ext_ram_we_n_r;

mycpu_top u_mycpu_top(
    .clk               (clk               ),
    .resetn            (resetn            ),
    .ext_int           (6'b0              ),
    .inst_sram_en      (cpu_inst_en       ),
    .inst_sram_wen     (cpu_inst_wen      ),
    .inst_sram_addr    (cpu_inst_addr     ),
    .inst_sram_wdata   (cpu_inst_wdata    ),
    .inst_sram_rdata   (cpu_inst_rdata    ),
    .data_sram_en      (cpu_data_en       ),
    .data_sram_wen     (cpu_data_wen      ),
    .data_sram_addr    (cpu_data_addr     ),
    .data_sram_wdata   (cpu_data_wdata    ),
    .data_sram_rdata   (cpu_data_rdata    ),
    
    .debug_wb_pc       (debug_wb_pc       ),
    .debug_wb_rf_wen   (debug_wb_rf_wen   ),
    .debug_wb_rf_wnum  (debug_wb_rf_wnum  ),
    .debug_wb_rf_wdata (debug_wb_rf_wdata )
);


endmodule
