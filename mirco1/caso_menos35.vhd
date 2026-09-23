library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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

    constant LIMITE : integer := 35;

    type estado_t is (S_ESPERA, S_CONTANDO, S_FELICITANDO, S_PASO35);
    signal estado : estado_t := S_ESPERA;

    signal cnt         : integer range 0 to LIMITE := 0;
    signal led_fel     : std_logic := '0';
    signal flag_paso35 : std_logic := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or boton_reset = '1' then
                estado      <= S_ESPERA;
                cnt         <= 0;
                led_fel     <= '0';
                flag_paso35 <= '0';
            else
                case estado is

                    when S_ESPERA =>
                        led_fel     <= '0';
                        flag_paso35 <= '0';
                        cnt         <= 0;
                        if sensor = '1' then
                            estado <= S_CONTANDO;
                        end if;

                    when S_CONTANDO =>
                        if sensor = '0' then
                            led_fel <= '1';
                            estado  <= S_FELICITANDO;
                        elsif tick_1s = '1' then
                            if cnt = LIMITE then
                                flag_paso35 <= '1';
                                estado      <= S_PASO35;
                            else
                                cnt <= cnt + 1;
                            end if;
                        end if;

                    when S_FELICITANDO =>

                        if sensor = '1' then
                            led_fel <= '0';
                            cnt     <= 0;
                            estado  <= S_CONTANDO;
                        end if;

                    when S_PASO35 =>

                        null;

                end case;
            end if;
        end if;
    end process;

    contador         <= std_logic_vector(to_unsigned(cnt, 6));
    led_felicitacion <= led_fel;
    paso_35          <= flag_paso35;

end Behavioral;
