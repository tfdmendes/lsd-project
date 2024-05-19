library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity AirFryer is

    -- ON_OFF: SW(0)
    -- RUN: SW(1)
    -- OPEN_OVEN: SW(2)
    -- PROGRAMS: SW(4,5,6)
	 -- FAST_COOL: SW(7).
	 -- SELECIONAR COOK OU HEAT: SW(8)
    -- TimerUp: Key(0)
    -- TimerDw: Key(1)
    -- TempUp: Key(2)
    -- TemUp: Key(3)
    -- FOOD_IN: LEDG(0)
    -- HALFTIME: LEDG(7...4)
    -- STATUS: LEDR(0,1,2,): IDLE, PreHEAT, COOK, FINISH, COOL
	 -- MODO SELECIONADO: LEDR(8)
    -- Temperature Display: HEX0, HEX1 e HEX2 (código BCD)
    -- Time Display: HEX4 e HEX5 (código BCD)
    -- RefClock: CLOCK_50
	port(CLOCK_50    : in  std_logic;
            KEY      : in  std_logic_vector(3 downto 0); 
            SW       : in  std_logic_vector(8 downto 0);
            
            LEDR     : out std_logic_vector(8 downto 0); 
            LEDG     : out std_logic_vector(7 downto 0);
            
            HEX0     : out std_logic_vector(6 downto 0);
            HEX1     : out std_logic_vector(6 downto 0);
            HEX2     : out std_logic_vector(6 downto 0);
            HEX4     : out std_logic_vector(6 downto 0);
		    HEX5     : out std_logic_vector(6 downto 0));
end AirFryer;

architecture Demo of AirFryer is 

        signal s_timeUp, s_timeDown, s_tempUp, s_tempDown  : std_logic;
        signal s_temp_Uni, s_temp_Doz, s_temp_Cen          : std_logic_vector(3 downto 0);
		  signal s_time_Uni, s_time_Doz							  : std_logic_vector(3 downto 0);

begin 
    -- Debouncer for all keys
    keys_debounce   : entity work.DebounceUnits(Behavioral)
    port map(clock          => CLOCK_50,
            timer_up_key    => KEY(0),
            timer_dw_key    => KEY(1),
            temp_up_key     => KEY(2),
            temp_dw_key     => KEY(3),
            timer_up_out    => s_timeUp,
            timer_dw_out    => s_timeDown,
            temp_up_out     => s_tempUp,
            temp_dw_out     => s_tempDown);
				
				
	 -- TEMPERATURA
    TemperatureController : entity work.TemperatureController(Behavioral)
    port map(clk            => CLOCK_50,
             startingTemp    => "01100100", -- temperatura do programa selecionado
             estado         => '0',    -- estar aberto ou fechado (a cuba)
             program       => "001",
             tempUp         => s_tempUp,
             tempDown       => s_tempDown,
             enable         => SW(0),
             run        	 => SW(1),
             tempUnits   => s_temp_Uni,
             tempDozens    => s_temp_Doz,
             tempHundreds   => s_temp_Cen);
				 
				 
				 
	-- TEMPO
	 TimeController : entity work.TimeController(Behavioral)
    port map(clk            => CLOCK_50,
				 timeHeat		 => "00000", -- MUDAR
				 timeCook		 => "00000", -- MUDAR
				 
             estado         => '0',    -- estar aberto ou fechado (a cuba)
             program       => "001",
             fastCooler  => SW(7),
				 heatOrCook		=> SW(8),
             timeUp         => s_timeUp,
             timeDown       => s_timeDown,
             enable         => SW(0),
             run        	 => SW(1),
             timeUnits   	=> s_time_Uni,
             timeDozens    => s_time_Doz,
				 ledSignal		=> LEDR(8));

				 
    DisplaysController : entity work.DisplaysController(Behavioral)
    port map(enable 			  => SW(0),
	          tempUnits       => s_temp_Uni,
             tempDozens      => s_temp_Doz,
             tempHundreds    => s_temp_Cen,
				 
				 timeUnits			=> s_time_Uni,
				 timeDozens			=> s_time_Doz,
            
             s_HEX0          => HEX0,
             s_HEX1          => HEX1,
             s_HEX2          => HEX2,
             s_HEX4          => HEX4,
             s_HEX5          => HEX5);

end Demo;