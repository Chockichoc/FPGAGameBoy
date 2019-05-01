module timer(

input clock,

input    [15:0]   A_mmu,
input    [7:0]    Di_mmu,
output   [7:0]    Do_mmu, 
input             wr_mmu,
input             rd_mmu,
input             cs_mmu,

output timerIRQ
);

reg [16:0] DIV = 8'b0;
reg [7:0] TIMA = 8'b0;
reg [7:0] TMA = 8'b0;
reg [7:0] TAC = 8'b0;

assign Do_mmu = (cs_mmu && rd_mmu) ? ( 
         A_mmu == 16'hFF04 ? DIV[15:8] :
         A_mmu == 16'hFF05 ? TIMA :
         A_mmu == 16'hFF06 ? TMA  :
         A_mmu == 16'hFF07 ? TAC  :
         8'b0) : 8'b0;

always @(posedge clock) begin

   if(cs_mmu && wr_mmu) begin
      case (A_mmu)
         16'hFF04:   DIV   <= 16'b0; 
         //16'hFF05:   TIMA  <= Di_mmu;
         16'hFF06:   begin 
                        TMA   <= Di_mmu;
                        DIV <= DIV + 1'b1;
                     end
         16'hFF07:   begin
                        TAC   <= Di_mmu;
                        DIV <= DIV + 1'b1;
                     end
      endcase
   end
   else
     DIV <= DIV + 1'b1;

end

wire TimaClk =  TAC[1:0] == 2'b01 ? DIV[3] :
                TAC[1:0] == 2'b10 ? DIV[5] :
                TAC[1:0] == 2'b11 ? DIV[7] :
                DIV[9];
                  

always @(posedge TimaClk) begin

   if(TAC[2] == 1'b1) begin
   
      if (TIMA == 8'hFF) 
         TIMA <= TMA;
      else 
         TIMA <= TIMA + 1'b1;
      
   end
   
end

assign timerIRQ = (TIMA == 8'hFF) ? 1'b1 : 1'b0;


endmodule