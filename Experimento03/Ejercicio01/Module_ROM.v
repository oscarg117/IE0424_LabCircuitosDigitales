`timescale 1ns/1ps
`include "Defintions.v"

`define LOOP1 8'd10
`define LOOP2 8'd7
module ROM
       (
         input wire [15:0] iAddress,
         output reg [27:0] oInstruction
       );
always @ (iAddress)
  begin
    case (iAddress)

      0 : oInstruction = { `NOP, 24'd4000 };
      1 : oInstruction = { `STO, `R7 , 16'b1111 };
      2 : oInstruction = { `STO, `R3 , 16'd4 };
      3 : oInstruction = { `STO, `R1 , 16'd1 };
      4 : oInstruction = { `CALL , 8'd7 , 16'b0 };
      5 : oInstruction = { `ADD, `R3 , `R3 , `R1 };
      6 : oInstruction = { `JMP, 8'd9 , 16'b0 };
      7 : oInstruction = { `SHL , `R4 , `R7 , `R3 };
      8 : oInstruction = { `RET, 24'b0 };
      9 : oInstruction = { `ADD, `R3 , `R3 , `R1 };

      default:
        oInstruction = {`NOP, 24'b0 }; //NOP
    endcase
  end
endmodule
