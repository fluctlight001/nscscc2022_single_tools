`timescale 1ns / 1ps

`define TRACE_REF_FILE "../../../../golden_trace.txt"

module tb;

wire clk_50M, clk_11M0592;

reg clock_btn = 0;         //BTN5�ֶ�ʱ�Ӱ�ť���أ���������·������ʱΪ1
reg reset_btn = 0;         //BTN6�ֶ���λ��ť���أ���������·������ʱΪ1

reg[3:0]  touch_btn;  //BTN1~BTN4����ť���أ�����ʱΪ1
reg[31:0] dip_sw;     //32λ���뿪�أ�����"ON"ʱΪ1

wire[15:0] leds;       //16λLED�����ʱ1����
wire[7:0]  dpy0;       //����ܵ�λ�źţ�����С���㣬���1����
wire[7:0]  dpy1;       //����ܸ�λ�źţ�����С���㣬���1����

wire txd;  //ֱ�����ڷ��Ͷ�
wire rxd;  //ֱ�����ڽ��ն�

wire[31:0] base_ram_data; //BaseRAM���ݣ���8λ��CPLD���ڿ���������
wire[19:0] base_ram_addr; //BaseRAM��ַ
wire[3:0] base_ram_be_n;  //BaseRAM�ֽ�ʹ�ܣ�����Ч�������ʹ���ֽ�ʹ�ܣ��뱣��Ϊ0
wire base_ram_ce_n;       //BaseRAMƬѡ������Ч
wire base_ram_oe_n;       //BaseRAM��ʹ�ܣ�����Ч
wire base_ram_we_n;       //BaseRAMдʹ�ܣ�����Ч

wire[31:0] ext_ram_data; //ExtRAM����
wire[19:0] ext_ram_addr; //ExtRAM��ַ
wire[3:0] ext_ram_be_n;  //ExtRAM�ֽ�ʹ�ܣ�����Ч�������ʹ���ֽ�ʹ�ܣ��뱣��Ϊ0
wire ext_ram_ce_n;       //ExtRAMƬѡ������Ч
wire ext_ram_oe_n;       //ExtRAM��ʹ�ܣ�����Ч
wire ext_ram_we_n;       //ExtRAMдʹ�ܣ�����Ч

wire [22:0]flash_a;      //Flash��ַ��a0����8bitģʽ��Ч��16bitģʽ������
wire [15:0]flash_d;      //Flash����
wire flash_rp_n;         //Flash��λ�źţ�����Ч
wire flash_vpen;         //Flashд�����źţ��͵�ƽʱ���ܲ�������д
wire flash_ce_n;         //FlashƬѡ�źţ�����Ч
wire flash_oe_n;         //Flash��ʹ���źţ�����Ч
wire flash_we_n;         //Flashдʹ���źţ�����Ч
wire flash_byte_n;       //Flash 8bitģʽѡ�񣬵���Ч����ʹ��flash��16λģʽʱ����Ϊ1

wire [31:0] debug_wb_pc;
wire [3:0] debug_wb_rf_wen;
wire [4:0] debug_wb_rf_wnum;
wire [31:0] debug_wb_rf_wdata;

//Windows��Ҫע��·���ָ�����ת�壬����"D:\\foo\\bar.bin"
parameter BASE_RAM_INIT_FILE = "D:\\Project\\lab\\nscscc2022_single_v1\\kernel\\kernel.bin"; //BaseRAM��ʼ���ļ������޸�Ϊʵ�ʵľ���·��
//parameter BASE_RAM_INIT_FILE = "C:\\Users\\Fluctlight\\Desktop\\2020_CPU\\kernel.bin"; //BaseRAM��ʼ���ļ������޸�Ϊʵ�ʵľ���·��
parameter EXT_RAM_INIT_FILE = "C:\\Users\\Fluctlight\\Desktop\\2020_CPU\\matrix.bin"; //BaseRAM��ʼ���ļ������޸�Ϊʵ�ʵľ���·��
//parameter EXT_RAM_INIT_FILE = "C:\\Users\\Fluctlight\\Desktop\\2020_CPU\\crypto.bin"; //BaseRAM��ʼ���ļ������޸�Ϊʵ�ʵľ���·��
//parameter BASE_RAM_INIT_FILE = "C:\\Users\\Fluctlight\\Desktop\\2020_CPU\\nscscc2020_v0.02\\nscscc2020\\supervisor_v2.01\\kernel.bin"; //BaseRAM��ʼ���ļ������޸�Ϊʵ�ʵľ���·��
//parameter BASE_RAM_INIT_FILE = "C:\\Users\\Fluctlight\\Desktop\\2020_CPU\\nscscc2020_v0.02\\nscscc2020\\fpga_template_gbk_v1.00\\asm\\user-sample.bin"; //BaseRAM��ʼ���ļ������޸�Ϊʵ�ʵľ���·��
//parameter EXT_RAM_INIT_FILE = "C:\\Users\\Fluctlight\\Desktop\\2020_CPU\\nscscc2020_v0.02\\nscscc2020\\fpga_template_gbk_v1.00\\asm\\user-sample.bin";    //ExtRAM��ʼ���ļ������޸�Ϊʵ�ʵľ���·��
parameter FLASH_INIT_FILE = "/tmp/kernel.elf";    //Flash��ʼ���ļ������޸�Ϊʵ�ʵľ���·��

assign rxd = 1'b1; //idle state

initial begin 
    //����������Զ�������������У����磺
    dip_sw = 32'h2;
    touch_btn = 0;
    reset_btn = 1;
    #100;
    reset_btn = 0;
    for (integer i = 0; i < 20; i = i+1) begin
        #100; //�ȴ�100ns
        clock_btn = 1; //�����ֹ�ʱ�Ӱ�ť
        #100; //�ȴ�100ns
        clock_btn = 0; //�ɿ��ֹ�ʱ�Ӱ�ť
    end
    // ģ��PCͨ�����ڷ����ַ�
//    cpld.pc_send_byte(8'h32);
//    #10000;
//    cpld.pc_send_byte(8'h33);
end

// �������û����
thinpad_top dut(
    .clk_50M(clk_50M),
    .clk_11M0592(clk_11M0592),
    .clock_btn(clk_50M),
    .reset_btn(reset_btn),
    .touch_btn(touch_btn),
    .dip_sw(dip_sw),
    .leds(leds),
    .dpy1(dpy1),
    .dpy0(dpy0),
    .txd(txd),
    .rxd(txd),
    .base_ram_data(base_ram_data),
    .base_ram_addr(base_ram_addr),
    .base_ram_ce_n(base_ram_ce_n),
    .base_ram_oe_n(base_ram_oe_n),
    .base_ram_we_n(base_ram_we_n),
    .base_ram_be_n(base_ram_be_n),
    .ext_ram_data(ext_ram_data),
    .ext_ram_addr(ext_ram_addr),
    .ext_ram_ce_n(ext_ram_ce_n),
    .ext_ram_oe_n(ext_ram_oe_n),
    .ext_ram_we_n(ext_ram_we_n),
    .ext_ram_be_n(ext_ram_be_n),
    .flash_d(flash_d),
    .flash_a(flash_a),
    .flash_rp_n(flash_rp_n),
    .flash_vpen(flash_vpen),
    .flash_oe_n(flash_oe_n),
    .flash_ce_n(flash_ce_n),
    .flash_byte_n(flash_byte_n),
    .flash_we_n(flash_we_n),
    .debug_wb_pc      (debug_wb_pc),
    .debug_wb_rf_wen  (debug_wb_rf_wen),
    .debug_wb_rf_wnum (debug_wb_rf_wnum),
    .debug_wb_rf_wdata(debug_wb_rf_wdata)
);
// ʱ��Դ
clock osc(
    .clk_11M0592(clk_11M0592),
    .clk_50M    (clk_50M)
);

// BaseRAM ����ģ��
sram_model base1(/*autoinst*/
            .DataIO(base_ram_data[15:0]),
            .Address(base_ram_addr[19:0]),
            .OE_n(base_ram_oe_n),
            .CE_n(base_ram_ce_n),
            .WE_n(base_ram_we_n),
            .LB_n(base_ram_be_n[0]),
            .UB_n(base_ram_be_n[1]));
sram_model base2(/*autoinst*/
            .DataIO(base_ram_data[31:16]),
            .Address(base_ram_addr[19:0]),
            .OE_n(base_ram_oe_n),
            .CE_n(base_ram_ce_n),
            .WE_n(base_ram_we_n),
            .LB_n(base_ram_be_n[2]),
            .UB_n(base_ram_be_n[3]));
// ExtRAM ����ģ��
sram_model ext1(/*autoinst*/
            .DataIO(ext_ram_data[15:0]),
            .Address(ext_ram_addr[19:0]),
            .OE_n(ext_ram_oe_n),
            .CE_n(ext_ram_ce_n),
            .WE_n(ext_ram_we_n),
            .LB_n(ext_ram_be_n[0]),
            .UB_n(ext_ram_be_n[1]));
sram_model ext2(/*autoinst*/
            .DataIO(ext_ram_data[31:16]),
            .Address(ext_ram_addr[19:0]),
            .OE_n(ext_ram_oe_n),
            .CE_n(ext_ram_ce_n),
            .WE_n(ext_ram_we_n),
            .LB_n(ext_ram_be_n[2]),
            .UB_n(ext_ram_be_n[3]));
// Flash ����ģ��
x28fxxxp30 #(.FILENAME_MEM(FLASH_INIT_FILE)) flash(
    .A(flash_a[1+:22]), 
    .DQ(flash_d), 
    .W_N(flash_we_n),    // Write Enable 
    .G_N(flash_oe_n),    // Output Enable
    .E_N(flash_ce_n),    // Chip Enable
    .L_N(1'b0),    // Latch Enable
    .K(1'b0),      // Clock
    .WP_N(flash_vpen),   // Write Protect
    .RP_N(flash_rp_n),   // Reset/Power-Down
    .VDD('d3300), 
    .VDDQ('d3300), 
    .VPP('d1800), 
    .Info(1'b1));

initial begin 
    wait(flash_byte_n == 1'b0);
    $display("8-bit Flash interface is not supported in simulation!");
    $display("Please tie flash_byte_n to high");
    $stop;
end

// ���ļ����� BaseRAM
initial begin 
    reg [31:0] tmp_array[0:1048575];
    integer n_File_ID, n_Init_Size;
    n_File_ID = $fopen(BASE_RAM_INIT_FILE, "rb");
    if(!n_File_ID)begin 
        n_Init_Size = 0;
        $display("Failed to open BaseRAM init file");
    end else begin
        n_Init_Size = $fread(tmp_array, n_File_ID);
        n_Init_Size /= 4;
        $fclose(n_File_ID);
    end
    $display("BaseRAM Init Size(words): %d",n_Init_Size);
    for (integer i = 0; i < n_Init_Size; i++) begin
        base1.mem_array0[i] = tmp_array[i][24+:8];
        base1.mem_array1[i] = tmp_array[i][16+:8];
        base2.mem_array0[i] = tmp_array[i][8+:8];
        base2.mem_array1[i] = tmp_array[i][0+:8];
    end
end

// ���ļ����� ExtRAM
initial begin 
    reg [31:0] tmp_array[0:1048575];
    integer n_File_ID, n_Init_Size;
    n_File_ID = $fopen(EXT_RAM_INIT_FILE, "rb");
    if(!n_File_ID)begin 
        n_Init_Size = 0;
        $display("Failed to open ExtRAM init file");
    end else begin
        n_Init_Size = $fread(tmp_array, n_File_ID);
        n_Init_Size /= 4;
        $fclose(n_File_ID);
    end
    $display("ExtRAM Init Size(words): %d",n_Init_Size);
    for (integer i = 0; i < n_Init_Size; i++) begin
        ext1.mem_array0[i] = tmp_array[i][24+:8];
        ext1.mem_array1[i] = tmp_array[i][16+:8];
        ext2.mem_array0[i] = tmp_array[i][8+:8];
        ext2.mem_array1[i] = tmp_array[i][0+:8];
    end
end



//wdata[i*8+7 : i*8] is valid, only wehile wen[i] is valid
wire [31:0] debug_wb_rf_wdata_v;
assign debug_wb_rf_wdata_v[31:24] = debug_wb_rf_wdata[31:24] & {8{debug_wb_rf_wen[3]}};
assign debug_wb_rf_wdata_v[23:16] = debug_wb_rf_wdata[23:16] & {8{debug_wb_rf_wen[2]}};
assign debug_wb_rf_wdata_v[15: 8] = debug_wb_rf_wdata[15: 8] & {8{debug_wb_rf_wen[1]}};
assign debug_wb_rf_wdata_v[7 : 0] = debug_wb_rf_wdata[7 : 0] & {8{debug_wb_rf_wen[0]}};

// open the trace file;
integer trace_ref;
initial begin
    trace_ref = $fopen(`TRACE_REF_FILE, "w");
end

reg        debug_end;
// generate trace
always @(posedge clk_50M)
begin
    if(|debug_wb_rf_wen && debug_wb_rf_wnum!=5'd0)
    begin
        $fdisplay(trace_ref, "%h %h %h %h", 1'b1,
            debug_wb_pc, debug_wb_rf_wnum, debug_wb_rf_wdata_v);
    end
end
endmodule
