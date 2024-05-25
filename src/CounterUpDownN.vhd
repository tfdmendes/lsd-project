library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CounterUpDownN is
    port(
        clk         : in  std_logic;
        reset       : in  std_logic;
        enable      : in  std_logic;
        countUpDown : in  std_logic;
		  
        init_count  : in  std_logic;   -- Se o count inicializou
		  
        count_init  : in  natural;     --  Valor inicial count
        max_value   : in  natural;
        min_value   : in  natural;
		  
		  INCREMENT_STEP : in integer;
		  DECREMENT_STEP : in integer;
		  
        count       : out natural);
end CounterUpDownN;

architecture Behavioral of CounterUpDownN is
    signal count_reg : natural := 0;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            count_reg <= 0;
        elsif rising_edge(clk) then
            if init_count = '1' then
                count_reg <= count_init;
            elsif enable = '1' then
                if countUpDown = '1' and count_reg <= max_value - INCREMENT_STEP then
                    count_reg <= count_reg + INCREMENT_STEP;
                elsif countUpDown = '0' and count_reg >= min_value + DECREMENT_STEP then
                    count_reg <= count_reg - DECREMENT_STEP;
                end if;
            end if;
        end if;
    end process;
    
    count <= count_reg;
end Behavioral;
