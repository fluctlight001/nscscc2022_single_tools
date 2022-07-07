`default_nettype none


module thinpad_top(
    input wire clk_50M,           //50MHz ʱ������
    input wire clk_11M0592,       //11.0592MHz ʱ�����루���ã��ɲ��ã�

    input wire clock_btn,         //BTN5�ֶ�ʱ�Ӱ�ť���أ���������·������ʱΪ1
    input wire reset_btn,         //BTN6�ֶ���λ��ť���أ���������·������ʱΪ1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4����ť���أ�����ʱΪ1
    input  wire[31:0] dip_sw,     //32λ���뿪�أ�������ON��ʱΪ1
    output wire[15:0] leds,       //16λLED�����ʱ1����
    output wire[7:0]  dpy0,       //����ܵ�λ�źţ�����С���㣬���1����
    output wire[7:0]  dpy1,       //����ܸ�λ�źţ�����С���㣬���1����

    //BaseRAM�ź�
    inout wire[31:0] base_ram_data,  //BaseRAM���ݣ���8λ��CPLD���ڿ���������
    output wire[19:0] base_ram_addr, //BaseRAM��ַ
    output wire[3:0] base_ram_be_n,  //BaseRAM�ֽ�ʹ�ܣ�����Ч�������ʹ���ֽ�ʹ�ܣ��뱣��Ϊ0
    output wire base_ram_ce_n,       //BaseRAMƬѡ������Ч
    output wire base_ram_oe_n,       //BaseRAM��ʹ�ܣ�����Ч
    output wire base_ram_we_n,       //BaseRAMдʹ�ܣ�����Ч

    //ExtRAM�ź�
    inout wire[31:0] ext_ram_data,  //ExtRAM����
    output wire[19:0] ext_ram_addr, //ExtRAM��ַ
    output wire[3:0] ext_ram_be_n,  //ExtRAM�ֽ�ʹ�ܣ�����Ч�������ʹ���ֽ�ʹ�ܣ��뱣��Ϊ0
    output wire ext_ram_ce_n,       //ExtRAMƬѡ������Ч
    output wire ext_ram_oe_n,       //ExtRAM��ʹ�ܣ�����Ч
    output wire ext_ram_we_n,       //ExtRAMдʹ�ܣ�����Ч

    //ֱ�������ź�
    output wire txd,  //ֱ�����ڷ��Ͷ�
    input  wire rxd,  //ֱ�����ڽ��ն�

    //Flash�洢���źţ��ο� JS28F640 оƬ�ֲ�
    output wire [22:0]flash_a,      //Flash��ַ��a0����8bitģʽ��Ч��16bitģʽ������
    inout  wire [15:0]flash_d,      //Flash����
    output wire flash_rp_n,         //Flash��λ�źţ�����Ч
    output wire flash_vpen,         //Flashд�����źţ��͵�ƽʱ���ܲ�������д
    output wire flash_ce_n,         //FlashƬѡ�źţ�����Ч
    output wire flash_oe_n,         //Flash��ʹ���źţ�����Ч
    output wire flash_we_n,         //Flashдʹ���źţ�����Ч
    output wire flash_byte_n,       //Flash 8bitģʽѡ�񣬵���Ч����ʹ��flash��16λģʽʱ����Ϊ1

    //ͼ������ź�
    output wire[2:0] video_red,    //��ɫ���أ�3λ
    output wire[2:0] video_green,  //��ɫ���أ�3λ
    output wire[1:0] video_blue,   //��ɫ���أ�2λ
    output wire video_hsync,       //��ͬ����ˮƽͬ�����ź�
    output wire video_vsync,       //��ͬ������ֱͬ�����ź�
    output wire video_clk,         //����ʱ�����
    output wire video_de,           //��������Ч�źţ���������������

    output wire [31:0] debug_wb_pc,
    output wire [3:0] debug_wb_rf_wen,
    output wire [4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
);

/* =========== Demo code begin =========== */

// PLL��Ƶʾ��
wire locked, clk_10M, clk_20M;
pll_example clock_gen 
 (
  // Clock in ports
  .clk_in1(clk_50M),  // �ⲿʱ������
  // Clock out ports
  .clk_out1(clk_10M), // ʱ�����1��Ƶ����IP���ý��������� // �Ѹĳ�50
  .clk_out2(clk_20M), // ʱ�����2��Ƶ����IP���ý���������
  // Status and control signals
  .reset(reset_btn), // PLL��λ����
  .locked(locked)    // PLL����ָʾ�����"1"��ʾʱ���ȶ���
                     // �󼶵�·��λ�ź�Ӧ���������ɣ����£�
 );

reg reset_of_clk10M;
// �첽��λ��ͬ���ͷţ���locked�ź�תΪ�󼶵�·�ĸ�λreset_of_clk10M
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


// cpu �����rst���Ǹ�λ��Ч
// cpu ����û������
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
    .debug_wb_pc      (debug_wb_pc),
    .debug_wb_rf_wen  (debug_wb_rf_wen),
    .debug_wb_rf_wnum (debug_wb_rf_wnum),
    .debug_wb_rf_wdata(debug_wb_rf_wdata)
);
// cpu ����û������



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
async_receiver #(.ClkFrequency(50000000),.Baud(9600)) //����ģ�飬9600�޼���λ
    ext_uart_r(
        .clk(clk_20M),                       //�ⲿʱ���ź�
        .RxD(rxd),                           //�ⲿ�����ź�����
        .RxD_data_ready(ext_uart_ready),  //���ݽ��յ���־
        .RxD_clear(ext_uart_clear),       //������ձ�־
        .RxD_data(ext_uart_rx)             //���յ���һ�ֽ�����
    );

assign ext_uart_clear = ext_uart_ready; //�յ����ݵ�ͬʱ�������־����Ϊ������ȡ��ext_uart_buffer��
always @(posedge clk_20M) begin //���յ�������ext_uart_buffer
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

always @(posedge clk_20M) begin //��������ext_uart_buffer���ͳ�ȥ
    if(!ext_uart_busy && cpu_data_avai)begin 
        ext_uart_tx <= uart_wdata[7:0];
        ext_uart_start <= 1;
    end else begin 
        ext_uart_start <= 0;
    end
end

async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //����ģ�飬9600�޼���λ
    ext_uart_t(
        .clk(clk_20M),                  //�ⲿʱ���ź�
        .TxD(txd),                      //�����ź����
        .TxD_busy(ext_uart_busy),       //������æ״ָ̬ʾ
        .TxD_start(ext_uart_start),    //��ʼ�����ź�
        .TxD_data(ext_uart_tx)        //�����͵�����
    );

// | ��ַ | λ | ˵�� |
// | --- | --- |--- |
// | 0xBFD003F8| [7:0] | �������ݣ�����д��ַ�ֱ��ʾ���ڽ��ա�����һ���ֽ�|
// | 0xBFD003FC| [0] | ֻ����Ϊ1ʱ��ʾ���ڿ��У��ɷ�������|
// | 0xBFD003FC| [1] | ֻ����Ϊ1ʱ��ʾ�����յ�����|


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

// ��ʹ���ڴ桢����ʱ��������ʹ���ź�
// assign base_ram_ce_n = 1'b1;
// assign base_ram_oe_n = 1'b1;
// assign base_ram_we_n = 1'b1;

// assign ext_ram_ce_n = 1'b1;
// assign ext_ram_oe_n = 1'b1;
// assign ext_ram_we_n = 1'b1;

// ��������ӹ�ϵʾ��ͼ��dpy1ͬ��
// p=dpy0[0] // ---a---
// c=dpy0[1] // |     |
// d=dpy0[2] // f     b
// e=dpy0[3] // |     |
// b=dpy0[4] // ---g---
// a=dpy0[5] // |     |
// f=dpy0[6] // e     c
// g=dpy0[7] // |     |
//           // ---d---  p

// 7���������������ʾ����number��16������ʾ�����������
// wire[7:0] number;
// SEG7_LUT segL(.oSEG1(dpy0), .iDIG(number[3:0])); //dpy0�ǵ�λ�����
// SEG7_LUT segH(.oSEG1(dpy1), .iDIG(number[7:4])); //dpy1�Ǹ�λ�����
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
//     if(reset_btn)begin //��λ���£�����LEDΪ��ʼֵ
//         led_bits <= 16'h1;
//     end
//     else begin //ÿ�ΰ���ʱ�Ӱ�ť��LEDѭ������
//         led_bits <= {led_bits[14:0],led_bits[15]};
//     end
// end

//ֱ�����ڽ��շ�����ʾ����ֱ�������յ��������ٷ��ͳ�ȥ
// wire [7:0] ext_uart_rx;
// reg  [7:0] ext_uart_buffer, ext_uart_tx;
// wire ext_uart_ready, ext_uart_clear, ext_uart_busy;
// reg ext_uart_start, ext_uart_avai;
    
// assign number = ext_uart_buffer;

// async_receiver #(.ClkFrequency(50000000),.Baud(9600)) //����ģ�飬9600�޼���λ
//     ext_uart_r(
//         .clk(clk_50M),                       //�ⲿʱ���ź�
//         .RxD(rxd),                           //�ⲿ�����ź�����
//         .RxD_data_ready(ext_uart_ready),  //���ݽ��յ���־
//         .RxD_clear(ext_uart_clear),       //������ձ�־
//         .RxD_data(ext_uart_rx)             //���յ���һ�ֽ�����
//     );

// assign ext_uart_clear = ext_uart_ready; //�յ����ݵ�ͬʱ�������־����Ϊ������ȡ��ext_uart_buffer��
// always @(posedge clk_50M) begin //���յ�������ext_uart_buffer
//     if(ext_uart_ready)begin
//         ext_uart_buffer <= ext_uart_rx;
//         ext_uart_avai <= 1;
//     end else if(!ext_uart_busy && ext_uart_avai)begin 
//         ext_uart_avai <= 0;
//     end
// end
// always @(posedge clk_50M) begin //��������ext_uart_buffer���ͳ�ȥ
//     if(!ext_uart_busy && ext_uart_avai)begin 
//         ext_uart_tx <= ext_uart_buffer;
//         ext_uart_start <= 1;
//     end else begin 
//         ext_uart_start <= 0;
//     end
// end

// async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //����ģ�飬9600�޼���λ
//     ext_uart_t(
//         .clk(clk_50M),                  //�ⲿʱ���ź�
//         .TxD(txd),                      //�����ź����
//         .TxD_busy(ext_uart_busy),       //������æ״ָ̬ʾ
//         .TxD_start(ext_uart_start),    //��ʼ�����ź�
//         .TxD_data(ext_uart_tx)        //�����͵�����
//     );

// //ͼ�������ʾ���ֱ���800x600@75Hz������ʱ��Ϊ50MHz
// wire [11:0] hdata;
// assign video_red = hdata < 266 ? 3'b111 : 0; //��ɫ����
// assign video_green = hdata < 532 && hdata >= 266 ? 3'b111 : 0; //��ɫ����
// assign video_blue = hdata >= 532 ? 2'b11 : 0; //��ɫ����
// assign video_clk = clk_50M;
// vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at75 (
//     .clk(clk_50M), 
//     .hdata(hdata), //������
//     .vdata(),      //������
//     .hsync(video_hsync),
//     .vsync(video_vsync),
//     .data_enable(video_de)
// );
// /* =========== Demo code end =========== */

endmodule
