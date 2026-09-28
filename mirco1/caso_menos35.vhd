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

    signal cnt         : integer range 0 to LIMITE := 0;
    signal sensor_d    : std_logic := '0';  
    signal iniciado    : std_logic := '0';  
    signal flag_paso35 : std_logic := '0';  

    signal flanco_subida : std_logic;

begin

    flanco_subida <= sensor and not sensor_d;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or boton_reset = '1' then
                cnt         <= 0;
                sensor_d    <= '0';
                iniciado    <= '0';
                flag_paso35 <= '0';
            else
                sensor_d <= sensor;

                if sensor = '1' then
                    iniciado <= '1';
                end if;

                if flag_paso35 = '0' then
                    if flanco_subida = '1' then
                        cnt <= 0;                    
                    elsif sensor = '1' and tick_1s = '1' then
                        if cnt = LIMITE then
                            flag_paso35 <= '1';
                        else
                            cnt <= cnt + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    led_felicitacion <= iniciado and (not sensor) and (not flag_paso35);

    contador <= std_logic_vector(to_unsigned(cnt, 6));
    paso_35  <= flag_paso35;

end Behavioral;