`timescale 1ns / 1ps
`include "Defintions.v"


module MiniAlu
       (
         input wire Clock,
         input wire Reset,
         output wire [7: 0] oLed,
         output wire oLCD_Enabled,
         output wire oLCD_RegisterSelect,
         output wire oLCD_StrataFlashControl,
         output wire oLCD_ReadWrite,
         output wire [3: 0] oLCD_Data
       );

wire [15: 0] wIP, wIP_temp, wRetIP;
reg rWriteEnable, rBranchTaken, rWriteEnable32, rRET;
wire [27: 0] wInstruction;
wire [3: 0] wOperation;
reg [15: 0] rResult16;
reg [31: 0] rResult32;
wire [7: 0] wSourceAddr0, wSourceAddr1, wDestination, wDestinationOld;
wire [15: 0] wPreSourceData0, wPreSourceData1, wIMult;
reg [7: 0] rReturn;
wire [15: 0] wIPInitialValue, wImmediateValue, wResult16Old, wIPInitialValue_temp;
wire [15: 0] wSourceData0_16, wSourceData1_16;
wire [31: 0] wSourceData0, wSourceData1;
wire [31: 0] wPreSourceData0_32, wPreSourceData1_32, wSourceData0_32, wSourceData1_32, wResult32Old, wMult_LUT_Result;
wire signed[15: 0] wsSourceData0, wsSourceData1;
wire wReady;
reg rWrite;
reg [7: 0] rData;


assign wsSourceData0 = wSourceData0;
assign wsSourceData1 = wSourceData1;


ROM InstructionRom
    (
      .iAddress( wIP ),
      .oInstruction( wInstruction )
    );

Module_LCD_Control LCD (
                     .Clock(Clock),
                     .Reset(Reset),
                     .wWrite(rWrite),
                     .wData(rData),
                     .wReady(wReady),
                     .oLCD_Enabled(oLCD_Enabled),
                     .oLCD_RegisterSelect(oLCD_RegisterSelect),  //0=Command, 1=Data
                     .oLCD_StrataFlashControl(oLCD_StrataFlashControl),
                     .oLCD_ReadWrite(oLCD_ReadWrite),
                     .oLCD_Data(oLCD_Data)
                   );

RAM_DUAL_READ_PORT DataRam
                   (
                     .Clock( Clock ),
                     .iWriteEnable( rWriteEnable ),
                     .iReadAddress0( wInstruction[7: 0] ),
                     .iReadAddress1( wInstruction[15: 8] ),
                     .iWriteAddress( wDestination ),
                     .iDataIn( rResult16 ),
                     .oDataOut0( wPreSourceData0 ),
                     .oDataOut1( wPreSourceData1 )
                   );

RAM_DUAL_READ_PORT # (32, 8, 8) DataRam32
                   (
                     .Clock( Clock ),
                     .iWriteEnable( rWriteEnable32 ),
                     .iReadAddress0( 8'b00000111 & wInstruction[7: 0] ),
                     .iReadAddress1( 8'b00000111 & wInstruction[15: 8] ),
                     .iWriteAddress( 8'b00000111 & wDestination ),
                     .iDataIn( rResult32 ),
                     .oDataOut0( wPreSourceData0_32 ),
                     .oDataOut1( wPreSourceData1_32 )
                   );

assign wIPInitialValue_temp = (Reset) ? 8'b0 : wDestination;
assign wIPInitialValue = (rRET) ? rReturn : wIPInitialValue_temp;


UPCOUNTER_POSEDGE IP
                  (
                    .Clock( Clock ),
                    .Reset( Reset | rBranchTaken ),
                    .Initial( wIPInitialValue + 1 ),
                    .Enable( 1'b1 ),
                    .Q( wIP_temp )
                  );
assign wIP = (rBranchTaken) ? wIPInitialValue : wIP_temp;

FFD_POSEDGE_SYNCRONOUS_RESET # ( 4 ) FFD1
                             (
                               .Clock(Clock),
                               .Reset(Reset),
                               .Enable(1'b1),
                               .D(wInstruction[27: 24]),
                               .Q(wOperation)
                             );

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD2
                             (
                               .Clock(Clock),
                               .Reset(Reset),
                               .Enable(1'b1),
                               .D(wInstruction[7: 0]),
                               .Q(wSourceAddr0)
                             );

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD3
                             (
                               .Clock(Clock),
                               .Reset(Reset),
                               .Enable(1'b1),
                               .D(wInstruction[15: 8]),
                               .Q(wSourceAddr1)
                             );

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD4
                             (
                               .Clock(Clock),
                               .Reset(Reset),
                               .Enable(1'b1),
                               .D(wInstruction[23: 16]),
                               .Q(wDestination)
                             );

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD5
                             (
                               .Clock(Clock),
                               .Reset(Reset),
                               .Enable(1'b1),
                               .D(wDestination),
                               .Q(wDestinationOld)
                             );

FFD_POSEDGE_SYNCRONOUS_RESET # ( 16 ) FFD6
                             (
                               .Clock(Clock),
                               .Reset(Reset),
                               .Enable(1'b1),
                               .D(rResult16),
                               .Q(wResult16Old)
                             );

FFD_POSEDGE_SYNCRONOUS_RESET # ( 32 ) FFD7
                             (
                               .Clock(Clock),
                               .Reset(Reset),
                               .Enable(1'b1),
                               .D(rResult32),
                               .Q(wResult32Old)
                             );

reg rFFLedEN;
FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FF_LEDS
                             (
                               .Clock(Clock),
                               .Reset(Reset),
                               .Enable( rFFLedEN ),
                               .D( wSourceData1 ),
                               .Q( oLed )
                             );
reg rSave;
FFD_POSEDGE_SYNCRONOUS_RESET # ( 16 ) FF_RET
                             (
                               .Clock(Clock),
                               .Reset(Reset),
                               .Enable(rSave),
                               .D(wIP),
                               .Q(wRetIP)
                             );


assign wImmediateValue = {wSourceAddr1, wSourceAddr0};

assign wSourceData0_16 = (wSourceAddr0 == wDestinationOld) ? wResult16Old : wPreSourceData0;
assign wSourceData1_16 = (wSourceAddr1 == wDestinationOld) ? wResult16Old : wPreSourceData1;

assign wSourceData0_32 = (wSourceAddr0 == wDestinationOld) ? wResult32Old : wPreSourceData0_32;
assign wSourceData1_32 = (wSourceAddr1 == wDestinationOld) ? wResult32Old : wPreSourceData1_32;

assign wSourceData0 = (wSourceAddr0[3] == 1) ? wSourceData0_32 : wSourceData0_16;
assign wSourceData1 = (wSourceAddr1[3] == 1) ? wSourceData1_32 : wSourceData1_16;

always @ ( * )
  begin

    case (wOperation)
      //-------------------------------------
      `NOP:
        begin
          rFFLedEN <= 1'b0;
          rBranchTaken <= 1'b0;
          rWriteEnable <= 1'b0;
          rWriteEnable32 <= 1'b0;
          rResult16 <= 0;
          rResult32 <= 0;
          rSave <= 1'b1;
          rRET <= 1'b0;
          rWrite <= 0;
        end

      //-------------------------------------
      `ADD:
        begin
          rFFLedEN <= 1'b0;
          rBranchTaken <= 1'b0;
          rWriteEnable <= 1'b1;
          rWriteEnable32 <= 1'b0;
          rResult16 <= wSourceData1 + wSourceData0;
          rResult32 <= 0;
          rSave <= 1'b1;
          rRET <= 1'b0;
          rWrite <= 0;
        end

      //-------------------------------------
      `STO:
        begin
          rFFLedEN <= 1'b0;
          rBranchTaken <= 1'b0;
          rWriteEnable <= 1'b1;
          rWriteEnable32 <= 1'b0;
          rResult16 <= wImmediateValue;
          rResult32 <= 0;
          rSave <= 1'b1;
          rRET <= 1'b0;
          rWrite <= 0;
        end

      //-------------------------------------
      `BLE:
        begin
          rFFLedEN <= 1'b0;
          rWriteEnable <= 1'b0;
          rWriteEnable32 <= 1'b0;
          rResult16 <= 0;
          rResult32 <= 0;

          if (wSourceData1 <= wSourceData0 )
            rBranchTaken <= 1'b1;
          else
            rBranchTaken <= 1'b0;
          rSave <= 1'b1;
          rRET <= 1'b0;
          rWrite <= 0;
        end

      //-------------------------------------
      `JMP:
        begin
          rFFLedEN <= 1'b0;
          rBranchTaken <= 1'b1;
          rWriteEnable <= 1'b0;
          rWriteEnable32 <= 1'b0;
          rResult16 <= 0;
          rResult32 <= 0;
          rSave <= 1'b1;
          rRET <= 1'b0;
          rWrite <= 0;
        end

      //-------------------------------------
      `LED:
        begin
          rFFLedEN <= 1'b1;
          rBranchTaken <= 1'b0;
          rWriteEnable <= 1'b0;
          rWriteEnable32 <= 1'b0;
          rResult16 <= 0;
          rResult32 <= 0;
          rSave <= 1'b1;
          rRET <= 1'b0;
          rWrite <= 0;
        end

      //-------------------------------------
      `SUB:
        begin
          rFFLedEN <= 1'b0;
          rBranchTaken <= 1'b0;
          rWriteEnable <= 1'b1;
          rWriteEnable32 <= 1'b0;
          rResult16 <= wSourceData1 - wSourceData0;
          rResult32 <= 0;
          rSave <= 1'b1;
          rRET <= 1'b0;
          rWrite <= 0;
        end

      //-------------------------------------
      `SMUL:
        begin
          rFFLedEN <= 1'b0;
          rBranchTaken <= 1'b0;
          rWriteEnable <= 1'b0;
          rWriteEnable32 <= 1'b1;
          rResult16 <= 0;
          rResult32 <= wsSourceData1 * wsSourceData0;	//Multiplicacion con signo
          rSave <= 1'b1;
          rRET <= 1'b0;
          rWrite <= 0;
        end

      //-------------------------------------
      `ADD32:
        begin
          rFFLedEN <= 1'b0;
          rBranchTaken <= 1'b0;
          rWriteEnable <= 1'b0;
          rWriteEnable32 <= 1'b1;
          rResult16 <= 0;
          rResult32 <= wSourceData1 + wSourceData0;
          rSave <= 1'b1;
          rRET <= 1'b0;
          rWrite <= 0;
        end

      //-------------------------------------
      `SUB32:
        begin
          rFFLedEN <= 1'b0;
          rBranchTaken <= 1'b0;
          rWriteEnable <= 1'b0;
          rWriteEnable32 <= 1'b1;
          rResult16 <= 0;
          rResult32 <= wSourceData1 - wSourceData0;
          rSave <= 1'b1;
          rRET <= 1'b0;
          rWrite <= 0;
        end

      //-------------------------------------
      `SHL:
        begin
          rFFLedEN <= 1'b0;
          rBranchTaken <= 1'b0;
          rWriteEnable <= 1'b1;
          rWriteEnable32 <= 1'b0;
          rResult16 <= wSourceData1 << wSourceData0;
          rResult32 <= 0;
          rSave <= 1'b1;
          rRET <= 1'b0;
          rWrite <= 0;
        end

      //-------------------------------------
      `CALL:
        begin
          rFFLedEN <= 1'b0;
          rBranchTaken <= 1'b1;
          rWriteEnable <= 1'b0;
          rWriteEnable32 <= 1'b0;
          rResult16 <= 0;
          rResult32 <= 0;
          rReturn <= wRetIP + 1;
          rSave <= 1'b0;
          rRET <= 1'b0;
          rWrite <= 0;
        end

      //-------------------------------------
      `RET:
        begin
          rFFLedEN <= 1'b0;
          rBranchTaken <= 1'b1;
          rWriteEnable <= 1'b0;
          rWriteEnable32 <= 1'b0;
          rResult16 <= 0;
          rResult32 <= 0;
          rSave <= 1'b1;
          rRET <= 1'b1;
          rWrite <= 0;
        end

      //-------------------------------------
      `LCD:
        begin
          rFFLedEN <= 1'b1;
          rWriteEnable <= 1'b0;
          rWriteEnable32 <= 1'b0;
          rResult16 <= 0;
          rResult32 <= 0;
          rSave <= 1'b1;
          rWrite <= 1;

          if (wReady)
            begin
              rBranchTaken <= 1'b0;
              rRET <= 1'b0;
              rData <= wSourceAddr1;
            end
          else
            begin
              rBranchTaken <= 1'b1;
              rReturn <= wRetIP;
              rRET <= 1'b1;
            end
        end

      //-------------------------------------
      default:
        begin
          rFFLedEN <= 1'b1;
          rWriteEnable <= 1'b0;
          rWriteEnable32 <= 1'b0;
          rResult16 <= 0;
          rResult32 <= 0;
          rBranchTaken <= 1'b0;
          rSave <= 1'b1;
          rRET <= 1'b0;
          rWrite <= 0;
        end

      //-------------------------------------
    endcase
  end


endmodule
