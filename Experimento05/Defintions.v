`timescale 1ns / 1ps
`ifndef DEFINTIONS_V
`define DEFINTIONS_V

`default_nettype none

`define NOP   4'd0
`define SMUL  4'd1
`define BLE   4'd2
`define STO   4'd3
`define ADD   4'd4
`define JMP   4'd5
`define SUB   4'd6
`define CALL  4'd7
`define RET   4'd8
`define VGA   4'd9
`define INC   4'd10
`define MOV   4'd11
`define BEQ   4'd12


`define R0  8'd0
`define R1  8'd1
`define R2  8'd2
`define R3  8'd3
`define R4  8'd4
`define R5  8'd5
`define R6  8'd6
`define R7  8'd7
`define R8  8'd8
`define R9  8'd9
`define R10 8'd10
`define R11 8'd11
`define R12 8'd12
`define R13 8'd13
`define R14 8'd14
`define R15 8'd15

//Colores en 8 bits
`define COLOR_BLACK   8'b00000000
`define COLOR_BLUE    8'b00000001
`define COLOR_GREEN   8'b00000010
`define COLOR_CYAN    8'b00000011
`define COLOR_RED     8'b00000100
`define COLOR_MAGENTA 8'b00000101
`define COLOR_YELLOW  8'b00000110
`define COLOR_WHITE   8'b00000111

//Colores en 3 bits
`define BLACK   3'd0
`define BLUE    3'd1
`define GREEN   3'd2
`define CYAN    3'd3
`define RED     3'd4
`define MAGENTA 3'd5
`define YELLOW  3'd6
`define WHITE   3'd7

`endif


`ifndef SYNC_CONSTS
`define SYNC_CONSTS

`define HS_Ts     800
`define HS_Tdisp  640
`define HS_Tpw    96
`define HS_Tfp    16
`define HS_Tbp    48

`define VS_lines_Ts     521
`define VS_lines_Tdisp  480
`define VS_lines_Tpw    2
`define VS_lines_Tfp    10
`define VS_lines_Tbp    29

`define V_OFFSET        0
`define H_OFFSET        0

`endif
