library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity BinToBCD8 is
    port(
        bindata : in std_logic_vector(7 downto 0); -- 8-bit binary input
        dec_out_u, dec_out_d, dec_out_c : out std_logic_vector(3 downto 0) -- Unidade, Dezena, Centena
    );
end BinToBCD8;

architecture Behavioral of BinToBCD8 is
    signal s_dez, s_cen : unsigned(7 downto 0);
    signal s_int, s_rem : unsigned(7 downto 0);
begin
    -- Convert binary to BCD
    s_cen <= "01100100"; -- 100 for hundreds place
    s_dez <= "00001010"; -- 10 for tens place

    -- Calculate hundreds place
    s_int <= unsigned(bindata) / s_cen; 
    s_rem <= unsigned(bindata) rem s_cen; 

    -- Output hundreds place
    dec_out_c <= std_logic_vector(s_int(3 downto 0)); 

    -- Calculate tens place
    s_int <= s_rem / s_dez; 
    s_rem <= s_rem rem s_dez; 

    -- Output tens place
    dec_out_d <= std_logic_vector(s_int(3 downto 0)); 

    -- Output units place
    dec_out_u <= std_logic_vector(s_rem(3 downto 0)); 
end Behavioral;
