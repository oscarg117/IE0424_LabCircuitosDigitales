`timescale 1ns / 1ps
`include "Defintions.v"

module MiniAlu
       (
         input  wire Clock,
         input  wire Reset,
         input  wire PS2_CLK,
         input  wire PS2_DATA,
         output wire VGA_RED, VGA_GREEN, VGA_BLUE,
         output wire VGA_HSYNC,
         output wire VGA_VSYNC
       );

wire [15:0] wIP, wIP_temp;
wire [27:0] wInstruction;
wire [3: 0] wOperation;
wire [7: 0] wSourceAddr0, wSourceAddr1, wDestination;
wire [15:0] wSourceData0, wSourceData1, wIPInitialValue, wImmediateValue;

reg rWriteEnable, rBranchTaken;
reg [15:0] rResult, rResultHI;
reg rVGAWriteEnable;
reg rRetCall;
reg [7: 0] rRetIP;
reg rRGB2VRAM;

wire [7:0] wRetCall;
wire wVGA_R, wVGA_G, wVGA_B;
wire [9:0] wHcnt, wVcnt;
wire [9:0] wCurrCol, wCurrRow;
wire [9:0] wXisqr;
wire [2:0] wRGB2VRAM;

//assign wXisqr = ({7'd28, 3'd0});


assign wCurrCol = ( wHcnt >= `HS_Tbp &&
                   wHcnt < `HS_Tdisp + `HS_Tbp) ?
       (wHcnt - `HS_Tbp) : 10'd0;

assign wCurrRow = ( wVcnt >= `VS_lines_Tbp &&
                   wVcnt < `VS_lines_Tdisp + `VS_lines_Tbp) ?
       (wVcnt - `VS_lines_Tbp) : 10'd0;

wire Clock25MHz;
UPCOUNTER_POSEDGE # ( 1 ) HalfCLK
                  (
                    .Clock( Clock ),
                    .Reset( Reset),
                    .Initial( 1'd0 ),
                    .Enable( 1'b1 ),
                    .Q( Clock25MHz )
                  );


VGA_controller VGA_ctrl
               (
                 .clk25MHz( Clock25MHz ),
                 .Reset( Reset ),
                 .iFromVRAM_RGB( {wVGA_R, wVGA_G, wVGA_B} ),
                 .iXisqr(wXisqr),
                 .oToVGA_RGB( {VGA_RED, VGA_GREEN, VGA_BLUE} ),
                 .oHSync( VGA_HSYNC ),
                 .oVSync( VGA_VSYNC ),
                 .oVcnt( wVcnt ),
                 .oHcnt( wHcnt )
               );

reg [7:0] Filter;
reg FClock;
always @ (posedge Clock25MHz) begin
	Filter <= {PS2_CLK, Filter[7:1]};
	if (Filter == 8'hFF) FClock = 1'b1;
	if (Filter == 8'd0) FClock = 1'b0;
end

reg [7:0] FilterData;
reg FData;
always @ (posedge Clock25MHz) begin
	FilterData <= {PS2_DATA, FilterData[7:1]};
	if (FilterData == 8'hFF) FData = 1'b1;
	if (FilterData == 8'd0) FData = 1'b0;
end


PS2_Controller PS2_Controller
(
	.Reset(Reset),
	.PS2_CLK(FClock),
	.PS2_DATA(FData),
	.oXisqr(wXisqr)
);

//*/


ROM InstructionRom
    (
      .iAddress( wIP ),
      .oInstruction( wInstruction )
    );


RAM_SINGLE_READ_PORT # (3, 13, 80*60) VideoRAM
                     (
                       .Clock(Clock),
                       .iWriteEnable( rVGAWriteEnable ),
                       .iReadAddress( {wCurrRow[8:3], wCurrCol[9:3]} ),  // Row, Col
                       .iWriteAddress( {wSourceData0[5:0], wSourceData1[6:0]} ),  // Row, Col
                       .iDataIn( wRGB2VRAM ),
                       .oDataOut( {wVGA_R, wVGA_G, wVGA_B} )
                     );


RAM_DUAL_READ_PORT # (16, 8, 16) DataRam
                   (
                     .Clock( Clock ),
                     .iWriteEnable( rWriteEnable ),
                     .iReadAddress0( wInstruction[7: 0] ),
                     .iReadAddress1( wInstruction[15:8] ),
                     .iWriteAddress( wDestination ),
                     .iDataIn( rResult ),
                     .oDataOut0( wSourceData0 ),
                     .oDataOut1( wSourceData1 )
                   );

always @ (posedge Clock)
  begin
    if (wOperation == `CALL)
      rRetIP <= wIP_temp;
  end

assign wImmediateValue = {wSourceAddr1, wSourceAddr0};

assign wIP = (rBranchTaken) ? wIPInitialValue : wIP_temp;
assign wIPInitialValue = (Reset) ? 8'b0 : wRetCall;
assign wRetCall = (rRetCall) ? rRetIP : wDestination;

UPCOUNTER_POSEDGE IP
                  (
                    .Clock( Clock ),
                    .Reset( Reset | rBranchTaken ),
                    .Initial( wIPInitialValue + 16'd1 ),
                    .Enable( 1'b1 ),
                    .Q( wIP_temp )
                  );
FFD_POSEDGE_SYNCRONOUS_RESET # ( 4 ) FFD1
                             (                //Operacion
                               .Clock(Clock),
                               .Reset(Reset),
                               .Enable(1'b1),
                               .D(wInstruction[27: 24]),
                               .Q(wOperation)
                             );

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD2
                             (                //Registro 0 (Der)
                               .Clock(Clock),
                               .Reset(Reset),
                               .Enable(1'b1),
                               .D(wInstruction[7: 0]),
                               .Q(wSourceAddr0)
                             );

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD3
                             (                //Registro 1 (Centro)
                               .Clock(Clock),
                               .Reset(Reset),
                               .Enable(1'b1),
                               .D(wInstruction[15: 8]),
                               .Q(wSourceAddr1)
                             );

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD4
                             (                //Registro destino (Izq)
                               .Clock(Clock),
                               .Reset(Reset),
                               .Enable(1'b1),
                               .D(wInstruction[23: 16]),
                               .Q(wDestination)
                             );

FFD_POSEDGE_SYNCRONOUS_RESET # ( 3 ) FFD_RGB
                            (                //Registro de Color
                              .Clock(Clock),
                              .Reset(Reset),
                              .Enable(rRGB2VRAM),
                              .D(wSourceAddr1[2:0]),
                              .Q(wRGB2VRAM)
                            );

always @ ( * )
  begin
    case (wOperation)
      //-------------------------------------
      `NOP:
        begin
          rBranchTaken <= 1'b0;
          rWriteEnable <= 1'b0;
          {rResultHI, rResult} <= 32'd0;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b0;
          rRGB2VRAM <= 1'd0;
        end

      //-------------------------------------
      `ADD:
        begin
          rBranchTaken <= 1'b0;
          rWriteEnable <= 1'b1;
          {rResultHI, rResult} <= wSourceData1 + wSourceData0;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b0;
          rRGB2VRAM <= 1'd0;
        end

      //-------------------------------------
      `SUB:
        begin
          rBranchTaken <= 1'b0;
          rWriteEnable <= 1'b1;
          {rResultHI, rResult} <= wSourceData1 - wSourceData0;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b0;
          rRGB2VRAM <= 1'd0;
        end

      //-------------------------------------
      `STO:
        begin
          rWriteEnable <= 1'b1;
          rBranchTaken <= 1'b0;
          {rResultHI, rResult} <= wImmediateValue;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b0;
          rRGB2VRAM <= 1'b0;
        end

      //-------------------------------------
      `BLE:
        begin
          rWriteEnable <= 1'b0;
          {rResultHI, rResult} <= 32'd0;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b0;
          rRGB2VRAM <= 1'd0;

          if (wSourceData1 <= wSourceData0 )
            rBranchTaken <= 1'b1;
          else
            rBranchTaken <= 1'b0;

        end
      //-------------------------------------
      `BEQ:
        begin
          rWriteEnable <= 1'b0;
          {rResultHI, rResult} <= 32'd0;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b0;
          rRGB2VRAM <= 1'd0;

          if (wSourceData1 == wSourceData0 )
            rBranchTaken <= 1'b1;
          else
            rBranchTaken <= 1'b0;

        end

      //-------------------------------------
      `JMP:
        begin
          rWriteEnable <= 1'b0;
          {rResultHI, rResult} <= 32'd0;
          rBranchTaken <= 1'b1;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b0;
          rRGB2VRAM <= 1'd0;
        end

      //-------------------------------------
      //-------------------------------------
      `SMUL:
        begin
          rBranchTaken <= 1'b0;
          rWriteEnable <= 1'b1;
          {rResultHI, rResult} <= wSourceData1 * wSourceData0;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b0;
          rRGB2VRAM <= 1'd0;
        end

      //--------------------------------------
      `CALL:
        begin
          rWriteEnable <= 1'b0;
          {rResultHI, rResult} <= 32'd0;
          rBranchTaken <= 1'b1;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b0;
          rRGB2VRAM <= 1'd0;
        end

      //--------------------------------------
      `RET:
        begin
          rWriteEnable <= 1'b0;
          {rResultHI, rResult} <= 32'd0;
          rBranchTaken <= 1'b1;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b1;
          rRGB2VRAM <= 1'd0;
        end

      //-------------------------------------
      `INC:
        begin
          rBranchTaken <= 1'b0;
          rWriteEnable <= 1'b1;
          {rResultHI, rResult} <= wSourceData1 + 1;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b0;
          rRGB2VRAM <= 1'd0;
        end

      //-------------------------------------
      `MOV:
        begin
          rBranchTaken <= 1'b0;
          rWriteEnable <= 1'b1;
          {rResultHI, rResult} <= wSourceData1;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b0;
          rRGB2VRAM <= 1'd0;
        end

        //-------------------------------------
        `RGB:
          begin
            rWriteEnable <= 1'b0;
            rBranchTaken <= 1'b0;
            {rResultHI, rResult} <= 32'd0;
            rVGAWriteEnable <= 1'b0;
            rRetCall <= 1'b0;
            rRGB2VRAM <= 1'b1;
          end

        //-------------------------------------
        `STC:
          begin
            rWriteEnable <= 1'b0;
            rBranchTaken <= 1'b0;
            {rResultHI, rResult} <= 32'd0;
            rVGAWriteEnable <= 1'b1;
            rRetCall <= 1'b0;
            rRGB2VRAM <= 1'd0;
          end


      //-------------------------------------
      default:
        begin
          rWriteEnable <= 1'b0;
          {rResultHI, rResult} <= 32'd0;
          rBranchTaken <= 1'b0;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b0;
          rRGB2VRAM <= 1'd0;
        end

      //-------------------------------------
    endcase
  end


endmodule
