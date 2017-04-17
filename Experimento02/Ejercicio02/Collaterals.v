`timescale 1ns / 1ps
//------------------------------------------------
module UPCOUNTER_POSEDGE # (parameter SIZE=16)
(
input wire Clock, Reset,
input wire [SIZE-1:0] Initial,
input wire Enable,
output reg [SIZE-1:0] Q
);


  always @(posedge Clock )
  begin
      if (Reset)
        Q = Initial;
      else
		begin
		if (Enable)
			Q = Q + 1;

		end
  end

endmodule
//----------------------------------------------------
module FFD_POSEDGE_SYNCRONOUS_RESET # ( parameter SIZE=8 )
(
	input wire				Clock,
	input wire				Reset,
	input wire				Enable,
	input wire [SIZE-1:0]	D,
	output reg [SIZE-1:0]	Q
);


always @ (posedge Clock)
begin
	if ( Reset )
		Q <= 0;
	else
	begin
		if (Enable)
			Q <= D;
	end

end//always

endmodule
//----------------------------------------------------
module FULL_ADDER
(
  input wire  iA,   //Sumando 1
  input wire  iB,   //Sumando 2
  input wire  iC,   //Entrada acarreo anterior
  output wire oR,   //Resultado suma
  output wire oC    //Salida acarreo
);

assign {oC, oR} = iA + iB + iC;

endmodule // FULL_ADDER
//----------------------------------------------------
module ARRAY_MULT //# ( parameter SIZE=16 )
(
  input wire [15:0] iMulA,    //Multiplicando 1
  input wire [15:0] iMulB,    //Multiplicando 2
  output wire [15:0] oMulR   //Resultado
);
//Cableado intermedio entre sumadores y resultado
wire [2:0] wR_L0;   //Cable resultado sumadores nivel 0
wire [2:0] wR_L1;   //Cable resultado sumadores nivel 1
wire [3:0] wC_L0;   //Cable acarreo sumadores nivel 0
wire [3:0] wC_L1;   //Cable acarreo sumadores nivel 1
wire [2:0] wC_L2;   //Cable acarreo sumadores nivel 2



assign oMulR[0] = iMulA[0] & iMulB[0];

//----------------------------------------------------
//Nivel 0
FULL_ADDER fa_L0_0
(
  .iA(iMulA[0] & iMulB[1]),
  .iB(iMulA[1] & iMulB[0]),
  .iC(1'b0),
  .oR(oMulR[1]),
  .oC(wC_L0[0])
);
//
FULL_ADDER fa_L0_1
(
  .iA(iMulA[2] & iMulB[0]),
  .iB(iMulA[1] & iMulB[1]),
  .iC(wC_L0[0]),
  .oR(wR_L0[0]),
  .oC(wC_L0[1])
);
//
FULL_ADDER fa_L0_2
(
  .iA(iMulA[3] & iMulB[0]),
  .iB(iMulA[2] & iMulB[1]),
  .iC(wC_L0[1]),
  .oR(wR_L0[1]),
  .oC(wC_L0[2])
);
//
FULL_ADDER fa_L0_3
(
  .iA(1'b0),
  .iB(iMulA[3] & iMulB[1]),
  .iC(wC_L0[2]),
  .oR(wR_L0[2]),
  .oC(wC_L0[3])
);
//
//----------------------------------------------------
//Nivel 1
FULL_ADDER fa_L1_0
(
  .iA(wR_L0[0]),
  .iB(iMulA[0] & iMulB[2]),
  .iC(1'b0),
  .oR(oMulR[2]),
  .oC(wC_L1[0])
);
//
FULL_ADDER fa_L1_1
(
  .iA(wR_L0[1]),
  .iB(iMulA[1] & iMulB[2]),
  .iC(wC_L1[0]),
  .oR(wR_L1[0]),
  .oC(wC_L1[1])
);
//
FULL_ADDER fa_L1_2
(
  .iA(wR_L0[2]),
  .iB(iMulA[2] & iMulB[2]),
  .iC(wC_L1[1]),
  .oR(wR_L1[1]),
  .oC(wC_L1[2])
);
//
FULL_ADDER fa_L1_3
(
  .iA(iMulA[3] & iMulB[2]),
  .iB(wC_L0[3]),
  .iC(wC_L1[2]),
  .oR(wR_L1[2]),
  .oC(wC_L1[3])
);
//
//----------------------------------------------------
//Nivel 2
FULL_ADDER fa_L2_0
(
  .iA(wR_L1[0]),
  .iB(iMulA[0] & iMulB[3]),
  .iC(1'b0),
  .oR(oMulR[3]),
  .oC(wC_L2[0])
);
//
FULL_ADDER fa_L2_1
(
  .iA(wR_L1[1]),
  .iB(iMulA[1] & iMulB[3]),
  .iC(wC_L2[0]),
  .oR(oMulR[4]),
  .oC(wC_L2[1])
);
//
FULL_ADDER fa_L2_2
(
  .iA(wR_L1[2]),
  .iB(iMulA[2] & iMulB[3]),
  .iC(wC_L2[1]),
  .oR(oMulR[5]),
  .oC(wC_L2[2])
);
//
FULL_ADDER fa_L2_3
(
  .iA(wC_L1[3]),
  .iB(iMulA[3] & iMulB[3]),
  .iC(wC_L2[2]),
  .oR(oMulR[6]),
  .oC(oMulR[7])
);

//----------------------------------------------------
//Se asignan ceros a los MSB

assign oMulR[15:8] = 8'd0;

endmodule // ARRAY_MULT
//----------------------------------------------------



//----------------------------------------------------------------------
