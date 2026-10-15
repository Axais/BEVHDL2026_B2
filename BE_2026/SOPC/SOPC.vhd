library ieee;
use ieee.std_logic_1164.all;

entity SOPC is
    port (
        clk_50M : in  std_logic;
        raz_n   : in  std_logic;
        pwm_out : out std_logic;
        led     : out std_logic_vector(7 downto 0)
    );
end SOPC;

architecture Beh of SOPC is

    -- Noms a verifier dans Platform Designer : onglet Generation -> HDL Example
    component SOPC_nios is
        port (
            clk_clk       : in  std_logic;
            reset_reset_n : in  std_logic;

            avalon_pwm_0_pwm_pwm_out : out std_logic;

            avalon_anemometre_0_anemometre_in_freq_anemometre : in  std_logic;
            avalon_anemometre_0_anemometre_led                : out std_logic_vector(7 downto 0)
        );
    end component;

    signal boucle : std_logic;

begin

    -- Sorties
    pwm_out <= boucle;

    u_nios : SOPC_nios
        port map (
            clk_clk       => clk_50M,
            reset_reset_n => raz_n,

            avalon_pwm_0_pwm_pwm_out => boucle,

            avalon_anemometre_0_anemometre_in_freq_anemometre => boucle,
            avalon_anemometre_0_anemometre_led                => led
        );

end Beh;
