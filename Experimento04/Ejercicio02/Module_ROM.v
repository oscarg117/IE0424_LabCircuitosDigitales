`timescale 1ns / 1ps
`include "Defintions.v"

`define START         8'd0
`define Yii           8'd13
`define UPD_yf        8'd15
`define UPD_xf        8'd18
`define THE_END       8'd33
`define DRAW_BLACK    8'd35
`define X0_BLACK      8'd36
`define BLACK2RAM     8'd37
`define DRAW_WHITE    8'd46
`define X0_WHITE      8'd47
`define WHITE2RAM     8'd48

`define WAIT          8'd57
`define WAIT_L        8'd58
`define WAIT_S        8'd60

`define DRAW_BLUE    8'd92
`define X0_BLUE      8'd93
`define BLUE2RAM     8'd94


`define VRAM_W        16'd80 - 1
`define VRAM_H        16'd60 - 1

`define SQR_W        16'd7
`define DXI          16'd6//`SQR_W-1
`define DXF          16'd14//2*`SQR_W
`define XI_MAX       16'd42//6*`SQR_W

`define OFFS_0       16'd7
`define OFFS_1       16'd14//`OFFS_0+`SQR_W

`define DELAY        16'd2500



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

      //Llena la VRAM con color blanco
      1  : oInstruction = { `STO , `R4, 16'd0}; //R4=xi
      2  : oInstruction = { `STO , `R5, 16'd0}; //R5=yi
      3  : oInstruction = { `STO , `R2, 16'd79}; //R2=xf
      4  : oInstruction = { `STO , `R3, 16'd59}; //R3=yf
      5  : oInstruction = { `JMP , 8'd85, 16'd0}; //R3=yf
      //5  : oInstruction = { `CALL , `DRAW_WHITE, 16'd0 }; //Dibuja un cuadro

      //Carga los valores para dibujar los cuadros pequeños
      6  : oInstruction = { `STO , `R9, 16'd12}; //R9=offsetH
      7  : oInstruction = { `STO , `R10, 16'd20}; //R10=Fin offsetH
      8  : oInstruction = { `STO , `R11, 16'd2}; //R11=offsetV
      9  : oInstruction = { `STO , `R6, 16'd7}; //R6=dxi
      10  : oInstruction = { `STO , `R7, 16'd16}; //R7=dxf
      11  : oInstruction = { `STO , `R8, 16'd60}; //R8=xi max
      12  : oInstruction = { `STO , `R12, 16'd50}; //R12=yi max

      //Label: Yii
      13  : oInstruction = { `MOV , `R5, `R11, 8'd0}; //R5=yi (offset)
      14 : oInstruction = { `NOP , 24'd0 };
      //Label: UPD_yf
      15  : oInstruction = { `ADD , `R3, `R5, `R6}; //R3=yf=yi+6
      16  : oInstruction = { `MOV , `R4, `R9, 8'd0}; //R4=xi (offset)
      17 : oInstruction = { `NOP , 24'd0 };
      //Label: UPD_xf
      18 : oInstruction = { `ADD , `R2, `R4, `R6}; //R2=xf=xi+6
      19 : oInstruction = { `CALL , `WAIT, 16'd0 }; //Espera
      20 : oInstruction = { `CALL , `DRAW_BLACK, 16'd0 }; //Dibuja un cuadro
      21 : oInstruction = { `ADD , `R4, `R4, `R7}; //R4=xi=xi+14
      22 : oInstruction = { `NOP , 24'd0 };
      23 : oInstruction = { `BLE , `UPD_xf, `R4, `R8}; //Salta si xi<=xi max
      24 : oInstruction = { `ADD , `R5, `R5, `R7}; //R5=yi=yi+14
      25 : oInstruction = { `NOP , 24'd0 };
      26 : oInstruction = { `BLE , `UPD_yf, `R5, `R12}; //Salta si yi<=yi max

      27 : oInstruction = { `BLE , `THE_END, `R10, `R9}; //
      28 : oInstruction = { `ADD , `R11, `R11, `R6 };
      29 : oInstruction = { `ADD , `R9, `R9, `R6}; //
      30 : oInstruction = { `INC , `R11, `R11, 8'd0}; //
      31 : oInstruction = { `INC , `R9, `R9, 8'd0}; //
      32 : oInstruction = { `JMP , `Yii, 16'b0 };


      /***********************************************************************/
      //Label: THE_END
      //33 : oInstruction = { `NOP , 24'd0 };
      //34 : oInstruction = { `JMP , `THE_END, 16'b0 };
      //33  : oInstruction = { `CALL , `WAIT, 16'd0 }; //Espera
      //34 : oInstruction = { `JMP , `START, 16'b0 };
      33 : oInstruction = { `JMP , 8'd67, 16'b0 };
      /***********************************************************************/

      //Label: DRAW_BLACK
      35 : oInstruction = { `MOV , `R1, `R5, 8'd0}; //y0=yi
      //Label: X0_BLACK
      36 : oInstruction = { `MOV , `R0, `R4, 8'd0}; //x0=xi
      //Label: BLACK2RAM
      37 : oInstruction = { `NOP , 24'd0 };
      38 : oInstruction = { `VGA , `COLOR_BLACK, `R0, `R1}; //Pixel {x0,y0} a RAM
      39 : oInstruction = { `INC , `R0, `R0, 8'd0}; //x0++
      40 : oInstruction = { `NOP , 24'd0 };
      41 : oInstruction = { `BLE , `BLACK2RAM, `R0, `R2}; //Salta si x0<=xf
      42 : oInstruction = { `INC , `R1, `R1, 8'd0}; //y0++
      43 : oInstruction = { `NOP , 24'd0 };
      44 : oInstruction = { `BLE , `X0_BLACK, `R1, `R3}; //Salta si y0<=yf
      45 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa

      //Label: DRAW_WHITE
      46 : oInstruction = { `MOV , `R1, `R5, 8'd0}; //y0=yi
      //Label: X0_WHITE
      47 : oInstruction = { `MOV , `R0, `R4, 8'd0}; //x0=xi
      //Label: WHITE2RAM
      48 : oInstruction = { `NOP , 24'd0 };
      49 : oInstruction = { `VGA , `COLOR_BLACK, `R0, `R1}; //Pixel {x0,y0} a RAM
      50 : oInstruction = { `INC , `R0, `R0, 8'd0}; //x0++
      51 : oInstruction = { `NOP , 24'd0 };
      52 : oInstruction = { `BLE , `WHITE2RAM, `R0, `R2}; //Salta si x0<=xf
      53 : oInstruction = { `INC , `R1, `R1, 8'd0}; //y0++
      54 : oInstruction = { `NOP , 24'd0 };
      55 : oInstruction = { `BLE , `X0_WHITE, `R1, `R3}; //Salta si y0<=yf
      56 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa


      //Label: WAIT  - Espera durante R15^2 ciclos
      57  : oInstruction = { `STO , `R13, 16'd0}; //R5=yi
      //Label: WAIT_L
      58  : oInstruction = { `STO , `R14, 16'd0}; //R4=xi
      59  : oInstruction = { `STO , `R15, 16'd2500}; //R5=yi
      //Label: WAIT_S
      60 : oInstruction = { `INC , `R14, `R14, 8'd0}; //x0++
      61 : oInstruction = { `NOP , 24'd0 };
      62 : oInstruction = { `BLE , `WAIT_S, `R14, `R15}; //Salta si y0<=yf
      63 : oInstruction = { `INC , `R13, `R13, 8'd0}; //x0++
      64 : oInstruction = { `NOP , 24'd0 };
      65 : oInstruction = { `BLE , `WAIT_L, `R13, `R15}; //Salta si y0<=yf
      66 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa

      67 : oInstruction = { `NOP , 24'd0 };
      68  : oInstruction = { `CALL , `WAIT, 16'd0 }; //Espera
      69 : oInstruction = { `NOP , 24'd0 };
      70  : oInstruction = { `CALL , `WAIT, 16'd0 }; //Espera
      71 : oInstruction = { `NOP , 24'd0 };
      72  : oInstruction = { `CALL , `WAIT, 16'd0 }; //Espera
      73 : oInstruction = { `NOP , 24'd0 };
      74  : oInstruction = { `CALL , `WAIT, 16'd0 }; //Espera
      75 : oInstruction = { `NOP , 24'd0 };
      76  : oInstruction = { `CALL , `WAIT, 16'd0 }; //Espera
      77 : oInstruction = { `NOP , 24'd0 };
      78  : oInstruction = { `CALL , `WAIT, 16'd0 }; //Espera
      79 : oInstruction = { `NOP , 24'd0 };
      80  : oInstruction = { `CALL , `WAIT, 16'd0 }; //Espera
      81 : oInstruction = { `NOP , 24'd0 };
      82  : oInstruction = { `CALL , `WAIT, 16'd0 }; //Espera
      83 : oInstruction = { `NOP , 24'd0 };
      84 : oInstruction = { `JMP , `START, 16'd0 };


      85  : oInstruction = { `CALL , `DRAW_WHITE, 16'd0 }; //Dibuja un cuadro

      86 : oInstruction = { `STO , `R4, 16'd11}; //R4=xi
      87 : oInstruction = { `STO , `R5, 16'd1}; //R5=yi
      88 : oInstruction = { `STO , `R2, 16'd68}; //R2=xf
      89 : oInstruction = { `STO , `R3, 16'd58}; //R3=yf
      90 : oInstruction = { `CALL , `DRAW_BLUE, 16'd0}; //R3=yf
      91 : oInstruction = { `JMP , 8'd6, 16'd0}; //R3=yf

      //Label: DRAW_BLUE
      92 : oInstruction = { `MOV , `R1, `R5, 8'd0}; //y0=yi
      //Label: X0_BLUE
      93 : oInstruction = { `MOV , `R0, `R4, 8'd0}; //x0=xi
      //Label: BLUE2RAM
      94 : oInstruction = { `NOP , 24'd0 };
      95 : oInstruction = { `VGA , `COLOR_WHITE, `R0, `R1}; //Pixel {x0,y0} a RAM
      96 : oInstruction = { `INC , `R0, `R0, 8'd0}; //x0++
      97 : oInstruction = { `NOP , 24'd0 };
      98 : oInstruction = { `BLE , `BLUE2RAM, `R0, `R2}; //Salta si x0<=xf
      99 : oInstruction = { `INC , `R1, `R1, 8'd0}; //y0++
      100 : oInstruction = { `NOP , 24'd0 };
      101 : oInstruction = { `BLE , `X0_BLUE, `R1, `R3}; //Salta si y0<=yf
      102 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa

      /*--------------------------------------------------------------*/
      /****************************************************************/



      default:
        oInstruction = { `NOP , 24'd0	};		//NOP
    endcase
  end

endmodule
