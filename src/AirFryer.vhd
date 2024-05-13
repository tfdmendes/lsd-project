library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity AirFryer is

    -- ON_OFF: SW(0)
    -- RUN: SW(1)
    -- OPEN_OVEN: SW(2)
    -- PROGRAMS: SW(4,5,6)
    -- TimerUp: Key(0)
    -- TimerDw: Key(1)
    -- TempUp: Key(2)
    -- TemUp: Key(3)
    -- FOOD_IN: LEDG(0)
    -- HALFTIME: LEDG(7...4)
    -- FAST_COOL: SW(7).
    -- STATUS: LEDR(0,1,2,): IDLE, PreHEAT, COOK, FINISH, COOL
    -- Temperature Display: HEX0, HEX1 e HEX2 (código BCD)
    -- Time Display: HEX4 e HEX5 (código BCD)
    -- RefClock: CLOCK_50
	port
    (
		CLOCK_50 : in  std_logic;
		KEY      : in  std_logic_vector(3 downto 0); 
		SW       : in  std_logic_vector(7 downto 0);
		
		LEDR     : out std_logic_vector(2 downto 0); 
		LEDG     : out std_logic_vector(7 downto 0);
		
		HEX0     : out std_logic_vector(6 downto 0);
		HEX1     : out std_logic_vector(6 downto 0);
		HEX2     : out std_logic_vector(6 downto 0);
		HEX4     : out std_logic_vector(6 downto 0);
		HEX5     : out std_logic_vector(6 downto 0)
	);
end AirFryer;

architecture Demo of AirFryer is 

        signal s_timeUp, s_timeDown, s_tempUp, s_tempDown  : std_logic;

begin 
    -- Debouncer for all keys
    keys_debounce   : entity work.DebounceUnits(Behavioral)
    port map
    (
        clock           => CLOCK_50,
        timer_up_key    => KEY(0),
        timer_dw_key    => KEY(1),
        temp_up_key     => KEY(2),
        temp_dw_key     => KEY(3),

        timer_up_out    => s_timeUp,
        timer_dw_out    => s_timeDown,
        temp_up_out     => s_tempUp,
        temp_dw_out     => s_timeDown
    );

