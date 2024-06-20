library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity DisplaysController is
  port
  (
    enable       : in std_logic;
    tempUnits    : in std_logic_vector(3 downto 0);
    tempDozens   : in std_logic_vector(3 downto 0);
    tempHundreds : in std_logic_vector(3 downto 0);

    timeUnits  : in std_logic_vector(3 downto 0);
    timeDozens : in std_logic_vector(3 downto 0);

    s_HEX0 : out std_logic_vector(6 downto 0);
    s_HEX1 : out std_logic_vector(6 downto 0);
    s_HEX2 : out std_logic_vector(6 downto 0);
    s_HEX4 : out std_logic_vector(6 downto 0);
    s_HEX5 : out std_logic_vector(6 downto 0));
end DisplaysController;

architecture Behavioral of DisplaysController is
  signal teste : std_logic_vector(6 downto 0);

begin
  bin7SegTemperatura : entity work.Bin7SegDecoder(Behavioral)
    port map
    (
      enable            => enable,
      binInput_units    => tempUnits,
      binInput_dozens   => tempDozens,
      binInput_hundreds => tempHundreds,

      decOut_u => s_HEX0,
      decOut_d => s_HEX1,
      decOut_h => s_HEX2);
  decOut_h => s_HEX2);

  bin7SegTime : entity work.Bin7SegDecoder(Behavioral)
    port
    map(enable        => enable,
    binInput_units    => timeUnits,
    binInput_dozens   => timeDozens,
    binInput_hundreds => "0000",

    decOut_u => S_HEX4,
    decOut_d => S_HEX5,
    decOut_h => teste);