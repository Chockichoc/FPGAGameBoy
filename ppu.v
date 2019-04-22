module ppu (
   input clock,

   input          [15:0]   A_mmu,
   output         [7:0]    Do_mmu,
   input          [7:0]    Di_mmu,
   input                   cs_mmu,
   input                   wr_mmu,
   input                   rd_mmu,
   
   output         [15:0]   A_vramio,
   output         [7:0]    Do_vramio,
   input          [7:0]    Di_vramio,
   output                  wr_vramio,
   output                  rd_vramio,
   
   output         [15:0]   A_oamio,
   output         [7:0]    Do_oamio,
   input          [7:0]    Di_oamio,
   output                  wr_oamio,
   output                  rd_oamio,
   
   output reg IRQ,
   output [7:0] dmaAdress,
   
   input pixelClk,
   output  HSync,
   output  VSync,
   output  [3:0] R,
   output  [3:0] G,
   output  [3:0] B

);

   assign dmaAdress = DMA;

   HVSync HVSync0(pixelClk, HSync, VSync, R, G, B, LY, LineBuffer0, LineBuffer1, LineBuffer2, LineBuffer3);

   //wire [9:0] HCount;
   //wire [9:0] VCount;

   //assign pixColor = Buffer[HCount][VCount];
   
   // 1 Buffer per bit
   reg [159:0] LineBuffer0;
   reg [159:0] LineBuffer1;
   reg [159:0] LineBuffer2;
   reg [159:0] LineBuffer3;

   reg [8:0]  XCount = 9'b0;  

   reg   [15:0]   A_vram    = 16'h0000;
   reg   [7:0]    Do_vram   = 8'b0;
   wire  [7:0]    Di_vram;
   reg            wr_vram   = 1'b0;
   reg            rd_vram   = 1'b0;
   
   reg   [15:0]   A_oam    = 16'h0000;
   reg   [7:0]    Do_oam   = 8'b0;
   wire  [7:0]    Di_oam;
   reg            wr_oam   = 1'b0;
   reg            rd_oam   = 1'b0; 
   
   reg   [7:0]    LCDC  = 8'b0;
   reg   [7:0]    STAT  = 8'b0;
   reg   [7:0]    SCY   = 8'b0;
   reg   [7:0]    SCX   = 8'b0;
   reg   [7:0]    LY    = 8'b0;
   reg   [7:0]    LYC   = 8'b0;
   reg   [7:0]    DMA   = 8'b0;
   reg   [7:0]    BGP   = 8'b0;
   reg   [7:0]    OBP0  = 8'b0;
   reg   [7:0]    OBP1  = 8'b0;
   reg   [7:0]    WY    = 8'b0;
   reg   [7:0]    WX    = 8'b0;
   
   
   wire  [15:0]   A_mmuToVram;
   wire  [7:0]    Do_mmuToVram;
   wire  [7:0]    Di_mmuToVram;
   wire           cs_mmuToVram;
   wire           wr_mmuToVram;
   wire           rd_mmuToVram;
   
   wire  [15:0]   A_mmuToOam;
   wire  [7:0]    Do_mmuToOam;
   wire  [7:0]    Di_mmuToOam;
   wire           cs_mmuToOam;
   wire           wr_mmuToOam;
   wire           rd_mmuToOam;
   
//   wire  [15:0]   A_mmu1ToVram;
//   wire  [7:0]    Do_mmu1ToVram;
//   wire  [7:0]    Di_mmu1ToVram;
//   wire           cs_mmu1ToVram;
//   wire           wr_mmu1ToVram;
//   wire           rd_mmu1ToVram;
//   
//   wire  [15:0]   A_mmu1ToOam;
//   wire  [7:0]    Do_mmu1ToOam;
//   wire  [7:0]    Di_mmu1ToOam;
//   wire           cs_mmu1ToOam;
//   wire           wr_mmu1ToOam;
//   wire           rd_mmu1ToOam;

   ppuInternalMMU ppuInternalMMU0 (
      A_mmu,
      Do_mmu,
      Di_mmu,
      wr_mmu,
      rd_mmu,
      
      A_mmuToVram,
      Do_mmuToVram,
      Di_mmuToVram,
      cs_mmuToVram,
      wr_mmuToVram,
      rd_mmuToVram,
      
      A_mmuToOam,
      Do_mmuToOam,
      Di_mmuToOam,
      cs_mmuToOam,
      wr_mmuToOam,
      rd_mmuToOam,
       LCDC,
       STAT,
       SCY ,
       SCX ,
       LY  ,
       LYC ,
       DMA ,
       BGP ,
       OBP0,
       OBP1,
       WY  ,
       WX    
   );
   
//   ppuInternalMMU ppuInternalMMU1 (
//      A_ppu,
//      Di_ppu,
//      Do_ppu,
//      wr_ppu,
//      rd_ppu,
//      
//      A_mmu1ToVram,
//      Do_mmu1ToVram,
//      Di_mmu1ToVram,
//      cs_mmu1ToVram,
//      wr_mmu1ToVram,
//      rd_mmu1ToVram,
//      
//      A_mmu1ToOam,
//      Do_mmu1ToOam,
//      Di_mmu1ToOam,
//      cs_mmu1ToOam,
//      wr_mmu1ToOam,
//      rd_mmu1ToOam 
//   );
   
   assign Di_mmuToVram = STAT[1] & STAT[0] ? 8'hFF : Di_vramio;
   assign Di_mmuToOam  = ((STAT[1] & ~STAT[0]) | (STAT[1] & STAT[0])) ? 8'hFF : Di_oamio;
   
   assign Di_vram = STAT[1] & STAT[0] ? Di_vramio : 8'hFF;
   assign Di_oam  = ((STAT[1] & ~STAT[0]) | (STAT[1] & STAT[0])) ? Di_oamio : 8'hFF;

   
   assign A_vramio =   STAT[1] & STAT[0] ? A_vram    : A_mmuToVram;
   assign Do_vramio =  STAT[1] & STAT[0] ? Do_vram   : Do_mmuToVram;
   assign wr_vramio =  STAT[1] & STAT[0] ? wr_vram   : wr_mmuToVram;
   assign rd_vramio =  STAT[1] & STAT[0] ? rd_vram   : rd_mmuToVram;
   
   assign A_oamio =    ((STAT[1] & ~STAT[0]) | (STAT[1] & STAT[0])) ? A_oam    : A_mmuToOam;
   assign Do_oamio =   ((STAT[1] & ~STAT[0]) | (STAT[1] & STAT[0])) ? Do_oam   : Do_mmuToOam;
   assign wr_oamio =   ((STAT[1] & ~STAT[0]) | (STAT[1] & STAT[0])) ? wr_oam   : wr_mmuToOam;
   assign rd_oamio =   ((STAT[1] & ~STAT[0]) | (STAT[1] & STAT[0])) ? rd_oam   : rd_mmuToOam;
   
   
always @(posedge clock) begin

   if(cs_mmu && wr_mmu) begin
      case (A_mmu)
         16'hFF40:   LCDC        <= Di_mmu;   
         16'hFF41:   STAT[7:3]   <= Di_mmu[7:3];
         16'hFF42:   SCY         <= Di_mmu;
         16'hFF43:   SCX         <= Di_mmu;
         //16'hFF44:   LY          <= Di_mmu;
         16'hFF45:   LYC         <= Di_mmu;
         16'hFF46:   DMA         <= Di_mmu;
         16'hFF47:   BGP         <= Di_mmu;
         16'hFF48:   OBP0        <= Di_mmu;
         16'hFF49:   OBP1        <= Di_mmu;
         16'hFF4A:   WY          <= Di_mmu;
         16'hFF4B:   WX          <= Di_mmu;
      endcase
   end
   else
     DMA <= 8'b0;

end

reg [4:0] renderCount = 5'b0;
reg [4:0] xBGTileIndex = 5'b0;
reg [7:0] currentTileAddress = 8'b0;
integer i;

always @(posedge clock) begin
   if (LCDC[7]) begin
   if(LY < 8'd144) begin
      IRQ <= 1'b0;
      if(XCount < 9'd80 ) begin
         STAT[1:0] <= 2'd2;
      
      end
      
      if(XCount >= 9'd80 && XCount < 9'd252) begin
         STAT[1:0] <= 2'd3;
        
         if(xBGTileIndex < 5'd20) begin
               case(renderCount)
               
                  5'd0 : begin   renderCount <= renderCount + 1'b1;
                                 A_vram <= 16'h1800 + xBGTileIndex + 16'h0020 * LY[7:3];
                                 rd_vram <= 1'b1; end
                                 
                  5'd1 : begin   renderCount <= renderCount + 1'b1; end
            
                  5'd2 : begin   A_vram <= {4'b0000, Di_vram, LY[2:0], 1'b0};
                                 currentTileAddress <= Di_vram;
                                 renderCount <= renderCount + 1'b1; end
                                 
                  5'd3 : begin   renderCount <= renderCount + 1'b1; end
                                  
                  5'd4 : begin   for(i = 0; i < 8; i = i + 1) begin
                                   
                                   LineBuffer3[8 * xBGTileIndex + i] <= ~Di_vram[7-i]; 
                                   LineBuffer1[8 * xBGTileIndex + i] <= ~Di_vram[7-i]; 

                                 end

                                 renderCount <= renderCount + 1'b1; end
                   
                  5'd5 : begin   A_vram <= {4'b0000, currentTileAddress, LY[2:0], 1'b1};
                                 renderCount <= renderCount + 1'b1; end
                  
                  5'd6 : begin   renderCount <= renderCount + 1'b1; end
                  
                  
                  5'd7 : begin   rd_vram <= 1'b0;
                                 for(i = 0; i < 8; i = i + 1) begin
                                   
                                   LineBuffer0[8 * xBGTileIndex + i] <= ~Di_vram[7-i]; 
                                   LineBuffer2[8 * xBGTileIndex + i] <= ~Di_vram[7-i]; 

                                 end

                                 xBGTileIndex <= xBGTileIndex + 1'b1;
                                 renderCount <= 5'd0; end
                            
               endcase
           
         end
      
      end
      
      if(XCount >= 9'd252 && XCount < 9'd456) begin
         STAT[1:0] <= 2'd0;
         xBGTileIndex <= 5'b0;
        
      
      end
   end
   else begin
         STAT[1:0] <= 2'd1;
         IRQ <= 1'b1;
         
      
   end

   XCount <= (XCount + 1'b1) % 9'd456;
   if (XCount == 9'd455)
      LY <= (LY + 1'd1) % 8'd154;
   
   
   STAT[2] = (LYC == LY) ? 1'b1 : 1'b0;
   end
end


















endmodule