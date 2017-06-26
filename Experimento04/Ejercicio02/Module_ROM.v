`timescale 1ns / 1ps
`include "Defintions.v"

/*Etiquetas de iAddress*/
`define START         8'd0

`define YII           8'd18

`define UPD_YF        8'd20
`define UPD_XF        8'd23

`define LAST_SQR      8'd37
`define THE_END       8'd43

`define DRAW_BLACK    8'd46
`define X0_BLACK      8'd47
`define BLACK2RAM     8'd48

`define DRAW_WHITE    8'd57
`define X0_WHITE      8'd58
`define WHITE2RAM     8'd59

`define DRAW_RED      8'd68
`define X0_RED        8'd69
`define RED2RAM       8'd70

/*Algunas dimensiones*/
`define VRAM_W       16'd79
`define VRAM_H       16'd59

`define SQR_W        16'd8
`define DXI          16'd7
`define DXF          16'd16
`define XI_MAX       16'd60
`define YI_MAX       16'd50

`define RSQR_X       16'd36
`define RSQR_Y       16'd34

`define OFFS_1H      16'd12
`define OFFS_0H      16'd20
`define OFFS_VV      16'd2




module ROM
       (
         input wire [15:0] iAddress,
         output reg [27:0] oInstruction
       );

always @ ( iAddress )
  begin
    case (iAddress)
      /****************************************************************/
      /*--------------------------------------------------------------*/

      0  : oInstruction = { `NOP , 24'd0 };

      //Llena la VRAM con color negro
      1  : oInstruction = { `STO , `R4, 16'd0}; //R4=xi
      2  : oInstruction = { `STO , `R5, 16'd0}; //R5=yi
      3  : oInstruction = { `STO , `R2, `VRAM_W}; //R2=xf
      4  : oInstruction = { `STO , `R3, `VRAM_H}; //R3=yf
      5  : oInstruction = { `CALL , `DRAW_BLACK, 16'd0 }; //Dibuja un cuadro

      //Carga los valores para dibujar un recuadro centrado
      6  : oInstruction = { `STO , `R4, 16'd11}; //R4=xi
      7  : oInstruction = { `STO , `R5, 16'd1}; //R5=yi
      8  : oInstruction = { `STO , `R2, 16'd68}; //R2=xf
      9  : oInstruction = { `STO , `R3, 16'd58}; //R3=yf
      //Dibuja un recuadro blanco en el centro de la pantalla
      10 : oInstruction = { `CALL , `DRAW_WHITE, 16'd0};

      //Carga los valores para dibujar los cuadros pequeños
      11 : oInstruction = { `STO , `R9, `OFFS_1H}; //R9=offsetH
      12 : oInstruction = { `STO , `R10, `OFFS_0H}; //R10=Fin offsetH
      13 : oInstruction = { `STO , `R11, `OFFS_VV}; //R11=offsetV
      14 : oInstruction = { `STO , `R6, `DXI}; //R6=dxi
      15 : oInstruction = { `STO , `R7, `DXF}; //R7=dxf
      16 : oInstruction = { `STO , `R8, `XI_MAX}; //R8=xi max
      17 : oInstruction = { `STO , `R12, `YI_MAX}; //R12=yi max

      //Label: YII
      18 : oInstruction = { `MOV , `R5, `R11, 8'd0}; //R5=yi (offset)
      19 : oInstruction = { `NOP , 24'd0 };
      //Label: UPD_YF
      20 : oInstruction = { `ADD , `R3, `R5, `R6}; //R3=yf=yi+dxi
      21 : oInstruction = { `MOV , `R4, `R9, 8'd0}; //R4=xi (offset)
      22 : oInstruction = { `NOP , 24'd0 };
      //Label: UPD_XF
      23 : oInstruction = { `ADD , `R2, `R4, `R6}; //R2=xf=xi+dxi
      24 : oInstruction = { `CALL , `DRAW_BLACK, 16'd0 }; //Dibuja un cuadro
      25 : oInstruction = { `ADD , `R4, `R4, `R7}; //R4=xi=xi+dxf
      26 : oInstruction = { `NOP , 24'd0 };
      27 : oInstruction = { `BLE , `UPD_XF, `R4, `R8}; //Salta si xi<=xi max
      28 : oInstruction = { `ADD , `R5, `R5, `R7}; //R5=yi=yi+dxf
      29 : oInstruction = { `NOP , 24'd0 };
      30 : oInstruction = { `BLE , `UPD_YF, `R5, `R12}; //Salta si yi<=yi max

      31 : oInstruction = { `BLE , `LAST_SQR, `R10, `R9}; //
      32 : oInstruction = { `ADD , `R11, `R11, `R6 }; //
      33 : oInstruction = { `ADD , `R9, `R9, `R6}; //
      34 : oInstruction = { `INC , `R11, `R11, 8'd0}; //
      35 : oInstruction = { `INC , `R9, `R9, 8'd0}; //
      36 : oInstruction = { `JMP , `YII, 16'b0 };


      //Carga los valores para dibujar un cuadro rojo
      //Label: LAST_SQR
      37 : oInstruction = { `STO , `R4, `RSQR_X}; //R4=xi
      38 : oInstruction = { `STO , `R5, `RSQR_Y}; //R5=yi
      39 : oInstruction = { `NOP , 24'd0 };
      40 : oInstruction = { `ADD , `R2, `R4, `R6}; //R2=xf=xi+dxi
      41 : oInstruction = { `ADD , `R3, `R5, `R6}; //R3=yf=yi+dxi
      42 : oInstruction = { `CALL , `DRAW_RED, 16'd0}; //

      /***********************************************************************/
      //Label: THE_END
      43 : oInstruction = { `NOP , 24'd0 };
      44 : oInstruction = { `JMP , `THE_END, 16'b0 };
      /***********************************************************************/

      /* Subrutina que carga en VRAM un cuadro de color negro*/
      //Label: DRAW_BLACK
      46 : oInstruction = { `MOV , `R1, `R5, 8'd0}; //y0=yi
      //Label: X0_BLACK
      47 : oInstruction = { `MOV , `R0, `R4, 8'd0}; //x0=xi
      //Label: BLACK2RAM
      48 : oInstruction = { `NOP , 24'd0 };
      49 : oInstruction = { `VGA , `COLOR_BLACK, `R0, `R1}; //Pixel {x0,y0} a RAM
      50 : oInstruction = { `INC , `R0, `R0, 8'd0}; //x0++
      51 : oInstruction = { `NOP , 24'd0 };
      52 : oInstruction = { `BLE , `BLACK2RAM, `R0, `R2}; //Salta si x0<=xf
      53 : oInstruction = { `INC , `R1, `R1, 8'd0}; //y0++
      54 : oInstruction = { `NOP , 24'd0 };
      55 : oInstruction = { `BLE , `X0_BLACK, `R1, `R3}; //Salta si y0<=yf
      56 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa

      /* Subrutina que carga en VRAM un cuadro de color blanco*/
      //Label: DRAW_WHITE
      57 : oInstruction = { `MOV , `R1, `R5, 8'd0}; //y0=yi
      //Label: X0_WHITE
      58 : oInstruction = { `MOV , `R0, `R4, 8'd0}; //x0=xi
      //Label: WHITE2RAM
      59 : oInstruction = { `NOP , 24'd0 };
      60 : oInstruction = { `VGA , `COLOR_WHITE, `R0, `R1}; //Pixel {x0,y0} a RAM
      61 : oInstruction = { `INC , `R0, `R0, 8'd0}; //x0++
      62 : oInstruction = { `NOP , 24'd0 };
      63 : oInstruction = { `BLE , `WHITE2RAM, `R0, `R2}; //Salta si x0<=xf
      64 : oInstruction = { `INC , `R1, `R1, 8'd0}; //y0++
      65 : oInstruction = { `NOP , 24'd0 };
      66 : oInstruction = { `BLE , `X0_WHITE, `R1, `R3}; //Salta si y0<=yf
      67 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa

      /* Subrutina que carga en VRAM un cuadro de color rojo*/
      //Label: DRAW_RED
      68 : oInstruction = { `MOV , `R1, `R5, 8'd0}; //y0=yi
      //Label: X0_RED
      69 : oInstruction = { `MOV , `R0, `R4, 8'd0}; //x0=xi
      //Label: RED2RAM
      70 : oInstruction = { `NOP , 24'd0 };
      71 : oInstruction = { `VGA , `COLOR_RED, `R0, `R1}; //Pixel {x0,y0} a RAM
      72 : oInstruction = { `INC , `R0, `R0, 8'd0}; //x0++
      73 : oInstruction = { `NOP , 24'd0 };
      74 : oInstruction = { `BLE , `RED2RAM, `R0, `R2}; //Salta si x0<=xf
      75 : oInstruction = { `INC , `R1, `R1, 8'd0}; //y0++
      76 : oInstruction = { `NOP , 24'd0 };
      77 : oInstruction = { `BLE , `X0_RED, `R1, `R3}; //Salta si y0<=yf
      78 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa
      /*--------------------------------------------------------------*/
      /****************************************************************/
      default:
        oInstruction = { `NOP , 24'd0	};		//NOP
    endcase
  end

endmodule
