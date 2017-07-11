`timescale 1ns / 1ps
`include "Defintions.v"

/*Etiquetas de iAddress*/
`define SET_XSOFF   8'd9

`define DRAW_SQR    8'd52
`define X0_SQR      8'd53
`define COLOR2VRAM  8'd54

`define CHECK       8'd63
`define CHK2        8'd71
`define RETCHK      8'd78

`define WAIT        8'd79
`define WAIT_L      8'd80
`define WAIT_S      8'd82

`define DRAW_SHIP   8'd89
`define DRW_FOO     8'd229

`define DELAY       16'd724


module ROM
       (
         input wire [15:0] iAddress,
         input wire [3:0] iShipX, iShipY,
         input wire [3:0] iFooX,
         output reg [27:0] oInstruction
       );
/*Algunas dimensiones*/
localparam VRAM_W  = 16'd79;
localparam VRAM_H  = 16'd59;

localparam SQR_W = 8'd5;
localparam MSQR  = 8'd6;
localparam YKMAX = 16'd9;
localparam XOFF  = 8'd28;
localparam YOFF  = 8'd0;
localparam XOFF16  = 16'd28;
localparam YOFF16  = 16'd0;

wire [3:0] nFooX;

assign nFooX = ({2'd0, ~iFooX[1:0]});

always @ ( iAddress )
  begin
    case (iAddress)
      /****************************************************************/
      /*--------------------------------------------------------------*/
              0  : oInstruction = { `NOP , 24'd0 };

              1  : oInstruction = { `STO , `R10, 16'd0}; //R4=xi
              2  : oInstruction = { `STO , `R4, 16'd0}; //R4=xi
              3  : oInstruction = { `STO , `R5, 16'd0}; //R5=yi
              4  : oInstruction = { `STO , `R2, VRAM_W}; //R2=xf
              5  : oInstruction = { `STO , `R3, VRAM_H}; //R3=yf
              6  : oInstruction = { `RGB , 8'd0, `COLOR_CYAN, 8'd0}; //Set color
              7  : oInstruction = { `CALL , `DRAW_SQR, 16'd0 }; //Dibuja un cuadro
              8  : oInstruction = { `NOP , 24'd0 };

              //9  : oInstruction = { `LED , 8'b0, `R10, 8'b0 };
/*SET_XSOFF*/ 9  : oInstruction = { `NOP , 24'd0 };
              10 : oInstruction = { `STO , `R4, XOFF16}; //R4=xi
              11 : oInstruction = { `STO , `R5, YOFF16}; //R5=yi
              12 : oInstruction = { `STO , `R2, (VRAM_W-XOFF16)}; //R2=xf
              13 : oInstruction = { `STO , `R3, (VRAM_H-YOFF16+16'd1)}; //R3=yf
              14 : oInstruction = { `RGB , 8'd0, `COLOR_BLACK, 8'd0}; //Set color
              15 : oInstruction = { `CALL , `DRAW_SQR, 16'd0};

              16 : oInstruction = { `STO , `R8, {12'd0, iFooX}}; //R8=iShipX=Xk
              17 : oInstruction = { `STO , `R9, {12'd0, 4'd2}}; //R9=iShipY=Yk
              //17 : oInstruction = { `NOP , 24'd0 };
              18 : oInstruction = { `STO , `R6, 16'd1}; //R6=1
              19 : oInstruction = { `MULi , `R11, `R8, MSQR}; //R11=Xk*M
              20 : oInstruction = { `MULi , `R12, `R9, MSQR}; //R12=Yk*M

              21 : oInstruction = { `ADDi , `R4, `R11, XOFF}; //R4=xsi+xsoff
              22 : oInstruction = { `ADDi , `R5, `R12, YOFF}; //R5=yi
              23 : oInstruction = { `ADDi , `R2, `R4, SQR_W}; //R3=yf
              24 : oInstruction = { `ADDi , `R3, `R5, SQR_W}; //R3=yf
              25 : oInstruction = { `RGB , 8'd0, `COLOR_GREEN, 8'd0}; //Set color
              26 : oInstruction = { `CALL , `DRAW_SHIP, 16'd0};

              27 : oInstruction = { `STO , `R8, {12'd0, nFooX}}; //R8=iShipX=Xk
              28 : oInstruction = { `STO , `R9, {12'd0, 4'd3}}; //R9=iShipY=Yk
              29 : oInstruction = { `STO , `R6, 16'd1}; //R6=1
              30 : oInstruction = { `MULi , `R11, `R8, MSQR}; //R11=Xk*M
              31 : oInstruction = { `MULi , `R12, `R9, MSQR}; //R12=Yk*M

              32 : oInstruction = { `ADDi , `R4, `R11, XOFF}; //R4=xsi+xsoff
              33 : oInstruction = { `ADDi , `R5, `R12, YOFF}; //R5=yi
              34 : oInstruction = { `ADDi , `R2, `R4, SQR_W}; //R3=yf
              35 : oInstruction = { `ADDi , `R3, `R5, SQR_W}; //R3=yf
              36 : oInstruction = { `RGB , 8'd0, `COLOR_GREEN, 8'd0}; //Set color
              37 : oInstruction = { `CALL , `DRAW_SHIP, 16'd0};

              38 : oInstruction = { `STO , `R8, {12'd0, iShipX}}; //R8=iShipX=Xk
              39 : oInstruction = { `STO , `R9, {12'd0, iShipY}}; //R9=iShipY=Yk
              40 : oInstruction = { `STO , `R6, 16'd0}; //R6=0
              41 : oInstruction = { `MULi , `R11, `R8, MSQR}; //R11=Xk*M
              42 : oInstruction = { `MULi , `R12, `R9, MSQR}; //R12=Yk*M

              43 : oInstruction = { `ADDi , `R4, `R11, XOFF}; //R4=xsi+xsoff
              44 : oInstruction = { `ADDi , `R5, `R12, YOFF}; //R5=yi
              45 : oInstruction = { `ADDi , `R2, `R4, SQR_W}; //R3=yf
              46 : oInstruction = { `ADDi , `R3, `R5, SQR_W}; //R3=yf
              47 : oInstruction = { `RGB , 8'd0, `COLOR_RED, 8'd0}; //Set color
              48 : oInstruction = { `CALL , `DRAW_SHIP, 16'd0};

              49 : oInstruction = { `CALL , `CHECK, 16'd0};
              50 : oInstruction = { `CALL , `WAIT, 16'd0};

              51 : oInstruction = { `JMP , `SET_XSOFF, 16'b0 };
              /***********************************************************************/
              /* Subrutina que carga en VRAM un cuadro del color asignado*/
/*DRAW_SQR*/  52 : oInstruction = { `ADDi , `R1, `R5, 8'd0}; //y0=yi
/*X0_SQR*/    53 : oInstruction = { `ADDi , `R0, `R4, 8'd0}; //x0=xi
/*COLOR2VRAM*/54 : oInstruction = { `NOP , 24'd0 };
              55 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM
              56 : oInstruction = { `INC , `R0, `R0, 8'd0}; //x0++
              57 : oInstruction = { `NOP , 24'd0 };
              58 : oInstruction = { `BLE , `COLOR2VRAM, `R0, `R2}; //Salta si x0<=xf
              59 : oInstruction = { `INC , `R1, `R1, 8'd0}; //y0++
              60 : oInstruction = { `NOP , 24'd0 };
              61 : oInstruction = { `BLE , `X0_SQR, `R1, `R3}; //Salta si y0<=yf
              62 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa

              /*Subrutina que evalua si hay colisiones*/
/*CHECK*/     63 : oInstruction = { `STO , `R6, {12'd0, iFooX}}; //R8=iShipX=Xk
              64 : oInstruction = { `STO , `R7, {12'd0, 4'd2}}; //R9=iShipY=Yk
              65 : oInstruction = { `NOP , 24'd0 };
              66 : oInstruction = { `BNE , `CHK2, `R6, `R8}; //Salta si y0!=yf
              67 : oInstruction = { `BNE , `CHK2, `R7, `R9}; //Salta si y0!=yf
              68 : oInstruction = { `INC , `R10, `R10, 8'd0}; //x0++
              69 : oInstruction = { `DFT , 24'd0 }; //Restaura valores por defecto
              70 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa
/*CHK2*/      71 : oInstruction = { `STO , `R6, {12'd0, nFooX}}; //R8=iShipX=Xk
              72 : oInstruction = { `STO , `R7, {12'd0, 4'd3}}; //R9=iShipY=Yk
              73 : oInstruction = { `NOP , 24'd0 };
              74 : oInstruction = { `BNE , `RETCHK, `R6, `R8}; //Salta si y0!=yf
              75 : oInstruction = { `BNE , `RETCHK, `R7, `R9}; //Salta si y0!=yf
              76 : oInstruction = { `INC , `R10, `R10, 8'd0}; //x0++
              77 : oInstruction = { `DFT , 24'd0 }; //Restaura valores por defecto
/*RETCHK*/    78 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa

              /*Subrutina que espera durante R15^2 ciclos*/
/*WAIT*/      79  : oInstruction = { `STO , `R13, 16'd0}; //
/*WAIT_L*/    80  : oInstruction = { `STO , `R14, 16'd0}; //
              81  : oInstruction = { `STO , `R15, `DELAY}; //
/*WAIT_S*/    82 : oInstruction = { `INC , `R14, `R14, 8'd0}; //x0++
              83 : oInstruction = { `NOP , 24'd0 };
              84 : oInstruction = { `BLE , `WAIT_S, `R14, `R15}; //Salta si y0<=yf
              85 : oInstruction = { `INC , `R13, `R13, 8'd0}; //x0++
              86 : oInstruction = { `NOP , 24'd0 };
              87 : oInstruction = { `BLE , `WAIT_L, `R13, `R15}; //Salta si y0<=yf
              88 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa

              /*Subrutina que carga en VRAM una nave del color asignado*/
/*DRAW_SHIP*/ 89 : oInstruction = { `STO , `R0, 16'd0}; //x0
              90 : oInstruction = { `STO , `R1, 16'd1}; //y0
              91 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              92 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              //107 : oInstruction = { `NOP , 24'd0 };
              93 : oInstruction = { `STO , `R7, 16'd0}; //R7=0
              94 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              95 : oInstruction = { `STO , `R0, 16'd2}; //x0
              96 : oInstruction = { `STO , `R1, 16'd1}; //y0
              97 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              98 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              99 : oInstruction = { `NOP , 24'd0 };
              100 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              101 : oInstruction = { `STO , `R0, 16'd2}; //x0
              102 : oInstruction = { `STO , `R1, 16'd1}; //y0
              103 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              104 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              105 : oInstruction = { `NOP , 24'd0 };
              106 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              107 : oInstruction = { `STO , `R0, 16'd3}; //x0
              108 : oInstruction = { `STO , `R1, 16'd1}; //y0
              109 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              110 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              111 : oInstruction = { `NOP , 24'd0 };
              112 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              113 : oInstruction = { `STO , `R0, 16'd5}; //x0
              114 : oInstruction = { `STO , `R1, 16'd1}; //y0
              115 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              116 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              117 : oInstruction = { `NOP , 24'd0 };
              118 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              119 : oInstruction = { `STO , `R0, 16'd0}; //x0
              120 : oInstruction = { `STO , `R1, 16'd2}; //y0
              121 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              122 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              123 : oInstruction = { `NOP , 24'd0 };
              124 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              125 : oInstruction = { `STO , `R0, 16'd2}; //x0
              126 : oInstruction = { `STO , `R1, 16'd2}; //y0
              127 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              128 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              129 : oInstruction = { `NOP , 24'd0 };
              130 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              131 : oInstruction = { `STO , `R0, 16'd3}; //x0
              132 : oInstruction = { `STO , `R1, 16'd2}; //y0
              133 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              134 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              135 : oInstruction = { `NOP , 24'd0 };
              136 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              137 : oInstruction = { `STO , `R0, 16'd5}; //x0
              138 : oInstruction = { `STO , `R1, 16'd2}; //y0
              139 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              140 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              141 : oInstruction = { `NOP , 24'd0 };
              142 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              143 : oInstruction = { `STO , `R0, 16'd0}; //x0
              144 : oInstruction = { `STO , `R1, 16'd3}; //y0
              145 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              146 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              147 : oInstruction = { `NOP , 24'd0 };
              148 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              149 : oInstruction = { `STO , `R0, 16'd2}; //x0
              150 : oInstruction = { `STO , `R1, 16'd3}; //y0
              151 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              152 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              153 : oInstruction = { `NOP , 24'd0 };
              154 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              155 : oInstruction = { `STO , `R0, 16'd3}; //x0
              156 : oInstruction = { `STO , `R1, 16'd3}; //y0
              157 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              158 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              159 : oInstruction = { `NOP , 24'd0 };
              160 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              161 : oInstruction = { `STO , `R0, 16'd5}; //x0
              162 : oInstruction = { `STO , `R1, 16'd3}; //y0
              163 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              164 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              165 : oInstruction = { `NOP , 24'd0 };
              166 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM7

              167 : oInstruction = { `STO , `R0, 16'd0}; //x0
              168 : oInstruction = { `STO , `R1, 16'd4}; //y0
              169 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              170 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              171 : oInstruction = { `NOP , 24'd0 };
              172 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              173 : oInstruction = { `STO , `R0, 16'd2}; //x0
              174 : oInstruction = { `STO , `R1, 16'd4}; //y0
              175 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              176 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              177 : oInstruction = { `NOP , 24'd0 };
              178 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              179 : oInstruction = { `STO , `R0, 16'd3}; //x0
              180 : oInstruction = { `STO , `R1, 16'd4}; //y0
              181 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              182 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              183 : oInstruction = { `NOP , 24'd0 };
              184 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              185 : oInstruction = { `STO , `R0, 16'd5}; //x0
              186 : oInstruction = { `STO , `R1, 16'd4}; //y0
              187 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              188 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              189 : oInstruction = { `NOP , 24'd0 };
              190 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM


              191 : oInstruction = { `BNE , `DRW_FOO, `R6, `R7}; //Salta si R6!=0

              192 : oInstruction = { `STO , `R0, 16'd1}; //x0
              193 : oInstruction = { `STO , `R1, 16'd5}; //y0
              194 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              195 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              196 : oInstruction = { `NOP , 24'd0 };
              197 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              198 : oInstruction = { `STO , `R0, 16'd4}; //x0
              199 : oInstruction = { `STO , `R1, 16'd5}; //y0
              200 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              201 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              202 : oInstruction = { `NOP , 24'd0 };
              203 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM


              204 : oInstruction = { `STO ,`R0, 16'd2}; //x0
              205 : oInstruction = { `STO, `R1, 16'd0}; //y0
              206 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              207 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              208 : oInstruction = { `NOP , 24'd0 };
              209 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              210 : oInstruction = { `STO , `R0, 16'd3}; //x0
              211 : oInstruction = { `STO, `R1, 16'd0}; //y0
              212 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              213 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              214 : oInstruction = { `NOP , 24'd0 };
              215 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              216 : oInstruction = { `STO , `R0, 16'd1}; //x0
              217 : oInstruction = { `STO , `R1, 16'd3}; //y0
              218 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              219 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              220 : oInstruction = { `NOP , 24'd0 };
              221 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              222 : oInstruction = { `STO , `R0, 16'd4}; //x0
              223 : oInstruction = { `STO , `R1, 16'd3}; //y0
              224 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              225 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              226 : oInstruction = { `NOP , 24'd0 };
              227 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              228 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa

/*DRW_FOO*/   229 : oInstruction = { `STO , `R0, 16'd1}; //x0
              230 : oInstruction = { `STO , `R1, 16'd0}; //y0
              231 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              232 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              233 : oInstruction = { `NOP , 24'd0 };
              234 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              235 : oInstruction = { `STO , `R0, 16'd4}; //x0
              236 : oInstruction = { `STO , `R1, 16'd0}; //y0
              237 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              238 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              239 : oInstruction = { `NOP , 24'd0 };
              240 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              241 : oInstruction = { `STO ,`R0, 16'd2}; //x0
              242 : oInstruction = { `STO, `R1, 16'd5}; //y0
              243 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              244 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              245 : oInstruction = { `NOP , 24'd0 };
              246 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              247 : oInstruction = { `STO , `R0, 16'd3}; //x0
              248 : oInstruction = { `STO, `R1, 16'd5}; //y0
              249 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              250 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              251 : oInstruction = { `NOP , 24'd0 };
              252 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              253 : oInstruction = { `STO , `R0, 16'd1}; //x0
              254 : oInstruction = { `STO , `R1, 16'd2}; //y0
              255 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              256 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              257 : oInstruction = { `NOP , 24'd0 };
              258 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              259 : oInstruction = { `STO , `R0, 16'd4}; //x0
              260 : oInstruction = { `STO , `R1, 16'd2}; //y0
              261 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              262 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              263 : oInstruction = { `NOP , 24'd0 };
              264 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              265 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa


      /*--------------------------------------------------------------*/
      /****************************************************************/
      default:
        oInstruction = { `NOP , 24'd0	};		//NOP
    endcase
  end

endmodule
