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
   
   output reg [7:0] LY = 8'b0, 
   output reg [159:0] LinePxlColorArray0,
   output reg [159:0] LinePxlColorArray1,

   output reg updateBufferSignal = 1'b0
   

);

   assign dmaAdress = DMA;

   
   reg [159:0] LineBGDotDatas0;
   reg [159:0] LineBGDotDatas1;
   
   
   reg [8:0]  XCount = 9'b0;  

   reg   [15:0]   A_vram    = 16'h1800;
   reg   [7:0]    Do_vram   = 8'b0;
   wire  [7:0]    Di_vram;
   reg            wr_vram   = 1'b0;
   reg            rd_vram   = 1'b1;
   
   reg   [15:0]   A_oam    = 16'h0000;
   reg   [7:0]    Do_oam   = 8'b0;
   wire  [7:0]    Di_oam;
   reg            wr_oam   = 1'b0;
   reg            rd_oam   = 1'b1; 
   
   reg   [7:0]    LCDC  = 8'b0;
   reg   [4:0]    HSTAT  = 5'b0;
   wire  [2:0]    LSTAT;
   reg   [7:0]    SCY   = 8'b0;
   reg   [7:0]    SCX   = 8'b0;
//   reg   [7:0]    LY    = 8'b0;
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
       HSTAT,
       LSTAT,
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
    
   assign Di_mmuToVram = LSTAT[1] & LSTAT[0] ? 8'hFF : Di_vramio;
   assign Di_mmuToOam  = ((LSTAT[1] & ~LSTAT[0]) | (LSTAT[1] & LSTAT[0])) ? 8'hFF : Di_oamio;
   
   assign Di_vram = LSTAT[1] & LSTAT[0] ? Di_vramio : 8'hFF;
   assign Di_oam  = ((LSTAT[1] & ~LSTAT[0]) | (LSTAT[1] & LSTAT[0])) ? Di_oamio : 8'hFF;

   
   assign A_vramio =   LSTAT[1] & LSTAT[0] ? A_vram    : A_mmuToVram;
   assign Do_vramio =  LSTAT[1] & LSTAT[0] ? Do_vram   : Do_mmuToVram;
   assign wr_vramio =  LSTAT[1] & LSTAT[0] ? wr_vram   : wr_mmuToVram;
   assign rd_vramio =  LSTAT[1] & LSTAT[0] ? rd_vram   : rd_mmuToVram;
   
   assign A_oamio =    ((LSTAT[1] & ~LSTAT[0]) | (LSTAT[1] & LSTAT[0])) ? A_oam    : A_mmuToOam;
   assign Do_oamio =   ((LSTAT[1] & ~LSTAT[0]) | (LSTAT[1] & LSTAT[0])) ? Do_oam   : Do_mmuToOam;
   assign wr_oamio =   ((LSTAT[1] & ~LSTAT[0]) | (LSTAT[1] & LSTAT[0])) ? wr_oam   : wr_mmuToOam;
   assign rd_oamio =   ((LSTAT[1] & ~LSTAT[0]) | (LSTAT[1] & LSTAT[0])) ? rd_oam   : rd_mmuToOam;
   
   
always @(posedge clock) begin

   if(cs_mmu && wr_mmu) begin
      case (A_mmu)
         16'hFF40:   LCDC        <= Di_mmu;   
         16'hFF41:   HSTAT       <= Di_mmu[7:3];
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


assign LSTAT[1:0] =  (LY >= 9'd144) ? 2'd1 : 
                     (LY < 8'd144 && XCount < 9'd80) ? 2'd2 : 
                     (LY < 8'd144 && XCount >= 9'd80 && XCount < 9'd252) ? 2'd3 : 
                     2'd0;
assign LSTAT[2] = (LY == LYC) ? 1'b1 : 1'b0;

reg [7:0] OBJArray [9:0][4:0];  ///0: Y // 1: X  // 2: CHR  // 3: Parameters  // 4: Index
reg [3:0] OBJIndex = 4'b0;
reg [5:0] OAMIndex = 6'b0;
reg [1:0] OAMYSortCount = 2'b00;


reg [3:0] OBJFetchDatasCount = 4'b0;
reg [3:0] OBJFetchIndex = 4'b0;


reg [2:0] renderMode = 3'b000; // 0: init BG rendering // 1: render BG // 2: init OBJ rendering // 3: render OBJ // 4: sleep
reg [4:0] renderBGCount = 5'b0;
reg [4:0] renderOBJCount = 5'd0;
reg [7:0] pixelDotData = 8'b0;

reg [4:0] xBGTileIndex = 5'b0;
reg [3:0] OBJRenderIndex = 4'b0;

reg [2:0] renderAssembly = 3'b000;


reg [7:0] currentTileAddress = 8'b0;
integer i;

always @(posedge clock) begin

   if (LCDC[7]) begin

   
      case (LSTAT)
         2'b10:   begin
                     renderAssembly <= 3'd0;
                     IRQ <= 1'b0;
                     
                     case(OAMYSortCount) 
                        2'd0 :   begin
                                    OAMYSortCount <= OAMYSortCount + 1'b1;
                                    A_oam <= 16'h0000;
                                 end
                        
                        2'd1 :   begin
                                    OAMYSortCount <= OAMYSortCount + 1'b1;
                                 end
                           
                        2'd2 :   begin
                                    A_oam <= {8'h0, OAMIndex + 1'b1, 2'b00};
                                    if((Di_oam >= LY + (LCDC[2] ? 8'd1 : 8'd9)) && (Di_oam <= LY + 8'd16) && (OBJIndex < 4'd10) && (Di_oam != 8'b0)) begin
                                       OBJArray[OBJIndex][0] <= Di_oam;
                                       OBJArray[OBJIndex][4] <= {2'b0, OAMIndex};
                                       OBJIndex <= OBJIndex + 1'b1;
                                    end
                                    OAMYSortCount <= 2'd1;
                                    OAMIndex <= OAMIndex + 1'b1;
                                 end
                     endcase
                  end
                  
         2'b11:   begin
                     
                     if(OBJFetchIndex < OBJIndex) begin
                        case(OBJFetchDatasCount)
                        
                           5'd0: begin 
                                    OBJFetchDatasCount <= OBJFetchDatasCount + 1'b1; 
                                    A_oam <= {6'b0, OBJArray[OBJFetchIndex][4], 2'b01};
                                 end
                           
                           5'd1: OBJFetchDatasCount <= OBJFetchDatasCount + 1'b1; 

                           5'd2: begin 
                                    OBJFetchDatasCount <= OBJFetchDatasCount + 1'b1; 
                                    OBJArray[OBJFetchIndex][1] <= Di_oam;
                                    A_oam <= {6'b0, OBJArray[OBJFetchIndex][4], 2'b10};
                                 end
                           
                           5'd3: OBJFetchDatasCount <= OBJFetchDatasCount + 1'b1; 
                           
                           5'd4: begin 
                                    OBJFetchDatasCount <= OBJFetchDatasCount + 1'b1; 
                                    OBJArray[OBJFetchIndex][2] <= Di_oam;
                                    A_oam <= {6'b0, OBJArray[OBJFetchIndex][4], 2'b11};
                                 end
                           
                           5'd5: OBJFetchDatasCount <= OBJFetchDatasCount + 1'b1; 
                                                      
                           5'd6: begin
                                    OBJFetchDatasCount <=  4'b0; 
                                    OBJFetchIndex <= OBJFetchIndex + 1'b1;
                                    OBJArray[OBJFetchIndex][3] <= Di_oam;
                                 end
                           
                        endcase
                     end
         
                     case(renderMode)
                        3'b000:  begin
                                    A_vram <= 16'h1800 + 16'h0020 * LY[7:3];
                                    renderMode <= 3'b001;
                                 end
                        
                        3'b001:  begin
                                    case(renderBGCount)
                                             
                                       5'd0 : begin   renderBGCount <= renderBGCount + 1'b1; end
                        
                                       5'd1 : begin   A_vram <= {4'b0000, Di_vram, LY[2:0], 1'b0};
                                             currentTileAddress <= Di_vram;
                                             renderBGCount <= renderBGCount + 1'b1; end
                                             
                                       5'd2 : begin   renderBGCount <= renderBGCount + 1'b1; end
                                              
                                       5'd3 : begin   for(i = 0; i < 8; i = i + 1) begin
                                               
                                               LineBGDotDatas0[8 * xBGTileIndex + i] <= Di_vram[7-i]; 

                                             end
                                             A_vram <= {4'b0000, currentTileAddress, LY[2:0], 1'b1};
                                             renderBGCount <= renderBGCount + 1'b1; end
                               
                                       5'd4 : begin   
                                             renderBGCount <= renderBGCount + 1'b1; end
                              
                              
                                       5'd5 : begin   for(i = 0; i < 8; i = i + 1) 
                                             begin
                                               LineBGDotDatas1[8 * xBGTileIndex + i] <= Di_vram[7-i];
                                               
                                               case({Di_vram[7-i],LineBGDotDatas0[8 * xBGTileIndex + i]})
                                                   2'b00:   {LinePxlColorArray1[8 * xBGTileIndex + i], LinePxlColorArray0[8 * xBGTileIndex + i]} <= BGP[1:0];
                                                   2'b01:   {LinePxlColorArray1[8 * xBGTileIndex + i], LinePxlColorArray0[8 * xBGTileIndex + i]} <= BGP[3:2];
                                                   2'b10:   {LinePxlColorArray1[8 * xBGTileIndex + i], LinePxlColorArray0[8 * xBGTileIndex + i]} <= BGP[5:4];
                                                   2'b11:   {LinePxlColorArray1[8 * xBGTileIndex + i], LinePxlColorArray0[8 * xBGTileIndex + i]} <= BGP[7:6];
                                               endcase
                                               
                                             end
                                             A_vram <= 16'h1800 + (xBGTileIndex + 1'b1) + 16'h0020 * LY[7:3];
                                             renderBGCount <= 5'd0; 
                                             if (xBGTileIndex == 5'd20)
                                                renderMode = 3'b010;
                                             else
                                                xBGTileIndex <= xBGTileIndex + 1'b1; end

                                    endcase
                                 end
                          
                           3'b010:  begin
                                       if(OBJIndex != 4'b0) begin
                                          if(OBJArray[OBJRenderIndex][0] - LY < 4'd9)
                                             A_vram <= {4'b0000, OBJArray[OBJRenderIndex][2] + 1'b1, LY[2:0] - OBJArray[OBJRenderIndex][0][2:0], 1'b0};
                                          else
                                             A_vram <= {4'b0000, OBJArray[OBJRenderIndex][2], LY[2:0] - OBJArray[OBJRenderIndex][0][2:0], 1'b0};
                                          renderMode <= 3'b011;
                                       end 
                                       else
                                          renderMode <= 3'b100;
                                    end
                                 
                           3'b011:  begin
                                       case(renderOBJCount) 
                                          5'd0 :   renderOBJCount <= renderOBJCount + 1'b1;
                                   
                                          5'd1 :   begin
                                                      for(i = 0; i < 8; i = i + 1) 
                                                        pixelDotData[i] <= OBJArray[OBJRenderIndex][3][5] ? Di_vram[i] : Di_vram[7-i];
                                                         
                                                      if(OBJArray[OBJRenderIndex][0] - LY < 4'd9)
                                                            A_vram <= {4'b0000, OBJArray[OBJRenderIndex][2] + 1'b1, LY[2:0] - OBJArray[OBJRenderIndex][0][2:0], 1'b1};
                                                               else
                                                            A_vram <= {4'b0000, OBJArray[OBJRenderIndex][2], LY[2:0] - OBJArray[OBJRenderIndex][0][2:0], 1'b1};
                                                      
                                                      renderOBJCount <= renderOBJCount + 1'b1;
                                                   end
                                          5'd2 :   renderOBJCount <= renderOBJCount + 1'b1;
                                          5'd3 :   begin
                                                      for(i = 0; i < 8; i = i + 1) 
                                                         begin
                                                         
                                                         if({LineBGDotDatas1[OBJArray[OBJRenderIndex][1] + i - 4'd8], LineBGDotDatas0[OBJArray[OBJRenderIndex][1] + i - 4'd8]} == 2'b00  || 
                                                         ({OBJArray[OBJRenderIndex][3][5] ? Di_vram[i] : Di_vram[7-i], pixelDotData[i]} != 2'b00 && OBJArray[OBJRenderIndex][3][7] == 1'b0 ) )
                                                            begin
                                                               case({OBJArray[OBJRenderIndex][3][5] ? Di_vram[i] : Di_vram[7-i], pixelDotData[i]})
                                                                  2'b00:   ;
                                                                  2'b01:   {LinePxlColorArray1[OBJArray[OBJRenderIndex][1] + i - 4'd8], LinePxlColorArray0[OBJArray[OBJRenderIndex][1] + i - 4'd8]} <= OBJArray[OBJRenderIndex][3][4] ? OBP1[1:0] : OBP0[3:2];
                                                                  2'b10:   {LinePxlColorArray1[OBJArray[OBJRenderIndex][1] + i - 4'd8], LinePxlColorArray0[OBJArray[OBJRenderIndex][1] + i - 4'd8]} <= OBJArray[OBJRenderIndex][3][4] ? OBP1[1:0] : OBP0[5:4];
                                                                  2'b11:   {LinePxlColorArray1[OBJArray[OBJRenderIndex][1] + i - 4'd8], LinePxlColorArray0[OBJArray[OBJRenderIndex][1] + i - 4'd8]} <= OBJArray[OBJRenderIndex][3][4] ? OBP1[1:0] : OBP0[7:6];
                                                               endcase
                                                            end

                                                         end
                                                      renderOBJCount <= 5'b0;
                                                      if (OBJRenderIndex < OBJIndex - 1'b1)
                                                         begin
                                                            OBJRenderIndex <= OBJRenderIndex + 1'b1; 
                                                            if(OBJArray[OBJRenderIndex + 1'b1][0] - LY < 4'd9)
                                                               A_vram <= {4'b0000, OBJArray[OBJRenderIndex + 1'b1][2] + 1'b1, LY[2:0] - OBJArray[OBJRenderIndex + 1'b1][0][2:0], 1'b0};
                                                                  else
                                                               A_vram <= {4'b0000, OBJArray[OBJRenderIndex + 1'b1][2], LY[2:0] - OBJArray[OBJRenderIndex + 1'b1][0][2:0], 1'b0};
                                                               
                                                         end
                                                         else
                                                            renderMode = 3'b100;

                                                      end
                                       endcase
                                    end
                                    
                              3'b100:  begin
                                       end
                     endcase
                  end
               
         2'b00:   begin
         
                     if(renderAssembly < 2'd2)  begin
                        case(renderAssembly)
                           3'd0 :   begin
                                      
                                       renderAssembly <= renderAssembly + 1'b1;
                                    end
                           
                           3'd1 :   begin 
                                       xBGTileIndex <= 5'b0;
                                       OBJRenderIndex <= 4'b0;
                                       OBJIndex <= 4'b0;
                                       OAMIndex <= 6'b0;
                                       OBJFetchIndex <= 4'b0;
                                       A_oam <= 16'b0;
                                       A_vram <= 16'h1800;
                                       renderMode <= 3'b000;
                                       
                
                                       OAMYSortCount <= 2'b00;


                                       OBJFetchDatasCount <= 4'b0;


                                       renderBGCount <= 5'b0;
                                       renderOBJCount <= 5'd0;

                                       
                                       updateBufferSignal <= 1'b1;
                                       renderAssembly <= renderAssembly + 1'b1;
                                    end
                           3'd2: begin
                                       updateBufferSignal <= 1'b0;
                                 end
                        endcase
                     end   
                     

         
                  end
                  
         2'b01:   begin
                     IRQ <= 1'b1;
                     
         
                  end
      endcase
      
      
      XCount <= (XCount == 9'd455) ? 9'd0 : (XCount + 1'b1);
      if (XCount == 9'd455)
         LY <= (LY == 8'd153) ? 8'd0 : (LY + 1'b1);
   
   end

end




















endmodule