---- detector_16_pkg.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package detector_16_pkg is



            constant ncp:std_logic_vector(7 downto 0):=x"30";--counts for 1 pixek for example 48 tp/1pixel
            constant np1:std_logic_vector(11 downto 0):=x"018";--no of pixel in state_1 pre pixel 24 ex B10,B11...
            constant np2:std_logic_vector(11 downto 0):=x"BB8";--no of pixel in state_2 counter of 1 to 6000 and total of (0 to 2999) 3000 counts
            constant np3:std_logic_vector(11 downto 0):=x"00C";--no of pixel in state_3 other post pixel 12
            constant np4:std_logic_vector(11 downto 0):=x"018";--no of pixel in state_4 post pixel 24 ex B10,B11...

            constant s0on:std_logic_vector(19 downto 0):=x"04E1F";--for counter of blank state which will provide zero value
            constant s1cnt:std_logic_vector(3 downto 0):=x"3";--one serial bit length as per now 48/12=4
            constant ser_clk_gen:std_logic_vector(3 downto 0):=x"1";--variable used to generate serial clock
            constant mas_clk_gen:std_logic_vector(7 downto 0):=x"17";--variable used to generate master clock

end package detector_16_pkg;
