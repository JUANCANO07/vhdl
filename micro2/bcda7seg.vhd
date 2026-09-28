library ieee;
use ieee.std_logic_1164.all;

-- DECODIFICADOR BCD A 7 SEGMENTOS
-- Convierte un número BCD de 4 bits en las señales necesarias
-- para mostrar dicho número en un display de 7 segmentos.
-- Entrada:
-- bcd : número en formato BCD de 4 bits.
-- Salida:
-- seg : señales de los siete segmentos.
-- Los displays utilizados trabajan con lógica activa en bajo.
-- Por esta razón, un '0' enciende un segmento.

entity bcda7seg is
    port (
        bcd : in  std_logic_vector(3 downto 0);
        seg : out std_logic_vector(6 downto 0)
    );
end entity bcda7seg;

architecture comb of bcda7seg is
begin

-- DECODIFICACIÓN DEL NÚMERO
    process(bcd)
    begin

        case bcd is

            -- Número 0.
            when "0000" =>
                seg <= "1000000";

            -- Número 1.
            when "0001" =>
                seg <= "1111001";

            -- Número 2.
            when "0010" =>
                seg <= "0100100";

            -- Número 3.
            when "0011" =>
                seg <= "0110000";

            -- Número 4.
            when "0100" =>
                seg <= "0011001";

            -- Número 5.
            when "0101" =>
                seg <= "0010010";

            -- Número 6.
            when "0110" =>
                seg <= "0000010";

            -- Número 7.
            when "0111" =>
                seg <= "1111000";

            -- Número 8.
            when "1000" =>
                seg <= "0000000";

            -- Número 9.
            when "1001" =>
                seg <= "0010000";

            -- Valores BCD no utilizados.
            -- Se apagan todos los segmentos.
            when others =>
                seg <= "1111111";

        end case;
    end process;

end architecture comb;