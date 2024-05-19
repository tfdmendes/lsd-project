library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity TemperatureController is
    Port(
        clk         : in std_logic;
		  clkEnable		: in std_logic;
        startingTemp : in std_logic_vector(7 downto 0); -- temperatura do program selecionado
        enable      : in std_logic;
        run         : in std_logic; -- se esta a trabalhar
        estado      : in std_logic;     -- estar aberto ou fechado (a cuba)
        fastCooler   : in std_logic;
        program    : in std_logic_vector(2 downto 0);
        tempUp      : in std_logic;
        tempDown    : in std_logic;
        tempUnits : out std_logic_vector(3 downto 0);
        tempDozens  : out std_logic_vector(3 downto 0);
        tempHundreds : out std_logic_vector(3 downto 0)
    );
end TemperatureController;

architecture Behavioral of TemperatureController is
    signal tempMin      : INTEGER := 20;
    signal tempMax      : INTEGER := 250;
    signal tempShown : INTEGER := 0;
    signal tempInitialized : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                if run = '0' then
						if program = "001" then
							  if tempInitialized = '0' then
									tempShown <= to_integer(unsigned(startingTemp));
									tempInitialized <= '1';
							  else
									-- Verifica a borda de subida de tempUp
									if tempUp = '1' and tempShown <= tempMax - 10 then
										 tempShown <= tempShown + 10;
									-- Verifica a borda de subida de tempDown
									elsif tempDown = '1' and tempShown >= tempMin + 10 then
										 tempShown <= tempShown - 10;
									end if;
							  end if;
						 end if;
                else
                    tempInitialized <= '0'; -- Redefine a inicialização quando run está ativado
                end if;
            end if;
        end if;
    end process;

    -- Converte a temperatura em dígitos BCD
    process(tempShown)
    begin
        tempHundreds <= std_logic_vector(to_unsigned((tempShown / 100) mod 10, 4));
        tempDozens  <= std_logic_vector(to_unsigned((tempShown / 10) mod 10, 4));
        tempUnits <= std_logic_vector(to_unsigned(tempShown mod 10, 4));
    end process;
end Behavioral;
