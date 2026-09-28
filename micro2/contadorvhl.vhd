library ieee;
use ieee.std_logic_1164.all;

-- DIVISOR DE FRECUENCIA
-- Divide la frecuencia del reloj de la FPGA para generar
-- un pulso que representa un segundo.
-- Entradas:
-- clk: reloj de la FPGA.
-- reset_n : reset activo en bajo.
-- enable  : habilita o detiene el conteo.
-- Salida:
-- tick    : pulso de un ciclo de reloj cada segundo.

entity contadorvhl is
    generic (
-- Frecuencia del reloj de entrada.
        CLK_FREQ : integer := 50000000
    );
    port (
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        enable   : in  std_logic;
        tick     : out std_logic
    );
end entity contadorvhl;

architecture rtl of contadorvhl is

-- VALOR MÁXIMO DEL CONTADOR
-- Para 50 MHz:
-- 50.000.000 ciclos = 1 segundo.
-- Por eso el contador va de 0 a 49.999.999.

    constant MAX_COUNT : integer := CLK_FREQ - 1;

-- Contador interno de ciclos del reloj.
    signal count : integer range 0 to MAX_COUNT := 0;

begin

-- DIVISOR
	 
    process(clk, reset_n)
    begin

-- Reset activo en bajo.
        if reset_n = '0' then
            count <= 0;
            tick  <= '0';

        elsif rising_edge(clk) then

-- El divisor solamente cuenta cuando el temporizador está funcionando.
            if enable = '1' then

-- Cuando se alcanza el máximo, ha transcurrido un segundo.
                if count = MAX_COUNT then
                    count <= 0;

-- Genera el pulso de un segundo.
                    tick <= '1';

                else
-- Continúa contando ciclos de reloj.
                    count <= count + 1;

-- No genera pulso todavía.
                    tick <= '0';
                end if;

            else
-- Si el temporizador está detenido, no se genera ningún tick.
                tick <= '0';
            end if;

        end if;
    end process;

end architecture rtl;