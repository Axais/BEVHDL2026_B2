library ieee;
use ieee.std_logic_1164.all;

entity tb_pwm_moteur is
end tb_pwm_moteur;

architecture behavior of tb_pwm_moteur is

    constant clk_period  : time    := 20 ns;
    constant max_sim     : natural := 1024;
    constant periode_pwm : time    := 20480 ns;

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal bouton   : std_logic := '1';
    signal pwm_out  : std_logic;
    signal sens_out : std_logic;

begin

    uut : entity work.pwm_moteur
        generic map (
            max              => max_sim,
            rapport_cyclique => 500
        )
        port map (
            clk      => clk,
            rst      => rst,
            bouton   => bouton,
            pwm_out  => pwm_out,
            sens_out => sens_out
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
        report "--- Depart : sens 0, rapport cyclique 500 / 1024 ---";
        wait for 2 * periode_pwm;

        report "--- Appui 1 : le sens doit passer a 1 ---";
        bouton <= '0';
        wait for 200 ns;
        bouton <= '1';
        wait for 2 * periode_pwm - 200 ns;

        report "--- Appui 2 : le sens doit revenir a 0 ---";
        bouton <= '0';
        wait for 200 ns;
        bouton <= '1';
        wait for 2 * periode_pwm - 200 ns;

        report "--- Appui 3 : le sens doit repasser a 1 ---";
        bouton <= '0';
        wait for 200 ns;
        bouton <= '1';
        wait for 2 * periode_pwm - 200 ns;

        report "--- Appui maintenu 1 us : le sens ne doit basculer qu'une fois ---";
        bouton <= '0';
        wait for 1 us;
        bouton <= '1';
        wait for 2 * periode_pwm - 1 us;

        report "--- Reset : le sens doit revenir a 0 ---";
        rst <= '0';
        wait for 1 us;
        rst <= '1';
        wait for 2 * periode_pwm;

        report "--- Fin de la simulation ---";
        wait;
    end process stim_process;

    affichage : process(sens_out)
    begin
        if (now > 0 ns) then
            report "sens_out = " & std_logic'image(sens_out);
        end if;
    end process affichage;

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
