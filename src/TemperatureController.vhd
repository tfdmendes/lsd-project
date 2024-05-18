library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


entity TemperatureController is
    Port(clk        : in std_logic;
        tempInicial : in std_logic_vector(7 downto 0); -- temperatura do programa selecionado
        estado      : in std_logic;     -- estar aberto ou fechado (a cuba)
        programa    : in std_logic_vector(2 downto 0);
        tempUp      : in std_logic;
        tempDown    : in std_logic;
        enable      : in std_logic:
        run         : in std_logic;

        tempUnidades : out std_logic_vector(3 downto 0);
        tempDezenas  : out std_logic(3 downto 0);
        tempCentenas : out std_logic(3 downto 0));

end TemperatureController;

architecture Behavioral of TemperatureController is
    signal tempMinima       : INTEGER := 20;
    signal tempMaxima        : INTEGER := 250;
    signal tempAlcancar     : INTEGER;
    signal tempDemonstrada   : INTEGER;
begin
    process(clk)
    begin
        if (rising_edge(clk)) then
            if run = 0 then
                tempDemonstrada  <= to_integer(unsigned(tempInicial));
                    
                if programa = "001" then
                    if tempUp = '1' and tempDemonstrada <= tempMaxima  then
                        tempDemonstrada <= tempDemonstrada + 10;
                    elsif tempDown = '1' and tempDemonstrada > tempMinima then
                        tempDemonstrada <= tempDemonstrada - 10;
                    end if;
                end if;
            end if;
        end if;
    end process;

    process(tempDemonstrada)
    begin 
        tempCentenas <= std_logic_vector(to_unsigned((tempDemonstrada / 100) mod 10, 4));
        tempDezenas  <= std_logic_vector(to_unsigned((tempDemonstrada / 10) mod 10, 4));
        tempUnidades <= std_logic_vector(to_unsigned(tempDemonstrada mod 10, 4));
    end process;
end Behavioral; 