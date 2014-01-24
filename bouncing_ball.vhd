---------------------------------------------------------------------------
--      BouncingBall.vhd                                                 --
--                                                                       --
--   Modeled off bouncing_ball.vhd by Stephen Kempf and Viral Mehta      --
--																		 --
--	  by Raj Vinjamuri and Sai Koppula                                   --
--	  Final Modifications by Raj Vinjamuri and Sai Koppula			     --
---------------------------------------------------------------------------
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Body_mapper is
    Port ( 	Up, Do, Le, Ri : in std_logic;				--input signals used by ball for movement
            Clk : in std_logic;
			Reset : in std_logic;
			Start : in std_logic;
			Seed : in std_logic_vector(17 downto 0);
			ResScore : in std_logic;
			Red   : out std_logic_vector(9 downto 0);
			Green : out std_logic_vector(9 downto 0);
			Blue  : out std_logic_vector(9 downto 0);
			VGA_clk : out std_logic; 
			sync : out std_logic;
			blank : out std_logic;
			vs : out std_logic;
			hs : out std_logic;
			game_statusOut : out std_logic_vector(3 downto 0);
			scoreOutH, scoreOutL : out std_logic_vector(3 downto 0));
end Body_mapper;

architecture Behavioral of Body_mapper is

-----------------------------------------------------
component game_handler is
    Port (  frame_clk : in std_logic;
            paddle_loss_statusIn : in std_logic_vector(1 downto 0);
            win_statusIn, ResetIn, ResetScore : in std_logic;
            brick_hitIn : in std_logic_vector(19 downto 0);
            score: out std_logic_vector(7 downto 0);
            game_status : out std_logic_vector(3 downto 0));
end component;

-----------------------------------------------------
component ball is
    Port ( --Up, Do : in std_logic;
		   Le, Ri : in std_logic;
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
end component;

-----------------------------------------------------
component paddle is
    Port ( Up, Do, Le, Ri : in std_logic;			--where those movement signals go, yo :)
           Reset : in std_logic;
           frame_clk : in std_logic;
           PaddleX : out std_logic_vector(10 downto 0);
           PaddleY : out std_logic_vector(10 downto 0);
           PaddleS : out std_logic_vector(10 downto 0));
end component;

-----------------------------------------------------
component vga_controller is
    Port ( clk : in std_logic;
           reset : in std_logic;
           hs : out std_logic;
           vs : out std_logic;
           pixel_clk : out std_logic;
           blank : out std_logic;
           sync : out std_logic;
           DrawX : out std_logic_vector(10 downto 0);
           DrawY : out std_logic_vector(10 downto 0));
end component;

-----------------------------------------------------
component Color_Mapper is
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
end component;

-----------------------------------------------------
component Brick is
   Port ( 	clk, Reset, frame_clk : in std_logic;
			BallX, BallY, BallS : in std_logic_vector(10 downto 0);
			BrickXIn, BrickYIn : in std_logic_vector(10 downto 0);
			--BrickX, BrickY: out std_logic_vector(10 downto 0);
			brick_hit: out std_logic;
			BrickOn: out std_logic);
end component;
-----------------------------------------------------
-----------------------------------------------------

signal Reset_h, vsSig, StartSig, win_statusSig : std_logic;
signal BallXSig, BallYSig, BallSSig, PaddleXSig, PaddleYSig, PaddleSSig : std_logic_vector(10 downto 0);
signal DrawXSig, DrawYSig : std_logic_vector(10 downto 0);
signal statusSig : std_logic_vector(3 downto 0);
signal BricksXsig, BricksYsig : std_logic_vector(219 downto 0);
signal BricksOn, brick_hitSig : std_logic_vector(19 downto 0) ; 
signal paddle_loss_statusSig : std_logic_vector(1 downto 0);
signal scoreOutSig : std_logic_vector (7 downto 0);

begin

Reset_h <= Reset; -- The push buttons are active low
StartSig <= Start;

find_win: process(BricksOn)
begin
	win_statusSig <= '0';

	if (BricksOn = "00000000000000000000") then
		win_statusSig <= '1';
	end if;
end process;


----------------Brick 0----------------------------------------
BricksXsig(10 downto 0) <= CONV_STD_LOGIC_VECTOR(90, 11);
BricksYsig(10 downto 0) <= CONV_STD_LOGIC_VECTOR(20, 11);
----------------Brick 1----------------------------------------
BricksXsig(21 downto 11) <= CONV_STD_LOGIC_VECTOR(190, 11);
BricksYsig(21 downto 11) <= CONV_STD_LOGIC_VECTOR(20, 11);
----------------Brick 2----------------------------------------
BricksXsig(32 downto 22) <= CONV_STD_LOGIC_VECTOR(290, 11);
BricksYsig(32 downto 22) <= CONV_STD_LOGIC_VECTOR(20, 11);
----------------Brick 3----------------------------------------
BricksXsig(43 downto 33) <= CONV_STD_LOGIC_VECTOR(390, 11);
BricksYsig(43 downto 33) <= CONV_STD_LOGIC_VECTOR(20, 11);
----------------Brick 4----------------------------------------
BricksXsig(54 downto 44) <= CONV_STD_LOGIC_VECTOR(490, 11);
BricksYsig(54 downto 44) <= CONV_STD_LOGIC_VECTOR(20, 11);
----------------Brick 5----------------------------------------
BricksXsig(65 downto 55) <= CONV_STD_LOGIC_VECTOR(90, 11);
BricksYsig(65 downto 55) <= CONV_STD_LOGIC_VECTOR(70, 11);
----------------Brick 6----------------------------------------
BricksXsig(76 downto 66) <= CONV_STD_LOGIC_VECTOR(190, 11);
BricksYsig(76 downto 66) <= CONV_STD_LOGIC_VECTOR(70, 11);
----------------Brick 7----------------------------------------
BricksXsig(87 downto 77) <= CONV_STD_LOGIC_VECTOR(290, 11);
BricksYsig(87 downto 77) <= CONV_STD_LOGIC_VECTOR(70, 11);
----------------Brick 8----------------------------------------
BricksXsig(98 downto 88) <= CONV_STD_LOGIC_VECTOR(390, 11);
BricksYsig(98 downto 88) <= CONV_STD_LOGIC_VECTOR(70, 11);
----------------Brick 9----------------------------------------
BricksXsig(109 downto 99) <= CONV_STD_LOGIC_VECTOR(490, 11);
BricksYsig(109 downto 99) <= CONV_STD_LOGIC_VECTOR(70, 11);
----------------Brick 10---------------------------------------
BricksXsig(120 downto 110) <= CONV_STD_LOGIC_VECTOR(90, 11);
BricksYsig(120 downto 110) <= CONV_STD_LOGIC_VECTOR(120, 11);
----------------Brick 11---------------------------------------
BricksXsig(131 downto 121) <= CONV_STD_LOGIC_VECTOR(190, 11);
BricksYsig(131 downto 121) <= CONV_STD_LOGIC_VECTOR(120, 11);
----------------Brick 12---------------------------------------
BricksXsig(142 downto 132) <= CONV_STD_LOGIC_VECTOR(290, 11);
BricksYsig(142 downto 132) <= CONV_STD_LOGIC_VECTOR(120, 11);
----------------Brick 13---------------------------------------
BricksXsig(153 downto 143) <= CONV_STD_LOGIC_VECTOR(390, 11);
BricksYsig(153 downto 143) <= CONV_STD_LOGIC_VECTOR(120, 11);
----------------Brick 14---------------------------------------
BricksXsig(164 downto 154) <= CONV_STD_LOGIC_VECTOR(490, 11);
BricksYsig(164 downto 154) <= CONV_STD_LOGIC_VECTOR(120, 11);
----------------Brick 15---------------------------------------
BricksXsig(175 downto 165) <= CONV_STD_LOGIC_VECTOR(90, 11);
BricksYsig(175 downto 165) <= CONV_STD_LOGIC_VECTOR(170, 11);
----------------Brick 16---------------------------------------
BricksXsig(186 downto 176) <= CONV_STD_LOGIC_VECTOR(190, 11);
BricksYsig(186 downto 176) <= CONV_STD_LOGIC_VECTOR(170, 11);
----------------Brick 17---------------------------------------
BricksXsig(197 downto 187) <= CONV_STD_LOGIC_VECTOR(290, 11);
BricksYsig(197 downto 187) <= CONV_STD_LOGIC_VECTOR(170, 11);
----------------Brick 18---------------------------------------
BricksXsig(208 downto 198) <= CONV_STD_LOGIC_VECTOR(390, 11);
BricksYsig(208 downto 198) <= CONV_STD_LOGIC_VECTOR(170, 11);
----------------Brick 19---------------------------------------
BricksXsig(219 downto 209) <= CONV_STD_LOGIC_VECTOR(490, 11);
BricksYsig(219 downto 209) <= CONV_STD_LOGIC_VECTOR(170, 11);
----------------End of Bricks----------------------------------
--Brick1Xsig <= CONV_STD_LOGIC_VECTOR(0, 11);
--Brick1Ysig <= CONV_STD_LOGIC_VECTOR(0, 11);


-----------------------------------------------------
game_handler_instance : game_handler
   Port map(frame_clk => vsSig,
            paddle_loss_statusIn => paddle_loss_statusSig,
            brick_hitIn => brick_hitSig,
            win_statusIn => win_statusSig,
            ResetIn => Reset_h,
            ResetScore => ResScore,
            game_status => statusSig,
            score => scoreOutSig);
            
-----------------------------------------------------
vgaSync_instance : vga_controller
   Port map(clk => clk,
            reset => Reset_h,
            hs => hs,
            vs => vsSig,
            pixel_clk => VGA_clk,
            blank => blank,
            sync => sync,
            DrawX => DrawXSig,
            DrawY => DrawYSig);

-----------------------------------------------------
ball_instance : ball
   Port map(Le => Le,
            Ri => Ri,
            clk => clk,
            paddle_loss_status => paddle_loss_statusSig,
            Reset => Reset_h,
            frame_clk => vsSig, -- Vertical Sync used as an "ad hoc" 60 Hz clock signal
            StartMove => StartSig,
            seedIn => Seed,
            BallX => BallXSig,  --   (This is why we registered it in the vga controller!)
            BallY => BallYSig,
            BallS => BallSSig,
            BricksX => BricksXSig,
            BricksY => BricksYSig,
            BricksOn => BricksOn,
            PaddleX => PaddleXSig,
            PaddleY => PaddleYSig,
            PaddleS => PaddleSSig);

-----------------------------------------------------
paddle_instance : paddle
   Port map(Up => Up,			--connecting the signals like magic
            Do => Do,
            Le => Le,
            Ri => Ri,
            Reset => Reset_h,
            frame_clk => vsSig, 	-- Vertical Sync used as an "ad hoc" 60 Hz clock signal
            PaddleX => PaddleXSig,  --   (This is why we registered it in the vga controller!)
            PaddleY => PaddleYSig,
            PaddleS => PaddleSSig);
            
-----------------------------------------------------
Color_instance : Color_Mapper
   Port Map(game_status => statusSig,
            BallX => BallXSig,
            BallY => BallYSig,
            PaddleX => PaddleXSig,
            PaddleY => PaddleYSig,
			BricksX => BricksXSig,
			BricksY => BricksYSig,
			BricksOn => BricksOn,
            DrawX => DrawXSig,
            DrawY => DrawYSig,
            Ball_size => BallSSig,
            Paddle_size => PaddleSSig,
            Red => Red,
            Green => Green,
            Blue => Blue);
            
------------------Start Bricks-----------------------
-----------------------------------------------------
Brick0 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(10 downto 0),
			BrickYIn => BricksYSig(10 downto 0),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(0),
			BrickOn => BricksOn(0) );	
-----------------------------------------------------
Brick1 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(21 downto 11),
			BrickYIn => BricksYSig(21 downto 11),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(1),
			BrickOn => BricksOn(1) );	
-----------------------------------------------------
Brick2 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(32 downto 22),
			BrickYIn => BricksYSig(32 downto 22),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(2),
			BrickOn => BricksOn(2) );	
-----------------------------------------------------
Brick3 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(43 downto 33),
			BrickYIn => BricksYSig(43 downto 33),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(3),
			BrickOn => BricksOn(3) );
-----------------------------------------------------
Brick4 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(54 downto 44),
			BrickYIn => BricksYSig(54 downto 44),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(4),
			BrickOn => BricksOn(4) );	
-----------------------------------------------------
Brick5 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(65 downto 55),
			BrickYIn => BricksYSig(65 downto 55),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(5),
			BrickOn => BricksOn(5) );	
-----------------------------------------------------
Brick6 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(76 downto 66),
			BrickYIn => BricksYSig(76 downto 66),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(6),
			BrickOn => BricksOn(6) );	
-----------------------------------------------------
Brick7 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(87 downto 77),
			BrickYIn => BricksYSig(87 downto 77),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(7),
			BrickOn => BricksOn(7) );
-----------------------------------------------------
Brick8 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(98 downto 88),
			BrickYIn => BricksYSig(98 downto 88),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(8),
			BrickOn => BricksOn(8) );	
-----------------------------------------------------
Brick9 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(109 downto 99),
			BrickYIn => BricksYSig(109 downto 99),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(9),
			BrickOn => BricksOn(9) );	
-----------------------------------------------------
Brick10 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(120 downto 110),
			BrickYIn => BricksYSig(120 downto 110),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(10),
			BrickOn => BricksOn(10) );	
-----------------------------------------------------
Brick11 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(131 downto 121),
			BrickYIn => BricksYSig(131 downto 121),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(11),
			BrickOn => BricksOn(11) );
-----------------------------------------------------
Brick12 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(142 downto 132),
			BrickYIn => BricksYSig(142 downto 132),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(12),
			BrickOn => BricksOn(12) );	
-----------------------------------------------------
Brick13 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(153 downto 143),
			BrickYIn => BricksYSig(153 downto 143),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(13),
			BrickOn => BricksOn(13) );	
-----------------------------------------------------
Brick14 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(164 downto 154),
			BrickYIn => BricksYSig(164 downto 154),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(14),
			BrickOn => BricksOn(14) );	
-----------------------------------------------------
Brick15 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(175 downto 165),
			BrickYIn => BricksYSig(175 downto 165),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(15),
			BrickOn => BricksOn(15) );
-----------------------------------------------------
Brick16 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(186 downto 176),
			BrickYIn => BricksYSig(186 downto 176),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(16),
			BrickOn => BricksOn(16) );	
-----------------------------------------------------
Brick17 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(197 downto 187),
			BrickYIn => BricksYSig(197 downto 187),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(17),
			BrickOn => BricksOn(17) );	
-----------------------------------------------------
Brick18 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(208 downto 198),
			BrickYIn => BricksYSig(208 downto 198),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(18),
			BrickOn => BricksOn(18) );					
-----------------------------------------------------
Brick19 : Brick
   Port Map(
			clk => clk,
			Reset => Reset_h,
			frame_clk => vsSig,
			BallX => BallXSig,
            BallY => BallYSig,
            BallS => BallSSig,
			BrickXIn => BricksXSig(219 downto 209),
			BrickYIn => BricksYSig(219 downto 209),
			--BrickX => BricksXSig(10 downto 0),
			--BrickY => BricksYSig(10 downto 0),
			brick_hit => brick_hitSig(19),
			BrickOn => BricksOn(19) );		
-----------------------------------------------------
vs <= vsSig;
game_statusOut <= statusSig;
scoreOutH <= scoreOutSig(7 downto 4);
scoreOutL <= scoreOutSig(3 downto 0);

end Behavioral;