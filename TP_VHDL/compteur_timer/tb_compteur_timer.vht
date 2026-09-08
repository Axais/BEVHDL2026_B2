library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_compteur_timer is
end tb_compteur_timer;

architecture behavior of tb_compteur_timer is

    constant clk_period    : time    := 20 ns;
    constant max_timer_sim : natural := 1000000;

    signal clk    : std_logic := '0';
    signal rst    : std_logic := '0';
    signal bouton : std_logic := '1';
    signal led    : std_logic_vector(3 downto 0);

begin

    uut : entity work.compteur_timer
        generic map (
            max_timer => max_timer_sim
        )
        port map (
            clk    => clk,
            rst    => rst,
            bouton => bouton,
            led    => led
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
        report "--- Reset ---";
        rst    <= '0';
        bouton <= '1';
        wait for 1 ms;
        rst <= '1';
        wait for 1 ms;

        report "--- Scenario 1 : appui de 10 ms (< 20 ms) -> ne doit PAS compter ---";
        bouton <= '0';
        wait for 10 ms;
        bouton <= '1';
        wait for 5 ms;

        report "--- Scenario 2 : appui de 25 ms (> 20 ms) -> +1 ---";
        bouton <= '0';
        wait for 25 ms;
        bouton <= '1';
        wait for 5 ms;

        report "--- Scenario 3 : appui maintenu 40 ms -> +1 une seule fois ---";
        bouton <= '0';
        wait for 40 ms;
        bouton <= '1';
        wait for 5 ms;

        report "--- Scenario 4 : reset -> retour a 0 ---";
        rst <= '0';
        wait for 1 ms;
        rst <= '1';
        wait for 2 ms;

        report "--- Fin de la simulation ---";
        wait;
    end process stim_process;

    affichage : process(led)
    begin
        if (now > 0 ns) then
            report "led = " & integer'image(conv_integer(led));
        end if;
    end process affichage;

end behavior;
