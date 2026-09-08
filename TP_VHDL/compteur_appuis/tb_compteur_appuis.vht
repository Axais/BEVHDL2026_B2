library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_compteur_appuis is
end tb_compteur_appuis;

architecture behavior of tb_compteur_appuis is

    constant clk_period : time := 20 ns;

    signal clk    : std_logic := '0';
    signal rst    : std_logic := '0';
    signal bouton : std_logic := '1';
    signal led    : std_logic_vector(3 downto 0);

begin

    uut : entity work.compteur_appuis
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
        wait for 100 ns;
        rst <= '1';
        wait for 100 ns;

        report "--- Scenario 1 : neuf appuis propres -> led = 1 a 9 ---";
        for i in 1 to 9 loop
            bouton <= '0';
            wait for 60 ns;
            bouton <= '1';
            wait for 60 ns;
        end loop;

        report "--- Scenario 2 : dixieme appui -> rebouclage a 0 ---";
        bouton <= '0';
        wait for 60 ns;
        bouton <= '1';
        wait for 60 ns;

        report "--- Scenario 3 : un appui avec 5 rebonds -> 5 comptages ---";
        for i in 1 to 5 loop
            bouton <= '0';
            wait for 60 ns;
            bouton <= '1';
            wait for 60 ns;
        end loop;

        report "--- Scenario 4 : reset -> retour a 0 ---";
        rst <= '0';
        wait for 100 ns;
        rst <= '1';
        wait for 200 ns;

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
