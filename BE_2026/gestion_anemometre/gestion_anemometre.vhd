library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity gestion_anemometre is
    generic (
        max_1s       : natural := 50000000;
        max_debounce : natural := 50000     -- ~1ms à 50MHz pour filtrer les rebonds
    );
    port (
        clk_50M            : in  std_logic;
        raz_n              : in  std_logic;
        in_freq_anemometre : in  std_logic;
        continu            : in  std_logic;
        start_stop         : in  std_logic;
        data_valid         : out std_logic;
        data_anemometre    : out std_logic_vector(7 downto 0);
        led                : out std_logic_vector(7 downto 0)
    );
end gestion_anemometre;

architecture Beh of gestion_anemometre is

    type state is (attente, mesure, fin, attente_acq);

    signal ep : state := attente;
    signal es : state := attente;
    
    signal timer    : natural range 0 to max_1s := 0;
    signal tim_1s   : std_logic;
    signal compte   : std_logic;
    signal charge   : std_logic;
    
    -- Nouveaux signaux pour synchronisation et anti-rebond
    signal sync1, sync2 : std_logic := '0';
    signal debounced    : std_logic := '0';
    signal debounce_cnt : natural range 0 to max_debounce := 0;
    
    signal avant    : std_logic := '0';
    signal front    : std_logic;
    
    signal compteur : std_logic_vector(7 downto 0) := "00000000";
    signal registre : std_logic_vector(7 downto 0) := "00000000";
    signal valid    : std_logic := '0';

begin

    tim_1s <= '1' when timer = max_1s - 1 else '0';
    compte <= '1' when ep = mesure else '0';
    charge <= '1' when ep = fin else '0';
    
    -- Le front est maintenant détecté uniquement sur le signal filtré et synchrone
    front  <= '1' when avant = '0' and debounced = '1' else '0';

    -- Partie séquentielle
    process(clk_50M, raz_n)
    begin
        if (raz_n = '0') then
            ep           <= attente;
            timer        <= 0;
            avant        <= '0';
            compteur     <= "00000000";
            registre     <= "00000000";
            valid        <= '0';
            sync1        <= '0';
            sync2        <= '0';
            debounced    <= '0';
            debounce_cnt <= 0;

        elsif rising_edge(clk_50M) then
            -- 1. Synchronisation (2 bascules pour éviter la métastabilité)
            sync1 <= in_freq_anemometre;
            sync2 <= sync1;

            -- 2. Filtre anti-rebond
            if (sync2 = debounced) then
                debounce_cnt <= 0;
            else
                debounce_cnt <= debounce_cnt + 1;
                if (debounce_cnt = max_debounce - 1) then
                    debounced <= sync2;
                    debounce_cnt <= 0;
                end if;
            end if;

            -- 3. Mise à jour de l'état précédent pour la détection de front
            avant <= debounced;

            -- 4. Machine d'état et Compteurs
            ep <= es;

            if (compte = '0') then
                timer    <= 0;
                compteur <= "00000000";
            else
                if (tim_1s = '1') then
                    timer <= 0;
                else
                    timer <= timer + 1;
                end if;
                
                if (front = '1' and compteur /= "11111111") then
                    compteur <= compteur + 1;
                end if;
            end if;

            if (charge = '1') then
                registre <= compteur;
                valid    <= '1';
            elsif (compte = '1') then
                valid <= '0';
            end if;

            if (continu = '0' and start_stop = '0') then
                valid <= '0';
            end if;
        end if;
    end process;

    -- Partie combinatoire (Inchangée)
    process(ep, continu, start_stop, tim_1s)
    begin
        case ep is
            when attente =>
                if (continu = '1' or start_stop = '1') then
                    es <= mesure;
                else
                    es <= attente;
                end if;

            when mesure =>
                if (tim_1s = '1') then
                    es <= fin;
                else
                    es <= mesure;
                end if;

            when fin =>
                if (continu = '1') then
                    es <= mesure;
                else
                    es <= attente_acq;
                end if;

            when attente_acq =>
                if (continu = '1') then
                    es <= mesure;
                elsif (start_stop = '0') then
                    es <= attente;
                else
                    es <= attente_acq;
                end if;
        end case;
    end process;

    -- Sorties
    data_anemometre <= registre;
    data_valid      <= valid;
    led             <= registre;

end Beh;
