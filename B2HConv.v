module B2HConv(inFromB, outToHex);

input [3:0] inFromB;
output [7:0] outToHex;

assign outToHex = inFromB == 4'b0000 ? 8'b11000000 :
						inFromB == 4'b0001 ? 8'b11111001 :
						inFromB == 4'b0010 ? 8'b10100100 :
						inFromB == 4'b0011 ? 8'b10110000 :
						inFromB == 4'b0100 ? 8'b10011001 :
						inFromB == 4'b0101 ? 8'b10010010 :
						inFromB == 4'b0110 ? 8'b10000010 :
						inFromB == 4'b0111 ? 8'b11111000 :
						inFromB == 4'b1000 ? 8'b10000000 :
						inFromB == 4'b1001 ? 8'b10010000 :
						inFromB == 4'b1010 ? 8'b10001000 :
						inFromB == 4'b1011 ? 8'b10000011 :
						inFromB == 4'b1100 ? 8'b11000110 :
						inFromB == 4'b1101 ? 8'b10100001 :
						inFromB == 4'b1110 ? 8'b10000110 :
													8'b10001110;



endmodule