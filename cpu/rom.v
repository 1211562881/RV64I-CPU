
//**********************************************
//COPYRIGHT(c)2021, Xidian University
//All rights reserved.
//
//File name     : rom.v
//Module name   : rom	
//Full name     :
//Author 		: Xu Mingwei
//Email 		: xumingweiaa@qq.com
//
//Version 		:
//This File is  Created on 2021-07-11 16:59:18
//------------------Discription-----------------
//
//----------------------------------------------
//-------------Modification history-------------
//Last Modified by 	: xumingwei
//Last Modified time: 2021-07-11 16:59:18
//Discription 	:
//----------------------------------------------
//TIMESCALE
`timescale 1ns/1ps
//DEFINES
`include "defines.v"
//----------------------------------------------

module rom(
	input		[`ADDR_BUS_WIDTH]	inst_addr_i,
	output reg	[`INST_WIDTH]		inst_o
);

// ROM
reg	[`INST_WIDTH]	rom_reg	[`ROM_DEPTH];



integer j;
initial begin
	$readmemh( "inst.bin", rom_reg );
	for( j=0; j<32; j=j+1 )
		$display( "%h", rom_reg[j] );
end


always @(*) begin
	inst_o = rom_reg[inst_addr_i[63:2]];
end



endmodule
