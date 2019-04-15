module ppuInternalMMU(

   input    [15:0]   A_mmu,
   output   [7:0]    Do_mmu,
   input    [7:0]    Di_mmu,
   input             wr_mmu,
   input             rd_mmu,

   output   [15:0]   A_vram,
   output   [7:0]    Do_vram,
   input    [7:0]    Di_vram,
   output            cs_vram,
   output            wr_vram,
   output            rd_vram,
   
   output   [15:0]   A_oam,
   output   [7:0]    Do_oam,
   input    [7:0]    Di_oam,
   output            cs_oam, 
   output            wr_oam,
   output            rd_oam,

   input   [7:0] LCDC,
   input   [7:0] STAT,
   input   [7:0] SCY ,
   input   [7:0] SCX ,
   input   [7:0] LY  ,
   input   [7:0] LYC ,
   input   [7:0] DMA ,
   input   [7:0] BGP ,
   input   [7:0] OBP0,
   input   [7:0] OBP1,
   input   [7:0] WY  ,
   input   [7:0] WX    
   
);

   
   assign A_vram = A_mmu - 16'h8000;
   assign A_oam = A_mmu - 16'hFE00;

   assign wr_vram =   cs_vram ? wr_mmu : 1'b0;
   assign wr_oam =  cs_oam ? wr_mmu : 1'b0;

   assign rd_vram =   cs_vram ? rd_mmu : 1'b0;
   assign rd_oam =  cs_oam ? rd_mmu : 1'b0;

   assign cs_vram = A_mmu >= 16'h8000 && A_mmu < 16'hA000;
   assign cs_oam = A_mmu >= 16'hFE00 && A_mmu < 16'hFEA0;

   assign Do_mmu = cs_vram ? Di_vram : (cs_oam ? Di_oam : 
         A_mmu == 16'hFF40 ? LCDC :
         A_mmu == 16'hFF41 ? STAT :
         A_mmu == 16'hFF42 ? SCY  :
         A_mmu == 16'hFF43 ? SCX  :
         A_mmu == 16'hFF44 ? LY   :
         A_mmu == 16'hFF45 ? LYC  :
         A_mmu == 16'hFF46 ? DMA  :
         A_mmu == 16'hFF47 ? BGP  :
         A_mmu == 16'hFF48 ? OBP0 :
         A_mmu == 16'hFF49 ? OBP1 :
         A_mmu == 16'hFF4A ? WY   :
         A_mmu == 16'hFF4B ? WX   :
         8'b0);

   assign Do_vram = cs_vram ? Di_mmu : 8'b0;
   assign Do_oam = cs_oam ? Di_mmu : 8'b0;



endmodule