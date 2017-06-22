`timescale 1ns / 1ps
`include "Defintions.v"

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
    input wire	[2:0]	iVGA_RGB,
    output wire	[2:0]	oVGA_RGB,
    output wire	oHsync,
    output wire	oVsync,
    output wire [9:0]	oVcounter,
    output wire [9:0]	oHcounter
  );
wire iVGA_R, iVGA_G, iVGA_B;
wire oVGA_R, oVGA_G, oVGA_B;
wire wEndline;
wire [2:0] wMarco; //, wCuadro;



assign iVGA_R = iVGA_RGB[2];
assign iVGA_G = iVGA_RGB[1];
assign iVGA_B = iVGA_RGB[0];
assign oVGA_RGB = {oVGA_R, oVGA_G, oVGA_B};

assign oHsync = (oHcounter < `HS_Ts - `HS_Tpw) ? 1'b1 : 1'b0;
assign wEndline = (oHcounter == `HS_Ts - 1);
assign oVsync = (oVcounter < `VS_lines_Ts - 1) ? 1'b1 : 1'b0;

assign wMarco  = `BLACK;//3'b000;

wire [2:0] wCuadroT, wCuadroB, wCuadro;

assign wCuadroT = (  ( oVcounter >= `VS_lines_Tbp+`V_OFFSET &&
                      oVcounter < `VS_lines_Tbp+`V_OFFSET+70 ) ||
                    (oVcounter > `VS_lines_Tbp+`V_OFFSET+140 &&
                      oVcounter < `VS_lines_Tbp+`V_OFFSET+210 )  )
                          ? `GREEN : `RED;

assign wCuadroB = (  ( oVcounter >= `VS_lines_Tbp+`V_OFFSET &&
                      oVcounter < `VS_lines_Tbp+`V_OFFSET+70 ) ||
                    (oVcounter > `VS_lines_Tbp+`V_OFFSET+140 &&
                      oVcounter < `VS_lines_Tbp+`V_OFFSET+210 )  )
                          ? `MAGENTA : `BLUE;

assign wCuadro = ( oVcounter > `VS_lines_Tbp+`V_OFFSET+140 )
                          ? wCuadroB : wCuadroT;


// Marco negro de 440*280
assign {oVGA_R, oVGA_G, oVGA_B} = ( oVcounter < `VS_lines_Tbp+`V_OFFSET  ||
                                    oVcounter >= `VS_lines_Ts-`VS_lines_Tpw-`VS_lines_Tfp-`V_OFFSET ||
                                    oHcounter < `HS_Tbp+`H_OFFSET ||
                                    oHcounter > `HS_Ts-`HS_Tpw-`HS_Tfp-`H_OFFSET  )
                                    ? `BLACK : {iVGA_R, iVGA_G, iVGA_B};//iVGA_RGB;
                                    //? `BLACK : wCuadro;

//assign {oVGA_R, oVGA_G, oVGA_B} = iVGA_RGB;
//assign {oVGA_R, oVGA_G, oVGA_B} = wCuadro;


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
