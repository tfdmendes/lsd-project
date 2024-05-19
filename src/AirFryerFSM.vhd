library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity AirFryerFSM is
  port
  (
    clk             : in std_logic;
    reset           : in std_logic;
    run             : in std_logic;
    OPEN_OVEN       : in std_logic;
    program         : in std_logic_vector(2 downto 0);
    tempNow         : in std_logic_vector(7 downto 0);
    timePreHeat     : in std_logic_vector(3 downto 0);
    timeTotal       : in std_logic_vector(4 downto 0);
    timeNow         : in std_logic_vector(4 downto 0);
    ledStateIDLE    : out std_logic;
    ledStatePREHEAT : out std_logic;
    ledStateCOOK    : out std_logic;
    ledStateCOOL    : out std_logic
  );
end AirFryerFSM;

architecture rtl of AirFryerFSM is

  type TState is (IDLE, PREHEAT, COOK, COOL);
  signal pState, nState : TState;

begin

  sync_proc : process (clk)
  begin
    if (rising_edge(clk)) then
      if (reset = '1') then
        pState <= IDLE;
      else
        pState <= nState;
      end if;
    end if;
  end process;

  comb_proc : process (pState, program, run, timeNow, timePreHeat, timeTotal, OPEN_OVEN, tempNow)
  begin
    case pState is
      when IDLE =>
        ledStateIDLE    <= '1';
        ledStatePREHEAT <= '0';
        ledStateCOOK    <= '0';
        ledStateCOOL    <= '0';
        if (program = "001" or program = "010" or program = "011" or program = "100" or program = "101") and run = '1' then
          nState <= PREHEAT;
        elsif (program = "000" or (program = "001" and timePreHeat = "0000")) and run = '1' then
          nState <= COOK;
        end if;

      when PREHEAT =>
        ledStateIDLE    <= '0';
        ledStatePREHEAT <= '1';
        ledStateCOOK    <= '0';
        ledStateCOOL    <= '0';
        if unsigned(timeTotal) - unsigned(timePreHeat) = timeNow then
          nState <= COOK;
        else
          nState <= PREHEAT;
        end if;

      when COOK =>
        ledStateIDLE    <= '0';
        ledStatePREHEAT <= '0';
        ledStateCOOK    <= '1';
        ledStateCOOL    <= '0';
        if timeNow = "00000" then
          nState <= COOL;
        else
          nState <= COOK;
        end if;

      when COOL =>
        ledStateIDLE    <= '0';
        ledStatePREHEAT <= '0';
        ledStateCOOK    <= '0';
        ledStateCOOL    <= '1';
        if OPEN_OVEN = '1' and tempNow = "00010100" then
          nState <= IDLE;
        else
          nState <= COOL;
        end if;

      when others =>
        nState          <= IDLE;
        ledStateIDLE    <= '1';
        ledStatePREHEAT <= '0';
        ledStateCOOK    <= '0';
        ledStateCOOL    <= '0';
    end case;
  end process;
end architecture;