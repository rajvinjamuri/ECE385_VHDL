---------------------------------------------------------------------------
---------------------------------------------------------------------------
--    Paddle.vhd  (Ball.vhd)                                             --
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
--use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity paddle is
   Port ( 	Up, Do, Le, Ri : in std_logic;				--added direction signals to modify direction
			Reset : in std_logic;
			frame_clk : in std_logic;
			PaddleX : out std_logic_vector(10 downto 0);
			PaddleY : out std_logic_vector(10 downto 0);
			PaddleS : out std_logic_vector(10 downto 0));
end paddle;

architecture Behavioral of paddle is

signal U, D, L, R : std_logic_vector (0 downto 0);		--added signals to use for math needed to change motion vars

signal Paddle_X_Pos, Paddle_Y_Pos, Paddle_Y_motion, Paddle_X_motion : std_logic_vector(10 downto 0);
signal Paddle_Size : std_logic_vector(10 downto 0);

constant Paddle_X_Start : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(320, 11);  --Center position on the X axis
constant Paddle_Y_Start : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(460, 11);  --Center position on the Y axis

constant Paddle_X_Min    : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(0, 11);  --Leftmost point on the X axis
constant Paddle_X_Max    : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(639, 11);  --Rightmost point on the X axis
constant Paddle_Y_Min    : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(0, 11);   --Topmost point on the Y axis
constant Paddle_Y_Max    : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(479, 11);  --Bottommost point on the Y axis
                              
constant Paddle_X_Step   : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(1, 11);  --Step size on the X axis (modified)
constant Paddle_Y_Step   : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(1, 11);  --Step size on the Y axis

begin
  Paddle_Size <= CONV_STD_LOGIC_VECTOR(4, 11); -- assigns the value 4 as a 10-digit binary number, ie "0000000100"
	U(0) <= Up;			--set internal signal/vars
	D(0) <= Do;	
	L(0) <= Le;
	R(0) <= Ri;


  Move_Paddle: process(Reset, frame_clk, Paddle_Size)
  begin
    if(Reset = '1') then   --Asynchronous Reset
      Paddle_Y_motion <= "00000000000";		--all the initial movement settings
      Paddle_X_motion <= "00000000000";
      Paddle_Y_Pos <= Paddle_Y_Start;
      Paddle_X_Pos <= Paddle_X_Start;

    elsif(rising_edge(frame_clk)) then
    
      if ((R(0) or L(0)) = '1') then		--see notes on up/down/y-direction
        if (R(0) = '1')then
			Paddle_X_Pos <= Paddle_X_Pos + "00000000011"; --Verify this works.
			if (Paddle_X_Pos + ("00000000110"*Paddle_size) >= Paddle_X_Max) then
			Paddle_X_Pos <= Paddle_X_Max - (Paddle_Size + Paddle_Size + Paddle_Size + Paddle_Size + Paddle_Size + Paddle_Size);
			end if;
		elsif (L(0) = '1') then
			Paddle_X_Pos <= Paddle_X_Pos - "00000000011";  --Verify this works. update: this KINDA works
			if (Paddle_X_Pos - ("00000000110"*Paddle_size) <= Paddle_X_Min ) then						--change here to fix going off screen
			Paddle_X_Pos <= Paddle_X_Min + (Paddle_Size + Paddle_Size + Paddle_Size + Paddle_Size + Paddle_Size + Paddle_Size);--Paddle_X_Min + (Paddle_Size + Paddle_Size);
			end if;
			--Paddle_X_Pos <= Paddle_X_Pos + "1111111101";  --Verify this works. update: this KINDA works
		else Paddle_X_Pos <= Paddle_X_Pos;
		end if;
	  end if;
	  
	  --if (Paddle_X_Pos - ("00000000110"*Paddle_size) <= Paddle_X_Min + ("00000000110"*Paddle_size)) then						--change here to fix going off screen
		--Paddle_X_Pos <= Paddle_X_Min + (Paddle_Size + Paddle_Size + Paddle_Size + Paddle_Size + Paddle_Size + Paddle_Size);--Paddle_X_Min + (Paddle_Size + Paddle_Size);
	 -- if (Paddle_X_Pos + ("00000000110"*Paddle_size) >= Paddle_X_Max - ("00000000110"*Paddle_size)) then
	  	--Paddle_X_Pos <= Paddle_X_Max - (Paddle_Size + Paddle_Size + Paddle_Size + Paddle_Size + Paddle_Size + Paddle_Size);		--if this were real I would take a steaming poop on it
	  	--cant get this to work. Keeps showing up on the other side
	  --end if;
      

      --Ball_Y_pos <= Ball_Y_pos + Ball_Y_Motion; -- Update ball position 
      --Ball_X_pos <= Ball_X_pos + Ball_X_Motion;

	
    end if;
  
  end process Move_Paddle;

  PaddleX <= Paddle_X_Pos;
  PaddleY <= Paddle_Y_Start;
  PaddleS <= Paddle_Size;
 
end Behavioral;      
