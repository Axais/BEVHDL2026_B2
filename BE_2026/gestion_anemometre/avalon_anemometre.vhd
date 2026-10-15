library ieee;
use ieee.std_logic_1164.all;

entity avalon_anemometre is
    generic (
        max_1s       : natural := 50000000;
        max_debounce : natural := 50000
    );
    port (
        clk        : in  std_logic;
        reset_n    : in  std_logic;

        chipselect : in  std_logic;
        write_n    : in  std_logic;
        address    : in  std_logic_vector(0 downto 0);
        writedata  : in  std_logic_vector(31 downto 0);
        readdata   : out std_logic_vector(31 downto 0);

        in_freq_anemometre : in  std_logic;
        led                : out std_logic_vector(7 downto 0)
    );
end avalon_anemometre;

architecture Beh of avalon_anemometre is

    component gestion_anemometre is
        generic (
            max_1s       : natural;
            max_debounce : natural
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
    end component;

    signal config : std_logic_vector(2 downto 0) := "000";

    signal raz_n      : std_logic;
    signal continu    : std_logic;
    signal start_stop : std_logic;

    signal data_valid      : std_logic;
    signal data_anemometre : std_logic_vector(7 downto 0);
    signal valid_memo      : std_logic := '0';

    signal ecriture : std_logic;
    signal lecture  : std_logic;

begin

    -- Partie combinatoire
    ecriture <= '1' when chipselect = '1' and write_n = '0' else '0';
    lecture  <= '1' when chipselect = '1' and write_n = '1' else '0';

    raz_n      <= reset_n and config(0);
    continu    <= config(1);
    start_stop <= config(2);

    -- Partie sequentielle : ecriture des registres
    process(clk, reset_n)
    begin
        if (reset_n = '0') then
            config <= "000";

        elsif rising_edge(clk) then
            if (ecriture = '1' and address = "0") then
                config <= writedata(2 downto 0);
            end if;
        end if;
    end process;

    -- Partie sequentielle : lecture des registres
    process(clk, reset_n)
    begin
        if (reset_n = '0') then
            readdata <= (others => '0');

        elsif rising_edge(clk) then
            readdata <= (others => '0');

            if (address = "0") then
                readdata(2 downto 0) <= config;
            else
                readdata(7 downto 0) <= data_anemometre;
                readdata(9)          <= valid_memo;
            end if;
        end if;
    end process;

    -- Partie sequentielle : memorisation de data_valid
    process(clk, reset_n)
    begin
        if (reset_n = '0') then
            valid_memo <= '0';

        elsif rising_edge(clk) then
            if (data_valid = '1') then
                valid_memo <= '1';
            elsif (lecture = '1' and address = "1") then
                valid_memo <= '0';
            end if;
        end if;
    end process;

    -- Sorties
    u_anemometre : gestion_anemometre
        generic map (
            max_1s       => max_1s,
            max_debounce => max_debounce
        )
        port map (
            clk_50M            => clk,
            raz_n              => raz_n,
            in_freq_anemometre => in_freq_anemometre,
            continu            => continu,
            start_stop         => start_stop,
            data_valid         => data_valid,
            data_anemometre    => data_anemometre,
            led                => led
        );

end Beh;
