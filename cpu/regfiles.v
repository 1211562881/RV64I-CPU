
//**********************************************
//COPYRIGHT(c)2021, Xidian University
//All rights reserved.
//
//File name     : regfiles.v
//Module name   : regfiles	
//Full name     :
//Author 		: Xu Mingwei
//Email 		: xumingweiaa@qq.com
//
//Version 		:
//This File is  Created on 2021-07-14 17:03:48
//------------------Discription-----------------
//
//----------------------------------------------
//-------------Modification history-------------
//Last Modified by 	: xumingwei
//Last Modified time: 2021-07-14 17:03:48
//Discription 	:
//----------------------------------------------
//TIMESCALE
`timescale 1ns/1ps
//DEFINES
`include "defines.v"
//----------------------------------------------

module regfiles(
	input				    		clk				,
	input				    		rst_n			,

	input		[`REG_ADDR_DEPTH]	reg1_rd_addr_i	,	// 寄存器1读地址
	input		[`REG_ADDR_DEPTH]	reg2_rd_addr_i	,	// 寄存器2读地址

	output reg	[`DATA_BUS_WIDTH]	reg1_rd_data_o	,	// 寄存器1读出数据
	output reg	[`DATA_BUS_WIDTH]	reg2_rd_data_o	,	// 寄存器2读出数据

	input							reg_wr_en_i		,	// 寄存器堆写使能
	input		[`REG_ADDR_DEPTH]	reg_wr_addr_i	,	// 寄存器堆写地址
	input		[`DATA_BUS_WIDTH]	reg_wr_data_i		// 寄存器堆写数据
);


reg [`DATA_BUS_WIDTH]	RegFileMem [31:0];	// 寄存器堆


// Write Registers
always @(posedge clk) begin : wr_reg
	integer i;
	if ( rst_n == 1'b0 ) begin
		for( i=0; i<=31; i=i+1 )
			RegFileMem[i] <= 64'd0;
	end
	else begin
		if( (reg_wr_en_i == 1'b1) && (reg_wr_addr_i != 5'h0) ) begin
			RegFileMem[reg_wr_addr_i] <= reg_wr_data_i;
		end
		else begin
			RegFileMem[reg_wr_addr_i] <= RegFileMem[reg_wr_addr_i];
		end
	end
end


// Read Registers 1
always @(*) begin
	if( (reg_wr_en_i == 1'b1) && (reg1_rd_addr_i == reg_wr_addr_i) ) begin
		reg1_rd_data_o = reg_wr_data_i;		// 数据前递/旁路
	end
	else begin
		reg1_rd_data_o = RegFileMem[reg1_rd_addr_i];
	end
end


// Read Registers 2
always @(*) begin
	if( (reg_wr_en_i == 1'b1) && (reg2_rd_addr_i == reg_wr_addr_i) ) begin
		reg2_rd_data_o = reg_wr_data_i;		// 数据前递/旁路
	end
	else begin
		reg2_rd_data_o = RegFileMem[reg2_rd_addr_i];
	end
end


endmodule
