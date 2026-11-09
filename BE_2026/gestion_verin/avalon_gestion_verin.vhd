library ieee;
use ieee.std_logic_1164.all;

entity avalon_gestion_verin is
    generic (
        max_1M    : natural := 50;
        max_100ms : natural := 100000
    );
    port (
        clk        : in  std_logic;
        reset_n    : in  std_logic;

        chipselect : in  std_logic;
        write_n    : in  std_logic;
        address    : in  std_logic_vector(2 downto 0);
        writedata  : in  std_logic_vector(31 downto 0);
        readdata   : out std_logic_vector(31 downto 0);

        data_in    : in  std_logic;
        out_pwm    : out std_logic;
        out_sens   : out std_logic;
        cs_n       : out std_logic;
        clk_adc    : out std_logic
    );
end avalon_gestion_verin;

architecture Beh of avalon_gestion_verin is

    component gestion_verin is
        generic (
            max_1M    : natural;
            max_100ms : natural
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
    end component;

    signal freq    : std_logic_vector(15 downto 0) := (others => '0');
    signal duty    : std_logic_vector(15 downto 0) := (others => '0');
    signal butee_g : std_logic_vector(15 downto 0) := (others => '0');
    signal butee_d : std_logic_vector(15 downto 0) := (others => '0');
    signal config  : std_logic_vector(2 downto 0)  := "000";

    signal raz_n        : std_logic;
    signal ecriture     : std_logic;
    signal angle_barre  : std_logic_vector(11 downto 0);
    signal fin_course_g : std_logic;
    signal fin_course_d : std_logic;

begin

    -- Partie combinatoire
    ecriture <= '1' when chipselect = '1' and write_n = '0' else '0';

    raz_n <= reset_n and config(0);

    -- Partie séquentielle
    process(clk, reset_n)
    begin
        if (reset_n = '0') then
            freq    <= (others => '0');
            duty    <= (others => '0');
            butee_g <= (others => '0');
            butee_d <= (others => '0');
            config  <= "000";

        elsif rising_edge(clk) then
            if (ecriture = '1') then
                case address is
                    when "000"  => freq    <= writedata(15 downto 0);
                    when "001"  => duty    <= writedata(15 downto 0);
                    when "010"  => butee_g <= writedata(15 downto 0);
                    when "011"  => butee_d <= writedata(15 downto 0);
                    when "100"  => config  <= writedata(2 downto 0);
                    when others => null;
                end case;
            end if;
        end if;
    end process;

    -- Partie séquentielle
    process(clk, reset_n)
    begin
        if (reset_n = '0') then
            readdata <= (others => '0');

        elsif rising_edge(clk) then
            readdata <= (others => '0');

            case address is
                when "000"  => readdata(15 downto 0) <= freq;
                when "001"  => readdata(15 downto 0) <= duty;
                when "010"  => readdata(15 downto 0) <= butee_g;
                when "011"  => readdata(15 downto 0) <= butee_d;
                when "100"  =>
                    readdata(2 downto 0) <= config;
                    readdata(3)          <= fin_course_d;
                    readdata(4)          <= fin_course_g;
                when "101"  => readdata(11 downto 0) <= angle_barre;
                when others => null;
            end case;
        end if;
    end process;

    -- Sorties
    u_verin : gestion_verin
        generic map (
            max_1M    => max_1M,
            max_100ms => max_100ms
        )
        port map (
            clk          => clk,
            raz_n        => raz_n,
            freq         => freq,
            duty         => duty,
            enable_pwm   => config(1),
            sens         => config(2),
            butee_g      => butee_g(11 downto 0),
            butee_d      => butee_d(11 downto 0),
            data_in      => data_in,
            out_pwm      => out_pwm,
            out_sens     => out_sens,
            cs_n         => cs_n,
            clk_adc      => clk_adc,
            angle_barre  => angle_barre,
            fin_course_g => fin_course_g,
            fin_course_d => fin_course_d
        );

end Beh;
