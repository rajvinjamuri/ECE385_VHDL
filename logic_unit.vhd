---------------------------------------------------------------------------
--    logic_unit.vhd		                                      		 --
--    Sai Koppula                                                        --
--    3-13	                                                             --
--												 						 --
--    Purpose/Description                                                --
--    Takes in make_code and outputs the right direction		         --
--                                                                       --
--                                                                       --
--	  Final Modifications by Raj Vinjamuri and Sai Koppula			     --
--                                                                       --
--                                                                       --
--Updates																 --
--										 								 --
--	>fixed 11 downto 0													 --
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity logic_unit is
    Port ( 
    	SR_In : in std_logic_vector(10 downto 0);
    	PR_In : in std_logic_vector(10 downto 0);
--    	Up, Do, Le, Ri : out std_logic;
		WW, SS, AA, DD : out std_logic;
    	QQ, EE, RR : out std_logic;
    	One, Two, Three, Four, Five, Six, Seven, Eight, Nine, Zero : out std_logic;
    	Plus, Minus : out std_logic;
    	Spacebar : out std_logic);
end logic_unit;
    
architecture Behavioral of logic_unit is

signal break_code : std_logic_vector(7 downto 0);

begin
	
	break_code <= "11110000";					--set the break code (supposed to be F0) to F8 here

    decideMove: process(SR_In, PR_In) 
    begin
        
    if (SR_In(8 downto 1) = "00011101")			--W
    then
    	if (PR_In(8 downto 1) /= break_code)
    	then WW <= '1';
    	else WW <= '0';
    	end if;
    else WW <= '0';
    end if;
    
    if (SR_In(8 downto 1) = "00011011")			--S
    then
    	if (PR_In(8 downto 1) /= break_code)
    	then SS <= '1';
    	else SS <= '0';
    	end if;
    else SS <= '0';
    end if;
    
    if (SR_In(8 downto 1) = "00011100")			--A
    then
    	if (PR_In(8 downto 1) /= break_code)	-- THIS WAS HACKED, FIND BETTER SOLUTION (Break code was coming out as F8 instead of F0)
    	then AA <= '1';
    	else AA <= '0';
    	end if;
    else AA <= '0';
    end if;
    
    if (SR_In(8 downto 1) = "00100011")			--D 
    then
    	if (PR_In(8 downto 1) /= break_code)	-- THIS WAS HACKED, FIND BETTER SOLUTION
    	then DD <= '1';
    	else DD <= '0';
    	end if;
    else DD <= '0';
    end if;
--------------------------------------------
    if (SR_In(8 downto 1) = "00010110")			--1
    then
    	if (PR_In(8 downto 1) /= break_code)
    	then One <= '1';
    	else One <= '0';
    	end if;
    else One <= '0';
    end if;
    
    if (SR_In(8 downto 1) = "00011110")			--2
    then
    	if (PR_In(8 downto 1) /= break_code)
    	then Two <= '1';
    	else Two <= '0';
    	end if;
    else Two <= '0';
    end if;
    
    if (SR_In(8 downto 1) = "00100110")			--3
    then
    	if (PR_In(8 downto 1) /= break_code)
    	then Three <= '1';
    	else Three <= '0';
    	end if;
    else Three <= '0';
    end if;
    
    if (SR_In(8 downto 1) = "00100101")			--4
    then
    	if (PR_In(8 downto 1) /= break_code)
    	then Four <= '1';
    	else Four <= '0';
    	end if;
    else Four <= '0';
    end if;

    if (SR_In(8 downto 1) = "00101110")			--5
    then
    	if (PR_In(8 downto 1) /= break_code)
    	then Five <= '1';
    	else Five <= '0';
    	end if;
    else Five <= '0';
    end if;
    
    if (SR_In(8 downto 1) = "00100110")			--6
    then
    	if (PR_In(8 downto 1) /= break_code)
    	then Six <= '1';
    	else Six <= '0';
    	end if;
    else Six <= '0';
    end if;
    
    if (SR_In(8 downto 1) = "00111101")			--7
    then
    	if (PR_In(8 downto 1) /= break_code)
    	then Seven <= '1';
    	else Seven <= '0';
    	end if;
    else Seven <= '0';
    end if;
    
    if (SR_In(8 downto 1) = "00111110")			--8
    then
    	if (PR_In(8 downto 1) /= break_code)
    	then Eight <= '1';
    	else Eight <= '0';
    	end if;
    else Eight <= '0';
    end if;

    if (SR_In(8 downto 1) = "01000110")			--9
    then
    	if (PR_In(8 downto 1) /= break_code)
    	then Nine <= '1';
    	else Nine <= '0';
    	end if;
    else Nine <= '0';
    end if;
    
    if (SR_In(8 downto 1) = "01000101")			--0
    then
    	if (PR_In(8 downto 1) /= break_code)
    	then Zero <= '1';
    	else Zero <= '0';
    	end if;
    else Zero <= '0';
    end if;
--------------------------------------------
    if (SR_In(8 downto 1) = "00010101")			--Q
    then
    	if (PR_In(8 downto 1) /= break_code)
    	then QQ <= '1';
    	else QQ <= '0';
    	end if;
    else QQ <= '0';
    end if;
    
    if (SR_In(8 downto 1) = "00100100")			--E
    then
    	if (PR_In(8 downto 1) /= break_code)
    	then EE <= '1';
    	else EE <= '0';
    	end if;
    else EE <= '0';
    end if;

    if (SR_In(8 downto 1) = "00101101")			--R
    then
    	if (PR_In(8 downto 1) /= break_code)
    	then RR <= '1';
    	else RR <= '0';
    	end if;
    else RR <= '0';
    end if;
--------------------------------------------
    if (SR_In(8 downto 1) = "01010101")			--Plus
    then
    	if (PR_In(8 downto 1) /= break_code)
    	then Plus <= '1';
    	else Plus <= '0';
    	end if;
    else Plus <= '0';
    end if;
    
    if (SR_In(8 downto 1) = "01001110")			--Minus
    then
    	if (PR_In(8 downto 1) /= break_code)
    	then Minus <= '1';
    	else Minus <= '0';
    	end if;
    else Minus <= '0';
    end if;
    
    if (SR_In(8 downto 1) = "00101001")			--Spacebar
    then
    	if (PR_In(8 downto 1) /= break_code)
    	then Spacebar <= '1';
    	else Spacebar <= '0';
    	end if;
    else Spacebar <= '0';
    end if;
        
    end process;

end Behavioral;