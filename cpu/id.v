
//**********************************************
//COPYRIGHT(c)2021, Xidian University
//All rights reserved.
//
//File name     : id.v
//Module name   : id	
//Full name     :
//Author 		: Xu Mingwei
//Email 		: xumingweiaa@qq.com
//
//Version 		:
//This File is  Created on 2021-07-11 16:49:46
//------------------Discription-----------------
//
//----------------------------------------------
//-------------Modification history-------------
//Last Modified by 	: xumingwei
//Last Modified time: 2021-07-11 16:49:46
//Discription 	:
//----------------------------------------------
//TIMESCALE
`timescale 1ns/1ps
//DEFINES
`include "defines.v"
//----------------------------------------------
module id(
	// 来自 if_id 寄存器
	input		[`INST_WIDTH]	 	inst_i 			,	// 指令数据
	input		[`ADDR_BUS_WIDTH]	inst_addr_i		,	// 指令地址

	// 来自寄存器堆
	input		[`DATA_BUS_WIDTH]	reg1_rd_data_i	,	// 寄存器堆的数据1
	input		[`DATA_BUS_WIDTH]	reg2_rd_data_i	,	// 寄存器堆的数据2

	// 去往寄存器堆
	output reg  [`REG_ADDR_DEPTH]	reg1_rd_addr_o	,	// 寄存器1序号
	output reg  [`REG_ADDR_DEPTH]	reg2_rd_addr_o	,	// 寄存器2序号

	// 去往 id_ex 寄存器
	output reg  [`DATA_BUS_WIDTH]	op_reg1_o		,	// 操作寄存器1数据
	output reg  [`DATA_BUS_WIDTH]	op_reg2_o		,	// 操作寄存器2数据
	output reg  [`DATA_BUS_WIDTH]	op_jump1_o		,	// 跳转操作数1
	output reg  [`DATA_BUS_WIDTH]	op_jump2_o		,	// 跳转操作数2
	output reg	[`DATA_BUS_WIDTH]	reg1_rd_data_o	,	// 寄存器堆的数据1
	output reg	[`DATA_BUS_WIDTH]	reg2_rd_data_o	,	// 寄存器堆的数据2
	output reg  					reg_wr_en_o		,	// 寄存器堆写使能
	output reg  [`REG_ADDR_DEPTH]	reg_wr_addr_o	,	// 寄存器堆写地址
	output reg  [`INST_WIDTH]		inst_o 			,	// 指令输出
	output reg  [`ADDR_BUS_WIDTH]	inst_addr_o 		// 指令地址输出
);

// 指令内容提取
wire[6:0] opcode = inst_i[6:0]   ;
wire[2:0] funct3 = inst_i[14:12] ;
wire[6:0] funct7 = inst_i[31:25] ;
wire[4:0] rd 	 = inst_i[11:7]  ;
wire[4:0] rs1 	 = inst_i[19:15] ;
wire[4:0] rs2  	 = inst_i[24:20] ;


always @(*) begin
	inst_o = inst_i;
	inst_addr_o = inst_addr_i;
	reg1_rd_data_o = reg1_rd_data_i;
	reg2_rd_data_o = reg2_rd_data_i;
	op_reg1_o = `ZERO_WORD;
	op_reg2_o = `ZERO_WORD;
	op_jump1_o = `ZERO_WORD;
	op_jump2_o = `ZERO_WORD;

	case( opcode )
		`INST_TYPE_I : begin
			case( funct3 )
				`INST_ADDI, `INST_SLTI, `INST_SLTIU, `INST_XORI, `INST_ORI, `INST_ANDI, `INST_SLLI, `INST_SRI: begin
					reg_wr_en_o = 1'b1;
					reg_wr_addr_o = rd;
					reg1_rd_addr_o = rs1;
					reg2_rd_addr_o = 5'h0;
					op_reg1_o = reg1_rd_data_i;
					op_reg2_o = {{52{inst_i[31]}}, inst_i[31:20]};
				end
				default : begin
					reg_wr_en_o = 1'b0;
					reg_wr_addr_o = 5'h0;
					reg1_rd_addr_o = 5'h0;
					reg2_rd_addr_o = 5'h0;
				end
			endcase
		end

		`INST_TYPE_R : begin
			case( funct3 )
				`INST_ADD_SUB, `INST_SLL, `INST_SLT, `INST_SLTU, `INST_XOR, `INST_SR, `INST_OR, `INST_AND: begin
					reg_wr_en_o = 1'b1;
					reg_wr_addr_o = rd;
					reg1_rd_addr_o = rs1;
					reg2_rd_addr_o = rs2;
					op_reg1_o = reg1_rd_data_i;
					op_reg2_o = reg2_rd_data_i;
				end
				default : begin
					reg_wr_en_o = 1'b0;
					reg_wr_addr_o = 5'h0;
					reg1_rd_addr_o = 5'h0;
					reg2_rd_addr_o = 5'h0;
				end
			endcase
		end

		`INST_TYPE_L : begin
			case( funct3 )
				`INST_LB, `INST_LH, `INST_LW, `INST_LBU, `INST_LHU, `INST_LD: begin
					reg_wr_en_o = 1'b1;
					reg_wr_addr_o = rd;
					reg1_rd_addr_o = rs1;
					reg2_rd_addr_o = 5'h0;
					op_reg1_o = reg1_rd_data_i;
					op_reg2_o = {{52{inst_i[31]}}, inst_i[31:20]};
				end
				default : begin
					reg_wr_en_o = 1'b0;
					reg_wr_addr_o = 5'h0;
					reg1_rd_addr_o = 5'h0;
					reg2_rd_addr_o = 5'h0;
				end
			endcase
		end

		`INST_TYPE_S : begin
			case( funct3 )
				`INST_SB, `INST_SW, `INST_SH, `INST_SD: begin
					reg_wr_en_o = 1'b0;
					reg_wr_addr_o = 5'h0;
					reg1_rd_addr_o = rs1;
					reg2_rd_addr_o = rs2;
					op_reg1_o = reg1_rd_data_i;
					op_reg2_o = {{52{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
				end
				default : begin
					reg_wr_en_o = 1'b0;
					reg_wr_addr_o = 5'h0;
					reg1_rd_addr_o = 5'h0;
					reg2_rd_addr_o = 5'h0;
				end
			endcase
		end


		`INST_TYPE_B : begin
			case( funct3 )
				`INST_BEQ, `INST_BNE, `INST_BLT, `INST_BGE, `INST_BLTU, `INST_BGEU: begin
					reg_wr_en_o = 1'b0;
					reg_wr_addr_o = 5'h0;
					reg1_rd_addr_o = rs1;
					reg2_rd_addr_o = rs2;
					op_reg1_o = reg1_rd_data_i;
					op_reg2_o = reg2_rd_data_i;
					op_jump1_o = inst_addr_i;
					op_jump2_o = {{52{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
				end
				default : begin
					reg_wr_en_o = 1'b0;
					reg_wr_addr_o = 5'h0;
					reg1_rd_addr_o = 5'h0;
					reg2_rd_addr_o = 5'h0;
				end
			endcase
		end

		`INST_JAL : begin
			reg_wr_en_o = 1'b1;
			reg_wr_addr_o = rd;
			reg1_rd_addr_o = 5'h0;
			reg2_rd_addr_o = 5'h0;
			op_reg1_o = inst_addr_i;
			op_reg2_o = 64'h4;
			op_jump1_o = inst_addr_i;
			op_jump2_o = {{44{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
		end

		`INST_JALR : begin
			reg_wr_en_o = 1'b1;
			reg_wr_addr_o = rd;
			reg1_rd_addr_o = rs1;
			reg2_rd_addr_o = 5'h0;
			op_reg1_o = inst_addr_i;
			op_reg2_o = 64'h4;
			op_jump1_o = reg1_rd_data_i;
			op_jump2_o = {{52{inst_i[31]}}, inst_i[31:20], 1'b0};
		end

		`INST_LUI : begin
			reg_wr_en_o = 1'b1;
			reg_wr_addr_o = rd;
			reg1_rd_addr_o = 5'h0;
			reg2_rd_addr_o = 5'h0;
			op_reg1_o = {{44{inst_i[31]}}, inst_i[31:12], 12'b0};
            op_reg2_o = `ZERO_WORD;
		end
		
		`INST_AUIPC : begin
			reg_wr_en_o = 1'b1;
			reg_wr_addr_o = rd;
			reg1_rd_addr_o = 5'h0;
			reg2_rd_addr_o = 5'h0;
			op_reg1_o = inst_addr_i;
            op_reg2_o = {{44{inst_i[31]}}, inst_i[31:12], 12'b0};
		end
		
		`INST_NOP_OP : begin
			reg_wr_en_o = 1'b0;
			reg_wr_addr_o = 5'h0;
			reg1_rd_addr_o = 5'h0;
			reg2_rd_addr_o = 5'h0;
		end

		`INST_TYPE_64_I : begin
			case( funct3 )
				`INST_ADDIW, `INST_SLLIW, `INST_SRIW: begin
					reg_wr_en_o = 1'b1;
					reg_wr_addr_o = rd;
					reg1_rd_addr_o = rs1;
					reg2_rd_addr_o = 5'h0;
					op_reg1_o = reg1_rd_data_i;
					op_reg2_o = {{52{inst_i[31]}}, inst_i[31:20]};
				end

				default: begin
					reg_wr_en_o = 1'b0;
					reg_wr_addr_o = 5'h0;
					reg1_rd_addr_o = 5'h0;
					reg2_rd_addr_o = 5'h0;
				end
			endcase
		end

		`INST_TYPE_64_R : begin
			case( funct3 )
				`INST_ADDW_SUBW, `INST_SLLW, `INST_SRW: begin
					reg_wr_en_o = 1'b1;
					reg_wr_addr_o = rd;
					reg1_rd_addr_o = rs1;
					reg2_rd_addr_o = rs2;
					op_reg1_o = reg1_rd_data_i;
					op_reg2_o = reg2_rd_data_i;
				end

				default: begin
					reg_wr_en_o = 1'b0;
					reg_wr_addr_o = 5'h0;
					reg1_rd_addr_o = 5'h0;
					reg2_rd_addr_o = 5'h0;
				end
			endcase
		end

		default : begin
			reg_wr_en_o = 1'b0;
			reg_wr_addr_o = 5'h0;
			reg1_rd_addr_o = 5'h0;
			reg2_rd_addr_o = 5'h0;
		end
	endcase
end








endmodule
