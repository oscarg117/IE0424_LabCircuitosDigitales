`timescale 1ns / 1ps
`include "Defintions.v"

`define THE_END       8'd21
`define DRAW_GREEN    8'd23
`define DRAW_RED      8'd33
`define DRAW_MAGENTA  8'd43
`define DRAW_BLUE     8'd53
`define DRAW_WHITE    8'd63

`define GREEN2RAM     8'd25
`define RED2RAM       8'd35
`define MAGENTA2RAM   8'd45
`define BLUE2RAM      8'd55
`define WHITE2RAM     8'd65


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

      0  : oInstruction = { `NOP , 24'd4000 };

      // 1  : oInstruction = { `STO , `R7, 16'd7}; //R7=7
      // 1  : oInstruction = { `STO , `R1, 16'd0}; //R1=7

      1  : oInstruction = { `STO , `R4, 16'd0}; //R4=xi
      2  : oInstruction = { `STO , `R5, 16'd0}; //R5=yi
      3  : oInstruction = { `STO , `R2, 16'd79}; //R2=xf
      4  : oInstruction = { `STO , `R3, 16'd59}; //R3=yf
      5  : oInstruction = { `CALL , `DRAW_WHITE, 16'd0 }; //Dibuja un cuadro


      6  : oInstruction = { `STO , `R4, 16'd0}; //R4=xi
      7  : oInstruction = { `STO , `R5, 16'd0}; //R5=yi
      8  : oInstruction = { `STO , `R2, 16'd6}; //R2=xf
      9  : oInstruction = { `STO , `R3, 16'd6}; //R3=yf
      10 : oInstruction = { `CALL , `DRAW_RED, 16'd0 }; //Dibuja un cuadro

      11 : oInstruction = { `ADD , `R4, 16'd7}; //R4=xi
      12 : oInstruction = { `STO , `R5, 16'd7}; //R5=yi
      13 : oInstruction = { `STO , `R2, 16'd13}; //R2=xf
      14 : oInstruction = { `STO , `R3, 16'd13}; //R3=yf
      15 : oInstruction = { `CALL , `DRAW_MAGENTA, 16'd0 }; //Dibuja un cuadro

      16 : oInstruction = { `STO , `R4, 16'd14}; //R4=xi
      17 : oInstruction = { `STO , `R5, 16'd0}; //R5=yi
      18 : oInstruction = { `STO , `R2, 16'd20}; //R2=xf
      19 : oInstruction = { `STO , `R3, 16'd6}; //R3=yf
      20 : oInstruction = { `CALL , `DRAW_BLUE, 16'd0 }; //Dibuja un cuadro

      /***********************************************************************/
      //THE_END
      21 : oInstruction = { `NOP , 24'd4000 };
      22 : oInstruction = { `JMP , `THE_END, 16'b0 };
      /***********************************************************************/

      //DRAW_GREEN
      23 : oInstruction = { `MOV , `R0, `R4, 8'd0}; //x0=xi
      24 : oInstruction = { `NOP , 24'd4000 }; //Espera
      //GREEN2RAM
      25 : oInstruction = { `VGA , `COLOR_GREEN, `R0, `R5}; //Pixel {x0,yi} a RAM
      26 : oInstruction = { `INC , `R0, `R0, 8'd0}; //x0++
      27 : oInstruction = { `NOP , 24'd4000 }; //Espera
      28 : oInstruction = { `BLE , `GREEN2RAM, `R0, `R2}; //Salta si x0<=xf
      29 : oInstruction = { `INC , `R5, `R5, 8'd0}; //yi++
      30 : oInstruction = { `NOP , 24'd4000 }; //Espera
      31 : oInstruction = { `BLE , `DRAW_GREEN, `R5, `R3}; //Salta si yi<=yf
      32 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa

      //DRAW_RED
      33 : oInstruction = { `MOV , `R0, `R4, 8'd0}; //x0=xi
      34 : oInstruction = { `NOP , 24'd4000 }; //Espera
      //RED2RAM
      35 : oInstruction = { `VGA , `COLOR_RED, `R0, `R5}; //Pixel {x0,yi} a RAM
      36 : oInstruction = { `INC , `R0, `R0, 8'd0}; //x0++
      37 : oInstruction = { `NOP , 24'd4000 }; //Espera
      38 : oInstruction = { `BLE , `RED2RAM, `R0, `R2}; //Salta si x0<=xf
      39 : oInstruction = { `INC , `R5, `R5, 8'd0}; //yi++
      40 : oInstruction = { `NOP , 24'd4000 }; //Espera
      41 : oInstruction = { `BLE , `DRAW_RED, `R5, `R3}; //Salta si yi<=yf
      42 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa

      //DRAW_MAGENTA
      43 : oInstruction = { `MOV , `R0, `R4, 8'd0}; //x0=xi
      44 : oInstruction = { `NOP , 24'd4000 }; //Espera
      //MAGENTA2RAM
      45 : oInstruction = { `VGA , `COLOR_MAGENTA, `R0, `R5}; //Pixel {x0,yi} a RAM
      46 : oInstruction = { `INC , `R0, `R0, 8'd0}; //x0++
      47 : oInstruction = { `NOP , 24'd4000 }; //Espera
      48 : oInstruction = { `BLE , `MAGENTA2RAM, `R0, `R2}; //Salta si x0<=xf
      49 : oInstruction = { `INC , `R5, `R5, 8'd0}; //yi++
      50 : oInstruction = { `NOP , 24'd4000 }; //Espera
      51 : oInstruction = { `BLE , `DRAW_MAGENTA, `R5, `R3}; //Salta si yi<=yf
      52 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa

      //DRAW_BLUE
      53 : oInstruction = { `MOV , `R0, `R4, 8'd0}; //x0=xi
      54 : oInstruction = { `NOP , 24'd4000 }; //Espera
      //BLUE2RAM
      55 : oInstruction = { `VGA , `COLOR_BLUE, `R0, `R5}; //Pixel {x0,yi} a RAM
      56 : oInstruction = { `INC , `R0, `R0, 8'd0}; //x0++
      57 : oInstruction = { `NOP , 24'd4000 }; //Espera
      58 : oInstruction = { `BLE , `BLUE2RAM, `R0, `R2}; //Salta si x0<=xf
      59 : oInstruction = { `INC , `R5, `R5, 8'd0}; //yi++
      60 : oInstruction = { `NOP , 24'd4000 }; //Espera
      61 : oInstruction = { `BLE , `DRAW_BLUE, `R5, `R3}; //Salta si yi<=yf
      62 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa

      //DRAW_WHITE
      63 : oInstruction = { `MOV , `R0, `R4, 8'd0}; //x0=xi
      64 : oInstruction = { `NOP , 24'd4000 }; //Espera
      //WHITE2RAM
      65 : oInstruction = { `VGA , `COLOR_WHITE, `R0, `R5}; //Pixel {x0,yi} a RAM
      66 : oInstruction = { `INC , `R0, `R0, 8'd0}; //x0++
      67 : oInstruction = { `NOP , 24'd4000 }; //Espera
      68 : oInstruction = { `BLE , `WHITE2RAM, `R0, `R2}; //Salta si x0<=xf
      69 : oInstruction = { `INC , `R5, `R5, 8'd0}; //yi++
      70 : oInstruction = { `NOP , 24'd4000 }; //Espera
      71 : oInstruction = { `BLE , `DRAW_WHITE, `R5, `R3}; //Salta si yi<=yf
      72 : oInstruction = { `RET , 24'd0 }; //Vuelve al programa
      //72 : oInstruction = { `JMP , `THE_END, 16'b0 };


      /*--------------------------------------------------------------*/
      /****************************************************************/



      default:
        oInstruction = { `NOP , 24'd0	};		//NOP
    endcase
  end

endmodule
