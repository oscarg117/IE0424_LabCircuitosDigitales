`timescale 1ns / 1ps
`include "Defintions.v"

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

//------------------------------------------------
module UPCOUNTER_POSEDGE # (parameter SIZE = 16)
       (
         input wire Clock, Reset,
         input wire [SIZE - 1: 0] Initial,
         input wire Enable,
         output reg [SIZE - 1: 0] Q
       );


always @(posedge Clock )
  begin
    if (Reset)
      Q = Initial;
    else
      begin
        if (Enable)
          Q = Q + 1;

      end
  end

endmodule
  //----------------------------------------------------
  module FFD_POSEDGE_SYNCRONOUS_RESET # ( parameter SIZE = 8 )
  (
    input wire	Clock,
    input wire	Reset,
    input wire	Enable,
    input wire [SIZE - 1: 0]	D,
    output reg [SIZE - 1: 0]	Q
  );


always @ (posedge Clock)
  begin
    if ( Reset )
      Q <= 0;
    else
      begin
        if (Enable)
          Q <= D;
      end

  end //always

endmodule


//----------------------------------------------------------------------


module VGA_controller
  (
    input wire	Clock_lento,
    input wire Reset,
    input wire	[2 :0]	iVGA_RGB,
    input wire [2 :0]	iColorCuadro,
    input wire [9 :0]	iXRedCounter,
    input wire [9 :0]	iYRedCounter,
    output wire	[2:0]	oVGA_RGB,
    output wire	oHsync,
    output wire	oVsync,
    output wire [9:0]	oVcounter,
    output wire [9:0]	oHcounter
  );
wire iVGA_R, iVGA_G, iVGA_B;
wire oVGA_R, oVGA_G, oVGA_B;
wire wEndline;
wire [3: 0] wMarco; //, wCuadro;
wire [3: 0] wCuadro;
wire [2: 0] wVGAOutputSelection;
reg [9: 0] puntero1, puntero2;
reg [23: 0] contador1, contador2;

assign wMarco  = `RED;//3'b000;

assign wCuadro = (  ( oVcounter >= `VS_lines_Tbp+`V_OFFSET &&
                      oVcounter <= `VS_lines_Tbp+`V_OFFSET+70 ) ||
                    (oVcounter > `VS_lines_Tbp+`V_OFFSET+140 &&
                      oVcounter <= `VS_lines_Tbp+`V_OFFSET+210 )  )
                        ? `GREEN : `BLUE;

initial
  begin
    puntero1 <= 10'b0;
    puntero2 <= 10'd96;
    contador1 <= 24'b0;
    contador2 <= 24'b0;
  end

always @ (posedge Clock_lento )
  begin
    if (contador1 >= 23'd45000000)//3056960/25M ~0,1222784s
      begin
        puntero1 <= puntero1 + 10'd32;
        puntero2 <= puntero2;
        contador1 <= 24'b0;
        contador2 <= contador2;
      end
    else if (contador2 >= 23'd40000000)//6445568/25M ~0,25782272s
      begin
        puntero2 <= puntero2 + 10'd32;
        puntero1 <= puntero1;
        contador1 <= contador1;
        contador2 <= 24'b0;
      end
    else
      begin
        puntero1 <= puntero1;
        puntero2 <= puntero2;
        contador1 <= contador1 + 24'b1;
        contador2 <= contador2 + 24'b1;
      end
  end


assign wVGAOutputSelection = (
         (((oHcounter >= iXRedCounter + 10'd272) && (oHcounter <= iXRedCounter + 10'd272 + 10'd31)) &&
          ((oVcounter >= iYRedCounter + 10'd333) && (oVcounter <= iYRedCounter + 10'd333 + 10'd31)))

          ||

         (((oHcounter >= iXRedCounter + 10'd272) && (oHcounter <= iXRedCounter + 10'd272 + 10'd31)) &&
          ((oVcounter >= iYRedCounter + 10'd397) && (oVcounter <= iYRedCounter + 10'd397 + 10'd31)))

          ||

         (((oHcounter >= iXRedCounter + 10'd240) && (oHcounter <= iXRedCounter + 10'd240 + 10'd31)) &&
          ((oVcounter >= iYRedCounter + 10'd429) && (oVcounter <= iYRedCounter + 10'd429 + 10'd31)))

          ||

         (((oHcounter >= iXRedCounter + 10'd240) && (oHcounter <= iXRedCounter + 10'd240 + 10'd31)) &&
          ((oVcounter >= iYRedCounter + 10'd365) && (oVcounter <= iYRedCounter + 10'd365 + 10'd31)))

          ||

         (((oHcounter >= iXRedCounter + 10'd304) && (oHcounter <= iXRedCounter + 10'd304 + 10'd31)) &&
          ((oVcounter >= iYRedCounter + 10'd365) && (oVcounter <= iYRedCounter + 10'd365 + 10'd31)))

          ||

         (((oHcounter >= iXRedCounter + 10'd304) && (oHcounter <= iXRedCounter + 10'd304 + 10'd31)) &&
          ((oVcounter >= iYRedCounter + 10'd429) && (oVcounter <= iYRedCounter + 10'd429 + 10'd31)))

          ||

         (((oHcounter >= 10'd272) && (oHcounter <= 10'd272 + 10'd31)) &&
          ((oVcounter >= 10'd77 + puntero1) && (oVcounter <= 10'd77 + puntero1 + 10'd31)))

          ||

         (((oHcounter >= 10'd368) && (oHcounter <= 10'd368 + 10'd31)) &&
          ((oVcounter >= 10'd77 + puntero2) && (oVcounter <= 10'd77 + puntero2 + 10'd31)))

       ) ? iColorCuadro : {iVGA_R, iVGA_G, iVGA_B}; //Cuadro central


assign iVGA_R = iVGA_RGB[2];
assign iVGA_G = iVGA_RGB[1];
assign iVGA_B = iVGA_RGB[0];
assign oVGA_RGB = {oVGA_R, oVGA_G, oVGA_B};

assign oHsync = (oHcounter < `HS_Ts - `HS_Tpw) ? 1'b1 : 1'b0;
assign wEndline = (oHcounter == `HS_Ts - 1);
assign oVsync = (oVcounter < `VS_lines_Ts - `VS_lines_Tpw) ? 1'b1 : 1'b0;


// Marco negro de 440*280
assign {oVGA_R, oVGA_G, oVGA_B} = ( oVcounter < `VS_lines_Tbp+`V_OFFSET  ||
                                    oVcounter >= `VS_lines_Ts-`VS_lines_Tpw-`VS_lines_Tfp-`V_OFFSET ||
                                    oHcounter < `HS_Tbp+`H_OFFSET ||
                                    oHcounter > `HS_Ts-`HS_Tpw-`HS_Tfp-`H_OFFSET  )
                                    ? `RED : {iVGA_R, iVGA_G, iVGA_B};//iVGA_RGB;
                                    //? `BLUE : wCuadro;

//assign {oVGA_R, oVGA_G, oVGA_B} = iVGA_RGB;


UPCOUNTER_POSEDGE # (10) HORIZONTAL_COUNTER
                  (
                    .Clock	( Clock_lento ),
                    .Reset	( (oHcounter > `HS_Ts-1) || Reset ),
                    .Initial	( 10'b0 ),
                    .Enable	( 1'b1	),
                    .Q	(	oHcounter )
                  );

UPCOUNTER_POSEDGE # (10) VERTICAL_COUNTER
                  (
                    .Clock	( Clock_lento ),
                    .Reset	( (oVcounter > `VS_lines_Ts-1) || Reset ),
                    .Initial	( 10'b0 ),
                    .Enable	( wEndline ),
                    .Q	( oVcounter )
                  );

endmodule
  //----------------------------------------------------------------------
