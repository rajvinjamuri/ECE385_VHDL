---------------------------------------------------------------------------
--    reg_11.vhd			                                      		 --
--    Raj Vinjamuri                                                      --
--    3-13	                                                             --
--												 						 --
--    Purpose/Description:                                               --
--    an 11-bit register unit with parallel-load and serial-in/out       --
--                                                                       --
--    based on 4-bit register given by UIUC                              --
--	  Final Modifications by Raj Vinjamuri and Sai Koppula			     --
--                                                                       --
--                                                                       --
--	  Updates:															 --
--										 								 --
--	  >3.10: added appropriate number of zeros to 'reset'			     --
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity reg_11 is
    Port (  Shift_In, Load, Shift_En, Clk, Reset : in std_logic;
            D : in std_logic_vector(10 downto 0);
            Shift_Out : out std_logic;
            Data_Out : out std_logic_vector(10 downto 0));           --added range
end reg_11;

architecture Behavioral of reg_11 is
    signal reg_value: std_logic_vector(10 downto 0);
begin
    operate_reg: process(Load, Shift_En, Clk, Shift_In, Reset) 
    begin
        if (rising_edge(Clk)) then
            if (Shift_En = '1')then
                reg_value <= Shift_In & reg_value (10 downto 1);
                -- operator "&" concatenates two bit-fields
            elsif (Load = '1') then
                reg_value <= D;
            elsif (Reset = '1') then
                reg_value <= "00000000000";
            else
                reg_value <= reg_value;
            end if;
        end if;
    end process;

Data_Out <= reg_value;
Shift_Out <=reg_value(0);

end Behavioral;