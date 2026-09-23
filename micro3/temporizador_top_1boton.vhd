library ieee;
use ieee.std_logic_1164.all;

entity temporizador_top_1boton is
    generic (
        CLK_FREQ : integer := 50000000   
    );
    port (
        clk         : in  std_logic;
        btn_n       : in  std_logic;     

        seg_min     : out std_logic_vector(6 downto 0);
        seg_sec_dec : out std_logic_vector(6 downto 0);
        seg_sec_uni : out std_logic_vector(6 downto 0)
    );
end entity temporizador_top_1boton;

architecture struct of temporizador_top_1boton is

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

    constant UMBRAL_2S : integer := 2 * CLK_FREQ;

    signal btn_sync   : std_logic := '1';  
    signal btn_prev   : std_logic := '1';  
    signal cont_pulso : integer range 0 to UMBRAL_2S := 0; 
    signal en_marcha  : std_logic := '0';  
    signal larga_ya   : std_logic := '0';  
    signal reset_n_i  : std_logic := '1';  

    signal tick_s      : std_logic;
    signal min_bcd      : std_logic_vector(3 downto 0);
    signal sec_dec_bcd  : std_logic_vector(3 downto 0);
    signal sec_uni_bcd  : std_logic_vector(3 downto 0);

begin

    process(clk)
    begin
        if rising_edge(clk) then

            btn_prev <= btn_sync;
            btn_sync <= btn_n;

            reset_n_i <= '1';

            if btn_sync = '0' then

                if cont_pulso /= UMBRAL_2S then
                    cont_pulso <= cont_pulso + 1;
                end if;

                if cont_pulso = UMBRAL_2S - 1 and larga_ya = '0' then
                    en_marcha  <= '0';   
                    reset_n_i  <= '0';   
                    larga_ya   <= '1';   
                end if;

            else

                cont_pulso <= 0;

                if btn_prev = '0' then
                    if larga_ya = '0' then
                        en_marcha <= not en_marcha;  
                    end if;
                    larga_ya <= '0';  
                end if;
            end if;
        end if;
    end process;

    divisor : contadorvhl
        generic map (CLK_FREQ => CLK_FREQ)
        port map (
            clk     => clk,
            reset_n => reset_n_i,
            enable  => en_marcha,
            tick    => tick_s
        );

    contador : contador7seg
        port map (
            clk     => clk,
            reset_n => reset_n_i,
            tick    => tick_s,
            minutos => min_bcd,
            seg_dec => sec_dec_bcd,
            seg_uni => sec_uni_bcd
        );

    dec_min : bcda7seg port map (bcd => min_bcd,     seg => seg_min);
    dec_sd  : bcda7seg port map (bcd => sec_dec_bcd, seg => seg_sec_dec);
    dec_su  : bcda7seg port map (bcd => sec_uni_bcd, seg => seg_sec_uni);

end architecture struct;
