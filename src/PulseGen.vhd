library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PulseGen is
    generic (MAX : integer := 50_000_000);
    port (clk : in std_logic;
        reset : in std_logic;
        pulse : out std_logic);
end PulseGen;

architecture Behavioral of PulseGen is
    signal count : integer := 0;
begin
    process(clk, reset)
    begin
		  if (rising_edge(clk)) then
				pulse <= '0';
				if(reset = '1') then
					count <= 0;
				else 
					count <= count +1;
					if (count = MAX -1) then
						count <= 0;
						pulse <= '1';
					end if;
				end if;
        end if;
    end process;
end Behavioral;
