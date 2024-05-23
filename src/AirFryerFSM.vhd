library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity AirFryerFSM is
    Port (
        clk             : in std_logic;
		  clkEnable			: in std_logic;
		  
        reset           : in std_logic;
        run             : in std_logic;
        OPEN_OVEN       : in std_logic;
		  
		  
		  timePreHeat     : in std_logic_vector(5 downto 0);
		  timeCook			: in std_logic_vector(5 downto 0);
		  currentTime 		: in std_logic_vector(5 downto 0);
		  
	 	  program         : in std_logic_vector(2 downto 0);
		  
		  ledFoodIn       : out std_logic;
        ledStateIDLE    : out std_logic;
        ledStatePREHEAT : out std_logic;
        ledStateCOOK    : out std_logic;
        ledStateCOOL    : out std_logic;
		  ledStateFINISH  : out std_logic;
		  
		  timerEnable		: out std_logic);
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
    process(state, run, OPEN_OVEN, program)
    begin
        -- Default values for outputs
        ledStateIDLE    <= '0';
        ledStatePREHEAT <= '0';
		  ledStateCOOK    <= '0';
        ledStateCOOL    <= '0';
		  ledStateFINISH  <= '0';
		  ledFoodIn       <= '0';
		  timerEnable     <= '1'; 
        next_state      <= state;

        case state is
            when IDLE =>
                ledStateIDLE <= '1';
					 if program = "000" or timePreHeat /= "000000" then
						ledFoodIn <= '1';
						if OPEN_OVEN = '1' then
							s_foodIn <= '1';
						end if;
						if OPEN_OVEN = '0' and s_foodIn = '1' and run = '1' then
							next_state <= COOK;
						end if;
                elsif run = '1' then 
							s_foodIn <= '0';
							next_state <= PREHEAT;
					 end if;

					 
             when PREHEAT =>
					 if run = '0' then
						next_state <= IDLE;
					 else
						 ledStatePREHEAT <= '1';
						 if currentTime = timeCook then
							  s_foodIn <= '1';
							  ledFoodIn <= '1';
							  timerEnable <= '0';
						 end if;
						 if s_foodIn = '1' and OPEN_OVEN = '1' then
							  next_state <= COOK;
						 end if;
					 end if;

					 
            when COOK =>
					 if run = '0' then
						next_state <= IDLE;
					 else
						 ledStateCOOK <= '1';
						 if OPEN_OVEN = '0' then
							  timerEnable <= '1';
							  if currentTime = "000000" then
									next_state <= FINISH;
							  end if;
						 end if;
					 end if;
					 
				when FINISH =>
					 if run = '0' then
						next_state <= IDLE;
					 else
						 ledStateFINISH <= '1';
						 if OPEN_OVEN = '1' then
								next_state <= IDLE;
						 end if;
					 end if;

            when others =>
					 ledStateIDLE <= '1';
                next_state <= IDLE;
        end case;
    end process;

end Behavioral;