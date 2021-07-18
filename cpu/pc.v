
//**********************************************
//COPYRIGHT(c)2021, Xidian University
//All rights reserved.
//
//File name     : pc.v
//Module name   : pc	
//Full name     :
//Author 		: Xu Mingwei
//Email 		: xumingweiaa@qq.com
//
//Version 		:
//This File is  Created on 2021-07-11 14:59:21
//------------------Discription-----------------
//
//----------------------------------------------
//-------------Modification history-------------
//Last Modified by 	: xumingwei
//Last Modified time: 2021-07-11 14:59:21
//Discription 	:
//----------------------------------------------
//TIMESCALE
`timescale 1ns/1ps
//DEFINES
`include "defines.v"
//----------------------------------------------

module pc(
	input			    			clk				,
	input			    			rst_n			,
    
	input			    			jump_en_i		,	// 跳转使能
	input	   [`ADDR_BUS_WIDTH]	jump_addr_i		,	// 跳转地址
    
	input	   [2:0]	    		pipe_hold_en_i	,	// 流水线停顿信号

	output reg [`ADDR_BUS_WIDTH]	pc_o			
);


always @(posedge clk) begin
	if ( rst_n == 1'b0 ) begin
		pc_o <= `RESET_ADDR;
	end
	else if( jump_en_i == 1'b1 ) begin	
		pc_o <= jump_addr_i;
	end
	else if( pipe_hold_en_i >= 3'b001 ) begin	
		pc_o <= pc_o;	// 暂停PC
	end
	else begin
		pc_o <= pc_o + 4'h4;
	end
end


endmodule
