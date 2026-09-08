library ieee;
use ieee.std_logic_1164.all;

entity decalage_droite is
    generic (
        max : natural := 25000000
    );
    port (
        clk : in  std_logic;
        rst : in  std_logic;
        led : out std_logic_vector(3 downto 0)
    );
end decalage_droite;

architecture Beh of decalage_droite is

    signal registre : std_logic_vector(3 downto 0);

begin

    -- Partie séquentielle
    process(clk, rst)
        variable temp : integer range 0 to max;
    begin
        if (rst = '0') then
            registre <= "1000";
            temp     := 0;

        elsif rising_edge(clk) then
            if (temp = max) then
                temp     := 0;
                registre <= registre(0) & registre(3 downto 1);
            else
                temp := temp + 1;
            end if;
        end if;
    end process;

    -- Sorties
    led <= registre;

end Beh;
