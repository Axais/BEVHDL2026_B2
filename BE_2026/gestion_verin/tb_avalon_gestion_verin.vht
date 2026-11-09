library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity tb_avalon_gestion_verin is
end tb_avalon_gestion_verin;

architecture behavior of tb_avalon_gestion_verin is

    constant clk_period : time    := 20 ns;
    constant max_sim    : natural := 100000;

    signal clk        : std_logic := '0';
    signal reset_n    : std_logic := '0';
    signal chipselect : std_logic := '0';
    signal write_n    : std_logic := '1';
    signal address    : std_logic_vector(2 downto 0)  := "000";
    signal writedata  : std_logic_vector(31 downto 0) := (others => '0');
    signal readdata   : std_logic_vector(31 downto 0);
    signal data_in    : std_logic := 'Z';
    signal out_pwm    : std_logic;
    signal out_sens   : std_logic;
    signal cs_n       : std_logic;
    signal clk_adc    : std_logic;

    signal valeur_adc : std_logic_vector(11 downto 0) := conv_std_logic_vector(800, 12);

begin

    uut : entity work.avalon_gestion_verin
        generic map (
            max_100ms => max_sim
        )
        port map (
            clk        => clk,
            reset_n    => reset_n,
            chipselect => chipselect,
            write_n    => write_n,
            address    => address,
            writedata  => writedata,
            readdata   => readdata,
            data_in    => data_in,
            out_pwm    => out_pwm,
            out_sens   => out_sens,
            cs_n       => cs_n,
            clk_adc    => clk_adc
        );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process clk_process;

    mcp3201 : process
    begin
        data_in <= 'Z';
        wait until cs_n = '0';
        wait until falling_edge(clk_adc);
        wait until falling_edge(clk_adc);
        data_in <= '0';
        for i in 11 downto 0 loop
            wait until falling_edge(clk_adc);
            data_in <= valeur_adc(i);
        end loop;
        wait until cs_n = '1';
    end process mcp3201;

    stim_process : process

        procedure ecrire(adr : in integer; val : in integer) is
        begin
            wait until rising_edge(clk);
            address    <= conv_std_logic_vector(adr, 3);
            writedata  <= conv_std_logic_vector(val, 32);
            chipselect <= '1';
            write_n    <= '0';
            wait until rising_edge(clk);
            chipselect <= '0';
            write_n    <= '1';
        end procedure;

        procedure lire(adr : in integer; nom : in string) is
        begin
            wait until rising_edge(clk);
            address    <= conv_std_logic_vector(adr, 3);
            chipselect <= '1';
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            chipselect <= '0';
            report nom & " = " & integer'image(conv_integer(readdata(30 downto 0)));
        end procedure;

    begin
        wait for 5 * clk_period;
        reset_n <= '1';

        report "--- ecriture comme le programme exemple du prof (config = 1 : PWM inactif) ---";
        ecrire(0, 2000);
        ecrire(1, 1500);
        ecrire(2, 410);
        ecrire(3, 1320);
        ecrire(4, 1);

        report "--- relecture des 6 registres ---";
        lire(0, "freq");
        lire(1, "duty");
        lire(2, "butee_g");
        lire(3, "butee_d");
        lire(4, "config");
        lire(5, "angle_barre");

        report "--- config = 7 : PWM actif, sens droite ---";
        ecrire(4, 7);
        wait for 1 ms;
        if (out_pwm'last_event < 1 ms) then
            report "    out_pwm actif, out_sens = " & std_logic'image(out_sens);
        else
            report "    out_pwm bloque a 0";
        end if;

        report "--- apres la premiere conversion (100 ms) ---";
        wait until cs_n = '0';
        wait until cs_n = '1';
        wait for 1 us;
        lire(4, "config");
        lire(5, "angle_barre");

        report "--- fin de la simulation ---";
        wait;
    end process stim_process;

end behavior;
