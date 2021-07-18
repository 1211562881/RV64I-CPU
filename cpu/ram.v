
//**********************************************
//COPYRIGHT(c)2021, Xidian University
//All rights reserved.
//
//File name     : ram.v
//Module name   : ram	
//Full name     :
//Author 		: Xu Mingwei
//Email 		: xumingweiaa@qq.com
//
//Version 		:
//This File is  Created on 2021-07-16 17:56:07
//------------------Discription-----------------
//
//----------------------------------------------
//-------------Modification history-------------
//Last Modified by 	: xumingwei
//Last Modified time: 2021-07-16 17:56:07
//Discription 	:
//----------------------------------------------
//TIMESCALE
`timescale 1ns/1ps
//DEFINES
`include "defines.v"
//----------------------------------------------

module ram(
	input			    			clk				,
	input			    			rst_n			,

	input	    [`RAM_ADDR_WIDTH]	mem_wr_addr_i	,	// RAM 写地址
	input	    					mem_wr_en_i		,	// RAM 写使能
	input	    [`DATA_BUS_WIDTH]	mem_wr_data_i	,	// RAM 写数据
	
	input	    [`RAM_ADDR_WIDTH]	mem_rd_addr_i	,	// RAM 读地址
	input	    					mem_rd_en_i		,	// RAM 读使能
	output reg	[`DATA_BUS_WIDTH]	mem_rd_data_o		// RAM 读数据
);


reg	[`DATA_BUS_WIDTH] ram_reg [`RAM_DEPTH];


// Write RAM
always @(posedge clk) begin : wr_ram
	integer i;
	if ( rst_n == 1'b0 ) begin
		for( i=0; i<=`RAM_WIDTH; i=i+1 )
			ram_reg[i] <= 64'd0;
	end
	else begin
		if( mem_wr_en_i == 1'b1 ) begin
			ram_reg[mem_wr_addr_i[31:3]] <= mem_wr_data_i;
		end
		else begin
			ram_reg[mem_wr_addr_i[31:3]] <= ram_reg[mem_wr_addr_i[31:3]];
		end
	end
end


// Read RAM
always @(*) begin
	if( mem_rd_en_i == 1'b1 ) begin
		mem_rd_data_o <= ram_reg[mem_rd_addr_i[31:3]];
	end
	else begin
		mem_rd_data_o <= 64'd0;
	end
end



endmodule
