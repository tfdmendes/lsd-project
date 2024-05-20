library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity ProgramSelector is
    port (
        clk           : in std_logic;
        input         : in std_logic_vector(2 downto 0);
        ps_temp       : out std_logic_vector(7 downto 0); -- Temperatura definida pelo programa
        ps_timeCook   : out std_logic_vector(4 downto 0); -- Tempo de Coccao definido pelo programa
        ps_timeHeat   : out std_logic_vector(4 downto 0)  -- Tempo de PreAquecimento definido pelo Programa
    );
end ProgramSelector;

architecture Behavioral of ProgramSelector is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- DEFAULT
            if input = "000" then
                ps_temp      <= "11001000"; -- 200°
                ps_timeCook  <= "10010";    -- 18 mins Coccao
                ps_timeHeat  <= "00000";    -- 0 minutos pre-aquecimento
            -- USER
            elsif input = "001" then
                ps_temp      <= "00000000"; -- 0º
                ps_timeCook  <= "00000";    -- 0 mins Coccao
                ps_timeHeat  <= "00000";    -- 0 minutos pre-aquecimento
            -- RISSOIS
            elsif input = "010" then
                ps_temp      <= "10110100"; -- 180º
                ps_timeCook  <= "01111";    -- 15 mins Coccao
                ps_timeHeat  <= "00011";    -- 3 minutos pre-aquecimento
            -- BATATAS
            elsif input = "011" then
                ps_temp      <= "11001000"; -- 200º
                ps_timeCook  <= "10100";    -- 20 mins Coccao
                ps_timeHeat  <= "00101";    -- 5 minutos pre-aquecimento
            -- FILETES PEIXE
            elsif input = "100" then
                ps_temp      <= "10101010"; -- 170º
                ps_timeCook  <= "10100";    -- 20 mins Coccao
                ps_timeHeat  <= "00011";    -- 3 minutos pre-aquecimento
            -- HAMBURGUER
            elsif input = "101" then
                ps_temp      <= "10101010"; -- 170º
                ps_timeCook  <= "10100";    -- 20 mins Coccao
                ps_timeHeat  <= "00101";    -- 5 minutos pre-aquecimento
            else
                ps_temp      <= "00000000"; -- Default case for others
                ps_timeCook  <= "00000";    
                ps_timeHeat  <= "00000";    
            end if;
        end if;
    end process;
end Behavioral;