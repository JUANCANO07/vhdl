library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- DIVISOR DE FRECUENCIA
-- Divide la frecuencia del reloj principal de la FPGA para
-- generar un pulso de un segundo.
-- Entrada:
-- clk : reloj principal de la FPGA.
-- rst : reset.
--
-- Salida:
-- tick_1s : pulso que permanece en '1' durante un ciclo de reloj
--cada vez que transcurre un segundo.

entity divisor is
    generic (
-- Frecuencia del reloj de entrada.
        FREQ_CLK : integer := 50_000_000
    );
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        tick_1s : out std_logic
    );
end divisor;

architecture Behavioral of divisor is

-- Valor máximo que debe alcanzar el contador.
-- Para un reloj de 100 MHz, cuenta de 0 a 99.999.999.
    constant MAX_CUENTA : integer := FREQ_CLK - 1;

-- Contador utilizado para medir un segundo.
    signal contador : integer range 0 to MAX_CUENTA := 0;

begin

-- PROCESO DEL DIVISOR
	 
    process(clk)
    begin
        if rising_edge(clk) then

-- Reinicia el contador y la salida.
            if rst = '1' then
                contador <= 0;
                tick_1s  <= '0';

-- Cuando se alcanza el máximo, significa que transcurrió un segundo.
            elsif contador = MAX_CUENTA then
                contador <= 0;

-- Genera un pulso de un ciclo de reloj.
                tick_1s <= '1';

            else
-- Continúa contando los ciclos del reloj.
                contador <= contador + 1;

-- Mantiene el pulso desactivado.
                tick_1s <= '0';
            end if;
        end if;
    end process;

end Behavioral;