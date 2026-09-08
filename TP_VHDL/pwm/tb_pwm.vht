library ieee;
use ieee.std_logic_1164.all;

entity tb_pwm is
end tb_pwm;

architecture behavior of tb_pwm is

    constant clk_period : time    := 20 ns;
    constant max_sim    : natural := 1024;

    signal clk     : std_logic := '0';
    signal rst     : std_logic := '1';
    signal pwm_25  : std_logic;
    signal pwm_50  : std_logic;
    signal pwm_75  : std_logic;

begin

    uut_25 : entity work.pwm
        generic map (
            max              => max_sim,
            rapport_cyclique => 256
        )
        port map (
            clk     => clk,
            rst     => rst,
            pwm_out => pwm_25
        );

    uut_50 : entity work.pwm
        generic map (
            max              => max_sim,
            rapport_cyclique => 512
        )
        port map (
            clk     => clk,
            rst     => rst,
            pwm_out => pwm_50
        );

    uut_75 : entity work.pwm
        generic map (
            max              => max_sim,
            rapport_cyclique => 768
        )
        port map (
            clk     => clk,
            rst     => rst,
            pwm_out => pwm_75
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
        report "--- Quatre periodes PWM : rapports 25, 50 et 75 pour cent ---";
        wait for 81920 ns;

        report "--- Reset en cours de periode ---";
        rst <= '0';
        wait for 1 us;
        rst <= '1';
        wait for 21 us;

        report "--- Fin de la simulation ---";
        wait;
    end process stim_process;

    affichage : process(pwm_25, pwm_50, pwm_75)
    begin
        if (now > 0 ns) then
            report "pwm 25% = " & std_logic'image(pwm_25) &
                   "   pwm 50% = " & std_logic'image(pwm_50) &
                   "   pwm 75% = " & std_logic'image(pwm_75);
        end if;
    end process affichage;

end behavior;
