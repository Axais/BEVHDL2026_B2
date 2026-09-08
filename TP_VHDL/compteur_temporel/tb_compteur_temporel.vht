library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_compteur_temporel is
end tb_compteur_temporel;

architecture behavior of tb_compteur_temporel is

    constant clk_period : time    := 20 ns;
    constant max_sim    : natural := 50000000;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal led : std_logic_vector(3 downto 0);

begin

    uut : entity work.compteur_temporel
        generic map (
            max => max_sim
        )
        port map (
            clk => clk,
            rst => rst,
            led => led
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
        rst <= '0';
        wait for 100 ms;
        rst <= '1';

        report "--- Comptage : une incrementation par seconde ---";
        wait for 3200 ms;

        report "--- Reset en cours de comptage ---";
        rst <= '0';
        wait for 100 ms;
        rst <= '1';
        wait for 200 ms;

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
