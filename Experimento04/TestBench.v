
`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:30:52 01/30/2011
// Design Name:   MiniAlu
// Module Name:   D:/Proyecto/RTL/Dev/MiniALU/TestBench.v
// Project Name:  MiniALU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MiniAlu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module TestBench;

	// Inputs
	reg Clock;
	reg Reset;

	// Outputs
	wire [7:0] oLed;
	wire  oLCD_Enabled;
	wire  oLCD_RegisterSelect; 
	wire 	oLCD_StrataFlashControl;
	wire 	oLCD_ReadWrite;
	wire	[3:0] oLCD_Data;
	wire  oVGA_RED;
	wire  oVGA_GREEN;
	wire  oVGA_BLUE;
	wire  oVGA_HSYNC;
	wire  oVGA_VSYNC;

	// Instantiate the Unit Under Test (UUT)
	MiniAlu uut (
		.Clock(Clock), 
		.Reset(Reset), 
		.oLed(oLed),
		.oLCD_Enabled(oLCD_Enabled),
		.oLCD_RegisterSelect(oLCD_RegisterSelect),
		.oLCD_StrataFlashControl(oLCD_StrataFlashControl),
		.oLCD_ReadWrite(oLCD_ReadWrite),
		.oLCD_Data(oLCD_Data),
		.oVGA_RED(oVGA_RED),
		.oVGA_GREEN(oVGA_GREEN),
		.oVGA_BLUE(oVGA_BLUE),
		.oVGA_HSYNC(oVGA_HSYNC),
		.oVGA_VSYNC(oVGA_VSYNC)
	);
	
	always
	begin
		#5  Clock =  ! Clock;

	end

	initial begin
		// Initialize Inputs
		Clock = 0;
		Reset = 0;

		// Wait 100 ns for global reset to finish
		#100;
		Reset = 1;
		#50
		Reset = 0;
        
		// Add stimulus here

	end
      
endmodule


