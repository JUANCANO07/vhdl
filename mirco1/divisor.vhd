library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity divisor is
    generic (
        FREQ_CLK : integer := 100_000_000  
    );
    port (
        clk     : in  std_logic;  
        rst     : in  std_logic;  
        tick_1s : out std_logic   
    );
end divisor;

architecture Behavioral of divisor is

    constant MAX_CUENTA : integer := FREQ_CLK - 1;
    signal contador : integer range 0 to MAX_CUENTA := 0;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                contador <= 0;
                tick_1s  <= '0';
            elsif contador = MAX_CUENTA then
                contador <= 0;
                tick_1s  <= '1';   
            else
                contador <= contador + 1;
                tick_1s  <= '0';
            end if;
        end if;
    end process;

end Behavioral;
