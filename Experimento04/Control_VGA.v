`timescale 1ns / 1ps


module VGA_CONTROLLER
(
input wire [1:0] Clock_25,
input wire Reset,
output wire oHS, oVS, oR, oG, oB     //, oVmemAddress
);

wire [9:0] wCurrentColumn, wCurrentRow;

UPCOUNTER_POSEDGE #(10) CurrentCol
(
	.Clock(  Clock_25[1]  ), 
	.Reset( (wCurrentColumn == 799) || Reset ),
	.Initial( 16'b0 ),
	.Enable(  1'b1  ),
	.Q( wCurrentColumn )
);

UPCOUNTER_POSEDGE # (10) CurrentRow
(
	.Clock(   Clock_25[1]  ), 
	.Reset( (wCurrentRow > 520) || Reset ),
	.Initial( 16'b0 ),
	.Enable( wCurrentColumn == 799),
	.Q( wCurrentRow )
);

assign oHS = (wCurrentColumn >= 656 && wCurrentColumn <= 752) ? 0 : 1;
assign oVS = (wCurrentRow >= 490 && wCurrentRow < 492) ? 0 : 1;
assign oR = 1;
assign oG = 0;
assign oB = 1;

endmodule 

/* 
module VGA_CONTROLLER
(
input wire Clock,
input wire Reset,
output wire [3:0] oVgaRed,oVgaGreen,oVgaBlue,
output wire oVgaVsync,  //Polarity of horizontal sync pulse is negative.
output wire oVgaHsync,  //Polarity of vertical sync pulse is negative.
output wire [15:0]  oRow,oCol
 
);
 
wire wHSync,wVSync,wPolarity_V,wPolarity_H;
wire wClockVga,wHCountEnd,wVCountEnd;
wire [15:0] wHCount,wVCount;
wire wPllLocked,wPsDone;
 
 
`ifdef XILINX_IP
DCM_SP
#
(
.CLKFX_MULTIPLY(2), //Values range from 2..32
.CLKFX_DIVIDE(CLK)        //Values range from 1..32
 
)
ClockVga
(
.CLKIN(Clock),          //32Mhz
.CLKFB(wClockVga),  //Feed back
.RST( Reset ),          //Global reset
.PSEN(1'b0),            //Disable variable phase shift. Ignore inputs to phase shifter
.LOCKED(wPllLocked),    //Use this signal to make sure PLL is locked
.PSDONE(wPsDone),       //I am not really using this one
.CLKFX(wClockVga)       //FCLKFX = FCLKIN * CLKFX_MULTIPLY / CLKFX_DIVIDE
 
);
`else
    assign wClockVga = Clock;
    assign wPllLocked = 1'b1;
`endif


assign wHCountEnd = (wHCount == 639)? 1'b1 : 1'b0;
assign wVCountEnd = (wVCount == 479)  ? 1'b1 : 1'b0;
 
UPCOUNTER_POSEDGE # (.SIZE(16)) HCOUNT
(
.Clock(wClockVga),
.Reset(Reset | ~wPllLocked | wHCountEnd),
.Initial(16'b0),
.Enable(1'b1),
.Q(wHCount)
);
 
UPCOUNTER_POSEDGE # (.SIZE(16)) VCOUNT
(
.Clock(wClockVga),
.Reset(Reset | ~wPllLocked | wVCountEnd ),
.Initial( 16'b0 ),
.Enable(wHCountEnd),
.Q(wVCount)
);
 
assign wVSync =
(
    wVCount >= 656 &&
    wVCount <= 752
) ? 1'b1 : 1'b0;
 
assign wHSync =
(
    wHCount >= 490 &&
    wHCount <= 492
) ? 1'b1 : 1'b0;
 
 
assign oVgaVsync = (wPolarity_V == 1'b1) ? wVSync : ~wVSync ;
assign oVgaHsync = (wPolarity_H == 1'b1) ? wHSync : ~wHSync ;
 
 
 
wire[3:0] wColorR, wColorG, wColorB;
assign wColorR = (wHCount < (640/2)) ? 4'b1111 : 4'b0000;
assign wColorG = (wVCount < (480/2)) ? 4'b1111 : 4'b0000;
assign wColorB = (wHCount >= (640/2) && wVCount < (640/2)) ?  4'b1111: 4'b0000;
 
assign {oVgaRed,oVgaGreen,oVgaBlue} = (wHCount < 640 && wVCount < 480) ?
 {wColorR,wColorG,wColorB} :    //display color
 {4'b1111,4'b0,4'b0};           //black
 
assign oCol = wHCount;
assign oRow = wVCount;
 
endmodule
*/