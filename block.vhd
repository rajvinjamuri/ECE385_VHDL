---------------------------------------------------------------------------
---------------------------------------------------------------------------
--    Brick.vhd  (Ball.vhd)                                              --
--                                                                       --
--    Modeled off ball.vhd version by Stephen Kempf and Viral Mehta      --
--																		 --
--	  by Raj Vinjamuri and Sai Koppula                                   --
--	  Final Modifications by Raj Vinjamuri and Sai Koppula			     --
---------------------------------------------------------------------------
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Brick is
   Port ( 	clk, Reset, frame_clk : in std_logic;
			BallX, BallY, BallS : in std_logic_vector(10 downto 0);
			BrickXIn, BrickYIn : in std_logic_vector(10 downto 0);
			--BrickX, BrickY: out std_logic_vector(10 downto 0);
			brick_hit: out std_logic;
			BrickOn: out std_logic);
end Brick;

architecture Behavioral of Brick is

signal Brick_statusSig : std_logic;
signal brick_hitSig : std_logic;
signal Brick_X_pos, Brick_Y_pos : std_logic_vector(10 downto 0);
signal Brick_Width : std_logic_vector(10 downto 0);
signal Brick_Height: std_logic_vector(10 downto 0);
signal Brick_X, Brick_Y : std_logic_vector (10 downto 0);
--constant Brick_X : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(0, 11);  --Center position on the X axis
--constant Brick_Y : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(0, 11);  --Center position on the Y axis
signal Brick_Y_Set : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(20, 11);  --Center position on the Y axis

constant Brick_X_Min    : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(0, 11);  --Leftmost point on the X axis
constant Brick_X_Max    : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(639, 11);  --Rightmost point on the X axis
constant Brick_Y_Min    : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(0, 11);   --Topmost point on the Y axis
constant Brick_Y_Max    : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(470, 11);  --Bottommost point on the Y axis
                              
begin
  Brick_Width <= CONV_STD_LOGIC_VECTOR(60, 11);
  Brick_Height <= CONV_STD_LOGIC_VECTOR(20, 11);
  Brick_X <= BrickXIn;
  Brick_Y <= BrickYIn;
  
  Handle_Brick: process(Reset, frame_clk)
  begin
  
	
    if(Reset = '1') then   --Asynchronous Reset
    Brick_Y_pos <= Brick_Y;
    Brick_X_pos <= Brick_X;
    Brick_statusSig <= '1';
    
    elsif(rising_edge(frame_clk)) then
	
		brick_hitSig <= '0';

		if (BallX-BallS <= Brick_X + Brick_Width) AND (BallX-BallS >= Brick_X)
			AND (BallY+BallS>= Brick_Y) AND (BallY-BallS<= Brick_Y + Brick_Height) then
			if (Brick_statusSig = '1') then brick_hitSig <= '1'; end if;
			Brick_statusSig <= '0';
		elsif (BallX+BallS <= Brick_X + Brick_Width) AND (BallX+BallS >= Brick_X)
			AND (BallY+BallS>= Brick_Y) AND (BallY-BallS<= Brick_Y + Brick_Height) then
			if (Brick_statusSig = '1') then brick_hitSig <= '1'; end if;
			Brick_statusSig <= '0';
		elsif (BallY-BallS <= Brick_Y + Brick_Height) AND (BallY-BallS >= Brick_Y)
			AND (BallX+BallS>= Brick_X) AND (BallX-BallS<= Brick_X + Brick_Width) then
			if (Brick_statusSig = '1') then brick_hitSig <= '1'; end if;
			Brick_statusSig <= '0';
		elsif (BallY+BallS <= Brick_Y + Brick_Height) AND (BallY+BallS >= Brick_Y)
			AND (BallX+BallS>= Brick_X) AND (BallX-BallS<= Brick_X + Brick_Width) then
			if (Brick_statusSig = '1') then brick_hitSig <= '1'; end if;
			Brick_statusSig <= '0';
		end if;
    
	end if;
  
  end process Handle_Brick;

  --BrickX <= Brick_X_pos;
  --BrickY <= Brick_Y_pos;
  BrickOn <= Brick_statusSig;
  brick_hit <= brick_hitSig;

end Behavioral;      
