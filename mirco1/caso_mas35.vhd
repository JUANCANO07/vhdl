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

    signal cnt : unsigned(7 downto 0) := (others => '0');  
    signal led : std_logic := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or boton_reset = '1' then
                cnt <= (others => '0');
                led <= '0';
            else
                if activar = '1' then
                    led <= '1';                        
                end if;

                if led = '1' and tick_1s = '1' and sensor = '1' then
                    cnt <= cnt + 1;
                end if;
            end if;
        end if;
    end process;

    contador_ext <= std_logic_vector(cnt);
    led_alarma   <= led;

end Behavioral;