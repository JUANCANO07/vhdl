library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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

    type estado_t is (S_INACTIVO, S_ALARMA);
    signal estado : estado_t := S_INACTIVO;

    signal cnt : integer range 0 to 255 := 0;
    signal led : std_logic := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or boton_reset = '1' then
                estado <= S_INACTIVO;
                cnt    <= 0;
                led    <= '0';
            else
                case estado is

                    when S_INACTIVO =>
                        led <= '0';
                        cnt <= 0;
                        if activar = '1' then
                            estado <= S_ALARMA;
                        end if;

                    when S_ALARMA =>
                        led <= '1';
                        if tick_1s = '1' and sensor = '1' then
                            if cnt = 255 then
                                cnt <= 0;
                            else
                                cnt <= cnt + 1;
                            end if;
                        end if;
                end case;
            end if;
        end if;
    end process;

    contador_ext <= std_logic_vector(to_unsigned(cnt, 8));
    led_alarma   <= led;

end Behavioral;
