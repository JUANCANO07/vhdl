library ieee;
use ieee.std_logic_1164.all;

entity contadorvhl is
    generic (
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
    constant MAX_COUNT : integer := CLK_FREQ - 1;
    signal count : integer range 0 to MAX_COUNT := 0;
begin
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            count <= 0;
            tick  <= '0';
        elsif rising_edge(clk) then
            if enable = '1' then
                if count = MAX_COUNT then
                    count <= 0;
                    tick  <= '1';
                else
                    count <= count + 1;
                    tick  <= '0';
                end if;
            else
                tick <= '0';
            end if;
        end if;
    end process;
end architecture rtl;
