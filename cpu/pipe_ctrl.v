
//**********************************************
//COPYRIGHT(c)2021, Xidian University
//All rights reserved.
//
//File name     : pipe_ctrl.v
//Module name   : pipe_ctrl	
//Full name     :
//Author 		: Xu Mingwei
//Email 		: xumingweiaa@qq.com
//
//Version 		:
//This File is  Created on 2021-07-14 18:02:29
//------------------Discription-----------------
//
//----------------------------------------------
//-------------Modification history-------------
//Last Modified by 	: xumingwei
//Last Modified time: 2021-07-14 18:02:29
//Discription 	:
//----------------------------------------------
//TIMESCALE
`timescale 1ns/1ps
//DEFINES
`include "defines.v"
//----------------------------------------------

module pipe_ctrl(
	// 来自 ex 模块的流水线暂停信号
	input							jump_en_i		,	// 跳转使能输入
	input	  	[`ADDR_BUS_WIDTH]	jump_addr_i		,	// 跳转地址输入

	// 来自 axi 总线的流水线暂停信号


	// 来自中断控制器的流水线暂停信号


	// 流水线控制信号
	output reg	[2:0]	    		pipe_hold_en_o	,	// 流水线停顿信号

	// 去往 pc 模块
	output reg						jump_en_o		,	// 跳转使能输出
	output reg	[`ADDR_BUS_WIDTH]	jump_addr_o			// 跳转地址输出
);


always @(*) begin
	jump_en_o = jump_en_i;
	jump_addr_o = jump_addr_i;
	pipe_hold_en_o = `HOLD_NONE;

	if( jump_en_i == 1'b1 ) begin
		pipe_hold_en_o = `HOLD_ID;
	end
	else begin
		pipe_hold_en_o = `HOLD_NONE;
	end
end


endmodule
