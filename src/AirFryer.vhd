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
	port(CLOCK_50    	: in  std_logic;
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
		  signal s_1Hz													  : std_logic;
		  signal s_timeCook, s_timeHeat				  			  : std_logic_vector(4 downto 0);
		  signal s_temp											     : std_logic_vector(7 downto 0);
		  signal s_programChosen									  : std_logic_vector(2 downto 0);

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
				
				
	 -- CLOCK DIVIDER
	 clkDivider : entity work.ClkDividerN(Behavioral)
    generic map (divFactor => 50_000_000)
    port map (clkIn 			=> CLOCK_50,
              clkOut 		=> s_1Hz);
				  
				  
	 -- PROGRAM SELECTOR
	 progamSelector : entity work.ProgramSelector(Behavioral)
	 port map(clk				=> CLOCK_50,
				 input			=> SW(6 downto 4),
				  ps_temp 		=> s_temp,
				  ps_timeCook 	=> s_timeCook,
				  ps_timeHeat 	=> s_timeHeat,
				  ps_programChosen => s_programChosen);
				
				
	 -- TEMPERATURA
    TemperatureController : entity work.TemperatureController(Behavioral)
    port map(clk            => CLOCK_50,
             startingTemp   => s_temp, -- temperatura do programa selecionado
             enable         => SW(0),
             run        	 => SW(1),
             estado         => SW(2),    	 -- estar aberto ou fechado (a cuba)
				 fastCooler		 => SW(7),
             program        => s_programChosen,
             tempUp         => s_tempUp,
             tempDown       => s_tempDown,
             tempUnits      => s_temp_Uni,
             tempDozens     => s_temp_Doz,
             tempHundreds   => s_temp_Cen);
				 
				 
	-- TEMPO
	 TimeController : entity work.TimeController(Behavioral)
    port map(clk            => CLOCK_50,
				 timeHeat		 => s_timeHeat,
				 timeCook		 => s_timeCook, 
				 
             estado         => '0',    -- estar aberto ou fechado (a cuba)
             program        => s_programChosen,
				 heatOrCook		 => SW(8),
             timeUp         => s_timeUp,
             timeDown       => s_timeDown,
             enable         => SW(0),
             run        	 => SW(1),
             timeUnits   	 => s_time_Uni,
             timeDozens     => s_time_Doz,
				 ledSignal		 => LEDR(8));

	 -- DISPLAYS CONTROLLER
    DisplaysController : entity work.DisplaysController(Behavioral)
    port map(enable 			 => SW(0),
	          tempUnits      => s_temp_Uni,
             tempDozens     => s_temp_Doz,
             tempHundreds   => s_temp_Cen,
				 
				 timeUnits		 => s_time_Uni,
				 timeDozens		 => s_time_Doz,
            
             s_HEX0         => HEX0,
             s_HEX1         => HEX1,
             s_HEX2         => HEX2,
             s_HEX4         => HEX4,
             s_HEX5         => HEX5);

end Demo;