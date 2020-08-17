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
    output wire video_de           //行数据有效信号，用于区分消隐区
);

/* =========== Demo code begin =========== */

// PLL分频示例
wire locked, clk_10M, clk_20M;
pll_example clock_gen 
 (
  // Clock in ports
  .clk_in1(clk_50M),  // 外部时钟输入
  // Clock out ports
  .clk_out1(clk_10M), // 时钟输出1，频率在IP配置界面中设置 // 已改成50
  .clk_out2(clk_20M), // 时钟输出2，频率在IP配置界面中设置
  // Status and control signals
  .reset(reset_btn), // PLL复位输入
  .locked(locked)    // PLL锁定指示输出，"1"表示时钟稳定，
                     // 后级电路复位信号应当由它生成（见下）
 );

reg reset_of_clk10M;
// 异步复位，同步释放，将locked信号转为后级电路的复位reset_of_clk10M
always@(posedge clk_20M or negedge locked) begin
    if(~locked) reset_of_clk10M <= 1'b1;
    else        reset_of_clk10M <= 1'b0;
end


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


// cpu 里出来rst都是高位有效
// cpu 本身没有问题
mycpu_top u_mycpu(              
    .clk              (clk_20M),
    .resetn           (~reset_of_clk10M),
    .int              (6'b0),

    .inst_sram_en     (cpu_inst_en   ),//1
    .inst_sram_wen    (cpu_inst_wen  ),//0000
    .inst_sram_addr   (cpu_inst_addr ),
    .inst_sram_wdata  (cpu_inst_wdata),
    .inst_sram_rdata  (cpu_inst_rdata),

    .data_sram_en     (cpu_data_en   ),//1
    .data_sram_wen    (cpu_data_wen  ),//sel
    .data_sram_addr   (cpu_data_addr ),
    .data_sram_wdata  (cpu_data_wdata),
    .data_sram_rdata  (cpu_data_rdata),
    .debug_wb_pc(),
    .debug_wb_rf_wen(),
    .debug_wb_rf_wnum(),
    .debug_wb_rf_wdata()
);
// cpu 本身没有问题



reg [31:0] cpu_inst_rdata_r;
reg [31:0] cpu_data_rdata_r;

reg [31:0] base_ram_data_r;
reg [19:0] base_ram_addr_r;
reg [3:0] base_ram_be_n_r;
reg base_ram_ce_n_r;
reg base_ram_oe_n_r;
reg base_ram_we_n_r;

reg [31:0] ext_ram_data_r;
reg [19:0] ext_ram_addr_r;
reg [3:0] ext_ram_be_n_r;
reg ext_ram_ce_n_r;
reg ext_ram_oe_n_r;
reg ext_ram_we_n_r;

reg sel_inst; // 1-inst 0-data for base_ram
reg sel_uart;
reg sel_uart_flag; // 1-flag 0-data

wire [31:0] uart_rdata;
reg [31:0] uart_wdata;

wire [7:0] ext_uart_rx;
reg  [7:0] ext_uart_buffer, ext_uart_tx;
wire ext_uart_ready, ext_uart_clear, ext_uart_busy;
reg ext_uart_start, ext_uart_avai;

reg cpu_data_avai;

reg uart_read_flag;
reg uart_write_flag;

assign base_ram_data = ~base_ram_we_n_r ? base_ram_data_r : 32'bz;
assign ext_ram_data = ~ext_ram_we_n_r ? ext_ram_data_r : 32'bz;

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


// in 
always @ (*) begin
    if (reset_of_clk10M) begin
        cpu_inst_rdata_r <= 32'b0;
        cpu_data_rdata_r <= 32'b0;
    end
    else begin
        cpu_inst_rdata_r <= ~sel_inst ? 32'b0 
                            : ~base_ram_oe_n_r ? base_ram_data 
                            : 32'b0;
        cpu_data_rdata_r <= sel_uart ? uart_rdata : sel_inst ? (~ext_ram_oe_n_r ? ext_ram_data : 32'b0) : (~base_ram_oe_n_r ? base_ram_data : 32'b0);
    end
end
assign cpu_inst_rdata = cpu_inst_rdata_r;
assign cpu_data_rdata = cpu_data_rdata_r;
assign uart_rdata = sel_uart_flag ? {30'b0,ext_uart_avai,~ext_uart_busy} : {24'b0,ext_uart_buffer};

reg [3:0] state;
 
// out 
always @ (posedge clk_20M) begin
    if (reset_of_clk10M) begin
        base_ram_addr_r <= 19'b0;
        base_ram_be_n_r <= 4'b0;
        base_ram_ce_n_r <= 1'b1;
        base_ram_oe_n_r <= 1'b1;
        base_ram_we_n_r <= 1'b1;
        base_ram_data_r <= 32'b0;

        ext_ram_addr_r <= 19'b0;
        ext_ram_be_n_r <= 4'b0;
        ext_ram_ce_n_r <= 1'b1;
        ext_ram_oe_n_r <= 1'b1;
        ext_ram_we_n_r <= 1'b1;
        ext_ram_data_r <= 32'b0;

        sel_inst <= 1'b0;
        sel_uart <= 1'b0;
        sel_uart_flag <= 1'b0;
        uart_wdata <= 32'b0;
        cpu_data_avai <= 1'b0;
        state <= 4'b0;
    end
    else if (cpu_data_addr >=32'h0 && cpu_data_addr <= 32'h003fffff && cpu_data_en) begin
        base_ram_addr_r <= cpu_data_addr[21:2];
        base_ram_be_n_r <= (|cpu_data_wen) ? ~cpu_data_wen : 4'b0;
        base_ram_ce_n_r <= ~cpu_data_en;
        base_ram_oe_n_r <= ~(cpu_data_en & ~(|cpu_data_wen));
        base_ram_we_n_r <= ~(cpu_data_en & (|cpu_data_wen));
        base_ram_data_r <= cpu_data_wdata;

        ext_ram_addr_r <= 19'b0;
        ext_ram_be_n_r <= 4'b0;
        ext_ram_ce_n_r <= 1'b1;
        ext_ram_oe_n_r <= 1'b1;
        ext_ram_we_n_r <= 1'b1;  
        ext_ram_data_r <= 32'b0;

        sel_inst <= 1'b0;
        sel_uart <= 1'b0;
        sel_uart_flag <= 1'b0;
        uart_wdata <= 32'b0;
        cpu_data_avai <= 1'b0;
        state <= 4'b1;
    end
    else if (cpu_data_addr >= 32'h00400000 && cpu_data_addr <= 32'h007fffff && cpu_data_en) begin       
        base_ram_addr_r <= cpu_inst_addr[21:2];
        base_ram_be_n_r <= 4'b0;
        base_ram_ce_n_r <= ~cpu_inst_en;
        base_ram_oe_n_r <= ~cpu_inst_en ;
        base_ram_we_n_r <= 1'b1;
        base_ram_data_r <= cpu_inst_wdata;
        
        ext_ram_addr_r <= cpu_data_addr[21:2];
        ext_ram_be_n_r <= (|cpu_data_wen) ? ~cpu_data_wen : 4'b0;
        ext_ram_ce_n_r <= ~cpu_data_en;
        ext_ram_oe_n_r <= ~(cpu_data_en & ~(|cpu_data_wen));
        ext_ram_we_n_r <= ~(cpu_data_en & (|cpu_data_wen)); 
        ext_ram_data_r <= cpu_data_wdata;

        sel_inst <= 1'b1;
        sel_uart <= 1'b0;
        sel_uart_flag <= 1'b0;
        uart_wdata <= 32'b0;
        cpu_data_avai <= 1'b0;
        state <= 4'd2;
    end
    else if (cpu_data_addr == 32'h1fd003fc) begin
        base_ram_addr_r <= cpu_inst_addr[21:2];
        base_ram_be_n_r <= 4'b0;
        base_ram_ce_n_r <= ~cpu_inst_en;
        base_ram_oe_n_r <= ~cpu_inst_en ;
        base_ram_we_n_r <= 1'b1;
        base_ram_data_r <= cpu_inst_wdata;
      
        ext_ram_addr_r <= 19'b0;
        ext_ram_be_n_r <= 4'b0;
        ext_ram_ce_n_r <= 1'b1;
        ext_ram_oe_n_r <= 1'b1;
        ext_ram_we_n_r <= 1'b1;
        ext_ram_data_r <= 32'b0;

        sel_inst <= 1'b1;
        sel_uart <= 1'b1;
        sel_uart_flag <= 1'b1;
        uart_wdata <= 32'b0;
        cpu_data_avai <= 1'b0;
        state <= 4'd3;
    end
    else if (cpu_data_addr == 32'h1fd003f8 && cpu_data_en) begin        
        base_ram_addr_r <= cpu_inst_addr[21:2];
        base_ram_be_n_r <= 4'b0;
        base_ram_ce_n_r <= ~cpu_inst_en;
        base_ram_oe_n_r <= ~cpu_inst_en ;
        base_ram_we_n_r <= 1'b1;
        base_ram_data_r <= cpu_inst_wdata;
       
        ext_ram_addr_r <= 19'b0;
        ext_ram_be_n_r <= 4'b0;
        ext_ram_ce_n_r <= 1'b1;
        ext_ram_oe_n_r <= 1'b1;
        ext_ram_we_n_r <= 1'b1;
        ext_ram_data_r <= 32'b0;

        sel_inst <= 1'b1;
        sel_uart <= 1'b1;
        sel_uart_flag <= 1'b0;
        uart_wdata <= cpu_data_wdata;
        cpu_data_avai <= (|cpu_data_wen) ? 1'b1 : 1'b0;
        state <= 4'd4;
    end
    else begin        
        base_ram_addr_r <= cpu_inst_addr[21:2];
        base_ram_be_n_r <= 4'b0;
        base_ram_ce_n_r <= ~cpu_inst_en;
        base_ram_oe_n_r <= ~cpu_inst_en ;
        base_ram_we_n_r <= 1'b1;
        base_ram_data_r <= cpu_inst_wdata;
      
        ext_ram_addr_r <= 19'b0;
        ext_ram_be_n_r <= 4'b0;
        ext_ram_ce_n_r <= 1'b1;
        ext_ram_oe_n_r <= 1'b1;
        ext_ram_we_n_r <= 1'b1;
        ext_ram_data_r <= 32'b0;

        sel_inst <= 1'b1;
        sel_uart <= 1'b0;
        sel_uart_flag <= 1'b0;
        uart_wdata <= 32'b0;
        cpu_data_avai <= 1'b0;
        state <= 4'd5;
    end
end


// uart
async_receiver #(.ClkFrequency(59000000),.Baud(9600)) //接收模块，9600无检验位
    ext_uart_r(
        .clk(clk_20M),                       //外部时钟信号
        .RxD(rxd),                           //外部串行信号输入
        .RxD_data_ready(ext_uart_ready),  //数据接收到标志
        .RxD_clear(ext_uart_clear),       //清除接收标志
        .RxD_data(ext_uart_rx)             //接收到的一字节数据
    );

assign ext_uart_clear = ext_uart_ready; //收到数据的同时，清除标志，因为数据已取到ext_uart_buffer中
always @(posedge clk_20M) begin //接收到缓冲区ext_uart_buffer
    if (reset_of_clk10M) begin
        ext_uart_buffer <= 8'b0;
        ext_uart_avai <= 1'b0;
    end
    else if(ext_uart_ready)begin
        ext_uart_buffer <= ext_uart_rx;
        ext_uart_avai <= 1'b1;
    end 
    else if(cpu_data_addr == 32'h1fd003f8 && (cpu_data_en & ~(|cpu_data_wen)) && ext_uart_avai)begin 
        ext_uart_avai <= 1'b0;
    end
end

always @(posedge clk_20M) begin //将缓冲区ext_uart_buffer发送出去
    if(!ext_uart_busy && cpu_data_avai)begin 
        ext_uart_tx <= uart_wdata[7:0];
        ext_uart_start <= 1;
    end else begin 
        ext_uart_start <= 0;
    end
end

async_transmitter #(.ClkFrequency(59000000),.Baud(9600)) //发送模块，9600无检验位
    ext_uart_t(
        .clk(clk_20M),                  //外部时钟信号
        .TxD(txd),                      //串行信号输出
        .TxD_busy(ext_uart_busy),       //发送器忙状态指示
        .TxD_start(ext_uart_start),    //开始发送信号
        .TxD_data(ext_uart_tx)        //待发送的数据
    );

// | 地址 | 位 | 说明 |
// | --- | --- |--- |
// | 0xBFD003F8| [7:0] | 串口数据，读、写地址分别表示串口接收、发送一个字节|
// | 0xBFD003FC| [0] | 只读，为1时表示串口空闲，可发送数据|
// | 0xBFD003FC| [1] | 只读，为1时表示串口收到数据|


// // assign inst_sram_rdata =  base_ram_data;  
// assign base_ram_addr = inst_sram_en ? inst_sram_addr[21:2] : cpu_inst_addr[21:2];
// assign base_ram_be_n = {4{~cpu_inst_en}};
// assign base_ram_ce_n = ~cpu_inst_en;
// assign base_ram_oe_n = ~cpu_inst_en;
// assign base_ram_we_n = ~cpu_inst_wen;

// // assign ext_ram_data = ext_ram_data_r;
// // assign data_sram_rdata = ext_ram_data;
// assign ext_ram_addr = data_sram_addr[21:2];
// assign ext_ram_be_n = 4'b0; //~data_sram_wen & {4{ext_ram_oe_n}};
// assign ext_ram_ce_n = ~data_sram_en;
// assign ext_ram_oe_n = ~(data_sram_en & ~data_sram_wen[0]);
// assign ext_ram_we_n = ~(data_sram_en & data_sram_wen[0]);

// 不使用内存、串口时，禁用其使能信号
// assign base_ram_ce_n = 1'b1;
// assign base_ram_oe_n = 1'b1;
// assign base_ram_we_n = 1'b1;

// assign ext_ram_ce_n = 1'b1;
// assign ext_ram_oe_n = 1'b1;
// assign ext_ram_we_n = 1'b1;

// 数码管连接关系示意图，dpy1同理
// p=dpy0[0] // ---a---
// c=dpy0[1] // |     |
// d=dpy0[2] // f     b
// e=dpy0[3] // |     |
// b=dpy0[4] // ---g---
// a=dpy0[5] // |     |
// f=dpy0[6] // e     c
// g=dpy0[7] // |     |
//           // ---d---  p

// 7段数码管译码器演示，将number用16进制显示在数码管上面
// wire[7:0] number;
// SEG7_LUT segL(.oSEG1(dpy0), .iDIG(number[3:0])); //dpy0是低位数码管
// SEG7_LUT segH(.oSEG1(dpy1), .iDIG(number[7:4])); //dpy1是高位数码管
// reg [7:0] wdata_r;
// reg[15:0] led_bits;
// assign leds = {8'b0,wdata_r};


// always @ (posedge clk_10M) begin
//     if (conf_en & conf_wen[0])begin
//         wdata_r <= conf_wdata[7:0];    
//     end
// end
// assign number = wdata_r;

// always@(posedge clock_btn or posedge reset_btn) begin
//     if(reset_btn)begin //复位按下，设置LED为初始值
//         led_bits <= 16'h1;
//     end
//     else begin //每次按下时钟按钮，LED循环左移
//         led_bits <= {led_bits[14:0],led_bits[15]};
//     end
// end

//直连串口接收发送演示，从直连串口收到的数据再发送出去
// wire [7:0] ext_uart_rx;
// reg  [7:0] ext_uart_buffer, ext_uart_tx;
// wire ext_uart_ready, ext_uart_clear, ext_uart_busy;
// reg ext_uart_start, ext_uart_avai;
    
// assign number = ext_uart_buffer;

// async_receiver #(.ClkFrequency(50000000),.Baud(9600)) //接收模块，9600无检验位
//     ext_uart_r(
//         .clk(clk_50M),                       //外部时钟信号
//         .RxD(rxd),                           //外部串行信号输入
//         .RxD_data_ready(ext_uart_ready),  //数据接收到标志
//         .RxD_clear(ext_uart_clear),       //清除接收标志
//         .RxD_data(ext_uart_rx)             //接收到的一字节数据
//     );

// assign ext_uart_clear = ext_uart_ready; //收到数据的同时，清除标志，因为数据已取到ext_uart_buffer中
// always @(posedge clk_50M) begin //接收到缓冲区ext_uart_buffer
//     if(ext_uart_ready)begin
//         ext_uart_buffer <= ext_uart_rx;
//         ext_uart_avai <= 1;
//     end else if(!ext_uart_busy && ext_uart_avai)begin 
//         ext_uart_avai <= 0;
//     end
// end
// always @(posedge clk_50M) begin //将缓冲区ext_uart_buffer发送出去
//     if(!ext_uart_busy && ext_uart_avai)begin 
//         ext_uart_tx <= ext_uart_buffer;
//         ext_uart_start <= 1;
//     end else begin 
//         ext_uart_start <= 0;
//     end
// end

// async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //发送模块，9600无检验位
//     ext_uart_t(
//         .clk(clk_50M),                  //外部时钟信号
//         .TxD(txd),                      //串行信号输出
//         .TxD_busy(ext_uart_busy),       //发送器忙状态指示
//         .TxD_start(ext_uart_start),    //开始发送信号
//         .TxD_data(ext_uart_tx)        //待发送的数据
//     );

// //图像输出演示，分辨率800x600@75Hz，像素时钟为50MHz
// wire [11:0] hdata;
// assign video_red = hdata < 266 ? 3'b111 : 0; //红色竖条
// assign video_green = hdata < 532 && hdata >= 266 ? 3'b111 : 0; //绿色竖条
// assign video_blue = hdata >= 532 ? 2'b11 : 0; //蓝色竖条
// assign video_clk = clk_50M;
// vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at75 (
//     .clk(clk_50M), 
//     .hdata(hdata), //横坐标
//     .vdata(),      //纵坐标
//     .hsync(video_hsync),
//     .vsync(video_vsync),
//     .data_enable(video_de)
// );
// /* =========== Demo code end =========== */

endmodule
