---------------------------------------------------------------------------
--    random_gen.vhd		                                      		 --
--    Raj Vinjamuri                                                      --
--    3-13	                                                             --
--												 						 --
--    Purpose/Description:                                               --
--	  generates bits based on a counter from the clock					 --
--	  acts as pseudo-random seed										 --
--																		 --
--	  Final Modifications by Raj Vinjamuri and Sai Koppula			     --
--                                                                       --
---------------------------------------------------------------------------
	
library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

----------------------------------------------------

entity random_gen is

port(	Clk, toggle, reset:		in std_logic;
		seed:	out std_logic_vector(17 downto 0);
		seedLED: out std_logic_vector(17 downto 0));
end random_gen;

----------------------------------------------------

architecture behavioral of random_gen is		 	  
	
    signal Pre_Q: std_logic_vector(35 downto 0);

begin

    count: process(Clk)
	begin
		if (reset = '1') then
			Pre_Q <= "000000000000000000000000000000000000"; --36 zeros
		elsif (Clk='1' and Clk'event) then
				Pre_Q <= Pre_Q + 1;
		end if;
	end process;	
	    
    setLED: process(toggle)
	begin
		if (toggle = '1') then 
			seedLED <= Pre_Q(35 downto 18);		--use a switch to see the seed or not
		else seedLED <= "000000000000000000";	--18 zeros
		end if;
	end process;

    -- concurrent assignment statement
    seed <= Pre_Q(35 downto 18);
    
end behavioral;

-----------------------------------------------------