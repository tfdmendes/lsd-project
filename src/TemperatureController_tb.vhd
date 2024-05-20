library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity TemperatureController_tb is
end TemperatureController_tb;

architecture Behavioral of TemperatureController_tb is
    -- Component declaration for the Unit Under Test (UUT)
    component TemperatureController is
        Port(
            clk         : in std_logic;
            clkEnable   : in std_logic;
            startingTemp : in std_logic_vector(7 downto 0); -- temperatura do program selecionado
            enable      : in std_logic;
            run         : in std_logic; -- se esta a trabalhar
            estado      : in std_logic;     -- estar aberto ou fechado (a cuba)
            fastCooler  : in std_logic;
            program     : in std_logic_vector(2 downto 0);
            tempUp      : in std_logic;
            tempDown    : in std_logic;
            tempUnits   : out std_logic_vector(3 downto 0);
            tempDozens  : out std_logic_vector(3 downto 0);
            tempHundreds : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Signals to connect to UUT
    signal clk         : std_logic := '0';
    signal clkEnable   : std_logic := '0';
    signal startingTemp : std_logic_vector(7 downto 0) := (others => '0');
    signal enable      : std_logic := '0';
    signal run         : std_logic := '0';
    signal estado      : std_logic := '0';
    signal fastCooler  : std_logic := '0';
    signal program     : std_logic_vector(2 downto 0) := (others => '0');
    signal tempUp      : std_logic := '0';
    signal tempDown    : std_logic := '0';
    signal tempUnits   : std_logic_vector(3 downto 0);
    signal tempDozens  : std_logic_vector(3 downto 0);
    signal tempHundreds : std_logic_vector(3 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: TemperatureController
        Port map (
            clk => clk,
            clkEnable => clkEnable,
            startingTemp => startingTemp,
            enable => enable,
            run => run,
            estado => estado,
            fastCooler => fastCooler,
            program => program,
            tempUp => tempUp,
            tempDown => tempDown,
            tempUnits => tempUnits,
            tempDozens => tempDozens,
            tempHundreds => tempHundreds
        );

    -- Clock process definitions
    clk_process :process
    begin
        while true loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize Inputs
        clkEnable <= '0';
        enable <= '0';
        run <= '0';
        tempUp <= '0';
        tempDown <= '0';
        program <= "000";
        startingTemp <= std_logic_vector(to_unsigned(100, 8)); -- Inicializa com 100

        -- Wait for global reset
        wait for 20 ns;
        clkEnable <= '1';
        enable <= '1';
        program <= "001";

        -- Set starting temperature
        wait for 20 ns;
        enable <= '1';

        -- Increment temperature
        wait for 20 ns;
        tempUp <= '1';
        wait for clk_period;
        tempUp <= '0';
        wait for 20 ns;

        -- Decrement temperature
        tempDown <= '1';
        wait for clk_period;
        tempDown <= '0';
        wait for 20 ns;

        -- Start run
        run <= '1';
        wait for 200 ns;
        run <= '0';
        
        -- Check the temperature increment to target
        wait for 200 ns;

        -- End simulation
        wait;
    end process;

end Behavioral;
