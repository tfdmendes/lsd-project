library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity AirFryer is
  port
  (
    CLOCK_50 : in std_logic;
    KEY      : in std_logic_vector(3 downto 0);
    SW       : in std_logic_vector(17 downto 0); -- Ajustado para refletir o novo número de switches

    LEDR : out std_logic_vector(8 downto 0);
    LEDG : out std_logic_vector(7 downto 0);

    HEX0 : out std_logic_vector(6 downto 0);
    HEX1 : out std_logic_vector(6 downto 0);
    HEX2 : out std_logic_vector(6 downto 0);
    HEX4 : out std_logic_vector(6 downto 0);
    HEX5 : out std_logic_vector(6 downto 0)
  );
end AirFryer;

architecture Demo of AirFryer is
  signal s_timeUp, s_timeDown, s_tempUp, s_tempDown         : std_logic;
  signal s_temp_Uni, s_temp_Doz, s_temp_Cen                 : std_logic_vector(3 downto 0);
  signal s_time_Uni, s_time_Doz                             : std_logic_vector(3 downto 0);
  signal s_1Hz                                              : std_logic;
  signal s_timeCook, s_timeHeat                             : std_logic_vector(4 downto 0);
  signal s_temp                                             : std_logic_vector(7 downto 0);
  signal s_programChosen                                    : std_logic_vector(2 downto 0);
  signal s_tempTimerEnable, s_timeTimerEnable               : std_logic;
  signal s_timePreHeatTotal, s_timeCookTotal, s_currentTime : std_logic_vector(5 downto 0);
  signal s_currentTemp                                      : std_logic_vector(7 downto 0);
  signal s_coolingMode, s_finished                          : std_logic;

  -- Entradas Switches Sincronizados
  signal sw1_ff_out, sw0_ff_out, sw2_ff_out, sw7_ff_out : std_logic;
  signal sw3_ff_out, sw8_ff_out                         : std_logic;
  signal swProgram_ff_out                               : std_logic_vector(2 downto 0);

begin
  process (CLOCK_50)
  begin
    if rising_edge(CLOCK_50) then
      sw0_ff_out       <= SW(0);
      sw1_ff_out       <= SW(1);
      sw2_ff_out       <= SW(2);
      sw3_ff_out       <= SW(3);
      swProgram_ff_out <= SW(6 downto 4);
      sw7_ff_out       <= SW(7);
      sw8_ff_out       <= SW(8);
    end if;
  end process;

  -- Debouncer for all keys
  keys_debounce : entity work.DebounceUnits(Behavioral)
    port map
    (
      clock        => CLOCK_50,
      timer_up_key => KEY(0),
      timer_dw_key => KEY(1),
      temp_up_key  => KEY(2),
      temp_dw_key  => KEY(3),
      timer_up_out => s_timeUp,
      timer_dw_out => s_timeDown,
      temp_up_out  => s_tempUp,
      temp_dw_out  => s_tempDown
    );

  -- Pulse Generator
  pulseGen : entity work.PulseGen
    generic
    map (MAX => 50_000_000)
    port
    map (
    clk   => CLOCK_50,
    reset => not sw0_ff_out,
    pulse => s_1Hz
    );

  -- PROGRAM SELECTOR
  progamSelector : entity work.ProgramSelector(Behavioral)
    port
    map(
    clk              => CLOCK_50,
    input            => swProgram_ff_out,
    ps_temp          => s_temp,
    ps_timeCook      => s_timeCook,
    ps_timeHeat      => s_timeHeat,
    ps_programChosen => s_programChosen
    );

  -- TEMPERATURA
  TemperatureController : entity work.TemperatureController(Behavioral)
    port
    map(
    clk         => CLOCK_50,
    clkEnable   => s_1Hz,
    timerEnable => s_tempTimerEnable,

    startingTemp => s_temp, -- temperatura do programa selecionado

    enable      => sw0_ff_out,
    run         => sw1_ff_out,
    estado      => sw2_ff_out, -- estar aberto ou fechado (a cuba)
    fastCool    => sw7_ff_out,
    coolingMode => s_coolingMode,
    finished    => s_finished,

    program  => s_programChosen,
    tempUp   => s_tempUp,
    tempDown => s_tempDown,

    currentTemp  => s_currentTemp,
    tempUnits    => s_temp_Uni,
    tempDozens   => s_temp_Doz,
    tempHundreds => s_temp_Cen);

  -- TEMPO
  TimeController : entity work.TimeController(Behavioral)
    port
    map(
    clk         => CLOCK_50,
    clkEnable   => s_1Hz,
    timerEnable => s_timeTimerEnable,

    timeHeat => s_timeHeat,
    timeCook => s_timeCook,

    enable      => sw0_ff_out,
    run         => sw1_ff_out,
    estado      => sw2_ff_out, -- estar aberto ou fechado (a cuba)
    coolingMode => s_coolingMode,
    heatOrCook  => sw8_ff_out,

    program  => s_programChosen,
    timeUp   => s_timeUp,
    timeDown => s_timeDown,
    finished => s_finished,

    timeUnits  => s_time_Uni,
    timeDozens => s_time_Doz,
    ledSignal  => LEDR(8),

    timePreHeatTotal => s_timePreHeatTotal,
    timeCookTotal    => s_timeCookTotal,
    currentTime      => s_currentTime);

  -- STATE MACHINE
  AirFryerFSM : entity work.AirFryerFSM(Behavioral)
    port
    map(
    enable    => sw0_ff_out,
    clk       => CLOCK_50,
    clkEnable => s_1Hz,

    reset     => not sw0_ff_out,
    run       => sw1_ff_out,
    OPEN_OVEN => sw2_ff_out,

    timePreHeat => s_timePreHeatTotal,
    timeCook    => s_timeCookTotal,
    currentTime => s_currentTime,
    currentTemp => s_currentTemp,

    ledFoodIn       => LEDG(0),
    ledHalfTime     => LEDG(7 downto 4),
    ledStateIDLE    => LEDR(3),
    ledStatePREHEAT => LEDR(2),
    ledStateCOOK    => LEDR(1),
    ledStateFINISH  => LEDR(0),

    finished        => s_finished,
    coolingMode     => s_coolingMode,
    tempTimerEnable => s_tempTimerEnable,
    timeTimerEnable => s_timeTimerEnable);
  -- DISPLAYS CONTROLLER
  DisplaysController : entity work.DisplaysController(Behavioral)
    port
    map(
    enable       => sw0_ff_out,
    tempUnits    => s_temp_Uni,
    tempDozens   => s_temp_Doz,
    tempHundreds => s_temp_Cen,
    timeUnits    => s_time_Uni,
    timeDozens   => s_time_Doz,
    s_HEX0       => HEX0,
    s_HEX1       => HEX1,
    s_HEX2       => HEX2,
    s_HEX4       => HEX4,
    s_HEX5       => HEX5);

end Demo;