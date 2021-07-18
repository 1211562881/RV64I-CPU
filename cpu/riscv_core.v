
//**********************************************
//COPYRIGHT(c)2021, Xidian University
//All rights reserved.
//
//File name     : riscv_core.v
//Module name   : riscv_core	
//Full name     :
//Author 		: Xu Mingwei
//Email 		: xumingweiaa@qq.com
//
//Version 		:
//This File is  Created on 2021-07-16 18:12:37
//------------------Discription-----------------
//
//----------------------------------------------
//-------------Modification history-------------
//Last Modified by 	: xumingwei
//Last Modified time: 2021-07-16 18:12:37
//Discription 	:
//----------------------------------------------
//TIMESCALE
`timescale 1ns/1ps
//DEFINES
`include "defines.v"
//----------------------------------------------

/*** < RV64I > 三级流水线单发射顺序核 ***/
module riscv_core(
	input			    			clk			,
	input			    			rst_n			
);


wire	[`ADDR_BUS_WIDTH]	pc_o;
wire	[`INST_WIDTH]		rom_inst_o;
wire	[`ADDR_BUS_WIDTH]	if_id_inst_addr_o;
wire	[`INST_WIDTH]		if_id_inst_o;
wire	[`ADDR_BUS_WIDTH]	id_inst_addr_o;
wire	[`INST_WIDTH]		id_inst_o;
wire	[`ADDR_BUS_WIDTH]	id_ex_inst_addr_o;
wire	[`INST_WIDTH]		id_ex_inst_o;

wire	[`DATA_BUS_WIDTH]	regfiles_reg1_rd_data_o;
wire	[`DATA_BUS_WIDTH]	regfiles_reg2_rd_data_o;

wire	[`DATA_BUS_WIDTH]	id_reg1_rd_data_o;
wire	[`DATA_BUS_WIDTH]	id_reg2_rd_data_o;
wire	[`REG_ADDR_DEPTH]	id_reg1_rd_addr_o;
wire	[`REG_ADDR_DEPTH]	id_reg2_rd_addr_o;
wire	[`DATA_BUS_WIDTH]	id_op_reg1_o;
wire	[`DATA_BUS_WIDTH]	id_op_reg2_o;
wire	[`DATA_BUS_WIDTH]	id_op_jump1_o;
wire	[`DATA_BUS_WIDTH]	id_op_jump2_o;

wire	[`DATA_BUS_WIDTH]	id_ex_reg1_rd_data_o;
wire	[`DATA_BUS_WIDTH]	id_ex_reg2_rd_data_o;
wire	[`DATA_BUS_WIDTH]	id_ex_op_reg1_o;
wire	[`DATA_BUS_WIDTH]	id_ex_op_reg2_o;
wire	[`DATA_BUS_WIDTH]	id_ex_op_jump1_o;
wire	[`DATA_BUS_WIDTH]	id_ex_op_jump2_o;

wire						ex_jump_en_o;
wire	[`ADDR_BUS_WIDTH]	ex_jump_addr_o;

wire						ctrl_jump_en_o;
wire	[`ADDR_BUS_WIDTH]	ctrl_jump_addr_o;
wire	[2:0]	    		ctrl_pipe_hold_en_o;

wire						id_reg_wr_en_o;
wire	[`REG_ADDR_DEPTH]	id_reg_wr_addr_o;

wire						id_ex_reg_wr_en_o;
wire	[`REG_ADDR_DEPTH]	id_ex_reg_wr_addr_o;

wire						ex_reg_wr_en_o;
wire	[`DATA_BUS_WIDTH]	ex_reg_wr_data_o;
wire	[`REG_ADDR_DEPTH]	ex_reg_wr_addr_o;

wire	[`DATA_BUS_WIDTH]	ex_mem_wr_data_o;
wire	[`RAM_ADDR_WIDTH]	ex_mem_wr_addr_o;
wire						ex_mem_wr_en_o;	

wire	[`DATA_BUS_WIDTH]	ram_mem_rd_data_o;
wire	[`RAM_ADDR_WIDTH]	ex_mem_rd_addr_o;
wire						ex_mem_rd_en_o;


// PC 模块例化
pc inst_pc (
		.clk            (clk),
		.rst_n          (rst_n),

		.jump_en_i      (ctrl_jump_en_o),
		.jump_addr_i    (ctrl_jump_addr_o),

		.pipe_hold_en_i (ctrl_pipe_hold_en_o),

		.pc_o           (pc_o)
	);


// ROM 例化
rom inst_rom (
		.inst_addr_i(pc_o), 
		.inst_o(rom_inst_o)
	);


// 指令数据 大小端转换模块例化
wire	[`INST_WIDTH]	endian_rom_inst_o;

endian_exchange #(
		.DATA_WIDTH(32), 
		.UNIT_WIDTH(8)
	) 
inst_endian_exchange (
		.din ( rom_inst_o ), 
		.dout( endian_rom_inst_o ),
		.en  ( 1'b1 )
	);



// IF_ID 寄存器例化
if_id inst_if_id (
		.clk            (clk),
		.rst_n          (rst_n),

		.inst_i         (endian_rom_inst_o),
		.inst_addr_i    (pc_o),

		.pipe_hold_en_i (ctrl_pipe_hold_en_o),

		.inst_o         (if_id_inst_o),
		.inst_addr_o    (if_id_inst_addr_o)
	);


// ID 模块例化
id inst_id (
		.inst_i         (if_id_inst_o),
		.inst_addr_i    (if_id_inst_addr_o),

		.reg1_rd_data_i (regfiles_reg1_rd_data_o),
		.reg2_rd_data_i (regfiles_reg2_rd_data_o),

		.reg1_rd_addr_o (id_reg1_rd_addr_o),
		.reg2_rd_addr_o (id_reg2_rd_addr_o),

		.op_reg1_o      (id_op_reg1_o),
		.op_reg2_o      (id_op_reg2_o),

		.op_jump1_o     (id_op_jump1_o),
		.op_jump2_o     (id_op_jump2_o),

		.reg1_rd_data_o (id_reg1_rd_data_o),
		.reg2_rd_data_o (id_reg2_rd_data_o),

		.reg_wr_en_o    (id_reg_wr_en_o),
		.reg_wr_addr_o  (id_reg_wr_addr_o),

		.inst_o         (id_inst_o),
		.inst_addr_o    (id_inst_addr_o)
	);


// 寄存器堆例化
regfiles inst_regfiles (
		.clk            (clk),
		.rst_n          (rst_n),

		.reg1_rd_addr_i (id_reg1_rd_addr_o),
		.reg2_rd_addr_i (id_reg2_rd_addr_o),

		.reg1_rd_data_o (regfiles_reg1_rd_data_o),
		.reg2_rd_data_o (regfiles_reg2_rd_data_o),

		.reg_wr_en_i    (ex_reg_wr_en_o),
		.reg_wr_addr_i  (ex_reg_wr_addr_o),
		.reg_wr_data_i  (ex_reg_wr_data_o)
	);


// ID_EX 寄存器例化
id_ex inst_id_ex (
		.clk            (clk),
		.rst_n          (rst_n),

		.inst_i         (id_inst_o),
		.inst_addr_i    (id_inst_addr_o),

		.reg1_rd_data_i (id_reg1_rd_data_o),
		.reg2_rd_data_i (id_reg2_rd_data_o),

		.reg_wr_en_i    (id_reg_wr_en_o),
		.reg_wr_addr_i  (id_reg_wr_addr_o),

		.op_reg1_i      (id_op_reg1_o),
		.op_reg2_i      (id_op_reg2_o),

		.op_jump1_i     (id_op_jump1_o),
		.op_jump2_i     (id_op_jump2_o),

		.pipe_hold_en_i (ctrl_pipe_hold_en_o),

		.inst_o         (id_ex_inst_o),
		.inst_addr_o    (id_ex_inst_addr_o),

		.reg1_rd_data_o (id_ex_reg1_rd_data_o),
		.reg2_rd_data_o (id_ex_reg2_rd_data_o),

		.reg_wr_en_o    (id_ex_reg_wr_en_o),
		.reg_wr_addr_o  (id_ex_reg_wr_addr_o),

		.op_reg1_o      (id_ex_op_reg1_o),
		.op_reg2_o      (id_ex_op_reg2_o),

		.op_jump1_o     (id_ex_op_jump1_o),
		.op_jump2_o     (id_ex_op_jump2_o)
	);


// EX 模块例化
ex inst_ex (
		.inst_i         (id_ex_inst_o),
		.inst_addr_i    (id_ex_inst_addr_o),

		.reg1_rd_data_i (id_ex_reg1_rd_data_o),
		.reg2_rd_data_i (id_ex_reg2_rd_data_o),

		.reg_wr_en_i    (id_ex_reg_wr_en_o),
		.reg_wr_addr_i  (id_ex_reg_wr_addr_o),

		.op_reg1_i      (id_ex_op_reg1_o),
		.op_reg2_i      (id_ex_op_reg2_o),

		.op_jump1_i     (id_ex_op_jump1_o),
		.op_jump2_i     (id_ex_op_jump2_o),	

		.reg_wr_en_o    (ex_reg_wr_en_o),
		.reg_wr_data_o  (ex_reg_wr_data_o),
		.reg_wr_addr_o  (ex_reg_wr_addr_o),

		.mem_wr_data_o  (ex_mem_wr_data_o),
		.mem_wr_addr_o  (ex_mem_wr_addr_o),
		.mem_wr_en_o    (ex_mem_wr_en_o),

		.mem_rd_data_i  (ram_mem_rd_data_o),
		.mem_rd_addr_o  (ex_mem_rd_addr_o),
		.mem_rd_en_o    (ex_mem_rd_en_o),

		.jump_en_o      (ex_jump_en_o),
		.jump_addr_o    (ex_jump_addr_o)
	);


// RAM 模块例化
ram inst_ram (
		.clk           (clk),
		.rst_n         (rst_n),

		.mem_wr_addr_i (ex_mem_wr_addr_o),
		.mem_wr_en_i   (ex_mem_wr_en_o),
		.mem_wr_data_i (ex_mem_wr_data_o),

		.mem_rd_addr_i (ex_mem_rd_addr_o),
		.mem_rd_en_i   (ex_mem_rd_en_o),
		.mem_rd_data_o (ram_mem_rd_data_o)
	);


// 流水线控制器例化
pipe_ctrl inst_pipe_ctrl (
		.jump_en_i      (ex_jump_en_o),
		.jump_addr_i    (ex_jump_addr_o),

		.pipe_hold_en_o (ctrl_pipe_hold_en_o),

		.jump_en_o      (ctrl_jump_en_o),
		.jump_addr_o    (ctrl_jump_addr_o)
	);



endmodule
