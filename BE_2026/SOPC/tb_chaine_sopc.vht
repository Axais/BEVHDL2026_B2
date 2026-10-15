library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity tb_chaine_sopc is
end tb_chaine_sopc;

architecture behavior of tb_chaine_sopc is

    constant clk_period : time    := 20 ns;
    constant max_sim    : natural := 1000;
    constant seconde    : time    := max_sim * clk_period;

    signal clk     : std_logic := '0';
    signal reset_n : std_logic := '0';

    signal cs_pwm    : std_logic := '0';
    signal wr_n_pwm  : std_logic := '1';
    signal adr_pwm   : std_logic_vector(1 downto 0)  := "00";
    signal wd_pwm    : std_logic_vector(31 downto 0) := (others => '0');
    signal rd_pwm    : std_logic_vector(31 downto 0);

    signal cs_ane    : std_logic := '0';
    signal wr_n_ane  : std_logic := '1';
    signal adr_ane   : std_logic_vector(0 downto 0)  := "0";
    signal wd_ane    : std_logic_vector(31 downto 0) := (others => '0');
    signal rd_ane    : std_logic_vector(31 downto 0);

    signal boucle : std_logic;
    signal led    : std_logic_vector(7 downto 0);

begin

    u_pwm : entity work.avalon_pwm
        port map (clk, reset_n, cs_pwm, wr_n_pwm, adr_pwm, wd_pwm, rd_pwm, boucle);

    u_ane : entity work.avalon_anemometre
        generic map (max_1s => max_sim, max_debounce => 2)
        port map (clk, reset_n, cs_ane, wr_n_ane, adr_ane, wd_ane, rd_ane, boucle, led);

    clk <= not clk after clk_period / 2;

    stimulus : process

        procedure ecrire_pwm(adr : in std_logic_vector(1 downto 0);
                             val : in integer) is
        begin
            wait until rising_edge(clk);
            adr_pwm  <= adr;
            wd_pwm   <= conv_std_logic_vector(val, 32);
            cs_pwm   <= '1';
            wr_n_pwm <= '0';
            wait until rising_edge(clk);
            cs_pwm   <= '0';
            wr_n_pwm <= '1';
        end procedure;

        procedure ecrire_ane(val : in integer) is
        begin
            wait until rising_edge(clk);
            adr_ane  <= "0";
            wd_ane   <= conv_std_logic_vector(val, 32);
            cs_ane   <= '1';
            wr_n_ane <= '0';
            wait until rising_edge(clk);
            cs_ane   <= '0';
            wr_n_ane <= '1';
        end procedure;

        procedure lire_ane is
        begin
            wait until rising_edge(clk);
            adr_ane  <= "1";
            cs_ane   <= '1';
            wr_n_ane <= '1';
            wait until rising_edge(clk);
            cs_ane   <= '0';
            wait until rising_edge(clk);
        end procedure;

        procedure essai(consigne : in integer) is
            variable periode : integer;
        begin
            periode := max_sim / consigne;
            ecrire_pwm("00", periode);
            ecrire_pwm("01", periode / 2);
            ecrire_pwm("10", 3);
            wait for 2 * seconde + seconde / 4;
            lire_ane;
            report "consigne " & integer'image(consigne) &
                   "  ->  mesure " & integer'image(conv_integer(rd_ane(7 downto 0))) &
                   "   valid = " & std_logic'image(rd_ane(9));
        end procedure;

    begin
        reset_n <= '0';
        wait for 5 * clk_period;
        reset_n <= '1';

        ecrire_ane(3);
        report "anemometre : raz_n = 1, mode continu";

        essai(10);
        essai(25);
        essai(50);
        essai(100);
        essai(200);
        essai(250);

        ecrire_pwm("10", 1);
        wait for 2 * seconde;
        lire_ane;
        report "PWM arrete       ->  mesure " &
               integer'image(conv_integer(rd_ane(7 downto 0)));

        report "fin de simulation";
        wait;
    end process;

end behavior;
