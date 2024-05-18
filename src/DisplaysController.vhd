library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DisplaysController is
    port(
        tempUnits       : in std_logic_vector(3 downto 0);
        tempDozens      : in std_logic_vector(3 downto 0);
        tempHundreds    : in std_logic_vector(3 downto 0)
        
        HEX0            : out std_logic(6 downto 0);
        HEX1            : out std_logic(6 downto 0);
        HEX2            : out std_logic(6 downto 0);
        HEX4            : out std_logic(6 downto 0);
        HEX5            : out std_logic(6 downto 0));
end DisplaysController;

architecture Behavioral of DisplaysController is


begin 
    bin7SegTemperatura : entity work.Bin7SegDecoder(Behavioral)
    port map(binInput_units     => tempUnits,
             binInput_dozens    => tempDozens,
             binInput_hundreds  => tempHundreds
             
             decOut_u           => HEX0
             decOut_d           => HEX1
             decOut_h           => HEX2);


end Behavioral;