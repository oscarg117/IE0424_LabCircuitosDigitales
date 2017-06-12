`timescale 1ns / 1ps
`include "Defintions.v"

`define LOOP1 8'd10
`define LOOP2 8'd7
module ROM
       (
         input wire[15: 0] iAddress,
         output reg [27: 0] oInstruction
       );
always @ ( iAddress )
  begin
    case (iAddress)
      0: oInstruction = { `NOP, 24'd4000 };
      1: oInstruction = { `STO, `R7, 16'b1111 };
      2: oInstruction = { `STO, `R3, 16'd4 };
      3: oInstruction = { `STO, `R1, 16'd1 };
      4: oInstruction = { `LCD, `R3, `H, `R1 };
      5: oInstruction = { `LCD, `R3, `O, `R1 };
      6: oInstruction = { `LCD, `R3, `L, `R1 };
      7: oInstruction = { `LCD, `R3, `A, `R1 };
      8: oInstruction = { `LCD, `R3, `SPC, `R1 };
      9: oInstruction = { `LCD, `R3, `M, `R1 };
      10: oInstruction = { `LCD, `R3, `U, `R1 };
      11: oInstruction = { `LCD, `R3, `N, `R1 };
      12: oInstruction = { `LCD, `R3, `D, `R1 };
      13: oInstruction = { `LCD, `R3, `O, `R1 };
      14: oInstruction = { `LCD, `R3, `EXC, `R1 };
      15: oInstruction = { `NOP, 24'd4000 };
      16: oInstruction = { `JMP, 8'd15, 16'b0	};
      default:
        oInstruction = { `NOP, 24'b0	};                //NOP
    endcase
  end


endmodule
