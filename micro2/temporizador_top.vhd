library ieee;
use ieee.std_logic_1164.all;

entity temporizador_top is
    generic (
        CLK_FREQ : integer := 50000000   
    );
    port (
        clk         : in  std_logic;
        start_n     : in  std_logic;     
        stop_n      : in  std_logic;     
        reset_n     : in  std_logic;     

        seg_min     : out std_logic_vector(6 downto 0);  
        seg_sec_dec : out std_logic_vector(6 downto 0);  
        seg_sec_uni : out std_logic_vector(6 downto 0)   
    );
end entity temporizador_top;

architecture struct of temporizador_top is

    component contadorvhl is
        generic (CLK_FREQ : integer);
        port (
            clk     : in  std_logic;
            reset_n : in  std_logic;
            enable  : in  std_logic;
            tick    : out std_logic
        );
    end component;

    component contador7seg is
        port (
            clk     : in  std_logic;
            reset_n : in  std_logic;
            tick    : in  std_logic;
            minutos : out std_logic_vector(3 downto 0);
            seg_dec : out std_logic_vector(3 downto 0);
            seg_uni : out std_logic_vector(3 downto 0)
        );
    end component;

    component bcda7seg is
        port (
            bcd : in  std_logic_vector(3 downto 0);
            seg : out std_logic_vector(6 downto 0)
        );
    end component;

    signal tick_s      : std_logic;
    signal running     : std_logic := '0';  
    signal start_d     : std_logic := '1';  
    signal stop_d      : std_logic := '1';

    signal min_bcd     : std_logic_vector(3 downto 0);
    signal sec_dec_bcd : std_logic_vector(3 downto 0);
    signal sec_uni_bcd : std_logic_vector(3 downto 0);

begin

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            running <= '0';
            start_d <= '1';
            stop_d  <= '1';
        elsif rising_edge(clk) then
            start_d <= start_n;
            stop_d  <= stop_n;

            if (start_d = '1' and start_n = '0') then
                running <= '1';  
            elsif (stop_d = '1' and stop_n = '0') then
                running <= '0';   
            end if;
        end if;
    end process;

    divisor : contadorvhl
        generic map (CLK_FREQ => CLK_FREQ)
        port map (
            clk     => clk,
            reset_n => reset_n,
            enable  => running,   
            tick    => tick_s
        );

    contador : contador7seg
        port map (
            clk     => clk,
            reset_n => reset_n,
            tick    => tick_s,
            minutos => min_bcd,
            seg_dec => sec_dec_bcd,
            seg_uni => sec_uni_bcd
        );

    dec_min : bcda7seg port map (bcd => min_bcd,     seg => seg_min);
    dec_sd  : bcda7seg port map (bcd => sec_dec_bcd, seg => seg_sec_dec);
    dec_su  : bcda7seg port map (bcd => sec_uni_bcd, seg => seg_sec_uni);

end architecture struct;
