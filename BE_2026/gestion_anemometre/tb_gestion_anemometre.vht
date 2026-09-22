library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_gestion_anemometre is
end tb_gestion_anemometre;

architecture behavior of tb_gestion_anemometre is

    constant clk_period : time    := 20 ns;
    constant max_sim    : natural := 50000000;
    constant seconde    : time    := max_sim * clk_period;

    signal clk_50M            : std_logic := '0';
    signal raz_n              : std_logic := '1';
    signal in_freq_anemometre : std_logic := '0';
    signal continu            : std_logic := '0';
    signal start_stop         : std_logic := '0';
    signal data_valid         : std_logic;
    signal data_anemometre    : std_logic_vector(7 downto 0);
    signal led                : std_logic_vector(7 downto 0);

    signal periode_vent : time := seconde / 47;

begin

    uut : entity work.gestion_anemometre
        generic map (
            max_1s => max_sim
        )
        port map (
            clk_50M            => clk_50M,
            raz_n              => raz_n,
            in_freq_anemometre => in_freq_anemometre,
            continu            => continu,
            start_stop         => start_stop,
            data_valid         => data_valid,
            data_anemometre    => data_anemometre,
            led                => led
        );

    clk_process : process
    begin
        clk_50M <= '0';
        wait for clk_period / 2;
        clk_50M <= '1';
        wait for clk_period / 2;
    end process clk_process;

    vent_process : process
    begin
        in_freq_anemometre <= '1';
        wait for periode_vent / 2;
        in_freq_anemometre <= '0';
        wait for periode_vent / 2;
    end process vent_process;

    stim_process : process
    begin
        report "--- 0 s : repos, vent a 47 Hz ---";
        wait for seconde;

        report "--- 1 s : monocoup, start_stop a 1 ---";
        start_stop <= '1';
        wait for 3 * seconde / 2;

        report "--- 2,5 s : passage en continu sans relacher, vent a 120 Hz ---";
        continu      <= '1';
        periode_vent <= seconde / 120;
        wait for 2 * seconde;

        report "--- 4,5 s : le vent tombe a 30 Hz ---";
        periode_vent <= seconde / 30;
        wait for 2 * seconde;

        report "--- 6,5 s : sortie du mode continu ---";
        continu <= '0';
        wait for 3 * seconde / 2;

        report "--- 8 s : acquittement, start_stop a 0 ---";
        start_stop <= '0';
        wait for seconde;

        report "--- 9 s : reset ---";
        raz_n <= '0';
        wait for seconde / 10;
        raz_n <= '1';
        wait for 9 * seconde / 10;

        report "--- 10 s : fin de la simulation ---";
        wait;
    end process stim_process;

    affichage : process(data_valid, data_anemometre)
    begin
        if (now > 0 ns) then
            report "data_valid = " & std_logic'image(data_valid) &
                   "   data_anemometre = " & integer'image(conv_integer(data_anemometre));
        end if;
    end process affichage;

end behavior;
