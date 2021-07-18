
//**********************************************
//COPYRIGHT(c)2021, Xidian University
//All rights reserved.
//
//File name     : ex.v
//Module name   : ex	
//Full name     :
//Author 		: Xu Mingwei
//Email 		: xumingweiaa@qq.com
//
//Version 		:
//This File is  Created on 2021-07-14 18:02:15
//------------------Discription-----------------
//
//----------------------------------------------
//-------------Modification history-------------
//Last Modified by 	: xumingwei
//Last Modified time: 2021-07-14 18:02:15
//Discription 	:
//----------------------------------------------
//TIMESCALE
`timescale 1ns/1ps
//DEFINES
`include "defines.v"
//----------------------------------------------

module ex(
	// 来自 ID 模块
	input		[`INST_WIDTH]		inst_i			,
	input		[`ADDR_BUS_WIDTH]	inst_addr_i		,
	input		[`DATA_BUS_WIDTH]	reg1_rd_data_i	,
	input		[`DATA_BUS_WIDTH]	reg2_rd_data_i	,
	input  							reg_wr_en_i		,
	input  		[`REG_ADDR_DEPTH]	reg_wr_addr_i	,
	input		[`DATA_BUS_WIDTH]	op_reg1_i		,	
	input		[`DATA_BUS_WIDTH]	op_reg2_i		,	
	input		[`DATA_BUS_WIDTH]	op_jump1_i		,
	input		[`DATA_BUS_WIDTH]	op_jump2_i		,

	// 来自 RAM
	input		[`DATA_BUS_WIDTH]	mem_rd_data_i	,	// RAM 读出的数据

	// 去往 regfiles 模块
	output reg						reg_wr_en_o		,	// 寄存器堆写使能
	output reg  [`DATA_BUS_WIDTH]	reg_wr_data_o	,	// 寄存器堆写数据
	output reg	[`REG_ADDR_DEPTH]	reg_wr_addr_o	,	// 寄存器堆写地址

	// 去往 RAM
	output reg  [`DATA_BUS_WIDTH]	mem_wr_data_o	,	// RAM 写数据
	output reg  [`RAM_ADDR_WIDTH]	mem_wr_addr_o	,	// RAM 写地址
	output reg  					mem_wr_en_o		,	// RAM 写使能

	output reg  [`RAM_ADDR_WIDTH]	mem_rd_addr_o	,	// RAM 读地址
	output reg  					mem_rd_en_o		,	// RAM 读使能

	// 去往 pipe_ctrl 模块
	output reg						jump_en_o		,	// 跳转使能输出
	output reg	[`ADDR_BUS_WIDTH]	jump_addr_o			// 跳转地址输出
);


// 指令内容提取
wire[6:0] opcode = inst_i[6:0]   ;
wire[2:0] funct3 = inst_i[14:12] ;
wire[6:0] funct7 = inst_i[31:25] ;
wire[4:0] rd 	 = inst_i[11:7]  ;
wire[4:0] uimm   = inst_i[19:15] ;

wire[63:0]	srai_shift;
wire[63:0]	srai_shift_mask;
wire[63:0]	sra_shift;
wire[63:0]	sra_shift_mask;

// 非双字访存 存储空间索引号
wire[2:0]	mem_rd_addr_index;
wire[2:0]	mem_wr_addr_index;

// RV64I扩展I、R型指令
wire[63:0]	addiw_result;
wire[63:0]	slliw_result;
wire[63:0]	srliw_result;
wire[63:0]	sraiw_result;
wire[63:0]	addw_result;
wire[63:0]	subw_result;
wire[63:0]	sllw_result;
wire[63:0]	srlw_result;
wire[63:0]	sraw_result;


assign srai_shift = reg1_rd_data_i >> inst_i[24:20];
assign srai_shift_mask = `MAX_WORD >> inst_i[24:20];
assign sra_shift = reg1_rd_data_i >> reg2_rd_data_i[4:0];
assign sra_shift_mask = `MAX_WORD >> reg2_rd_data_i[4:0];

assign mem_rd_addr_index = (reg1_rd_data_i + {{52{inst_i[31]}}, inst_i[31:20]}) & 3'b111;
assign mem_wr_addr_index = (reg1_rd_data_i + {{52{inst_i[31]}}, inst_i[31:25], inst_i[11:7]}) & 3'b111;

assign addiw_result = op_reg1_i + op_reg2_i;
assign slliw_result = reg1_rd_data_i << inst_i[24:20];
assign sraiw_result = (srai_shift & srai_shift_mask) | ({64{reg1_rd_data_i[63]}} & (~srai_shift_mask));
assign srliw_result = reg1_rd_data_i >> inst_i[24:20];
assign addw_result = op_reg1_i + op_reg2_i;
assign subw_result = op_reg1_i - op_reg2_i;
assign sllw_result = op_reg1_i << op_reg2_i[4:0];
assign srlw_result = reg1_rd_data_i >> reg2_rd_data_i[4:0];
assign sraw_result = (sra_shift & sra_shift_mask) | ({64{reg1_rd_data_i[63]}} & (~sra_shift_mask));


// 执行模块
always @(*) begin
	reg_wr_en_o = reg_wr_en_i;
	reg_wr_addr_o = reg_wr_addr_i;
	mem_wr_en_o = 1'b0;
	mem_rd_en_o = 1'b0;
	jump_en_o = 1'b0;

	case( opcode )
		`INST_TYPE_I : begin
			case( funct3 )
				`INST_ADDI : begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = op_reg1_i + op_reg2_i;
				end

				`INST_SLTI: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = ( $signed(op_reg1_i) < $signed(op_reg2_i) );
				end

				`INST_SLTIU: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = ( op_reg1_i < op_reg2_i );
				end

				`INST_XORI: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = op_reg1_i ^ op_reg2_i;
				end

				`INST_ORI: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = op_reg1_i | op_reg2_i;
				end

				`INST_ANDI: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = op_reg1_i & op_reg2_i;
				end

				`INST_SLLI: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = reg1_rd_data_i << inst_i[24:20];
				end

				`INST_SRI: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					if( inst_i[30] == 1'b1 ) begin
						reg_wr_data_o = (srai_shift & srai_shift_mask) | ({64{reg1_rd_data_i[63]}} & (~srai_shift_mask));
					end
					else begin
						reg_wr_data_o = reg1_rd_data_i >> inst_i[24:20];
					end
				end

				default : begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = `ZERO_WORD;
				end
			endcase
		end

		`INST_TYPE_R : begin
			case( funct3 )
				`INST_ADD_SUB: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					if( inst_i[30] == 1'b1 ) begin
						reg_wr_data_o = op_reg1_i - op_reg2_i;
					end
					else begin
						reg_wr_data_o = op_reg1_i + op_reg2_i;
					end
				end

				`INST_SLL: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = op_reg1_i << op_reg2_i[4:0];
				end

				`INST_SLT: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = $signed(op_reg1_i) < $signed(op_reg2_i);
				end

				`INST_SLTU: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = op_reg1_i < op_reg2_i;
				end

				`INST_XOR: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = op_reg1_i ^ op_reg2_i;
				end

				`INST_SR: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					if( inst_i[30] == 1'b1 ) begin
						reg_wr_data_o = (sra_shift & sra_shift_mask) | ({64{reg1_rd_data_i[63]}} & (~sra_shift_mask));
					end
					else begin
						reg_wr_data_o = reg1_rd_data_i >> reg2_rd_data_i[4:0];
					end
				end

				`INST_OR: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = op_reg1_i | op_reg2_i;
				end

				`INST_AND: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = op_reg1_i & op_reg2_i;
				end
				default : begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = `ZERO_WORD;
				end
			endcase
		end

		`INST_TYPE_L : begin
			case( funct3 )
				`INST_LB: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = op_reg1_i + op_reg2_i;
					mem_rd_en_o = 1'b1;
					case( mem_rd_addr_index )
						3'b000 : begin
							reg_wr_data_o = { {56{mem_rd_data_i[7]}}, mem_rd_data_i[7:0] };
						end
						3'b001 : begin
							reg_wr_data_o = { {56{mem_rd_data_i[15]}}, mem_rd_data_i[15:8] };
						end
						3'b010 : begin
							reg_wr_data_o = { {56{mem_rd_data_i[23]}}, mem_rd_data_i[23:16] };
						end
						3'b011 : begin
							reg_wr_data_o = { {56{mem_rd_data_i[31]}}, mem_rd_data_i[31:24] };
						end
						3'b100 : begin
							reg_wr_data_o = { {56{mem_rd_data_i[39]}}, mem_rd_data_i[39:32] };
						end
						3'b101 : begin
							reg_wr_data_o = { {56{mem_rd_data_i[47]}}, mem_rd_data_i[47:40] };
						end
						3'b110 : begin
							reg_wr_data_o = { {56{mem_rd_data_i[55]}}, mem_rd_data_i[55:48] };
						end
						3'b111 : begin
							reg_wr_data_o = { {56{mem_rd_data_i[63]}}, mem_rd_data_i[63:56] };
						end
					endcase
				end

				`INST_LH: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = op_reg1_i + op_reg2_i;
					mem_rd_en_o = 1'b1;
					case( mem_rd_addr_index[2:1] )
						2'b00 : begin
							reg_wr_data_o = { {48{mem_rd_data_i[15]}}, mem_rd_data_i[15:0] };
						end
						2'b01 : begin
							reg_wr_data_o = { {48{mem_rd_data_i[31]}}, mem_rd_data_i[31:16] };
						end
						2'b10 : begin
							reg_wr_data_o = { {48{mem_rd_data_i[47]}}, mem_rd_data_i[47:32] };
						end
						2'b11 : begin
							reg_wr_data_o = { {48{mem_rd_data_i[63]}}, mem_rd_data_i[63:48] };
						end
					endcase
				end

				`INST_LW: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = op_reg1_i + op_reg2_i;
					mem_rd_en_o = 1'b1;
					case( mem_rd_addr_index[2] )
						1'b0 : begin
							reg_wr_data_o = { {32{mem_rd_data_i[31]}}, mem_rd_data_i[31:0] };
						end
						1'b1 : begin
							reg_wr_data_o = { {32{mem_rd_data_i[63]}}, mem_rd_data_i[63:32] };
						end
					endcase
				end

				`INST_LBU: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = op_reg1_i + op_reg2_i;
					mem_rd_en_o = 1'b1;
					case( mem_rd_addr_index )
						3'b000 : begin
							reg_wr_data_o = { 56'h0, mem_rd_data_i[7:0] };
						end
						3'b001 : begin
							reg_wr_data_o = { 56'h0, mem_rd_data_i[15:8] };
						end
						3'b010 : begin
							reg_wr_data_o = { 56'h0, mem_rd_data_i[23:16] };
						end
						3'b011 : begin
							reg_wr_data_o = { 56'h0, mem_rd_data_i[31:24] };
						end
						3'b100 : begin
							reg_wr_data_o = { 56'h0, mem_rd_data_i[39:32] };
						end
						3'b101 : begin
							reg_wr_data_o = { 56'h0, mem_rd_data_i[47:40] };
						end
						3'b110 : begin
							reg_wr_data_o = { 56'h0, mem_rd_data_i[55:48] };
						end
						3'b111 : begin
							reg_wr_data_o = { 56'h0, mem_rd_data_i[63:56] };
						end
					endcase
				end

				`INST_LHU: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = op_reg1_i + op_reg2_i;
					mem_rd_en_o = 1'b1;
					case( mem_rd_addr_index[2:1] )
						2'b00 : begin
							reg_wr_data_o = { 48'h0, mem_rd_data_i[15:0] };
						end
						2'b01 : begin
							reg_wr_data_o = { 48'h0, mem_rd_data_i[31:16] };
						end
						2'b10 : begin
							reg_wr_data_o = { 48'h0, mem_rd_data_i[47:32] };
						end
						2'b11 : begin
							reg_wr_data_o = { 48'h0, mem_rd_data_i[63:48] };
						end
					endcase
				end

				`INST_LD: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = op_reg1_i + op_reg2_i;
					mem_rd_en_o = 1'b1;
					reg_wr_data_o = mem_rd_data_i;
				end

				`INST_LWU: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = op_reg1_i + op_reg2_i;
					mem_rd_en_o = 1'b1;
					case( mem_rd_addr_index[2] )
						1'b0 : begin
							reg_wr_data_o = { 32'h0, mem_rd_data_i[31:0] };
						end
						1'b1 : begin
							reg_wr_data_o = { 32'h0, mem_rd_data_i[63:32] };
						end
					endcase
				end

				default : begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = `ZERO_WORD;
				end
			endcase
		end

		`INST_TYPE_S : begin
			case( funct3 )
				`INST_SB: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_rd_addr_o = op_reg1_i + op_reg2_i;
					mem_rd_en_o = 1'b1;
					mem_wr_addr_o = op_reg1_i + op_reg2_i;
					mem_wr_en_o = 1'b1;
					case( mem_wr_addr_index )
						3'b000 : begin
							mem_wr_data_o = { mem_rd_data_i[63:8], reg2_rd_data_i[7:0] };
						end
						3'b001 : begin
							mem_wr_data_o = { mem_rd_data_i[63:16], reg2_rd_data_i[7:0], mem_rd_data_i[7:0] };
						end
						3'b010 : begin
							mem_wr_data_o = { mem_rd_data_i[63:24], reg2_rd_data_i[7:0], mem_rd_data_i[15:0] };
						end
						3'b011 : begin
							mem_wr_data_o = { mem_rd_data_i[63:32], reg2_rd_data_i[7:0], mem_rd_data_i[23:0] };
						end
						3'b100 : begin
							mem_wr_data_o = { mem_rd_data_i[63:40], reg2_rd_data_i[7:0], mem_rd_data_i[31:0] };
						end
						3'b101 : begin
							mem_wr_data_o = { mem_rd_data_i[63:48], reg2_rd_data_i[7:0], mem_rd_data_i[39:0] };
						end
						3'b110 : begin
							mem_wr_data_o = { mem_rd_data_i[63:56], reg2_rd_data_i[7:0], mem_rd_data_i[47:0] };
						end
						3'b111 : begin
							mem_wr_data_o = { reg2_rd_data_i[7:0], mem_rd_data_i[55:0] };
						end
					endcase
				end

				`INST_SH: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_rd_addr_o = op_reg1_i + op_reg2_i;
					mem_rd_en_o = 1'b1;
					mem_wr_addr_o = op_reg1_i + op_reg2_i;
					mem_wr_en_o = 1'b1;
					case( mem_wr_addr_index[2:1] )
						2'b00 : begin
							mem_wr_data_o = { mem_rd_data_i[63:16], reg2_rd_data_i[15:0] };
						end
						2'b01 : begin
							mem_wr_data_o = { mem_rd_data_i[63:32], reg2_rd_data_i[15:0], mem_rd_data_i[15:0] };
						end
						2'b10 : begin
							mem_wr_data_o = { mem_rd_data_i[63:48], reg2_rd_data_i[15:0], mem_rd_data_i[31:0] };
						end
						2'b11 : begin
							mem_wr_data_o = { reg2_rd_data_i[15:0], mem_rd_data_i[47:0] };
						end
					endcase
				end

				`INST_SW: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_rd_addr_o = op_reg1_i + op_reg2_i;
					mem_rd_en_o = 1'b1;
					mem_wr_addr_o = op_reg1_i + op_reg2_i;
					mem_wr_en_o = 1'b1;
					case( mem_wr_addr_index[2] )
						1'b0 : begin
							mem_wr_data_o = { mem_rd_data_i[63:32], reg2_rd_data_i[31:0] };
						end
						1'b1 : begin
							mem_wr_data_o = { reg2_rd_data_i[31:0], mem_rd_data_i[31:0] };
						end
					endcase
				end

				`INST_SD: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_rd_addr_o = op_reg1_i + op_reg2_i;
					mem_rd_en_o = 1'b1;
					mem_wr_addr_o = op_reg1_i + op_reg2_i;
					mem_wr_en_o = 1'b1;
					mem_wr_data_o = reg2_rd_data_i;
				end

				default : begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = `ZERO_WORD;
				end
			endcase
		end

		`INST_TYPE_B : begin
			case( funct3 )
				`INST_BEQ: begin
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = `ZERO_WORD;
					if( op_reg1_i == op_reg2_i ) begin
						jump_en_o = 1'b1;
						jump_addr_o = op_jump1_i + op_jump2_i;
					end
					else begin
						jump_en_o = 1'b0;
						jump_addr_o = `ZERO_WORD;
					end
				end

				`INST_BNE: begin
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = `ZERO_WORD;
					if( op_reg1_i != op_reg2_i ) begin
						jump_en_o = 1'b1;
						jump_addr_o = op_jump1_i + op_jump2_i;
					end
					else begin
						jump_en_o = 1'b0;
						jump_addr_o = `ZERO_WORD;
					end
				end

				`INST_BLT: begin
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = `ZERO_WORD;
					if( $signed(op_reg1_i) < $signed(op_reg2_i) ) begin
						jump_en_o = 1'b1;
						jump_addr_o = op_jump1_i + op_jump2_i;
					end
					else begin
						jump_en_o = 1'b0;
						jump_addr_o = `ZERO_WORD;
					end
				end

				`INST_BGE: begin
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = `ZERO_WORD;
					if( $signed(op_reg1_i) >= $signed(op_reg2_i) ) begin
						jump_en_o = 1'b1;
						jump_addr_o = op_jump1_i + op_jump2_i;
					end
					else begin
						jump_en_o = 1'b0;
						jump_addr_o = `ZERO_WORD;
					end
				end

				`INST_BLTU: begin
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = `ZERO_WORD;
					if( op_reg1_i < op_reg2_i ) begin
						jump_en_o = 1'b1;
						jump_addr_o = op_jump1_i + op_jump2_i;
					end
					else begin
						jump_en_o = 1'b0;
						jump_addr_o = `ZERO_WORD;
					end
				end

				`INST_BGEU: begin
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = `ZERO_WORD;
					if( op_reg1_i >= op_reg2_i ) begin
						jump_en_o = 1'b1;
						jump_addr_o = op_jump1_i + op_jump2_i;
					end
					else begin
						jump_en_o = 1'b0;
						jump_addr_o = `ZERO_WORD;
					end
				end
				default : begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = `ZERO_WORD;
				end
			endcase
		end

		`INST_JAL, `INST_JALR: begin
			mem_wr_data_o = `ZERO_WORD;
			mem_wr_addr_o = 32'd0;
			mem_wr_en_o = 1'b0;
			mem_rd_addr_o = 32'd0;
			mem_rd_en_o = 1'b0;
			reg_wr_data_o = op_reg1_i + op_reg2_i;
			jump_en_o = 1'b1;
			jump_addr_o = op_jump1_i + op_jump2_i;
		end

		`INST_LUI, `INST_AUIPC: begin
			mem_wr_data_o = `ZERO_WORD;
			mem_wr_addr_o = 32'd0;
			mem_wr_en_o = 1'b0;
			mem_rd_addr_o = 32'd0;
			mem_rd_en_o = 1'b0;
			jump_en_o = 1'b0;
			jump_addr_o = `ZERO_WORD;
			reg_wr_data_o = op_reg1_i + op_reg2_i;
		end

		`INST_NOP_OP: begin
			jump_en_o = 1'b0;
			jump_addr_o = `ZERO_WORD;
			mem_wr_data_o = `ZERO_WORD;
			mem_wr_addr_o = 32'd0;
			mem_wr_en_o = 1'b0;
			mem_rd_addr_o = 32'd0;
			mem_rd_en_o = 1'b0;
			reg_wr_data_o = `ZERO_WORD;
		end

		`INST_TYPE_64_I: begin
			case( funct3 )
				`INST_ADDIW: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = { {32{addiw_result[31]}}, addiw_result[31:0] };
				end

				`INST_SLLIW: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = { {32{slliw_result[31]}}, slliw_result[31:0] };
				end

				`INST_SRIW: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					if( inst_i[30] == 1'b1 ) begin
						reg_wr_data_o = { {32{sraiw_result[31]}}, sraiw_result[31:0] };
					end
					else begin
						reg_wr_data_o = { {32{srliw_result[31]}}, srliw_result[31:0] };
					end
				end

				default: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = `ZERO_WORD;
				end
			endcase
		end

		`INST_TYPE_64_R: begin
			case( funct3 )
				`INST_ADDW_SUBW: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					if( inst_i[30] == 1'b1 ) begin
						reg_wr_data_o = { {32{subw_result[31]}}, subw_result[31:0] };
					end
					else begin
						reg_wr_data_o = { {32{addw_result[31]}}, addw_result[31:0] };
					end
				end

				`INST_SLLW: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = { {32{sllw_result[31]}}, sllw_result[31:0] };
				end

				`INST_SRW: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					if( inst_i[30] == 1'b1 ) begin
						reg_wr_data_o = { {32{sraw_result[31]}}, sraw_result[31:0] };
					end
					else begin
						reg_wr_data_o = { {32{srlw_result[31]}}, srlw_result[31:0] };
					end
				end

				default: begin
					jump_en_o = 1'b0;
					jump_addr_o = `ZERO_WORD;
					mem_wr_data_o = `ZERO_WORD;
					mem_wr_addr_o = 32'd0;
					mem_wr_en_o = 1'b0;
					mem_rd_addr_o = 32'd0;
					mem_rd_en_o = 1'b0;
					reg_wr_data_o = `ZERO_WORD;
				end
			endcase
		end

		default : begin
			jump_en_o = 1'b0;
			jump_addr_o = `ZERO_WORD;
			mem_wr_data_o = `ZERO_WORD;
			mem_wr_addr_o = 32'd0;
			mem_wr_en_o = 1'b0;
			mem_rd_addr_o = 32'd0;
			mem_rd_en_o = 1'b0;
			reg_wr_data_o = `ZERO_WORD;
		end
	endcase
end






endmodule
