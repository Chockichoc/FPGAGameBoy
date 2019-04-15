module cpu(

   //2^22 Hz clock
   input             pllClk,
   
   //reset
   input             reset,
   
   //To MMU
   output   [15:0]   A_MMU,
   input    [7:0]    Di_MMU,
   output   [7:0]    Do_MMU,
   output            cs_MMU,
   output            wr_MMU,
   output            rd_MMU,
   
   //To HRAM
   output   [15:0]   A_HRAM,
   input    [7:0]    Di_HRAM,
   output   [7:0]    Do_HRAM,
   output            cs_HRAM,
   output            wr_HRAM,
   output            rd_HRAM,
   


   output reg  [7:0]    A = 8'h00,
   output reg  [7:0]    B = 8'h00,
   output reg  [7:0]    C = 8'h00,
   output reg  [7:0]    D = 8'h00,
   output reg  [7:0]    E = 8'h00,
   output reg  [7:0]    F = 8'h00,
   output reg  [7:0]    H = 8'h00,
   output reg  [7:0]    L = 8'h00,
   output reg  [15:0]   PC = 16'h0000,
   output reg  [15:0]   SP = 16'hFFFE

);

   //To cpuInternalMMU
   reg   [15:0]   A_cpu = 16'h0000;
   wire  [7:0]    Di_cpu;
   reg   [7:0]    Do_cpu;
   reg            wr = 1'b0;
   reg            rd = 1'b0;

   //Internal registers
// reg   [7:0]    A = 8'h00;
// reg   [7:0]    B = 8'h00;
// reg   [7:0]    C = 8'h00;
// reg   [7:0]    D = 8'h00;
// reg   [7:0]    E = 8'h00;
// reg   [7:0]    F = 8'h00;
// reg   [7:0]    H = 8'h00;
// reg   [7:0]    L = 8'h00;
   
   //Program counter and Stack pointer
   //reg [15:0]   PC = 16'h0000;
   //reg [15:0]   SP = 16'hFFFE;
   
   //Interrupt things
   reg   [7:0]    IF = 8'h0000;
   reg   [7:0]    IE = 8'h0000;
   reg            IME = 1'b0;
   
   //Current Instruction
   reg   [7:0]    CI = 8'bz;
   reg   [2:0]    CurrentMCycle = 3'd0;
   reg   [2:0]    CurrentTCycle = 3'd0;
   reg   [7:0]    CB = 8'b0;
    

    
   cpuInternalMMU cpuInternalMMU0(
      A_cpu,
      Di_cpu,
      Do_cpu,
      wr,
      rd,
      
      A_MMU,
      Do_MMU,
      Di_MMU,
      cs_MMU,
      wr_MMU,
      rd_MMU,
      
      A_HRAM,
      Do_HRAM,
      Di_HRAM,
      cs_HRAM,
      wr_HRAM,
      rd_HRAM
      
   );
   
   
   always @(posedge pllClk or posedge reset) begin

   
   if(reset) begin
   
      A <= 8'h00;
      B <= 8'h00;
      C <= 8'h00;
      D <= 8'h00;
      E <= 8'h00;
      F <= 8'h00;
      H <= 8'h00;
      L <= 8'h00;
      
      PC <= 16'h0000;
      SP <= 16'hFFFE;
      CurrentMCycle <= 3'd0;
      CurrentTCycle <= 3'd0;
   
   end
   else begin 
   
            ////////////
            //op fetch//
            ////////////
      if(CurrentMCycle == 0 && CurrentTCycle < 2'd3)  begin
         case (CurrentTCycle)
            3'd0 :   begin A_cpu <= PC; 
                           rd <= 1'b1; 
                           CurrentTCycle <= CurrentTCycle + 3'd1;    end
            3'd1 :   begin   
                           CurrentTCycle <= CurrentTCycle + 3'd1;    end
            3'd2 :   begin CI <= Di_cpu; 
                           rd <= 1'b0; 
                           CurrentTCycle <= CurrentTCycle + 3'd1;    end
         endcase
      
      end
      else begin
         
         case (CI)
         
            //////////////////
            //LD r, r'family//
            //////////////////
            

            8'b01111111, 8'b01111000, 8'b01111001, 8'b01111010, 8'b01111011, 8'b01111100, 8'b01111101,
            8'b01000111, 8'b01000000, 8'b01000001, 8'b01000010, 8'b01000011, 8'b01000100, 8'b01000101,
            8'b01001111, 8'b01001000, 8'b01001001, 8'b01001010, 8'b01001011, 8'b01001100, 8'b01001101,
            8'b01010111, 8'b01010000, 8'b01010001, 8'b01010010, 8'b01010011, 8'b01010100, 8'b01010101,
            8'b01011111, 8'b01011000, 8'b01011001, 8'b01011010, 8'b01011011, 8'b01011100, 8'b01011101,
            8'b01100111, 8'b01100000, 8'b01100001, 8'b01100010, 8'b01100011, 8'b01100100, 8'b01100101,
            8'b01101111, 8'b01101000, 8'b01101001, 8'b01101010, 8'b01101011, 8'b01101100, 8'b01101101 :
            
                           begin    PC <= PC + 16'd1; 
                                    CurrentTCycle <= 3'd0;
                                    case (CI[5:3])
                                          
                                          //LD A, r'
                                          3'b111:  begin
                                                      case (CI[2:0])
                                                      3'b111: A <= A;
                                                      3'b000: A <= B;
                                                      3'b001: A <= C;
                                                      3'b010: A <= D;
                                                      3'b011: A <= E;
                                                      3'b100: A <= H;
                                                      3'b101: A <= L;
                                                      endcase
                                                   end
                                                   
                                          //LD B, r'
                                          3'b000:  begin
                                                      case (CI[2:0])
                                                      3'b111: B <= A;
                                                      3'b000: B <= B;
                                                      3'b001: B <= C;
                                                      3'b010: B <= D;
                                                      3'b011: B <= E;
                                                      3'b100: B <= H;
                                                      3'b101: B <= L;
                                                      endcase
                                                   end
                                                   
                                          //LD C, r'
                                          3'b001:  begin
                                                      case (CI[2:0])
                                                      3'b111: C <= A;
                                                      3'b000: C <= B;
                                                      3'b001: C <= C;
                                                      3'b010: C <= D;
                                                      3'b011: C <= E;
                                                      3'b100: C <= H;
                                                      3'b101: C <= L;
                                                      endcase
                                                   end
                                                   
                                          //LD D, r'
                                          3'b010:  begin
                                                      case (CI[2:0])
                                                      3'b111: D <= A;
                                                      3'b000: D <= B;
                                                      3'b001: D <= C;
                                                      3'b010: D <= D;
                                                      3'b011: D <= E;
                                                      3'b100: D <= H;
                                                      3'b101: D <= L;
                                                      endcase
                                                   end
                                                   
                                          //LD E, r'
                                          3'b011:  begin
                                                      case (CI[2:0])
                                                      3'b111: E <= A;
                                                      3'b000: E <= B;
                                                      3'b001: E <= C;
                                                      3'b010: E <= D;
                                                      3'b011: E <= E;
                                                      3'b100: E <= H;
                                                      3'b101: E <= L;
                                                      endcase
                                                   end
                                                   
                                          //LD H, r'
                                          3'b100:  begin
                                                      case (CI[2:0])
                                                      3'b111: H <= A;
                                                      3'b000: H <= B;
                                                      3'b001: H <= C;
                                                      3'b010: H <= D;
                                                      3'b011: H <= E;
                                                      3'b100: H <= H;
                                                      3'b101: H <= L;
                                                      endcase
                                                   end
                                                   
                                          //LD L, r'
                                          3'b101:  begin
                                                      case (CI[2:0])
                                                      3'b111: L <= A;
                                                      3'b000: L <= B;
                                                      3'b001: L <= C;
                                                      3'b010: L <= D;
                                                      3'b011: L <= E;
                                                      3'b100: L <= H;
                                                      3'b101: L <= L;
                                                      endcase
                                                   end
                                          
                                    endcase;
                           end
                                          
                           
            //////////////////         
            //LD r, n family//
            //////////////////               

            8'b00111110, 8'b00000110, 8'b00001110, 8'b00010110, 8'b00011110, 8'b00100110, 8'b00101110  :   
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    A_cpu <= PC + 16'd1;
                                                               PC <= PC + 16'd2; 
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    case (CI[5:3])
                                                                  3'b111: A <= Di_cpu;
                                                                  3'b000: B <= Di_cpu;
                                                                  3'b001: C <= Di_cpu;
                                                                  3'b010: D <= Di_cpu;
                                                                  3'b011: E <= Di_cpu;
                                                                  3'b100: H <= Di_cpu;
                                                                  3'b101: L <= Di_cpu;
                                                               endcase;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase                 
                              endcase

                           end
            
         
                  
            /////////////////////         
            //LD (HL), r family//
            /////////////////////

            8'b01110111, 8'b01110000, 8'b01110001, 8'b01110010, 8'b01110011, 8'b01110100, 8'b01110101 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    PC <= PC + 16'd1; 
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= {H, L};
                                                               case(CI[2:0])
                                                                  3'b111: Do_cpu <= A;
                                                                  3'b000: Do_cpu <= B;
                                                                  3'b001: Do_cpu <= C;
                                                                  3'b010: Do_cpu <= D;
                                                                  3'b011: Do_cpu <= E;
                                                                  3'b100: Do_cpu <= H;
                                                                  3'b101: Do_cpu <= L;
                                                               endcase;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    wr<= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    wr<= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end
                           
                           
                           
            /////////////////////         
            //LD r, (HL) family//
            /////////////////////
            
            8'b01111110, 8'b01000110, 8'b01001110, 8'b01010110, 8'b01011110, 8'b01100110, 8'b01101110 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    A_cpu <= {H, L};
                                                               PC <= PC + 16'd1; 
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    case(CI[5:3])
                                                                  3'b111: A <= Di_cpu;
                                                                  3'b000: B <= Di_cpu;
                                                                  3'b001: C <= Di_cpu;
                                                                  3'b010: D <= Di_cpu;
                                                                  3'b011: E <= Di_cpu;
                                                                  3'b100: H <= Di_cpu;
                                                                  3'b101: L <= Di_cpu;
                                                               endcase;
                                                               rd<= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end
                           
                           
                           
            //////////////       
            //LD (HL), n//
            //////////////

            8'b00110110 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    A_cpu <= PC + 16'd1;
                                                               PC <= PC + 16'd2; 
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    Do_cpu <= Di_cpu;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase
                                 3'd2  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= {H, L};
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    wr <= 1'b1; 
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    wr <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end
                           
            //////////////       
            //LD A, (BC)//
            //////////////

            8'b00001010 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    A_cpu <= {B, C};
                                                               PC <= PC + 16'd1; 
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    A <= Di_cpu;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end   
   

   
            //////////////       
            //LD A, (DE)//
            //////////////
            
            8'b00011010 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    A_cpu <= {D, E};
                                                               PC <= PC + 16'd1; 
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    A <= Di_cpu;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end      
                           
                           
                     
            /////////////        
            //LD A, (C)//
            /////////////

            8'b11110010 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    A_cpu <= {8'hFF, C};
                                                               PC <= PC + 16'd1; 
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    A <= Di_cpu;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end         
               
               
               
            /////////////        
            //LD (C), A//
            /////////////

            8'b11100010, :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    PC <= PC + 16'd1; 
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= {8'hFF, C};
                                                               Do_cpu <= A;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    wr<= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    wr<= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end
                           
                           
                           
            /////////////        
            //LD A, (n)//
            /////////////

            8'b11110000 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    A_cpu <= PC + 1'b1;
                                                               PC <= PC + 2'd2; 
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    A_cpu <= {8'hFF, Di_cpu};
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase
                                 3'd2  :  case (CurrentTCycle)
                                             3'd0  :  begin    rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    A <= Di_cpu;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end   
   
   
   
            /////////////        
            //LD (n), A//
            /////////////

            8'b11100000 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    A_cpu <= PC + 16'd1;
                                                               PC <= PC + 16'd2; 
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    A_cpu <= {8'hFF, Di_cpu};
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase
                                 3'd2  :  case (CurrentTCycle)
                                             3'd0  :  begin    Do_cpu <= A;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;
                                                               wr <= 1'b1;                                  end
                                             3'd2  :  begin    wr <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end   
                           
                           
                           
            //////////////       
            //LD A, (nn)//
            //////////////

            8'b11111010 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= PC + 16'd1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;
                                                               rd <= 1'b1;                                  end
                                             3'd2  :  begin    
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    Do_cpu <= Di_cpu;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase
                                 3'd2  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= PC + 16'd2;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    rd <= 1'b0;
                                                               A_cpu <= {Di_cpu, Do_cpu};
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase
                                 3'd3  :  case (CurrentTCycle)
                                             3'd0  :  begin    rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    rd <= 1'b0;
                                                               A <= Di_cpu;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    PC <= PC + 16'd3;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end   
                           
                        
                        
            //////////////       
            //LD (nn), A//
            //////////////

            8'b11101010 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= PC + 16'd1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;
                                                               rd <= 1'b1;                                  end
                                             3'd2  :  begin    
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    Do_cpu <= Di_cpu;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase
                                 3'd2  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= PC + 16'd2;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    rd <= 1'b0;
                                                               A_cpu <= {Di_cpu, Do_cpu};
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase
                                 3'd3  :  case (CurrentTCycle)
                                             3'd0  :  begin    Do_cpu <= A;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    wr <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    wr <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    PC <= PC + 16'd3;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end   

                           
                           
            ////////////////////////         
            //LD A, (HLI/D) family//
            ////////////////////////

            8'b00101010, 8'b00111010 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    A_cpu <= {H, L};
                                                               PC <= PC + 16'd1; 
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    A <= Di_cpu;
                                                               rd<= 1'b0;
                                                               case (CI[5:3])
                                                                  3'b101: {H, L} <= {H, L} + 16'd1;
                                                                  3'b111: {H, L} <= {H, L} - 16'd1;
                                                               endcase;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end
                     
                     
                     
            /////////////////////         
            //LD (rr), A family//
            /////////////////////

            8'b00000010, 8'b00010010, 8'b00100010, 8'b00110010 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    PC <= PC + 16'd1; 
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    case (CI[5:3])
                                                                  3'b000 : A_cpu <= {B, C};
                                                                  3'b010 : A_cpu <= {D, E};
                                                                  3'b100 : A_cpu <= {H, L};
                                                                  3'b110 : A_cpu <= {H, L};
                                                               endcase;
                                                               Do_cpu <= A;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    wr <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    wr <= 1'b0;
                                                               case (CI[5:3])
                                                                  3'b100: {H, L} <= {H, L} + 16'd1;
                                                                  3'b110: {H, L} <= {H, L} - 16'd1;
                                                               endcase;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end            

                           
                                                   
            ////////////////////       
            //LD dd, nn family//
            ////////////////////

            8'b00000001, 8'b00010001, 8'b00100001, 8'b00110001 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= PC + 16'd1;
                                                               rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    case (CI[5:4])
                                                                  2'b00 : C <= Di_cpu;
                                                                  2'b01 : E <= Di_cpu;
                                                                  2'b10 : L <= Di_cpu;
                                                                  2'b11 : SP[7:0] <= Di_cpu;
                                                               endcase;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase
                                 3'd2  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= PC + 16'd2;
                                                               rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    case (CI[5:4])
                                                                  2'b00 : B <= Di_cpu;
                                                                  2'b01 : D <= Di_cpu;
                                                                  2'b10 : H <= Di_cpu;
                                                                  2'b11 : SP[15:8] <= Di_cpu;
                                                               endcase;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    PC <= PC + 16'd3;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end         
                           
                           
                           
            /////////////        
            //LD SP, HL//
            /////////////

            8'b11111001 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    PC <= PC + 16'd1; 
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    SP <= {H, L};
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end
                           
                           
                           
            //////////////////         
            //push qq family//
            //////////////////

            8'b11000101, 8'b11010101, 8'b11100101, 8'b11110101 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    PC <= PC + 1'b1;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    SP <= SP - 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    A_cpu <= SP;
                                                               case (CI[5:4])
                                                                  2'b00 : Do_cpu <= B;
                                                                  2'b01 : Do_cpu <= D;
                                                                  2'b10 : Do_cpu <= H;
                                                                  2'b11 : Do_cpu <= A;
                                                               endcase
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    wr <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    Do_cpu <= Di_cpu;
                                                               wr <= 1'b0;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase
                                 3'd2  :  case (CurrentTCycle)
                                             3'd0  :  begin    SP <= SP - 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    A_cpu <= SP;
                                                               case (CI[5:4])
                                                                  2'b00 : Do_cpu <= C;
                                                                  2'b01 : Do_cpu <= E;
                                                                  2'b10 : Do_cpu <= L;
                                                                  2'b11 : Do_cpu <= F;
                                                               endcase;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    wr <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    wr <= 1'b0;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase
                                 3'd3  :  case (CurrentTCycle)
                                             3'd0  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end   
                           
                           
                           
            /////////////////       
            //pop qq family//
            /////////////////

            8'b11000001, 8'b11010001, 8'b11100001, 8'b11110001 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    PC <= PC + 16'd1; 
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= SP;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    case (CI[5:4])
                                                                  2'b00 : C <= Di_cpu;
                                                                  2'b01 : E <= Di_cpu;
                                                                  2'b10 : L <= Di_cpu;
                                                                  2'b11 : F <= Di_cpu;
                                                               endcase;
                                                               rd <= 1'b0;
                                                               SP <= SP + 1'b1;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase
                                 3'd2  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= SP;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    case (CI[5:4])
                                                                  2'b00 : B <= Di_cpu;
                                                                  2'b01 : D <= Di_cpu;
                                                                  2'b10 : H <= Di_cpu;
                                                                  2'b11 : A <= Di_cpu;
                                                               endcase;
                                                               rd <= 1'b0;
                                                               SP <= SP + 1'b1;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end

                           
                           
            ///////////////         
            //LD HL SP, e//
            ///////////////

            8'b11111000 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    F <= 8'b00000000;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= PC + 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    {H, L} <= SP + $signed(Di_cpu);
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase
                                 3'd2  :  case (CurrentTCycle)
                                             3'd0  :  begin    case (Di_cpu[7])
                                                                  1'b0 :   begin 
                                                                              F[5] <= (SP[3:0] + Di_cpu[3:0]) < Di_cpu[3:0] ? 1'b1 : 1'b0;
                                                                              F[4] <= (SP[7:0] + Di_cpu) < Di_cpu ? 1'b1 : 1'b0;
                                                                           end
                                                                  1'b1 :   begin
                                                                              F[5] <= SP[3:0] < SP[3:0] - (~Di_cpu[3:0] + 1'b1) ? 1'b1 : 1'b0;
                                                                              F[4] <= SP[7:0] < SP[7:0] - (~Di_cpu + 1'b1) ? 1'b1 : 1'b0;
                                                                           end
                                                               endcase;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             2'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             2'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             2'd3  :  begin    PC <= PC + 16'd2; 
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end   
                     
            ///////////////         
            //LD (nn), SP//
            ///////////////

            8'b00001000 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= PC + 16'd1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    Do_cpu <= Di_cpu;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase
                                 3'd2  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= PC + 16'd2;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    A_cpu <= {Di_cpu, Do_cpu};
                                                               Do_cpu <= SP[7:0];
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase
                                 3'd3  :  case (CurrentTCycle)
                                             3'd0  :  begin    wr <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    wr <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase
                                 3'd4  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= A_cpu + 1'b1;
                                                               Do_cpu <= SP[15:8];
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    wr <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    wr <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    PC <= PC + 8'd3; 
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end   
                     
            ///////////////////
            //ADD A, r family//
            ///////////////////
            

            8'b10000111, 8'b10000000, 8'b10000001, 8'b10000010, 8'b10000011, 8'b10000100, 8'b10000101 :
            
                           begin    PC <= PC + 16'd1; 
                                    CurrentTCycle <= 3'd0;
                                    F[6] <= 1'b0;
                              case (CI[2:0])
                                 3'b111 : begin A <= A + A;
                                                F[7] <= A[7:0] + A[7:0] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] > A[3:0] + A[3:0] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] > A[7:0] + A[7:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b000 : begin A <= A + B;
                                                F[7] <= A[7:0] + B[7:0] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] > A[3:0] + B[3:0] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] > A[7:0] + B[7:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b001 : begin A <= A + C;
                                                F[7] <= A[7:0] + C[7:0] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] > A[3:0] + C[3:0] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] > A[7:0] + C[7:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b010 : begin A <= A + D;
                                                F[7] <= A[7:0] + D[7:0] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] > A[3:0] + D[3:0] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] > A[7:0] + D[7:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b011 : begin A <= A + E;
                                                F[7] <= A[7:0] + E[7:0] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] > A[3:0] + E[3:0] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] > A[7:0] + E[7:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b100 : begin A <= A + H;
                                                F[7] <= A[7:0] + H[7:0] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] > A[3:0] + H[3:0] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] > A[7:0] + H[7:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b101 : begin A <= A + L;
                                                F[7] <= A[7:0] + L[7:0] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] > A[3:0] + L[3:0] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] > A[7:0] + L[7:0] ? 1'b1 : 1'b0;
                                          end
                              endcase
                           end
                           
                           
                           
            ////////////         
            //ADD A, n//
            ////////////
            
            8'b11000110 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= PC + 1'd1;
                                                               rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    A <= A + Di_cpu;
                                                               F[7] <= A[7:0] + Di_cpu == 8'b0 ? 1'b1 : 1'b0;
                                                               F[6] <= 1'b0;
                                                               F[5] <= A[3:0] > A[3:0] + Di_cpu[3:0] ? 1'b1 : 1'b0;
                                                               F[4] <= A[7:0] > A[7:0] + Di_cpu[7:0] ? 1'b1 : 1'b0;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    PC <= PC + 16'd2;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end      
                           
                           
                           
            ///////////////         
            //ADD A, (HL)//
            ///////////////
            
            8'b10000110 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    PC <= PC + 16'd1;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= {H, L};
                                                               rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    A <= A + Di_cpu;
                                                               F[7] <= A[7:0] + Di_cpu == 8'b0 ? 1'b1 : 1'b0;
                                                               F[6] <= 1'b0;
                                                               F[5] <= A[3:0] > A[3:0] + Di_cpu[3:0] ? 1'b1 : 1'b0;
                                                               F[4] <= A[7:0] > A[7:0] + Di_cpu[7:0] ? 1'b1 : 1'b0;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end   
                        
                        
                        
            ///////////////////
            //ADC A, r family//
            ///////////////////
            

            8'b10001111, 8'b10001000, 8'b10001001, 8'b10001010, 8'b10001011, 8'b10001100, 8'b10001101 :
            
                           begin    PC <= PC + 16'd1; 
                                    CurrentTCycle <= 3'd0;
                                    F[6] <= 1'b0;
                              case (CI[2:0])
                                 3'b111 : begin A <= A + A + F[4];
                                                F[7] <= A[7:0] + A[7:0] + F[4] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] > A[3:0] + A[3:0] + F[4] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] > A[7:0] + A[7:0] + F[4] ? 1'b1 : 1'b0;
                                          end
                                 3'b000 : begin A <= A + B + F[4];
                                                F[7] <= A[7:0] + B[7:0] + F[4] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] > A[3:0] + B[3:0] + F[4] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] > A[7:0] + B[7:0] + F[4] ? 1'b1 : 1'b0;
                                          end
                                 3'b001 : begin A <= A + C + F[4];
                                                F[7] <= A[7:0] + C[7:0] + F[4] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] > A[3:0] + C[3:0] + F[4] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] > A[7:0] + C[7:0] + F[4] ? 1'b1 : 1'b0;
                                          end
                                 3'b010 : begin A <= A + D + F[4];
                                                F[7] <= A[7:0] + D[7:0] + F[4] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] > A[3:0] + D[3:0] + F[4] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] > A[7:0] + D[7:0] + F[4] ? 1'b1 : 1'b0;
                                          end
                                 3'b011 : begin A <= A + E + F[4];
                                                F[7] <= A[7:0] + E[7:0] + F[4] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] > A[3:0] + E[3:0] + F[4] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] > A[7:0] + E[7:0] + F[4] ? 1'b1 : 1'b0;
                                          end
                                 3'b100 : begin A <= A + H + F[4];
                                                F[7] <= A[7:0] + H[7:0] + F[4] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] > A[3:0] + H[3:0] + F[4] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] > A[7:0] + H[7:0] + F[4] ? 1'b1 : 1'b0;
                                          end
                                 3'b101 : begin A <= A + L + F[4];
                                                F[7] <= A[7:0] + L[7:0] + F[4] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] > A[3:0] + L[3:0] + F[4] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] > A[7:0] + L[7:0] + F[4] ? 1'b1 : 1'b0;
                                          end
                              endcase
                           end   
                           
   
   
            ////////////         
            //ADC A, n//
            ////////////
            
            8'b11001110 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= PC + 1'd1;
                                                               rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    A <= A + Di_cpu + F[4];
                                                               F[7] <= A[7:0] + Di_cpu + F[4] == 8'b0 ? 1'b1 : 1'b0;
                                                               F[6] <= 1'b0;
                                                               F[5] <= A[3:0] > A[3:0] + Di_cpu[3:0] + F[4] ? 1'b1 : 1'b0;
                                                               F[4] <= A[7:0] > A[7:0] + Di_cpu[7:0] + F[4] ? 1'b1 : 1'b0;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    PC <= PC + 16'd2;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end   
                           
   
   
            ///////////////         
            //ADC A, (HL)//
            ///////////////
            
            8'b10001110 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    PC <= PC + 16'd1;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= {H, L};
                                                               rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    A <= A + Di_cpu + F[4];
                                                               F[7] <= A[7:0] + Di_cpu + F[4] == 8'b0 ? 1'b1 : 1'b0;
                                                               F[6] <= 1'b0;
                                                               F[5] <= A[3:0] > A[3:0] + Di_cpu[3:0] + F[4] ? 1'b1 : 1'b0;
                                                               F[4] <= A[7:0] > A[7:0] + Di_cpu[7:0] + F[4] ? 1'b1 : 1'b0;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end   
                           
                           
                           
            //////////////////////
            //SUB/CP A, r family//
            //////////////////////
            

            8'b10010111, 8'b10010000, 8'b10010001, 8'b10010010, 8'b10010011, 8'b10010100, 8'b10010101,
            8'b10111111, 8'b10111000, 8'b10111001, 8'b10111010, 8'b10111011, 8'b10111100, 8'b10111101 :
            
                           begin    PC <= PC + 16'd1; 
                                    CurrentTCycle <= 3'd0;
                                    F[6] <= 1'b1;
                              case (CI[2:0])
                                 3'b111 : begin case (CI[5:3])
                                                   3'b010 : A <= A - A;
                                                endcase
                                                F[7] <= A[7:0] - A[7:0] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] < A[3:0] - A[3:0] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] < A[7:0] - A[7:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b000 : begin case (CI[5:3])
                                                   3'b010 : A <= A - B;
                                                endcase
                                                F[7] <= A[7:0] - B[7:0] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] < A[3:0] - B[3:0] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] < A[7:0] - B[7:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b001 : begin case (CI[5:3])
                                                   3'b010 : A <= A - C;
                                                endcase
                                                F[7] <= A[7:0] - C[7:0] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] < A[3:0] - C[3:0] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] < A[7:0] - C[7:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b010 : begin case (CI[5:3])
                                                   3'b010 : A <= A - D;
                                                endcase
                                                F[7] <= A[7:0] - D[7:0] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] < A[3:0] - D[3:0] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] < A[7:0] - D[7:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b011 : begin case (CI[5:3])
                                                   3'b010 : A <= A - E;
                                                endcase
                                                F[7] <= A[7:0] - E[7:0] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] < A[3:0] - E[3:0] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] < A[7:0] - E[7:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b100 : begin case (CI[5:3])
                                                   3'b010 : A <= A - H;
                                                endcase
                                                F[7] <= A[7:0] - H[7:0] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] < A[3:0] - H[3:0] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] < A[7:0] - H[7:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b101 : begin case (CI[5:3])
                                                   3'b010 : A <= A - L;
                                                endcase
                                                F[7] <= A[7:0] - L[7:0] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] < A[3:0] - L[3:0] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] < A[7:0] - L[7:0] ? 1'b1 : 1'b0;
                                          end
                              endcase
                           end
                           
            ///////////////         
            //SUB/CP A, n//
            ///////////////
            
            8'b11010110, 8'b11111110 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= PC + 1'd1;
                                                               rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    case (CI[5:3])
                                                                  3'b010 : A <= A - Di_cpu;
                                                               endcase
                                                               F[7] <= A[7:0] - Di_cpu == 8'b0 ? 1'b1 : 1'b0;
                                                               F[6] <= 1'b1;
                                                               F[5] <= A[3:0] < A[3:0] - Di_cpu[3:0] ? 1'b1 : 1'b0;
                                                               F[4] <= A[7:0] < A[7:0] - Di_cpu[7:0] ? 1'b1 : 1'b0;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    PC <= PC + 16'd2;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end   
                           
                           
                           
            //////////////////         
            //SUB/CP A, (HL)//
            //////////////////
            
            8'b10010110, 8'b10111110 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    PC <= PC + 16'd1;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= {H, L};
                                                               rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    case (CI[5:3])
                                                                  3'b010 : A <= A - Di_cpu;
                                                               endcase
                                                               F[7] <= A[7:0] - Di_cpu == 8'b0 ? 1'b1 : 1'b0;
                                                               F[6] <= 1'b1;
                                                               F[5] <= A[3:0] < A[3:0] - Di_cpu[3:0] ? 1'b1 : 1'b0;
                                                               F[4] <= A[7:0] < A[7:0] - Di_cpu[7:0] ? 1'b1 : 1'b0;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end   
                           
                           

            ///////////////////
            //SBC A, r family//
            ///////////////////
            

            8'b10011111, 8'b10011000, 8'b10011001, 8'b10011010, 8'b10011011, 8'b10011100, 8'b10011101 :
            
                           begin    PC <= PC + 16'd1; 
                                    CurrentTCycle <= 3'd0;
                                    F[6] <= 1'b1;
                              case (CI[2:0])
                                 3'b111 : begin A <= A - A - F[4];
                                                F[7] <= A[7:0] - A[7:0] - F[4] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] < A[3:0] - A[3:0] - F[4] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] < A[7:0] - A[7:0] - F[4] ? 1'b1 : 1'b0;
                                          end
                                 3'b000 : begin A <= A - B - F[4];
                                                F[7] <= A[7:0] - B[7:0] - F[4] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] < A[3:0] - B[3:0] - F[4] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] < A[7:0] - B[7:0] - F[4] ? 1'b1 : 1'b0;
                                          end
                                 3'b001 : begin A <= A - C - F[4];
                                                F[7] <= A[7:0] - C[7:0] - F[4] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] < A[3:0] - C[3:0] - F[4] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] < A[7:0] - C[7:0] - F[4] ? 1'b1 : 1'b0;
                                          end
                                 3'b010 : begin A <= A - D - F[4];
                                                F[7] <= A[7:0] - D[7:0] - F[4] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] < A[3:0] - D[3:0] - F[4] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] < A[7:0] - D[7:0] - F[4] ? 1'b1 : 1'b0;
                                          end
                                 3'b011 : begin A <= A - E - F[4];
                                                F[7] <= A[7:0] - E[7:0] - F[4] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] < A[3:0] - E[3:0] - F[4] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] < A[7:0] - E[7:0] - F[4] ? 1'b1 : 1'b0;
                                          end
                                 3'b100 : begin A <= A - H - F[4];
                                                F[7] <= A[7:0] - H[7:0] - F[4] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] < A[3:0] - H[3:0] - F[4] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] < A[7:0] - H[7:0] - F[4] ? 1'b1 : 1'b0;
                                          end
                                 3'b101 : begin A <= A - L - F[4];
                                                F[7] <= A[7:0] - L[7:0] - F[4] == 8'b0 ? 1'b1 : 1'b0;
                                                F[5] <= A[3:0] < A[3:0] - L[3:0] - F[4] ? 1'b1 : 1'b0;
                                                F[4] <= A[7:0] < A[7:0] - L[7:0] - F[4] ? 1'b1 : 1'b0;
                                          end
                              endcase
                           end
                           
            ////////////         
            //SBC A, n//
            ////////////
            
            8'b11011110 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= PC + 1'd1;
                                                               rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    A <= A - Di_cpu - F[4];
                                                               F[7] <= A[7:0] - Di_cpu - F[4] == 8'b0 ? 1'b1 : 1'b0;
                                                               F[6] <= 1'b1;
                                                               F[5] <= A[3:0] < A[3:0] - Di_cpu[3:0] - F[4] ? 1'b1 : 1'b0;
                                                               F[4] <= A[7:0] < A[7:0] - Di_cpu[7:0] - F[4] ? 1'b1 : 1'b0;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    PC <= PC + 16'd2;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end   
                           
                           
                           
            ///////////////         
            //SBC A, (HL)//
            ///////////////
            
            8'b10011110 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    PC <= PC + 16'd1;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= {H, L};
                                                               rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    A <= A - Di_cpu - F[4];
                                                               F[7] <= A[7:0] - Di_cpu - F[4] == 8'b0 ? 1'b1 : 1'b0;
                                                               F[6] <= 1'b1;
                                                               F[5] <= A[3:0] < A[3:0] - Di_cpu[3:0] - F[4] ? 1'b1 : 1'b0;
                                                               F[4] <= A[7:0] < A[7:0] - Di_cpu[7:0] - F[4] ? 1'b1 : 1'b0;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end   
                           
                           
                           
            //////////////////////////
            //AND/OR/XOR A, r family//
            //////////////////////////
            

            8'b10100111, 8'b10100000, 8'b10100001, 8'b10100010, 8'b10100011, 8'b10100100, 8'b10100101, 
            8'b10110111, 8'b10110000, 8'b10110001, 8'b10110010, 8'b10110011, 8'b10110100, 8'b10110101,
            8'b10101111, 8'b10101000, 8'b10101001, 8'b10101010, 8'b10101011, 8'b10101100, 8'b10101101 :
            
                           begin    PC <= PC + 16'd1; 
                                    CurrentTCycle <= 3'd0;
                                    F[6] <= 1'b0;
                                    F[5] <= CI[5:3] == 3'b100 ? 1'b1 : 1'b0;
                                    F[4] <= 1'b0;
                                    case (CI[2:0])
                                       3'b111 : begin case (CI[5:3])
                                                         3'b100 : A = A & A;
                                                         3'b110 : A = A | A;
                                                         3'b101 : A = A ^ A;
                                                      endcase
                                                end
                                       3'b000 : begin case (CI[5:3])
                                                         3'b100 : A = A & B;
                                                         3'b110 : A = A | B;
                                                         3'b101 : A = A ^ B;
                                                      endcase
                                                end
                                       3'b001 : begin case (CI[5:3])
                                                         3'b100 : A = A & C;
                                                         3'b110 : A = A | C;
                                                         3'b101 : A = A ^ C;
                                                      endcase
                                                end
                                       3'b010 : begin case (CI[5:3])
                                                         3'b100 : A = A & D;
                                                         3'b110 : A = A | D;
                                                         3'b101 : A = A ^ D;
                                                      endcase
                                                end
                                       3'b011 : begin case (CI[5:3])
                                                         3'b100 : A = A & E;
                                                         3'b110 : A = A | E;
                                                         3'b101 : A = A ^ E;
                                                      endcase
                                                end
                                       3'b100 : begin case (CI[5:3])
                                                         3'b100 : A = A & H;
                                                         3'b110 : A = A | H;
                                                         3'b101 : A = A ^ H;
                                                      endcase
                                                end
                                       3'b101 : begin case (CI[5:3])
                                                         3'b100 : A = A & L;
                                                         3'b110 : A = A | L;
                                                         3'b101 : A = A ^ L;
                                                      endcase
                                                end
                                    endcase
                                    F[7] = A == 8'b0 ? 1'b1 : 1'b0;
                           end
                           
                           
                           
            ////////////////////////         
            //AND/OR/XOR A, n/(HL)//
            ////////////////////////
            
            8'b11100110, 8'b11101110, 8'b11110110,
            8'b10100110, 8'b10101110, 8'b10110110 :
            
                           begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    case (CI[7:6])
                                                                  2'b11 :  begin A_cpu <= PC + 1'd1;
                                                                              PC <= PC + 16'd2;
                                                                           end
                                                                  2'b10 :  begin A_cpu <= {H, L};
                                                                              PC <= PC + 16'd1;
                                                                           end
                                                               endcase
                                                               rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    case (CI[5:3])
                                                                  3'b100 : A = A & Di_cpu;
                                                                  3'b110 : A = A | Di_cpu;
                                                                  3'b101 : A = A ^ Di_cpu;
                                                               endcase
                                                               F[7] = A == 8'b0 ? 1'b1 : 1'b0;
                                                               F[6] <= 1'b0;
                                                               F[5] <= CI[5:3] == 3'b100 ? 1'b1 : 1'b0;
                                                               F[4] <= 1'b0;
                                                               rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end   
                           
                           
            /////////      
            //INC r//
            /////////
            
            8'b00000100, 8'b00001100, 8'b00010100, 8'b00011100, 8'b00100100,
            8'b00101100, 8'b00111100 :
            
                           begin 
                           
                              PC <= PC + 16'd1; 
                              CurrentTCycle <= 3'd0;
                              
                              case (CI[5:3])
                                 3'b111:  begin    A <= A + 1'b1;
                                                F[7] <= A + 1'b1 == 8'b0 ? 1'b1 : 1'b0;
                                                F[6] <= 1'b0;
                                                F[5] <= A[3:0] + 1'b1 < A[3:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b000:  begin    B <= B + 1'b1;
                                                F[7] <= B + 1'b1 == 8'b0 ? 1'b1 : 1'b0;
                                                F[6] <= 1'b0;
                                                F[5] <= B[3:0] + 1'b1 < B[3:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b001:  begin    C <= C + 1'b1;
                                                F[7] <= C + 1'b1 == 8'b0 ? 1'b1 : 1'b0;
                                                F[6] <= 1'b0;
                                                F[5] <= C[3:0] + 1'b1 < C[3:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b010:  begin    D <= D + 1'b1;
                                                F[7] <= D + 1'b1 == 8'b0 ? 1'b1 : 1'b0;
                                                F[6] <= 1'b0;
                                                F[5] <= D[3:0] + 1'b1 < D[3:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b011:  begin    E <= E + 1'b1;
                                                F[7] <= E + 1'b1 == 8'b0 ? 1'b1 : 1'b0;
                                                F[6] <= 1'b0;
                                                F[5] <= E[3:0] + 1'b1 < E[3:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b100:  begin    H <= H + 1'b1;
                                                F[7] <= H + 1'b1 == 8'b0 ? 1'b1 : 1'b0;
                                                F[6] <= 1'b0;
                                                F[5] <= H[3:0] + 1'b1 < H[3:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b101:  begin    L <= L + 1'b1;
                                                F[7] <= L + 1'b1 == 8'b0 ? 1'b1 : 1'b0;
                                                F[6] <= 1'b0;
                                                F[5] <= L[3:0] + 1'b1 < L[3:0] ? 1'b1 : 1'b0;
                                          end
                              endcase;   
                           end   
         
         
            ////////////      
            //INC (HL)//
            ////////////
            
            8'b00110100 : begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    PC <= PC + 16'd1;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= {H, L};
                                                               rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    rd <= 1'b0;
                                                               Do_cpu <= Di_cpu + 1'b1;
                                                               F[7] <= Di_cpu + 1'b1 == 8'b0 ? 1'b1 : 1'b0;
                                                               F[6] <= 1'b0;
                                                               F[5] <= Di_cpu[3:0] + 1'b1 < Di_cpu[3:0] ? 1'b1 : 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    wr <= 1'b1;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase
                                 3'd2  :  case (CurrentTCycle)
                                             3'd0  :  begin    wr <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end 
                        
                        
            /////////      
            //DEC r//
            /////////
            
            8'b00000101, 8'b00001101, 8'b00010101, 8'b00011101, 8'b00100101,
            8'b00101101, 8'b00111101 :
            
                           begin 
                           
                              PC <= PC + 16'd1; 
                              CurrentTCycle <= 3'd0;
                              
                              case (CI[5:3])
                                 3'b111:  begin    A <= A - 1'b1;
                                                F[7] <= A - 1'b1 == 8'b0 ? 1'b1 : 1'b0;
                                                F[6] <= 1'b1;
                                                F[5] <= A[3:0] - 1'b1 > A[3:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b000:  begin    B <= B - 1'b1;
                                                F[7] <= B - 1'b1 == 8'b0 ? 1'b1 : 1'b0;
                                                F[6] <= 1'b1;
                                                F[5] <= B[3:0] - 1'b1 > B[3:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b001:  begin    C <= C - 1'b1;
                                                F[7] <= C - 1'b1 == 8'b0 ? 1'b1 : 1'b0;
                                                F[6] <= 1'b1;
                                                F[5] <= C[3:0] - 1'b1 > C[3:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b010:  begin    D <= D - 1'b1;
                                                F[7] <= D - 1'b1 == 8'b0 ? 1'b1 : 1'b0;
                                                F[6] <= 1'b1;
                                                F[5] <= D[3:0] - 1'b1 > D[3:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b011:  begin    E <= E - 1'b1;
                                                F[7] <= E - 1'b1 == 8'b0 ? 1'b1 : 1'b0;
                                                F[6] <= 1'b1;
                                                F[5] <= E[3:0] - 1'b1 > E[3:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b100:  begin    H <= H - 1'b1;
                                                F[7] <= H - 1'b1 == 8'b0 ? 1'b1 : 1'b0;
                                                F[6] <= 1'b1;
                                                F[5] <= H[3:0] - 1'b1 > H[3:0] ? 1'b1 : 1'b0;
                                          end
                                 3'b101:  begin    L <= L - 1'b1;
                                                F[7] <= L - 1'b1 == 8'b0 ? 1'b1 : 1'b0;
                                                F[6] <= 1'b1;
                                                F[5] <= L[3:0] - 1'b1 > L[3:0] ? 1'b1 : 1'b0;
                                          end
                              endcase;   
                           end   
         
         
            ////////////      
            //DEC (HL)//
            ////////////
            
            8'b00110101 : begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    PC <= PC + 16'd1;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= {H, L};
                                                               rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    rd <= 1'b0;
                                                               Do_cpu <= Di_cpu - 1'b1;
                                                               F[7] <= Di_cpu - 1'b1 == 8'b0 ? 1'b1 : 1'b0;
                                                               F[6] <= 1'b1;
                                                               F[5] <= Di_cpu[3:0] - 1'b1 > Di_cpu[3:0] ? 1'b1 : 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    wr <= 1'b1;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase
                                 3'd2  :  case (CurrentTCycle)
                                             3'd0  :  begin    wr <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end 
                  
         
            //////////////      
            //ADD HL, ss//
            //////////////
            
            8'b00001001, 8'b00011001, 8'b00101001, 8'b00111001 : 
                        begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    PC <= PC + 16'd1;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                              
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    case (CI[5:4])
                                                                  2'b00 :  begin    {H, L} <= {H, L} + {B, C}; 
                                                                                    F[6] <= 1'b0; 
                                                                                    F[5] <= {H[3:0], L} + {B[3:0], C} > {H[3:0], L} ? 1'b0 : 1'b1;
                                                                                    F[4] <= {H, L} + {B, C} > {H, L} ? 1'b0 : 1'b1; end
                                                                  2'b01 :  begin    {H, L} <= {H, L} + {D, E}; 
                                                                                    F[6] <= 1'b0; 
                                                                                    F[5] <= {H[3:0], L} + {D[3:0], E} > {H[3:0], L} ? 1'b0 : 1'b1;
                                                                                    F[4] <= {H, L} + {D, E} > {H, L} ? 1'b0 : 1'b1; end
                                                                  2'b10 :  begin    {H, L} <= {H, L} + {H, L}; 
                                                                                    F[6] <= 1'b0; 
                                                                                    F[5] <= {H[3:0], L} + {H[3:0], L} > {H[3:0], L} ? 1'b0 : 1'b1;
                                                                                    F[4] <= {H, L} + {H, L} > {H, L} ? 1'b0 : 1'b1; end
                                                                  2'b11 :  begin    {H, L} <= {H, L} + SP; 
                                                                                    F[6] <= 1'b0; 
                                                                                    F[5] <= {H[3:0], L} + SP[11:0] > {H[3:0], L} ? 1'b0 : 1'b1;
                                                                                    F[4] <= {H, L} + SP > {H, L} ? 1'b0 : 1'b1;  end
                                                               endcase;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end 
                  
            //////////////      
            //ADD SP, r8//
            //////////////    
         
            8'b11101000 :
                     begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    A_cpu <= PC + 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    rd <= 1'b1;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    SP <= SP + $signed(Di_cpu);
                                                               case (Di_cpu[7])
                                                                  1'b0 :   begin 
                                                                              F[5] <= (SP[3:0] + Di_cpu[3:0]) < SP[3:0] ? 1'b1 : 1'b0;
                                                                              F[4] <= (SP[7:0] + Di_cpu) < SP[7:0] ? 1'b1 : 1'b0;
                                                                           end
                                                                  1'b1 :   begin
                                                                              F[5] <= SP[3:0] < SP[3:0] - (~Di_cpu[3:0] + 1'b1) ? 1'b1 : 1'b0;
                                                                              F[4] <= SP[7:0] < SP[7:0] - (~Di_cpu + 1'b1) ? 1'b1 : 1'b0;
                                                                           end
                                                               endcase;
                                                               F[7] <= 1'b0;
                                                               F[6] <= 1'b0;
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase
                                 3'd2  :  case (CurrentTCycle)
                                             3'd0  :  begin    rd <= 1'b0;
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             2'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             2'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             2'd3  :  begin    PC <= PC + 16'd2; 
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;                       end
                                          endcase
                                 3'd3  :  case (CurrentTCycle)
                                             3'd0  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end 
                           
            //////////////      
            //INC/DEC ss//
            //////////////    
         
            8'b00000011, 8'b00010011, 8'b00100011, 8'b00110011,
            8'b00001011, 8'b00011011, 8'b00101011, 8'b00111011:
                     begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    PC <= PC + 16'd1; 
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= CurrentMCycle + 3'd1;       end
                                          endcase     
                                 3'd1  :  case (CurrentTCycle)
                                             3'd0  :  begin    case (CI[5:3])
                                                                  3'b000 : {B, C} <= {B, C} + 1'b1;
                                                                  3'b010 : {D, E} <= {D, E} + 1'b1;
                                                                  3'b100 : {H, L} <= {H, L} + 1'b1;
                                                                  3'b110 : SP <= SP + 1'b1;
                                                                  3'b001 : {B, C} <= {B, C} - 1'b1;
                                                                  3'b011 : {D, E} <= {D, E} - 1'b1;
                                                                  3'b101 : {H, L} <= {H, L} - 1'b1;
                                                                  3'b111 : SP <= SP - 1'b1;
                                                               endcase
                                                               CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                             3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase
                              endcase
                           end
                           
            ////////////////////////      
            //RLCA, RLA, RRCA, RRA//
            ////////////////////////      
         
            8'b00000111, 8'b00010111, 8'b00001111, 8'b00011111:
                     begin
                              case(CurrentMCycle)
                                 3'd0  :  case (CurrentTCycle)
                                             3'd3  :  begin    PC <= PC + 16'd1;
                                                               F[7] <= 1'b0;
                                                               F[6] <= 1'b0;
                                                               F[5] <= 1'b0;
                                                               case (CI[4:3])
                                                                  2'b00 : begin  F[4] <= A[7];
                                                                                 A <= {A[6:0], A[7]}; end
                                                                  2'b01 : begin  F[4] <= A[0];
                                                                                 A <= {A[0], A[7:1]}; end
                                                                  2'b10 : begin  F[4] <= A[7];
                                                                                 A <= {A[6:0], F[4]}; end
                                                                  2'b11 : begin  F[4] <= A[0];
                                                                                 A <= {F[4], A[7:1]}; end
                                                               endcase
                                                               
                                                               CurrentTCycle <= 3'd0;
                                                               CurrentMCycle <= 3'd0;                       end
                                          endcase     
                              endcase
                     end 
                     
            //////      
            //CB//
            //////      
            
            8'b11001011 :  begin
                              case(CurrentMCycle)
                                 3'd0 :
                                    case(CurrentTCycle)
                                       3'd3 :   begin
                                                   PC <= PC + 16'd2;
                                                   A_cpu <= PC + 16'd1;
                                                   rd <= 1'b1;
                                                   CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;
                                                end
                                    endcase
                                 3'd1 :
                                    case(CurrentTCycle)
                                       3'd0 :   begin 
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                end
                                       3'd1 :   begin
                                                   CB <= Di_cpu;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                   rd <= 1'b0;
                                                end
                                    endcase
                              endcase
                           

            
                           if(CurrentMCycle >= 3'd2 || (CurrentMCycle == 3'd1 && CurrentTCycle >= 3'd2)) begin
                              case(CB)
                              
                                 /////////////
                                 ////RLC r////
                                 /////////////
                                 8'b00000000, 8'b00000001, 8'b00000010, 8'b00000011, 8'b00000100, 8'b00000101, 8'b00000111 :
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin    
                                                                  F[6] <= 1'b0;
                                                                  F[5] <= 1'b0;
                                                                  case(CB[2:0])
                                                                     3'b000 : begin    F[4] <= B[7];
                                                                                       F[7] <= {B[6:0], B[7]} == 0 ? 1'b1 : 1'b0;
                                                                                       B <= {B[6:0], B[7]}; end
                                                                     3'b001 : begin    F[4] <= C[7];
                                                                                       F[7] <= {C[6:0], C[7]} == 0 ? 1'b1 : 1'b0;
                                                                                       C <= {C[6:0], C[7]}; end
                                                                     3'b010 : begin    F[4] <= D[7];
                                                                                       F[7] <= {D[6:0], D[7]} == 0 ? 1'b1 : 1'b0;
                                                                                       D <= {D[6:0], D[7]}; end
                                                                     3'b011 : begin    F[4] <= E[7];
                                                                                       F[7] <= {E[6:0], E[7]} == 0 ? 1'b1 : 1'b0;
                                                                                       E <= {E[6:0], E[7]}; end
                                                                     3'b100 : begin    F[4] <= H[7];
                                                                                       F[7] <= {H[6:0], H[7]} == 0 ? 1'b1 : 1'b0;
                                                                                       H <= {H[6:0], H[7]}; end
                                                                     3'b101 : begin    F[4] <= L[7];
                                                                                       F[7] <= {L[6:0], L[7]} == 0 ? 1'b1 : 1'b0;
                                                                                       L <= {L[6:0], L[7]}; end
                                                                     3'b111 : begin    F[4] <= A[7];
                                                                                       F[7] <= {A[6:0], A[7]} == 0 ? 1'b1 : 1'b0;
                                                                                       A <= {A[6:0], A[7]}; end
                                                                  endcase
                                                                  CurrentTCycle <= CurrentTCycle + 3'd1;
                                                               end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                                    
                                 ////////////////
                                 ////RLC (HL)////
                                 ////////////////
                                 8'b00000110 :
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin A_cpu <= {H, L};
                                                                     rd <= 1'b1;
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= CurrentMCycle + 3'd1; end
                                                   endcase
                                          3'd2 :   case (CurrentTCycle)
                                                      3'd0 :   begin rd <= 1'b0;
                                                                     F[6] <= 1'b0;
                                                                     F[5] <= 1'b0;
                                                                     F[4] <= Di_cpu[7];
                                                                     F[7] <= {Di_cpu[6:0], Di_cpu[7]} == 0 ? 1'b1 : 1'b0;
                                                                     Do_cpu <= {Di_cpu[6:0], Di_cpu[7]};
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd1 :   begin wr <= 1'b1;
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd2 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd3 :   begin wr <= 1'b0;
                                                                     CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= CurrentMCycle + 3'd1; end
                                                   endcase
                                          3'd3 :   case (CurrentTCycle)
                                                      3'd0 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd1 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd2 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                                    
                                 ////////////
                                 ////RL r////
                                 ////////////
                                 8'b00010000, 8'b00010001, 8'b00010010, 8'b00010011, 8'b00010100, 8'b00010101, 8'b00010111 :
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin    
                                                                  F[6] <= 1'b0;
                                                                  F[5] <= 1'b0;
                                                                  case(CB[2:0])
                                                                     3'b000 : begin    F[4] <= B[7];
                                                                                       F[7] <= {B[6:0], F[4]} == 0 ? 1'b1 : 1'b0;
                                                                                       B <= {B[6:0], F[4]}; end
                                                                     3'b001 : begin    F[4] <= C[7];
                                                                                       F[7] <= {C[6:0], F[4]} == 0 ? 1'b1 : 1'b0;
                                                                                       C <= {C[6:0], F[4]}; end
                                                                     3'b010 : begin    F[4] <= D[7];
                                                                                       F[7] <= {D[6:0], F[4]} == 0 ? 1'b1 : 1'b0;
                                                                                       D <= {D[6:0], F[4]}; end
                                                                     3'b011 : begin    F[4] <= E[7];
                                                                                       F[7] <= {E[6:0], F[4]} == 0 ? 1'b1 : 1'b0;
                                                                                       E <= {E[6:0], F[4]}; end
                                                                     3'b100 : begin    F[4] <= H[7];
                                                                                       F[7] <= {H[6:0], F[4]} == 0 ? 1'b1 : 1'b0;
                                                                                       H <= {H[6:0], F[4]}; end
                                                                     3'b101 : begin    F[4] <= L[7];
                                                                                       F[7] <= {L[6:0], F[4]} == 0 ? 1'b1 : 1'b0;
                                                                                       L <= {L[6:0], F[4]}; end
                                                                     3'b111 : begin    F[4] <= A[7];
                                                                                       F[7] <= {A[6:0], F[4]} == 0 ? 1'b1 : 1'b0;
                                                                                       A <= {A[6:0], F[4]}; end
                                                                  endcase
                                                                  CurrentTCycle <= CurrentTCycle + 3'd1;
                                                               end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                                    
                                 ///////////////
                                 ////RL (HL)////
                                 ///////////////
                                 8'b00010110 :
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin A_cpu <= {H, L};
                                                                     rd <= 1'b1;
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= CurrentMCycle + 3'd1; end
                                                   endcase
                                          3'd2 :   case (CurrentTCycle)
                                                      3'd0 :   begin rd <= 1'b0;
                                                                     F[6] <= 1'b0;
                                                                     F[5] <= 1'b0;
                                                                     F[4] <= Di_cpu[7];
                                                                     F[7] <= {Di_cpu[6:0], F[4]} == 0 ? 1'b1 : 1'b0;
                                                                     Do_cpu <= {Di_cpu[6:0], F[4]};
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd1 :   begin wr <= 1'b1;
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd2 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd3 :   begin wr <= 1'b0;
                                                                     CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= CurrentMCycle + 3'd1; end
                                                   endcase
                                          3'd3 :   case (CurrentTCycle)
                                                      3'd0 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd1 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd2 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                                    
                                 /////////////
                                 ////RRC r////
                                 /////////////
                                 8'b00001000, 8'b00001001, 8'b00001010, 8'b00001011, 8'b00001100, 8'b00001101, 8'b00001111 :
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin    
                                                                  F[6] <= 1'b0;
                                                                  F[5] <= 1'b0;
                                                                  case(CB[2:0])
                                                                     3'b000 : begin    F[4] <= B[0];
                                                                                       F[7] <= {B[0], B[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       B <= {B[0], B[7:1]}; end
                                                                     3'b001 : begin    F[4] <= C[0];
                                                                                       F[7] <= {C[0], C[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       C <= {C[0], C[7:1]}; end
                                                                     3'b010 : begin    F[4] <= D[0];
                                                                                       F[7] <= {D[0], D[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       D <= {D[0], D[7:1]}; end
                                                                     3'b011 : begin    F[4] <= E[0];
                                                                                       F[7] <= {E[0], E[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       E <= {E[0], E[7:1]}; end
                                                                     3'b100 : begin    F[4] <= H[0];
                                                                                       F[7] <= {H[0], H[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       H <= {H[0], H[7:1]}; end
                                                                     3'b101 : begin    F[4] <= L[0];
                                                                                       F[7] <= {L[0], L[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       L <= {L[0], L[7:1]}; end
                                                                     3'b111 : begin    F[4] <= A[0];
                                                                                       F[7] <= {A[0], A[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       A <= {A[0], A[7:1]}; end
                                                                  endcase
                                                                  CurrentTCycle <= CurrentTCycle + 3'd1;
                                                               end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                                    
                                 ////////////////
                                 ////RRC (HL)////
                                 ////////////////
                                 8'b00001110 :
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin A_cpu <= {H, L};
                                                                     rd <= 1'b1;
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= CurrentMCycle + 3'd1; end
                                                   endcase
                                          3'd2 :   case (CurrentTCycle)
                                                      3'd0 :   begin rd <= 1'b0;
                                                                     F[6] <= 1'b0;
                                                                     F[5] <= 1'b0;
                                                                     F[4] <= Di_cpu[0];
                                                                     F[7] <= {Di_cpu[0], Di_cpu[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                     Do_cpu <= {Di_cpu[0], Di_cpu[7:1]};
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd1 :   begin wr <= 1'b1;
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd2 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd3 :   begin wr <= 1'b0;
                                                                     CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= CurrentMCycle + 3'd1; end
                                                   endcase
                                          3'd3 :   case (CurrentTCycle)
                                                      3'd0 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd1 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd2 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                                    
                                 ////////////
                                 ////RR r////
                                 ////////////
                                 8'b00011000, 8'b00011001, 8'b00011010, 8'b00011011, 8'b00011100, 8'b00011101, 8'b00011111 :
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin    
                                                                  F[6] <= 1'b0;
                                                                  F[5] <= 1'b0;
                                                                  case(CB[2:0])
                                                                     3'b000 : begin    F[4] <= B[0];
                                                                                       F[7] <= {F[4], B[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       B <= {F[4], B[7:1]}; end
                                                                     3'b001 : begin    F[4] <= C[0];
                                                                                       F[7] <= {F[4], C[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       C <= {F[4], C[7:1]}; end
                                                                     3'b010 : begin    F[4] <= D[0];
                                                                                       F[7] <= {F[4], D[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       D <= {F[4], D[7:1]}; end
                                                                     3'b011 : begin    F[4] <= E[0];
                                                                                       F[7] <= {F[4], E[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       E <= {F[4], E[7:1]}; end
                                                                     3'b100 : begin    F[4] <= H[0];
                                                                                       F[7] <= {F[4], H[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       H <= {F[4], H[7:1]}; end
                                                                     3'b101 : begin    F[4] <= L[0];
                                                                                       F[7] <= {F[4], L[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       L <= {F[4], L[7:1]}; end
                                                                     3'b111 : begin    F[4] <= A[0];
                                                                                       F[7] <= {F[4], A[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       A <= {F[4], A[7:1]}; end
                                                                  endcase
                                                                  CurrentTCycle <= CurrentTCycle + 3'd1;
                                                               end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                                    
                                 ///////////////
                                 ////RR (HL)////
                                 ///////////////
                                 8'b00011110 :
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin A_cpu <= {H, L};
                                                                     rd <= 1'b1;
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= CurrentMCycle + 3'd1; end
                                                   endcase
                                          3'd2 :   case (CurrentTCycle)
                                                      3'd0 :   begin rd <= 1'b0;
                                                                     F[6] <= 1'b0;
                                                                     F[5] <= 1'b0;
                                                                     F[4] <= Di_cpu[0];
                                                                     F[7] <= {F[4], Di_cpu[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                     Do_cpu <= {F[4], Di_cpu[7:1]};
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd1 :   begin wr <= 1'b1;
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd2 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd3 :   begin wr <= 1'b0;
                                                                     CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= CurrentMCycle + 3'd1; end
                                                   endcase
                                          3'd3 :   case (CurrentTCycle)
                                                      3'd0 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd1 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd2 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                                    
                                 /////////////
                                 ////SLA r////
                                 /////////////
                                 8'b00100000, 8'b00100001, 8'b00100010, 8'b00100011, 8'b00100100, 8'b00100101, 8'b00100111 :
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin    
                                                                  F[6] <= 1'b0;
                                                                  F[5] <= 1'b0;
                                                                  case(CB[2:0])
                                                                     3'b000 : begin    F[4] <= B[7];
                                                                                       F[7] <= {B[6:0], 1'b0} == 0 ? 1'b1 : 1'b0;
                                                                                       B <= {B[6:0], 1'b0}; end
                                                                     3'b001 : begin    F[4] <= C[7];
                                                                                       F[7] <= {C[6:0], 1'b0} == 0 ? 1'b1 : 1'b0;
                                                                                       C <= {C[6:0], 1'b0}; end
                                                                     3'b010 : begin    F[4] <= D[7];
                                                                                       F[7] <= {D[6:0], 1'b0} == 0 ? 1'b1 : 1'b0;
                                                                                       D <= {D[6:0], 1'b0}; end
                                                                     3'b011 : begin    F[4] <= E[7];
                                                                                       F[7] <= {E[6:0], 1'b0} == 0 ? 1'b1 : 1'b0;
                                                                                       E <= {E[6:0], 1'b0}; end
                                                                     3'b100 : begin    F[4] <= H[7];
                                                                                       F[7] <= {H[6:0], 1'b0} == 0 ? 1'b1 : 1'b0;
                                                                                       H <= {H[6:0], 1'b0}; end
                                                                     3'b101 : begin    F[4] <= L[7];
                                                                                       F[7] <= {L[6:0], 1'b0} == 0 ? 1'b1 : 1'b0;
                                                                                       L <= {L[6:0], 1'b0}; end
                                                                     3'b111 : begin    F[4] <= A[7];
                                                                                       F[7] <= {A[6:0], 1'b0} == 0 ? 1'b1 : 1'b0;
                                                                                       A <= {A[6:0], 1'b0}; end
                                                                  endcase
                                                                  CurrentTCycle <= CurrentTCycle + 3'd1;
                                                               end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                                    
                                 ////////////////
                                 ////SLA (HL)////
                                 ////////////////
                                 8'b00100110 :
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin A_cpu <= {H, L};
                                                                     rd <= 1'b1;
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= CurrentMCycle + 3'd1; end
                                                   endcase
                                          3'd2 :   case (CurrentTCycle)
                                                      3'd0 :   begin rd <= 1'b0;
                                                                     F[6] <= 1'b0;
                                                                     F[5] <= 1'b0;
                                                                     F[4] <= Di_cpu[7];
                                                                     F[7] <= {Di_cpu[6:0], 1'b0} == 0 ? 1'b1 : 1'b0;
                                                                     Do_cpu <= {Di_cpu[6:0], 1'b0};
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd1 :   begin wr <= 1'b1;
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd2 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd3 :   begin wr <= 1'b0;
                                                                     CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= CurrentMCycle + 3'd1; end
                                                   endcase
                                          3'd3 :   case (CurrentTCycle)
                                                      3'd0 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd1 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd2 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                                 
                                 /////////////
                                 ////SRA r////
                                 /////////////
                                 8'b00101000, 8'b00101001, 8'b00101010, 8'b00101011, 8'b00101100, 8'b00101101, 8'b00101111 :
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin    
                                                                  F[6] <= 1'b0;
                                                                  F[5] <= 1'b0;
                                                                  case(CB[2:0])
                                                                     3'b000 : begin    F[4] <= B[0];
                                                                                       F[7] <= {B[7], B[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       B <= {B[7], B[7:1]}; end
                                                                     3'b001 : begin    F[4] <= C[0];
                                                                                       F[7] <= {C[7], C[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       C <= {C[7], C[7:1]}; end
                                                                     3'b010 : begin    F[4] <= D[0];
                                                                                       F[7] <= {D[7], D[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       D <= {D[7], D[7:1]}; end
                                                                     3'b011 : begin    F[4] <= E[0];
                                                                                       F[7] <= {E[7], E[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       E <= {E[7], E[7:1]}; end
                                                                     3'b100 : begin    F[4] <= H[0];
                                                                                       F[7] <= {H[7], H[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       H <= {H[7], H[7:1]}; end
                                                                     3'b101 : begin    F[4] <= L[0];
                                                                                       F[7] <= {L[7], L[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       L <= {L[7], L[7:1]}; end
                                                                     3'b111 : begin    F[4] <= A[0];
                                                                                       F[7] <= {A[7], A[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       A <= {A[7], A[7:1]}; end
                                                                  endcase
                                                                  CurrentTCycle <= CurrentTCycle + 3'd1;
                                                               end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                                    
                                 ////////////////
                                 ////SRA (HL)////
                                 ////////////////
                                 8'b00101110 :
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin A_cpu <= {H, L};
                                                                     rd <= 1'b1;
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= CurrentMCycle + 3'd1; end
                                                   endcase
                                          3'd2 :   case (CurrentTCycle)
                                                      3'd0 :   begin rd <= 1'b0;
                                                                     F[6] <= 1'b0;
                                                                     F[5] <= 1'b0;
                                                                     F[4] <= Di_cpu[0];
                                                                     F[7] <= {Di_cpu[7], Di_cpu[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                     Do_cpu <= {Di_cpu[7], Di_cpu[7:1]};
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd1 :   begin wr <= 1'b1;
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd2 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd3 :   begin wr <= 1'b0;
                                                                     CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= CurrentMCycle + 3'd1; end
                                                   endcase
                                          3'd3 :   case (CurrentTCycle)
                                                      3'd0 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd1 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd2 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                                    
                                 /////////////
                                 ////SRL r////
                                 /////////////
                                 8'b00111000, 8'b00111001, 8'b00111010, 8'b00111011, 8'b00111100, 8'b00111101, 8'b00111111 :
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin    
                                                                  F[6] <= 1'b0;
                                                                  F[5] <= 1'b0;
                                                                  case(CB[2:0])
                                                                     3'b000 : begin    F[4] <= B[0];
                                                                                       F[7] <= {1'b0, B[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       B <= {1'b0, B[7:1]}; end
                                                                     3'b001 : begin    F[4] <= C[0];
                                                                                       F[7] <= {1'b0, C[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       C <= {1'b0, C[7:1]}; end
                                                                     3'b010 : begin    F[4] <= D[0];
                                                                                       F[7] <= {1'b0, D[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       D <= {1'b0, D[7:1]}; end
                                                                     3'b011 : begin    F[4] <= E[0];
                                                                                       F[7] <= {1'b0, E[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       E <= {1'b0, E[7:1]}; end
                                                                     3'b100 : begin    F[4] <= H[0];
                                                                                       F[7] <= {1'b0, H[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       H <= {1'b0, H[7:1]}; end
                                                                     3'b101 : begin    F[4] <= L[0];
                                                                                       F[7] <= {1'b0, L[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       L <= {1'b0, L[7:1]}; end
                                                                     3'b111 : begin    F[4] <= A[0];
                                                                                       F[7] <= {1'b0, A[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       A <= {1'b0, A[7:1]}; end
                                                                  endcase
                                                                  CurrentTCycle <= CurrentTCycle + 3'd1;
                                                               end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                                    
                                 ////////////////
                                 ////SRL (HL)////
                                 ////////////////
                                 8'b00111110 :
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin A_cpu <= {H, L};
                                                                     rd <= 1'b1;
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= CurrentMCycle + 3'd1; end
                                                   endcase
                                          3'd2 :   case (CurrentTCycle)
                                                      3'd0 :   begin rd <= 1'b0;
                                                                     F[6] <= 1'b0;
                                                                     F[5] <= 1'b0;
                                                                     F[4] <= Di_cpu[0];
                                                                     F[7] <= {1'b0, Di_cpu[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                     Do_cpu <= {1'b0, Di_cpu[7:1]};
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd1 :   begin wr <= 1'b1;
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd2 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd3 :   begin wr <= 1'b0;
                                                                     CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= CurrentMCycle + 3'd1; end
                                                   endcase
                                          3'd3 :   case (CurrentTCycle)
                                                      3'd0 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd1 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd2 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                                    
                                    
                                 //////////////
                                 ////SWAP r////
                                 //////////////
                                 8'b00110000, 8'b00110001, 8'b00110010, 8'b00110011, 8'b00110100, 8'b00110101, 8'b00110111 :
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin    
                                                                  F[6] <= 1'b0;
                                                                  F[5] <= 1'b0;
                                                                  F[4] <= 1'b0;
                                                                  case(CB[2:0])
                                                                     3'b000 : begin    F[7] <= {B[3:0], B[7:4]} == 0 ? 1'b1 : 1'b0;
                                                                                       B <= {B[3:0], B[7:4]}; end
                                                                     3'b001 : begin    F[7] <= {C[7:1], C[7:1]} == 0 ? 1'b1 : 1'b0;
                                                                                       C <= {C[3:0], C[7:4]}; end
                                                                     3'b010 : begin    F[7] <= {D[3:0], D[7:4]} == 0 ? 1'b1 : 1'b0;
                                                                                       D <= {D[3:0], D[7:4]}; end
                                                                     3'b011 : begin    F[7] <= {E[3:0], E[7:4]} == 0 ? 1'b1 : 1'b0;
                                                                                       E <= {E[3:0], E[7:4]}; end
                                                                     3'b100 : begin    F[7] <= {H[3:0], H[7:4]} == 0 ? 1'b1 : 1'b0;
                                                                                       H <= {H[3:0], H[7:4]}; end
                                                                     3'b101 : begin    F[7] <= {L[3:0], L[7:4]} == 0 ? 1'b1 : 1'b0;
                                                                                       L <= {L[3:0], L[7:4]}; end
                                                                     3'b111 : begin    F[7] <= {A[3:0], A[7:4]} == 0 ? 1'b1 : 1'b0;
                                                                                       A <= {A[3:0], A[7:4]}; end
                                                                  endcase
                                                                  CurrentTCycle <= CurrentTCycle + 3'd1;
                                                               end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                                    
                                 /////////////////
                                 ////SWAP (HL)////
                                 /////////////////
                                 8'b00110110 :
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin A_cpu <= {H, L};
                                                                     rd <= 1'b1;
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= CurrentMCycle + 3'd1; end
                                                   endcase
                                          3'd2 :   case (CurrentTCycle)
                                                      3'd0 :   begin rd <= 1'b0;
                                                                     F[6] <= 1'b0;
                                                                     F[5] <= 1'b0;
                                                                     F[4] <= 1'b0;
                                                                     F[7] <= {Di_cpu[3:0], Di_cpu[7:4]} == 0 ? 1'b1 : 1'b0;
                                                                     Do_cpu <= {Di_cpu[3:0], Di_cpu[7:4]};
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd1 :   begin wr <= 1'b1;
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd2 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd3 :   begin wr <= 1'b0;
                                                                     CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= CurrentMCycle + 3'd1; end
                                                   endcase
                                          3'd3 :   case (CurrentTCycle)
                                                      3'd0 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd1 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd2 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                                    
                                 ////////////////
                                 ////BIT b, r////
                                 ////////////////
                                 
                                 8'b01000000, 8'b01000001, 8'b01000010, 8'b01000011, 8'b01000100, 8'b01000101, 8'b01000111,
                                 8'b01001000, 8'b01001001, 8'b01001010, 8'b01001011, 8'b01001100, 8'b01001101, 8'b01001111,
                                 8'b01010000, 8'b01010001, 8'b01010010, 8'b01010011, 8'b01010100, 8'b01010101, 8'b01010111,
                                 8'b01011000, 8'b01011001, 8'b01011010, 8'b01011011, 8'b01011100, 8'b01011101, 8'b01011111,
                                 8'b01100000, 8'b01100001, 8'b01100010, 8'b01100011, 8'b01100100, 8'b01100101, 8'b01100111,
                                 8'b01101000, 8'b01101001, 8'b01101010, 8'b01101011, 8'b01101100, 8'b01101101, 8'b01101111,
                                 8'b01110000, 8'b01110001, 8'b01110010, 8'b01110011, 8'b01110100, 8'b01110101, 8'b01110111,
                                 8'b01111000, 8'b01111001, 8'b01111010, 8'b01111011, 8'b01111100, 8'b01111101, 8'b01111111 :
                                 
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin    
                                                                  F[6] <= 1'b0;
                                                                  F[5] <= 1'b1;
                                                                  case(CB[2:0])
                                                                     3'b000 : begin
                                                                                 case(CB[5:3])
                                                                                    3'b000 : F[7] <= ~B[0]; 
                                                                                    3'b001 : F[7] <= ~B[1];
                                                                                    3'b010 : F[7] <= ~B[2];
                                                                                    3'b011 : F[7] <= ~B[3];
                                                                                    3'b100 : F[7] <= ~B[4];
                                                                                    3'b101 : F[7] <= ~B[5];
                                                                                    3'b110 : F[7] <= ~B[6];
                                                                                    3'b111 : F[7] <= ~B[7];
                                                                                 endcase
                                                                              end
                                                                     3'b001 : begin
                                                                                 case(CB[5:3])
                                                                                    3'b000 : F[7] <= ~C[0]; 
                                                                                    3'b001 : F[7] <= ~C[1];
                                                                                    3'b010 : F[7] <= ~C[2];
                                                                                    3'b011 : F[7] <= ~C[3];
                                                                                    3'b100 : F[7] <= ~C[4];
                                                                                    3'b101 : F[7] <= ~C[5];
                                                                                    3'b110 : F[7] <= ~C[6];
                                                                                    3'b111 : F[7] <= ~C[7];
                                                                                 endcase
                                                                              end
                                                                     3'b010 : begin
                                                                                 case(CB[5:3])
                                                                                    3'b000 : F[7] <= ~D[0]; 
                                                                                    3'b001 : F[7] <= ~D[1];
                                                                                    3'b010 : F[7] <= ~D[2];
                                                                                    3'b011 : F[7] <= ~D[3];
                                                                                    3'b100 : F[7] <= ~D[4];
                                                                                    3'b101 : F[7] <= ~D[5];
                                                                                    3'b110 : F[7] <= ~D[6];
                                                                                    3'b111 : F[7] <= ~D[7];
                                                                                 endcase
                                                                              end
                                                                     3'b011 : begin
                                                                                 case(CB[5:3])
                                                                                    3'b000 : F[7] <= ~E[0]; 
                                                                                    3'b001 : F[7] <= ~E[1];
                                                                                    3'b010 : F[7] <= ~E[2];
                                                                                    3'b011 : F[7] <= ~E[3];
                                                                                    3'b100 : F[7] <= ~E[4];
                                                                                    3'b101 : F[7] <= ~E[5];
                                                                                    3'b110 : F[7] <= ~E[6];
                                                                                    3'b111 : F[7] <= ~E[7];
                                                                                 endcase
                                                                              end
                                                                     3'b100 : begin
                                                                                 case(CB[5:3])
                                                                                    3'b000 : F[7] <= ~H[0]; 
                                                                                    3'b001 : F[7] <= ~H[1];
                                                                                    3'b010 : F[7] <= ~H[2];
                                                                                    3'b011 : F[7] <= ~H[3];
                                                                                    3'b100 : F[7] <= ~H[4];
                                                                                    3'b101 : F[7] <= ~H[5];
                                                                                    3'b110 : F[7] <= ~H[6];
                                                                                    3'b111 : F[7] <= ~H[7];
                                                                                 endcase
                                                                              end
                                                                     3'b101 : begin
                                                                                 case(CB[5:3])
                                                                                    3'b000 : F[7] <= ~L[0]; 
                                                                                    3'b001 : F[7] <= ~L[1];
                                                                                    3'b010 : F[7] <= ~L[2];
                                                                                    3'b011 : F[7] <= ~L[3];
                                                                                    3'b100 : F[7] <= ~L[4];
                                                                                    3'b101 : F[7] <= ~L[5];
                                                                                    3'b110 : F[7] <= ~L[6];
                                                                                    3'b111 : F[7] <= ~L[7];
                                                                                 endcase
                                                                              end
                                                                     3'b111 : begin
                                                                                 case(CB[5:3])
                                                                                    3'b000 : F[7] <= ~A[0]; 
                                                                                    3'b001 : F[7] <= ~A[1];
                                                                                    3'b010 : F[7] <= ~A[2];
                                                                                    3'b011 : F[7] <= ~A[3];
                                                                                    3'b100 : F[7] <= ~A[4];
                                                                                    3'b101 : F[7] <= ~A[5];
                                                                                    3'b110 : F[7] <= ~A[6];
                                                                                    3'b111 : F[7] <= ~A[7];
                                                                                 endcase
                                                                              end
                                                                  endcase
                                                                  CurrentTCycle <= CurrentTCycle + 3'd1;
                                                               end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                                    
                                 ///////////////////
                                 ////BIT b, (HL)////
                                 ///////////////////
                                 
                                 8'b01000110, 8'b01001110, 8'b01010110, 8'b01011110, 8'b01100110, 8'b01101110, 8'b01110110, 8'b01111110 :
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin A_cpu <= {H, L};
                                                                     rd <= 1'b1;
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= CurrentMCycle + 3'd1; end
                                                   endcase
                                          3'd2 :   case (CurrentTCycle)
                                                      3'd0 :   begin rd <= 1'b0;
                                                                     F[6] <= 1'b0;
                                                                     F[5] <= 1'b1;
                                                                     case(CB[5:3])
                                                                        3'b000 : F[7] <= ~Di_cpu[0]; 
                                                                        3'b001 : F[7] <= ~Di_cpu[1];
                                                                        3'b010 : F[7] <= ~Di_cpu[2];
                                                                        3'b011 : F[7] <= ~Di_cpu[3];
                                                                        3'b100 : F[7] <= ~Di_cpu[4];
                                                                        3'b101 : F[7] <= ~Di_cpu[5];
                                                                        3'b110 : F[7] <= ~Di_cpu[6];
                                                                        3'b111 : F[7] <= ~Di_cpu[7];
                                                                     endcase
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd1 :   begin CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd2 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                                    
                                 ////////////////////
                                 ////SET/RES b, r////
                                 ////////////////////
                                 
                                 8'b11000000, 8'b11000001, 8'b11000010, 8'b11000011, 8'b11000100, 8'b11000101, 8'b11000111,
                                 8'b11001000, 8'b11001001, 8'b11001010, 8'b11001011, 8'b11001100, 8'b11001101, 8'b11001111,
                                 8'b11010000, 8'b11010001, 8'b11010010, 8'b11010011, 8'b11010100, 8'b11010101, 8'b11010111,
                                 8'b11011000, 8'b11011001, 8'b11011010, 8'b11011011, 8'b11011100, 8'b11011101, 8'b11011111,
                                 8'b11100000, 8'b11100001, 8'b11100010, 8'b11100011, 8'b11100100, 8'b11100101, 8'b11100111,
                                 8'b11101000, 8'b11101001, 8'b11101010, 8'b11101011, 8'b11101100, 8'b11101101, 8'b11101111,
                                 8'b11110000, 8'b11110001, 8'b11110010, 8'b11110011, 8'b11110100, 8'b11110101, 8'b11110111,
                                 8'b11111000, 8'b11111001, 8'b11111010, 8'b11111011, 8'b11111100, 8'b11111101, 8'b11111111,
                                
                                 8'b10000000, 8'b10000001, 8'b10000010, 8'b10000011, 8'b10000100, 8'b10000101, 8'b10000111,
                                 8'b10001000, 8'b10001001, 8'b10001010, 8'b10001011, 8'b10001100, 8'b10001101, 8'b10001111,
                                 8'b10010000, 8'b10010001, 8'b10010010, 8'b10010011, 8'b10010100, 8'b10010101, 8'b10010111,
                                 8'b10011000, 8'b10011001, 8'b10011010, 8'b10011011, 8'b10011100, 8'b10011101, 8'b10011111,
                                 8'b10100000, 8'b10100001, 8'b10100010, 8'b10100011, 8'b10100100, 8'b10100101, 8'b10100111,
                                 8'b10101000, 8'b10101001, 8'b10101010, 8'b10101011, 8'b10101100, 8'b10101101, 8'b10101111,
                                 8'b10110000, 8'b10110001, 8'b10110010, 8'b10110011, 8'b10110100, 8'b10110101, 8'b10110111,
                                 8'b10111000, 8'b10111001, 8'b10111010, 8'b10111011, 8'b10111100, 8'b10111101, 8'b10111111 :
                                 
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin    
                                                                  case(CB[2:0])
                                                                     3'b000 : begin
                                                                                 case(CB[5:3])
                                                                                    3'b000 : B[0] <= CB[6] ? 1'b1 : 1'b0; 
                                                                                    3'b001 : B[1] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b010 : B[2] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b011 : B[3] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b100 : B[4] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b101 : B[5] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b110 : B[6] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b111 : B[7] <= CB[6] ? 1'b1 : 1'b0;
                                                                                 endcase
                                                                              end
                                                                     3'b001 : begin
                                                                                 case(CB[5:3])
                                                                                    3'b000 : C[0] <= CB[6] ? 1'b1 : 1'b0; 
                                                                                    3'b001 : C[1] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b010 : C[2] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b011 : C[3] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b100 : C[4] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b101 : C[5] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b110 : C[6] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b111 : C[7] <= CB[6] ? 1'b1 : 1'b0;
                                                                                 endcase
                                                                              end
                                                                     3'b010 : begin
                                                                                 case(CB[5:3])
                                                                                    3'b000 : D[0] <= CB[6] ? 1'b1 : 1'b0; 
                                                                                    3'b001 : D[1] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b010 : D[2] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b011 : D[3] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b100 : D[4] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b101 : D[5] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b110 : D[6] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b111 : D[7] <= CB[6] ? 1'b1 : 1'b0;
                                                                                 endcase
                                                                              end
                                                                     3'b011 : begin
                                                                                 case(CB[5:3])
                                                                                    3'b000 : E[0] <= CB[6] ? 1'b1 : 1'b0; 
                                                                                    3'b001 : E[1] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b010 : E[2] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b011 : E[3] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b100 : E[4] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b101 : E[5] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b110 : E[6] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b111 : E[7] <= CB[6] ? 1'b1 : 1'b0;
                                                                                 endcase
                                                                              end
                                                                     3'b100 : begin
                                                                                 case(CB[5:3])
                                                                                    3'b000 : H[0] <= CB[6] ? 1'b1 : 1'b0; 
                                                                                    3'b001 : H[1] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b010 : H[2] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b011 : H[3] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b100 : H[4] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b101 : H[5] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b110 : H[6] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b111 : H[7] <= CB[6] ? 1'b1 : 1'b0;
                                                                                 endcase
                                                                              end
                                                                     3'b101 : begin
                                                                                 case(CB[5:3])
                                                                                    3'b000 : L[0] <= CB[6] ? 1'b1 : 1'b0; 
                                                                                    3'b001 : L[1] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b010 : L[2] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b011 : L[3] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b100 : L[4] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b101 : L[5] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b110 : L[6] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b111 : L[7] <= CB[6] ? 1'b1 : 1'b0;
                                                                                 endcase
                                                                              end
                                                                     3'b111 : begin
                                                                                 case(CB[5:3])
                                                                                    3'b000 : A[0] <= CB[6] ? 1'b1 : 1'b0; 
                                                                                    3'b001 : A[1] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b010 : A[2] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b011 : A[3] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b100 : A[4] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b101 : A[5] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b110 : A[6] <= CB[6] ? 1'b1 : 1'b0;
                                                                                    3'b111 : A[7] <= CB[6] ? 1'b1 : 1'b0;
                                                                                 endcase
                                                                              end
                                                                  endcase
                                                                  CurrentTCycle <= CurrentTCycle + 3'd1;
                                                               end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                                    
                                 ///////////////////////
                                 ////SET/RES b, (HL)////
                                 ///////////////////////
                                 
                                 8'b11000110, 8'b11001110, 8'b11010110, 8'b11011110, 8'b11100110, 8'b11101110, 8'b11110110, 8'b11111110,
                                 8'b10000110, 8'b10001110, 8'b10010110, 8'b10011110, 8'b10100110, 8'b10101110, 8'b10110110, 8'b10111110   :
                                    begin
                                       case(CurrentMCycle)
                                          3'd1 :   case (CurrentTCycle)
                                                      3'd2 :   begin A_cpu <= {H, L};
                                                                     rd <= 1'b1;
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= CurrentMCycle + 3'd1; end
                                                   endcase
                                          3'd2 :   case (CurrentTCycle)
                                                      3'd0 :   begin rd <= 1'b0;
                                                                     case(CB[5:3])
                                                                        3'b000 : Do_cpu <= CB[6] ? (Di_cpu | 8'b00000001) : (Di_cpu & 8'b11111110); 
                                                                        3'b001 : Do_cpu <= CB[6] ? (Di_cpu | 8'b00000010) : (Di_cpu & 8'b11111101);
                                                                        3'b010 : Do_cpu <= CB[6] ? (Di_cpu | 8'b00000100) : (Di_cpu & 8'b11111011);
                                                                        3'b011 : Do_cpu <= CB[6] ? (Di_cpu | 8'b00001000) : (Di_cpu & 8'b11110111);
                                                                        3'b100 : Do_cpu <= CB[6] ? (Di_cpu | 8'b00010000) : (Di_cpu & 8'b11101111);
                                                                        3'b101 : Do_cpu <= CB[6] ? (Di_cpu | 8'b00100000) : (Di_cpu & 8'b11011111);
                                                                        3'b110 : Do_cpu <= CB[6] ? (Di_cpu | 8'b01000000) : (Di_cpu & 8'b10111111);
                                                                        3'b111 : Do_cpu <= CB[6] ? (Di_cpu | 8'b10000000) : (Di_cpu & 8'b01111111);
                                                                     endcase
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd1 :   begin wr <= 1'b1;
                                                                     CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd2 :   CurrentTCycle <= CurrentTCycle + 3'd1;
                                                      3'd3 :   begin wr <= 1'b0;
                                                                     CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= CurrentMCycle + 3'd1; end
                                                   endcase
                                          3'd3 :   case (CurrentTCycle)
                                                      3'd0 :   begin CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd1 :   begin CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd2 :   begin CurrentTCycle <= CurrentTCycle + 3'd1; end
                                                      3'd3 :   begin CurrentTCycle <= 3'd0;
                                                                     CurrentMCycle <= 3'd0; end
                                                   endcase
                                       endcase
                                    end
                              /////////////  
                                 
                              endcase
                           end
                            
               end  
                                    
            /////////      
            //JP nn//
            /////////

            8'b11000011 :
            
               begin
                  case(CurrentMCycle)
                     3'd0  :  case (CurrentTCycle)
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase     
                  
                     3'd1  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= A_cpu + 16'd1;
                                                   rd <= 1'b1;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    PC[7:0] <= Di_cpu;
                                                   rd <= 1'b0;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase
                     3'd2  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= A_cpu + 16'd1;
                                                   rd <= 1'b1;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    PC[15:8] <= Di_cpu;
                                                   rd <= 1'b0;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= 3'd0;                       end
                              endcase
                  endcase
               end
               
            /////////////      
            //JP cc, nn//
            /////////////

            8'b11000010, 8'b11001010, 8'b11010010, 8'b11011010 :
            
               begin
                  case(CurrentMCycle)
                     3'd0  :  case (CurrentTCycle)
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase     
                  
                     3'd1  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= A_cpu + 16'd1;
                                                   rd <= 1'b1;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    case(CI[4:3])
                                                      2'b00 :  if(F[7] == 0) PC[7:0] <= Di_cpu; else PC <= PC + 3'd3;
                                                      2'b01 :  if(F[7] == 1) PC[7:0] <= Di_cpu; else PC <= PC + 3'd3;
                                                      2'b10 :  if(F[4] == 0) PC[7:0] <= Di_cpu; else PC <= PC + 3'd3;
                                                      2'b11 :  if(F[4] == 1) PC[7:0] <= Di_cpu; else PC <= PC + 3'd3;
                                                   endcase
                                                   rd <= 1'b0;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase
                     3'd2  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= A_cpu + 16'd1;
                                                   rd <= 1'b1;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    case(CI[4:3])
                                                      2'b00 :  if(F[7] == 0) PC[15:8] <= Di_cpu;
                                                      2'b01 :  if(F[7] == 1) PC[15:8] <= Di_cpu;
                                                      2'b10 :  if(F[4] == 0) PC[15:8] <= Di_cpu;
                                                      2'b11 :  if(F[4] == 1) PC[15:8] <= Di_cpu;
                                                   endcase
                                                   rd <= 1'b0;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    case(CI[4:3])
                                                      2'b00 :  if(F[7] == 0) CurrentMCycle <= CurrentMCycle + 3'd1;  else CurrentMCycle <= 3'd0; 
                                                      2'b01 :  if(F[7] == 1) CurrentMCycle <= CurrentMCycle + 3'd1;  else CurrentMCycle <= 3'd0;
                                                      2'b10 :  if(F[4] == 0) CurrentMCycle <= CurrentMCycle + 3'd1;  else CurrentMCycle <= 3'd0;
                                                      2'b11 :  if(F[4] == 1) CurrentMCycle <= CurrentMCycle + 3'd1;  else CurrentMCycle <= 3'd0;
                                                   endcase
                                                   CurrentTCycle <= 3'd0;                       end
                              endcase
                     3'd3  :  case (CurrentTCycle)
                                 3'd0  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= 3'd0;                       end
                              endcase
                  endcase
               end  

            /////////      
            //JR r8//
            /////////

            8'b00011000 :
            
               begin
                  case(CurrentMCycle)
                     3'd0  :  case (CurrentTCycle)
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase     
                  
                     3'd1  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= A_cpu + 16'd1;
                                                   rd <= 1'b1;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    PC <= PC + $signed(Di_cpu) + 2'd2;
                                                   rd <= 1'b0;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase
                     3'd2  :  case (CurrentTCycle)
                                 3'd0  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= 3'd0;                       end
                              endcase
                  endcase
               end

            /////////////      
            //JR cc, r8//
            /////////////

            8'b00100000, 8'b00101000, 8'b00110000, 8'b00111000 :
            
               begin
                  case(CurrentMCycle)
                     3'd0  :  case (CurrentTCycle)
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase     
                  
                     3'd1  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= A_cpu + 16'd1;
                                                   rd <= 1'b1;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    case(CI[4:3])
                                                      2'b00 :  if(F[7] == 0) PC <= PC + $signed(Di_cpu) + 2'd2; else PC <= PC + 3'd2;
                                                      2'b01 :  if(F[7] == 1) PC <= PC + $signed(Di_cpu) + 2'd2; else PC <= PC + 3'd2;
                                                      2'b10 :  if(F[4] == 0) PC <= PC + $signed(Di_cpu) + 2'd2; else PC <= PC + 3'd2;
                                                      2'b11 :  if(F[4] == 1) PC <= PC + $signed(Di_cpu) + 2'd2; else PC <= PC + 3'd2;
                                                   endcase
                                                   rd <= 1'b0;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    case(CI[4:3])
                                                      2'b00 :  if(F[7] == 0) CurrentMCycle <= CurrentMCycle + 3'd1;  else CurrentMCycle <= 3'd0; 
                                                      2'b01 :  if(F[7] == 1) CurrentMCycle <= CurrentMCycle + 3'd1;  else CurrentMCycle <= 3'd0;
                                                      2'b10 :  if(F[4] == 0) CurrentMCycle <= CurrentMCycle + 3'd1;  else CurrentMCycle <= 3'd0;
                                                      2'b11 :  if(F[4] == 1) CurrentMCycle <= CurrentMCycle + 3'd1;  else CurrentMCycle <= 3'd0;
                                                   endcase
                                                   CurrentTCycle <= 3'd0; end
                              endcase
                     3'd2  :  case (CurrentTCycle)
                                 3'd0  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= 3'd0;                       end
                              endcase
                  endcase
               end  

            ///////////      
            //JP (HL)//
            ///////////

            8'b11101001 :
            
               begin
                  case(CurrentMCycle)
                     3'd0  :  case (CurrentTCycle)
                                 3'd3  :  begin    PC <= {H, L};
                                                   CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= 3'd0;       end
                              endcase
                  endcase
               end
               
            ///////////////      
            //CALL cc, nn//
            ///////////////

            8'b11000100, 8'b11001100, 8'b11010100, 8'b11011100 :

               begin
                  case(CurrentMCycle)
                     3'd0  :  case (CurrentTCycle)
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;
                                                   PC <= PC + 2'd3;  end
                              endcase     
                  
                     3'd1  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= SP - 2'd1;
                                                   Do_cpu <= PC[15:8];
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    case(CI[4:3])
                                                      2'b00 :  if(F[7] == 0) wr <= 1'b1;
                                                      2'b01 :  if(F[7] == 1) wr <= 1'b1;
                                                      2'b10 :  if(F[4] == 0) wr <= 1'b1;
                                                      2'b11 :  if(F[4] == 1) wr <= 1'b1;
                                                   endcase
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    wr <= 1'b0;
                                                   CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase
                     3'd2  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= SP - 2'd2;
                                                   Do_cpu <= PC[7:0];
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    case(CI[4:3])
                                                      2'b00 :  if(F[7] == 0) wr <= 1'b1;
                                                      2'b01 :  if(F[7] == 1) wr <= 1'b1;
                                                      2'b10 :  if(F[4] == 0) wr <= 1'b1;
                                                      2'b11 :  if(F[4] == 1) wr <= 1'b1;
                                                   endcase
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    wr <= 1'b0;
                                                   CurrentTCycle <= 3'd0;
                                                   case(CI[4:3])
                                                      2'b00 :  if(F[7] == 0) CurrentMCycle <= CurrentMCycle + 3'd1;  else CurrentMCycle <= 3'd0; 
                                                      2'b01 :  if(F[7] == 1) CurrentMCycle <= CurrentMCycle + 3'd1;  else CurrentMCycle <= 3'd0;
                                                      2'b10 :  if(F[4] == 0) CurrentMCycle <= CurrentMCycle + 3'd1;  else CurrentMCycle <= 3'd0;
                                                      2'b11 :  if(F[4] == 1) CurrentMCycle <= CurrentMCycle + 3'd1;  else CurrentMCycle <= 3'd0;
                                                   endcase
                                          end
                              endcase
                     3'd3  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= PC - 2'd2;
                                                   rd <= 1'b1;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    PC[7:0] <= Di_cpu;
                                                   rd <= 1'b0;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase
                     3'd4  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= A_cpu + 1'b1;
                                                   rd <= 1'b1;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    PC[15:8] <= Di_cpu;
                                                   rd <= 1'b0;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase
                     3'd5  :  case (CurrentTCycle)
                                 3'd0  :  begin    SP <= SP - 2'd2;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= 3'd0;                       end
                              endcase
                  endcase
               end
                 
            ///////////      
            //CALL nn//
            ///////////

           
            8'b11001101 :
            
               begin
                  case(CurrentMCycle)
                     3'd0  :  case (CurrentTCycle)
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;
                                                   PC <= PC + 2'd3;  end
                              endcase     
                  
                     3'd1  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= SP - 2'd1;
                                                   Do_cpu <= PC[15:8];
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    wr <= 1'b1;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    wr <= 1'b0;
                                                   CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase
                     3'd2  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= SP - 2'd2;
                                                   Do_cpu <= PC[7:0];
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    wr <= 1'b1;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    wr <= 1'b0;
                                                   CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase
                     3'd3  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= PC - 2'd2;
                                                   rd <= 1'b1;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    PC[7:0] <= Di_cpu;
                                                   rd <= 1'b0;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase
                     3'd4  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= A_cpu + 1'b1;
                                                   rd <= 1'b1;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    PC[15:8] <= Di_cpu;
                                                   rd <= 1'b0;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase
                     3'd5  :  case (CurrentTCycle)
                                 3'd0  :  begin    SP <= SP - 2'd2;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= 3'd0;                       end
                              endcase
                  endcase
               end       
       
            /////////////      
            //RET/ RETI//
            /////////////

           
            8'b11001001, 8'b11011001 :
            
               begin
                  case(CurrentMCycle)
                     3'd0  :  case (CurrentTCycle)
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;
                                                   if(CI[4:3] == 2'b11) IME <= 1'b1; end
                              endcase     
                  
                     3'd1  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= SP;
                                                   rd <= 1'b1;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    PC[7:0] <= Di_cpu;
                                                   rd <= 1'b0;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase
                     3'd2  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= SP + 1'b1;
                                                   rd <= 1'b1;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    PC[15:8] <= Di_cpu;
                                                   rd <= 1'b0;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase
                     3'd3  :  case (CurrentTCycle)
                                 3'd0  :  begin    SP <= SP + 2'd2;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= 3'd0;       end
                              endcase
                  endcase
               end   
            
            //////////      
            //RET cc//
            //////////

           
            8'b11000000, 8'b11001000, 8'b11010000, 8'b11011000 :
            
               begin
                  case(CurrentMCycle)
                     3'd0  :  case (CurrentTCycle)
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;
                                                   PC <= PC + 1'b1;  end
                              endcase     
                  
                     3'd1  :  case (CurrentTCycle)
                                 3'd0  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   case(CI[4:3])
                                                      2'b00 :  if(F[7] == 0) CurrentMCycle <= CurrentMCycle + 3'd1;  else CurrentMCycle <= 3'd0; 
                                                      2'b01 :  if(F[7] == 1) CurrentMCycle <= CurrentMCycle + 3'd1;  else CurrentMCycle <= 3'd0;
                                                      2'b10 :  if(F[4] == 0) CurrentMCycle <= CurrentMCycle + 3'd1;  else CurrentMCycle <= 3'd0;
                                                      2'b11 :  if(F[4] == 1) CurrentMCycle <= CurrentMCycle + 3'd1;  else CurrentMCycle <= 3'd0;
                                                   endcase
                                          end
                              endcase
                     3'd2  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= SP;
                                                   rd <= 1'b1;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    PC[7:0] <= Di_cpu;
                                                   rd <= 1'b0;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase
                     3'd3  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= SP + 1'b1;
                                                   rd <= 1'b1;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    PC[15:8] <= Di_cpu;
                                                   rd <= 1'b0;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase
                     3'd4  :  case (CurrentTCycle)
                                 3'd0  :  begin    SP <= SP + 2'd2;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= 3'd0;       end
                              endcase
                  endcase
               end   
               
            /////////      
            //RST t//
            /////////

           
            8'b11000111, 8'b11001111, 8'b11010111, 8'b11011111, 8'b11100111, 8'b11101111, 8'b11110111, 8'b11111111, :
            
               begin
                  case(CurrentMCycle)
                     3'd0  :  case (CurrentTCycle)
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1; 
                                                   PC <= PC + 1'b1;  end
                              endcase     
                  
                     3'd1  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= SP - 1'b1;
                                                   Do_cpu <= PC[15:8];
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    wr <= 1'b1;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    wr <= 1'b0;
                                                   CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase
                     3'd2  :  case (CurrentTCycle)
                                 3'd0  :  begin    A_cpu <= SP - 2'd2;
                                                   Do_cpu <= PC[7:0];
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    wr <= 1'b1;
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    wr <= 1'b0;
                                                   CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= CurrentMCycle + 3'd1;       end
                              endcase
                     3'd3  :  case (CurrentTCycle)
                                 3'd0  :  begin    SP <= SP - 2'd2;
                                                   PC[15:8] <= 8'b0;
                                                   case(CI[5:3])
                                                      3'b000 : PC[7:0] <= 8'h00; 
                                                      3'b001 : PC[7:0] <= 8'h08;
                                                      3'b010 : PC[7:0] <= 8'h10;
                                                      3'b011 : PC[7:0] <= 8'h18;
                                                      3'b100 : PC[7:0] <= 8'h20;
                                                      3'b101 : PC[7:0] <= 8'h28;
                                                      3'b110 : PC[7:0] <= 8'h30;
                                                      3'b111 : PC[7:0] <= 8'h38;
                                                   endcase
                                                   CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd1  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd2  :  begin    CurrentTCycle <= CurrentTCycle + 3'd1;       end
                                 3'd3  :  begin    CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= 3'd0;       end
                              endcase
                  endcase
               end 
         
      
            ///////      
            //CPL//
            ///////
           
            8'b00101111 :
            
               begin
                  case(CurrentMCycle)
                     3'd0  :  case (CurrentTCycle)
                                 3'd3  :  begin    PC <= PC + 1'b1;
                                                   A <= ~A;
                                                   F[5] <= 1'b1;
                                                   F[6] <= 1'b1;
                                                   CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= 3'd0;       end
                              endcase     
                  endcase
               end  
               
            ///////      
            //NOP//
            ///////
           
            8'b0000000 :
            
               begin
                  case(CurrentMCycle)
                     3'd0  :  case (CurrentTCycle)
                                 3'd3  :  begin    PC <= PC + 1'b1;
                                                   CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= 3'd0;       end
                              endcase     
                  endcase
               end  
               
            ///////      
            //CCF//
            ///////
           
            8'b00111111 :
            
               begin
                  case(CurrentMCycle)
                     3'd0  :  case (CurrentTCycle)
                                 3'd3  :  begin    PC <= PC + 1'b1;
                                                   F[4] <= ~F[4];
                                                   F[5] <= 1'b0;
                                                   F[6] <= 1'b0;
                                                   CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= 3'd0;       end
                              endcase     
                  endcase
               end    
        
            ///////      
            //SCF//
            ///////
           
            8'b00110111 :
            
               begin
                  case(CurrentMCycle)
                     3'd0  :  case (CurrentTCycle)
                                 3'd3  :  begin    PC <= PC + 1'b1;
                                                   F[4] <= 1'b1;
                                                   F[5] <= 1'b0;
                                                   F[6] <= 1'b0;
                                                   CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= 3'd0;       end
                              endcase     
                  endcase
               end          
     
     
            //////      
            //DI//
            //////
           
            8'b11110011 :
            
               begin
                  case(CurrentMCycle)
                     3'd0  :  case (CurrentTCycle)
                                 3'd3  :  begin    PC <= PC + 1'b1;
                                                   IME <= 1'b0;
                                                   CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= 3'd0;       end
                              endcase     
                  endcase
               end   
               
            //////      
            //EI//
            //////
           
            8'b11111011 :
            
               begin
                  case(CurrentMCycle)
                     3'd0  :  case (CurrentTCycle)
                                 3'd3  :  begin    PC <= PC + 1'b1;
                                                   IME <= 1'b1;
                                                   CurrentTCycle <= 3'd0;
                                                   CurrentMCycle <= 3'd0;       end
                              endcase     
                  endcase
               end   
               
   /////////////////////////              
         endcase
      end
   end
end
   

endmodule

