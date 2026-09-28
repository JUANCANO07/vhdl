library ieee;
use ieee.std_logic_1164.all;

-- TEMPORIZADOR CON UN SOLO BOTÓN
-- Controla un temporizador utilizando un único botón.
-- FUNCIONES DEL BOTÓN:
-- 1. Pulsación corta:
--    - Si está detenido, inicia el temporizador.
--    - Si está funcionando, detiene el temporizador.
-- 2. Pulsación larga de aproximadamente 2 segundos:
--    - Detiene el temporizador.
--    - Reinicia el conteo a 00:00.
-- Entrada:
-- clk   : reloj principal de la FPGA.
-- btn_n : botón activo en bajo.
-- Salidas:
-- seg_min     : display de minutos.
-- seg_min_dp  : punto decimal del display de minutos.
-- seg_sec_dec : display de decenas de segundos.
-- seg_sec_uni : display de unidades de segundos.

entity temporizador_top_1boton is
    generic (
-- Frecuencia del reloj de la FPGA.
        CLK_FREQ : integer := 50000000
    );
    port (
        clk         : in  std_logic;
        btn_n       : in  std_logic;

        seg_min     : out std_logic_vector(6 downto 0);
        seg_min_dp  : out std_logic;
        seg_sec_dec : out std_logic_vector(6 downto 0);
        seg_sec_uni : out std_logic_vector(6 downto 0)
    );
end entity temporizador_top_1boton;


-- ARQUITECTURA 
-- Integra:
-- - Control del botón.
-- - Divisor de frecuencia.
-- - Contador de minutos y segundos.
-- - Decodificadores para los displays.

architecture struct of temporizador_top_1boton is

-- COMPONENTE DIVISOR DE FRECUENCIA
-- Genera un pulso cada segundo.
    component contadorvhl is
        generic (CLK_FREQ : integer);
        port (
            clk     : in  std_logic;
            reset_n : in  std_logic;
            enable  : in  std_logic;
            tick    : out std_logic
        );
    end component;


-- COMPONENTE CONTADOR DE TIEMPO
-- Cuenta minutos y segundos utilizando el tick de 1 segundo.
	 
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


-- COMPONENTE DECODIFICADOR BCD A 7 SEGMENTOS
-- Convierte cada dígito BCD en las señales del display.
	 
    component bcda7seg is
        port (
            bcd : in  std_logic_vector(3 downto 0);
            seg : out std_logic_vector(6 downto 0)
        );
    end component;


-- CONSTANTE PARA DETECTAR UNA PULSACIÓN LARGA
-- Se necesitan dos segundos de ciclos de reloj.
-- Ejemplo:
-- CLK_FREQ = 50.000.000 Hz
-- UMBRAL_2S = 2 × 50.000.000
--           = 100.000.000 ciclos
-- Cuando el botón permanece presionado durante este tiempo,
-- se considera una pulsación larga.
    constant UMBRAL_2S : integer := 2 * CLK_FREQ;


-- SEÑALES DEL BOTÓN
-- Estado actual sincronizado del botón.

    signal btn_sync : std_logic := '1';

-- Estado anterior del botón.
-- Se utiliza para detectar cuándo se suelta.
    signal btn_prev : std_logic := '1';


-- CONTADOR DE DURACIÓN DEL PULSO
-- Cuenta cuántos ciclos de reloj permanece presionado
-- el botón, hasta llegar al límite de 2 segundos.
	 
    signal cont_pulso : integer range 0 to UMBRAL_2S := 0;


-- ESTADO DEL TEMPORIZADOR
-- Indica si el temporizador está funcionando.
-- '0' = detenido
-- '1' = funcionando
	 
    signal en_marcha : std_logic := '0';


-- INDICADOR DE PULSACIÓN LARGA
-- Evita que una pulsación larga también sea interpretada
-- como una pulsación corta cuando se suelta el botón.
-- '0' = todavía no se detectó pulsación larga.
-- '1' = ya se detectó pulsación larga.
	 
    signal larga_ya : std_logic := '0';

-- RESET INTERNO
-- Se utiliza para reiniciar el divisor y el contador
-- cuando se detecta una pulsación larga.
    signal reset_n_i : std_logic := '1';


-- SEÑALES DE CONEXIÓN ENTRE COMPONENTES
-- Pulso de un segundo.

    signal tick_s : std_logic;

-- Dígitos BCD del tiempo.
	 
    signal min_bcd     : std_logic_vector(3 downto 0);
    signal sec_dec_bcd : std_logic_vector(3 downto 0);
    signal sec_uni_bcd : std_logic_vector(3 downto 0);

begin

-- PROCESO DE CONTROL DEL BOTÓN
-- Este proceso determina si la pulsación es corta o larga.
-- El botón es activo en bajo:
-- '1' = botón sin presionar.
-- '0' = botón presionado.

    process(clk)
    begin
        if rising_edge(clk) then

-- Guarda el estado anterior del botón.
            btn_prev <= btn_sync;

-- Actualiza el estado sincronizado del botón.
            btn_sync <= btn_n;


-- RESET INTERNO NORMAL
-- Por defecto el reset interno permanece desactivado.
-- Solo se activa durante la detección de una pulsación larga.
            reset_n_i <= '1';

            -- BOTÓN PRESIONADO
				
            if btn_sync = '0' then

-- Mientras el botón esté presionado,
-- se cuenta cuánto tiempo lleva presionado.
                if cont_pulso /= UMBRAL_2S then
                    cont_pulso <= cont_pulso + 1;
                end if;

-- DETECCIÓN DE PULSACIÓN LARGA
-- Cuando el contador llega a aproximadamente
-- 2 segundos y todavía no se había detectado
-- una pulsación larga:
-- 1. Se detiene el temporizador.
-- 2. Se activa el reset interno.
-- 3. Se marca que ya fue detectada la pulsación larga.
                if cont_pulso = UMBRAL_2S - 1 and larga_ya = '0' then

                    en_marcha <= '0';

-- Reset activo en bajo.
                    reset_n_i <= '0';

                    larga_ya <= '1';

                end if;


-- BOTÓN SIN PRESIONAR
            else

-- Reinicia el contador de duración del botón.
                cont_pulso <= 0;

-- DETECCIÓN DE SOLTAR EL BOTÓN
-- Si anteriormente estaba presionado y ahora
-- está libre, se detectó el final de la pulsación.
                if btn_prev = '0' then

-- Si no fue una pulsación larga,
-- se interpreta como una pulsación corta.
                    if larga_ya = '0' then

-- Cambia el estado del temporizador:
-- detenido -> funcionando
-- funcionando -> detenido
                        en_marcha <= not en_marcha;

                    end if;

-- Prepara el sistema para una nueva pulsación.
                    larga_ya <= '0';

                end if;
            end if;

        end if;
    end process;


-- DIVISOR DE FRECUENCIA
-- Recibe el reloj de la FPGA y genera un tick de 1 segundo.
-- El divisor solamente cuenta cuando:
-- en_marcha = '1'
-- Cuando el temporizador está detenido, no genera ticks.

    divisor : contadorvhl
        generic map (CLK_FREQ => CLK_FREQ)
        port map (
            clk     => clk,
            reset_n => reset_n_i,
            enable  => en_marcha,
            tick    => tick_s
        );


-- CONTADOR DE MINUTOS Y SEGUNDOS
-- Recibe el tick de un segundo y actualiza:
-- - minutos
-- - decenas de segundos
-- - unidades de segundos

    contador : contador7seg
        port map (
            clk     => clk,
            reset_n => reset_n_i,
            tick    => tick_s,
            minutos => min_bcd,
            seg_dec => sec_dec_bcd,
            seg_uni => sec_uni_bcd
        );


-- DECODIFICADORES BCD A 7 SEGMENTOS

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


-- Mantiene el punto decimal del display de minutos
-- encendido mediante lógica activa en bajo.
    seg_min_dp <= '0';


end architecture struct;