module cpuInternalMMU (

   //Cpu 0000-FFFF
	input 	[15:0] 	A_cpu,
	output 	[7:0] 	Do_cpu,
	input 	[7:0] 	Di_cpu,
	input					wr_cpu,
	input					rd_cpu,
	
	//MMU 0000-FF7F
	output 	[15:0] 	A_MMU,
	output 	[7:0] 	Do_MMU,
	input		[7:0]		Di_MMU,
	output				cs_MMU,
	output				wr_MMU,
	output				rd_MMU,

	//HRAM FF80-FFFF
	output 	[15:0] 	A_HRAM,
	output 	[7:0] 	Do_HRAM,
	input		[7:0]		Di_HRAM,
	output				cs_HRAM,
	output				wr_HRAM,
	output				rd_HRAM

);

assign A_MMU = A_cpu;
assign A_HRAM = A_cpu - 16'hFF80;

assign wr_MMU =   cs_MMU ? wr_cpu : 1'b0;
assign wr_HRAM =  cs_HRAM ? wr_cpu : 1'b0;

assign rd_MMU =   cs_MMU ? rd_cpu : 1'b0;
assign rd_HRAM =  cs_HRAM ? rd_cpu : 1'b0;

assign cs_MMU = A_cpu < 16'hFF80;
assign cs_HRAM = A_cpu >= 16'hFF80;

assign Do_cpu = cs_MMU ? Di_MMU : (cs_HRAM ? Di_HRAM : 8'b0);

assign Do_MMU = cs_MMU ? Di_cpu : 8'b0;
assign Do_HRAM = cs_HRAM ? Di_cpu : 8'b0;

endmodule