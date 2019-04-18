module dma(

   input [7:0] dmaAdress,
   input clock,
   
   output DmaEnableSignal,
   
   input [15:0] A_cpu,
   input [7:0] Di_cpu,
   output [7:0] Do_cpu,
   input wr_cpu,
   input rd_cpu,
   
   output reg [15:0] A_oam,
   output reg [7:0] Do_oam,
   input [7:0] Di_oam,
   output reg wr_oam,
   output reg rd_oam,
   
   output [15:0] A_mmu,
   output [7:0] Do_mmu,
   input [7:0] Di_mmu,
   output wr_mmu,
   output rd_mmu

);
   reg   [2:0]    CurrentTCycle = 3'd0;
   reg   [7:0]    DmaCounter = 8'b0;

   reg [7:0] oldDmaAdress = 8'b0;
   reg [1:0] DmaState = 2'b00; //00 wait for dma transfert, 01 init dma transfert, 10 dma transfert in progress

   reg [15:0] A_dma = 16'b0;
   reg [7:0] Do_dma = 8'b0;
   reg wr_dma = 1'b0;
   reg rd_dma = 1'b0;

   assign DmaEnableSignal = DmaState == 2'b00 ? 1'b0 : 1'b1;
   
   assign A_mmu = DmaState ?  A_dma : A_cpu;
   assign Do_mmu = DmaState ?  Do_dma : Di_cpu;
   assign wr_mmu = DmaState ?  wr_dma : wr_cpu;
   assign rd_mmu = DmaState ?  rd_dma : rd_cpu;

   assign Do_cpu = DmaState ? 8'b0 : Di_mmu;


   always @(posedge clock) begin

      if(oldDmaAdress != dmaAdress) begin
         oldDmaAdress <= dmaAdress;
         DmaState <= 2'b01;
         A_dma <= {dmaAdress, 8'b0};
         rd_dma <= 1'b1;
         DmaCounter <= 8'b0;
         CurrentTCycle <= 3'd1;
         A_oam <= 16'hFF00;
         
      end
      else
      if(DmaState == 2'b01) begin
         case(CurrentTCycle)
            3'd1: begin
                     CurrentTCycle <= CurrentTCycle + 3'd1;
                  end
            3'd2: begin
                     CurrentTCycle <= CurrentTCycle + 3'd1;

                  end
            3'd3: begin
                     CurrentTCycle <= 3'd0;
                     DmaState <= 2'b10;
                  end

         endcase
      end
      else
      if(DmaState == 2'b10) begin
         case(CurrentTCycle)
            3'd0: begin
                     Do_oam <= Di_mmu;
                     CurrentTCycle <= CurrentTCycle + 3'd1;
                  end
            3'd1: begin
                     wr_oam <= 1'b1;
                     rd_dma <= 1'b0;
                     CurrentTCycle <= CurrentTCycle + 3'd1;
                  end
            3'd2: begin
                     wr_oam <= 1'b0;
                     A_dma <=  {oldDmaAdress, DmaCounter + 1'b1};
                     rd_dma <= 1'b1;
                     CurrentTCycle <= CurrentTCycle + 3'd1;
                  end
            3'd3: begin
                     CurrentTCycle <= 3'd0;

                     if(DmaCounter == 8'd159)
                        begin
                           DmaCounter <= 8'd0;
                           DmaState <= 2'b00;
                        end
                        else begin
                           A_oam <= 16'hFE00 + {8'b0, DmaCounter + 1'b1};
                           DmaCounter <= DmaCounter + 1'b1;
                        end
                  end

         endcase
      end

   end


endmodule