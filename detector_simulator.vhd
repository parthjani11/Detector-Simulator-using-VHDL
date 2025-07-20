----detector_line_serial


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.detector_16_pkg.all;



entity detector_simulator is
      port(
            rst:in STD_LOGIC;
--            line_clk:in std_logic;
            clk:in STD_LOGIC;
            -----DECLARATIONS FOR THE SERIAL DATA WHICH IS TO BE DISPLAYED-------
            line_clk_o:out std_logic;
            b1_ocnt_c:out std_logic:='0';
            b1_ecnt_c:out std_logic:='0';
            b2_ocnt_c:out std_logic:='0';
            b2_ecnt_c:out std_logic:='0';
            b3_ocnt_c:out std_logic:='0';
            b3_ecnt_c:out std_logic:='0';
            b4_ocnt_c:out std_logic:='0';
            b4_ecnt_c:out std_logic:='0';
            b5_ocnt_c:out std_logic:='0';
            b5_ecnt_c:out std_logic:='0';
            -----DECLARATIONS FOR THE MASTER CLOCK AND SERIAL CLOCK TO VERIFY---
            master1:out std_logic:='1';
            serial_2:out std_logic:='1';
            serial1:out std_logic:='1'
            );
            end detector_simulator;
            
architecture  cd of detector_simulator is

            signal master_cnt:std_logic_vector(7 downto 0):=x"00";--COUNT REGISTER FOR GENERATING MASTER CLOCK
            signal serial_cnt:std_logic_vector(3 downto 0):=x"0";--COUNT REGISTER FOR GENERATING SERIAL CLOCK
            signal serial_cnt1:std_logic_vector(3 downto 0):=x"0";
            -----integers to be declared to change serial data after each count and generate appropriate index value from parralel data to serial data example if 11th bit value to generate index=11 and serial=parralel[index]          
            signal bit_index : integer range 0 to 11 := 0;--declare bit index as per the bits in each pixel for an example 12 in our case
            signal bit_index4 : integer range 0 to 11 := 0;
            signal bit_index5 : integer range 0 to 11 := 0;

            -----DECLARATIONS FOR THE PARALLEL DATA WHICH IS TO BE DISPLAYED-------

            signal b1_ocnt:std_logic_vector(11 downto 0):=x"000";
            signal b1_ecnt:std_logic_vector(11 downto 0):=x"000";
            signal b2_ocnt:std_logic_vector(11 downto 0):=x"000";
            signal b2_ecnt:std_logic_vector(11 downto 0):=x"000";
            signal b3_ocnt:std_logic_vector(11 downto 0):=x"000";
            signal b3_ecnt:std_logic_vector(11 downto 0):=x"000";
            signal b4_ocnt:std_logic_vector(11 downto 0):=x"000";
            signal b4_ecnt:std_logic_vector(11 downto 0):=x"000";
            signal b5_ocnt:std_logic_vector(11 downto 0):=x"000";
            signal b5_ecnt:std_logic_vector(11 downto 0):=x"000";

            signal state_1:std_logic_vector(3 downto 0):=x"0";--REGISTER WHICH IS USED TO GENERATE STATE WISE DATA FOR FIRST 3 PAIRS OF ODD AND EVEN SIGNALS
            signal count:std_logic_vector(19 downto 0):=x"00000";--COUNT REGISTER USED TO COUNT CLOCKS FOR FIRST 3 PAIRS OF ODD AND EVEN SIGNALS 
            signal count4:std_logic_vector(19 downto 0):=x"00000";--COUNT REGISTER USED TO COUNT CLOCKS FOR FIRST 4TH PAIR OF ODD AND EVEN SIGNALS            
            signal state_4:std_logic_vector(3 downto 0):=x"0";--REGISTER WHICH IS USED TO GENERATE STATE WISE DATA FOR 4TH PAIR OF ODD AND EVEN SIGNALS
            signal count5:std_logic_vector(19 downto 0):=x"00000";--COUNT REGISTER USED TO COUNT CLOCKS FOR FIRST 5TH PAIR OF ODD AND EVEN SIGNALS           
            signal state_5:std_logic_vector(3 downto 0):=x"0";--REGISTER WHICH IS USED TO GENERATE STATE WISE DATA FOR 5TH PAIR OF ODD AND EVEN SIGNALS 
            

            -----REGISTERS FOR SERIAL DATA GENERATIONS ----------
            signal cnt:std_logic_vector(3 downto  0):=x"0";
            signal cnt1:std_logic_vector(3 downto  0):=x"0";
            signal cnt2:std_logic_vector(3 downto  0):=x"0";
            -----variables related to change parralel output after each 48 clock cycles
            signal cunt:std_logic_vector(7 downto 0):=x"00";
            signal cunt4:std_logic_vector(7 downto 0):=x"00";
            signal cunt5:std_logic_vector(7 downto 0):=x"00";

            signal master:std_logic:='1';--REGISTER FOR MASTER CLOCK GENERATION
            signal serial:std_logic:='1';--REGISTER FOR SERIAL CLOCK GENERATION
            signal serial2:std_logic:='1';

            signal first:std_logic_vector(7 downto 0):=x"2F";
            signal flame:std_logic_vector(3 downto 0):=x"0";--INDICATION FLAG FOR SOLVING ISSUE WHICH IS RELATED TO FIRST CHUNK OF DATA WHERE THERE WAS ONE DELAY ISSSUE DUE TO SERIALIZATION OF PARRALEL DATA

            signal chunk1:std_logic_vector(3 downto 0):=x"0";--TO ENSURE THAT IN ONE LINE CLOCK THERE ARE ONLY 4 CHUNKS IN FIRST 3 PAIRS
            signal chunk4:std_logic_vector(3 downto 0):=x"0";--TO ENSURE THAT IN ONE LINE CLOCK THERE ARE ONLY 2 CHUNKS IN 4TH PAIR  
            
            ------VARIABLES RELATED OF STATE TRANSITIONS----------
            signal s1on:std_logic_vector(19 downto 0);--VARIABLE FOR THE STATE-1 AND STATE-4 PRE AND POST PIXELS(24)
            signal s2on:std_logic_vector(19 downto 0);--VARIABLE FOR THE STATE-2 COUNTER PIXELS(3000) 
            signal s3on:std_logic_vector(19 downto 0);--VARIABLE FOR THE STATE-3 COUNTER FOR OTHER PIXELS(12)
            signal s5on4:std_logic_vector(19 downto 0);--VARIABLE FOR THE STATE-5 FOR 4TH PAIR OF SIGNALS (STATE 5 FOR THE 0 VALUES)
            signal s6on4:std_logic_vector(19 downto 0);--VARIABLE FOR THE STATE-6 FOR 4TH PAIR OF SIGNALS (STATE 6 FOR THE 0 VALUES)
            signal line_clk:std_logic:='0';
            signal count_line:std_logic_vector(19 downto 0):=x"00000";

            --signal fff:std_logic_vector(3 downto 0);



            
                      
            begin
               
--master_clock
process(clk,rst)
begin
if (rst='0') then
      if(rising_edge(clk))then

                      master_cnt<=x"00";        
                      master<='1';
--required registers initialization 
                      s1on<=(ncp*np1)-1;
                      s2on<=(ncp*np2)-1;
                      s3on<=(ncp*np3)-1;
                      s5on4<=(ncp)*(np4+np3+np2+np1);
                      s6on4<=s0on-1;
      end if;
else       
       if (rising_edge(clk)) then
          
             if(line_clk='0')then
              
                   if((state_1=x"1")or(state_1=x"2")or(state_1=x"3")or(state_1=x"4"))then              
                           master_cnt<=master_cnt+1;
                          
                           if(master_cnt=mas_clk_gen)then
                               master<= not master;
                               master_cnt<=x"00";
                           end if;
                   else 
                           master<='1';
                   end if;
             else
                   master<='1';
             end if;
       end if;                 
end if;
                   
                     
                   
end process;

--line_clk generation
process(clk,rst)
                 begin
                  
                   if(rst='0') then
                       line_clk<='1';
                       line_clk_o<='1';
                       count_line<=x"00000";
                       else
                        if rising_edge(clk) then
                            if(line_clk='1')then                         
                           
                                 if(count_line=x"00063")then
                                    line_clk<='0';
                                    line_clk_o<='0';
                                    count_line<=x"00000";
                                 else
                                    count_line<=count_line+1;
                                 end if;
                            end if;

                            if(line_clk='0')then                         
                           
                                 if(count_line=x"A6CB0")then
                                    line_clk<='1';
                                    line_clk_o<='1';
                                    count_line<=x"00000";
                                 else
                                    count_line<=count_line+1;
                                 end if;
                            end if;
--                            line_clk_o<=line_clk;     
                        end if;   
                     end if;   

             
                     
                         
                     
                       
                     
                        
 end process;

--serial_clock
process(clk,rst)
begin
                  
if (rst='1' ) then
       if (rising_edge(clk)) then
       
             if(line_clk='0')then
                   if((state_1=x"1")or(state_1=x"2")or(state_1=x"3")or(state_1=x"4"))then              
                           serial_cnt<=serial_cnt+1;
                           if(serial_cnt=ser_clk_gen)then
                               serial<= not serial;
                               serial_cnt<=x"0";
                           end if;
                   else 
                           serial<='1';
                   end if;
             else
                   serial<='1';
             end if;
       end if;
else
      if(rising_edge(clk))then
             serial<='1';
             serial_cnt<=x"0";   
      end if;                 
end if;
                   
                     
                   
end process;

--serial_clock_2
process(clk,rst)
begin
                  
if (rst='1' ) then
       if (rising_edge(clk)) then
       
             --if((line_clk='0') or (line_clk='1'))then
                   --if((state_1=x"0")or(state_1=x"1")or(state_1=x"2")or(state_1=x"3")or(state_1=x"4")or(state_1=x"5"))then              
                           serial_cnt1<=serial_cnt1+1;
                           if(serial_cnt1=ser_clk_gen)then
                               serial2<= not serial2;
                               serial_cnt1<=x"0";
                           end if;
                           serial_2<=serial2;
--                   else 
--                           serial2<='1';
--                   end if;
--             else
--                   serial1<='1';
            -- end if;
       end if;
else
      if(rising_edge(clk))then
             serial2<='1';
             serial_cnt1<=x"0";   
      end if;                 
end if;
                   
                     
                   
end process;



--B1,B2,B3 ALL ODD AND EVEN SIGNALS GENERATION
process(clk,rst)
begin

if (rst='1') then
                       
      if(rising_edge(clk))then
      
            if(line_clk='0')then
                 if(state_1=x"0")then--STATE-0 FOR FREE SPACE OR VALUE 0 SPACE
                      if(flame=x"0")then--TO SOLVE ISSUE OF THE ONE EXTRA DELAY
                             if(count=s0on-1)then
                                state_1<=x"1";
--                                fff<=x"4";
                                b1_ocnt<=x"B10";
                                b1_ecnt<=x"B10";
                                b2_ocnt<=x"B20";
                                b2_ecnt<=x"B20";
                                b3_ocnt<=x"B30";
                                b3_ecnt<=x"B30";
                                count<=x"00000";
                                flame<=flame+1;
                             else
                                count<=count+1;
                                
                             end if;
                      else
                             if(count=s0on)then
                                state_1<=x"1";
                                b1_ocnt<=x"B10";
                                b1_ecnt<=x"B10";
                                b2_ocnt<=x"B20";
                                b2_ecnt<=x"B20";
                                b3_ocnt<=x"B30";
                                b3_ecnt<=x"B30";
                                count<=x"00000";
                                
                             else
                                count<=count+1;
                             end if; 
                     end if;
                 --end if;
                 
                 elsif((state_1=x"1"))then--STATE-1 FOR PRE PIXEL DATA
                              if(count=s1on)then
                                  state_1<=x"2";
                                  
                                  b1_ocnt<=x"001";
                                  b1_ecnt<=x"000";
                                  b2_ocnt<=x"001";
                                  b2_ecnt<=x"000";
                                  b3_ocnt<=x"001";
                                  b3_ecnt<=x"000";
                                  count<=x"00000";
                                  cunt<=x"00";
                             
                              else 
                              
                                   if(b1_ocnt=x"B1F")then
                                   count<=count+1;
                                   cunt<=cunt+1;
                                   if(cunt=ncp-1)then--to change parallel data after 48 clk cycles for each pixel
                                   b1_ocnt<=x"B10";
                                   b1_ecnt<=x"B10";
                                   b2_ocnt<=x"B20";
                                   b2_ecnt<=x"B20";
                                   b3_ocnt<=x"B30";
                                   b3_ecnt<=x"B30";
                                   cunt<=x"00";
                                   end if;
                                   else
                                   count<=count+1;
                                   cunt<=cunt+1;
                                   if(cunt=ncp-1)then--to change parallel data after 48 clk cycles for each pixel
                                   b1_ocnt<=b1_ocnt+1;
                                   b1_ecnt<=b1_ecnt+1;
                                   b2_ocnt<=b2_ocnt+1;
                                   b2_ecnt<=b2_ecnt+1;
                                   b3_ocnt<=b3_ocnt+1;
                                   b3_ecnt<=b3_ecnt+1;
                                   cunt<=x"00";
                                   end if;
                                   end if;
                              end if;
                --end if;
                elsif(state_1=x"2")then--STATE-2 FOR THE COUNTER WHICH HAVE VALUES OF ODD AND EVEN VALUES FROM 0 TO 5999
                              if(count=s2on)then
                                  state_1<=x"3";
                                    b1_ocnt<=x"055";
                                    b1_ecnt<=x"055";
                                    b2_ocnt<=x"055";
                                    b2_ecnt<=x"055";
                                    b3_ocnt<=x"055";
                                    b3_ecnt<=x"055";
                                    cunt<=x"00";
                                  count<=x"00000";
                               
                              else 
                              
                                   count<=count+1;
                                   cunt<=cunt+1;
                                   if(cunt=ncp-1)then--to change parallel data after 48 clk cycles for each pixel
                                   b1_ocnt<=b1_ocnt+2;
                                   b1_ecnt<=b1_ecnt+2;
                                   b2_ocnt<=b2_ocnt+2;
                                   b2_ecnt<=b2_ecnt+2;
                                   b3_ocnt<=b3_ocnt+2;
                                   b3_ecnt<=b3_ecnt+2;
                                   cunt<=x"00";
                                   end if;
                              
                              end if;
               --end if;
               elsif(state_1=x"3")then--STATE-3 FOR OTHER PIXEL VALUES
                              if(count=s3on)then
                                  state_1<=x"4";
                                  b1_ocnt<=x"B10";
                                  b1_ecnt<=x"B10";
                                  b2_ocnt<=x"B20";
                                  b2_ecnt<=x"B20";
                                  b3_ocnt<=x"B30";
                                  b3_ecnt<=x"B30";
                                  cunt<=x"00";
                                  count<=x"00000";
                                  
                              else 
                              
                                   count<=count+1;
                                   cunt<=cunt+1;
                                   if(cunt=ncp-1)then--to change parallel data after 48 clk cycles for each pixel
                                   b1_ocnt<=b1_ocnt+5;
                                   b1_ecnt<=b1_ecnt+5;
                                   b2_ocnt<=b2_ocnt+5;
                                   b2_ecnt<=b2_ecnt+5;
                                   b3_ocnt<=b3_ocnt+5;
                                   b3_ecnt<=b3_ecnt+5;
                                   cunt<=x"00";
                                   end if;
                              
                              end if;
               --end if;
               elsif(state_1=x"4")then--STATE-4 FOR PRE PIXEL DATA                       
                              if(count=s1on)then                                 
                                  b1_ocnt<=x"000";
                                  b1_ecnt<=x"000";
                                  b2_ocnt<=x"000";
                                  b2_ecnt<=x"000";
                                  b3_ocnt<=x"000";
                                  b3_ecnt<=x"000";
                                  count<=x"00000";
                                  cunt<=x"00";
                                  chunk1<=chunk1+1;
                                  if(chunk1=x"3")then
                                  state_1<=x"5";
                                  else
                                  state_1<=x"0";
                                  end if;   
                              else 
                                   if(b1_ocnt=x"B1F")then
                                   count<=count+1;
                                   cunt<=cunt+1;
                                   if(cunt=ncp-1)then--to change parallel data after 48 clk cycles for each pixel
                                   b1_ocnt<=x"B10";
                                   b1_ecnt<=x"B10";
                                   b2_ocnt<=x"B20";
                                   b2_ecnt<=x"B20";
                                   b3_ocnt<=x"B30";
                                   b3_ecnt<=x"B30";
                                   cunt<=x"00";
                                   end if;
                                   else
                                   count<=count+1;
                                   cunt<=cunt+1;
                                   if(cunt=ncp-1)then--to change parallel data after 48 clk cycles for each pixel
                                   b1_ocnt<=b1_ocnt+1;
                                   b1_ecnt<=b1_ecnt+1;
                                   b2_ocnt<=b2_ocnt+1;
                                   b2_ecnt<=b2_ecnt+1;
                                   b3_ocnt<=b3_ocnt+1;
                                   b3_ecnt<=b3_ecnt+1;
                                   cunt<=x"00";
                                   end if;
                                   end if;
                               
                              end if;
             --end if;
             elsif(state_1=x"5")then--TERMINATION OF FINAL STATE WHEN DECLARED CHUNKS PER LINE CLOCK IS RECEIVED
                           b1_ocnt<=x"000";
                           b1_ecnt<=x"000";
                           b2_ocnt<=x"000";
                           b2_ecnt<=x"000";
                           b3_ocnt<=x"000";
                           b3_ecnt<=x"000";
             end if;

           else
                             b1_ocnt<=x"000";
                             b1_ecnt<=x"000";
                             b2_ocnt<=x"000";
                             b2_ecnt<=x"000";
                             b3_ocnt<=x"000";
                             b3_ecnt<=x"000";
                             state_1<=x"0";
                             count<=x"00000";
                             cunt<=x"00";
                             count<=x"00000";
                             flame<=x"0";
                             chunk1<=x"0";
           end if;
      end if; 
else
      

                      chunk1<=x"0";
                      b1_ocnt<=x"000";
                      b1_ecnt<=x"000";
                      b2_ocnt<=x"000";
                      b2_ecnt<=x"000";
                      b3_ocnt<=x"000";
                      b3_ecnt<=x"000";
                      state_1<=x"0";
                      cunt<=x"00";
                      count<=x"00000";
                      flame<=x"0";
     
end if;
end process;

--B4 ALL ODD AND EVEN SIGNALS GENERATION
                 
process(clk,rst)
begin
if (rst='1') then
      if(rising_edge(clk))then
           
           if(line_clk='0')then
              if(state_4=x"0")then--STATE-0 FOR FREE SPACE OR VALUE 0 SPACE
                            if(flame=x"0")then--TO SOLVE ISSUE OF THE ONE EXTRA DELAY
                             if(count4=s0on-1)then
                                state_4<=x"1";
                                b4_ocnt<=x"B40";
                                b4_ecnt<=x"B40";
                                count4<=x"00000";
                             else
                                count4<=count4+1;
                             end if;
                            else
                             if(count4=s0on)then
                                state_4<=x"1";
                                b4_ocnt<=x"B40";
                                b4_ecnt<=x"B40";
                                count4<=x"00000";
                             else
                                count4<=count4+1;
                             end if;
                            end if;
              --end if;
              elsif(state_4=x"1")then--STATE-1 FOR PRE PIXEL DATA
                              if(count4=s1on)then
                                  state_4<=x"2";
                                  count4<=x"00000";
                                  b4_ocnt<=x"001";
                                  b4_ecnt<=x"000";
                                  cunt4<=x"00";                             
                              else                            
                                   if(b4_ocnt=x"B4F")then
                                   count4<=count4+1;
                                   cunt4<=cunt4+1;
                                   if(cunt4=ncp-1)then--to change parallel data after 48 clk cycles for each pixel
                                   b4_ocnt<=x"B40";
                                   b4_ecnt<=x"B40";
                                   cunt4<=x"00";
                                   end if;       
                                   else
                                   count4<=count4+1;
                                   cunt4<=cunt4+1;
                                   if(cunt4=ncp-1)then--to change parallel data after 48 clk cycles for each pixel
                                   b4_ocnt<=b4_ocnt+1;
                                   b4_ecnt<=b4_ecnt+1;
                                   cunt4<=x"00";
                                   end if;
                                   end if;
                              end if;
              --end if;
              elsif((state_4=x"2")and line_clk='0')then--STATE-2 FOR THE COUNTER WHICH HAVE VALUES OF ODD AND EVEN VALUES FROM 0 TO 5999
                              if(count4=s2on)then
                                  state_4<=x"3";
                                    b4_ocnt<=x"055";
                                    b4_ecnt<=x"055";
                                    cunt4<=x"00";
                                  count4<=x"00000";
                               
                              else                              
                                   count4<=count4+1;
                                   cunt4<=cunt4+1;
                                   if(cunt4=ncp-1)then--to change parallel data after 48 clk cycles for each pixel
                                   b4_ocnt<=b4_ocnt+2;
                                   b4_ecnt<=b4_ecnt+2;
                                   cunt4<=x"00";
                                   end if;
                             
                              end if;
              --end if;
              elsif(state_4=x"3")then--STATE-3 FOR OTHER PIXEL VALUES
                              if(count4=s3on)then
                                  state_4<=x"4";
                                  b4_ocnt<=x"B40";
                                  b4_ecnt<=x"B40";
                                  cunt4<=x"00";
                                  count4<=x"00000";
                                  
                              else 
                                   count4<=count4+1;
                                   cunt4<=cunt4+1;
                                   if(cunt4=ncp-1)then--to change parallel data after 48 clk cycles for each pixel
                                   b4_ocnt<=b4_ocnt+5;
                                   b4_ecnt<=b4_ecnt+5;
                                   cunt4<=x"00";
                                   end if;
                              end if;
              --end if;
              elsif(state_4=x"4")then--STATE-4 FOR PRE PIXEL DATA
                              if(count4=s1on)then
                                  state_4<=x"5";
                                  count4<=x"00000";
                                  b4_ocnt<=x"000";
                                  b4_ecnt<=x"000";
                                  cunt4<=x"00";
                                  
                                  
                             
                              else                              
                                   if(b4_ocnt=x"B4F")then
                                   count4<=count4+1;
                                   cunt4<=cunt4+1;
                                   if(cunt4=ncp-1)then--to change parallel data after 48 clk cycles for each pixel
                                   b4_ocnt<=x"B40";
                                   b4_ecnt<=x"B40";
                                   cunt4<=x"00";
                                   end if;
                                   
                                   else
                                   count4<=count4+1;
                                   cunt4<=cunt4+1;
                                   if(cunt4=ncp-1)then--to change parallel data after 48 clk cycles for each pixel
                                   b4_ocnt<=b4_ocnt+1;
                                   b4_ecnt<=b4_ecnt+1;
                                   cunt4<=x"00";
                                   end if;
                                   end if;
                              end if;
             --end if;
             elsif(state_4=x"5")then--ZERO STATE
                             if(count4=s5on4)then
                                state_4<=x"6";
                                b4_ocnt<=x"000";
                                b4_ecnt<=x"000";
                                cunt4<=x"00";
                                
                                
                                count4<=x"00000";
                             else
                                count4<=count4+1;
                              end if;
             --end if;
             elsif(state_4=x"6")then--ZERO STATE
                             if(count4=s6on4)then                                
                                b4_ocnt<=x"000";
                                b4_ecnt<=x"000";
                                cunt4<=x"00";
                                chunk4<=chunk4+1;
                                if(chunk4=x"1")then
                                state_4<=x"7";
                                else
                                state_4<=x"0";
                                end if;                                                                
                                count4<=x"00000";
                             else
                                count4<=count4+1;
                              end if;
             --end if;
             elsif(state_4=x"7")then--FINAL STATE IF CHUNK REQUIREMENTS ARE MEANT
                           b4_ocnt<=x"000";
                           b4_ecnt<=x"000";
             end if;
          else
                             b4_ocnt<=x"000";
                             b4_ecnt<=x"000";
                             cunt4<=x"00";
                             state_4<=x"0";
                             count4<=x"00000";
                             chunk4<=x"0";
          end if;
      end if;   
else      
      
                      chunk4<=x"0"; 
                      b4_ocnt<=x"000";
                      b4_ecnt<=x"000";
                      state_4<=x"0";
                      cunt4<=x"00";
                      count4<=x"00000";
      

end if;
end process;

--B5 ALL ODD AND EVEN SIGNALS GENERATION
                 
process(clk,rst)
begin
if (rst='1') then
      if(rising_edge(clk))then
          if(line_clk='0')then
              if(state_5=x"0")then--STATE-0 FOR FREE SPACE OR VALUE 0 SPACE
                            if(flame=x"0")then--TO SOLVE ISSUE OF THE ONE EXTRA DELAY
                             if(count5=s0on-1)then
                                state_5<=x"1";
                                b5_ocnt<=x"B50";
                                b5_ecnt<=x"B50";
                               
                                
                                count5<=x"00000";
                             else
                                count5<=count5+1;
                             end if;
                            else
                              if(count5=s0on)then
                                state_5<=x"1";
                                b5_ocnt<=x"B50";
                                b5_ecnt<=x"B50";  
                                count5<=x"00000";
                              else
                                count5<=count5+1;
                              end if;
                            end if;
              --end if;
              elsif(state_5=x"1")then--STATE-1 FOR PRE PIXEL DATA
                              if(count5=s1on)then
                                  state_5<=x"2";
                                  count5<=x"00000";
                                  b5_ocnt<=x"001";
                                  b5_ecnt<=x"000";
                                  cunt5<=x"00";                             
                              else 
                                   if(b5_ocnt=x"B5F")then
                                   count5<=count5+1;
                                   cunt5<=cunt5+1;
                                   if(cunt5=ncp-1)then--to change parallel data after 48 clk cycles for each pixel
                                   b5_ocnt<=x"B50";
                                   b5_ecnt<=x"B50";
                                   cunt5<=x"00";
                                   end if;
                                   
                                   else
                                   count5<=count5+1;
                                   cunt5<=cunt5+1;
                                   if(cunt5=ncp-1)then--to change parallel data after 48 clk cycles for each pixel
                                   b5_ocnt<=b5_ocnt+1;
                                   b5_ecnt<=b5_ecnt+1;
                                   cunt5<=x"00";
                                   end if;
                                   end if;
                              end if;
              --end if;
              elsif(state_5=x"2")then--STATE-2 FOR THE COUNTER WHICH HAVE VALUES OF ODD AND EVEN VALUES FROM 0 TO 5999
                              if(count5=s2on)then
                                  state_5<=x"3";
                                    b5_ocnt<=x"055";
                                    b5_ecnt<=x"055";
                                    cunt5<=x"00";
                                  count5<=x"00000";
                               
                              else 
--                            
                                   count5<=count5+1;
                                   cunt5<=cunt5+1;
                                   if(cunt5=ncp-1)then--to change parallel data after 48 clk cycles for each pixel
                                   b5_ocnt<=b5_ocnt+2;
                                   b5_ecnt<=b5_ecnt+2;
                                   cunt5<=x"00";
                                   end if;
                              end if;
              --end if;
              elsif(state_5=x"3")then--STATE-3 FOR OTHER PIXEL VALUES
                              if(count5=s3on)then
                                  state_5<=x"4";
                                  b5_ocnt<=x"B50";
                                  b5_ecnt<=x"B50";
                                  cunt5<=x"00";
                                  count5<=x"00000";                                 
                              else 
                                   count5<=count5+1;
                                   cunt5<=cunt5+1;
                                   if(cunt5=ncp-1)then--to change parallel data after 48 clk cycles for each pixel
                                   b5_ocnt<=b5_ocnt+5;
                                   b5_ecnt<=b5_ecnt+5;
                                   cunt5<=x"00";
                                   end if;
                              end if;
              --end if;
              elsif(state_5=x"4")then--STATE-4 FOR PRE PIXEL DATA
                              if(count5=s1on)then
                                  state_5<=x"5";
                                  count5<=x"00000";
                                  b5_ocnt<=x"000";
                                  b5_ecnt<=x"000";
                                  cunt5<=x"00";
                              else 
                                   if(b5_ocnt=x"B5F")then
                                   count5<=count5+1;
                                   cunt5<=cunt5+1;
                                   if(cunt5=ncp-1)then--to change parallel data after 48 clk cycles for each pixel
                                   b5_ocnt<=x"B50";
                                   b5_ecnt<=x"B50";
                                   cunt5<=x"00";
                                   end if;
                                   
                                   else
                                   count5<=count5+1;
                                   cunt5<=cunt5+1;
                                   if(cunt5=ncp-1)then--to change parallel data after 48 clk cycles for each pixel
                                   b5_ocnt<=b5_ocnt+1;
                                   b5_ecnt<=b5_ecnt+1;
                                   cunt5<=x"00";
                                   end if;
                                   end if;
                              end if;
              --end if;
              elsif(state_5=x"5")then--AFTER ONE CHUNK IS GENERATED IN LINE CLOCK THEN GO TO THAT STATE
                           b5_ocnt<=x"000";
                           b5_ecnt<=x"000";
              end if;
           else
                             b5_ocnt<=x"000";
                             b5_ecnt<=x"000";
                             cunt5<=x"00";
                             state_5<=x"0";
                             count5<=x"00000";
           end if;
       end if;
else
       
                      b5_ocnt<=x"000";
                      b5_ecnt<=x"000";
                      state_5<=x"0";
                      cunt5<=x"00";
                      count5<=x"00000";
       
end if;
end process;





--serial data generation FOR B1,B2 AND B3
process(clk, rst)
begin
if (rst = '0') then
        if(rising_edge(clk))then
                      bit_index <= 11;    --change as per bit index range declared in the signal declaration
                      b1_ocnt_c <= '0'; 
                      b1_ecnt_c <= '0'; 
                      

                      b2_ocnt_c <= '0'; 
                      b2_ecnt_c <= '0'; 

                      b3_ocnt_c <= '0'; 
                      b3_ecnt_c <= '0'; 

                      cnt<=x"0";
        end if;
else
        if (rising_edge(clk)) then
              if (line_clk='1')then
                      bit_index <= 11;    --change as per bit index range declared in the signal declaration
                      b1_ocnt_c <= '0'; 
                      b1_ecnt_c <= '0'; 
                      

                      b2_ocnt_c <= '0'; 
                      b2_ecnt_c <= '0'; 

                      b3_ocnt_c <= '0'; 
                      b3_ecnt_c <= '0'; 

                      cnt<=x"0";
              else
                      if(state_1=x"0")then
                      bit_index <= 11;    --change as per bit index range declared in the signal declaration
                      b1_ocnt_c <= '0'; 
                      b1_ecnt_c <= '0'; 
                      

                      b2_ocnt_c <= '0'; 
                      b2_ecnt_c <= '0'; 

                      b3_ocnt_c <= '0'; 
                      b3_ecnt_c <= '0'; 

                      cnt<=x"0";
                      else
                      cnt<=cnt+1;
                      b1_ocnt_c<=b1_ocnt(bit_index);--SERIAL DATA GENERATION USING PARALLEL DATA OF SUITABLE INDEX
                      b1_ecnt_c<=b1_ecnt(bit_index);

                      b2_ocnt_c<=b2_ocnt(bit_index);
                      b2_ecnt_c<=b2_ecnt(bit_index);

                      b3_ocnt_c<=b3_ocnt(bit_index);
                      b3_ecnt_c<=b3_ecnt(bit_index);

                      master1<=master;
                      serial1<=serial;
                      
            
                      if(cnt=s1cnt)then--LOOP FOR UPDATING INDEX AS PER NEW SERIAL DATA TO GENERATE
                       if bit_index = 0 then
                           bit_index <= 11;  --change as per bit index range declared in the signal declaration
                       else
                           bit_index <= bit_index - 1; 
                       end if;
                       
                       cnt<=x"0";
                      end if;
                      end if;
              end if;
        end if;
end if;
end process;


--serial data generation FOR B4

 
process(clk, rst)
begin                  
if (rst = '0') then
        if(rising_edge(clk))then
                      bit_index4 <= 11;    --change as per bit index range declared in the signal declaration
                      b4_ocnt_c <= '0'; 
                      b4_ecnt_c <= '0'; 
                      cnt1<=x"0";
        end if;
else
        if (rising_edge(clk)) then
            if(line_clk='1')then
                      bit_index4 <= 11;    --change as per bit index range declared in the signal declaration
                      b4_ocnt_c <= '0'; 
                      b4_ecnt_c <= '0'; 
                      cnt1<=x"0";
            else
                 if((state_4=x"0")or(state_4=x"5")or(state_4=x"6"))then
                      bit_index4 <= 11;    --change as per bit index range declared in the signal declaration
                      b4_ocnt_c <= '0'; 
                      b4_ecnt_c <= '0'; 
                      cnt1<=x"0";
                 else
                      cnt1<=cnt1+1;
                      b4_ocnt_c<=b4_ocnt(bit_index4);--SERIAL DATA GENERATION USING PARALLEL DATA OF SUITABLE INDEX
                      b4_ecnt_c<=b4_ecnt(bit_index4);
                    if(cnt1=s1cnt)then--LOOP FOR UPDATING INDEX AS PER NEW SERIAL DATA TO GENERATE
                       if bit_index4 = 0 then
                           bit_index4 <= 11;  --change as per bit index range declared in the signal declaration
                       else
                           bit_index4 <= bit_index4 - 1; 
                       end if;
                       cnt1<=x"0";
                    end if;
                 end if;
            end if;
        end if;
end if;
end process;

--serial data generation FOR B5
process(clk, rst)
begin
if (rst = '0') then
        if(rising_edge(clk))then
                      bit_index5 <= 11;    --change as per bit index range declared in the signal declaration
                      b5_ocnt_c <= '0'; 
                      b5_ecnt_c <= '0'; 
                      cnt2<=x"0";
        end if;
else
        if rising_edge(clk) then
            if(line_clk='1')then
                      bit_index5 <= 11;    --change as per bit index range declared in the signal declaration
                      b5_ocnt_c <= '0'; 
                      b5_ecnt_c <= '0'; 
                      cnt2<=x"0";
            else
                 if((state_5=x"0")or(state_5=x"5"))then 
                      bit_index5 <= 11;    --change as per bit index range declared in the signal declaration
                      b5_ocnt_c <= '0'; 
                      b5_ecnt_c <= '0'; 
                      cnt2<=x"0";
                 else                    
                      cnt2<=cnt2+1;
                      b5_ocnt_c<=b5_ocnt(bit_index5);--SERIAL DATA GENERATION USING PARALLEL DATA OF SUITABLE INDEX
                      b5_ecnt_c<=b5_ecnt(bit_index5);            
                    if(cnt2=s1cnt)then--LOOP FOR UPDATING INDEX AS PER NEW SERIAL DATA TO GENERATE
                       if bit_index5 = 0 then
                           bit_index5 <= 11;  --change as per bit index range declared in the signal declaration
                       else
                           bit_index5 <= bit_index5 - 1; 
                       end if;
                       cnt2<=x"0";
                       end if;
                 end if;
            end if;
        end if;
end if;
end process;



end cd;
