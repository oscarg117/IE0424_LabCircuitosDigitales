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

`define V_OFFSET        100
`define H_OFFSET        100

`endif


module MiniAlu
       (
         input wire Clock,
         input wire Reset,
         output wire VGA_RED, VGA_GREEN, VGA_BLUE,
         output wire VGA_HSYNC,
         output wire VGA_VSYNC
       );

wire [15: 0] wIP, wIP_temp;
reg rWriteEnable, rBranchTaken;
wire [27: 0] wInstruction;
wire [3: 0] wOperation;
reg signed [15: 0] rResult, rResultHI; //Con signo
wire signed [31: 0]	wResultTotal;
wire [7: 0] wSourceAddr0, wSourceAddr1, wDestination;
wire signed [15: 0] wSourceData0, wSourceData1, wIPInitialValue, wImmediateValue; //Con signo

/******/

reg rVGAWriteEnable;
wire wVGA_R, wVGA_G, wVGA_B;

wire [9: 0] wH_counter, wV_counter;
wire [9: 0] wH_read, wV_read;

assign wH_read = (  wH_counter >= `HS_Tbp &&
                    wH_counter < `HS_Tdisp + `HS_Tbp) ?
                      (wH_counter - `HS_Tbp) : 10'd0;

assign wV_read = (  wV_counter >= `VS_lines_Tbp &&
                    wV_counter < `VS_lines_Tdisp + `VS_lines_Tbp) ?
                      (wV_counter - `VS_lines_Tbp) : 10'd0;

/* */
// assign wH_read = (  wH_counter >= `HS_Tbp+`H_OFFSET &&
//                     wH_counter <= `VS_lines_Ts - `VS_lines_Tpw) ?
//                       (wH_counter - `HS_Tbp+`H_OFFSET) : 8'd0;
// assign wV_read = (  wV_counter >= `VS_lines_Tbp+`V_OFFSET &&
//                     wV_counter <= `VS_lines_Ts-`VS_lines_Tpw-`VS_lines_Tfp-`V_OFFSET) ?
//                       (wV_counter - `VS_lines_Tbp+`V_OFFSET) : 8'd0;

reg rRetCall;
reg [7: 0] rDirectionBuffer;
wire [7: 0] wRetCall;
wire [9: 0] wXRedCounter, wYRedCounter;
wire [2: 0] HolyCow;

// Definición del clock de 25 MHz
wire Clock_lento; // Clock con frecuencia de 25 MHz

// Se crea una entrada de reset especial
// para el clock lento, ya que se quiere
// que se inicie desde el puro inicio.
reg rflag;
reg Reset_clock;
always @ (posedge Clock)
  begin
    if (rflag)
      begin
        Reset_clock <= 0;
      end
    else
      begin
        Reset_clock <= 1;
        rflag <= 1;
      end
  end

// Instancia para crear el clock lento
wire wClock_counter;
assign Clock_lento = wClock_counter;
UPCOUNTER_POSEDGE # ( 1 ) Slow_clock
                  (
                    .Clock( Clock ),
                    .Reset( Reset_clock ),
                    .Initial( 1'd0 ),
                    .Enable( 1'b1 ),
                    .Q( wClock_counter )
                  );
// Fin de la implementación del reloj lento

// Instancia del controlador de VGA
VGA_controller VGA_controlador
               (
                 .Clock_lento(Clock_lento),
                 .Reset(Reset),
                 .iXRedCounter(wXRedCounter),
                 .iYRedCounter(wYRedCounter),
                 .iVGA_RGB({wVGA_R, wVGA_G, wVGA_B}),
                 .iColorCuadro(HolyCow),
                 .oVGA_RGB({VGA_RED, VGA_GREEN, VGA_BLUE}),
                 .oHsync(VGA_HSYNC),
                 .oVsync(VGA_VSYNC),
                 .oVcounter(wV_counter),
                 .oHcounter(wH_counter)
               );
// reg [7: 0] Filter;
// reg FClock;
// always @ (posedge Clock_lento)
//   begin
//     Filter <= {PS2_CLK, Filter[7: 1]};
//
//     if (Filter == 8'hFF) FClock = 1'b1;
//     if (Filter == 8'd0) FClock = 1'b0;
//   end
//
// reg [7: 0] FilterData;
// reg FData;
// always @ (posedge Clock_lento)
//   begin
//     FilterData <= {PS2_DATA, FilterData[7: 1]};
//
//     if (FilterData == 8'hFF) FData = 1'b1;
//     if (FilterData == 8'd0) FData = 1'b0;
//   end


ROM InstructionRom
    (
      .iAddress( wIP ),
      .oInstruction( wInstruction )
    );


RAM_SINGLE_READ_PORT # (3, 13, 80*60) VideoMemory
                     (
                       .Clock(Clock),
                       .iWriteEnable( rVGAWriteEnable ),
                       .iReadAddress( {wH_read[9:3], wV_read[9:4]} ),  // Columna, fila
                       .iWriteAddress( {wSourceData1[6:0], wSourceData0[5:0]} ),  // Columna, fila
                       .iDataIn(wInstruction[18: 16]),
                       .oDataOut( {wVGA_R, wVGA_G, wVGA_B} )
                     );

RAM_DUAL_READ_PORT DataRam
                   (
                     .Clock( Clock ),
                     .iWriteEnable( rWriteEnable ),
                     .iReadAddress0( wInstruction[7: 0] ),
                     .iReadAddress1( wInstruction[15: 8] ),
                     .iWriteAddress( wDestination ),
                     .iDataIn( rResult ),
                     .oDataOut0( wSourceData0 ),
                     .oDataOut1( wSourceData1 )
                   );

always @ (posedge Clock)
 begin
   if (wOperation == `CALL)
     rDirectionBuffer <= wIP_temp;
 end

assign wIP = (rBranchTaken) ? wIPInitialValue : wIP_temp;
assign wIPInitialValue = (Reset) ? 8'b0 : wRetCall;
assign wRetCall = (rRetCall) ? rDirectionBuffer : wDestination;

//assign wIPInitialValue = (Reset) ? 8'b0 : wDestination;

initial
  begin
		 $monitor("t=%3d VGA_WEn=%d RET=%d \n",$time,rVGAWriteEnable, rRetCall);
  end

UPCOUNTER_POSEDGE IP
                  (
                    .Clock( Clock ),
                    .Reset( Reset | rBranchTaken ),
                    .Initial( wIPInitialValue + 16'd1 ),
                    .Enable( 1'b1 ),
                    .Q( wIP_temp )
                  );
//assign wIP = (rBranchTaken) ? wIPInitialValue : wIP_temp;

FFD_POSEDGE_SYNCRONOUS_RESET # ( 4 ) FFD1
                             (                //Instruccion
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



assign wImmediateValue = {wSourceAddr1, wSourceAddr0};
assign wResultTotal = {rResultHI, rResult};



always @ ( * )
  begin
    case (wOperation)
      //-------------------------------------
      `NOP:
        begin
          rBranchTaken <= 1'b0;
          rWriteEnable <= 1'b0;
          {rResultHI, rResult} <= 0;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b0;
        end

      //-------------------------------------
      `ADD:
        begin
          rBranchTaken <= 1'b0;
          rWriteEnable <= 1'b1;
          {rResultHI, rResult} <= wSourceData1 + wSourceData0;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b0;
        end

      //-------------------------------------
      `SUB:
        begin
          rBranchTaken <= 1'b0;
          rWriteEnable <= 1'b1;
          {rResultHI, rResult} <= wSourceData1 - wSourceData0;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b0;
        end

      //-------------------------------------
      `STO:
        begin
          rBranchTaken <= 1'b0;
          rWriteEnable <= 1'b1;
          {rResultHI, rResult} <= wImmediateValue;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b0;
        end

      //-------------------------------------
      `BLE:
        begin
          rWriteEnable <= 1'b0;
          {rResultHI, rResult} <= 0;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b0;
          if (wSourceData1 <= wSourceData0 )
            rBranchTaken <= 1'b1;
          else
            rBranchTaken <= 1'b0;

        end
        //-------------------------------------
        `BGE:
          begin
            rWriteEnable <= 1'b0;
            {rResultHI, rResult} <= 0;
            rVGAWriteEnable <= 1'b0;
            rRetCall <= 1'b0;

            if (wSourceData1 >= wSourceData0 )
              rBranchTaken <= 1'b1;
            else
              rBranchTaken <= 1'b0;
          end

      //-------------------------------------
      `JMP:
        begin
          rWriteEnable <= 1'b0;
          {rResultHI, rResult} <= 0;
          rBranchTaken <= 1'b1;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b0;
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
        end

        //--------------------------------------
        `CALL:
          begin
            rWriteEnable <= 1'b0;
            rResult <= 0;
            rBranchTaken <= 1'b1;
            rVGAWriteEnable <= 1'b0;
            rRetCall <= 1'b0;
          end

        //--------------------------------------
        `RET:
          begin
            rWriteEnable <= 1'b0;
            {rResultHI, rResult} <= 0;
            rBranchTaken <= 1'b1;
            rVGAWriteEnable <= 1'b0;
            rRetCall <= 1'b1;
          end

        //-------------------------------------
        `VGA:
          begin
            rWriteEnable <= 1'b0;
            rBranchTaken <= 1'b0;
            {rResultHI, rResult} <= 0;
            rVGAWriteEnable <= 1'b1;
            rRetCall <= 1'b0;
          end

        //-------------------------------------
        `INC:
          begin
            rBranchTaken <= 1'b0;
            rWriteEnable <= 1'b1;
            {rResultHI, rResult} <= wSourceData1 + 1;
            rVGAWriteEnable <= 1'b0;
            rRetCall <= 1'b0;
          end

          //-------------------------------------
          `MOV:
            begin
              rBranchTaken <= 1'b0;
              rWriteEnable <= 1'b1;
              {rResultHI, rResult} <= wSourceData1;
              rVGAWriteEnable <= 1'b0;
              rRetCall <= 1'b0;
            end
      //-------------------------------------
      default:
        begin
          rWriteEnable <= 1'b0;
          {rResultHI, rResult} <= 0;
          rBranchTaken <= 1'b0;
          rVGAWriteEnable <= 1'b0;
          rRetCall <= 1'b0;
        end

      //-------------------------------------
    endcase
  end


endmodule
