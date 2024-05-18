library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity TemperatureController is
    Port(
        clk         : in std_logic;
        tempInicial : in std_logic_vector(7 downto 0); -- temperatura do programa selecionado
        estado      : in std_logic;     -- estar aberto ou fechado (a cuba)
        programa    : in std_logic_vector(2 downto 0);
        tempUp      : in std_logic;
        tempDown    : in std_logic;
        enable      : in std_logic;
        run         : in std_logic;
        tempUnidades : out std_logic_vector(3 downto 0);
        tempDezenas  : out std_logic_vector(3 downto 0);
        tempCentenas : out std_logic_vector(3 downto 0)
    );
end TemperatureController;

architecture Behavioral of TemperatureController is
    signal tempMinima      : INTEGER := 20;
    signal tempMaxima      : INTEGER := 250;
    signal tempDemonstrada : INTEGER := 0;
    signal tempInitialized : std_logic := '0';
    signal prev_tempUp     : std_logic := '0';
    signal prev_tempDown   : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                if run = '0' then
                    if tempInitialized = '0' then
                        tempDemonstrada <= to_integer(unsigned(tempInicial));
                        tempInitialized <= '1';
                    else
                        -- Verifica a borda de subida de tempUp
                        if tempUp = '1' and prev_tempUp = '0' and tempDemonstrada <= tempMaxima - 10 then
                            tempDemonstrada <= tempDemonstrada + 10;
                        -- Verifica a borda de subida de tempDown
                        elsif tempDown = '1' and prev_tempDown = '0' and tempDemonstrada >= tempMinima + 10 then
                            tempDemonstrada <= tempDemonstrada - 10;
                        end if;
                    end if;
                else
                    tempInitialized <= '0'; -- Redefine a inicialização quando run está ativado
                end if;
            end if;
            -- Atualiza os estados anteriores dos sinais tempUp e tempDown
            prev_tempUp <= tempUp;
            prev_tempDown <= tempDown;
        end if;
    end process;

    -- Converte a temperatura em dígitos BCD
    process(tempDemonstrada)
    begin
        tempCentenas <= std_logic_vector(to_unsigned((tempDemonstrada / 100) mod 10, 4));
        tempDezenas  <= std_logic_vector(to_unsigned((tempDemonstrada / 10) mod 10, 4));
        tempUnidades <= std_logic_vector(to_unsigned(tempDemonstrada mod 10, 4));
    end process;
end Behavioral;
