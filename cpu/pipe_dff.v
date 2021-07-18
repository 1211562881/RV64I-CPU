
//**********************************************
//COPYRIGHT(c)2021, Xidian University
//All rights reserved.
//
//File name     : pipe_dff.v
//Module name   : pipe_dff	
//Full name     :
//Author 		: Xu Mingwei
//Email 		: xumingweiaa@qq.com
//
//Version 		:
//This File is  Created on 2021-07-11 16:52:53
//------------------Discription-----------------
//
//----------------------------------------------
//-------------Modification history-------------
//Last Modified by 	: xumingwei
//Last Modified time: 2021-07-11 16:52:53
//Discription 	:
//----------------------------------------------
//TIMESCALE
`timescale 1ns/1ps
//DEFINES
//`include ".v"
//----------------------------------------------

module pipe_dff#(
    parameter DW = 32)
(

    input  wire 			clk		,
    input  wire 			rst_n	,

    input  wire 			hold_en	,

    input  wire[DW-1:0]  	def_val	,
    input  wire[DW-1:0]  	din 	,
    output wire[DW-1:0]  	qout
    );


reg[DW-1:0] qout_r;


always @ (posedge clk) begin
    if (!rst_n | hold_en) begin
        qout_r <= def_val;
    end 
    else begin
        qout_r <= din;
    end
end


assign qout = qout_r;


endmodule
