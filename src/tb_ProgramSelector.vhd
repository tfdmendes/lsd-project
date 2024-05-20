library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity tb_ProgramSelector is
end tb_ProgramSelector;

architecture Behavioral of tb_ProgramSelector is
    signal clk             : std_logic := '0';
    signal input           : std_logic_vector(2 downto 0);
    signal ps_temp         : std_logic_vector(7 downto 0);
    signal ps_timeCook     : std_logic_vector(4 downto 0);
    signal ps_timeHeat     : std_logic_vector(4 downto 0);
    signal ps_programChosen: std_logic_vector(2 downto 0);

    constant clk_period : time := 20 ns;

begin
    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    uut: entity work.ProgramSelector
        port map (
            clk             => clk,
            input           => input,
            ps_temp         => ps_temp,
            ps_timeCook     => ps_timeCook,
            ps_timeHeat     => ps_timeHeat,
            ps_programChosen=> ps_programChosen
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Test each program
        input <= "000"; wait for clk_period * 10;
        input <= "001"; wait for clk_period * 10;
        input <= "010"; wait for clk_period * 10;
        input <= "011"; wait for clk_period * 10;
        input <= "100"; wait for clk_period * 10;
        input <= "101"; wait for clk_period * 10;
        input <= "111"; wait for clk_period * 10; -- default case
        wait;
    end process;
end Behavioral;
