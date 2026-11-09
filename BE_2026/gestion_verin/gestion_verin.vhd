library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity gestion_verin is
    generic (
        max_1M    : natural := 50;
        max_100ms : natural := 100000
    );
    port (
        clk          : in  std_logic;
        raz_n        : in  std_logic;
        freq         : in  std_logic_vector(15 downto 0);
        duty         : in  std_logic_vector(15 downto 0);
        enable_pwm   : in  std_logic;
        sens         : in  std_logic;
        butee_g      : in  std_logic_vector(11 downto 0);
        butee_d      : in  std_logic_vector(11 downto 0);
        data_in      : in  std_logic;
        out_pwm      : out std_logic;
        out_sens     : out std_logic;
        cs_n         : out std_logic;
        clk_adc      : out std_logic;
        angle_barre  : out std_logic_vector(11 downto 0);
        fin_course_g : out std_logic;
        fin_course_d : out std_logic
    );
end gestion_verin;

architecture Beh of gestion_verin is

    type state is (repos, lecture, fin);

    signal ep : state := repos;

    signal compteur : std_logic_vector(15 downto 0) := (others => '0');
    signal pwm      : std_logic := '0';

    signal fin_g  : std_logic;
    signal fin_d  : std_logic;
    signal moteur : std_logic;

    signal cpt_1M     : natural range 0 to max_1M - 1 := 0;
    signal top_1M     : std_logic := '0';
    signal cpt_100ms  : natural range 0 to max_100ms - 1 := 0;
    signal start_conv : std_logic := '0';
    signal horloge    : std_logic := '0';
    signal nb_fronts  : natural range 0 to 15 := 0;
    signal registre   : std_logic_vector(11 downto 0) := (others => '0');
    signal angle      : std_logic_vector(11 downto 0) := (others => '0');

begin

    -- Partie séquentielle
    process(clk, raz_n)
    begin
        if (raz_n = '0') then
            compteur <= (others => '0');
            pwm      <= '0';

        elsif rising_edge(clk) then
            if (enable_pwm = '0' or freq = 0) then
                compteur <= (others => '0');
                pwm      <= '0';
            else
                if (compteur >= freq - 1) then
                    compteur <= (others => '0');
                else
                    compteur <= compteur + 1;
                end if;

                if (compteur < duty) then
                    pwm <= '1';
                else
                    pwm <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Partie combinatoire
    process(angle, butee_g, butee_d, sens, pwm)
    begin
        if (angle <= butee_g) then
            fin_g <= '1';
        else
            fin_g <= '0';
        end if;

        if (angle >= butee_d) then
            fin_d <= '1';
        else
            fin_d <= '0';
        end if;

        if ((sens = '0' and angle <= butee_g) or (sens = '1' and angle >= butee_d)) then
            moteur <= '0';
        else
            moteur <= pwm;
        end if;
    end process;

    -- Partie séquentielle
    process(clk, raz_n)
    begin
        if (raz_n = '0') then
            cpt_1M     <= 0;
            top_1M     <= '0';
            cpt_100ms  <= 0;
            start_conv <= '0';
            ep         <= repos;
            horloge    <= '0';
            nb_fronts  <= 0;
            registre   <= (others => '0');
            angle      <= (others => '0');

        elsif rising_edge(clk) then
            if (cpt_1M = max_1M - 1) then
                cpt_1M <= 0;
                top_1M <= '1';
            else
                cpt_1M <= cpt_1M + 1;
                top_1M <= '0';
            end if;

            start_conv <= '0';
            if (top_1M = '1') then
                if (cpt_100ms = max_100ms - 1) then
                    cpt_100ms  <= 0;
                    start_conv <= '1';
                else
                    cpt_100ms <= cpt_100ms + 1;
                end if;
            end if;

            case ep is
                when repos =>
                    horloge   <= '0';
                    nb_fronts <= 0;
                    if (start_conv = '1') then
                        ep <= lecture;
                    end if;

                when lecture =>
                    if (top_1M = '1') then
                        if (horloge = '0') then
                            horloge   <= '1';
                            registre  <= registre(10 downto 0) & data_in;
                            nb_fronts <= nb_fronts + 1;
                        else
                            horloge <= '0';
                            if (nb_fronts = 15) then
                                ep <= fin;
                            end if;
                        end if;
                    end if;

                when fin =>
                    angle <= registre;
                    ep    <= repos;
            end case;
        end if;
    end process;

    -- Sorties
    out_pwm      <= moteur;
    out_sens     <= sens;
    cs_n         <= '0' when ep = lecture else '1';
    clk_adc      <= horloge;
    angle_barre  <= angle;
    fin_course_g <= fin_g;
    fin_course_d <= fin_d;

end Beh;
