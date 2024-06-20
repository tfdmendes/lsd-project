library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity AirFryerFSM is
  port
  (
    enable      : in std_logic;
    clk         : in std_logic;
    clkEnable   : in std_logic;
    reset       : in std_logic;
    run         : in std_logic;
    OPEN_OVEN   : in std_logic;
    timePreHeat : in std_logic_vector(5 downto 0);
    timeCook    : in std_logic_vector(5 downto 0);
    currentTime : in std_logic_vector(5 downto 0);
    currentTemp : in std_logic_vector(7 downto 0);

    ledFoodIn       : out std_logic; -- Liga quando pre-aquecimento e 0 
    ledHalfTime     : out std_logic_vector(3 downto 0);
    ledStateIDLE    : out std_logic;
    ledStatePREHEAT : out std_logic;
    ledStateCOOK    : out std_logic;
    ledStateFINISH  : out std_logic;

    finished        : out std_logic;
    coolingMode     : out std_logic;
    tempTimerEnable : out std_logic;
    timeTimerEnable : out std_logic);
end AirFryerFSM;

architecture Behavioral of AirFryerFSM is
  type state_type is (IDLE, PREHEAT, COOK, FINISH, COOL);
  signal state, next_state : state_type;
  signal s_blink           : std_logic;

begin
  -- State Machine Process
  process (clk, reset)
  begin
    if reset = '1' then
      state <= IDLE;
    elsif (rising_edge(clk)) then
      state <= next_state;
    end if;
  end process;

  -- Blink Generator
  blinkGen : entity work.BlinkGen(Behavioral)
    generic
    map(NUMBER_STEPS => 25_000_000)
    port map
    (
      clk   => clk,
      reset => reset,
      blink => s_blink);
  blink => s_blink);

  process (enable, state, run, OPEN_OVEN, currentTime, currentTemp)
  begin
    -- Default values for outputs
    ledHalfTime     <= (others => '0');
    ledStateIDLE    <= '0';
    ledStatePREHEAT <= '0';
    ledStateCOOK    <= '0';
    ledStateFINISH  <= '0';
    ledFoodIn       <= '0';
    timeTimerEnable <= '1';
    tempTimerEnable <= '1';
    coolingMode     <= '0';
    finished        <= '0';
    next_state      <= state;

    if enable = '1' then
      case state is
        when IDLE =>
          ledStateIDLE <= '1';
          if timePreHeat = "000000" then
            timeTimerEnable <= '0';
            tempTimerEnable <= '0';
            if run = '1' then
              ledFoodIn <= '1';
              if OPEN_OVEN = '1' then
                next_state <= COOK;
              end if;
            else
              ledFoodIn <= '0';
            end if;
          elsif timePreHeat /= "000000" then
            ledFoodIn <= '0';
            if run = '1' then
              next_state <= PREHEAT;
            end if;
          end if;

        when PREHEAT =>
          ledStatePREHEAT <= '1';
          if run = '0' then
            finished <= '1';
            if OPEN_OVEN = '1' then
              next_state <= COOL;
            end if;
          else
            if currentTime = timeCook then
              ledFoodIn       <= '1'; -- Pre Aquecimento a zero
              timeTimerEnable <= '0';
            end if;
            if OPEN_OVEN = '1' then
              next_state <= COOK;
            end if;
          end if;

        when COOK =>
          ledStateCOOK <= '1';
          if run = '0' then
            finished <= '1';
            if OPEN_OVEN = '1' then
              next_state <= COOL;
            end if;
          else
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

        when FINISH               =>
          ledHalfTime    <= (others => '1');
          ledStateFINISH <= '1';
          finished       <= '1';
          if run = '0' and OPEN_OVEN = '1' then
            next_state <= COOL;
          end if;

        when COOL =>
          ledStateIDLE <= '1';
          coolingMode  <= '1';
          if (unsigned(currentTemp) = 20) and (OPEN_OVEN = '0') then
            next_state <= IDLE;
          end if;

        when others =>
          ledStateIDLE <= '1';
          next_state   <= IDLE;

      end case;
    end if;
  end process;