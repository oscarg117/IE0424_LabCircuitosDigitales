`timescale 1ns / 1ps


// `define STATE_RESET             0
`define STATE_POWERON_INIT_0_A  34
`define STATE_POWERON_INIT_0_B  35
//`define STATE_POWERON_INIT_1    3
`define STATE_POWERON_INIT_2_A  36
`define STATE_POWERON_INIT_2_B  37
`define STATE_POWERON_INIT_3_B  38

`define STATE_RESET 0
`define STATE_POWERON_INIT_0 1
`define STATE_POWERON_INIT_1 2
`define STATE_POWERON_INIT_2 3
`define STATE_POWERON_INIT_3 4
`define STATE_POWERON_INIT_4 5
`define STATE_POWERON_INIT_5 6
`define STATE_POWERON_INIT_6 7
`define STATE_POWERON_INIT_7 8
`define STATE_POWERON_INIT_8 9
`define STATE_POWERON_INIT_9 10
`define STATE_POWERON_INIT_10 11
`define STATE_POWERON_INIT_11 12
`define STATE_POWERON_INIT_12 13
`define STATE_POWERON_INIT_13 14
`define STATE_POWERON_INIT_14 15
`define STATE_POWERON_INIT_15 16
`define STATE_POWERON_INIT_16 17
`define STATE_POWERON_INIT_17 18
`define STATE_POWERON_INIT_18 19
`define STATE_POWERON_INIT_19 20
`define STATE_POWERON_INIT_20 21
`define STATE_POWERON_INIT_21 22
`define STATE_POWERON_INIT_22 23
`define STATE_POWERON_INIT_23 24
`define STATE_POWERON_INIT_24 25
`define STATE_POWERON_INIT_25 26
`define STATE_POWERON_INIT_26 27
`define STATE_POWERON_INIT_27 28
`define STATE_POWERON_INIT_28 29
`define STATE_POWERON_INIT_29 30
`define STATE_POWERON_INIT_30 31
`define STATE_POWERON_INIT_31 32
`define STATE_POWERON_INIT_32 33



module Module_LCD_Control
(
  input wire Clock,
  input wire Reset,
  output wire oLCD_Enabled,
  output reg oLCD_RegisterSelect,
  output wire oLCD_StrataFlashControl,
  output wire oLCD_ReadWrite,
  output reg[3:0] oLCD_Data
);
//0=Command, 1=Data
  reg rWrite_Enabled;
  assign oLCD_ReadWrite = 0;
  //I only Write to the LCD display, never Read from it
  assign oLCD_StrataFlashControl = 1; //StrataFlash disabled. Full read/write access to LCD
  reg [7:0] rCurrentState,rNextState;
  reg [31:0] rTimeCount;
  reg rTimeCountReset;
  wire wWriteDone;
  //----------------------------------------------
  //Next State and delay logic
  always @ ( posedge Clock )
  begin
    if (Reset)
      begin
        rCurrentState = `STATE_RESET;
        rTimeCount <= 32'b0;
      end
    else
      begin
        if (rTimeCountReset)
          rTimeCount <= 32'b0;
        else
          rTimeCount <= rTimeCount + 32'b1;
          rCurrentState <= rNextState;
      end
  end
  //----------------------------------------------
  //Current state and output logic
  always @ ( * )
  begin
    case (rCurrentState)
      //------------------------------------------
      `STATE_RESET:
        begin
          rWrite_Enabled = 1'b0;
          oLCD_Data = 4'h0;
          oLCD_RegisterSelect = 1'b0;
          rTimeCountReset = 1'b0;
          rNextState = `STATE_POWERON_INIT_0_A;
        end
    //------------------------------------------
  /*
  Wait 15 ms or longer.
  The 15 ms interval is 750,000 clock cycles at 50 MHz.
  */
      `STATE_POWERON_INIT_0_A:
        begin
          rWrite_Enabled = 1'b0;
          oLCD_Data = 4'h0;
          oLCD_RegisterSelect = 1'b0; //these are commands
          rTimeCountReset = 1'b0;
          if (rTimeCount > 32'd750000 )
            rNextState = `STATE_POWERON_INIT_0_B;
          else
            rNextState = `STATE_POWERON_INIT_0_A;
        end
  //------------------------------------------
      `STATE_POWERON_INIT_0_B:
        begin
          rWrite_Enabled = 1'b0;
          oLCD_Data = 4'h0;
          oLCD_RegisterSelect = 1'b0; //these are commands
          rTimeCountReset = 1'b1; //Reset the counter here
          rNextState = `STATE_POWERON_INIT_1;
        end
  //------------------------------------------
  /*
  Write SF_D<11:8> = 0x3, pulse LCD_E High for 12 clock cycles
  */
      `STATE_POWERON_INIT_1:
        begin
          rWrite_Enabled = 1'b1;
          oLCD_Data = 4'h3;
          oLCD_RegisterSelect = 1'b0; //these are commands
          rTimeCountReset = 1'b1;
          if ( wWriteDone )
            rNextState = `STATE_POWERON_INIT_2;
          else
            rNextState = `STATE_POWERON_INIT_1;
        end
  //------------------------------------------
  /*
  Wait 4.1 ms or longer, which is 205,000 clock cycles at 50 MHz.
  */
      `STATE_POWERON_INIT_2_A:
        begin
          rWrite_Enabled = 1'b0;
          oLCD_Data = 4'h3;
          oLCD_RegisterSelect = 1'b0; //these are commands
          rTimeCountReset = 1'b0;
          if (rTimeCount > 32'd205000 )
            rNextState = `STATE_POWERON_INIT_3;
          else
            rNextState = `STATE_POWERON_INIT_2;
        end
  //------------------------------------------
      `STATE_POWERON_INIT_2_B:
        begin
          rWrite_Enabled = 1'b0;
          oLCD_Data = 4'h3;
          oLCD_RegisterSelect = 1'b0; //these are commands
          rTimeCountReset = 1'b1;
          rNextState = `STATE_POWERON_INIT_3;
        end
  //------------------------------------------
      default:
        begin
          rWrite_Enabled = 1'b0;
          oLCD_Data = 4'h0;
          oLCD_RegisterSelect = 1'b0;
          rTimeCountReset = 1'b0;
          rNextState = `STATE_RESET;
        end
  //------------------------------------------
    endcase
    end
  endmodule
