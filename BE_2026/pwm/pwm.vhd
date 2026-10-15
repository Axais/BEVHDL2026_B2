library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pwm is
    port (
        clk     : in  std_logic;
        raz_n   : in  std_logic;
        enable  : in  std_logic;
        freq    : in  std_logic_vector(31 downto 0);
        duty    : in  std_logic_vector(31 downto 0);
        pwm_out : out std_logic
    );
end pwm;

architecture Beh of pwm is

    signal compteur : std_logic_vector(31 downto 0) := (others => '0');
    signal sortie   : std_logic := '0';

begin

    -- Partie sequentielle
    process(clk, raz_n)
    begin
        if (raz_n = '0') then
            compteur <= (others => '0');
            sortie   <= '0';

        elsif rising_edge(clk) then
            if (enable = '0' or freq = 0) then
                compteur <= (others => '0');
                sortie   <= '0';
            else
                if (compteur >= freq - 1) then
                    compteur <= (others => '0');
                else
                    compteur <= compteur + 1;
                end if;

                if (compteur < duty) then
                    sortie <= '1';
                else
                    sortie <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Sorties
    pwm_out <= sortie;

end Beh;
