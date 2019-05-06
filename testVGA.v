module HVSync(pixelClk, HSync, VSync, R, G, B, LY, LineBuffer0, LineBuffer1, updateBufferSignal);

input pixelClk;
output HSync;
output VSync;
output [3:0] R;
output [3:0] G;
output [3:0] B;
input  [7:0] LY;
input [159:0] LineBuffer0;
input [159:0] LineBuffer1;

input updateBufferSignal;

reg [7:0] oldLY = 8'b0;
reg [9:0] HCount = 10'b0;
reg [9:0] VCount = 10'b0;

wire HCountMax = (HCount == 799); 
wire VCountMax = (VCount == 524);

wire [159:0] bufferOutput0;
wire [159:0] bufferOutput1;

reg wr_buffer = 1'b0;

parameter hori_line  = 800;                           
parameter hori_back  = 144;
parameter hori_front = 16;
parameter vert_line  = 525;
parameter vert_back  = 34;
parameter vert_front = 11;
parameter H_sync_cycle = 96;
parameter V_sync_cycle = 2;
parameter H_BLANK = hori_front+H_sync_cycle ;

videoRam ppuBuffer0(pixelClk,
	LineBuffer0,
	YValid,
	oldLY,
	wr_buffer,
	bufferOutput0);

videoRam ppuBuffer1(pixelClk,
	LineBuffer1,
	YValid,
	oldLY,
	wr_buffer,
	bufferOutput1);


always @(negedge pixelClk) begin
	
	if(HCount == hori_line - 1'b1)
		begin
			HCount <= 10'd0;
			
			if(VCount == vert_line - 1'b1)
				VCount <= 10'd0;
			else
				VCount <= VCount + 1'b1;
		
		end
	else
		HCount <= HCount + 1'b1;

end



assign HSync = (HCount < H_sync_cycle) ? 1'b0 : 1'b1;
assign VSync = (VCount < V_sync_cycle) ? 1'b0 : 1'b1;

reg [1:0] saveRoutineCounter = 2'b00;

always @(posedge pixelClk) begin

   if((oldLY != LY && updateBufferSignal == 1'b1) || saveRoutineCounter != 2'b00) begin
      if (saveRoutineCounter == 2'b00) begin
         oldLY <= LY;
         saveRoutineCounter <= saveRoutineCounter + 1'b1;
      end
      if (saveRoutineCounter == 2'b01) begin
         saveRoutineCounter <= saveRoutineCounter + 1'b1;
      end
      if (saveRoutineCounter == 2'b10) begin
         wr_buffer <= 1'b1;  
         saveRoutineCounter <= saveRoutineCounter + 1'b1;
      end
      if (saveRoutineCounter == 2'b11) begin
         wr_buffer <= 1'b0;  
         saveRoutineCounter <= 2'b00;
      end
   end

end

wire [9:0] XValid;
wire [9:0] YValid;

assign XValid = HCount - hori_back;
assign YValid = VCount - vert_back;

assign R = (YValid >= 10'd0 && YValid < 10'd145 && XValid >= 10'd0 && XValid < 10'd160) ? 
   ({bufferOutput1[XValid], bufferOutput0[XValid]} == 2'b00 ? 4'b1101 : 
   ({bufferOutput1[XValid], bufferOutput0[XValid]} == 2'b01 ? 4'b1000 : 
   ({bufferOutput1[XValid], bufferOutput0[XValid]} == 2'b10 ? 4'b0011 : 
   4'b0001))) : 4'b0000;
   
assign G = (YValid >= 10'd0 && YValid < 10'd145 && XValid >= 10'd0 && XValid < 10'd160) ? 
   ({bufferOutput1[XValid], bufferOutput0[XValid]} == 2'b00 ? 4'b1111 : 
   ({bufferOutput1[XValid], bufferOutput0[XValid]} == 2'b01 ? 4'b1011 : 
   ({bufferOutput1[XValid], bufferOutput0[XValid]} == 2'b10 ? 4'b0110 : 
   4'b0001))) : 4'b0000;
   
assign B = (YValid >= 10'd0 && YValid < 10'd145 && XValid >= 10'd0 && XValid < 10'd160) ? 
   ({bufferOutput1[XValid], bufferOutput0[XValid]} == 2'b00 ? 4'b1100 : 
   ({bufferOutput1[XValid], bufferOutput0[XValid]} == 2'b01 ? 4'b0111 : 
   ({bufferOutput1[XValid], bufferOutput0[XValid]} == 2'b10 ? 4'b0101 : 
   4'b0010))) : 4'b0000;



endmodule