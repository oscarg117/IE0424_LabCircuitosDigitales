`timescale 1ns / 1ps
`include "Defintions.v"

`define LOOP1 8'd9
`define LOOP2 8'd6

`define SaveWhite 8'd50
`define WhiteWhite 8'd52
`define WhiteBlack 8'd57

`define `SUB_VGA 8'd17

module ROM
       (
         input wire[15: 0] iAddress,
         output reg [27: 0] oInstruction
       );
always @ ( iAddress )
  begin
    case (iAddress)

      // 0: oInstruction = { `NOP, 24'd4000 };
      // 1: oInstruction = { `STO, `R7, 16'd1	};
      // 2: oInstruction = { `STO, `R6, 16'd1	};
      // 3: oInstruction = { `STO, `R3, 16'd1	};
      // 4: oInstruction = { `STO, `R4, 16'd45000	}; //1000
      // 5: oInstruction = { `STO, `R5, 16'd0	};  //j
      // //LOOP2:
      // 6: oInstruction = { `LED, 8'b0, `R7, 8'b0	};
      // 7: oInstruction = { `STO, `R1, 16'h0	};
      // 8: oInstruction = { `STO, `R2, 16'd65000	}; //65000
      // //LOOP1:
      // 9: oInstruction = { `ADD, `R1, `R1, `R3	};
      // 10: oInstruction = { `BLE, `LOOP1, `R1, `R2	};
      //
      // 11: oInstruction = { `ADD, `R5, `R5, `R3	};
      // 12: oInstruction = { `BLE, `LOOP2, `R5, `R4	};
      // 13: oInstruction = { `NOP, 24'd4000	};
      // 14: oInstruction = { `ADD, `R7, `R7, `R3	};
      // //	14: oInstruction = { `SMUL,	`R7,`R7,`R6		};
      // 15: oInstruction = { `JMP, 8'd3, 16'b0	};

/****************************************************************/
/****************************************************************/

0: oInstruction = { `NOP , 24'd4000 };
1: oInstruction = { `STO , `R1, 16'd0 };	//R1 => Col
2: oInstruction = { `STO , `R2, 16'd0 };	//R2 => Fil
3: oInstruction = { `STO , `R7, 16'd32 };	//R7 => ADD
4: oInstruction = { `STO , `R6, 16'd255 };	//EndH
5: oInstruction = { `STO , `R0, 16'd383 };	//EndV
6: oInstruction = { `STO , `R5, 16'd192};
7: oInstruction = { `STO , `R8, 16'd192};

8: oInstruction = { `STO , `R4, 16'd31 };	//R4 => Límite Fil
9: oInstruction = { `CALL , 8'd100, 16'd0 };
10: oInstruction = { `ADD , `R4, `R4, `R7 };
11: oInstruction = { `CALL , 8'd25, 16'd0 };
12: oInstruction = { `BGE , 8'd60, `R4, `R0 };
13: oInstruction = { `ADD , `R4, `R4, `R7 };
14: oInstruction = { `JMP , 8'd9, 16'b0 };

25: oInstruction = { `STO , `R1, 16'd0 };	//R1 => Col
26: oInstruction = { `STO , `R3, 16'd31 };	//R3 => Límite Col
27: oInstruction = { `VGA , `COLOR_MAGENTA, `R1, `R2 };
28: oInstruction = { `INC , `R1, `R1, 8'd0 };
29: oInstruction = { `NOP , 24'd4000 };
30: oInstruction = { `BLE , 8'd27, `R1, `R3 };
31: oInstruction = { `ADD , `R3, `R3, `R5 };
32: oInstruction = { `VGA , `COLOR_CYAN, `R1, `R2 };
33: oInstruction = { `INC , `R1, `R1, 8'd0 };
34: oInstruction = { `NOP , 24'd4000 };
35: oInstruction = { `BLE , 8'd32, `R1, `R3 };
36: oInstruction = { `VGA , `COLOR_MAGENTA, `R1, `R2 };
37: oInstruction = { `INC , `R1, `R1, 8'd0 };
38: oInstruction = { `NOP , 24'd4000 };
39: oInstruction = { `BLE , 8'd36, `R1, `R6 };
40: oInstruction = { `INC , `R2, `R2, 8'd0 };
41: oInstruction = { `NOP , 24'd4000 };
42: oInstruction = { `BLE , 8'd25, `R2, `R4 };
43: oInstruction = { `RET , 24'd0 };


60: oInstruction = { `STO , `R8, 16'd2000 };	//R1 => Col
61: oInstruction = { `STO , `R9, 16'd2000 };	//R3 => Límite Col
62: oInstruction = { `STO , `R11, 16'd0 };	//R1 => Col
63: oInstruction = { `STO , `R10, 16'd0 };	//R3 => Límite Col
64: oInstruction = { `INC , `R10, `R10, 8'd0 };
65: oInstruction = { `BLE , 8'd64, `R10, `R8 }; //**********
66: oInstruction = { `INC , `R11, `R11, 8'd0 };
67: oInstruction = { `BLE , 8'd63, `R11, `R9 }; //**********
68: oInstruction = { `NOP , 8'd9, 16'b0 };

69: oInstruction = { `NOP , 24'd4000 };
70: oInstruction = { `STO , `R1, 16'd0 };	//R1 => Col
71: oInstruction = { `STO , `R2, 16'd0 };	//R2 => Fil
72: oInstruction = { `STO , `R7, 16'd32 };	//R7 => ADD
73: oInstruction = { `STO , `R6, 16'd255 };	//EndH
74: oInstruction = { `STO , `R0, 16'd383 };	//EndV
75: oInstruction = { `STO , `R5, 16'd192};
76: oInstruction = { `STO , `R8, 16'd192};

77: oInstruction = { `STO , `R4, 16'd31 };	//R4 => Límite Fil
78: oInstruction = { `CALL , 8'd25, 16'd0 };
79: oInstruction = { `ADD , `R4, `R4, `R7 };
80: oInstruction = { `CALL , 8'd100, 16'd0 };
81: oInstruction = { `BGE , 8'd84, `R4, `R0 };
82: oInstruction = { `ADD , `R4, `R4, `R7 };
83: oInstruction = { `JMP , 8'd78, 16'b0 };

84: oInstruction = { `STO , `R8, 16'd2000 };	//R1 => Col
85: oInstruction = { `STO , `R9, 16'd2000 };	//R3 => Límite Col
86: oInstruction = { `STO , `R11, 16'd0 };	//R1 => Col
87: oInstruction = { `STO , `R10, 16'd0 };	//R3 => Límite Col
88: oInstruction = { `INC , `R10, `R10, 8'd0 };
89: oInstruction = { `BLE , 8'd88, `R10, `R8 }; //**********
90: oInstruction = { `INC , `R11, `R11, 8'd0 };
91: oInstruction = { `BLE , 8'd87, `R11, `R9 }; //**********
92: oInstruction = { `JMP , 8'd0, 16'b0 };

100: oInstruction = { `STO , `R1, 16'd0 };	//R1 => Col
101: oInstruction = { `STO , `R3, 16'd31 };	//R3 => Límite Col
102: oInstruction = { `VGA , `COLOR_RED, `R1, `R2 };
103: oInstruction = { `INC , `R1, `R1, 8'd0 };
104: oInstruction = { `NOP , 24'd4000 };
105: oInstruction = { `BLE , 8'd102, `R1, `R3 };
106: oInstruction = { `ADD , `R3, `R3, `R5 };
107: oInstruction = { `VGA , `COLOR_CYAN, `R1, `R2 };
108: oInstruction = { `INC , `R1, `R1, 8'd0 };
109: oInstruction = { `NOP , 24'd4000 };
110: oInstruction = { `BLE , 8'd107, `R1, `R3 };
111: oInstruction = { `VGA , `COLOR_RED, `R1, `R2 };
112: oInstruction = { `INC , `R1, `R1, 8'd0 };
113: oInstruction = { `NOP , 24'd4000 };
114: oInstruction = { `BLE , 8'd111, `R1, `R6 };
115: oInstruction = { `INC , `R2, `R2, 8'd0 };
116: oInstruction = { `NOP , 24'd4000 };
117: oInstruction = { `BLE , 8'd100, `R2, `R4 };
118: oInstruction = { `RET , 24'd0 };

/****************************************************************/
/****************************************************************/

      default:
        oInstruction = { `NOP , 24'd4000	};		//NOP
    endcase
  end

endmodule
