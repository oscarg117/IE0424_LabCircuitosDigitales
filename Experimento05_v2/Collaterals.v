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
    input wire clk25MHz,
    input wire Reset,
    input wire [2: 0]	iFromVRAM_RGB,
    output wire	[2: 0]	oToVGA_RGB,
    output wire	oHSync,
    output wire	oVSync,
    output wire [9: 0]	oVcnt,
    output wire [9: 0]	oHcnt
  );
wire wFromVRAM_R, wFromVRAM_G, wFromVRAM_B;
wire wToVGA_R, wToVGA_G, wToVGA_B;
wire wEOL;

assign wFromVRAM_R = iFromVRAM_RGB[2];
assign wFromVRAM_G = iFromVRAM_RGB[1];
assign wFromVRAM_B = iFromVRAM_RGB[0];
assign oToVGA_RGB = {wToVGA_R, wToVGA_G, wToVGA_B};

assign oHSync = (oHcnt < `HS_Ts - `HS_Tpw) ? 1'b1 : 1'b0;
assign wEOL = (oHcnt == `HS_Ts - 1);
assign oVSync = (oVcnt < `VS_lines_Ts - 1) ? 1'b1 : 1'b0;

assign {wToVGA_R, wToVGA_G, wToVGA_B} = ( oVcnt < `VS_lines_Tbp + `V_OFFSET ||
       oVcnt >= `VS_lines_Ts - `VS_lines_Tpw - `VS_lines_Tfp - `V_OFFSET ||
       oHcnt < `HS_Tbp + `H_OFFSET ||
       oHcnt > `HS_Ts - `HS_Tpw - `HS_Tfp - `H_OFFSET )
       ? `BLACK : {wFromVRAM_R, wFromVRAM_G, wFromVRAM_B};

UPCOUNTER_POSEDGE # (10) HORIZONTAL_COUNTER
                  (
                    .Clock	( clk25MHz ),
                    .Reset	( (oHcnt > `HS_Ts - 1) || Reset ),
                    .Initial	( 10'b0 ),
                    .Enable	( 1'b1	),
                    .Q	(	oHcnt )
                  );

UPCOUNTER_POSEDGE # (10) VERTICAL_COUNTER
                  (
                    .Clock	( clk25MHz ),
                    .Reset	( (oVcnt > `VS_lines_Ts - 1) || Reset ),
                    .Initial	( 10'b0 ),
                    .Enable	( wEOL ),
                    .Q	( oVcnt )
                  );

endmodule
  //----------------------------------------------------------------------

module PS2_Controller
  (
    input wire Reset,
    input wire PS2_CLK,
    input wire PS2_DATA,
    output reg [3: 0] oXk, oYk
  );

reg [7: 0] ScanCode;
reg [8: 0] rDataBuffer;
reg Done, Read;
reg [3: 0] ClockCounter;
reg rFlagNoError;
reg rFlagF0;

always @ (negedge PS2_CLK or posedge Reset)
  begin
    if (Reset)
      begin
        ClockCounter <= 0;
        Read <= 1;
        Done <= 0;
      end
    else
      begin
        if (Read == 1'b1 && PS2_DATA == 1'b0)
          begin
            Read <= 0;
            Done <= 0;
          end
        else if (Read == 1'b0)
          begin
            if (ClockCounter < 9)
              begin
                ClockCounter <= ClockCounter + 1;
                rDataBuffer <= {PS2_DATA, rDataBuffer[8: 1]};
                Done <= 0;
              end
            else
              begin
                ClockCounter <= 1'b0;
                Done <= 1;
                ScanCode <= rDataBuffer[7: 0];
                Read <= 1;

                if ( ^ ScanCode == rDataBuffer[8])
                  rFlagNoError <= 1'b0;
                else
                  rFlagNoError <= 1'b1;
              end

          end
      end
  end

always @ (posedge Done or posedge Reset)
  begin
    if (Reset)
      begin
        oXk <= 4'd1;
        oYk <= 4'd8;
        rFlagF0 <= 1'b0;
      end
    else
      begin
        if (rFlagF0)
          begin
            rFlagF0 <= 1'd0;
          end
        else
          case (ScanCode)
            `LEF:
              begin
                oYk <= oYk;
                rFlagF0 <= rFlagF0;
                if (oXk <= 4'd0)
                  begin
                    oXk <= 4'd3;
                  end
                else
                  begin
                    oXk <= oXk - 4'd1;
                  end
              end

            `RIG:
              begin
                oYk <= oYk;
                rFlagF0 <= rFlagF0;
                if (oXk >= 4'd3)
                  begin
                    oXk <= 4'd0;
                  end
                else
                  begin
                    oXk <= oXk + 4'd1;
                  end
              end

            `UP :
              begin
                oXk <= oXk;
                rFlagF0 <= rFlagF0;
                if (oYk <= 4'd0)
                  begin
                    oYk <= 4'd0;
                  end
                else
                  begin
                    oYk <= oYk - 4'd1;
                  end
              end

            `DOW:
              begin
                oXk <= oXk;
                rFlagF0 <= rFlagF0;
                if (oYk >= 4'd9)
                  begin
                    oYk <= 4'd9;
                  end
                else
                  begin
                    oYk <= oYk + 4'd1;
                  end
              end

            `END_PS2:
              begin	//Señal de finalizacion del PS2
                oXk <= oXk;
                oYk <= oYk;
                rFlagF0 <= 1'b1;
              end

            `SPACE:
              begin	//29 = Barra Espaciadora
                oXk <= 4'd1;
                oYk <= 4'd8;
                rFlagF0 <= 1'd0;
              end

            default:
              begin
                oXk <= oXk;
                oYk <= oYk;
                rFlagF0 <= rFlagF0;
              end

          endcase
      end
  end

endmodule
