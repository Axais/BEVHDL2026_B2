library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


entity pwm is
    generic (
        max              : natural := 1024;
        rapport_cyclique : natural := 750
    );
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        pwm_out : out std_logic
    );
end pwm;

architecture Beh of pwm is

    signal compteur : natural range 0 to max - 1;

begin

    process(clk, rst)
    begin
        if (rst = '0') then
            compteur <= 0;

        elsif rising_edge(clk) then
            if (compteur = max - 1) then -- car la valeur du signal est màj en fin d'archi
                compteur <= 0;
            else
                compteur <= compteur + 1;
            end if;
        end if;
    end process;

    pwm_out <= '1' when compteur < rapport_cyclique else '0';

end Beh;
