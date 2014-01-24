---------------------------------------------------------------------------
--    Color_Mapper.vhd                                                   --
--    Stephen Kempf, David Kesler, Raj Vinjamuri, Sai Koppula            --
--    4-13                                                               --
--												 						 --
--    For use with ECE 385                                               --
--    University of Illinois ECE Department                              --
--                                                                       --
--                                                                       --
--	  Final Modifications by Raj Vinjamuri and Sai Koppula			     --
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Color_Mapper is
   Port ( game_status : in std_logic_vector(3 downto 0);
          BallX, BallY : in std_logic_vector(10 downto 0);
          PaddleX, PaddleY : in std_logic_vector (10 downto 0);
          BricksX, BricksY : in std_logic_vector(219 downto 0);
          BricksOn : in std_logic_vector(19 downto 0);
          DrawX, DrawY : in std_logic_vector(10 downto 0);
          Ball_size : in std_logic_vector(10 downto 0);
          Paddle_size :  in std_logic_vector(10 downto 0);
--          Brick_size : in std_logic_vector(9 downto 0);
          Red   : out std_logic_vector(9 downto 0);
          Green : out std_logic_vector(9 downto 0);
          Blue  : out std_logic_vector(9 downto 0));
end Color_Mapper;

architecture Behavioral of Color_Mapper is

signal Ball_on, Paddle_on, Brick_on : std_logic;
signal Brick_Width : std_logic_vector(10 downto 0);
signal Brick_Height : std_logic_vector(10 downto 0);
signal BrickX, BrickY : std_logic_vector(10 downto 0);
signal BrickOn : std_logic;
signal start , ender : natural;
--signal temp1, temp2   : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(100, 10);  --Step size on the Y axis (modified)
  
begin
Brick_Width <= CONV_STD_LOGIC_VECTOR(60, 11); -- assigns the value 4 as a 10-digit binary number, ie "0000000100"
  Brick_Height <= CONV_STD_LOGIC_VECTOR(20, 11);
-----------------------------------------------------

  Ball_on_proc : process (BallX, BallY, DrawX, DrawY, Ball_size)
  begin
  -- Old Ball: Generated square box by checking if the current pixel is within a square of length
  -- 2*Ball_Size, centered at (BallX, BallY).  Note that this requires unsigned comparisons, by using
  -- IEEE.STD_LOGIC_UNSIGNED.ALL at the top.
--   if ((DrawX >= BallX - Ball_size) AND
--      (DrawX <= BallX + Ball_size) AND
--      (DrawY >= BallY - Ball_size) AND
--      (DrawY <= BallY + Ball_size)) then

  -- New Ball: Generates (pixelated) circle by using the standard circle formula.  Note that while 
  -- this single line is quite powerful descriptively, it causes the synthesis tool to use up three
  -- of the 12 available multipliers on the chip!  It also requires IEEE.STD_LOGIC_SIGNED.ALL for
  -- the signed multiplication to operate correctly.
    if ((((DrawX - BallX) * (DrawX - BallX)) + ((DrawY - BallY) * (DrawY - BallY))) <= (Ball_size*Ball_size)) then
      Ball_on <= '1';
    else
      Ball_on <= '0';
    end if;
  end process Ball_on_proc;

-----------------------------------------------------
  
  Paddle_on_proc : process (PaddleX, PaddleY, DrawX, DrawY, Paddle_size)
  begin
	if ((DrawX >= PaddleX - ("00000000110"*Paddle_size)) 	AND
		(DrawX <= PaddleX + ("00000000110"*Paddle_size)) 	AND
		(DrawY >= PaddleY - Paddle_size) 					AND
		(DrawY <= PaddleY + Paddle_size)) 			then
			Paddle_on <= '1';
	else
			Paddle_on <= '0';
	end if;
  end process Paddle_on_proc;
  
-----------------------------------------------------


-----------------------------------------------------
  
  Brick_on_proc : process (BrickX, BrickY, DrawX, DrawY)
  begin
	Brick_On <= '0';
	--for I in 0 to 19 loop
	--start <= I*11+10;
	--ender <= I*11;
	--case I is
	--when 0 =>
	--BrickX <= BricksX(10 downto 0);
	--BrickY <= BricksY(10 downto 0);
	--BrickOn <= BricksOn(0);
	--when others =>
	--BrickX <= BricksX(219 downto 209);
	--BrickY <= BricksY(219 downto 209);
	--BrickOn <= BricksOn(19);
	--end case;
	--BrickX <= BricksX(10 downto 0);
	--BrickY <= BricksY(10 downto 0);
	--BrickOn <= BricksOn(0);
	
	if (DrawX <= BricksX(10 downto 0) + Brick_Width) AND (DrawX >= BricksX(10 downto 0))
			AND (DrawY>= BricksY(10 downto 0)) AND (DrawY<= BricksY(10 downto 0) + Brick_Height)
			AND (BricksOn(0) = '1') then
			Brick_On <= '1';
	elsif (DrawX <= BricksX(21 downto 11) + Brick_Width) AND (DrawX >= BricksX(21 downto 11))
			AND (DrawY>= BricksY(21 downto 11)) AND (DrawY<= BricksY(21 downto 11) + Brick_Height)
			AND (BricksOn(1) = '1') then
			Brick_On <= '1';
	elsif (DrawX <= BricksX(32 downto 22) + Brick_Width) AND (DrawX >= BricksX(32 downto 22))
			AND (DrawY>= BricksY(32 downto 22)) AND (DrawY<= BricksY(32 downto 22) + Brick_Height)
			AND (BricksOn(2) = '1') then
			Brick_On <= '1';
	elsif (DrawX <= BricksX(43 downto 33) + Brick_Width) AND (DrawX >= BricksX(43 downto 33))
			AND (DrawY>= BricksY(43 downto 33)) AND (DrawY<= BricksY(43 downto 33) + Brick_Height)
			AND (BricksOn(3) = '1') then
			Brick_On <= '1';
	elsif (DrawX <= BricksX(54 downto 44) + Brick_Width) AND (DrawX >= BricksX(54 downto 44))
			AND (DrawY>= BricksY(54 downto 44)) AND (DrawY<= BricksY(54 downto 44) + Brick_Height)
			AND (BricksOn(4) = '1') then
			Brick_On <= '1';
	elsif (DrawX <= BricksX(65 downto 55) + Brick_Width) AND (DrawX >= BricksX(65 downto 55))
			AND (DrawY>= BricksY(65 downto 55)) AND (DrawY<= BricksY(65 downto 55) + Brick_Height)
			AND (BricksOn(5) = '1') then
			Brick_On <= '1';
	elsif (DrawX <= BricksX(76 downto 66) + Brick_Width) AND (DrawX >= BricksX(76 downto 66))
			AND (DrawY>= BricksY(76 downto 66)) AND (DrawY<= BricksY(76 downto 66) + Brick_Height)
			AND (BricksOn(6) = '1') then
			Brick_On <= '1';
	elsif (DrawX <= BricksX(87 downto 77) + Brick_Width) AND (DrawX >= BricksX(87 downto 77))
			AND (DrawY>= BricksY(87 downto 77)) AND (DrawY<= BricksY(87 downto 77) + Brick_Height)
			AND (BricksOn(7) = '1') then
			Brick_On <= '1';
	elsif (DrawX <= BricksX(98 downto 88) + Brick_Width) AND (DrawX >= BricksX(98 downto 88))
			AND (DrawY>= BricksY(98 downto 88)) AND (DrawY<= BricksY(98 downto 88) + Brick_Height)
			AND (BricksOn(8) = '1') then
			Brick_On <= '1';
	elsif (DrawX <= BricksX(109 downto 99) + Brick_Width) AND (DrawX >= BricksX(109 downto 99))
			AND (DrawY>= BricksY(109 downto 99)) AND (DrawY<= BricksY(109 downto 99) + Brick_Height)
			AND (BricksOn(9) = '1') then
			Brick_On <= '1';
	elsif (DrawX <= BricksX(120 downto 110) + Brick_Width) AND (DrawX >= BricksX(120 downto 110))
			AND (DrawY>= BricksY(120 downto 110)) AND (DrawY<= BricksY(120 downto 110) + Brick_Height)
			AND (BricksOn(10) = '1') then
			Brick_On <= '1';
	elsif (DrawX <= BricksX(131 downto 121) + Brick_Width) AND (DrawX >= BricksX(131 downto 121))
			AND (DrawY>= BricksY(131 downto 121)) AND (DrawY<= BricksY(131 downto 121) + Brick_Height)
			AND (BricksOn(11) = '1') then
			Brick_On <= '1';
	elsif (DrawX <= BricksX(142 downto 132) + Brick_Width) AND (DrawX >= BricksX(142 downto 132))
			AND (DrawY>= BricksY(142 downto 132)) AND (DrawY<= BricksY(142 downto 132) + Brick_Height)
			AND (BricksOn(12) = '1') then
			Brick_On <= '1';
	elsif (DrawX <= BricksX(153 downto 143) + Brick_Width) AND (DrawX >= BricksX(153 downto 143))
			AND (DrawY>= BricksY(153 downto 143)) AND (DrawY<= BricksY(153 downto 143) + Brick_Height)
			AND (BricksOn(13) = '1') then
			Brick_On <= '1';
	elsif (DrawX <= BricksX(164 downto 154) + Brick_Width) AND (DrawX >= BricksX(164 downto 154))
			AND (DrawY>= BricksY(164 downto 154)) AND (DrawY<= BricksY(164 downto 154) + Brick_Height)
			AND (BricksOn(14) = '1') then
			Brick_On <= '1';
	elsif (DrawX <= BricksX(175 downto 165) + Brick_Width) AND (DrawX >= BricksX(175 downto 165))
			AND (DrawY>= BricksY(175 downto 165)) AND (DrawY<= BricksY(175 downto 165) + Brick_Height)
			AND (BricksOn(15) = '1') then
			Brick_On <= '1';
	elsif (DrawX <= BricksX(186 downto 176) + Brick_Width) AND (DrawX >= BricksX(186 downto 176))
			AND (DrawY>= BricksY(186 downto 176)) AND (DrawY<= BricksY(186 downto 176) + Brick_Height)
			AND (BricksOn(16) = '1') then
			Brick_On <= '1';
	elsif (DrawX <= BricksX(197 downto 187) + Brick_Width) AND (DrawX >= BricksX(197 downto 187))
			AND (DrawY>= BricksY(197 downto 187)) AND (DrawY<= BricksY(197 downto 187) + Brick_Height)
			AND (BricksOn(17) = '1') then
			Brick_On <= '1';
	elsif (DrawX <= BricksX(208 downto 198) + Brick_Width) AND (DrawX >= BricksX(208 downto 198))
			AND (DrawY>= BricksY(208 downto 198)) AND (DrawY<= BricksY(208 downto 198) + Brick_Height)
			AND (BricksOn(18) = '1') then
			Brick_On <= '1';		
	elsif (DrawX <= BricksX(219 downto 209) + Brick_Width) AND (DrawX >= BricksX(219 downto 209))
			AND (DrawY>= BricksY(219 downto 209)) AND (DrawY<= BricksY(219 downto 209) + Brick_Height)
			AND (BricksOn(19) = '1') then
			Brick_On <= '1';
	end if;
	--end loop;
  end process Brick_on_proc;
--
--
-----------------------------------------------------


  RGB_Display : process (game_status, Ball_on, Paddle_on, Brick_on, DrawX, DrawY)
    variable GreenVar, BlueVar : std_logic_vector(22 downto 0);
  begin
    if (Ball_on = '1') AND
		(Paddle_on = '0')	then -- turn ball on display				--ball
    if (game_status(0) = '0') then
			Red 	<= "0101010101";
			Green 	<= "1010101010";
			Blue 	<= "1010101010";
		else							--change ball to black if lost
			Red 	<= "0000000000";
			Green 	<= "0000000000";
			Blue 	<= "0000000000";
		end if;
    elsif (Paddle_on = '1') then  -- turn paddle on display				--paddle
		if (game_status(0) = '0') then
			Red 	<= "0000000000";
			Green 	<= "1001100010";
			Blue 	<= "0000000000";
		else							--change paddle to red if lost
			Red 	<= "1001100010";
			Green 	<= "0000000000";
			Blue 	<= "0000000000";
		end if;
	elsif (Brick_On = '1') then --turn brick on display					--bricks
		if (game_status(0) = '0') then
			Red 	<= "1010101010";
			Green 	<= "0101010101";
			Blue 	<= "0000000000";
		else							--change brick to White if lost
			Red 	<= "1010101010";
			Green 	<= "1010101010";
			Blue 	<= "1010101010";
		end if;
    else          				 -- turn on gradient background			--BG
      if (game_status(3) = '1') then
			Red   <= DrawY(9 downto 0);
			Green <= "0111100010";
			Blue  <= DrawY(9 downto 0);
	  elsif (game_status(0) = '0') then
			Red   <= DrawY(9 downto 0);
			Green <= DrawY(9 downto 0);
			Blue  <= DrawY(9 downto 0);
	  else								--change background to if lost
			Red   <= "0111100010";
			Green <= DrawY(9 downto 0);
			Blue  <= DrawY(9 downto 0);
	end if;
	  
	  
    end if;
  end process RGB_Display;

-----------------------------------------------------

end Behavioral;

------------Previous Code, saved for possible reuse ------------------
--	BrickX <= temp1;
--	BrickY <= temp1;
--	Brick_size <= "0000000100"
--	
--	--already lose? put all Bricks back
--	if (game_statusSig = '1') then Brick_statusSig <= '0';
--	end if;
--
--  	if ((DrawX >= BrickX - ("0000000100"*Brick_size)) 	AND
--		(DrawX <= BrickX + ("0000000100"*Brick_size)) 	AND
--		(DrawY >= BrickY - Brick_size) 					AND
--		(DrawY <= BrickY + Brick_size)) 			then
--			Brick_on <= '1';
--	else
--			Brick_on <= '0';
--	end if;
---------------------------------------------------------------------