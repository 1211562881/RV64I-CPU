
//**********************************************
//COPYRIGHT(c)2021, Xidian University
//All rights reserved.
//
//File name     : id_ex.v
//Module name   : id_ex	
//Full name     :
//Author 		: Xu Mingwei
//Email 		: xumingweiaa@qq.com
//
//Version 		:
//This File is  Created on 2021-07-14 17:19:53
//------------------Discription-----------------
//
//----------------------------------------------
//-------------Modification history-------------
//Last Modified by 	: xumingwei
//Last Modified time: 2021-07-14 17:19:53
//Discription 	:
//----------------------------------------------
//TIMESCALE
`timescale 1ns/1ps
//DEFINES
`include "defines.v"
//----------------------------------------------

module id_ex(
	input			    			clk				,
	input			    			rst_n			,

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

	input	    [2:0]	    		pipe_hold_en_i	,	// 流水线停顿信号

	output		[`INST_WIDTH]		inst_o			,
	output		[`ADDR_BUS_WIDTH]	inst_addr_o		,
	output		[`DATA_BUS_WIDTH]	reg1_rd_data_o	,
	output		[`DATA_BUS_WIDTH]	reg2_rd_data_o	,
	output							reg_wr_en_o		,
	output		[`REG_ADDR_DEPTH]	reg_wr_addr_o	,
	output		[`DATA_BUS_WIDTH]	op_reg1_o		,
	output		[`DATA_BUS_WIDTH]	op_reg2_o		,
	output		[`DATA_BUS_WIDTH]	op_jump1_o		,
	output		[`DATA_BUS_WIDTH]	op_jump2_o		
);


wire hold_en = (pipe_hold_en_i >= 3'b011);


pipe_dff #(
		.DW(32)
	) inst_dff (
		.clk     ( clk		),
		.rst_n   ( rst_n	),
 
		.hold_en ( hold_en	),
		.def_val ( 32'h00000001	),	// NOP指令冲刷流水线
 
		.din     ( inst_i	),
		.qout    ( inst_o	)
	);

pipe_dff #(
		.DW(64)
	) inst_addr_dff (
		.clk     ( clk		),
		.rst_n   ( rst_n	),
 
		.hold_en ( hold_en	),
		.def_val ( `ZERO_WORD	),
 
		.din     ( inst_addr_i	),
		.qout    ( inst_addr_o	)
	);

pipe_dff #(
		.DW(64)
	) reg1_data_dff (
		.clk     ( clk		),
		.rst_n   ( rst_n	),
 
		.hold_en ( hold_en	),
		.def_val ( `ZERO_WORD	),
 
		.din     ( reg1_rd_data_i	),
		.qout    ( reg1_rd_data_o	)
	);

pipe_dff #(
		.DW(64)
	) reg2_data_dff (
		.clk     ( clk		),
		.rst_n   ( rst_n	),
 
		.hold_en ( hold_en	),
		.def_val ( `ZERO_WORD	),
 
		.din     ( reg2_rd_data_i	),
		.qout    ( reg2_rd_data_o	)
	);

pipe_dff #(
		.DW(1)
	) reg_wr_en_dff (
		.clk     ( clk		),
		.rst_n   ( rst_n	),
 
		.hold_en ( hold_en	),
		.def_val ( 1'b0	),
 
		.din     ( reg_wr_en_i	),
		.qout    ( reg_wr_en_o	)
	);

pipe_dff #(
		.DW(5)
	) reg_wr_addr_dff (
		.clk     ( clk		),
		.rst_n   ( rst_n	),
 
		.hold_en ( hold_en	),
		.def_val ( 5'h0	),
 
		.din     ( reg_wr_addr_i	),
		.qout    ( reg_wr_addr_o	)
	);

pipe_dff #(
		.DW(64)
	) op_reg1_dff (
		.clk     ( clk		),
		.rst_n   ( rst_n	),
 
		.hold_en ( hold_en	),
		.def_val ( `ZERO_WORD	),
 
		.din     ( op_reg1_i	),
		.qout    ( op_reg1_o	)
	);

pipe_dff #(
		.DW(64)
	) op_reg2_dff (
		.clk     ( clk		),
		.rst_n   ( rst_n	),
 
		.hold_en ( hold_en	),
		.def_val ( `ZERO_WORD	),
 
		.din     ( op_reg2_i	),
		.qout    ( op_reg2_o	)
	);

pipe_dff #(
		.DW(64)
	) op_jump1_dff (
		.clk     ( clk		),
		.rst_n   ( rst_n	),
 
		.hold_en ( hold_en	),
		.def_val ( `ZERO_WORD	),
 
		.din     ( op_jump1_i	),
		.qout    ( op_jump1_o	)
	);

pipe_dff #(
		.DW(64)
	) op_jump2_dff (
		.clk     ( clk		),
		.rst_n   ( rst_n	),
 
		.hold_en ( hold_en	),
		.def_val ( `ZERO_WORD	),
 
		.din     ( op_jump2_i	),
		.qout    ( op_jump2_o	)
	);


endmodule
