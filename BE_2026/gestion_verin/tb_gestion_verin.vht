library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity tb_gestion_verin is
end tb_gestion_verin;

architecture behavior of tb_gestion_verin is

    constant clk_period : time    := 20 ns;
    constant max_sim    : natural := 100000;

    signal clk          : std_logic := '0';
    signal raz_n        : std_logic := '0';
    signal freq         : std_logic_vector(15 downto 0) := (others => '0');
    signal duty         : std_logic_vector(15 downto 0) := (others => '0');
    signal enable_pwm   : std_logic := '0';
    signal sens         : std_logic := '0';
    signal butee_g      : std_logic_vector(11 downto 0) := (others => '0');
    signal butee_d      : std_logic_vector(11 downto 0) := (others => '0');
    signal data_in      : std_logic := 'Z';
    signal out_pwm      : std_logic;
    signal out_sens     : std_logic;
    signal cs_n         : std_logic;
    signal clk_adc      : std_logic;
    signal angle_barre  : std_logic_vector(11 downto 0);
    signal fin_course_g : std_logic;
    signal fin_course_d : std_logic;

    signal valeur_adc : std_logic_vector(11 downto 0) := conv_std_logic_vector(800, 12);

begin

    uut : entity work.gestion_verin
        generic map (
            max_100ms => max_sim
        )
        port map (
            clk          => clk,
            raz_n        => raz_n,
            freq         => freq,
            duty         => duty,
            enable_pwm   => enable_pwm,
            sens         => sens,
            butee_g      => butee_g,
            butee_d      => butee_d,
            data_in      => data_in,
            out_pwm      => out_pwm,
            out_sens     => out_sens,
            cs_n         => cs_n,
            clk_adc      => clk_adc,
            angle_barre  => angle_barre,
            fin_course_g => fin_course_g,
            fin_course_d => fin_course_d
        );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process clk_process;

    mcp3201 : process
    begin
        data_in <= 'Z';
        wait until cs_n = '0';
        wait until falling_edge(clk_adc);
        wait until falling_edge(clk_adc);
        data_in <= '0';
        for i in 11 downto 0 loop
            wait until falling_edge(clk_adc);
            data_in <= valeur_adc(i);
        end loop;
        wait until cs_n = '1';
    end process mcp3201;

    stim_process : process

        procedure etat_pwm is
        begin
            wait for 1 ms;
            if (out_pwm'last_event < 1 ms) then
                report "    out_pwm actif";
            else
                report "    out_pwm bloque a 0";
            end if;
        end procedure;

    begin
        report "--- 0 ms : PWM 25 kHz a 50 %, sens droite, butees 410 et 1320, barre a 800 ---";
        freq       <= conv_std_logic_vector(2000, 16);
        duty       <= conv_std_logic_vector(1000, 16);
        enable_pwm <= '1';
        sens       <= '1';
        butee_g    <= conv_std_logic_vector(410, 12);
        butee_d    <= conv_std_logic_vector(1320, 12);
        wait for 1 us;
        raz_n <= '1';
        wait for 199 us;

        report "--- 0,2 ms : rapport cyclique 25 % ---";
        duty <= conv_std_logic_vector(500, 16);
        wait for 200 us;

        report "--- 0,4 ms : enable_pwm a 0 ---";
        enable_pwm <= '0';
        etat_pwm;
        enable_pwm <= '1';
        etat_pwm;

        wait until fin_course_g = '0';
        wait for 10 ms;

        report "--- 110 ms : la barre passe a 1500, au-dela de la butee droite ---";
        valeur_adc <= conv_std_logic_vector(1500, 12);
        wait until fin_course_d = '1';
        etat_pwm;

        report "--- sens gauche : le moteur peut repartir ---";
        sens <= '0';
        etat_pwm;
        wait for 10 ms;

        report "--- la barre passe a 300, au-dela de la butee gauche ---";
        valeur_adc <= conv_std_logic_vector(300, 12);
        wait until fin_course_g = '1';
        etat_pwm;

        report "--- sens droite : le moteur peut repartir ---";
        sens <= '1';
        etat_pwm;

        report "--- fin de la simulation ---";
        wait;
    end process stim_process;

    affichage : process
    begin
        wait on angle_barre;
        wait for clk_period;
        report "angle_barre = " & integer'image(conv_integer(angle_barre)) &
               "   fin_course_g = " & std_logic'image(fin_course_g) &
               "   fin_course_d = " & std_logic'image(fin_course_d);
    end process affichage;

end behavior;
