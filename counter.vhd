---------------------------------------------------------------------------
--    counter.vhd			                                      		 --
--    Raj Vinjamuri                                                      --
--    3-13	                                                             --
--												 						 --
--    Purpose/Description:                                               --
--	  custom counter modified from Wikipedia source code				 --
--			goal is to get input clock divided by 512					 --
--																		 --
--	  References:														 --
--		http://en.wikipedia.org/wiki/Vhdl_87#Example:_a_counter			 --
--		http://esd.cs.ucr.edu/labs/tutorial/counter.vhd					 --
--																		 --
--	  Final Modifications by Raj Vinjamuri and Sai Koppula			     --
--                                                                       --
---------------------------------------------------------------------------
	
library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

----------------------------------------------------

entity counter is

generic(n: 			in natural := 16);

port(	Clk:		in std_logic;
		mod_Clk:	out std_logic);
end counter;

----------------------------------------------------

architecture behavioral of counter is		 	  
	
    signal Pre_Q: std_logic_vector(n-1 downto 0);

begin

    process(Clk)
		begin
		if (Clk='1' and Clk'event) then
			Pre_Q <= Pre_Q + 1;
		end if;
	end process;	
	
    -- concurrent assignment statement
    mod_Clk <= Pre_Q(9);

end behavioral;

-----------------------------------------------------