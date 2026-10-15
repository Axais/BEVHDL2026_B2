library ieee;
use ieee.std_logic_1164.all;

entity avalon_pwm is
    port (
        clk        : in  std_logic;
        reset_n    : in  std_logic;

        chipselect : in  std_logic;
        write_n    : in  std_logic;
        address    : in  std_logic_vector(1 downto 0);
        writedata  : in  std_logic_vector(31 downto 0);
        readdata   : out std_logic_vector(31 downto 0);

        pwm_out    : out std_logic
    );
end avalon_pwm;

architecture Beh of avalon_pwm is

    component pwm is
        port (
            clk     : in  std_logic;
            raz_n   : in  std_logic;
            enable  : in  std_logic;
            freq    : in  std_logic_vector(31 downto 0);
            duty    : in  std_logic_vector(31 downto 0);
            pwm_out : out std_logic
        );
    end component;

    signal freq    : std_logic_vector(31 downto 0) := (others => '0');
    signal duty    : std_logic_vector(31 downto 0) := (others => '0');
    signal control : std_logic_vector(1 downto 0)  := "00";

    signal raz_n    : std_logic;
    signal enable   : std_logic;
    signal ecriture : std_logic;

begin

    -- Partie combinatoire
    ecriture <= '1' when chipselect = '1' and write_n = '0' else '0';

    raz_n  <= reset_n and control(0);
    enable <= control(1);

    -- Partie sequentielle : ecriture des registres
    process(clk, reset_n)
    begin
        if (reset_n = '0') then
            freq    <= (others => '0');
            duty    <= (others => '0');
            control <= "00";

        elsif rising_edge(clk) then
            if (ecriture = '1') then
                case address is
                    when "00"   => freq    <= writedata;
                    when "01"   => duty    <= writedata;
                    when others => control <= writedata(1 downto 0);
                end case;
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

            case address is
                when "00"   => readdata              <= freq;
                when "01"   => readdata              <= duty;
                when others => readdata(1 downto 0)  <= control;
            end case;
        end if;
    end process;

    -- Sorties
    u_pwm : pwm
        port map (
            clk     => clk,
            raz_n   => raz_n,
            enable  => enable,
            freq    => freq,
            duty    => duty,
            pwm_out => pwm_out
        );

end Beh;
