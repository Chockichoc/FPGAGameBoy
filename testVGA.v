module HVSync(pixelClk, HSync, VSync, R, G, B, LY, LineBuffer0, LineBuffer1, LineBuffer2, LineBuffer3, updateBufferSignal);

input pixelClk;
output HSync;
output VSync;
output [3:0] R;
output [3:0] G;
output [3:0] B;
input  [7:0] LY;
input [159:0] LineBuffer0;
input [159:0] LineBuffer1;
input [159:0] LineBuffer2;
input [159:0] LineBuffer3;
input updateBufferSignal;

reg [7:0] oldLY = 8'b0;
reg [9:0] HCount = 10'b0;
reg [9:0] VCount = 10'b0;

//wire HSync = 1'b1;
//wire VSync = 1'b1;
//reg [3:0] R = 4'b0000;
//reg [3:0] G = 4'b0000;
//reg [3:0] B = 4'b0000;

wire HCountMax = (HCount == 799); 
wire VCountMax = (VCount == 524);

wire [159:0] bufferOutput0;
wire [159:0] bufferOutput1;
wire [159:0] bufferOutput2;
wire [159:0] bufferOutput3;

reg wr_buffer;

videoRam ppuBuffer0(pixelClk,
	LineBuffer0,
	VCount,
	LY,
	wr_buffer,
	bufferOutput0);

videoRam ppuBuffer1(pixelClk,
	LineBuffer1,
	VCount,
	LY,
	wr_buffer,
	bufferOutput1);

videoRam ppuBuffer2(pixelClk,
	LineBuffer2,
	VCount,
	LY,
	wr_buffer,
	bufferOutput2);
   
videoRam ppuBuffer3(pixelClk,
	LineBuffer3,
	VCount,
	LY,
	wr_buffer,
	bufferOutput3);

always @(posedge pixelClk) begin
	
	if(HCountMax) begin
		HCount <= 10'd0;

	end
	else begin
		HCount <= HCount + 1'b1;


	end

end

always @(negedge HCountMax) begin
	
	if(VCountMax)
		VCount <= 10'd0;
	else 
		VCount <= VCount + 1'b1;
	
		
end

assign HSync = (HCount >= 10'd655 && HCount <= 10'd750) ? 1'b0 : 1'b1;
assign VSync = (VCount >= 10'd489 && VCount <= 10'd491) ? 1'b0 : 1'b1;


//always @(posedge pixelClk) begin
//
//	if(HCount >= 10'd655 && HCount <= 10'd750)
//		HSync <= 1'b0;
//	else
//		HSync <= 1'b1;
//	
//end
//
//always @(posedge HCount[0]) begin
//
//	if(VCount >= 10'd489 && VCount <= 10'd491)
//		VSync <= 1'b0;
//	else
//		VSync <= 1'b1;
//      
//end

reg  saveRoutineCounter = 1'b0;

always @(posedge pixelClk) begin

   if((LY != oldLY && updateBufferSignal == 1'b1) ||saveRoutineCounter > 3'd0) begin
      if (saveRoutineCounter == 1'b0) begin
         wr_buffer <= 1'b1;
         saveRoutineCounter <= saveRoutineCounter + 1'b1;
      end
         
      if (saveRoutineCounter == 1'b1) begin
         wr_buffer <= 1'b0;  
         saveRoutineCounter <= 1'b0;
         oldLY <= LY;
      end
   end

end

assign R = (VCount < 10'd144 && HCount < 10'd160) ? {bufferOutput0[HCount], bufferOutput1[HCount], bufferOutput2[HCount], bufferOutput3[HCount]} : 4'b0000;
assign G = (VCount < 10'd144 && HCount < 10'd160) ? {bufferOutput0[HCount], bufferOutput1[HCount], bufferOutput2[HCount], bufferOutput3[HCount]} : 4'b0000;
assign B = (VCount < 10'd144 && HCount < 10'd160) ? {bufferOutput0[HCount], bufferOutput1[HCount], bufferOutput2[HCount], bufferOutput3[HCount]} : 4'b0000;



//always @(posedge pixelClk) begin
//
//    if(VCount < 10'd144 && HCount < 10'd160) begin
//      R <= {bufferOutput0[HCount], bufferOutput1[HCount], bufferOutput2[HCount], bufferOutput3[HCount]};
//      G <= {bufferOutput0[HCount], bufferOutput1[HCount], bufferOutput2[HCount], bufferOutput3[HCount]};
//      B <= {bufferOutput0[HCount], bufferOutput1[HCount], bufferOutput2[HCount], bufferOutput3[HCount]};
//
//	end
//	else begin
//		R <= 4'b0000;
//		G <= 4'b0000;
//		B <= 4'b0000;
//	end
//
//
//end
endmodule