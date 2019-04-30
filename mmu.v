module mmu(

	//Cpu 0000-FFFF
	input 	[15:0] 	A_cpu,
	output 	[7:0] 	Di_cpu,
	input 	[7:0] 	Do_cpu,
	input					wr_cpu,
	input					rd_cpu,
	
	//Cartridge 0000-7FFF & A000-BFFF
	output 	[15:0] 	A_crd,
	output 	[7:0] 	Di_crd,
	input		[7:0]		Do_crd,
	output				cs_crd,
	output				wr_crd,
	output				rd_crd,

   //PPU 8000-9FFF & FE00-FE9F & FF40-FF4B
	output 	[15:0] 	A_ppu,
	output 	[7:0] 	Di_ppu,
	input		[7:0]		Do_ppu,
	output				cs_ppu,
	output				wr_ppu,
	output				rd_ppu,
   
	//RAM C000-DFFF
	output 	[15:0] 	A_ram,
	output 	[7:0] 	Di_ram,
	input		[7:0]		Do_ram,
	output 				cs_ram,
	output				wr_ram,
	output				rd_ram,
   
   //Controller Manager FF00
   output 	[15:0] 	A_ctrlMgr,
	output 	[7:0] 	Di_ctrlMgr,
	input		[7:0]		Do_ctrlMgr,
	output				cs_ctrlMgr,
	output				wr_ctrlMgr,
	output				rd_ctrlMgr,
	
	//Working & Stack RAM FF01-FF40
	output 	[15:0] 	A_wsram,
	output 	[7:0] 	Di_wsram,
	input		[7:0]		Do_wsram,
	output				cs_wsram,
	output				wr_wsram,
	output				rd_wsram
	
);


assign A_crd = A_cpu;
assign A_ppu = A_cpu;
assign A_ram = A_cpu - 16'hC000;
assign A_wsram = A_cpu - 16'hFF00;

assign wr_crd =   cs_crd ? wr_cpu : 1'b0;
assign wr_ppu = cs_ppu ? wr_cpu : 1'b0;
assign wr_ram =   cs_ram ? wr_cpu : 1'b0;
assign wr_wsram = cs_wsram ? wr_cpu : 1'b0;
assign wr_ctrlMgr = cs_ctrlMgr ? wr_cpu : 1'b0;

assign rd_crd =   cs_crd ? rd_cpu : 1'b0;
assign rd_ppu = cs_ppu ? rd_cpu : 1'b0;
assign rd_ram =   cs_ram ? rd_cpu : 1'b0;
assign rd_wsram = cs_wsram ? rd_cpu : 1'b0;
assign rd_ctrlMgr = cs_ctrlMgr ? rd_cpu : 1'b0;

assign cs_crd = (A_cpu >= 16'h0000 && A_cpu < 16'h8000) || (A_cpu >= 16'hA000 && A_cpu < 16'hC000);
assign cs_ppu = (A_cpu >= 16'h8000 && A_cpu < 16'h9FFF) || (A_cpu >= 16'hFE00 && A_cpu < 16'hFEA0) || (A_cpu >= 16'hFF40 && A_cpu < 16'hFF4C);
assign cs_ram = (A_cpu >= 16'hC000 && A_cpu < 16'hE000);
assign cs_wsram = (A_cpu >= 16'hFF01 && A_cpu < 16'hFF40);
assign cs_ctrlMgr = A_cpu == 16'hFF00;

assign Di_cpu = cs_crd ? Do_crd : (cs_ppu ? Do_ppu : (cs_ram ? Do_ram : (cs_wsram ? Do_wsram : (cs_ctrlMgr ? Do_ctrlMgr : 8'b0 ))));

assign Di_crd = cs_crd ? Do_cpu : 8'b0;
assign Di_ppu = cs_ppu ? Do_cpu : 8'b0;
assign Di_ram = cs_ram ? Do_cpu : 8'b0;
assign Di_wsram = cs_wsram ? Do_cpu : 8'b0;
assign Di_ctrlMgr = cs_ctrlMgr ? Do_cpu : 8'b0;


endmodule