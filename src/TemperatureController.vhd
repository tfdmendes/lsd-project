library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity TemperatureController is
    port(
        clk          : in std_logic;
        startingTemp : in std_logic_vector(7 downto 0); -- temperatura do programa selecionado
        enable       : in std_logic;
        run          : in std_logic; -- se está a trabalhar
        estado       : in std_logic; -- estar aberto ou fechado (a cuba)
        fastCooler   : in std_logic;
        program      : in std_logic_vector(2 downto 0);
        tempUp       : in std_logic;
        tempDown     : in std_logic;
        tempUnits    : out std_logic_vector(3 downto 0);
        tempDozens   : out std_logic_vector(3 downto 0);
        tempHundreds : out std_logic_vector(3 downto 0));
end TemperatureController;

architecture Behavioral of TemperatureController is
    signal tempMin         : INTEGER := 20;
    signal tempMax         : INTEGER := 250;
    signal tempShown       : INTEGER := 0;
    signal tempTarget      : INTEGER := 100;
    signal tempInitialized : std_logic := '0';
    signal tempRun         : std_logic := '0';
    signal one_sec_pulse   : std_logic := '0';
    signal timerOut        : std_logic;

begin
    -- Instanciação do TimerModule
    timer : entity work.TimerN(Behavioral)
    port map(clk       => clk,
            reset       => not enable,
            timerEnable => run,
            timerOut    => one_sec_pulse);

    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                if run = '0' then
                    if tempInitialized = '0' then
                        tempShown <= to_integer(unsigned(startingTemp));
                        tempInitialized <= '1';
                        tempRun <= '0';
                    end if;
                    -- Se o programa for o USER - pode definir temperatura
                    if program = "001" then
                        if tempUp = '1' and tempShown <= tempMax - 10 then
                            tempShown <= tempShown + 10;
                        elsif tempDown = '1' and tempShown >= tempMin + 10 then
                            tempShown <= tempShown - 10;
                        end if;
                    end if;
						  tempTarget <= tempShown; -- Define a temperatura alvo
                else
                    -- Quando run é 1, a temperatura inicial é definida como 20°C
                    if tempRun = '0' then
                        tempShown <= tempMin;
                        tempInitialized <= '0';
                        tempRun <= '1';
                    else
                        if one_sec_pulse = '1' then
                            if tempShown < tempTarget then
                                tempShown <= tempShown + 10;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Converte a temperatura em dígitos BCD
    process(tempShown)
    begin
        tempHundreds <= std_logic_vector(to_unsigned((tempShown / 100) mod 10, 4));
        tempDozens   <= std_logic_vector(to_unsigned((tempShown / 10) mod 10, 4));
        tempUnits    <= std_logic_vector(to_unsigned(tempShown mod 10, 4));
    end process;
end Behavioral;
