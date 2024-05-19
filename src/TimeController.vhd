library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity TimeController is
    Port(
        clk          : in std_logic;
		  
		  timeHeat		: in std_logic_vector(4 downto 0); -- tempo de Aquecimento que vira do programa
		  timeCook		: in std_logic_vector(4 downto 0); -- tempo de Coccao que vira do programa
		  
        estado       : in std_logic; -- estar aberto ou fechado (a cuba)
        program      : in std_logic_vector(2 downto 0);
        heatOrCook   : in std_logic; -- sinal para quando queremos editar um dos tempos (0 para alterar heat) (1 para alterar cook)
        timeUp       : in std_logic;
        timeDown     : in std_logic;
        enable       : in std_logic;
        run          : in std_logic;
        timeUnits    : out std_logic_vector(3 downto 0);
        timeDozens   : out std_logic_vector(3 downto 0);
        ledSignal    : out std_logic;
        ledEndPreHeat    : out std_logic;
    );
end TimeController;

architecture Behavioral of TimeController is
    -- Sinais de Coccao
    signal timeCookMin     : INTEGER := 10;
    signal timeCookMax     : INTEGER := 30;
    
    -- Sinais de Pré-aquecimento
    signal timePreHeatMin  : INTEGER := 3;
    signal timePreHeatMax  : INTEGER := 10;
    
	 -- Sinais de mostragem
    signal timePreHeatShown : INTEGER := 0;
    signal timeCookShown    : INTEGER := 0;
    signal timeTotal        : INTEGER := 0;
    signal timeTotalShown   : INTEGER := 0;
    
    signal timeInitialized  : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                if run = '0' then
                    if program = "001" then
                        if timeInitialized = '0' then
                            -- Inicializa os tempos de pré-aquecimento e cozimento
                            timePreHeatShown <= timePreHeatMin;
                            timeCookShown <= timeCookMin;
                            timeInitialized <= '1';
                        else
                            -- Editando o tempo de pré-aquecimento
                            if heatOrCook = '1' then
                                ledSignal <= '1'; -- LED ligado para sinalizar edição do tempo de pré-aquecimento
                                if timeUp = '1' and timePreHeatShown < timePreHeatMax then
                                    timePreHeatShown <= timePreHeatShown + 1;
                                elsif timeDown = '1' and timePreHeatShown > timePreHeatMin then
                                    timePreHeatShown <= timePreHeatShown - 1;
                                end if;
                            -- Editando o tempo de cozimento
                            else
                                ledSignal <= '0'; -- LED desligado para sinalizar edição do tempo de cozimento
                                if timeUp = '1' and timeCookShown < timeCookMax then
                                    timeCookShown <= timeCookShown + 1;
                                elsif timeDown = '1' and timeCookShown > timeCookMin then
                                    timeCookShown <= timeCookShown - 1;
                                end if;
                            end if;
                        end if;
                    end if;
                else
                    timeInitialized <= '0'; -- Redefine a inicialização quando run está ativado
                    timeTotal <= timePreHeatShown + timeCookShown
                    if estado = '0' and timeTotalShown < 0 then
                        if timeTotal - timePreHeatShown == timeTotalShown then
                            ledEndPreHeat <= '1';
                        else
                            timeTotalShown <= timeTotalShown - 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Converte o tempo em dígitos BCD para os displays de sete segmentos
    process(timeCookShown, timePreHeatShown, heatOrCook)
    begin
        if heatOrCook = '1' then
            -- Mostra o tempo de pré-aquecimento
            timeDozens <= std_logic_vector(to_unsigned((timePreHeatShown / 10) mod 10, 4));
            timeUnits <= std_logic_vector(to_unsigned(timePreHeatShown mod 10, 4));
        else
            -- Mostra o tempo de cozimento
            timeDozens <= std_logic_vector(to_unsigned((timeCookShown / 10) mod 10, 4));
            timeUnits <= std_logic_vector(to_unsigned(timeCookShown mod 10, 4));
        end if;
    end process;
end Behavioral;
