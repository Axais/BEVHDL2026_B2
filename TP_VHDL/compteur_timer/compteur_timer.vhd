library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity compteur_timer is
    generic (
        max_timer : natural := 1000000
    );
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        bouton : in  std_logic;
        led    : out std_logic_vector(3 downto 0)
    );
end compteur_timer;

architecture Beh of compteur_timer is

    type state is (attente, tempo, compte, relachement);

    signal ep        : state;
    signal es        : state;
    signal timer     : natural range 0 to max_timer := 0;
    signal fin_timer : std_logic;
    signal go_compte : std_logic;
    signal compteur  : std_logic_vector(3 downto 0);

begin

    fin_timer <= '1' when timer = max_timer else '0';

    -- Partie séquentielle
    process(clk, rst)
    begin
        if (rst = '0') then
            ep       <= attente;
            timer    <= 0;
            compteur <= "0000";

        elsif rising_edge(clk) then
            ep <= es;

            if (ep = tempo) then
                if (timer < max_timer) then
                    timer <= timer + 1;
                end if;
            else
                timer <= 0;
            end if;

            if (go_compte = '1') then
                compteur <= compteur + 1;
            end if;
        end if;
    end process;

    -- Partie combinatoire
    process(ep, bouton, fin_timer)
    begin
        case ep is

            when attente =>
                if (bouton = '0') then
                    es <= tempo;
                else
                    es <= attente;
                end if;

            when tempo =>
                if (bouton = '1') then
                    es <= attente;
                elsif (fin_timer = '1') then
                    es <= compte;
                else
                    es <= tempo;
                end if;

            when compte =>
                es <= relachement;

            when relachement =>
                if (bouton = '1') then
                    es <= attente;
                else
                    es <= relachement;
                end if;

        end case;
    end process;

    -- Sorties
    process(ep)
    begin
        case ep is
            when compte => go_compte <= '1';
            when others => go_compte <= '0';
        end case;
    end process;

    led <= compteur;

end Beh;
