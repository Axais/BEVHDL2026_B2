library ieee;
use ieee.std_logic_1164.all;

entity tb_decalage_droite is
end tb_decalage_droite;

architecture behavior of tb_decalage_droite is

    constant clk_period : time    := 20 ns;
    constant max_sim    : natural := 5;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal led : std_logic_vector(3 downto 0);

    function vect_to_string(v : std_logic_vector) return string is
        variable r : string(1 to v'length);
        variable k : integer := 1;
    begin
        for i in v'range loop
            case v(i) is
                when '0'    => r(k) := '0';
                when '1'    => r(k) := '1';
                when others => r(k) := 'X';
            end case;
            k := k + 1;
        end loop;
        return r;
    end function;

begin

    uut : entity work.decalage_droite
        generic map (
            max => max_sim
        )
        port map (
            clk => clk,
            rst => rst,
            led => led
        );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process clk_process;

    stim_process : process
    begin
        report "--- Reset : led doit valoir 1000 ---";
        rst <= '0';
        wait for 100 ns;
        rst <= '1';

        report "--- Deux tours d'anneau : 1000 0100 0010 0001 ... ---";
        wait for 1100 ns;

        report "--- Reset en cours de rotation : retour a 1000 ---";
        rst <= '0';
        wait for 100 ns;
        rst <= '1';
        wait for 400 ns;

        report "--- Fin de la simulation ---";
        wait;
    end process stim_process;

    affichage : process(led)
    begin
        if (now > 0 ns) then
            report "led = " & vect_to_string(led);
        end if;
    end process affichage;

end behavior;
