
//**********************************************
//COPYRIGHT(c)2021, Xidian University
//All rights reserved.
//
//File name     : defines.v
//Module name   : defines	
//Full name     :
//Author 		: Xu Mingwei
//Email 		: xumingweiaa@qq.com
//
//Version 		:
//This File is  Created on 2021-07-12 14:48:12
//------------------Discription-----------------
//
//----------------------------------------------
//-------------Modification history-------------
//Last Modified by 	: xumingwei
//Last Modified time: 2021-07-12 14:48:12
//Discription 	:
//----------------------------------------------
//TIMESCALE
`timescale 1ns/1ps
//DEFINES
//`include ".v"
//----------------------------------------------


`define ZERO_WORD    64'h0
`define MAX_WORD     64'hffff_ffff_ffff_ffff

// data bus's width
`define DATA_BUS_WIDTH    63 : 0
// addr bus's width
`define ADDR_BUS_WIDTH	  63 : 0
// inst's width
`define INST_WIDTH    31 : 0
// ROM & RAM's depth
`define ROM_DEPTH    32-1 : 0
`define ROM_WIDTH    32
`define RAM_DEPTH    4096-1 : 0
`define RAM_WIDTH    4096
// Register address's width
`define REG_ADDR_DEPTH    4 : 0
// RAM address's width
`define RAM_ADDR_WIDTH    31 : 0


`define RESET_ADDR    64'h0


// 流水线控制信号
`define HOLD_NONE  3'b000
`define HOLD_PC    3'b001
`define HOLD_IF    3'b010
`define HOLD_ID    3'b011

// I type inst
`define INST_TYPE_I 7'b0010011
`define INST_ADDI   3'b000
`define INST_SLTI   3'b010
`define INST_SLTIU  3'b011
`define INST_XORI   3'b100
`define INST_ORI    3'b110
`define INST_ANDI   3'b111
`define INST_SLLI   3'b001
`define INST_SRI    3'b101

// L type inst
`define INST_TYPE_L 7'b0000011
`define INST_LB     3'b000
`define INST_LH     3'b001
`define INST_LW     3'b010
`define INST_LBU    3'b100
`define INST_LHU    3'b101
// RV64I extend
`define INST_LWU	3'b110
`define INST_LD     3'b011

// S type inst
`define INST_TYPE_S 7'b0100011
`define INST_SB     3'b000
`define INST_SH     3'b001
`define INST_SW     3'b010
// RV64I extend
`define INST_SD     3'b011

// R型指令
`define INST_TYPE_R 7'b0110011
`define INST_ADD_SUB 3'b000
`define INST_SLL    3'b001
`define INST_SLT    3'b010
`define INST_SLTU   3'b011
`define INST_XOR    3'b100
`define INST_SR     3'b101
`define INST_OR     3'b110
`define INST_AND    3'b111

// J型指令
`define INST_JAL    7'b1101111
`define INST_JALR   7'b1100111

`define INST_LUI    7'b0110111
`define INST_AUIPC  7'b0010111
`define INST_NOP    32'h00000001
`define INST_NOP_OP 7'b0000001
`define INST_MRET   32'h30200073
`define INST_RET    32'h00008067

`define INST_FENCE  7'b0001111
`define INST_ECALL  32'h73
`define INST_EBREAK 32'h00100073

// B型指令
`define INST_TYPE_B 7'b1100011
`define INST_BEQ    3'b000
`define INST_BNE    3'b001
`define INST_BLT    3'b100
`define INST_BGE    3'b101
`define INST_BLTU   3'b110
`define INST_BGEU   3'b111

// NOP指令
`define INST_NOP_OP 7'b0000001

// RV64I扩展：I型指令
`define INST_TYPE_64_I    7'b0011011
`define INST_ADDIW    3'b000
`define INST_SLLIW    3'b001
`define INST_SRIW     3'b101

// RV64I扩展：R型指令
`define INST_TYPE_64_R    7'b0111011
`define INST_ADDW_SUBW    3'b000
`define INST_SLLW  		  3'b001
`define INST_SRW 		  3'b101

