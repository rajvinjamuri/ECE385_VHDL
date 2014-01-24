---------------------------------------------------------------------------
--    keyboard_processor.vhd                                      		 --
--    Sai Koppula                                                        --
--    3-13	                                                             --
--												 						 --
--    Purpose/Description                                                --
--    Takes in ps2data and outputs the right make codes			         --
--                                                                       --
--                                                                       --
--	  Final Modifications by Raj Vinjamuri and Sai Koppula			     --
--                                                                       --
--                                                                       --
--Updates																 --
--										 								 --
--	>changed A/B_out to just A/B										 --
--	>condensed signals for clearer reading								 --
--	>changed re buses from  7 downto 0 to 10 downto 0					 --
--	>changed name of data bits in for uniformity						 --
---------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity keyboard_processor is
    Port (  Clk : in std_logic;	--takes in modified clock
            Status : in std_logic_vector(1 downto 0); 
            ps2data : in std_logic;		--from keyboard
            Reset : in std_logic;
            SR_Out : out std_logic_vector(10 downto 0);	--one code
            PR_Out : out std_logic_vector(10 downto 0)      --prev code
            );
end keyboard_processor;           
            
architecture Behavioral of keyboard_processor is             

component reg_unit is
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
end component reg_unit;


signal ClrSR, ClrPR :  std_logic;
signal SR_In, Ld_SR, Ld_PR, Shift_En : std_logic;
signal D_In : std_logic_vector(10 downto 0);
signal nreset, data: std_logic;


begin
	nreset <= Reset;
	data <= ps2data;
	
	Registers : reg_unit
	port map(   Clk => Clk,
				ClrSR => ClrSR,
				ClrPR => ClrPR,
				D_In  => D_In,
				SR_In  => SR_In,
				Ld_SR  => Ld_SR,
				Ld_PR  => Ld_PR,
				Shift_En  => Shift_En,
				SR => SR_Out,
				PR => PR_Out);

	pass_Data: process(Status, data) 		--shift data from prev code into another register
    begin
    	if (Status = "10")
			then Shift_En <= '1';
    	else Shift_En <= '0';
    	end if;
   	ClrSR <= nreset;
   	ClrPr <= nreset;
   	SR_In <= data;
   	Ld_SR <= '0';
   	Ld_PR <= '0';   
    end process;


end Behavioral;