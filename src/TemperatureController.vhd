library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TemperatureController is
    port(
        clk          : in std_logic;
        clkEnable    : in std_logic;
        timerEnable  : in std_logic;
                
        startingTemp : in std_logic_vector(7 downto 0); -- temperatura do programa selecionado
        enable       : in std_logic;
        run          : in std_logic; -- se está a trabalhar
        estado       : in std_logic; -- estar aberto ou fechado (a cuba)
        fastCool     : in std_logic;
        coolingMode  : in std_logic;
        finished     : in std_logic;
                
        program      : in std_logic_vector(2 downto 0);
        tempUp       : in std_logic;
        tempDown     : in std_logic;
        
        currentTemp  : out std_logic_vector(7 downto 0);
        tempUnits    : out std_logic_vector(3 downto 0);
        tempDozens   : out std_logic_vector(3 downto 0);
        tempHundreds : out std_logic_vector(3 downto 0));
end TemperatureController;

architecture Behavioral of TemperatureController is
    signal tempMin         : natural := 20;
    signal tempMax         : natural := 250;
    signal tempInitialized : std_logic := '0';
    signal tempRun         : std_logic := '0';
    signal one_sec_pulse   : std_logic := '0';
    signal countUpDown     : std_logic; -- increment/decrement
    signal enableCounter   : std_logic; 
    signal initCount       : std_logic; -- Signal to initialize the counter
    signal countInitValue  : natural;   -- Value to initialize the counter as
    signal internalCount   : natural;   -- Internal count signal
    signal userDefinedTemp : natural := 200; 
    
    signal maxValue        : natural;

    signal s_INCREMENT_STEP : integer := 10;
    signal s_DECREMENT_STEP : integer := 10;

begin
    -- TIMER
    timer : entity work.TimerN(Behavioral)
    port map(
        clk         => clk,
        clkEnable   => clkEnable,
        reset       => not enable,
        timerEnable => timerEnable,
        timerOut    => one_sec_pulse
    );
    
    process(program, userDefinedTemp, startingTemp, internalCount)
    begin
        if finished = '1' then
            maxValue <= internalCount;
        elsif program = "001" then
            maxValue <= userDefinedTemp;
        else
            maxValue <= to_integer(unsigned(startingTemp));
        end if;
    end process;

    -- COUNTER UPDOWN
    counter : entity work.CounterUpDownN
    port map (
        clk         => clk,
        reset       => not enable,
        enable      => enableCounter,
        countUpDown => countUpDown,
        init_count  => initCount,
        count_init  => countInitValue,
        max_value   => maxValue,
        min_value   => tempMin,
        INCREMENT_STEP => s_INCREMENT_STEP,
        DECREMENT_STEP => s_DECREMENT_STEP,
        count       => internalCount);

    process(clk)
    begin
        if (rising_edge(clk)) then
            if enable = '1' then
                if finished = '1' then
                    enableCounter <= '0';
                    countInitValue <= maxValue;
                elsif coolingMode = '1' then
                    if one_sec_pulse = '1' then
                        countUpDown <= '0'; -- Decrementar temperatura
                        enableCounter <= '1';
                        initCount <= '0';
                        if fastCool = '1' then
                            s_DECREMENT_STEP <= 40; 
                        else
                            s_DECREMENT_STEP <= 20;
                        end if;
                    else
                        enableCounter <= '0';
                    end if;
                elsif run = '1' then
                    if tempRun = '0' then
                        countInitValue <= tempMin;
                        initCount <= '1';
                        tempInitialized <= '0'; -- Reset tempInitialized para próxima vez que run for 0
                        tempRun <= '1';
                    elsif one_sec_pulse = '1' then
                        if estado = '1' then
                            s_DECREMENT_STEP <= 20;
                            countUpDown <= '0'; -- Decrementar Temperatura
                            enableCounter <= '1';
                            initCount <= '0';
                        else
                            s_INCREMENT_STEP <= 10;
                            countUpDown <= '1'; -- Incrementar temperatura
                            enableCounter <= '1';
                            initCount <= '0';
                        end if;
                    else
                        enableCounter <= '0';
                    end if;
                elsif run = '0' then
                    if tempInitialized = '0' then
                        countInitValue <= to_integer(unsigned(startingTemp));
                        initCount <= '1';
                        tempInitialized <= '1';
                        tempRun <= '0';
                    end if;
                    if program = "001" then
                        -- USER pode definir manualmente até tempMax (250)
                        if tempUp = '1' and internalCount <= tempMax - s_INCREMENT_STEP then
                            userDefinedTemp <= internalCount + s_INCREMENT_STEP;
                            countUpDown <= '1';
                            enableCounter <= '1';
                            initCount <= '0';
                        elsif tempDown = '1' and internalCount >= tempMin + s_DECREMENT_STEP then
                            userDefinedTemp <= internalCount - s_DECREMENT_STEP;
                            countUpDown <= '0';
                            enableCounter <= '1';
                            initCount <= '0';
                        else
                            enableCounter <= '0';
                        end if;
                    else
                        userDefinedTemp <= to_integer(unsigned(startingTemp));
                        countInitValue <= to_integer(unsigned(startingTemp));
                        initCount <= '1';
                    end if;
                end if;
            elsif enable = '0' then
                countInitValue <= to_integer(unsigned(startingTemp));
                initCount <= '1';
            end if;
            currentTemp <= std_logic_vector(to_unsigned(internalCount, 8));
        end if;
    end process;

    -- Converte a temperatura em dígitos BCD
    process(internalCount)
    begin
        tempHundreds <= std_logic_vector(to_unsigned((internalCount / 100) mod 10, 4));
        tempDozens   <= std_logic_vector(to_unsigned((internalCount / 10) mod 10, 4));
        tempUnits    <= std_logic_vector(to_unsigned(internalCount mod 10, 4));
    end process;
end Behavioral;