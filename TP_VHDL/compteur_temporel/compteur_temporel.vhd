library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity compteur_temporel is
    generic (
        max : natural := 50000000
    );
    port (
        clk : in  std_logic;
        rst : in  std_logic;
        led : out std_logic_vector(3 downto 0)
    );
end compteur_temporel;

architecture Beh of compteur_temporel is

    signal compteur : std_logic_vector(3 downto 0);

begin

    -- Partie séquentielle
    process(clk, rst)
        variable temp : integer range 0 to max;
    begin
        if (rst = '0') then
            temp     := 0;
            compteur <= "0000";
            led      <= "0000";

        elsif rising_edge(clk) then
            temp := temp + 1;

            if (temp = max) then
                temp     := 0;
                compteur <= compteur + 1;

                if (compteur = "1001") then
                    compteur <= "0000";
                end if;
            end if;

            led <= compteur;
        end if;
    end process;

end Beh;
