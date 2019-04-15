module RegName2HConv(inFromB, dot, outToHex);

input dot;
input [3:0] inFromB;
output [7:0] outToHex;

assign outToHex = inFromB == 4'b0000 ? {dot, 7'b0001000} ://A
						inFromB == 4'b0001 ? {dot, 7'b0001110} ://F
						inFromB == 4'b0010 ? {dot, 7'b0000011} ://B
						inFromB == 4'b0011 ? {dot, 7'b1000110} ://C
						inFromB == 4'b0100 ? {dot, 7'b0100001} ://D
						inFromB == 4'b0101 ? {dot, 7'b0000110} ://E
						inFromB == 4'b0110 ? {dot, 7'b0001001} ://H
						inFromB == 4'b0111 ? {dot, 7'b1000111} ://L
						inFromB == 4'b1000 ? {dot, 7'b0001100} ://P
						inFromB == 4'b1001 ? {dot, 7'b1111001} ://I
						inFromB == 4'b1010 ? {dot, 7'b0000000} ://8
						inFromB == 4'b1011 ? {dot, 7'b0010010} ://S
						inFromB == 4'b1100 ? {dot, 7'b1111000} :
						inFromB == 4'b1101 ? {dot, 7'b1010001} :
						inFromB == 4'b1110 ? {dot, 7'b1011000} :
													{dot, 7'b1001110} ;



endmodule