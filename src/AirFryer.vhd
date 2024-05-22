library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity AirFryer is 
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
		  signal s_timeCook, s_timeHeat, s_timeNow			  : std_logic_vector(4 downto 0);
		  signal s_temp, s_tempNow									  : std_logic_vector(7 downto 0);
		  signal s_programChosen									  : std_logic_vector(2 downto 0);
		  signal s_heatFinished, s_timeFinished ,s_foodIn	  : std_logic;
		  signal sw1_ff_out, sw0_ff_out, sw2_ff_out, sw7_ff_out : std_logic;
		  signal sw8_ff_out												: std_logic;

begin 
	process(CLOCK_50)
	begin
		if rising_edge(CLOCK_50) then
			sw0_ff_out <= SW(0);
			sw1_ff_out <= SW(1);
			sw2_ff_out <= SW(2);
			sw7_ff_out <= SW(7);
			sw8_ff_out <= SW(8);
		end if;
	end process;
	
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
				
	-- Pulse Generator
	 pulseGen : entity work.PulseGen
    generic map (MAX => 50_000_000)
    port map (clk => CLOCK_50,
            reset => not sw1_ff_out,
            pulse => s_1Hz);
					
				
				  
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
				clkEnable		 => s_1Hz,
             startingTemp   => s_temp, -- temperatura do programa selecionado
             enable         => sw0_ff_out,
             run        	 => sw1_ff_out,
             estado         => sw2_ff_out,    	 -- estar aberto ou fechado (a cuba)
				 fastCooler		 => sw7_ff_out,
             program        => s_programChosen,
             tempUp         => s_tempUp,
             tempDown       => s_tempDown,
             tempUnits      => s_temp_Uni,
             tempDozens     => s_temp_Doz,
             tempHundreds   => s_temp_Cen);
				 
				 
	-- TEMPO
	 TimeController : entity work.TimeController(Behavioral)
    port map(clk            => CLOCK_50,
				 clkEnable		 => s_1Hz,
				 timeHeat		 => s_timeHeat,
				 timeCook		 => s_timeCook, 
             estado         => sw2_ff_out,    -- estar aberto ou fechado (a cuba)
             program        => s_programChosen,
				 heatOrCook		 => sw8_ff_out,
             timeUp         => s_timeUp,
             timeDown       => s_timeDown,
             enable         => sw0_ff_out,
             run        	 => sw1_ff_out,
             timeUnits   	 => s_time_Uni,
             timeDozens     => s_time_Doz,
				 ledSignal		 => LEDR(8));
				 
	 -- DISPLAYS CONTROLLER
    DisplaysController : entity work.DisplaysController(Behavioral)
    port map(enable 			 => sw0_ff_out,
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
				 
	-- FSM
	AirFryerFSM : entity work.AirFryerFSM(Behavioral)
	port map(
        clk             => CLOCK_50,
		  clkEnable			=> s_1Hz,
        reset           => not sw0_ff_out,
        run             => sw1_ff_out,
        OPEN_OVEN       => sw2_ff_out,
		  heatFinished    => s_heatFinished,
		  timeFinished    => s_timeFinished,
		  program         => s_programChosen,
		  foodIn          => s_foodIn,
        ledStateIDLE    => LEDG(3),
        ledStatePREHEAT => LEDG(2),
        ledStateCOOK    => LEDG(1),
        ledStateCOOL    => LEDG(0)
    );

end Demo;