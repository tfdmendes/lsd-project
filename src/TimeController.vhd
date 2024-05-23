library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity TimeController is
    Port(
        clk          : in std_logic;
		  clkEnable		: in std_logic;
		  timerEnable	: in std_logic;
		  
        timeHeat	 	: in std_logic_vector(4 downto 0); -- tempo de Aquecimento que vira do programa
        timeCook	 	: in std_logic_vector(4 downto 0); -- tempo de Coccao que vira do programa
		  
        enable       : in std_logic;
        run          : in std_logic;
        estado       : in std_logic; -- estar aberto ou fechado (a cuba)
        heatOrCook   : in std_logic; -- sinal para quando queremos editar um dos tempos (0 para alterar heat) (1 para alterar cook)
		  
        program      : in std_logic_vector(2 downto 0);
        timeUp       : in std_logic;
        timeDown     : in std_logic;

        timeUnits    : out std_logic_vector(3 downto 0);
        timeDozens   : out std_logic_vector(3 downto 0);
        ledSignal    : out std_logic;
		  
		  timePreHeatTotal : out std_logic_vector(5 downto 0);
		  timeCookTotal	 : out std_logic_vector(5 downto 0);
		  currentTime 		 : out std_logic_vector(5 downto 0));
		  
end TimeController;

architecture Behavioral of TimeController is
    -- Sinais de Coccao
    signal timeCookMin      : INTEGER := 10;
    signal timeCookMax      : INTEGER := 30;
    
    -- Sinais de Pré-aquecimento
    signal timePreHeatMin   : INTEGER := 0;
    signal timePreHeatMax   : INTEGER := 10;
    
	-- Sinais de mostragem
    signal timePreHeatShown : INTEGER := 0;
    signal timeCookShown    : INTEGER := 0;
	signal timeTotalShown   : INTEGER := 0;
    signal timeInitialized  : std_logic := '0';
	signal timeRun          : std_logic := '0';
	 
	signal one_sec_pulse    : std_logic := '0';

begin
	 -- TIMER
    timer : entity work.TimerN(Behavioral)
    port map(clk         => clk,
				 clkEnable	 => clkEnable,
             reset       => not enable,
             timerEnable => timerEnable,
             timerOut    => one_sec_pulse);

    process(clk)
    begin
        if (rising_edge(clk)) then
            if enable = '1' then
                if run = '0' then
                    if timeInitialized = '0' then
                        -- Inicializa os tempos de pré-aquecimento e cozimento
                        timePreHeatShown <= to_integer(unsigned(timeHeat));
                        timeCookShown <= to_integer(unsigned(timeCook));
                        timeInitialized <= '1';
                        timeRun <= '0';
                    end if;
                    -- Se o programa for o USER - pode definir TEMPO
                    if program = "001" then
                        -- Editando o tempo de pré-aquecimento
                        if heatOrCook = '1' then
                            if timeUp = '1' and timePreHeatShown < timePreHeatMax then
                                timePreHeatShown <= timePreHeatShown + 1;
                            elsif timeDown = '1' and timePreHeatShown > timePreHeatMin then
                                timePreHeatShown <= timePreHeatShown - 1;
                            end if;
                        -- Editando o tempo de cozimento
                        else
                            if timeUp = '1' and timeCookShown < timeCookMax then
                                timeCookShown <= timeCookShown + 1;
                            elsif timeDown = '1' and timeCookShown > timeCookMin then
                                timeCookShown <= timeCookShown - 1;
                            end if;
                        end if;
							  timePreHeatTotal <= std_logic_vector(to_unsigned(timePreHeatShown, 6));
							  timeCookTotal <= std_logic_vector(to_unsigned(timeCookShown, 6));
                    else
                        timePreHeatShown <= to_integer(unsigned(timeHeat));
                        timeCookShown <= to_integer(unsigned(timeCook));
                    end if;
                elsif run = '1' then
                    if timeRun = '0' then
                            timeTotalShown <= timePreHeatShown + timeCookShown;
									 timePreHeatTotal <= std_logic_vector(to_unsigned(timePreHeatShown, 6));
									 timeCookTotal <= std_logic_vector(to_unsigned(timeCookShown, 6));
									 
                            timeInitialized <= '0'; -- Reset timeInitialized para próxima vez que run for 0
                            timeRun <= '1';
                    end if;
                    if estado = '0' then
                        if timeRun = '1' then
									 currentTime		<= std_logic_vector(to_unsigned(timeTotalShown, 6));
                            if one_sec_pulse = '1' then
                                if timeTotalShown > 0 then
                                    timeTotalShown <= timeTotalShown - 1;
                                end if;
                            end if;
                        end if;
                    else
                        timeTotalShown <= timeTotalShown;
							end if;
                end if;
					 
				elsif enable = '0' then
					timePreHeatShown <= to_integer(unsigned(timeHeat));
					timeCookShown <= to_integer(unsigned(timeCook));
            end if;
        end if;
    end process;

    -- Converte o tempo em dígitos BCD para os displays de sete segmentos
    process(timeCookShown, timePreHeatShown, heatOrCook)
    begin
		if run = '0' then
        if heatOrCook = '1' then
				ledSignal <= '1';
            -- Mostra o tempo de pré-aquecimento
            timeDozens <= std_logic_vector(to_unsigned((timePreHeatShown / 10) mod 10, 4));
            timeUnits <= std_logic_vector(to_unsigned(timePreHeatShown mod 10, 4));
        else
				ledSignal <= '0';
            -- Mostra o tempo de cozimento
            timeDozens <= std_logic_vector(to_unsigned((timeCookShown / 10) mod 10, 4));
            timeUnits <= std_logic_vector(to_unsigned(timeCookShown mod 10, 4));
        end if;
		else
			timeDozens <= std_logic_vector(to_unsigned((timeTotalShown / 10) mod 10, 4));
         timeUnits <= std_logic_vector(to_unsigned(timeTotalShown mod 10, 4));
		end if;
    end process;
end Behavioral;