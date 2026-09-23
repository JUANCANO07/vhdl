library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    generic (
        FREQ_CLK : integer := 100_000_000  
    );
    port (
        clk              : in  std_logic;                     
        rst              : in  std_logic;                     
        sensor           : in  std_logic;                    
        boton_reset_n    : in  std_logic;                     
        led_felicitacion : out std_logic;                     
        led_alarma       : out std_logic;                     
        seg_dec          : out std_logic_vector(6 downto 0);  
        seg_uni          : out std_logic_vector(6 downto 0)   
    );
end top;

architecture Structural of top is

    component divisor
        generic ( FREQ_CLK : integer := 100_000_000 );
        port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            tick_1s : out std_logic
        );
    end component;

    component caso_menos35
        port (
            clk              : in  std_logic;
            rst              : in  std_logic;
            tick_1s          : in  std_logic;
            sensor           : in  std_logic;
            boton_reset      : in  std_logic;
            contador         : out std_logic_vector(5 downto 0);
            led_felicitacion : out std_logic;
            paso_35          : out std_logic
        );
    end component;

    component caso_mas35
        port (
            clk          : in  std_logic;
            rst          : in  std_logic;
            tick_1s      : in  std_logic;
            activar      : in  std_logic;
            sensor       : in  std_logic;
            boton_reset  : in  std_logic;
            contador_ext : out std_logic_vector(7 downto 0);
            led_alarma   : out std_logic
        );
    end component;

    component bcd7seg
        port (
            bcd : in  std_logic_vector(3 downto 0);
            seg : out std_logic_vector(6 downto 0)
        );
    end component;

    signal tick_1s      : std_logic;
    signal boton_reset  : std_logic;  
    signal cnt_caso1    : std_logic_vector(5 downto 0);
    signal paso_35      : std_logic;
    signal cnt_caso2    : std_logic_vector(7 downto 0);
    signal led_alarma_i : std_logic;

    signal valor_mostrar   : unsigned(7 downto 0);
    signal digito_decenas  : std_logic_vector(3 downto 0);
    signal digito_unidades : std_logic_vector(3 downto 0);

begin

    boton_reset <= not boton_reset_n;

    u_divisor : divisor
        generic map ( FREQ_CLK => FREQ_CLK )
        port map (
            clk     => clk,
            rst     => rst,
            tick_1s => tick_1s
        );

    u_caso1 : caso_menos35
        port map (
            clk              => clk,
            rst              => rst,
            tick_1s          => tick_1s,
            sensor           => sensor,
            boton_reset      => boton_reset,
            contador         => cnt_caso1,
            led_felicitacion => led_felicitacion,
            paso_35          => paso_35
        );

    u_caso2 : caso_mas35
        port map (
            clk          => clk,
            rst          => rst,
            tick_1s      => tick_1s,
            activar      => paso_35,
            sensor       => sensor,
            boton_reset  => boton_reset,
            contador_ext => cnt_caso2,
            led_alarma   => led_alarma_i
        );

    led_alarma <= led_alarma_i;


    valor_mostrar <= unsigned(cnt_caso2) when led_alarma_i = '1'
                      else resize(unsigned(cnt_caso1), 8);

    digito_decenas  <= std_logic_vector(to_unsigned(to_integer(valor_mostrar) / 10, 4));
    digito_unidades <= std_logic_vector(to_unsigned(to_integer(valor_mostrar) mod 10, 4));

    u_bcd_decenas : bcd7seg
        port map (
            bcd => digito_decenas,
            seg => seg_dec
        );

    u_bcd_unidades : bcd7seg
        port map (
            bcd => digito_unidades,
            seg => seg_uni
        );

end Structural;