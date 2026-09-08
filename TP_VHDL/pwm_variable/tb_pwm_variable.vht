library ieee;
use ieee.std_logic_1164.all;

entity tb_pwm_variable is
end tb_pwm_variable;

architecture behavior of tb_pwm_variable is

    constant clk_period  : time    := 20 ns;
    constant max_sim     : natural := 1024;
    constant periode_pwm : time    := 20480 ns;

    signal clk     : std_logic := '0';
    signal rst     : std_logic := '1';
    signal bouton  : std_logic := '1';
    signal pwm_out : std_logic;

begin

    uut : entity work.pwm_variable
        generic map (
            max         => max_sim,
            pas         => 250,
            rapport_max => 1000
        )
        port map (
            clk     => clk,
            rst     => rst,
            bouton  => bouton,
            pwm_out => pwm_out
        );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process clk_process;

    stim_process : process
    begin
        report "--- Depart : rapport cyclique 0 / 1024, sortie toujours a 0 ---";
        wait for 2 * periode_pwm;

        report "--- Appui 1 : rapport cyclique 250 / 1024 ---";
        bouton <= '0';
        wait for 200 ns;
        bouton <= '1';
        wait for 2 * periode_pwm - 200 ns;

        report "--- Appui 2 : rapport cyclique 500 / 1024 ---";
        bouton <= '0';
        wait for 200 ns;
        bouton <= '1';
        wait for 2 * periode_pwm - 200 ns;

        report "--- Appui 3 : rapport cyclique 750 / 1024 ---";
        bouton <= '0';
        wait for 200 ns;
        bouton <= '1';
        wait for 2 * periode_pwm - 200 ns;

        report "--- Appui 4 : rapport cyclique 1000 / 1024 ---";
        bouton <= '0';
        wait for 200 ns;
        bouton <= '1';
        wait for 2 * periode_pwm - 200 ns;

        report "--- Appui 5 : rebouclage a 0 / 1024 ---";
        bouton <= '0';
        wait for 200 ns;
        bouton <= '1';
        wait for 2 * periode_pwm - 200 ns;

        report "--- Appui 6 : retour a 250 / 1024 ---";
        bouton <= '0';
        wait for 200 ns;
        bouton <= '1';
        wait for 2 * periode_pwm - 200 ns;

        report "--- Fin de la simulation ---";
        wait;
    end process stim_process;

    mesure_process : process
        variable nb_haut : natural;
    begin
        nb_haut := 0;
        for i in 1 to max_sim loop
            wait until rising_edge(clk);
            if (pwm_out = '1') then
                nb_haut := nb_haut + 1;
            end if;
        end loop;
        report "rapport cyclique mesure = " & integer'image(nb_haut) & " / 1024";
    end process mesure_process;

end behavior;
