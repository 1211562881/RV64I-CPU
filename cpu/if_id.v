
//**********************************************
//COPYRIGHT(c)2021, Xidian University
//All rights reserved.
//
//File name     : if_id.v
//Module name   : if_id	
//Full name     :
//Author 		: Xu Mingwei
//Email 		: xumingweiaa@qq.com
//
//Version 		:
//This File is  Created on 2021-07-11 16:49:34
//------------------Discription-----------------
//
//----------------------------------------------
//-------------Modification history-------------
//Last Modified by 	: xumingwei
//Last Modified time: 2021-07-11 16:49:34
//Discription 	:
//----------------------------------------------
//TIMESCALE
`timescale 1ns/1ps
//DEFINES
`include "defines.v"
//----------------------------------------------

module if_id(
	input			    		clk				,
	input			    		rst_n			,

	input	[`INST_WIDTH]		inst_i			,	// 指令内容输入
	input	[`ADDR_BUS_WIDTH]	inst_addr_i		,	// 指令地址输入

	input	[2:0]				pipe_hold_en_i 	,	// 流水线停顿信号

	output	[`INST_WIDTH]		inst_o 			,	// 指令内容缓存输出
	output	[`ADDR_BUS_WIDTH]	inst_addr_o			// 指令地址缓存输出 
);


wire	hold_en = pipe_hold_en_i >= 3'b010;


// 缓存指令数据
pipe_dff #(
		.DW(32)
	) inst_dff (
		.clk     (clk),
		.rst_n   (rst_n),

		.hold_en (hold_en),
		.def_val (32'h00000001),	// NOP指令冲刷流水线

		.din     (inst_i),
		.qout    (inst_o)
	);


// 缓存指令地址
pipe_dff #(
		.DW(64)
	) inst_addr_dff (
		.clk     (clk),
		.rst_n   (rst_n),

		.hold_en (hold_en),
		.def_val (`ZERO_WORD),

		.din     (inst_addr_i),
		.qout    (inst_addr_o)
	);


endmodule
