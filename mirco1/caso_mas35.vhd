library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CASO: TIEMPO MAYOR A 35 SEGUNDOS
-- Se activa cuando el primer contador alcanza los 35 segundos.
-- A partir de ese momento activa la alarma y comienza a contar
-- el tiempo adicional mientras el sensor siga activo.
-- Entradas:
-- clk: reloj de la FPGA.
-- rst: reset general.
-- tick_1s: pulso de un segundo.
-- activar: indica que se alcanzaron los 35 segundos.
-- sensor: indica si el espacio sigue ocupado.
-- boton_reset: reinicio manual.
-- Salidas:
-- contador_ext: tiempo adicional después de los 35 segundos.
-- led_alarma: indica que se superó el límite.

entity caso_mas35 is
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
end caso_mas35;

architecture Behavioral of caso_mas35 is

-- Contador de segundos adicionales.
    signal cnt : unsigned(7 downto 0) := (others => '0');

-- Estado interno del LED de alarma.
    signal led : std_logic := '0';

begin

    -- PROCESO PRINCIPAL
	 
    process(clk)
    begin
        if rising_edge(clk) then

-- Reset mediante botón.
            if rst = '1' or boton_reset = '1' then
                cnt <= (others => '0');
                led <= '0';

            else

-- Cuando se recibe la señal activar,se enciende la alarma.
                if activar = '1' then
                    led <= '1';
                end if;

-- Mientras la alarma esté activa, el sensor siga detectando ocupación y
-- llegue un tick de un segundo,se incrementa el contador adicional.
                if led = '1' and tick_1s = '1' and sensor = '1' then
                    cnt <= cnt + 1;
                end if;

            end if;
        end if;
    end process;

-- Convierte el contador a vector de salida.
    contador_ext <= std_logic_vector(cnt);

-- Entrega el estado del LED de alarma.
    led_alarma <= led;

end Behavioral;