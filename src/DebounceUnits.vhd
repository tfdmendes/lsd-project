library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity DebounceUnits is
	port
	(
		clock : in std_logic;
		
		timer_up_key    : in  std_logic;
		timer_dw_key    : in  std_logic;
		temp_up_key     : in  std_logic;
        temp_dw_key   : in std_logic;
		
		timer_up_out    : out std_logic;
		timer_dw_out    : out std_logic;
		temp_up_out     : out std_logic;
        temp_dw_out   : out std_logic
	);
end DebounceUnits;

architecture Behavioral of DebounceUnits is
begin
	
	time_dw_debouncer   : entity work.Debouncer(Behavioral)
	port map
	(
		refClk    => clock,
		dirtyIn   => timer_up_key,
		pulsedOut => timer_up_out
	);
	
	time_dw_debouncer   : entity work.Debouncer(Behavioral)
	port map
	(
		refClk    => clock,
		dirtyIn   => timer_dw_key,
		pulsedOut => timer_dw_out
    );
	
	temp_up_debouncer   : entity work.Debouncer(Behavioral)
	port map
	(
		refClk    => clock,
		dirtyIn   => temp_up_key,
		pulsedOut => temp_up_out
	);

    temp_dw_debouncer   : entity work.Debouncer(Behavioral)
	port map
	(
		refClk    => clock,
		dirtyIn   => temp_dw_key,
		pulsedOut => temp_dw_out
	);
	
end Behavioral;