---------------------------------------------------------------------------
--    reg_unit.vhd			                                      		 --
--    Raj Vinjamuri                                                      --
--    3-13	                                                             --
--												 						 --
--    Purpose/Description:                                               --
--    combines the registers to be used as simply as we desire the I/O   --
--                                                                       --
--    based on register unit given by UIUC                               --
--	  Final Modifications by Raj Vinjamuri and Sai Koppula			     --
--                                                                       --
--                                                                       --
--	  Updates:															 --
--										 								 --
--	  >3.10: Made components lower case			    					 --
--	  >changed A and B to SR and PR respectively					     --
--	  >fixed 7 downto 0 to 10 downto 0			 						 --
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity reg_unit is
    Port (  Clk : in std_logic;
            ClrSR, ClrPR : in std_logic;
            D_In : in std_logic_vector(10 downto 0);
            SR_In : in std_logic;
            Ld_SR : in std_logic;
            Ld_PR : in std_logic;
            Shift_En : in std_logic;          
            SR_out : out std_logic;
            PR_out : out std_logic;
            SR : out std_logic_vector(10 downto 0);
            PR : out std_logic_vector(10 downto 0));
end reg_unit;


architecture Behavioral of reg_unit is 


component reg_11 is
	Port (	Clk, Reset, Shift_In, Load, Shift_En : in std_logic;
            D : in std_logic_vector(10 downto 0);
            Shift_Out : out std_logic;
            Data_Out : out std_logic_vector(10 downto 0));    
end component reg_11;

signal shift_line : std_logic;

begin		--connecting both registers so one feeds the other

	scan_reg: reg_11
        port map(   Clk => Clk,
                    Reset => ClrSR,
                    D => D_In,
                    Shift_In => SR_in,
                    Load => Ld_SR,
                    Shift_En => Shift_En,
                    Shift_Out => shift_line,
                    Data_Out => SR);
    
	prev_reg: reg_11
        port map(   Clk => Clk,
                    Reset => ClrPR,
                    D => D_In,
                    Shift_In => shift_line,
                    Load => Ld_PR,
                    Shift_En => Shift_En,
                    Shift_Out => PR_out,
                    Data_Out => PR);

end Behavioral;