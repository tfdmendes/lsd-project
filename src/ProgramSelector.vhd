library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity ProgramSelector is
  port
  (
    clk              : in std_logic;
    input            : in std_logic_vector(2 downto 0);
    ps_temp          : out std_logic_vector(7 downto 0); -- Temperatura definida pelo programa
    ps_timeCook      : out std_logic_vector(4 downto 0); -- Tempo de Cozimento definido pelo programa
    ps_timeHeat      : out std_logic_vector(4 downto 0); -- Tempo de Preaquecimento definido pelo Programa
    ps_programChosen : out std_logic_vector(2 downto 0)
  );
end ProgramSelector;

architecture Behavioral of ProgramSelector is
begin
  process (clk)
  begin
    if rising_edge(clk) then
      case input is
        when "000" =>
          ps_temp     <= "11001000"; -- 200°
          ps_timeCook <= "10010"; -- 18 mins Cozimento
          ps_timeHeat <= "00000"; -- 0 minutos Preaquecimento
        when "001" =>
          ps_temp     <= "11001000"; -- 200°
          ps_timeCook <= "10010"; -- 18 mins Cozimento
          ps_timeHeat <= "00000"; -- 0 minutos Preaquecimento
        when "010" =>
          ps_temp     <= "10110100"; -- 180°
          ps_timeCook <= "01111"; -- 15 mins Cozimento
          ps_timeHeat <= "00011"; -- 3 minutos Preaquecimento
        when "011" =>
          ps_temp     <= "11001000"; -- 200°
          ps_timeCook <= "10100"; -- 20 mins Cozimento
          ps_timeHeat <= "00101"; -- 5 minutos Preaquecimento
        when "100" =>
          ps_temp     <= "10101010"; -- 170°
          ps_timeCook <= "10100"; -- 20 mins Cozimento
          ps_timeHeat <= "00011"; -- 3 minutos Preaquecimento
        when "101" =>
          ps_temp     <= "10101010"; -- 170°
          ps_timeCook <= "10100"; -- 20 mins Cozimento
          ps_timeHeat <= "00101"; -- 5 minutos Preaquecimento
        when others =>
          ps_temp     <= "11001000"; -- Default case for others
          ps_timeCook <= "10010";
          ps_timeHeat <= "00000";
      end case;
      ps_programChosen <= input;
    end if;
  end process;
end Behavioral;