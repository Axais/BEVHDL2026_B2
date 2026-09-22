library ieee;
use ieee.std_logic_1164.all;

entity pwm_moteur is
    generic (
        max              : natural := 1024;
        rapport_cyclique : natural := 500
    );
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        bouton   : in  std_logic;
        pwm_out  : out std_logic;
        sens_out : out std_logic
    );
end pwm_moteur;

architecture Beh of pwm_moteur is

    type state is (attente, appui);

    signal ep       : state;
    signal es       : state;
    signal compteur : natural range 0 to max - 1;
    signal sens     : std_logic := '0';

begin

    -- Partie séquentielle
    process(clk, rst)
    begin
        if (rst = '0') then
            ep       <= attente;
            compteur <= 0;
            sens     <= '0';

        elsif rising_edge(clk) then
            ep <= es;

            if (compteur = max - 1) then
                compteur <= 0;
            else
                compteur <= compteur + 1;
            end if;

            if (ep = attente and bouton = '0') then
                sens <= not sens;
            end if;
        end if;
    end process;

    -- Partie combinatoire
    process(ep, bouton)
    begin
        case ep is

            when attente =>
                if (bouton = '0') then
                    es <= appui;
                else
                    es <= attente;
                end if;

            when appui =>
                if (bouton = '1') then
                    es <= attente;
                else
                    es <= appui;
                end if;

        end case;
    end process;

    -- Sorties
    pwm_out  <= '1' when compteur < rapport_cyclique else '0';
    sens_out <= sens;

end Beh;
