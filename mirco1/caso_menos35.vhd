library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CASO: TIEMPO MENOR O IGUAL A 35 SEGUNDOS
-- Cuenta los segundos mientras el sensor indica que el espacio
-- está ocupado. Si se llega a 35 segundos, activa paso_35.
-- Entradas:
-- clk: reloj de la FPGA.
-- rst: reset general.
-- tick_1s: pulso generado cada segundo.
-- sensor: indica ocupación del espacio.
-- boton_reset: reinicio manual.
-- Salidas:
-- contador: valor del contador de segundos.
-- led_felicitacion : se activa cuando el vehículo sale antes de superar los 35 segundos.
-- paso_35: indica que se alcanzaron los 35 segundos.

entity caso_menos35 is
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
end caso_menos35;

architecture Behavioral of caso_menos35 is

-- Tiempo máximo de este contador.
    constant LIMITE : integer := 35;

-- Contador interno de 0 a 35.
    signal cnt : integer range 0 to LIMITE := 0;

-- Guarda el estado anterior del sensor para detectar cambios.
    signal sensor_d : std_logic := '0';

-- Indica que alguna vez se detectó una entrada.
    signal iniciado : std_logic := '0';

-- Indica que ya se alcanzaron los 35 segundos.
    signal flag_paso35 : std_logic := '0';

-- Señal utilizada para detectar el flanco de subida del sensor.
    signal flanco_subida : std_logic;

begin

-- Detecta cuando el sensor cambia de 0 a 1.
    flanco_subida <= sensor and not sensor_d;

-- PROCESO PRINCIPAL
    process(clk)
    begin
        if rising_edge(clk) then

-- Reset mediante botón.
            if rst = '1' or boton_reset = '1' then
                cnt         <= 0;
                sensor_d    <= '0';
                iniciado    <= '0';
                flag_paso35 <= '0';

            else

-- Guarda el estado actual del sensor.
                sensor_d <= sensor;

-- Si el sensor detecta ocupación, se registra que el proceso ya fue iniciado.
                if sensor = '1' then
                    iniciado <= '1';
                end if;

-- Mientras no se hayan alcanzado los 35 segundos.
                if flag_paso35 = '0' then

-- Cuando llega una nueva persona, el contador comienza nuevamente desde cero.
                    if flanco_subida = '1' then
                        cnt <= 0;

-- Cada tick de un segundo se incrementa el contador.
                    elsif sensor = '1' and tick_1s = '1' then

-- Si se alcanza el límite, se activa el paso hacia el segundo caso.
                        if cnt = LIMITE then
                            flag_paso35 <= '1';

                        else
-- Incrementa un segundo.
                            cnt <= cnt + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

-- LED DE FELICITACIÓN
-- Se activa si:
-- 1. El proceso ya había comenzado.
-- 2. El sensor deja de detectar ocupación.
-- 3. No se habían superado los 35 segundos.

    led_felicitacion <= iniciado and (not sensor) and (not flag_paso35);

-- Convierte el contador entero a vector de 6 bits.
    contador <= std_logic_vector(to_unsigned(cnt, 6));

-- Envía la señal de que se alcanzaron los 35 segundos.
    paso_35 <= flag_paso35;

end Behavioral;