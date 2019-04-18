module oam(

input dmaTransfert, 

input    [15:0]   A_ppu,
input    [7:0]    Di_ppu,
output   [7:0]    Do_ppu,
input             wr_ppu,
input             rd_ppu,  

input    [15:0]   A_dma,
input    [7:0]    Di_dma,
output   [7:0]    Do_dma,
input             wr_dma,
input             rd_dma, 

output   [15:0]   A_oam,
input    [7:0]    Di_oam,
output   [7:0]    Do_oam,
output            wr_oam,
output            rd_oam

);


assign A_oam = dmaTransfert ? A_dma : A_ppu;
assign Do_oam = dmaTransfert ? Di_dma : Di_ppu;
assign wr_oam = dmaTransfert ? wr_dma : wr_ppu;
assign rd_oam = dmaTransfert ? rd_dma : rd_ppu;

assign Do_ppu = dmaTransfert ? 8'h00 : Di_oam;
assign Do_dma = dmaTransfert ? Di_oam : 8'h00;




endmodule   