library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity TemperatureController_tb is
end TemperatureController_tb;

architecture Behavioral of TemperatureController_tb is
    -- Sinais de teste
    signal clk         : std_logic := '0';
    signal tempInicial : std_logic_vector(7 downto 0) := "01100100"; -- 100 em binário
    signal estado      : std_logic := '0';
    signal programa    : std_logic_vector(2 downto 0) := "001";
    signal tempUp      : std_logic := '0';
    signal tempDown    : std_logic := '0';
    signal enable      : std_logic := '1';
    signal run         : std_logic := '0';

    signal tempUnidades : std_logic_vector(3 downto 0);
    signal tempDezenas  : std_logic_vector(3 downto 0);
    signal tempCentenas : std_logic_vector(3 downto 0);

    -- Período do clock de 20ns (50MHz)
    constant clk_period : time := 20 ns;

begin
    -- Instancia o módulo TemperatureController
    uut: entity work.TemperatureController
        port map (
            clk         => clk,
            tempInicial => tempInicial,
            estado      => estado,
            programa    => programa,
            tempUp      => tempUp,
            tempDown    => tempDown,
            enable      => enable,
            run         => run,
            tempUnidades => tempUnidades,
            tempDezenas  => tempDezenas,
            tempCentenas => tempCentenas
        );

    -- Geração do clock
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Processo de simulação
    stimulus: process
    begin
        -- Inicialmente run = 0 (incremento e decremento permitidos)
        run <= '0';
        wait for 100 ns;

        -- Incrementa a temperatura
        tempUp <= '1';
        wait for clk_period;
        tempUp <= '0';
        wait for 100 ns;

        -- Decrementa a temperatura
        tempDown <= '1';
        wait for clk_period;
        tempDown <= '0';
        wait for 100 ns;

        -- Ativa run (incremento e decremento não permitidos)
        run <= '1';
        wait for 100 ns;

        -- Tenta incrementar a temperatura (não deve mudar)
        tempUp <= '1';
        wait for clk_period;
        tempUp <= '0';
        wait for 100 ns;

        -- Tenta decrementar a temperatura (não deve mudar)
        tempDown <= '1';
        wait for clk_period;
        tempDown <= '0';
        wait for 100 ns;

        -- Finaliza a simulação
        wait;
    end process;

end Behavioral;
