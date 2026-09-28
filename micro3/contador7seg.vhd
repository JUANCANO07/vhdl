library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- CONTADOR DE MINUTOS Y SEGUNDOS
-- Cuenta el tiempo utilizando los pulsos de un segundo.
-- El conteo se organiza en tres dígitos:
-- minutos: 0 a 9
-- segundos decenas : 0 a 5
-- segundos unidades: 0 a 9
-- El temporizador se detiene cuando llega a 9:59.
-- Entradas:
-- clk: reloj de la FPGA.
-- reset_n : reset activo en bajo.
-- tick: pulso generado cada segundo.
-- Salidas:
-- minutos : valor BCD de los minutos.
-- seg_dec : valor BCD de las decenas de segundos.
-- seg_uni : valor BCD de las unidades de segundos.

entity contador7seg is
    port (
        clk     : in  std_logic;
        reset_n : in  std_logic;
        tick    : in  std_logic;
        minutos : out std_logic_vector(3 downto 0);
        seg_dec : out std_logic_vector(3 downto 0);
        seg_uni : out std_logic_vector(3 downto 0)
    );
end entity contador7seg;

architecture rtl of contador7seg is

-- Registro para almacenar los minutos.
    signal min_r : unsigned(3 downto 0) := (others => '0');

-- Registro para almacenar las decenas de segundos.
    signal sec_dec_r : unsigned(3 downto 0) := (others => '0');

-- Registro para almacenar las unidades de segundos.
    signal sec_uni_r : unsigned(3 downto 0) := (others => '0');

begin

-- CONTADOR
	 
    process(clk, reset_n)
    begin

-- Reset activo en bajo.
        if reset_n = '0' then
            min_r     <= (others => '0');
            sec_dec_r <= (others => '0');
            sec_uni_r <= (others => '0');

        elsif rising_edge(clk) then

-- Solo se actualiza el tiempo cuando llega
-- el pulso correspondiente a un segundo.
            if tick = '1' then

-- Verifica si se llegó al límite de 9:59.
                if min_r = "1001" and
                   sec_dec_r = "0101" and
                   sec_uni_r = "1001" then

-- Mantiene el valor 9:59.
                    null;

                else

-- CAMBIO DE UNIDADES DE SEGUNDO
-- Si las unidades llegan a 9, vuelven a 0 y se incrementan las decenas.
                    if sec_uni_r = "1001" then

                        sec_uni_r <= (others => '0');

-- CAMBIO DE DECENAS DE SEGUNDO
-- Las decenas solamente pueden ir de 0 a 5.
                        if sec_dec_r = "0101" then

-- Después de 59 segundos vuelven a 00.
                            sec_dec_r <= (others => '0');

-- Se incrementa un minuto.
                            min_r <= min_r + 1;

                        else
-- Incrementa las decenas de segundos.
                            sec_dec_r <= sec_dec_r + 1;
                        end if;

                    else
-- Incrementa las unidades de segundos.
                        sec_uni_r <= sec_uni_r + 1;

                    end if;
                end if;
            end if;
        end if;
    end process;

-- CONVERSIÓN DE LOS REGISTROS A LAS SALIDAS

-- Minutos.
    minutos <= std_logic_vector(min_r);

-- Decenas de segundos.
    seg_dec <= std_logic_vector(sec_dec_r);

-- Unidades de segundos.
    seg_uni <= std_logic_vector(sec_uni_r);

end architecture rtl;