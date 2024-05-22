library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity TimerN is
    port(
        clk       : in  std_logic;
		  clkEnable	: in std_logic;
        reset       : in  std_logic;
        timerEnable : in  std_logic;
        timerOut    : out std_logic);
end TimerN;

architecture Behavioral of TimerN is
begin
    process(clk)
    begin
        if (rising_edge(clk)) then
				timerOut <= clkEnable and timerEnable;
        end if;
    end process;
end Behavioral;
