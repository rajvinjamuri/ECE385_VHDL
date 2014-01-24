---------------------------------------------------------------------------
--    game_handler.vhd	                    	                  		 --
--    Raj Vinjamuri                                                      --
--    4-13	                                                             --
--												 						 --
--    Purpose/Description:                                               --
--    handles game status										         --
--                                                                       --
--    based on 4-bit register given by UIUC                              --
--	  Final Modifications by Raj Vinjamuri and Sai Koppula			     --
--                                                                       --
--    see theory.txt for what each bit means							 --
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity game_handler is
    Port (  frame_clk : in std_logic;
            paddle_loss_statusIn : in std_logic_vector(1 downto 0);
            win_statusIn, ResetIn, ResetScore : in std_logic;
            brick_hitIn : in std_logic_vector(19 downto 0);
            score: out std_logic_vector(7 downto 0);
            game_status : out std_logic_vector(3 downto 0));
end game_handler;

architecture Behavioral of game_handler is
    signal reg_value: std_logic_vector(3 downto 0);
    signal scoreSig: std_logic_vector(7 downto 0);
begin
    operate_reg: process(paddle_loss_statusIn, brick_hitIn, win_statusIn, ResetIn) 
    begin
		if (ResetIn = '1') then
			reg_value <= "0000";
		elsif(rising_edge(frame_clk)) then
			reg_value(0) <= paddle_loss_statusIn(0);
			reg_value(1) <= paddle_loss_statusIn(1);
			reg_value(2) <= (brick_hitIn(0) OR brick_hitIn(1) OR brick_hitIn(2) OR brick_hitIn(3) OR 
								brick_hitIn(4) OR brick_hitIn(5) OR brick_hitIn(6) OR brick_hitIn(7) OR 
								brick_hitIn(8) OR brick_hitIn(9) OR brick_hitIn(10) OR brick_hitIn(11) OR 
								brick_hitIn(12) OR brick_hitIn(13) OR brick_hitIn(14) OR brick_hitIn(15) OR 
								brick_hitIn(16) OR brick_hitIn(17) OR brick_hitIn(18) OR brick_hitIn(19));
			reg_value(3) <= win_statusIn;
		end if;
    end process;
    
    operate_score: process(reg_value, ResetScore)
	begin
		if (ResetScore = '1') then
			scoreSig <= "00000000";
		elsif(rising_edge(frame_clk)) then
			if (reg_value(1) = '1') then
				scoreSig <= scoreSig + "00000001";
			elsif (reg_value(2) = '1') then
				scoreSig <= scoreSig + "00001010";
			elsif (reg_value(3) = '1') then
				scoreSig <= scoreSig + "00110010";
			else
				scoreSig <= scoreSig;
			end if;
		end if;
	end process;
	
--	decimel: process(scoreOutSig)
--	begin
--		scoreH <= (scoreOutSig mod "00001010");
--		scoreL <= 
	
score <= scoreSig;
game_status <= reg_value;

end Behavioral;