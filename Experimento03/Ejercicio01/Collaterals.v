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


//----------------------------------------------------

module ARRAY_MULT_GEN # ( parameter SIZE=16 )
(
  input wire [SIZE-1:0] iMulA,    //Multiplicando 1
  input wire [SIZE-1:0] iMulB,    //Multiplicando 2
  output wire [(2*SIZE)-1:0] oMulR    //Resultado
);
//Cableado intermedio entre sumadores y resultado
wire [SIZE-1:0] wR [SIZE-1:0];   //Cable resultado intermedio sumadores
wire [SIZE-1:0] wC [SIZE-1:0];   //Cable acarreos intermedios sumadores


parameter MAX_COLS = SIZE-1;
parameter MAX_ROWS = SIZE-2;

//----------------------------------------------------

assign oMulR[0] = iMulA[0] & iMulB[0];
assign wR[0][MAX_COLS] = 1'b0;

//----------------------------------------------------
//El último sumador tiene el resultado de los 2 MSB del producto
FULL_ADDER fa_final
(
  .iA(iMulA[SIZE-1] & iMulB[SIZE-1]),
  .iB(wR[MAX_ROWS][MAX_COLS]),
  .iC(wC[MAX_ROWS][MAX_COLS]),
  .oR(oMulR[2*MAX_COLS]),
  .oC(oMulR[(2*SIZE) - 1])
);

//

genvar  CurrentRow, CurrentCol;
generate

//Primera fila recibe 0 como suma anterior
for (CurrentCol = 0; CurrentCol < MAX_COLS; CurrentCol = CurrentCol + 1)
  begin : NIVEL_0
    assign wR[0][CurrentCol] = iMulA[CurrentCol + 1] & iMulB[0];
  end

//----------------------------------------------------

//El acarreo de entrada de la columna del LSB es siempre 0 y la suma va directo
//al resultado final
for (CurrentRow = 0; CurrentRow < MAX_ROWS - 1; CurrentRow = CurrentRow + 1)
  begin : COL_0
    assign wC[CurrentRow][0] = 0; //Acarreo 0

    FULL_ADDER fa_col0
    (
      .iA(iMulA[0] & iMulB[CurrentRow + 1]),
      .iB(wR[CurrentRow][0]),
      .iC(wC[CurrentRow][0]),
      .oR(oMulR[CurrentRow + 1]),
      .oC(wC[CurrentRow][1])
    );

  end


//----------------------------------------------------

//

for (CurrentRow = 0; CurrentRow < MAX_ROWS; CurrentRow = CurrentRow + 1)
  begin : ULTIMA_COL

    FULL_ADDER fa_ulcol
    (
      .iA(iMulA[SIZE-1] & iMulB[CurrentRow + 1]),
      .iB(wR[CurrentRow][SIZE-1]),
      .iC(wC[CurrentRow][SIZE-1]),
      .oR(wR[CurrentRow + 1][SIZE-2]),
      .oC(wR[CurrentRow + 1][SIZE-1])
    );

  end

  for (CurrentCol = 1; CurrentCol < MAX_COLS; CurrentCol = CurrentCol + 1)
    begin : COL_INTERM
    for (CurrentRow = 1; CurrentRow <= MAX_ROWS; CurrentRow = CurrentRow + 1)
      begin : FIL_INTERM
        if (CurrentRow < MAX_ROWS) begin

          FULL_ADDER fa_interm_NUR
          (
            .iA(iMulA[CurrentCol] & iMulB[CurrentRow + 1]),
            .iB(wR[CurrentRow][CurrentCol]),
            .iC(wC[CurrentRow][CurrentCol]),
            .oR(wR[CurrentRow + 1][CurrentCol - 1]),
            .oC(wC[CurrentRow][CurrentCol + 1])
          );

        end else begin

          FULL_ADDER fa_interm_UR
          (
            .iA(iMulA[CurrentCol] & iMulB[SIZE-1]),
            .iB(wR[CurrentRow][CurrentCol]),
            .iC(wC[CurrentRow][CurrentCol]),
            .oR(oMulR[CurrentCol + MAX_COLS]),
            .oC(wR[CurrentRow][CurrentCol + 1])
          );

        end

      end

    end

endgenerate

endmodule // ARRAY_MULT
//----------------------------------------------------
//----------------------------------------------------


//----------------------------------------------------------------------
