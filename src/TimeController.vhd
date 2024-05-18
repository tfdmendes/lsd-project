library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity TimeController is
    Port(
        clk         : in std_logic;
        timeInicial : in std_logic_vector(7 downto 0); -- temperatura do programa selecionado
        estado      : in std_logic;     -- estar aberto ou fechado (a cuba)
        programa    : in std_logic_vector(2 downto 0);
        preOrCook   : in std_logic;
        timeUp      : in std_logic;
        timeDown    : in std_logic;
        enable      : in std_logic;
        run         : in std_logic;
        tempUnidades : out std_logic_vector(3 downto 0);
        tempDezenas  : out std_logic_vector(3 downto 0)
    );
end TimeController;

architecture Behavioral of TemperatureController is
    signal timeCookMinimo      : INTEGER := 10; --possivel alteração
    signal timeCookMaxima      : INTEGER := 30; --possivel alteração
    signal timePreMinimo      : INTEGER := 3; --possivel alteração
    signal timePreMaxima      : INTEGER := 10; --possivel alteração
    signal timePreDemonstrada : INTEGER := 0;
    signal timeCookDemonstrada : INTEGER := 0;
    signal timeInitialized : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                if run = '0' then
                    if timeInitialized = '0' then
                        timeDemonstrada <= to_integer(unsigned(timeInicial));
                        timeInitialized <= '1';
                    else
                        if preOrCook = '1' then
                            if timeUp = '1' and timePreDemonstrada <= timePreMaxima - 1 then
                                timePreDemonstrada <= timePreDemonstrada + 1;
                            elsif timeUp = '1' and timePreDemonstrada <= timePreMinima + 1 then
                                timePreDemonstrada <= timePreDemonstrada - 1;
                            end if;
                        else
                            if timeUp = '1' and timeCookDemonstrada <= timeCookMaxima - 1 then
                                timeCookDemonstrada <= timeCookDemonstrada + 1;
                            elsif timeDown = '1' and timeCookDemonstrada >= timeCookMinima + 1 then
                                timeCookDemonstrada <= timeCookDemonstrada - 1;
                            end if;
                    end if;
                else
                    timeInitialized <= '0'; -- Redefine a inicialização quando run está ativado
                end if;
            end if;
        end if;
    end process;

    -- Converte a temperatura em dígitos BCD
    process(timeDemonstrada)
    begin
        timeDezenas  <= std_logic_vector(to_unsigned((timeDemonstrada / 10) mod 10, 4));
        timeUnidades <= std_logic_vector(to_unsigned(timeDemonstrada mod 10, 4));
    end process;
end Behavioral;
