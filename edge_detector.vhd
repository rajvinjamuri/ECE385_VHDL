---------------------------------------------------------------------------
--    edge-detector.vhd                                           		 --
--    Raj Vinjamuri                                                      --
--    3-13	                                                             --
--												 						 --
--    Purpose/Description                                                --
--    Takes FPGA clock and ps2Clk and outputs rising/falling/0/1         --
--                                                                       --
--                                                                       --
--                                                                       --
--	  Final Modifications by Raj Vinjamuri and Sai Koppula			     --
--                                                                       --
--                                                                       --
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity edge_detector is
    Port (  mod_Clk, ps2Clk : in std_logic;
            status : out std_logic_vector(1 downto 0));
end edge_detector;

architecture Behavioral of edge_detector is

component Dreg is
    port(   D, clk, reset, ld: in std_logic;
            Q : out std_logic);
end component Dreg;

signal chain : std_logic_vector(1 downto 0);		--internal bus to hold outputs

begin
    
    dff1: Dreg
	port map(	D => ps2Clk,
				clk => mod_clk,
				reset => '0',
				ld => '1',
				Q => chain(0));			--feeds into other d-ff
				
	dff2: Dreg
	port map(	D => chain(0),
				clk => mod_clk,
				reset => '0',
				ld => '1',
				Q => chain(1));				

    status <= chain;		--set output
    
end Behavioral;