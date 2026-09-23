library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
    signal min_r     : unsigned(3 downto 0) := (others => '0');
    signal sec_dec_r : unsigned(3 downto 0) := (others => '0');
    signal sec_uni_r : unsigned(3 downto 0) := (others => '0');
begin
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            min_r     <= (others => '0');
            sec_dec_r <= (others => '0');
            sec_uni_r <= (others => '0');
        elsif rising_edge(clk) then
            if tick = '1' then
                if min_r = "1001" and sec_dec_r = "0101" and sec_uni_r = "1001" then
                    null;
                else
                    if sec_uni_r = "1001" then
                        sec_uni_r <= (others => '0');
                        if sec_dec_r = "0101" then
                            sec_dec_r <= (others => '0');
                            min_r     <= min_r + 1;
                        else
                            sec_dec_r <= sec_dec_r + 1;
                        end if;
                    else
                        sec_uni_r <= sec_uni_r + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    minutos <= std_logic_vector(min_r);
    seg_dec <= std_logic_vector(sec_dec_r);
    seg_uni <= std_logic_vector(sec_uni_r);
end architecture rtl;
