library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity TemperatureController is
    Port(
        clk          : in std_logic;
        clkEnable    : in std_logic
        startingTemp : in std_logic_vector(7 downto 0); -- temperatura do program selecionado
        estado       : in std_logic;     -- estar aberto ou fechado (a cuba)
        fastCooler   : in std_logic;
        program      : in std_logic_vector(2 downto 0);
        tempUp       : in std_logic;
        tempDown     : in std_logic;
        enable       : in std_logic;
        run          : in std_logic; -- se esta a trabalhar
        tempUnits    : out std_logic_vector(3 downto 0);
        tempDozens   : out std_logic_vector(3 downto 0);
        tempHundreds : out std_logic_vector(3 downto 0)
    );
end TemperatureController;

architecture Behavioral of TemperatureController is
    signal tempMin                 : INTEGER := 20;
    signal tempMax                 : INTEGER := 250;
    signal tempCookShown           : INTEGER := 0;
    signal tempUserShown           : INTEGER := 0;
    signal tempInitialized         : std_logic := '0';
    signal tempStart               : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) and clkEnable = '1' then
            if enable = '1' then
                if run = '0' then
						if program = "001" then
							  if tempInitialized = '0' then
									tempUserShown <= to_integer(unsigned(startingTemp));
									tempInitialized <= '1';
							  else
									-- Verifica a borda de subida de tempUp
									if tempUp = '1' and tempUserShown <= tempMax - 10 then
										 tempUserShown <= tempUserShown + 10;
									-- Verifica a borda de subida de tempDown
									elsif tempDown = '1' and tempUserShown >= tempMin + 10 then
										 tempUserShown <= tempUserShown - 10;
									end if;
							  end if;
						 end if;
                tempStart <= '0';
                else
                    tempInitialized <= '0'; -- Redefine a inicialização quando run está ativado
                    if tempStart = '0' then
                        tempCookShown <= tempMin;
                        tempMax <= tempUserShown;
                        tempStart <= '1';
                    else
                        if estado = '0' and tempCookShown <= tempMax - 10 then
                            tempCookCookShown <= tempCookShown + 10;
                        elsif estado = '1' and tempCookShown >= tempMin + 20 then
                            tempCookShown <= tempCookShown - 20;
                        elsif estado = '1' and tempCookShown >= tempMin + 40 and fastCooler = '1' then
                            tempCookShown <= tempCookShown - 40;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Converte a temperatura em dígitos BCD
    process(tempUserShown, tempCookShown, run)
    begin
        if run = '0' then 
            tempHundreds <= std_logic_vector(to_unsigned((tempUserShown / 100) mod 10, 4));
            tempDozens  <= std_logic_vector(to_unsigned((tempUserShown / 10) mod 10, 4));
            tempUnits <= std_logic_vector(to_unsigned(tempUSerShown mod 10, 4));
        else
            tempHundreds <= std_logic_vector(to_unsigned((tempCookShown / 100) mod 10, 4));
            tempDozens  <= std_logic_vector(to_unsigned((tempCookShown / 10) mod 10, 4));
            tempUnits <= std_logic_vector(to_unsigned(tempCookShown mod 10, 4));
        end if;
    end process;
end Behavioral;
