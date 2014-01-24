---------------------------------------------------------------------------
---------------------------------------------------------------------------
--    Ball.vhd				                                             --
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

entity ball is
   Port ( 	Le, Ri : in std_logic;				--same as keyboard input. Used to dictate ball reaction
			--Up, Do, Le, Ri : in std_logic;
			clk : in std_logic;
			Reset : in std_logic;
			frame_clk : in std_logic;
			StartMove : in std_logic;
			seedIn : in std_logic_vector(17 downto 0);
			BallX : out std_logic_vector(10 downto 0);
			BallY : out std_logic_vector(10 downto 0);
			BallS : out std_logic_vector(10 downto 0);
			PaddleX : in std_logic_vector(10 downto 0);
			PaddleY : in std_logic_vector(10 downto 0);
			PaddleS : in std_logic_vector(10 downto 0);
			BricksX : in std_logic_vector(219 downto 0);
			BricksY : in std_logic_vector(219 downto 0);
			BricksOn : in std_logic_vector(19 downto 0);
			paddle_loss_status : out std_logic_vector(1 downto 0));
end ball;

architecture Behavioral of ball is

--signal L, R : std_logic_vector (0 downto 0);		--added signals to use for math needed to change motion vars
signal paddle_loss_statusSig : std_logic_vector(1 downto 0);
signal Ball_X_pos, Ball_X_motion, Ball_Y_pos, Ball_Y_motion : std_logic_vector(10 downto 0);
signal Ball_Size : std_logic_vector(10 downto 0);


constant Ball_X_Center : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(320, 11);  --Center position on the X axis
constant Ball_Y_Center : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(240, 11);  --Center position on the Y axis
constant Ball_Y_Set : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(450, 11);  --Center position on the Y axis

constant Ball_X_Min    : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(0, 11);  --Leftmost point on the X axis
constant Ball_X_Max    : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(639, 11);  --Rightmost point on the X axis
constant Ball_Y_Min    : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(0, 11);   --Topmost point on the Y axis
constant Ball_Y_Max    : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(470, 11);  --Bottommost point on the Y axis
                             
signal Ball_X_Step   : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(1, 11);  --Step size on the X axis (modified)
signal Ball_Y_Step   : std_logic_vector(10 downto 0) := CONV_STD_LOGIC_VECTOR(2, 11);  --Step size on the Y axis (modified)

signal Brick_Width, Brick_Height : std_logic_vector(10 downto 0);
signal BrickX, BrickY : std_logic_vector(10 downto 0);
signal BrickOn : std_logic;


begin

  Ball_Size <= CONV_STD_LOGIC_VECTOR(4, 11); -- assigns the value 4 as a 10-digit binary number, ie "0000000100"
--  Ball_Y_Step <= not(Ball_Y_Step) + '1';
  
	--U(0) <= Up;			--set internal signal/vars
	--D(0) <= Do;	
	--L(0) <= Le;
	--R(0) <= Ri;


  Move_Ball: process(Reset, frame_clk, Ball_Size)
  begin
  
--Temp Brick info  
	Brick_Width <= CONV_STD_LOGIC_VECTOR(60, 11);
	Brick_Height <= CONV_STD_LOGIC_VECTOR(20, 11);
  
-------Randomizing y-step value with seed---------------
	if (seedIn(2) = '1') then 
		Ball_X_Step <= "00000000010";
	else 
		Ball_X_Step <= "00000000001";
	end if;
  
  
-------[START] Reset and Initial Conditions--------------	  
if(Reset = '1') then   --Asynchronous Reset

	Ball_Y_Motion <= "00000000000";		--changed
	Ball_X_Motion <= "00000000000";
	
--	if (StartMove = '1') then
--		if (seedIn(3)  = '1') then
--			Ball_Y_Motion <= not(Ball_Y_Step) + '1';		--all the initial movement settings
--			Ball_X_Motion <= Ball_X_Step;
--		else
--			Ball_Y_Motion <= not(Ball_Y_Step) + '1';		--all the initial movement settings
--			Ball_X_Motion <= not(Ball_X_Step) + '1';
--		end if;
--	end if;	
		
    paddle_loss_statusSig <= "00";
    Ball_Y_pos <= Ball_Y_Set;
    Ball_X_pos <= Ball_X_Center;
-------[END] Reset and Initial Conditions--------------


elsif(rising_edge(frame_clk)) then
    paddle_loss_statusSig(1) <= '0';			--change paddle-hit back to zero on next interaction-cycle
    
    if (StartMove = '1') then
		if (seedIn(3)  = '1') then
			Ball_Y_Motion <= not(Ball_Y_Step) + '1';		--all the initial movement settings
			Ball_X_Motion <= Ball_X_Step;
		else
			Ball_Y_Motion <= not(Ball_Y_Step) + '1';		--all the initial movement settings
			Ball_X_Motion <= not(Ball_X_Step) + '1';
		end if;
	else
		Ball_Y_Motion <= Ball_Y_Motion;
		Ball_X_Motion <= Ball_X_Motion;
	end if;	

    
-------Wall Interactions Below (X-axis change in ball movement)---------------	
	  if ((Ball_X_Pos - Ball_Size - "00000000100" <= Ball_X_Min) OR (Ball_X_Pos - Ball_Size - "00000000100" >= Ball_X_Max) ) then						--change here to fix going off screen
		Ball_X_Pos <= Ball_X_Min + Ball_Size;
		Ball_X_Motion <= Ball_X_Step;
	  elsif	(Ball_X_Pos + Ball_Size >= Ball_X_Max) then
	  	Ball_X_Pos <= Ball_X_Max - Ball_Size;
	  	Ball_X_Motion <= not(Ball_X_Step) + '1';							--change here to fix going off screen

	--redundancy in wall conditions:
      elsif   (Ball_X_pos + Ball_Size >= Ball_X_Max) then -- Ball is at the right edge, BOUNCE!
        Ball_X_Motion <= not(Ball_X_Step) + '1'; --2's complement.
      elsif((Ball_X_Pos - Ball_Size - "00000000100" <= Ball_X_Min) OR (Ball_X_Pos - Ball_Size - "00000000100" >= Ball_X_Max) )then  -- Ball is at the left edge, BOUNCE!
        Ball_X_Motion <= Ball_X_Step;
--      end if;  
      

-------Wall Interactions Below (Y-axis change in ball movement)---------------
      elsif (Ball_Y_Pos - Ball_Size - Ball_Y_Step <= Ball_Y_Min) then						--change here to fix going off screen
		Ball_Y_Pos <= Ball_Y_Min + Ball_Size;
		Ball_Y_Motion <= Ball_Y_Step;
	  --elsif	(Ball_Y_Pos + Ball_Size >= Ball_Y_Max) then
	  	--Ball_Y_Pos <= Ball_Y_Max - Ball_Size;
	  	--Ball_Y_Motion <= not(Ball_Y_Step) + '1';							--change here to fix going off screen
	  	
      --elsif(Ball_Y_pos - Ball_Size <= Ball_Y_Min) then  -- Ball is at the top edge, BOUNCE! If at bottom then dealt with in loss conditions
        --Ball_Y_Motion <= Ball_Y_Step;
        
--      end if;

          
-------Losing Condition Check/Set (Ball Movement and Game_Status change)---------------	
      elsif   (Ball_Y_pos + Ball_Size >= Ball_Y_Max) then -- Ball is at the bottom edge, go to the right

		if (Ball_X_Motion < 0) then --if going left then go right
			Ball_X_Motion <= not(Ball_X_Step) + '1'; --2's complement.
		end if;

		if (paddle_loss_statusSig(0) = '1') then Ball_Y_Motion <= "00000000000"; --soon after the bounce, make it zero
		end if;

	  paddle_loss_statusSig <= "01";			--indicate loss


-------Difficulty Change Below (Various change in ball movement)---------------	
	  --elsif (U(0) = '1') then Ball_Y_Motion <= Ball_Y_Step + "0000000001";	--change difficulty up on "W"
	  --elsif (D(0) = '1') then Ball_Y_Motion <= Ball_Y_Step - "0000000001";	--change difficulty down on "S"

        
-------Paddle Interactions Below (Y-axis and X-axis change in ball movement)---------------	
      elsif((Ball_Y_Pos + Ball_Size >= PaddleY - (PaddleS)) AND ((Ball_X_Pos + Ball_Size >= PaddleX - ("00000000110" * PaddleS) AND Ball_X_Pos + Ball_Size <= PaddleX + ("00000000110"*PaddleS)) 
			OR (Ball_X_Pos - Ball_Size >= PaddleX - ("00000000110" * PaddleS) AND Ball_X_Pos - Ball_Size <= PaddleX + ("00000000110"*PaddleS))))  then
				if (Le = '1') then 									--depending on paddle movement, have ball go in according X-direction
					Ball_X_Motion <= not(Ball_X_Step) + '1';		--go left
				elsif (Ri = '1') then 
					Ball_X_Motion <= Ball_X_Step;					--go right
				end if;
				
				Ball_Y_Motion <= not(Ball_Y_Step) + '1';
				paddle_loss_statusSig(1) <= '1';			--indicate paddle hit

	  elsif(Ball_X_Pos - Ball_Size <= PaddleX + ("00000000110"*PaddleS) AND Ball_X_Pos - Ball_Size >= PaddleX - ("0000000110"*PaddleS) AND Ball_Y_Pos - Ball_Size >= PaddleY - PaddleS AND Ball_Y_Pos + Ball_Size >= PaddleY + PaddleS)  then
				Ball_X_Motion <= Ball_X_Step;
				paddle_loss_statusSig(1) <= '1';			--indicate paddle hit
	  elsif(Ball_X_Pos + Ball_Size <= PaddleX + ("00000000110"*PaddleS) AND Ball_X_Pos + Ball_Size >= PaddleX - ("0000000110"*PaddleS) AND Ball_Y_Pos - Ball_Size >= PaddleY - PaddleS AND Ball_Y_Pos + Ball_Size >= PaddleY + PaddleS)  then
				Ball_X_Motion <= not(Ball_X_Step) + '1';
				paddle_loss_statusSig(1) <= '1';			--indicate paddle hit
	  end if;
	  
	  

------Brick Interactions Below (Y-axis change in ball movement)----------------
	  if(Ball_Y_Pos - Ball_Size <= BricksY(10 downto 0) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(10 downto 0) AND Ball_X_Pos + Ball_Size >= BricksX(10 downto 0) AND Ball_X_Pos - Ball_Size <= BricksX(10 downto 0) + Brick_Width AND BricksOn(0) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(10 downto 0) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(10 downto 0) AND Ball_X_Pos + Ball_Size >= BricksX(10 downto 0) AND Ball_X_Pos - Ball_Size <= BricksX(10 downto 0) + Brick_Width AND BricksOn(0) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
	  elsif(Ball_Y_Pos - Ball_Size <= BricksY(21 downto 11) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(21 downto 11) AND Ball_X_Pos + Ball_Size >= BricksX(21 downto 11) AND Ball_X_Pos - Ball_Size <= BricksX(21 downto 11) + Brick_Width AND BricksOn(1) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(21 downto 11) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(21 downto 11) AND Ball_X_Pos + Ball_Size >= BricksX(21 downto 11) AND Ball_X_Pos - Ball_Size <= BricksX(21 downto 11) + Brick_Width AND BricksOn(1) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
	  elsif(Ball_Y_Pos - Ball_Size <= BricksY(32 downto 22) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(32 downto 22) AND Ball_X_Pos + Ball_Size >= BricksX(32 downto 22) AND Ball_X_Pos - Ball_Size <= BricksX(32 downto 22) + Brick_Width AND BricksOn(2) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(32 downto 22) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(32 downto 22) AND Ball_X_Pos + Ball_Size >= BricksX(32 downto 22) AND Ball_X_Pos - Ball_Size <= BricksX(32 downto 22) + Brick_Width AND BricksOn(2) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
	  elsif(Ball_Y_Pos - Ball_Size <= BricksY(43 downto 33) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(43 downto 33) AND Ball_X_Pos + Ball_Size >= BricksX(43 downto 33) AND Ball_X_Pos - Ball_Size <= BricksX(43 downto 33) + Brick_Width AND BricksOn(3) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(43 downto 33) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(43 downto 33) AND Ball_X_Pos + Ball_Size >= BricksX(43 downto 33) AND Ball_X_Pos - Ball_Size <= BricksX(43 downto 33) + Brick_Width AND BricksOn(3) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
	  elsif(Ball_Y_Pos - Ball_Size <= BricksY(54 downto 44) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(54 downto 44) AND Ball_X_Pos + Ball_Size >= BricksX(54 downto 44) AND Ball_X_Pos - Ball_Size <= BricksX(54 downto 44) + Brick_Width AND BricksOn(4) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(54 downto 44) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(54 downto 44) AND Ball_X_Pos + Ball_Size >= BricksX(54 downto 44) AND Ball_X_Pos - Ball_Size <= BricksX(54 downto 44) + Brick_Width AND BricksOn(4) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
	  elsif(Ball_Y_Pos - Ball_Size <= BricksY(65 downto 55) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(65 downto 55) AND Ball_X_Pos + Ball_Size >= BricksX(65 downto 55) AND Ball_X_Pos - Ball_Size <= BricksX(65 downto 55) + Brick_Width AND BricksOn(5) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(65 downto 55) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(65 downto 55) AND Ball_X_Pos + Ball_Size >= BricksX(65 downto 55) AND Ball_X_Pos - Ball_Size <= BricksX(65 downto 55) + Brick_Width AND BricksOn(5) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
	  elsif(Ball_Y_Pos - Ball_Size <= BricksY(76 downto 66) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(76 downto 66) AND Ball_X_Pos + Ball_Size >= BricksX(76 downto 66) AND Ball_X_Pos - Ball_Size <= BricksX(76 downto 66) + Brick_Width AND BricksOn(6) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(76 downto 66) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(76 downto 66) AND Ball_X_Pos + Ball_Size >= BricksX(76 downto 66) AND Ball_X_Pos - Ball_Size <= BricksX(76 downto 66) + Brick_Width AND BricksOn(6) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
	  elsif(Ball_Y_Pos - Ball_Size <= BricksY(87 downto 77) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(87 downto 77) AND Ball_X_Pos + Ball_Size >= BricksX(87 downto 77) AND Ball_X_Pos - Ball_Size <= BricksX(87 downto 77) + Brick_Width AND BricksOn(7) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(87 downto 77) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(87 downto 77) AND Ball_X_Pos + Ball_Size >= BricksX(87 downto 77) AND Ball_X_Pos - Ball_Size <= BricksX(87 downto 77) + Brick_Width AND BricksOn(7) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
	  elsif(Ball_Y_Pos - Ball_Size <= BricksY(98 downto 88) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(98 downto 88) AND Ball_X_Pos + Ball_Size >= BricksX(98 downto 88) AND Ball_X_Pos - Ball_Size <= BricksX(98 downto 88) + Brick_Width AND BricksOn(8) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(98 downto 88) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(98 downto 88) AND Ball_X_Pos + Ball_Size >= BricksX(98 downto 88) AND Ball_X_Pos - Ball_Size <= BricksX(98 downto 88) + Brick_Width AND BricksOn(8) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
	  elsif(Ball_Y_Pos - Ball_Size <= BricksY(109 downto 99) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(109 downto 99) AND Ball_X_Pos + Ball_Size >= BricksX(109 downto 99) AND Ball_X_Pos - Ball_Size <= BricksX(109 downto 99) + Brick_Width AND BricksOn(9) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(109 downto 99) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(109 downto 99) AND Ball_X_Pos + Ball_Size >= BricksX(109 downto 99) AND Ball_X_Pos - Ball_Size <= BricksX(109 downto 99) + Brick_Width AND BricksOn(9) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
	  elsif(Ball_Y_Pos - Ball_Size <= BricksY(120 downto 110) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(120 downto 110) AND Ball_X_Pos + Ball_Size >= BricksX(120 downto 110) AND Ball_X_Pos - Ball_Size <= BricksX(120 downto 110) + Brick_Width AND BricksOn(10) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(120 downto 110) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(120 downto 110) AND Ball_X_Pos + Ball_Size >= BricksX(120 downto 110) AND Ball_X_Pos - Ball_Size <= BricksX(120 downto 110) + Brick_Width AND BricksOn(10) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
	  elsif(Ball_Y_Pos - Ball_Size <= BricksY(131 downto 121) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(131 downto 121) AND Ball_X_Pos + Ball_Size >= BricksX(131 downto 121) AND Ball_X_Pos - Ball_Size <= BricksX(131 downto 121) + Brick_Width AND BricksOn(11) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(131 downto 121) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(131 downto 121) AND Ball_X_Pos + Ball_Size >= BricksX(131 downto 121) AND Ball_X_Pos - Ball_Size <= BricksX(131 downto 121) + Brick_Width AND BricksOn(11) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
	  elsif(Ball_Y_Pos - Ball_Size <= BricksY(142 downto 132) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(142 downto 132) AND Ball_X_Pos + Ball_Size >= BricksX(142 downto 132) AND Ball_X_Pos - Ball_Size <= BricksX(142 downto 132) + Brick_Width AND BricksOn(12) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(142 downto 132) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(142 downto 132) AND Ball_X_Pos + Ball_Size >= BricksX(142 downto 132) AND Ball_X_Pos - Ball_Size <= BricksX(142 downto 132) + Brick_Width AND BricksOn(12) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
	  elsif(Ball_Y_Pos - Ball_Size <= BricksY(153 downto 143) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(153 downto 143) AND Ball_X_Pos + Ball_Size >= BricksX(153 downto 143) AND Ball_X_Pos - Ball_Size <= BricksX(153 downto 143) + Brick_Width AND BricksOn(13) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(153 downto 143) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(153 downto 143) AND Ball_X_Pos + Ball_Size >= BricksX(153 downto 143) AND Ball_X_Pos - Ball_Size <= BricksX(153 downto 143) + Brick_Width AND BricksOn(13) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
	  elsif(Ball_Y_Pos - Ball_Size <= BricksY(164 downto 154) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(164 downto 154) AND Ball_X_Pos + Ball_Size >= BricksX(164 downto 154) AND Ball_X_Pos - Ball_Size <= BricksX(164 downto 154) + Brick_Width AND BricksOn(14) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(164 downto 154) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(164 downto 154) AND Ball_X_Pos + Ball_Size >= BricksX(164 downto 154) AND Ball_X_Pos - Ball_Size <= BricksX(164 downto 154) + Brick_Width AND BricksOn(14) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
	  elsif(Ball_Y_Pos - Ball_Size <= BricksY(175 downto 165) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(175 downto 165) AND Ball_X_Pos + Ball_Size >= BricksX(175 downto 165) AND Ball_X_Pos - Ball_Size <= BricksX(175 downto 165) + Brick_Width AND BricksOn(15) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(175 downto 165) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(175 downto 165) AND Ball_X_Pos + Ball_Size >= BricksX(175 downto 165) AND Ball_X_Pos - Ball_Size <= BricksX(175 downto 165) + Brick_Width AND BricksOn(15) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
	  elsif(Ball_Y_Pos - Ball_Size <= BricksY(186 downto 176) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(186 downto 176) AND Ball_X_Pos + Ball_Size >= BricksX(186 downto 176) AND Ball_X_Pos - Ball_Size <= BricksX(186 downto 176) + Brick_Width AND BricksOn(16) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(186 downto 176) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(186 downto 176) AND Ball_X_Pos + Ball_Size >= BricksX(186 downto 176) AND Ball_X_Pos - Ball_Size <= BricksX(186 downto 176) + Brick_Width AND BricksOn(16) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
	  elsif(Ball_Y_Pos - Ball_Size <= BricksY(197 downto 187) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(197 downto 187) AND Ball_X_Pos + Ball_Size >= BricksX(197 downto 187) AND Ball_X_Pos - Ball_Size <= BricksX(197 downto 187) + Brick_Width AND BricksOn(17) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(197 downto 187) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(197 downto 187) AND Ball_X_Pos + Ball_Size >= BricksX(197 downto 187) AND Ball_X_Pos - Ball_Size <= BricksX(197 downto 187) + Brick_Width AND BricksOn(17) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
	  elsif(Ball_Y_Pos - Ball_Size <= BricksY(208 downto 198) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(208 downto 198) AND Ball_X_Pos + Ball_Size >= BricksX(208 downto 198) AND Ball_X_Pos - Ball_Size <= BricksX(208 downto 198) + Brick_Width AND BricksOn(18) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(208 downto 198) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(208 downto 198) AND Ball_X_Pos + Ball_Size >= BricksX(208 downto 198) AND Ball_X_Pos - Ball_Size <= BricksX(208 downto 198) + Brick_Width AND BricksOn(18) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
	  elsif(Ball_Y_Pos - Ball_Size <= BricksY(219 downto 209) + Brick_Height AND Ball_Y_Pos - Ball_Size >= BricksY(219 downto 209) AND Ball_X_Pos + Ball_Size >= BricksX(219 downto 209) AND Ball_X_Pos - Ball_Size <= BricksX(219 downto 209) + Brick_Width AND BricksOn(19) = '1')  then
		Ball_Y_Motion <= Ball_Y_Step;
	  elsif(Ball_Y_Pos + Ball_Size <= BricksY(219 downto 209) + Brick_Height AND Ball_Y_Pos + Ball_Size >= BricksY(219 downto 209) AND Ball_X_Pos + Ball_Size >= BricksX(219 downto 209) AND Ball_X_Pos - Ball_Size <= BricksX(219 downto 209) + Brick_Width AND BricksOn(19) = '1')  then
		Ball_Y_Motion <= not(Ball_Y_Step) + '1';
      
      --end if;

-------Brick Interactions Below (X-axis change in ball movement)---------------	
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(10 downto 0) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(10 downto 0) AND Ball_Y_Pos + Ball_Size >= BricksY(10 downto 0) AND Ball_Y_Pos - Ball_Size <= BricksY(10 downto 0) + Brick_Height AND BricksOn(0) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(10 downto 0) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(10 downto 0) AND Ball_Y_Pos + Ball_Size >= BricksY(10 downto 0) AND Ball_Y_Pos - Ball_Size <= BricksY(10 downto 0) + Brick_Height AND BricksOn(0) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(21 downto 11) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(21 downto 11) AND Ball_Y_Pos + Ball_Size >= BricksY(21 downto 11) AND Ball_Y_Pos - Ball_Size <= BricksY(21 downto 11) + Brick_Height AND BricksOn(1) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(21 downto 11) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(21 downto 11) AND Ball_Y_Pos + Ball_Size >= BricksY(21 downto 11) AND Ball_Y_Pos - Ball_Size <= BricksY(21 downto 11) + Brick_Height AND BricksOn(1) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(32 downto 22) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(32 downto 22) AND Ball_Y_Pos + Ball_Size >= BricksY(32 downto 22) AND Ball_Y_Pos - Ball_Size <= BricksY(32 downto 22) + Brick_Height AND BricksOn(2) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(32 downto 22) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(32 downto 22) AND Ball_Y_Pos + Ball_Size >= BricksY(32 downto 22) AND Ball_Y_Pos - Ball_Size <= BricksY(32 downto 22) + Brick_Height AND BricksOn(2) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(43 downto 33) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(43 downto 33) AND Ball_Y_Pos + Ball_Size >= BricksY(43 downto 33) AND Ball_Y_Pos - Ball_Size <= BricksY(43 downto 33) + Brick_Height AND BricksOn(3) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(43 downto 33) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(43 downto 33) AND Ball_Y_Pos + Ball_Size >= BricksY(43 downto 33) AND Ball_Y_Pos - Ball_Size <= BricksY(43 downto 33) + Brick_Height AND BricksOn(3) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(54 downto 44) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(54 downto 44) AND Ball_Y_Pos + Ball_Size >= BricksY(54 downto 44) AND Ball_Y_Pos - Ball_Size <= BricksY(54 downto 44) + Brick_Height AND BricksOn(4) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(54 downto 44) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(54 downto 44) AND Ball_Y_Pos + Ball_Size >= BricksY(54 downto 44) AND Ball_Y_Pos - Ball_Size <= BricksY(54 downto 44) + Brick_Height AND BricksOn(4) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(65 downto 55) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(65 downto 55) AND Ball_Y_Pos + Ball_Size >= BricksY(65 downto 55) AND Ball_Y_Pos - Ball_Size <= BricksY(65 downto 55) + Brick_Height AND BricksOn(5) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(65 downto 55) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(65 downto 55) AND Ball_Y_Pos + Ball_Size >= BricksY(65 downto 55) AND Ball_Y_Pos - Ball_Size <= BricksY(65 downto 55) + Brick_Height AND BricksOn(5) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(76 downto 66) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(76 downto 66) AND Ball_Y_Pos + Ball_Size >= BricksY(76 downto 66) AND Ball_Y_Pos - Ball_Size <= BricksY(76 downto 66) + Brick_Height AND BricksOn(6) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(76 downto 66) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(76 downto 66) AND Ball_Y_Pos + Ball_Size >= BricksY(76 downto 66) AND Ball_Y_Pos - Ball_Size <= BricksY(76 downto 66) + Brick_Height AND BricksOn(6) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(87 downto 77) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(87 downto 77) AND Ball_Y_Pos + Ball_Size >= BricksY(87 downto 77) AND Ball_Y_Pos - Ball_Size <= BricksY(87 downto 77) + Brick_Height AND BricksOn(7) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(87 downto 77) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(87 downto 77) AND Ball_Y_Pos + Ball_Size >= BricksY(87 downto 77) AND Ball_Y_Pos - Ball_Size <= BricksY(87 downto 77) + Brick_Height AND BricksOn(7) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(98 downto 88) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(98 downto 88) AND Ball_Y_Pos + Ball_Size >= BricksY(98 downto 88) AND Ball_Y_Pos - Ball_Size <= BricksY(98 downto 88) + Brick_Height AND BricksOn(8) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(98 downto 88) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(98 downto 88) AND Ball_Y_Pos + Ball_Size >= BricksY(98 downto 88) AND Ball_Y_Pos - Ball_Size <= BricksY(98 downto 88) + Brick_Height AND BricksOn(8) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(109 downto 99) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(109 downto 99) AND Ball_Y_Pos + Ball_Size >= BricksY(109 downto 99) AND Ball_Y_Pos - Ball_Size <= BricksY(109 downto 99) + Brick_Height AND BricksOn(9) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(109 downto 99) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(109 downto 99) AND Ball_Y_Pos + Ball_Size >= BricksY(109 downto 99) AND Ball_Y_Pos - Ball_Size <= BricksY(109 downto 99) + Brick_Height AND BricksOn(9) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(120 downto 110) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(120 downto 110) AND Ball_Y_Pos + Ball_Size >= BricksY(120 downto 110) AND Ball_Y_Pos - Ball_Size <= BricksY(120 downto 110) + Brick_Height AND BricksOn(10) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(120 downto 110) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(120 downto 110) AND Ball_Y_Pos + Ball_Size >= BricksY(120 downto 110) AND Ball_Y_Pos - Ball_Size <= BricksY(120 downto 110) + Brick_Height AND BricksOn(10) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(131 downto 121) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(131 downto 121) AND Ball_Y_Pos + Ball_Size >= BricksY(131 downto 121) AND Ball_Y_Pos - Ball_Size <= BricksY(131 downto 121) + Brick_Height AND BricksOn(11) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(131 downto 121) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(131 downto 121) AND Ball_Y_Pos + Ball_Size >= BricksY(131 downto 121) AND Ball_Y_Pos - Ball_Size <= BricksY(131 downto 121) + Brick_Height AND BricksOn(11) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(142 downto 132) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(142 downto 132) AND Ball_Y_Pos + Ball_Size >= BricksY(142 downto 132) AND Ball_Y_Pos - Ball_Size <= BricksY(142 downto 132) + Brick_Height AND BricksOn(12) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(142 downto 132) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(142 downto 132) AND Ball_Y_Pos + Ball_Size >= BricksY(142 downto 132) AND Ball_Y_Pos - Ball_Size <= BricksY(142 downto 132) + Brick_Height AND BricksOn(12) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(153 downto 143) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(153 downto 143) AND Ball_Y_Pos + Ball_Size >= BricksY(153 downto 143) AND Ball_Y_Pos - Ball_Size <= BricksY(153 downto 143) + Brick_Height AND BricksOn(13) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(153 downto 143) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(153 downto 143) AND Ball_Y_Pos + Ball_Size >= BricksY(153 downto 143) AND Ball_Y_Pos - Ball_Size <= BricksY(153 downto 143) + Brick_Height AND BricksOn(13) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(164 downto 154) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(164 downto 154) AND Ball_Y_Pos + Ball_Size >= BricksY(164 downto 154) AND Ball_Y_Pos - Ball_Size <= BricksY(164 downto 154) + Brick_Height AND BricksOn(14) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(164 downto 154) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(164 downto 154) AND Ball_Y_Pos + Ball_Size >= BricksY(164 downto 154) AND Ball_Y_Pos - Ball_Size <= BricksY(164 downto 154) + Brick_Height AND BricksOn(14) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(175 downto 165) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(175 downto 165) AND Ball_Y_Pos + Ball_Size >= BricksY(175 downto 165) AND Ball_Y_Pos - Ball_Size <= BricksY(175 downto 165) + Brick_Height AND BricksOn(15) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(175 downto 165) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(175 downto 165) AND Ball_Y_Pos + Ball_Size >= BricksY(175 downto 165) AND Ball_Y_Pos - Ball_Size <= BricksY(175 downto 165) + Brick_Height AND BricksOn(15) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(186 downto 176) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(186 downto 176) AND Ball_Y_Pos + Ball_Size >= BricksY(186 downto 176) AND Ball_Y_Pos - Ball_Size <= BricksY(186 downto 176) + Brick_Height AND BricksOn(16) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(186 downto 176) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(186 downto 176) AND Ball_Y_Pos + Ball_Size >= BricksY(186 downto 176) AND Ball_Y_Pos - Ball_Size <= BricksY(186 downto 176) + Brick_Height AND BricksOn(16) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(197 downto 187) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(197 downto 187) AND Ball_Y_Pos + Ball_Size >= BricksY(197 downto 187) AND Ball_Y_Pos - Ball_Size <= BricksY(197 downto 187) + Brick_Height AND BricksOn(17) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(197 downto 187) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(197 downto 187) AND Ball_Y_Pos + Ball_Size >= BricksY(197 downto 187) AND Ball_Y_Pos - Ball_Size <= BricksY(197 downto 187) + Brick_Height AND BricksOn(17) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(208 downto 198) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(208 downto 198) AND Ball_Y_Pos + Ball_Size >= BricksY(208 downto 198) AND Ball_Y_Pos - Ball_Size <= BricksY(208 downto 198) + Brick_Height AND BricksOn(18) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(208 downto 198) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(208 downto 198) AND Ball_Y_Pos + Ball_Size >= BricksY(208 downto 198) AND Ball_Y_Pos - Ball_Size <= BricksY(208 downto 198) + Brick_Height AND BricksOn(18) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
	  elsif(Ball_X_Pos - Ball_Size <= BricksX(219 downto 209) + Brick_Width AND Ball_X_Pos - Ball_Size >= BricksX(219 downto 209) AND Ball_Y_Pos + Ball_Size >= BricksY(219 downto 209) AND Ball_Y_Pos - Ball_Size <= BricksY(219 downto 209) + Brick_Height AND BricksOn(19) = '1')  then
		Ball_X_Motion <= Ball_X_Motion;
	  elsif(Ball_X_Pos + Ball_Size <= BricksX(219 downto 209) + Brick_Width AND Ball_X_Pos + Ball_Size >= BricksX(219 downto 209) AND Ball_Y_Pos + Ball_Size >= BricksY(219 downto 209) AND Ball_Y_Pos - Ball_Size <= BricksY(219 downto 209) + Brick_Height AND BricksOn(19) = '1')  then
		Ball_X_Motion <= not(Ball_X_Step) + '1';
		
	
      end if;


    Ball_Y_pos <= Ball_Y_pos + Ball_Y_Motion; -- Update ball position 
	Ball_X_pos <= Ball_X_pos + Ball_X_Motion;

    end if;
  
  end process Move_Ball;

 
  BallX <= Ball_X_pos;
  BallY <= Ball_Y_pos;
  BallS <= Ball_Size;
  paddle_loss_status <= paddle_loss_statusSig;
 
end Behavioral;      