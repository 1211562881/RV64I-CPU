
//**********************************************
//COPYRIGHT(c)2021, Xidian University
//All rights reserved.
//
//File name     : endian_exchange.v
//Module name   : endian_exchange	
//Full name     :
//Author 		: Xu Mingwei
//Email 		: xumingweiaa@qq.com
//
//Version 		:
//This File is  Created on 2021-06-23 17:37:38
//------------------Discription-----------------
//
//----------------------------------------------
//-------------Modification history-------------
//Last Modified by 	: xumingwei
//Last Modified time: 2021-06-23 17:59:15
//Discription 	:
//----------------------------------------------
//TIMESCALE
`timescale 1ns/1ns
//DEFINES
//`include ".v"
//----------------------------------------------

module endian_exchange #(
		parameter	DATA_WIDTH = 32  	  ,		// 数据总线宽度
		parameter	UNIT_WIDTH = 8				// 存储单元宽度
	)
	(
	input		[DATA_WIDTH-1:0]	din   ,		// input  data
	output reg	[DATA_WIDTH-1:0]	dout  ,		// output data
	input							en   
);


localparam	EXC_NUM = DATA_WIDTH / UNIT_WIDTH;	// 交换次数


// 大小端切换
integer i;
always @(*) begin
	if( en == 1'b1 ) begin
		for( i=0; i<EXC_NUM; i=i+1 ) begin
			dout[i*UNIT_WIDTH+:UNIT_WIDTH] = din[(DATA_WIDTH-1-i*UNIT_WIDTH)-:UNIT_WIDTH];
		end
	end
	else begin
		dout = din;
	end
end


endmodule
