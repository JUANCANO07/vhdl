library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ENTIDAD TOP LEVEL DEL PROYECTO
-- Integra todos los módulos del sistema: divisor de frecuencia,
-- contador de los primeros 35 segundos, contador después de 35 s
-- y decodificadores para los displays de 7 segmentos.
-- Entradas:
-- clk: reloj principal de la FPGA.
-- rst: reset general.
-- sensor: indica si el espacio está ocupado.
-- boton_reset_n: botón de reset activo en bajo.
-- Salidas:
-- led_felicitacion : LED que indica que el vehículo salió antes de superar los 35 segundos.
-- led_alarma: LED que indica que se superaron los 35 segundos.
-- seg_dec: display de las decenas.
-- seg_uni: display de las unidades.

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


-- ARQUITECTURA 
-- Se conectan entre sí los diferentes módulos del sistema.

architecture Structural of top is

-- COMPONENTE DIVISOR
-- Genera un pulso de un segundo a partir del reloj de la FPGA.

    component divisor
        generic ( FREQ_CLK : integer := 100_000_000 );
        port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            tick_1s : out std_logic
        );
    end component;

-- COMPONENTE CASO MENOS DE 35 SEGUNDOS
-- Cuenta el tiempo mientras el sensor está activo.

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

-- COMPONENTE CASO MÁS DE 35 SEGUNDOS
-- Se activa cuando el primer contador alcanza los 35 segundos.
-- Continúa contando el tiempo adicional.
	 
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

-- COMPONENTE DECODIFICADOR BCD A 7 SEGMENTOS
-- Convierte cada dígito decimal en las señales necesarias
-- para controlar un display de 7 segmentos.
	 
    component bcd7seg
        port (
            bcd : in  std_logic_vector(3 downto 0);
            seg : out std_logic_vector(6 downto 0)
        );
    end component;

    -- SEÑALES INTERNAS

    signal tick_1s      : std_logic;
    signal boton_reset  : std_logic;

-- Contador de 0 a 35 segundos.
    signal cnt_caso1    : std_logic_vector(5 downto 0);

-- Indica que se alcanzaron los 35 segundos.
    signal paso_35      : std_logic;

-- Contador del tiempo adicional después de 35 segundos.
    signal cnt_caso2    : std_logic_vector(7 downto 0);

-- Señal interna del LED de alarma.
    signal led_alarma_i : std_logic;

-- Valor que finalmente se mostrará en los displays.
    signal valor_mostrar   : unsigned(7 downto 0);

-- Dígitos separados para decenas y unidades.
    signal digito_decenas  : std_logic_vector(3 downto 0);
    signal digito_unidades : std_logic_vector(3 downto 0);

begin

-- El botón externo es activo en bajo.
-- Se invierte para trabajar internamente con lógica activa en alto.
    boton_reset <= not boton_reset_n;

    -- DIVISOR DE FRECUENCIA
    -- Genera un pulso tick_1s cada segundo.
	 
    u_divisor : divisor
        generic map ( FREQ_CLK => FREQ_CLK )
        port map (
            clk     => clk,
            rst     => rst,
            tick_1s => tick_1s
        );

    -- CASO MENOS DE 35 SEGUNDOS
    -- Cuenta desde que el sensor detecta ocupación.
	 
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

-- CASO MÁS DE 35 SEGUNDOS
-- Se activa mediante la señal paso_35.

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

-- Conecta la señal interna del LED con la salida.
    led_alarma <= led_alarma_i;

-- SELECCIÓN DEL VALOR A MOSTRAR
-- Si se superaron los 35 segundos:
--     valor mostrado = 35 + tiempo adicional.
--
-- Si todavía no se superaron:
--     valor mostrado = contador de los primeros 35 segundos.

    valor_mostrar <= to_unsigned(35, 8) + unsigned(cnt_caso2)
                     when led_alarma_i = '1'
                     else resize(unsigned(cnt_caso1), 8);

-- Obtiene las decenas del valor.
    digito_decenas <= std_logic_vector(
        to_unsigned(to_integer(valor_mostrar) / 10, 4)
    );

-- Obtiene las unidades del valor.
    digito_unidades <= std_logic_vector(
        to_unsigned(to_integer(valor_mostrar) mod 10, 4)
    );

-- DECODIFICADOR DE DECENAS
    u_bcd_decenas : bcd7seg
        port map (
            bcd => digito_decenas,
            seg => seg_dec
        );

    -- DECODIFICADOR DE UNIDADES
	 
    u_bcd_unidades : bcd7seg
        port map (
            bcd => digito_unidades,
            seg => seg_uni
        );

end Structural;