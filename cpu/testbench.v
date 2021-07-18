
//**********************************************
//COPYRIGHT(c)2021, Xidian University
//All rights reserved.
//
//File name     : testbench.v
//Module name   : testbench	
//Full name     :
//Author 		: Xu Mingwei
//Email 		: xumingweiaa@qq.com
//
//Version 		:
//This File is  Created on 2021-07-16 21:27:33
//------------------Discription-----------------
//
//----------------------------------------------
//-------------Modification history-------------
//Last Modified by 	: xumingwei
//Last Modified time: 2021-07-16 21:27:33
//Discription 	:
//----------------------------------------------
//TIMESCALE
`timescale 1ns/1ns
//DEFINES
//`include ".v"
//----------------------------------------------

module testbench();

reg		clk;
reg		rst_n;


initial begin
	clk = 0;
	forever #5 clk = ~clk;
end


initial begin
	rst_n = 0;
	#100
	rst_n = 1;
	// #150
	// $stop;
end


// risc-v 64I Core
riscv_core inst_riscv_core (
		.clk(clk), 
		.rst_n(rst_n)
	);


endmodule
