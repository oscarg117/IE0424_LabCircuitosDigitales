`timescale 1ns / 1ps
`include "Defintions.v"

/*Etiquetas de iAddress*/
`define START         8'd0

`define SET_XSOFF   8'd10
`define UPD_BG      8'd11

`define THE_END       8'd43

`define DRAW_SQR    8'd46
`define X0_SQR      8'd47
`define COLOR2VRAM     8'd48

`define WAIT          8'd79
`define WAIT_L        8'd80
`define WAIT_S        8'd82

`define DRAW_SHIP     8'd90

`define DELAY         16'd1800


module ROM
       (
         input wire [15:0] iAddress,
         output reg [27:0] oInstruction
       );
/*Algunas dimensiones*/
localparam VRAM_W  = 16'd79;
localparam VRAM_H  = 16'd59;

localparam SQR_W  = 16'd5;
localparam OFFS_X = 16'd22;
localparam OFFS_Y = 16'd0;

localparam RSQR_X  = OFFS_X+16'd14;
localparam RSQR_Y  = VRAM_H-SQR_W-16'd8;



always @ ( iAddress )
  begin
    case (iAddress)
      /****************************************************************/
      /*--------------------------------------------------------------*/
              0  : oInstruction = { `NOP , 24'd0 };
              1  : oInstruction = { `STO , `R6, SQR_W}; //R6=sqr width
              2  : oInstruction = { `STO , `R7, OFFS_X}; //R7=xsi
              3  : oInstruction = { `STO , `R9, 16'd30}; //R9=xsoff max

              4  : oInstruction = { `STO , `R4, 16'd0}; //R4=xi
              5  : oInstruction = { `STO , `R5, 16'd0}; //R5=yi
              6  : oInstruction = { `STO , `R2, VRAM_W}; //R2=xf
              7  : oInstruction = { `STO , `R3, VRAM_H}; //R3=yf
              8  : oInstruction = { `RGB , 8'd0, `COLOR_CYAN, 8'd0}; //Set color
              9  : oInstruction = { `CALL , `DRAW_SQR, 16'd0 }; //Dibuja un cuadro

/*SET_XSOFF*/ 10 : oInstruction = { `STO , `R8, 16'd0}; //R8=xsoff
/*UPD_BG*/    11 : oInstruction = { `STO , `R4, OFFS_X}; //R4=xi
              12 : oInstruction = { `STO , `R5, OFFS_Y}; //R5=yi
              13 : oInstruction = { `STO , `R2, (VRAM_W-OFFS_X)}; //R2=xf
              14 : oInstruction = { `STO , `R3, (VRAM_H-OFFS_Y+16'd1)}; //R3=yf
              15 : oInstruction = { `RGB , 8'd0, `COLOR_BLACK, 8'd0}; //Set color
              16 : oInstruction = { `CALL , `DRAW_SQR, 16'd0};

              17 : oInstruction = { `ADD , `R4, `R7, `R8}; //R4=xsi+xsoff
              18 : oInstruction = { `STO , `R5, RSQR_Y}; //R5=yi
              19 : oInstruction = { `ADD , `R2, `R4, `R6}; //R2=xf
              20 : oInstruction = { `ADD , `R3, `R5, `R6}; //R3=yf
              21 : oInstruction = { `RGB , 8'd0, `COLOR_BLUE, 8'd0}; //Set color
              22 : oInstruction = { `CALL , `DRAW_SHIP, 16'd0};

              //23 : oInstruction = { `INC , `R8, `R8, 8'd0}; //R8=xsoff++
              23 : oInstruction = { `ADD , `R8, `R8, `R6}; //R8=R8+6
              24 : oInstruction = { `CALL , `WAIT, 16'd0};
              25 : oInstruction = { `BLE , `UPD_BG, `R8, `R9}; //Salta si x0<=xf
              26 : oInstruction = { `JMP , `SET_XSOFF, 16'b0 };



              /***********************************************************************/
              //Label: THE_END
              43 : oInstruction = { `NOP , 24'd0 };
              //44 : oInstruction = { `JMP , `START, 16'b0 };
              44 : oInstruction = { `JMP , `THE_END, 16'b0 };
              /***********************************************************************/
              /* Subrutina que carga en VRAM un cuadro del color asignado*/
              //Label: DRAW_SQR
              46 : oInstruction = { `MOV , `R1, `R5, 8'd0}; //y0=yi
              //Label: X0_SQR
              47 : oInstruction = { `MOV , `R0, `R4, 8'd0}; //x0=xi
              //Label: COLOR2VRAM
              48 : oInstruction = { `NOP , 24'd0 };
              49 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM
              50 : oInstruction = { `INC , `R0, `R0, 8'd0}; //x0++
              51 : oInstruction = { `NOP , 24'd0 };
              52 : oInstruction = { `BLE , `COLOR2VRAM, `R0, `R2}; //Salta si x0<=xf
              53 : oInstruction = { `INC , `R1, `R1, 8'd0}; //y0++
              54 : oInstruction = { `NOP , 24'd0 };
              55 : oInstruction = { `BLE , `X0_SQR, `R1, `R3}; //Salta si y0<=yf
              56 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa

              //Label: WAIT  - Espera durante R15^2 ciclos
              79  : oInstruction = { `STO , `R13, 16'd0}; //R5=yi
              //Label: WAIT_L
              80  : oInstruction = { `STO , `R14, 16'd0}; //R4=xi
              81  : oInstruction = { `STO , `R15, `DELAY}; //R5=yi
              //Label: WAIT_S
              82 : oInstruction = { `INC , `R14, `R14, 8'd0}; //x0++
              83 : oInstruction = { `NOP , 24'd0 };
              84 : oInstruction = { `BLE , `WAIT_S, `R14, `R15}; //Salta si y0<=yf
              85 : oInstruction = { `INC , `R13, `R13, 8'd0}; //x0++
              86 : oInstruction = { `NOP , 24'd0 };
              87 : oInstruction = { `BLE , `WAIT_L, `R13, `R15}; //Salta si y0<=yf
              88 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa


              /* Subrutina que carga en VRAM una nave del color asignado*/
              //Label: DRAW_SHIP
              90 : oInstruction = { `STO ,`R0, 16'd2}; //x0
              91 : oInstruction = { `STO, `R1, 16'd0}; //y0
              92 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              93 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              94 : oInstruction = { `NOP , 24'd0 };
              95 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              96 : oInstruction = { `STO , `R0, 16'd3}; //x0
              97 : oInstruction = { `STO, `R1, 16'd0}; //y0
              98 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              99 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              100 : oInstruction = { `NOP , 24'd0 };
              101 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              102 : oInstruction = { `STO , `R0, 16'd0}; //x0
              103 : oInstruction = { `STO , `R1, 16'd1}; //y0
              104 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              105 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              106 : oInstruction = { `NOP , 24'd0 };
              107 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              108 : oInstruction = { `STO , `R0, 16'd2}; //x0
              109 : oInstruction = { `STO , `R1, 16'd1}; //y0
              110 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              111 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              112 : oInstruction = { `NOP , 24'd0 };
              113 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              114 : oInstruction = { `STO , `R0, 16'd2}; //x0
              115 : oInstruction = { `STO , `R1, 16'd1}; //y0
              116 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              117 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              118 : oInstruction = { `NOP , 24'd0 };
              119 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              120 : oInstruction = { `STO , `R0, 16'd3}; //x0
              121 : oInstruction = { `STO , `R1, 16'd1}; //y0
              122 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              123 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              124 : oInstruction = { `NOP , 24'd0 };
              125 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              126 : oInstruction = { `STO , `R0, 16'd5}; //x0
              127 : oInstruction = { `STO , `R1, 16'd1}; //y0
              128 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              129 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              130 : oInstruction = { `NOP , 24'd0 };
              131 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              132 : oInstruction = { `STO , `R0, 16'd0}; //x0
              133 : oInstruction = { `STO , `R1, 16'd2}; //y0
              134 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              135 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              136 : oInstruction = { `NOP , 24'd0 };
              137 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              138 : oInstruction = { `STO , `R0, 16'd2}; //x0
              139 : oInstruction = { `STO , `R1, 16'd2}; //y0
              140 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              141 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              142 : oInstruction = { `NOP , 24'd0 };
              143 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              144 : oInstruction = { `STO , `R0, 16'd3}; //x0
              145 : oInstruction = { `STO , `R1, 16'd2}; //y0
              146 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              147 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              148 : oInstruction = { `NOP , 24'd0 };
              149 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              150 : oInstruction = { `STO , `R0, 16'd5}; //x0
              151 : oInstruction = { `STO , `R1, 16'd2}; //y0
              152 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              153 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              154 : oInstruction = { `NOP , 24'd0 };
              155 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              156 : oInstruction = { `STO , `R0, 16'd0}; //x0
              157 : oInstruction = { `STO , `R1, 16'd3}; //y0
              158 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              159 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              160 : oInstruction = { `NOP , 24'd0 };
              161 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              162 : oInstruction = { `STO , `R0, 16'd1}; //x0
              163 : oInstruction = { `STO , `R1, 16'd3}; //y0
              164 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              165 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              166 : oInstruction = { `NOP , 24'd0 };
              167 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              168 : oInstruction = { `STO , `R0, 16'd2}; //x0
              169 : oInstruction = { `STO , `R1, 16'd3}; //y0
              170 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              171 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              172 : oInstruction = { `NOP , 24'd0 };
              173 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              174 : oInstruction = { `STO , `R0, 16'd3}; //x0
              175 : oInstruction = { `STO , `R1, 16'd3}; //y0
              176 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              177 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              178 : oInstruction = { `NOP , 24'd0 };
              179 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              180 : oInstruction = { `STO , `R0, 16'd4}; //x0
              181 : oInstruction = { `STO , `R1, 16'd3}; //y0
              182 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              183 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              184 : oInstruction = { `NOP , 24'd0 };
              185 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              186 : oInstruction = { `STO , `R0, 16'd5}; //x0
              187 : oInstruction = { `STO , `R1, 16'd3}; //y0
              188 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              189 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              190 : oInstruction = { `NOP , 24'd0 };
              191 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              192 : oInstruction = { `STO , `R0, 16'd0}; //x0
              193 : oInstruction = { `STO , `R1, 16'd4}; //y0
              194 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              195 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              196 : oInstruction = { `NOP , 24'd0 };
              197 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              198 : oInstruction = { `STO , `R0, 16'd2}; //x0
              199 : oInstruction = { `STO , `R1, 16'd4}; //y0
              200 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              201 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              202 : oInstruction = { `NOP , 24'd0 };
              203 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              204 : oInstruction = { `STO , `R0, 16'd3}; //x0
              205 : oInstruction = { `STO , `R1, 16'd4}; //y0
              206 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              207 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              208 : oInstruction = { `NOP , 24'd0 };
              209 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              210 : oInstruction = { `STO , `R0, 16'd5}; //x0
              211 : oInstruction = { `STO , `R1, 16'd4}; //y0
              212 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              213 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              214 : oInstruction = { `NOP , 24'd0 };
              215 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              216 : oInstruction = { `STO , `R0, 16'd1}; //x0
              217 : oInstruction = { `STO , `R1, 16'd5}; //y0
              218 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              219 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              220 : oInstruction = { `NOP , 24'd0 };
              221 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              222 : oInstruction = { `STO , `R0, 16'd4}; //x0
              223 : oInstruction = { `STO , `R1, 16'd5}; //y0
              224 : oInstruction = { `ADD , `R0, `R4, `R0}; //x0=xi+x0
              225 : oInstruction = { `ADD , `R1, `R5, `R1}; //y0=yi+y0
              226 : oInstruction = { `NOP , 24'd0 };
              227 : oInstruction = { `STC , 8'd0, `R0, `R1}; //Pixel {x0,y0} a RAM

              228 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa


      /*--------------------------------------------------------------*/
      /****************************************************************/
      default:
        oInstruction = { `NOP , 24'd0	};		//NOP
    endcase
  end

endmodule
