library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity AirFryerFSM is
    Port (
        clk             : in std_logic;
		  clkEnable			: in std_logic;
        reset           : in std_logic;
        run             : in std_logic;
        OPEN_OVEN       : in std_logic;
		  heatFinished    : in std_logic;
		  timeFinished    : in std_logic;
		  program         : in std_logic_vector(2 downto 0);
		  foodIn          : out std_logic;
        ledStateIDLE    : out std_logic;
        ledStatePREHEAT : out std_logic;
        ledStateCOOK    : out std_logic;
        ledStateCOOL    : out std_logic
    );
end AirFryerFSM;

architecture Behavioral of AirFryerFSM is
    type state_type is (IDLE, PREHEAT, COOK, FINISH, COOL);
    signal state, next_state: state_type;
	 signal s_foodIn         : std_logic := '0';

begin
    -- State Machine Process
    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
        elsif (rising_edge(clk)) then
            state <= next_state;
        end if;
    end process;

    -- Next State Logic
    process(state, run, OPEN_OVEN, program, heatFinished, timeFinished)
    begin
        -- Default values for outputs
        ledStateIDLE <= '0';
        ledStatePREHEAT <= '0';
		  ledStateCOOK <= '0';
        ledStateCOOL <= '0';
        next_state <= state;

        case state is
            when IDLE =>
                ledStateIDLE <= '1';
                if run = '1' then
						if program /= "000" then
							next_state <= PREHEAT;
						else
							next_state <= COOK;
						end if;
                end if;

             when PREHEAT =>
                ledStatePREHEAT <= '1';
                if heatFinished = '1' then
                    s_foodIn <= '1';
                end if;
                if s_foodIn = '1' and OPEN_OVEN = '1' then
                    next_state <= COOK;
                end if;

            when COOK =>
                ledStateCOOK <= '1';
                if OPEN_OVEN = '0' then
                    foodIn <= s_foodIn;
                    if timeFinished = '1' then
                        next_state <= IDLE;
                    end if;
                end if;

            when others =>
					 ledStateIDLE <= '1';
                next_state <= IDLE;
        end case;
    end process;

end Behavioral;