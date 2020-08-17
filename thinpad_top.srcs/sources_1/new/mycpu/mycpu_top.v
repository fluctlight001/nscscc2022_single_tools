`include "defines.v"

module mycpu_top(
  input wire clk,
  input wire resetn,
  input wire [5:0] int,
  
  output wire inst_sram_en,
  output wire [3:0] inst_sram_wen,
  output wire [31:0] inst_sram_addr,
  output wire [31:0] inst_sram_wdata,
  input wire [31:0] inst_sram_rdata,
  
  output wire data_sram_en,
  output wire [3:0] data_sram_wen,
  output wire [31:0] data_sram_addr,
  output wire [31:0] data_sram_wdata,
  input wire [31:0] data_sram_rdata,
  
  output wire [31:0] debug_wb_pc,
  output wire [3:0] debug_wb_rf_wen,
  output wire [4:0] debug_wb_rf_wnum,
  output wire [31:0] debug_wb_rf_wdata
);
  wire rst;
  assign rst = ~resetn;
// pc - pre_icache 
  wire [`InstAddrBus] pc_pc_o;
  wire pc_ce_o;

// pre_icache
  wire [`InstAddrBus] icache_pc_i;
  wire icache_ce_i;

// icache - if_id
  wire [`InstAddrBus] if_pc_o;
  wire [`InstBus] if_inst_o;

// if_id - decoder
  wire [`InstAddrBus] id_pc_i;
  wire [`InstBus] id_inst_i;

// decoder - id_ex
  wire [`AluOpBus] id_aluop_o;
  wire [`AluSelBus] id_alusel_o;
  wire [`RegBus] id_reg1_o;
  wire [`RegBus] id_reg2_o;
  wire [`RegAddrBus] id_waddr_o;
  wire id_wreg_o;
  wire [`RegBus] id_inst_o;
  wire [`InstAddrBus] id_pc_o;

// decoder - regfile
  wire reg1_read;
  wire reg2_read;
  wire [`RegBus] reg1_data;
  wire [`RegBus] reg2_data;
  wire [`RegAddrBus] reg1_addr;
  wire [`RegAddrBus] reg2_addr;

// id_ex - ex
  wire [`AluOpBus] ex_aluop_i;
  wire [`AluSelBus] ex_alusel_i;
  wire [`RegBus] ex_reg1_i;
  wire [`RegBus] ex_reg2_i;
  wire [`RegAddrBus] ex_waddr_i;
  wire ex_wreg_i;
  wire [`RegBus] ex_inst_i;
  wire [`InstAddrBus] ex_pc_i;

// ex - ex_premem
  wire [`RegAddrBus] ex_waddr_o;
  wire ex_wreg_o;
  wire [`RegBus] ex_wdata_o;

  wire [`AluOpBus] ex_aluop_o;
  wire [`RegBus] ex_mem_addr_o;
  wire [`RegBus] ex_reg2_o;

  wire [`RegBus] ex_hi_o;
  wire [`RegBus] ex_lo_o;
  wire ex_whilo_o;

  wire ex_cp0_reg_we_o;
  wire [4:0] ex_cp0_reg_write_addr_o;
  wire [`RegBus] ex_cp0_reg_data_o;

  wire [`InstAddrBus] ex_pc_o;

// ex_premem - premem
  wire [`AluOpBus] premem_aluop;
  wire [`RegBus] premem_mem_addr_i;
  wire [`RegBus] premem_reg2_i;

  wire [`InstAddrBus] premem_pc_i;

// ex_premem - pre_dcache
  wire [`RegAddrBus] premem_waddr;
  wire premem_wreg;
  wire [`RegBus] premem_wdata;

  wire [`RegBus] premem_hi;
  wire [`RegBus] premem_lo;
  wire premem_whilo;

  wire premem_cp0_reg_we;
  wire [4:0] premem_cp0_reg_write_addr;
  wire [`RegBus] premem_cp0_reg_data;

// premem - pre_dcache
  // wire [`RegAddrBus] premem_waddr_o;
  // wire premem_wreg_o;
  // wire [`RegBus] premem_wdata_o;

  // wire [`RegBus] premem_hi_o;
  // wire [`RegBus] premem_lo_o;
  // wire premem_whilo_o;

  // wire [`AluOpBus] premem_aluop_o;

  wire premem_we_o;
  wire [3:0] premem_sel_o;
  wire [`RegBus] premem_data_o;
  wire premem_ce_o;

  wire [`InstAddrBus] premem_pc_o;

// premem - mmu 
  wire [`RegBus] premem_addr_un_mmu;
  wire [`RegBus] premem_addr_mmu;

// mmu - pre_dcache
  wire mmu_cache_o;

// pre_dcache - dcache
  wire [`RegBus] dcache_addr_i;
  wire dcache_we_i;
  wire [3:0] dcache_sel_i;
  wire [`RegBus] dcache_data_i;
  wire dcache_ce_i;
  wire dcache_cache_i;

// dcache - dcache_mem
  wire [`RegBus] dcache_data_o;

// pre_dcache (- dcache) - dcache_mem
  wire [`RegAddrBus] dcache_waddr;
  wire dcache_wreg;
  wire [`RegBus] dcache_wdata;

  wire [`RegBus] dcache_hi;
  wire [`RegBus] dcache_lo;
  wire dcache_whilo;

  wire [`AluOpBus] dcache_aluop;
  wire [`RegBus] dcache_addr;

  wire dcache_cp0_reg_we;
  wire [4:0] dcache_cp0_reg_write_addr;
  wire [`RegBus] dcache_cp0_reg_data;
  
  wire [`RegBus] dcache_pc;

// dcache_mem - mem
  wire [`RegAddrBus] mem_waddr_i;
  wire mem_wreg_i;
  wire [`RegBus] mem_wdata_i;

  wire [`RegBus] mem_hi_i;
  wire [`RegBus] mem_lo_i;
  wire mem_whilo_i;

  wire [`AluOpBus] mem_aluop_i;
  wire [`RegBus] mem_addr_i;
  wire [`RegBus] mem_data_i;
  wire [`RegBus] mem_pc_i;

// dcache_mem - mem_wb
  wire mem_cp0_reg_we;
  wire [4:0] mem_cp0_reg_write_addr;
  wire [`RegBus] mem_cp0_reg_data;

// mem - mem_wb
  wire [`RegAddrBus] mem_waddr_o;
  wire mem_wreg_o;
  wire [`RegBus] mem_wdata_o;

  wire [`RegBus] mem_hi_o;
  wire [`RegBus] mem_lo_o;
  wire mem_whilo_o;

  wire [`RegBus] mem_pc_o;

// mem_wb - regfile
  wire [`RegAddrBus] wb_waddr_i;
  wire wb_wreg_i;
  wire [`RegBus] wb_wdata_i;

// hilo_reg - ex
  wire [`RegBus] hi_i;
  wire [`RegBus] lo_i;

// mem_wb - HILO
  wire [`RegBus] wb_hi_i;
  wire [`RegBus] wb_lo_i;
  wire wb_whilo_i;

// mem_wb - cp0_reg
  wire cp0_reg_we_i;
  wire [4:0] cp0_reg_write_addr_i;
  wire [`RegBus] cp0_reg_data_i;

// cp0_reg - ex
  wire [`RegBus] cp0_reg_data_o;

// ex - cp0_reg
  wire [4:0] cp0_reg_read_addr_i;

// stall
  wire [`StallBus] stall;
  wire stallreq_from_id;
  wire stallreq_from_ex;
  wire stallreq_from_icache;
  wire stallreq_from_dcache;

// excepttype
  wire flush;
  wire [`RegBus] new_pc;
  wire [31:0] pc_excepttype_o;
  wire [31:0] icache_excepttype;
  wire [31:0] id_excepttype_i;
  wire [31:0] id_excepttype_o;
  wire [31:0] ex_excepttype_i;
  wire [31:0] ex_excepttype_o;
  wire ex_is_in_delayslot_o;
  wire [`RegBus] ex_badvaddr_o;
  wire [31:0] premem_excepttype;
  wire premem_is_in_delayslot;
  wire [`RegBus] premem_badvaddr;
  wire [31:0] dcache_excepttype;
  wire dcache_is_in_delayslot;
  wire [`RegBus] dcache_badvaddr;
  wire [31:0] mem_excepttype_i;
  wire mem_is_in_delayslot_i;
  wire [`RegBus] mem_badvaddr_i;
  wire [31:0] mem_excepttype_o;
  wire [`RegBus] mem_cp0_epc_o;
  wire mem_is_in_delayslot_o;
  wire [`RegBus] mem_badvaddr_o;

  wire [`RegBus] mem_cp0_status_i;
  wire [`RegBus] mem_cp0_cause_i;
  wire [`RegBus] mem_cp0_epc_i;

// ex - mul
  wire mul_start;
  wire [`RegBus] mul_op1;
  wire [`RegBus] mul_op2;
  wire mul_signed;
  wire [`DoubleRegBus] result_mul;
  wire result_is_ok;

// ex - div
  wire div_start;
	wire[`RegBus] div_op1;
	wire[`RegBus] div_op2;
	wire div_signed;
	wire[`DoubleRegBus] div_result;
	wire div_ready;

// jump & branch
  wire id_pc_branch_flag;                     // id -> pc
  wire [`RegBus] id_pc_branch_target_address; // id -> pc
  wire next_inst_in_delayslot;                // id -> id_ex
  wire [`RegBus] id_link_address_o;           // id -> id_ex
  wire id_is_in_delayslot_o;                  // id -> id_ex
  wire id_is_in_delayslot_i;                  // id_ex -> id
  wire [`RegBus] ex_link_addrss_i;            // id_ex -> ex
  wire ex_is_in_delayslot_i;                  // id_ex -> ex

// axi & cache
  // icache to axi
  wire [`InstAddrBus] icache_pc_o;
  wire isMiss_from_icache;
  // axi to icache
  wire icache_we_w;
  wire [`InstAddrBus] icache_pc_w;
  wire [`InstBus] icache_inst_w;
  wire last_for_icache;
  // dcache to axi
  wire [`RegBus] dcache_mem_addr_i;
  wire dcache_mem_we_i;
  wire [3:0] dcache_mem_sel_i;
  wire [`RegBus] dcache_mem_data_i;
  wire dcache_mem_ce_i;
  wire isMiss_from_dcache;
  wire dcache_cache_o;
  // axi to dcache
  wire [`RegBus] dcache_mem_addr_w;
  wire dcache_mem_we_w;
  wire [`RegBus] dcache_mem_data_w;
  wire dcache_cache_w;
  wire dcache_last_w;

// debug
  assign debug_wb_rf_wen = {4{wb_wreg_i}};
  assign debug_wb_rf_wnum = wb_waddr_i;
  assign debug_wb_rf_wdata = wb_wdata_i;


// LINE2
  wire l2_pc_plus_4_req;
  // l2: icache - pre_decoder
    wire [31:0] l1_icache_decoder_pc;
    wire [31:0] l1_icache_decoder_inst;
    wire l1_is_ok;
    wire [31:0] l2_icache_decoder_pc;
    wire [31:0] l2_icache_decoder_inst;
    wire l2_is_ok;

  // l2: pre_decoder - if_id
    wire [`AluSelBus] l1_decoder_alusel_o;
    wire [`RegAddrBus] l1_decoder_waddr_o;
    wire l1_decoder_wreg_o;
    wire [`InstAddrBus] l2_decoder_pc;
    wire l2_decoder_reg1_read;
    wire l2_decoder_reg2_read;
    wire [`RegAddrBus] l2_decoder_reg1_addr;
    wire [`RegAddrBus] l2_decoder_reg2_addr;
    wire [`AluOpBus] l2_decoder_aluop;
    wire [`AluSelBus] l2_decoder_alusel;
    wire [`RegAddrBus] l2_decoder_waddr;
    wire l2_decoder_wreg;
    wire [`RegBus] l2_decoder_imm;
    wire [`InstAddrBus] l2_decoder_pc_o;
    wire l2_decoder_reg1_read_o;
    wire l2_decoder_reg2_read_o;
    wire [`RegAddrBus] l2_decoder_reg1_addr_o;
    wire [`RegAddrBus] l2_decoder_reg2_addr_o;
    wire [`AluOpBus] l2_decoder_aluop_o;
    wire [`AluSelBus] l2_decoder_alusel_o;
    wire [`RegAddrBus] l2_decoder_waddr_o;
    wire l2_decoder_wreg_o;
    wire [`RegBus] l2_decoder_imm_o;
    wire l1_run;
    wire l2_run;

  // l2: if_id - id_ex
    wire [`InstAddrBus] l2_regfile_pc;
    wire l2_regfile_reg1_read;
    wire l2_regfile_reg2_read;
    wire [`RegAddrBus] l2_regfile_reg1_addr;
    wire [`RegAddrBus] l2_regfile_reg2_addr;
    wire [`AluOpBus] l2_regfile_aluop;
    wire [`AluSelBus] l2_regfile_alusel;
    wire [`RegAddrBus] l2_regfile_waddr;
    wire l2_regfile_wreg;
    wire [`RegBus] l2_regfile_imm;

  // l2: regfile - id_ex
    wire [`RegBus] l2_regfile_reg1_rdata;
    wire [`RegBus] l2_regfile_reg2_rdata;

  // l2: id_ex - ex
    wire [`InstAddrBus] l2_ex_pc;
    wire l2_ex_reg1_read;
    wire l2_ex_reg2_read;
    wire [`RegAddrBus] l2_ex_reg1_addr;
    wire [`RegAddrBus] l2_ex_reg2_addr;
    wire [`AluOpBus] l2_ex_aluop;
    wire [`AluSelBus] l2_ex_alusel;
    wire [`RegAddrBus] l2_ex_waddr;
    wire l2_ex_wreg;
    wire [`RegBus] l2_ex_imm;
    wire [`RegBus] l2_ex_reg1_rdata;
    wire [`RegBus] l2_ex_reg2_rdata;

  // l2: ex - ex_dcache
    wire [`InstAddrBus] l2_ex_pc_o;
    wire [`RegAddrBus] l2_ex_waddr_o;
    wire l2_ex_wreg_o;
    wire [`RegBus] l2_ex_wdata_o;

  // l2: ex_dcache - dcache_mem
    wire [`InstAddrBus] l2_dcache_pc;
    wire [`RegAddrBus] l2_dcache_waddr;
    wire l2_dcache_wreg;
    wire [`RegBus] l2_dcache_wdata;

  // l2: dcache_mem - mem_wb
    wire [`InstAddrBus] l2_mem_pc;
    wire [`RegAddrBus] l2_mem_waddr;
    wire l2_mem_wreg;
    wire [`RegBus] l2_mem_wdata;

  // l2: wb
    wire [`InstAddrBus] l2_wb_pc;
    wire [`RegAddrBus] l2_wb_waddr;
    wire l2_wb_wreg;
    wire [`RegBus] l2_wb_wdata;
    

 
  pc u_pc(
    .clk(clk), .rst(rst), .stall(stall),
    .flush(flush), .new_pc(new_pc),
    .branch_flag_i(id_pc_branch_flag), .branch_target_address_i(id_pc_branch_target_address),
    .l2_pc_plus_4_req(l2_pc_plus_4_req),
    .pc(pc_pc_o), .ce(pc_ce_o),
    .excepttype_o(pc_excepttype_o)
  );

  wire [`InstAddrBus] pc_pc_o_with_l2;
  assign pc_pc_o_with_l2 = l2_pc_plus_4_req ? pc_pc_o + 32'h4 : pc_pc_o;
  pre_icache u_pre_icache(
    .clk(clk), .rst(rst), .stall(stall), .flush(flush),
    .new_pc(new_pc), .branch_flag_i(id_pc_branch_flag), .branch_target_address_i(id_pc_branch_target_address),
    .pc_pc(pc_pc_o_with_l2), 
    .icache_pc(icache_pc_i), 
    .pc_excepttype(pc_excepttype_o), .icache_excepttype(icache_excepttype)
  );

  line2_icache u_l2_icache(
    .clk(clk), .rst(rst),
    .pc_i(icache_pc_i), .inst_i(inst_sram_rdata),
    .l1_pc_o(l1_icache_decoder_pc), .l1_inst_o(l1_icache_decoder_inst), .l1_is_ok(l1_is_ok),
    .l2_pc_o(l2_icache_decoder_pc), .l2_inst_o(l2_icache_decoder_inst), .l2_is_ok_o(l2_is_ok)
  );

  line2_pre_decoder u_l1_pre_decoder(
    .rst(rst), .pc_i(l1_icache_decoder_pc), .inst_i(l1_icache_decoder_inst), 
    .pc_o(), //.inst_o(),
    .reg1_read_o(), .reg2_read_o(), 
    .reg1_addr_o(), .reg2_addr_o(),
    .aluop_o(), .alusel_o(l1_decoder_alusel_o),
    .waddr_o(l1_decoder_waddr_o), .wreg_o(l1_decoder_wreg_o),
    .imm_o(),
    .l1_run(l1_run), .l2_run()
  );

  line2_pre_decoder u_l2_pre_decoder(
    .rst(rst), .pc_i(l2_icache_decoder_pc), .inst_i(l2_icache_decoder_inst), 
    .pc_o(l2_decoder_pc), //.inst_o(),
    .reg1_read_o(l2_decoder_reg1_read), .reg2_read_o(l2_decoder_reg2_read), 
    .reg1_addr_o(l2_decoder_reg1_addr), .reg2_addr_o(l2_decoder_reg2_addr),
    .aluop_o(l2_decoder_aluop), .alusel_o(l2_decoder_alusel),
    .waddr_o(l2_decoder_waddr), .wreg_o(l2_decoder_wreg),
    .imm_o(l2_decoder_imm),
    .l1_run(), .l2_run(l2_run)
  );

  // assign l2_pc_plus_4_req = `False_v;
  // & (dcache_aluop != `LW) & (dcache_aluop != `LB)
  // & (ex_aluop_o != `LW) & (ex_aluop_o != `LB) 
  // assign l2_pc_plus_4_req = (id_alusel_o != `EXE_JUMP_BRANCH) & (id_alusel_o != `EXE_LOAD_STORE) & (l1_run & l2_run) & (l1_is_ok & l2_is_ok) ? 
  //                           (l1_decoder_wreg_o ? 
  //                           ((l1_decoder_waddr_o == l2_decoder_reg1_addr) || (l1_decoder_waddr_o == l2_decoder_reg2_addr) ? `False_v : `True_v ) : `True_v) : `False_v;     

  assign l2_pc_plus_4_req = ~id_pc_branch_flag & ~((id_alusel_o == `EXE_LOAD_STORE) & (id_wreg_o || id_waddr_o == l2_decoder_reg1_addr || id_waddr_o == l2_decoder_reg2_addr)) & (l1_run & l2_run) & (l1_is_ok & l2_is_ok) ? 
                            (l1_decoder_wreg_o ? 
                            ((l1_decoder_waddr_o == l2_decoder_reg1_addr) || (l1_decoder_waddr_o == l2_decoder_reg2_addr) ? `False_v : `True_v ) : `True_v) : `False_v;  

  assign l2_decoder_pc_o = l2_pc_plus_4_req ? l2_decoder_pc : `ZeroWord;
  assign l2_decoder_reg1_read_o = l2_pc_plus_4_req ? l2_decoder_reg1_read : `False_v;
  assign l2_decoder_reg2_read_o = l2_pc_plus_4_req ? l2_decoder_reg2_read : `False_v;
  assign l2_decoder_reg1_addr_o = l2_pc_plus_4_req ? l2_decoder_reg1_addr : `NOPRegAddr;
  assign l2_decoder_reg2_addr_o = l2_pc_plus_4_req ? l2_decoder_reg2_addr : `NOPRegAddr;
  assign l2_decoder_aluop_o = l2_pc_plus_4_req ? l2_decoder_aluop : `NOP;
  assign l2_decoder_alusel_o = l2_pc_plus_4_req ? l2_decoder_alusel : `EXE_NOP;
  assign l2_decoder_waddr_o = l2_pc_plus_4_req ? l2_decoder_waddr : `NOPRegAddr;
  assign l2_decoder_wreg_o = l2_pc_plus_4_req ? l2_decoder_wreg : `WriteDisable;
  assign l2_decoder_imm_o = l2_pc_plus_4_req ? l2_decoder_imm : `ZeroWord;


  line2_if_id u_l2_if_id(
    .clk(clk), .rst(rst), .stall(stall), .flush(flush),
    .if_pc(l2_decoder_pc_o), 
    .if_reg1_read(l2_decoder_reg1_read_o), .if_reg2_read(l2_decoder_reg2_read_o), 
    .if_reg1_addr(l2_decoder_reg1_addr_o), .if_reg2_addr(l2_decoder_reg2_addr_o),
    .if_aluop(l2_decoder_aluop_o), .if_alusel(l2_decoder_alusel_o),
    .if_waddr(l2_decoder_waddr_o), .if_wreg(l2_decoder_wreg_o),
    .if_imm(l2_decoder_imm_o),
    .id_pc(l2_regfile_pc), 
    .id_reg1_read(l2_regfile_reg1_read), .id_reg2_read(l2_regfile_reg2_read),
    .id_reg1_addr(l2_regfile_reg1_addr), .id_reg2_addr(l2_regfile_reg2_addr),
    .id_aluop(l2_regfile_aluop), .id_alusel(l2_regfile_alusel),
    .id_waddr(l2_regfile_waddr), .id_wreg(l2_regfile_wreg),
    .id_imm(l2_regfile_imm)
  );

  wire [`RegBus] l2_regfile_reg1_rdata_o;
  wire [`RegBus] l2_regfile_reg2_rdata_o;
  wire dcache_inst_is_load = ((dcache_aluop == `LB) ||
                              (dcache_aluop == `LBU) ||
                              (dcache_aluop == `LH) ||
                              (dcache_aluop == `LHU) ||
                              (dcache_aluop == `LW)) ? `True_v : `False_v;

  assign l2_regfile_reg1_rdata_o = (dcache_inst_is_load == `True_v) & (dcache_waddr == l2_regfile_reg1_addr) & l2_regfile_reg1_read ? data_sram_rdata : l2_regfile_reg1_rdata;
  assign l2_regfile_reg2_rdata_o = (dcache_inst_is_load == `True_v) & (dcache_waddr == l2_regfile_reg2_addr) & l2_regfile_reg2_read ? data_sram_rdata : l2_regfile_reg2_rdata;

  line2_id_ex u_l2_id_ex(
    .clk(clk), .rst(rst), .stall(stall), .flush(flush),
    .id_pc(l2_regfile_pc), 
    .id_reg1_read(l2_regfile_reg1_read), .id_reg2_read(l2_regfile_reg2_read),
    .id_reg1_addr(l2_regfile_reg1_addr), .id_reg2_addr(l2_regfile_reg2_addr),
    .id_aluop(l2_regfile_aluop), .id_alusel(l2_regfile_alusel),
    .id_waddr(l2_regfile_waddr), .id_wreg(l2_regfile_wreg),
    .id_imm(l2_regfile_imm),
    .id_reg1_rdata(l2_regfile_reg1_rdata_o), .id_reg2_rdata(l2_regfile_reg2_rdata_o),
    .ex_pc(l2_ex_pc), 
    .ex_reg1_read(l2_ex_reg1_read), .ex_reg2_read(l2_ex_reg2_read),
    .ex_reg1_addr(l2_ex_reg1_addr), .ex_reg2_addr(l2_ex_reg2_addr),
    .ex_aluop(l2_ex_aluop), .ex_alusel(l2_ex_alusel),
    .ex_waddr(l2_ex_waddr), .ex_wreg(l2_ex_wreg),
    .ex_imm(l2_ex_imm),
    .ex_reg1_rdata(l2_ex_reg1_rdata), .ex_reg2_rdata(l2_ex_reg2_rdata)
  );

  line2_ex u_l2_ex(
    .rst(rst), .pc_i(l2_ex_pc), .pc_o(l2_ex_pc_o),
    .reg1_read_i(l2_ex_reg1_read), .reg2_read_i(l2_ex_reg2_read),
    .reg1_addr_i(l2_ex_reg1_addr), .reg2_addr_i(l2_ex_reg2_addr),
    .aluop_i(l2_ex_aluop), .alusel_i(l2_ex_alusel),
    .waddr_i(l2_ex_waddr), .wreg_i(l2_ex_wreg),
    .imm_i(l2_ex_imm),
    .reg1_rdata_i(l2_ex_reg1_rdata), .reg2_rdata_i(l2_ex_reg2_rdata),
    // .l1_ex_we(ex_wreg_o), .l1_ex_waddr(ex_waddr_o), .l1_ex_wdata(ex_wdata_o),
    .waddr_o(l2_ex_waddr_o), .wreg_o(l2_ex_wreg_o), .wdata_o(l2_ex_wdata_o)
  );

  line2_ex_dcache u_l2_ex_dcache(
    .clk(clk), .rst(rst), .stall(stall), .flush(flush),
    .ex_pc(l2_ex_pc_o), .ex_wreg(l2_ex_wreg_o), .ex_waddr(l2_ex_waddr_o), .ex_wdata(l2_ex_wdata_o),
    .dcache_pc(l2_dcache_pc), .dcache_wreg(l2_dcache_wreg), .dcache_waddr(l2_dcache_waddr), .dcache_wdata(l2_dcache_wdata) 
  );

  line2_dcache_mem u_l2_dcache_mem(
    .clk(clk), .rst(rst), .stall(stall), .flush(flush),
    .dcache_pc(l2_dcache_pc), .dcache_wreg(l2_dcache_wreg), .dcache_waddr(l2_dcache_waddr), .dcache_wdata(l2_dcache_wdata),
    .mem_pc(l2_mem_pc), .mem_wreg(l2_mem_wreg), .mem_waddr(l2_mem_waddr), .mem_wdata(l2_mem_wdata) 
  );

  line2_mem_wb u_l2_mem_wb(
    .clk(clk), .rst(rst), .stall(stall), .flush(flush),
    .mem_pc(l2_mem_pc), .mem_wreg(l2_mem_wreg), .mem_waddr(l2_mem_waddr), .mem_wdata(l2_mem_wdata),
    .wb_pc(l2_wb_pc), .wb_wreg(l2_wb_wreg), .wb_waddr(l2_wb_waddr), .wb_wdata(l2_wb_wdata) 
  );

  assign inst_sram_en = rst ? `False_v : pc_ce_o;
  assign inst_sram_wen = 4'b0000;
  assign inst_sram_addr = rst ? `ZeroWord : 
                          flush ? new_pc : 
                          id_pc_branch_flag ? id_pc_branch_target_address : 
                          l2_pc_plus_4_req ? pc_pc_o + 32'h4 :
                          pc_pc_o;
  assign inst_sram_wdata = `ZeroWord;
  
  if_id u_if_id(
    .clk(clk), .rst(rst), .stall(stall), .flush(flush),
    .if_pc(icache_pc_i), .if_inst(inst_sram_rdata),
    .id_pc(id_pc_i), .id_inst(id_inst_i),
    .icache_excepttype(icache_excepttype), .id_excepttype(id_excepttype_i)
  );

  decoder u_decoder(
    .rst(rst), .stallreq(stallreq_from_id),
    .pc_i(id_pc_i), .inst_i(id_inst_i),
    .pc_o(id_pc_o), .inst_o(id_inst_o),
    .reg1_read_o(reg1_read), .reg2_read_o(reg2_read), .reg1_addr_o(reg1_addr), .reg2_addr_o(reg2_addr),
    .reg1_data_i(reg1_data), .reg2_data_i(reg2_data),
    .aluop_o(id_aluop_o), .alusel_o(id_alusel_o), .reg1_o(id_reg1_o), .reg2_o(id_reg2_o),
    .waddr_o(id_waddr_o), .wreg_o(id_wreg_o),
    .is_in_delayslot_i(id_is_in_delayslot_i), .next_inst_in_delayslot_o(next_inst_in_delayslot),
    .branch_flag_o(id_pc_branch_flag), .branch_target_address_o(id_pc_branch_target_address),
    .link_addr_o(id_link_address_o), .is_in_delayslot_o(id_is_in_delayslot_o),
    .ex_waddr_i(ex_waddr_o), .ex_aluop_i(ex_aluop_o), .ex_mem_addr_i(ex_mem_addr_o),
    // .premem_waddr_i(premem_waddr), .premem_aluop_i(premem_aluop),
    .dcache_waddr_i(dcache_waddr), .dcache_aluop_i(dcache_aluop), .dcache_wdata_i(data_sram_rdata),
    .excepttype_i(id_excepttype_i), .excepttype_o(id_excepttype_o)
  );

  regfile u_regfile(
    .clk(clk), .rst(rst),
    .we(wb_wreg_i), .waddr(wb_waddr_i), .wdata(wb_wdata_i),
    .l2_we(l2_wb_wreg), .l2_waddr(l2_wb_waddr), .l2_wdata(l2_wb_wdata),
    .re1(reg1_read), .raddr1(reg1_addr), .rdata1(reg1_data),
    .re2(reg2_read), .raddr2(reg2_addr), .rdata2(reg2_data),
    .ex_forwarding_we(ex_wreg_o), .ex_forwarding_waddr(ex_waddr_o), .ex_forwarding_wdata(ex_wdata_o),
    .dcache_forwarding_we(dcache_wreg), .dcache_forwarding_waddr(dcache_waddr), .dcache_forwarding_wdata(dcache_wdata),
    .mem_forwarding_we(mem_wreg_o), .mem_forwarding_waddr(mem_waddr_o), .mem_forwarding_wdata(mem_wdata_o),
    .l2_re1(l2_regfile_reg1_read), .l2_raddr1(l2_regfile_reg1_addr), .l2_rdata1(l2_regfile_reg1_rdata),
    .l2_re2(l2_regfile_reg2_read), .l2_raddr2(l2_regfile_reg2_addr), .l2_rdata2(l2_regfile_reg2_rdata),
    .l2_ex_forwarding_we(l2_ex_wreg_o), .l2_ex_forwarding_waddr(l2_ex_waddr_o), .l2_ex_forwarding_wdata(l2_ex_wdata_o),
    .l2_dcache_forwarding_we(l2_dcache_wreg), .l2_dcache_forwarding_waddr(l2_dcache_waddr), .l2_dcache_forwarding_wdata(l2_dcache_wdata),
    .l2_mem_forwarding_we(l2_mem_wreg), .l2_mem_forwarding_waddr(l2_mem_waddr), .l2_mem_forwarding_wdata(l2_mem_wdata)
  );

  id_ex u_id_ex(
    .clk(clk), .rst(rst), .stall(stall), .flush(flush),
    .id_pc(id_pc_o), .ex_pc(ex_pc_i),
    .id_inst(id_inst_o), .ex_inst(ex_inst_i),
    .id_aluop(id_aluop_o), .id_alusel(id_alusel_o), .id_reg1(id_reg1_o), .id_reg2(id_reg2_o),
    .id_waddr(id_waddr_o), .id_wreg(id_wreg_o),
    .ex_aluop(ex_aluop_i), .ex_alusel(ex_alusel_i), .ex_reg1(ex_reg1_i), .ex_reg2(ex_reg2_i),
    .ex_waddr(ex_waddr_i), .ex_wreg(ex_wreg_i),
    .id_link_address(id_link_address_o), .id_is_in_delayslot(id_is_in_delayslot_o), .next_inst_in_delayslot_i(next_inst_in_delayslot),
    .ex_link_addrss(ex_link_addrss_i), .ex_is_in_delayslot(ex_is_in_delayslot_i), .is_in_delayslot_o(id_is_in_delayslot_i),
    .id_excepttype(id_excepttype_o), .ex_excepttype(ex_excepttype_i)
  );

  ex u_ex(
    .rst(rst), .stallreq(stallreq_from_ex), 
    .pc_i(ex_pc_i), .pc_o(ex_pc_o), .inst_i(ex_inst_i),
    .aluop_i(ex_aluop_i), .alusel_i(ex_alusel_i), .reg1_i(ex_reg1_i), .reg2_i(ex_reg2_i),
    .waddr_i(ex_waddr_i), .wreg_i(ex_wreg_i),
    .waddr_o(ex_waddr_o), .wreg_o(ex_wreg_o), .wdata_o(ex_wdata_o),
    .hi_i(hi_i), .lo_i(lo_i),
    .wb_hi_i(wb_hi_i), .wb_lo_i(wb_lo_i), .wb_whilo_i(wb_whilo_i),
    .mem_hi_i(mem_hi_o), .mem_lo_i(mem_lo_o), .mem_whilo_i(mem_whilo_o), // 这里按照雷思磊书上的使用的是mem之后的信号，个人感觉使用mem前的信号也没区别
    .dcache_hi_i(dcache_hi), .dcache_lo_i(dcache_lo), .dcache_whilo_i(dcache_whilo),
    // .premem_hi_i(premem_hi), .premem_lo_i(premem_lo), .premem_whilo_i(premem_whilo),
    .hi_o(ex_hi_o), .lo_o(ex_lo_o), .whilo_o(ex_whilo_o),
    // .result_mul(result_mul), .result_is_ok(result_is_ok),
    // .mul_opdata1_o(mul_op1), .mul_opdata2_o(mul_op2), .mul_start_o(mul_start), .signed_mul_o(mul_signed),
    .div_result_i(div_result), .div_ready_i(div_ready), 
    .div_opdata1_o(div_op1), .div_opdata2_o(div_op2), .div_start_o(div_start), .signed_div_o(div_signed),
    .link_address_i(ex_link_addrss_i), .is_in_delayslot_i(ex_is_in_delayslot_i),
    .aluop_o(ex_aluop_o), .mem_addr_o(ex_mem_addr_o), .reg2_o(ex_reg2_o),
    // .premem_cp0_reg_we(premem_cp0_reg_we), .premem_cp0_reg_write_addr(premem_cp0_reg_write_addr), .premem_cp0_reg_data(premem_cp0_reg_data),
    .dcache_cp0_reg_we(dcache_cp0_reg_we), .dcache_cp0_reg_write_addr(dcache_cp0_reg_write_addr), .dcache_cp0_reg_data(dcache_cp0_reg_data),
    .mem_cp0_reg_we(mem_cp0_reg_we), .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr), .mem_cp0_reg_data(mem_cp0_reg_data),
    // .wb_cp0_reg_we(cp0_reg_we_i), .wb_cp0_reg_write_addr(cp0_reg_write_addr_i), .wb_cp0_reg_data(cp0_reg_data_i),
    .cp0_reg_data_i(cp0_reg_data_o), .cp0_reg_read_addr_o(cp0_reg_read_addr_i),
    .cp0_reg_we_o(ex_cp0_reg_we_o), . cp0_reg_write_addr_o(ex_cp0_reg_write_addr_o), .cp0_reg_data_o(ex_cp0_reg_data_o),
    .excepttype_i(ex_excepttype_i), .excepttype_o(ex_excepttype_o),
    .is_in_delayslot_o(ex_is_in_delayslot_o), .badvaddr_o(ex_badvaddr_o)
  );

  reg [31:0] excepttype_temp;
  assign premem_waddr = ex_waddr_o;
  assign premem_wreg = ex_wreg_o;
  assign premem_wdata = ex_wdata_o;
  assign premem_hi = ex_hi_o;
  assign premem_lo = ex_lo_o;
  assign premem_whilo = ex_whilo_o;
  assign premem_aluop = ex_aluop_o;
  assign premem_mem_addr_i = ex_mem_addr_o;
  assign premem_reg2_i = ex_reg2_o;
  assign premem_cp0_reg_we = ex_cp0_reg_we_o;
  assign premem_cp0_reg_write_addr = ex_cp0_reg_write_addr_o;
  assign premem_cp0_reg_data = ex_cp0_reg_data_o;
  assign premem_pc_i = ex_pc_o;
  assign premem_excepttype = |excepttype_temp ? excepttype_temp : ex_excepttype_o;
  assign premem_is_in_delayslot = ex_is_in_delayslot_o;
  assign premem_badvaddr = ex_badvaddr_o;

  always @ (posedge clk) begin
    excepttype_temp <= ex_excepttype_o;
  end

  pre_mem u_pre_mem(
    .rst(rst),
    // .waddr_i(premem_waddr_i), .wreg_i(premem_wreg_i), .wdata_i(premem_wdata_i),
    // .waddr_o(premem_waddr_o), .wreg_o(premem_wreg_o), .wdata_o(premem_wdata_o),
    // .hi_i(premem_hi_i), .lo_i(premem_lo_i), .whilo_i(premem_whilo_i),
    // .hi_o(premem_hi_o), .lo_o(premem_lo_o), .whilo_o(premem_whilo_o),
    .aluop_i(premem_aluop), .mem_addr_i(premem_mem_addr_i), .reg2_i(premem_reg2_i), 
    // .aluop_o(premem_aluop_o),
    // .mem_data_i(dcache_mem_data),
    .mem_addr_o(premem_addr_un_mmu), .mem_we_o(premem_we_o), .mem_sel_o(premem_sel_o), .mem_data_o(premem_data_o), .mem_ce_o(premem_ce_o),
    .pc_i(premem_pc_i), .pc_o(premem_pc_o),
    .excepttype_i(premem_excepttype)
  );

  assign premem_addr_mmu = (premem_addr_un_mmu < 32'h80000000) ? premem_addr_un_mmu :
                            (premem_addr_un_mmu < 32'hA0000000) ? (premem_addr_un_mmu - 32'h80000000) :
                            (premem_addr_un_mmu < 32'hC0000000) ? (premem_addr_un_mmu - 32'hA0000000) :
                            (premem_addr_un_mmu < 32'hE0000000) ? (premem_addr_un_mmu) :
                            (premem_addr_un_mmu <= 32'hFFFFFFFF) ? (premem_addr_un_mmu) : 
                            32'h00000000;

  pre_dcache u_pre_dcache(
    .clk(clk), .rst(rst), .stall(stall), .flush(flush),
    .premem_waddr(premem_waddr), .premem_wreg(premem_wreg), .premem_wdata(premem_wdata), 
    .dcache_waddr(dcache_waddr), .dcache_wreg(dcache_wreg), .dcache_wdata(dcache_wdata),
    .premem_hi(premem_hi), .premem_lo(premem_lo), .premem_whilo(premem_whilo),
    .dcache_hi(dcache_hi), .dcache_lo(dcache_lo), .dcache_whilo(dcache_whilo),
    .premem_aluop(premem_aluop), .dcache_aluop(dcache_aluop),
    .premem_addr(premem_addr_mmu), .premem_we(premem_we_o), .premem_sel(premem_sel_o), .premem_data(premem_data_o), .premem_ce(premem_ce_o), .premem_cache(mmu_cache_o),
    .dcache_addr(dcache_addr), .dcache_we(dcache_we_i), .dcache_sel(dcache_sel_i), .dcache_data(dcache_data_i), .dcache_ce(dcache_ce_i), .dcache_cache(dcache_cache_i),
    .premem_cp0_reg_we(premem_cp0_reg_we), .premem_cp0_reg_write_addr(premem_cp0_reg_write_addr), .premem_cp0_reg_data(premem_cp0_reg_data),
    .dcache_cp0_reg_we(dcache_cp0_reg_we), .dcache_cp0_reg_write_addr(dcache_cp0_reg_write_addr), .dcache_cp0_reg_data(dcache_cp0_reg_data),
    .premem_pc(premem_pc_o), .dcache_pc(dcache_pc),
    .premem_excepttype(premem_excepttype), .premem_is_in_delayslot(premem_is_in_delayslot), .premem_badvaddr(premem_badvaddr),
    .dcache_excepttype(dcache_excepttype), .dcache_is_in_delayslot(dcache_is_in_delayslot), .dcache_badvaddr(dcache_badvaddr)
  );
  assign dcache_addr_i = dcache_addr;

  assign data_sram_en = rst ? `False_v : premem_ce_o;
  assign data_sram_wen = rst ? 4'b0000 : premem_sel_o & {4{premem_we_o}};
  assign data_sram_addr = rst ? `ZeroWord : premem_addr_mmu;
  assign data_sram_wdata = rst ? `ZeroWord : premem_data_o;

  dcache_mem u_dcache_mem(
    .clk(clk), .rst(rst), .stall(stall), .flush(flush),
    .dcache_waddr(dcache_waddr), .dcache_wreg(dcache_wreg), .dcache_wdata(dcache_wdata),
    .mem_waddr(mem_waddr_i), .mem_wreg(mem_wreg_i), .mem_wdata(mem_wdata_i),
    .dcache_hi(dcache_hi), .dcache_lo(dcache_lo), .dcache_whilo(dcache_whilo),
    .mem_hi(mem_hi_i), .mem_lo(mem_lo_i), .mem_whilo(mem_whilo_i),
    .dcache_aluop(dcache_aluop), .mem_aluop(mem_aluop_i),
    .dcache_addr(dcache_addr), .mem_addr(mem_addr_i),
    .dcache_data(data_sram_rdata), .mem_data(mem_data_i),
    .dcache_cp0_reg_we(dcache_cp0_reg_we), .dcache_cp0_reg_write_addr(dcache_cp0_reg_write_addr), .dcache_cp0_reg_data(dcache_cp0_reg_data),
    .mem_cp0_reg_we(mem_cp0_reg_we), .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr), .mem_cp0_reg_data(mem_cp0_reg_data),
    .dcache_pc(dcache_pc), .mem_pc(mem_pc_i),
    .dcache_excepttype(dcache_excepttype), .dcache_is_in_delayslot(dcache_is_in_delayslot), .dcache_badvaddr(dcache_badvaddr),
    .mem_excepttype(mem_excepttype_i), .mem_is_in_delayslot(mem_is_in_delayslot_i), .mem_badvaddr(mem_badvaddr_i)
  );

  mem u_mem(
    .rst(rst),
    .waddr_i(mem_waddr_i), .wreg_i(mem_wreg_i), .wdata_i(mem_wdata_i),
    .waddr_o(mem_waddr_o), .wreg_o(mem_wreg_o), .wdata_o(mem_wdata_o),
    .hi_i(mem_hi_i), .lo_i(mem_lo_i), .whilo_i(mem_whilo_i),
    .hi_o(mem_hi_o), .lo_o(mem_lo_o), .whilo_o(mem_whilo_o),
    .aluop_i(mem_aluop_i), .mem_addr_i(mem_addr_i), .mem_data_i(mem_data_i),
    .pc_i(mem_pc_i), .pc_o(mem_pc_o),
    .excepttype_i(mem_excepttype_i), .is_in_delayslot_i(mem_is_in_delayslot_i), .badvaddr_i(mem_badvaddr_i), 
    .cp0_status_i(mem_cp0_status_i), .cp0_cause_i(mem_cp0_cause_i), .cp0_epc_i(mem_cp0_epc_i),
    // .wb_cp0_reg_we(cp0_reg_we_i), .wb_cp0_reg_write_addr(cp0_reg_write_addr_i), .wb_cp0_reg_data(cp0_reg_data_i),
    .excepttype_o(mem_excepttype_o), .cp0_epc_o(mem_cp0_epc_o), .is_in_delayslot_o(mem_is_in_delayslot_o), .badvaddr_o(mem_badvaddr_o)
  );

  mem_wb u_mem_wb(
    .clk(clk), .rst(rst), .stall(stall), .flush(flush),
    .mem_waddr(mem_waddr_o), .mem_wreg(mem_wreg_o), .mem_wdata(mem_wdata_o),
    .wb_waddr(wb_waddr_i), .wb_wreg(wb_wreg_i), .wb_wdata(wb_wdata_i),
    .mem_hi(mem_hi_o), .mem_lo(mem_lo_o), .mem_whilo(mem_whilo_o),
    .wb_hi(wb_hi_i), .wb_lo(wb_lo_i), .wb_whilo(wb_whilo_i),
    // .mem_cp0_reg_we(mem_cp0_reg_we), .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr), .mem_cp0_reg_data(mem_cp0_reg_data),
    // .wb_cp0_reg_we(cp0_reg_we_i), .wb_cp0_reg_write_addr(cp0_reg_write_addr_i), .wb_cp0_reg_data(cp0_reg_data_i),
    .pc_i(mem_pc_o), .pc_o(debug_wb_pc)
  );

  hilo_reg u_hilo_reg(
    .clk(clk), .rst(rst),
    .we(wb_whilo_i), .hi_i(wb_hi_i), .lo_i(wb_lo_i),
    .hi_o(hi_i), .lo_o(lo_i)
  );

  cp0_reg u_cp0_reg(
    .clk(clk), .rst(rst), 
    .we_i(mem_cp0_reg_we), .waddr_i(mem_cp0_reg_write_addr), .raddr_i(cp0_reg_read_addr_i), .data_i(mem_cp0_reg_data),
    .int_i(int),
    .data_o(cp0_reg_data_o), .badvaddr_o(), .count_o(), .compare_o(),
    .status_o(mem_cp0_status_i), .cause_o(mem_cp0_cause_i), .epc_o(mem_cp0_epc_i), .config_o(),
    .timer_int_o(),
    .excepttype_i(mem_excepttype_o), .pc_i(mem_pc_o), .is_in_delayslot_i(mem_is_in_delayslot_o), .badvaddr_i(mem_badvaddr_o)
  );

  ctrl u_ctrl(
    .rst(rst),
    .stallreq_from_id(stallreq_from_id),
    .stallreq_from_ex(stallreq_from_ex),
    .stallreq_from_icache(1'b0),
    .stallreq_from_dcache(1'b0),
    .excepttype_i(mem_excepttype_o),
    .cp0_epc_i(mem_cp0_epc_o),
    .new_pc(new_pc),
    .flush(flush),
    .stall(stall)
  );

  div u_div(
		.clk(clk),
		.rst(rst),
		.signed_div_i(div_signed),
		.opdata1_i(div_op1),
		.opdata2_i(div_op2),
		.start_i(div_start),
		.annul_i(1'b0),
		.result_o(div_result),
		.ready_o(div_ready)
	);

  // axi_bus u_axi_bus(
  //   .clk(clk), .rst(rst),
  //   .pc_i(icache_pc_o), .isMiss_from_icache(isMiss_from_icache),
  //   .we_icache_o(icache_we_w), .pc_icache_o(icache_pc_w), .inst_icache_o(icache_inst_w), .last_for_icache(last_for_icache),
  //   .mem_addr_i(dcache_mem_addr_i), .mem_we_i(dcache_mem_we_i), .mem_sel_i(dcache_mem_sel_i), .mem_data_i(dcache_mem_data_i), .mem_ce_i(dcache_mem_ce_i), .isMiss_from_dcache(isMiss_from_dcache), .cache_i(dcache_cache_o),
  //   .mem_addr_o(dcache_mem_addr_w), .mem_we_o(dcache_mem_we_w), .mem_data_o(dcache_mem_data_w), .cache_o(dcache_cache_w), .last_for_dcache(dcache_last_w),
  // //写地址通道信号
  //   .awid(awid),//写地址ID，用来标志一组写信号
  //   .awaddr(awaddr),//写地址，给出一次写突发传输的写地址
  //   .awlen(awlen),//突发长度，给出突发传输的次数
  //   .awsize(awsize),//突发大小，给出每次突发传输的字节数
  //   .awburst(awburst),//突发类型
  //   .awlock(awlock),//总线锁信号，可提供操作的原子性
  //   .awcache(awcache),//内存类型，表明一次传输是怎样通过系统的
  //   .awprot(awprot),//保护类型，表明一次传输的特权级及安全等级
  //   .awvalid(awvalid),//有效信号，表明此通道的地址控制信号有效
  //   .awready(awready),//表明"从"可以接收地址和对应的控制信号

  // //写数据通道信号
  //   .wid(wid),//一次写传输的ID tag
  //   .wdata(wdata),//写数据
  //   .wstrb(wstrb),//写数据有效的字节线，用来表明哪8bits数据是有效的
  //   .wlast(wlast),//表明此次传输是最后一个突发传输
  //   .wvalid(wvalid),//写有效，表明此次写有效
  //   .wready(wready),//表明从机可以接收写数据
  // //写响应通道信号
  //   .bid(bid),//写响应ID tag
  //   .bresp(bresp),//写响应，表明写传输的状态 00为正常，当然可以不理会
  //   .bvalid(bvalid),//写响应有效
  //   .bready(bready),//表明主机能够接收写响应

  // //总线侧接口
  // //读地址通道信号
  //   .arid(arid),//读地址ID，用来标志一组写信号
  //   .araddr(araddr),//读地址，给出一次写突发传输的读地址
  //   .arlen(arlen),//突发长度，给出突发传输的次数
  //   .arsize(arsize),//突发大小，给出每次突发传输的字节数
  //   .arburst(arburst),//突发类型
  //   .arlock(arlock),//总线锁信号，可提供操作的原子性
  //   .arcache(arcache),//内存类型，表明一次传输是怎样通过系统的
  //   .arprot(arprot),//保护类型，表明一次传输的特权级及安全等级
  //   .arvalid(arvalid),//有效信号，表明此通道的地址控制信号有效
  //   .arready(arready),//表明"从"可以接收地址和对应的控制信号
  // //读数据通道信号
  //   .rid(rid),//读ID tag
  //   .rdata(rdata),//读数据
  //   .rresp(rresp),//读响应，表明读传输的状态
  //   .rlast(rlast),//表明读突发的最后一次传输
  //   .rvalid(rvalid),//表明此通道信号有效
  //   .rready(rready)//表明主机能够接收读数据和响应信息
  // );

endmodule