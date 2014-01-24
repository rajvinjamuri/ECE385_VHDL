---------------------------------------------------------------------------
--    d_ff.vhd                                                   		 --
--    Raj Vinjamuri                                                      --
--    3-13	                                                             --
--												 						 --
--    Purpose/Description                                                --
--    A 1-bit d-flip flop with load and reset functionality              --
--                                                                       --
--                                                                       --
--	  Final Modifications by Raj Vinjamuri and Sai Koppula			     --
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Dreg is
    port(   D, clk, reset, ld: in std_logic;
            Q : out std_logic);
end Dreg;

architecture behavior of Dreg is
begin
    process(reset, clk)
    begin
        if reset = '1' then
            Q <= '0';
        elsif (rising_edge(clk)) then
            if ld = '1' then
                Q <= D; --else Q is unchanged
            end if;
        end if;
    end process;
end behavior;