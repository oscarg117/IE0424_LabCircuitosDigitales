`timescale 1ns / 1ps
`include "Defintions.v"


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
`define STATE_POWERON_INIT_33 34
`define STATE_POWERON_INIT_34 35

module Module_LCD_Control
(
input wire Clock,
input wire Reset,
output reg wReady,
output reg oLCD_Enabled,
output reg oLCD_RegisterSelect, //0=Command, 1=Data
output wire oLCD_StrataFlashControl,
output wire oLCD_ReadWrite,
output reg[3:0] oLCD_Data
);

//reg rWrite_Enabled;
assign oLCD_ReadWrite = 0; //I only Write to the LCD display, never Read from it
assign oLCD_StrataFlashControl = 1; //StrataFlash disabled. Full read/write access to LCD
reg [7:0] rCurrentState,rNextState;
reg [31:0] rTimeCount;
reg rTimeCountReset;
//wire wWriteDone;

//----------------------------------------------
//Next State and delay logic
always @ ( posedge Clock )
begin
		if (Reset)
			begin
				rCurrentState = `STATE_RESET;
				rTimeCount = 32'b0;
			end
		else
			begin
				if (rTimeCountReset)
				rTimeCount = 32'b0;
			else
				rTimeCount = rTimeCount + 32'b1;
		rCurrentState = rNextState;
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
				wReady = 1'b0;
				oLCD_Enabled = 1'b0;
				oLCD_Data = 4'h0;
				oLCD_RegisterSelect = 1'b0;
				rTimeCountReset = 1'b0;
				rNextState = `STATE_POWERON_INIT_0;
			end
		//------------------------------------------
		/*
		Wait 15 ms or longer.
		The 15 ms interval is 750,000 clock cycles at 50 MHz.
		*/
			`STATE_POWERON_INIT_0:
			begin
				wReady = 1'b0;
				oLCD_Enabled = 1'b0;
				oLCD_Data = 4'h3;
				oLCD_RegisterSelect = 1'b0; //these are commands
				if (rTimeCount > 32'd750000 )
					begin
					rTimeCountReset = 1'b1;
					rNextState = `STATE_POWERON_INIT_1;
					end
				else
					begin
					rTimeCountReset = 1'b0;
					rNextState = `STATE_POWERON_INIT_0;
					end
			end
//------------------------------------------
/*Write SF_D<11:8> = 0x3, pulse LCD_E High for 12 clock cycles
*/
			`STATE_POWERON_INIT_1:
			begin
				wReady = 1'b0;
				oLCD_Enabled = 1'b1;
				oLCD_Data = 4'h3;
				oLCD_RegisterSelect = 1'b0; //these are commands
				rTimeCountReset = 1'b1;
				if (rTimeCount > 32'd11 )
					begin
					rTimeCountReset = 1'b1;
					rNextState = `STATE_POWERON_INIT_2;
					end
				else
					begin
					rTimeCountReset = 1'b0;
					rNextState = `STATE_POWERON_INIT_1;
					end
			end
//------------------------------------------
/* Wait 4.1 ms or longer, which is 205,000 clock cycles at 50 MHz.
*/
		`STATE_POWERON_INIT_2:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
			if (rTimeCount > 32'd205000 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_3;
			end
			else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_2;
			end
		end
//------------------------------------------
/*Write SF_D<11:8> = 0x3, pulse LCD_E High for 12 clock cycles
*/
		
		`STATE_POWERON_INIT_3:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b1;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
			rTimeCountReset = 1'b1;
			if (rTimeCount > 32'd11 )
				begin
				rTimeCountReset = 1'b1;
				rNextState = `STATE_POWERON_INIT_4;
				end
			else
				begin
				rTimeCountReset = 1'b0;
				rNextState = `STATE_POWERON_INIT_3;
				end
		end
//------------------------------------------
// Wait 100 us or longer, which is 5,000 clock cycles at 50 MHz.
		`STATE_POWERON_INIT_4:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
			if (rTimeCount > 32'd5000 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_5;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_4;
			end
		end
//------------------------------------------
/*Write SF_D<11:8> = 0x3, pulse LCD_E High for 12 clock cycles
*/
		`STATE_POWERON_INIT_5:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b1;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
			rTimeCountReset = 1'b1;
			if (rTimeCount > 32'd11 )
				begin
				rTimeCountReset = 1'b1;
				rNextState = `STATE_POWERON_INIT_6;
				end
			else
				begin
				rTimeCountReset = 1'b0;
				rNextState = `STATE_POWERON_INIT_5;
				end
		end
//------------------------------------------
/* Wait 40 us or longer, which is 2,000 clock cycles at 50 MHz.
*/
		`STATE_POWERON_INIT_6:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
			if (rTimeCount > 32'd2000 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_7;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_6;
			end
		end
//------------------------------------------
/*Write SF_D<11:8> = 0x2, pulse LCD_E High for 12 clock cycles
*/
		`STATE_POWERON_INIT_7:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b1;
			oLCD_Data = 4'h2;
			oLCD_RegisterSelect = 1'b0; //these are commands
			rTimeCountReset = 1'b1;
			if (rTimeCount > 32'd11 )
				begin
				rTimeCountReset = 1'b1;
				rNextState = `STATE_POWERON_INIT_8;
				end
			else
				begin
				rTimeCountReset = 1'b0;
				rNextState = `STATE_POWERON_INIT_7;
				end
		end
//------------------------------------------
/* Wait 40 us or longer, which is 2,000 clock cycles at 50 MHz.
*/
		`STATE_POWERON_INIT_8:
		begin
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd2000 )
			begin
			rTimeCountReset = 1'b1;
			wReady = 1'b1;
			rNextState = `STATE_POWERON_INIT_9;
			end
		else
			begin
			wReady = 1'b0;
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_8;
			end
		end
//------------------------------------------
// Write SF_D<11:8> = 0x28, Function Set

// Write SF_D<11:8> = 4'b0010, pulse LCD_E High for 12 clock cycles
	`STATE_POWERON_INIT_9:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b1;
			oLCD_Data = 4'b0010;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd12 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_10;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_9;
			end
		end
//------------------------------------------
// Wait 1 us or longer, which is 50 clock cycles at 50 MHz.

		`STATE_POWERON_INIT_10:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd50 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_11;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_10;
			end
		end
//------------------------------------------
// Write SF_D<11:8> = 4'b1000, pulse LCD_E High for 12 clock cycles
	`STATE_POWERON_INIT_11:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b1;
			oLCD_Data = 4'b1000;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd12 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_12;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_11;
			end
		end
//------------------------------------------
/* Wait 40 us or longer, which is 2,000 clock cycles at 50 MHz.
*/
		`STATE_POWERON_INIT_12:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd2000 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_13;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_12;
			end
		end
//------------------------------------------
// Write SF_D<11:8> = 0x06, Entry Mode Set

// Write SF_D<11:8> = 4'b0000, pulse LCD_E High for 12 clock cycles
	`STATE_POWERON_INIT_13:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b1;
			oLCD_Data = 4'b0000;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd12 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_14;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_13;
			end
		end
//------------------------------------------
// Wait 1 us or longer, which is 50 clock cycles at 50 MHz.
		`STATE_POWERON_INIT_14:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd50 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_15;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_14;
			end
		end
//------------------------------------------
// Write SF_D<11:8> = 4'b0110, pulse LCD_E High for 12 clock cycles
	`STATE_POWERON_INIT_15:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b1;
			oLCD_Data = 4'b0110;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd12 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_16;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_15;
			end
		end
//------------------------------------------
/* Wait 40 us or longer, which is 2,000 clock cycles at 50 MHz.
*/
		`STATE_POWERON_INIT_16:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd2000 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_17;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_16;
			end
		end
//------------------------------------------
// Write SF_D<11:8> = 0x0C, Display On/Off

// Write SF_D<11:8> = 4'b0000, pulse LCD_E High for 12 clock cycles
	`STATE_POWERON_INIT_17:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b1;
			oLCD_Data = 4'b0000;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd12 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_18;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_17;
			end
		end
//------------------------------------------
// Wait 1 us or longer, which is 50 clock cycles at 50 MHz.
		`STATE_POWERON_INIT_18:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd50 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_19;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_18;
			end
		end
//------------------------------------------
// Write SF_D<11:8> = 4'b1100, pulse LCD_E High for 12 clock cycles
	`STATE_POWERON_INIT_19:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b1;
			oLCD_Data = 4'b1101;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd12 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_20;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_19;
			end
		end
//------------------------------------------
/* Wait 40 us or longer, which is 2,000 clock cycles at 50 MHz.
*/
		`STATE_POWERON_INIT_20:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd2000 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_21;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_20;
			end
		end
//------------------------------------------
//------------------------------------------
// Write SF_D<11:8> = 0x01, Clear Display

// Write SF_D<11:8> = 4'b0000, pulse LCD_E High for 12 clock cycles
	`STATE_POWERON_INIT_21:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b1;
			oLCD_Data = 4'b0000;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd12 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_22;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_21;
			end
		end
//------------------------------------------
// Wait 1 us or longer, which is 50 clock cycles at 50 MHz.
		`STATE_POWERON_INIT_22:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd50 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_23;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_22;
			end
		end
//------------------------------------------
// Write SF_D<11:8> = 4'b0001, pulse LCD_E High for 12 clock cycles
	`STATE_POWERON_INIT_23:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b1;
			oLCD_Data = 4'b0001;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd12 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_24;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_23;
			end
		end
//------------------------------------------
/* Wait 1.64 ms or longer, which is 82,000 clock cycles at 50 MHz.
*/
		`STATE_POWERON_INIT_24:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd82000 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_25;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_24;
			end
		end				
		//------------------------------------------
// Write SF_D<11:8> = 0x80, Set DD RAM Address

// Write SF_D<11:8> = 4'b1000, pulse LCD_E High for 12 clock cycles
	`STATE_POWERON_INIT_25:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b1;
			oLCD_Data = 4'b1000;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd12 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_26;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_25;
			end
		end
//------------------------------------------
// Wait 1 us or longer, which is 50 clock cycles at 50 MHz.
		`STATE_POWERON_INIT_26:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd50)
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_27;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_26;
			end
		end
//------------------------------------------
// Write SF_D<11:8> = 4'b0000, pulse LCD_E High for 12 clock cycles
	`STATE_POWERON_INIT_27:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b1;
			oLCD_Data = 4'b0000;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd12 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_28;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_27;
			end
		end
//------------------------------------------
/* Wait 40us or longer, which is 2,000 clock cycles at 50 MHz.
*/
		`STATE_POWERON_INIT_28:
		begin
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd2000 )
			begin
			wReady = 1'b1;
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_29;
			end
		else
			begin
			wReady = 1'b0;
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_28;
			end
		end	
//------------------------------------------		
// Write SF_D<11:8> = 0x01, Write Data to DD RAM, writing B

// Write SF_D<11:8> = 4'b0100, pulse LCD_E High for 12 clock cycles
	`STATE_POWERON_INIT_29:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b1;
			oLCD_Data = 4'b0100;
			oLCD_RegisterSelect = 1'b1; //this is data
		if (rTimeCount > 32'd12 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_30;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_29;
			end
		end
//------------------------------------------
// Wait 1 us or longer, which is 50 clock cycles at 50 MHz.
		`STATE_POWERON_INIT_30:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd50)
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_31;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_30;
			end
		end
//------------------------------------------
// Write SF_D<11:8> = 4'b0010, pulse LCD_E High for 12 clock cycles
	`STATE_POWERON_INIT_31:
		begin
			wReady = 1'b0;
			oLCD_Enabled = 1'b1;
			oLCD_Data = 4'b0010;
			oLCD_RegisterSelect = 1'b1; //this is data
		if (rTimeCount > 32'd12 )
			begin
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_32;
			end
		else
			begin
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_31;
			end
		end
//------------------------------------------
/* Wait 40us or longer, which is 2,000 clock cycles at 50 MHz.
*/
		`STATE_POWERON_INIT_32:
		begin
			oLCD_Enabled = 1'b0;
			oLCD_Data = 4'h3;
			oLCD_RegisterSelect = 1'b0; //these are commands
		if (rTimeCount > 32'd25000000 )
			begin
			wReady = 1'b1;
			rTimeCountReset = 1'b1;
			rNextState = `STATE_POWERON_INIT_21;
			end
		else
			begin
			wReady = 1'b0;
			rTimeCountReset = 1'b0;
			rNextState = `STATE_POWERON_INIT_32;
			end
		end		
//------------------------------------------
		default:
		begin
				oLCD_Enabled = 1'b0;
				oLCD_Data = 4'h0;
				oLCD_RegisterSelect = 1'b0;
				rTimeCountReset = 1'b0;
				rNextState = `STATE_RESET;
		end
//------------------------------------------
endcase
end
endmodule
