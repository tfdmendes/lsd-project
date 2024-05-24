library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity AirFryerFSM is
    Port (
        clk             : in std_logic;
        clkEnable       : in std_logic;
        reset           : in std_logic;
        run             : in std_logic;
        OPEN_OVEN       : in std_logic;
        fastCool        : in std_logic;
        timePreHeat     : in std_logic_vector(5 downto 0);
        timeCook        : in std_logic_vector(5 downto 0);
        currentTime     : in std_logic_vector(5 downto 0);
        currentTemp     : in std_logic_vector(7 downto 0);
        program         : in std_logic_vector(2 downto 0);
        ledFoodIn       : out std_logic; -- Liga quando pre-aquecimento e 0 
        ledFoodInside   : out std_logic;
        ledHalfTime     : out std_logic_vector(3 downto 0);
        ledStateIDLE    : out std_logic;
        ledStatePREHEAT : out std_logic;
        ledStateCOOK    : out std_logic;
        ledStateFINISH  : out std_logic;
        N               : out integer;
        coolingMode     : out std_logic;
        tempTimerEnable : out std_logic;
        timeTimerEnable : out std_logic
    );
end AirFryerFSM;

architecture Behavioral of AirFryerFSM is
    type state_type is (IDLE, PREHEAT, COOK, FINISH, COOL);
    signal state, next_state: state_type;
    signal s_foodIn         : std_logic := '0';
    signal s_blink          : std_logic;

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

    -- Blink Generator
    blinkGen : entity work.BlinkGen(Behavioral)
    generic map(NUMBER_STEPS => 25_000_000)
    port map(clk => clk, reset => reset, blink => s_blink);

    -- Next State Logic
    process(state, run, OPEN_OVEN, program, currentTime, currentTemp, fastCool)
    begin
        -- Default values for outputs
        ledFoodInside   <= '0';
        ledHalfTime     <= (others => '0');
        ledStateIDLE    <= '0';
        ledStatePREHEAT <= '0';
        ledStateCOOK    <= '0';
        ledStateFINISH  <= '0';
        ledFoodIn       <= '0';
        timeTimerEnable <= '1'; 
        tempTimerEnable <= '1';
        coolingMode     <= '0';
        N               <= 0;
        next_state      <= state;

        case state is
            when IDLE =>
                ledStateIDLE <= '1';
                if run = '1' then
                    if program /= "000" then
                        if timePreHeat /= "00000" then
                            next_state <= PREHEAT;
                        else
                            next_state <= COOK;
                        end if;
                    else
                        next_state <= COOK;
                    end if;
                end if;
                
            when PREHEAT =>
                if run = '0' then
                    next_state <= IDLE;
                else
                    ledStatePREHEAT <= '1';
                    if currentTime = timeCook then
                        s_foodIn <= '1';
                        ledFoodIn <= '1'; -- Pre Aquecimento a zero
                        timeTimerEnable <= '0';
                    end if;
                    if s_foodIn = '1' and OPEN_OVEN = '1' then
                        ledFoodInside <= s_foodIn;
                        next_state <= COOK;
                    end if;
                end if;
                
            when COOK =>
                if run = '0' then
                    next_state <= IDLE;
                else
                    ledStateCOOK <= '1';
                    if OPEN_OVEN = '0' then
                        timeTimerEnable <= '1';
                        -- Quando cook chegar a metade, LEDs piscam
                        if ((unsigned(currentTime)) = (unsigned(timeCook) / 2)) then
                            ledHalfTime <= (others => s_blink);
                        end if;
                        -- Quando o tempo chegar ao FIM
                        if currentTime = "000000" then
                            next_state <= FINISH;
                        end if;
                    end if;
                end if;
                
            when FINISH =>
                ledStateFINISH <= '1';
					 coolingMode <= '1';
                if run = '0' and OPEN_OVEN = '1' then
                    next_state <= COOL;
                end if;
                
            when COOL =>
                ledStateIDLE <= '1';
                coolingMode <= '1'; 
                if fastCool = '1' then
                    N <= 40; -- Fast cooling mode
                else
                    N <= 20; -- Normal cooling mode
                end if;
                if unsigned(currentTemp) = 20 then
                    next_state <= IDLE;
                end if;
                
            when others =>
                ledStateIDLE <= '1';
                next_state <= IDLE;
                
        end case;
    end process;
end Behavioral;
