library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity compteur_appuis is
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        bouton : in  std_logic;
        led    : out std_logic_vector(3 downto 0)
    );
end compteur_appuis;

architecture Beh of compteur_appuis is

    type state is (machine, comptage);

    signal ep       : state;
    signal es       : state;
    signal compteur : std_logic_vector(3 downto 0);

begin

    -- Partie séquentielle
    process(clk, rst)
    begin
        if (rst = '0') then
            ep       <= machine;
            compteur <= "0000";

        elsif rising_edge(clk) then
            ep <= es;

            if (ep = machine and bouton = '0') then
                if (compteur = "1001") then
                    compteur <= "0000";
                else
                    compteur <= compteur + 1;
                end if;
            end if;
        end if;
    end process;

    -- Partie combinatoire
    process(ep, bouton)
    begin
        case ep is

            when machine =>
                if (bouton = '0') then
                    es <= comptage;
                else
                    es <= machine;
                end if;

            when comptage =>
                if (bouton = '1') then
                    es <= machine;
                else
                    es <= comptage;
                end if;

        end case;
    end process;

    -- Sorties
    led <= compteur;

end Beh;
