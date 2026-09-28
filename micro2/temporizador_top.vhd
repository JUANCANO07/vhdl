library ieee;
use ieee.std_logic_1164.all;
-- ENTIDAD TOP LEVEL
-- Integra los módulos encargados de generar un segundo,
-- contar minutos y segundos y mostrar el resultado en
-- displays de 7 segmentos.
-- Entradas:
-- clk: reloj principal de la FPGA.
-- start_n : botón de inicio, activo en bajo.
-- stop_n: botón de parada, activo en bajo.
-- reset_n : reset general, activo en bajo.
-- Salidas:
-- seg_min: display de los minutos.
-- seg_min_dp: punto decimal del display de minutos.
-- seg_sec_dec : display de las decenas de segundos.
-- seg_sec_uni : display de las unidades de segundos.

entity temporizador_top is
    generic (
-- Frecuencia del reloj de la FPGA.
        CLK_FREQ : integer := 50_000_000
    );
    port (
        clk         : in  std_logic;
        start_n     : in  std_logic;
        stop_n      : in  std_logic;
        reset_n     : in  std_logic;

        seg_min     : out std_logic_vector(6 downto 0);
        seg_min_dp  : out std_logic;
        seg_sec_dec : out std_logic_vector(6 downto 0);
        seg_sec_uni : out std_logic_vector(6 downto 0)
    );
end entity temporizador_top;

-- ARQUITECTURA 
-- Conecta los diferentes módulos del temporizador.

architecture struct of temporizador_top is

-- COMPONENTE DIVISOR DE FRECUENCIA
-- Convierte el reloj de la FPGA en un pulso de 1 segundo.

    component contadorvhl is
        generic (CLK_FREQ : integer);
        port (
            clk     : in  std_logic;
            reset_n : in  std_logic;
            enable  : in  std_logic;
            tick    : out std_logic
        );
    end component;

-- COMPONENTE CONTADOR
-- Lleva el conteo de minutos y segundos.
  
    component contador7seg is
        port (
            clk     : in  std_logic;
            reset_n : in  std_logic;
            tick    : in  std_logic;
            minutos : out std_logic_vector(3 downto 0);
            seg_dec : out std_logic_vector(3 downto 0);
            seg_uni : out std_logic_vector(3 downto 0)
        );
    end component;

-- COMPONENTE DECODIFICADOR
-- Convierte los valores BCD en señales para los displays.
    
    component bcda7seg is
        port (
            bcd : in  std_logic_vector(3 downto 0);
            seg : out std_logic_vector(6 downto 0)
        );
    end component;

-- SEÑALES INTERNAS

-- Pulso de un segundo generado por el divisor.
    signal tick_s : std_logic;

-- Indica si el temporizador está funcionando.
    signal running : std_logic := '0';

-- Estados anteriores de los botones.
-- Se utilizan para detectar el momento en que se presionan.
    signal start_d : std_logic := '1';
    signal stop_d  : std_logic := '1';

-- Valores BCD de minutos y segundos.
    signal min_bcd     : std_logic_vector(3 downto 0);
    signal sec_dec_bcd : std_logic_vector(3 downto 0);
    signal sec_uni_bcd : std_logic_vector(3 downto 0);

begin

-- CONTROL DE INICIO Y PARADA
-- Los botones son activos en bajo.
-- Se detecta el cambio de 1 a 0 para identificar
-- la pulsación de cada botón.

    process(clk, reset_n)
    begin

-- Reset activo en bajo.
        if reset_n = '0' then
            running <= '0';
            start_d <= '1';
            stop_d  <= '1';

        elsif rising_edge(clk) then

-- Guarda el estado actual de los botones
-- para poder detectar el siguiente cambio.
            start_d <= start_n;
            stop_d  <= stop_n;

-- Detecta el flanco de bajada del botón START.
            if (start_d = '1' and start_n = '0') then
                running <= '1';

-- Detecta el flanco de bajada del botón STOP.
            elsif (stop_d = '1' and stop_n = '0') then
                running <= '0';
            end if;

        end if;
    end process;

-- DIVISOR DE FRECUENCIA
-- Solo funciona cuando running está activo.
-- Genera un tick cada segundo.
   
    divisor : contadorvhl
        generic map (CLK_FREQ => CLK_FREQ)
        port map (
            clk     => clk,
            reset_n => reset_n,
            enable  => running,
            tick    => tick_s
        );

-- CONTADOR DE MINUTOS Y SEGUNDOS
-- Recibe el pulso de un segundo y actualiza el tiempo.

    contador : contador7seg
        port map (
            clk     => clk,
            reset_n => reset_n,
            tick    => tick_s,
            minutos => min_bcd,
            seg_dec => sec_dec_bcd,
            seg_uni => sec_uni_bcd
        );

-- DECODIFICADORES PARA LOS DISPLAYS

-- Display de minutos.
    dec_min : bcda7seg
        port map (
            bcd => min_bcd,
            seg => seg_min
        );

-- Display de decenas de segundos.
    dec_sd : bcda7seg
        port map (
            bcd => sec_dec_bcd,
            seg => seg_sec_dec
        );

-- Display de unidades de segundos.
    dec_su : bcda7seg
        port map (
            bcd => sec_uni_bcd,
            seg => seg_sec_uni
        );

-- Mantiene el punto decimal encendido.
    seg_min_dp <= '0';

end architecture struct;