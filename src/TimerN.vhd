library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity TimerN is
    port(
        clk       : in  std_logic;
        reset       : in  std_logic;
        timerEnable : in  std_logic;
        timerOut    : out std_logic);
end TimerN;

architecture Behavioral of TimerN is
    signal s_pulse : std_logic;
begin

    pulseGen : entity work.PulseGen
        generic map (MAX => 50_000_000)
        port map (clk => clk,
            reset => reset,
            pulse => s_pulse);

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                timerOut <= '0';
            else
                timerOut <= s_pulse and timerEnable;
            end if;
        end if;
    end process;
end Behavioral;
