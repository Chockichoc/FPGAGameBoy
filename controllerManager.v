module controllerManager(

input clock,


input [7:0] Di_mmu,
input wr_mmu,
input rd_mmu,
input cs_mmu,
output reg [7:0] Do_mmu,

input ctrlClk,
input data,
output reg latch = 1'b0

);

reg [15:0] buttonsState = 16'b0;
reg [4:0] count = 4'b0;

always @(negedge ctrlClk)
	begin
	
		if (count == 0) begin
			
			latch <= 1'b1;
			count <= count + 1'b1;
				
		end
		else begin
		
			latch <= 1'b0;
			buttonsState[count - 1'b1] <= data;
			
			if (count == 16) 
				count <= 5'b0;
			else
				count <= count + 1'b1;
		
		end
	end


always @(posedge clock) begin
   if(cs_mmu && rd_mmu) begin
         case(Do_mmu[5:4])
            2'b00:   Do_mmu <= {Do_mmu[7:4], 4'b0};
            2'b10:   Do_mmu <= {Do_mmu[7:4], buttonsState[5], buttonsState[4], buttonsState[6], buttonsState[7]};
            2'b01:   Do_mmu <= {Do_mmu[7:4], buttonsState[3], buttonsState[2], buttonsState[0], buttonsState[8]};
            2'b11:   Do_mmu <= {Do_mmu[7:4], 4'b0};
         endcase
      end
   if(cs_mmu && wr_mmu) 
      Do_mmu[7:4] <= Di_mmu[7:4];
   
   end

endmodule

