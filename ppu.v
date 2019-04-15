module ppu (
   input clock,

   input          [15:0]   A_mmu,
   output         [7:0]    Do_mmu,
   input          [7:0]    Di_mmu,
   input                   cs_mmu,
   input                   wr_mmu,
   input                   rd_mmu,
   
   output         [15:0]   A_vram,
   output         [7:0]    Do_vram,
   input          [7:0]    Di_vram,
   output                  wr_vram,
   output                  rd_vram,
   
   output         [15:0]   A_oam,
   output         [7:0]    Do_oam,
   input          [7:0]    Di_oam,
   output                  wr_oam,
   output                  rd_oam,
   
   input pixelClk,
   output  HSync,
   output  VSync,
   output  [3:0] R,
   output  [3:0] G,
   output  [3:0] B

);

   HVSync HVSync0(pixelClk, HSync, VSync, R, G, B, LY, LineBuffer);

   //wire [9:0] HCount;
   //wire [9:0] VCount;

   //assign pixColor = Buffer[HCount][VCount];
   
   reg [159:0] LineBuffer;
   reg [8:0]  XCount = 9'b0;  

   reg   [15:0]   A_ppu    = 16'h0000;
   reg   [7:0]    Do_ppu   = 8'b0;
   wire  [7:0]    Di_ppu;
   reg            wr_ppu   = 1'b0;
   reg            rd_ppu   = 1'b0;
   
   
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
   
   
   wire  [15:0]   A_mmu0ToVram;
   wire  [7:0]    Do_mmu0ToVram;
   wire  [7:0]    Di_mmu0ToVram;
   wire           cs_mmu0ToVram;
   wire           wr_mmu0ToVram;
   wire           rd_mmu0ToVram;
   
   wire  [15:0]   A_mmu0ToOam;
   wire  [7:0]    Do_mmu0ToOam;
   wire  [7:0]    Di_mmu0ToOam;
   wire           cs_mmu0ToOam;
   wire           wr_mmu0ToOam;
   wire           rd_mmu0ToOam;
   
   wire  [15:0]   A_mmu1ToVram;
   wire  [7:0]    Do_mmu1ToVram;
   wire  [7:0]    Di_mmu1ToVram;
   wire           cs_mmu1ToVram;
   wire           wr_mmu1ToVram;
   wire           rd_mmu1ToVram;
   
   wire  [15:0]   A_mmu1ToOam;
   wire  [7:0]    Do_mmu1ToOam;
   wire  [7:0]    Di_mmu1ToOam;
   wire           cs_mmu1ToOam;
   wire           wr_mmu1ToOam;
   wire           rd_mmu1ToOam;

   ppuInternalMMU ppuInternalMMU0 (
      A_mmu,
      Do_mmu,
      Di_mmu,
      wr_mmu,
      rd_mmu,
      
      A_mmu0ToVram,
      Do_mmu0ToVram,
      Di_mmu0ToVram,
      cs_mmu0ToVram,
      wr_mmu0ToVram,
      rd_mmu0ToVram,
      
      A_mmu0ToOam,
      Do_mmu0ToOam,
      Di_mmu0ToOam,
      cs_mmu0ToOam,
      wr_mmu0ToOam,
      rd_mmu0ToOam,
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
   
   ppuInternalMMU ppuInternalMMU1 (
      A_ppu,
      Di_ppu,
      Do_ppu,
      wr_ppu,
      rd_ppu,
      
      A_mmu1ToVram,
      Do_mmu1ToVram,
      Di_mmu1ToVram,
      cs_mmu1ToVram,
      wr_mmu1ToVram,
      rd_mmu1ToVram,
      
      A_mmu1ToOam,
      Do_mmu1ToOam,
      Di_mmu1ToOam,
      cs_mmu1ToOam,
      wr_mmu1ToOam,
      rd_mmu1ToOam 
   );
   
   assign Di_mmu0ToVram = STAT[1] & STAT[0] ? 8'hFF : Di_vram;
   assign Di_mmu0ToOam  = STAT[1] & ~STAT[0] ? 8'hFF : Di_oam;
   
   assign Di_mmu1ToVram = STAT[1] & STAT[0] ? Di_vram : 8'hFF;
   assign Di_mmu1ToOam  = STAT[1] & ~STAT[0] ? Di_oam : 8'hFF;

   
   assign A_vram =   STAT[1] & STAT[0] ? A_mmu1ToVram    : A_mmu0ToVram;
   assign Do_vram =  STAT[1] & STAT[0] ? Do_mmu1ToVram   : Do_mmu0ToVram;
   assign wr_vram =  STAT[1] & STAT[0] ? wr_mmu1ToVram   : wr_mmu0ToVram;
   assign rd_vram =  STAT[1] & STAT[0] ? rd_mmu1ToVram   : rd_mmu0ToVram;
   
   assign A_oam =    ((STAT[1] & ~STAT[0]) | (STAT[1] & STAT[0]))  ? A_mmu1ToOam    : A_mmu0ToOam;
   assign Do_oam =   ((STAT[1] & ~STAT[0]) | (STAT[1] & STAT[0])) ? Do_mmu1ToOam   : Do_mmu0ToOam;
   assign wr_oam =   ((STAT[1] & ~STAT[0]) | (STAT[1] & STAT[0])) ? wr_mmu1ToOam   : wr_mmu0ToOam;
   assign rd_oam =   ((STAT[1] & ~STAT[0]) | (STAT[1] & STAT[0])) ? rd_mmu1ToOam   : rd_mmu0ToOam;
   
   
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
//   else if(cs_mmu && rd_mmu) begin
//      case (A_mmu)
//         16'hFF40:   Do_mmu <= LCDC;
//         16'hFF41:   Do_mmu <= STAT;
//         16'hFF42:   Do_mmu <= SCY;
//         16'hFF43:   Do_mmu <= SCX;
//         16'hFF44:   Do_mmu <= LY;
//         16'hFF45:   Do_mmu <= LYC;
//         16'hFF46:   Do_mmu <= DMA;
//         16'hFF47:   Do_mmu <= BGP;
//         16'hFF48:   Do_mmu <= OBP0;
//         16'hFF49:   Do_mmu <= OBP1;
//         16'hFF4A:   Do_mmu <= WY;
//         16'hFF4B:   Do_mmu <= WX;
//      endcase
//   end

end

reg [4:0] renderCount = 5'b0;
reg [4:0] xBGTileIndex = 5'b0;


always @(posedge clock) begin
   if (LCDC[7]) begin
   if(LY < 8'd144) begin
      if(XCount < 9'd80 ) begin
         STAT[1:0] <= 2'd2;
      
      end
      
      if(XCount >= 9'd80 && XCount < 9'd252) begin
         STAT[1:0] <= 2'd3;
        
         if(xBGTileIndex < 5'd20) begin
               case(renderCount)
               
                  5'd0 : begin   renderCount <= renderCount + 1'b1;
                                 A_ppu <= 16'h9800 + xBGTileIndex + 16'h0020 * LY[7:3];
                                 rd_ppu <= 1'b1; end
                                 
                  5'd1 : begin   renderCount <= renderCount + 1'b1; end
            
                  5'd2 : begin   A_ppu <= {4'b1000, Di_ppu, LY[2:0], 1'b0};
                                 renderCount <= renderCount + 1'b1; end
                                 
                  5'd3 : begin   renderCount <= renderCount + 1'b1; end
                  
                  
                  5'd4 : begin   rd_ppu <= 1'b0;
                                 LineBuffer[8 * xBGTileIndex + 0] <= Di_ppu[7]; 
                                 LineBuffer[8 * xBGTileIndex + 1] <= Di_ppu[6];
                                 LineBuffer[8 * xBGTileIndex + 2] <= Di_ppu[5];
                                 LineBuffer[8 * xBGTileIndex + 3] <= Di_ppu[4];
                                 LineBuffer[8 * xBGTileIndex + 4] <= Di_ppu[3];
                                 LineBuffer[8 * xBGTileIndex + 5] <= Di_ppu[2];
                                 LineBuffer[8 * xBGTileIndex + 6] <= Di_ppu[1];
                                 LineBuffer[8 * xBGTileIndex + 7] <= Di_ppu[0];
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
         
         
      
   end

   XCount <= (XCount + 1'b1) % 9'd456;
   if (XCount == 9'd455)
      LY <= (LY + 1'd1) % 8'd154;
   
   
   STAT[2] = (LYC == LY) ? 1'b1 : 1'b0;
   end
end


















endmodule