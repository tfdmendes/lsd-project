library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


entity TemperatureController is
    Port(
        CLOCK_50 : in std_logic;
        Temp_Inicial : in std_logic_vector(7 downto 0); -- considerando ate 255°C
        Temp_Final : in std_logic_vector(7 downto 0);
        N : in STD_LOGIC_VECTOR(7 downto 0); -- Ajustável se necessário
        program : in STD_LOGIC_VECTOR(2 downto 0);
        Temp_Up : in STD_LOGIC;
        Temp_Down : in STD_LOGIC;
        RUN : in STD_LOGIC;
        Temperature_BCD : out STD_LOGIC_VECTOR(7 downto 0); -- 4 bits para dezenas e 4 para centenas
        FOOD_IN : out STD_LOGIC;
        Status_LEDs : out STD_LOGIC_VECTOR(3 downto 0)
    );
end TemperatureController;

architecture Behavioral of TemperatureController is
    signal current_temp : INTEGER range 0 to 300 := 20 -- defines range of temperature
    signal target_temp  : INTEGER range 0 to 300;
    signal is_cooking   : BOOLEAN := false;
    signal user_mode_selected    : BOOLEAN;
begin 
    user_mode <= (Program = "001"); -- verifica se o program está no modo USER
    process(CLOCK_50)
    begin 
        if rising_edge(CLOCK_50) then
            if RUN = '1' and not is_cooking then
                is_cooking = true;
                temp_target = to_integer(unsigned(Temp_final));
            end if;
            
            if is_cooking and user_mode_selected then
                    -- incrementar temperatura

                    -- decrementar temperatura
            end if; 
        end if;
    end process; 

    Temperature_BCD <= current_temp; 
end Behavioral; 