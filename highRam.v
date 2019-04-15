module highRam(
	input 			[15:0] 	A_wsram,
	input 			[7:0] 	Di_wsram,
	output	reg 	[7:0]		Do_wsram,
	input							cs_wsram,
	input							wr_wsram,
	input							rd_wsram,
	input 						clock

);

reg [7:0] Datas [127:0];

always @(posedge clock) begin

	if(cs_wsram && rd_wsram) begin
	
		Do_wsram <= Datas[A_wsram];
	

	end	
	else if(cs_wsram && wr_wsram) begin
	
		Datas[A_wsram] <= Di_wsram;
		
	end
end


	
endmodule