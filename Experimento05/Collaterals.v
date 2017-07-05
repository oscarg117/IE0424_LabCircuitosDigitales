`timescale 1ns / 1ps
`include "Defintions.v"

//------------------------------------------------
module UPCOUNTER_POSEDGE # (parameter SIZE = 16)
       (
         input wire Clock, Reset,
         input wire [SIZE-1:0] Initial,
         input wire Enable,
         output reg [SIZE-1:0] Q
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
    input wire [SIZE-1:0]	D,
    output reg [SIZE-1:0]	Q
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
    input wire clk25MHz,
    input wire Reset,
    input wire [2:0]	iFromVRAM_RGB,
    input wire [9:0] iXisqr,
    output wire	[2:0]	oToVGA_RGB,
    output wire	oHSync,
    output wire	oVSync,
    output wire [9:0]	oVcnt,
    output wire [9:0]	oHcnt
  );
wire wFromVRAM_R, wFromVRAM_G, wFromVRAM_B;
wire wToVGA_R, wToVGA_G, wToVGA_B;
wire wEOL;

assign wFromVRAM_R = iFromVRAM_RGB[2];
assign wFromVRAM_G = iFromVRAM_RGB[1];
assign wFromVRAM_B = iFromVRAM_RGB[0];

//assign oToVGA_RGB = {wToVGA_R, wToVGA_G, wToVGA_B};
assign oToVGA_RGB = ( (oVcnt >= `VS_lines_Ts-`VS_lines_Tpw-`VS_lines_Tfp-`V_OFFSET-56) &&
                      (oHcnt > `H_OFFSET+iXisqr &&
                       oHcnt < `H_OFFSET+iXisqr+48) )
                    ? `BLUE : {wToVGA_R, wToVGA_G, wToVGA_B};

assign oHSync = (oHcnt < `HS_Ts - `HS_Tpw) ? 1'b1 : 1'b0;
assign wEOL = (oHcnt == `HS_Ts - 1);
assign oVSync = (oVcnt < `VS_lines_Ts - 1) ? 1'b1 : 1'b0;

assign {wToVGA_R, wToVGA_G, wToVGA_B} = ( oVcnt < `VS_lines_Tbp+`V_OFFSET  ||
                                    oVcnt >= `VS_lines_Ts-`VS_lines_Tpw-`VS_lines_Tfp-`V_OFFSET ||
                                    oHcnt < `HS_Tbp+`H_OFFSET ||
                                    oHcnt > `HS_Ts-`HS_Tpw-`HS_Tfp-`H_OFFSET  )
                                    ? `BLACK : {wFromVRAM_R, wFromVRAM_G, wFromVRAM_B};

UPCOUNTER_POSEDGE # (10) HORIZONTAL_COUNTER
                  (
                    .Clock	( clk25MHz ),
                    .Reset	( (oHcnt > `HS_Ts-1) || Reset ),
                    .Initial	( 10'b0 ),
                    .Enable	( 1'b1	),
                    .Q	(	oHcnt )
                  );

UPCOUNTER_POSEDGE # (10) VERTICAL_COUNTER
                  (
                    .Clock	( clk25MHz ),
                    .Reset	( (oVcnt > `VS_lines_Ts-1) || Reset ),
                    .Initial	( 10'b0 ),
                    .Enable	( wEOL ),
                    .Q	( oVcnt )
                  );

endmodule
  //----------------------------------------------------------------------
