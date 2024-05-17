library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


entity TemperatureController is
    Port(clk       : in std_logic;
        Temp_Inicial    : in std_logic_vector(7 downto 0); -- considerando ate 255°C
        Temp_Final      : in std_logic_vector(7 downto 0);
        N               : in STD_LOGIC_VECTOR(7 downto 0); -- Ajustável se necessário
        program         : in STD_LOGIC_VECTOR(2 downto 0);
        Temp_Up         : in STD_LOGIC;
        Temp_Down       : in STD_LOGIC;
        RUN             : in STD_LOGIC;
        Temperature_BCD : out STD_LOGIC_VECTOR(7 downto 0); -- 4 bits para dezenas e 4 para centenas
        FOOD_IN         : out STD_LOGIC;
        Status_LEDs     : out STD_LOGIC_VECTOR(3 downto 0));
end TemperatureController;

architecture Behavioral of TemperatureController is
    signal current_temp          : unsigned(7 downto 0);
    signal target_temp           : unsigned(7 downto 0);
    signal is_cooking            : BOOLEAN := false;
    signal user_mode_selected    : BOOLEAN;
begin
    user_mode <= (Program = "001"); -- verifica se o program está no modo USER
    process(clk)
    begin 
        if rising_edge(clk) then
            current_temp <= (unsigned(Temp_Inicial));

            if Run = '1' then
                if not is_cooking then
                    is_cooking <= true;
                    target_temp <= unsigned(Temp_Final);
                    current_temp <= unsigned(Temp_Inicial); 
                end if;
                
                if user_mode_selected and not is_cooking then
                    -- Incrementar temperatura
                    if Temp_Up = '1' and current_temp < unsigned(Temp_Final) then
                        current_temp <= current_temp + unsigned(N);
                    end if;
                    -- Decrementar temperatura
                    if Temp_Down = '1' and current_temp >= 20 then
                        current_temp <= current_temp - unsigned(N);
                    end if;
                end if;
            end if;       
        end if; 
    end process; 

    Temperature_BCD <= current_temp;
    FOOD_IN <= '0'; -- place holder, ajustar conforme necessário
    Status_LEDs <= "0000"; -- place holder, ajustar conforme necessário

end Behavioral; 