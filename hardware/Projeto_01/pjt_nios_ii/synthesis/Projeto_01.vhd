library ieee;
use ieee.std_logic_1164.all;

entity Projeto_01 is
    port(
        -- Clock principal da placa (50 MHz)
        CICLONE2_CLK1_50     : in std_logic;
        
        -- Botões físicos (KEY0 para Reset, KEY1 para Start/Stop)
        KEY                  : in std_logic_vector(1 downto 0);
        
        -- 2 Chaves seletoras (SW0 e SW1)
        SW                   : in std_logic_vector(1 downto 0);
        
        -- 10 LEDs vermelhos para saídas genéricas
        LEDS                 : out std_logic_vector(9 downto 0);
        
        -- Displays de 7 segmentos (HEX0 para unidade, HEX1 para dezena)
        HEX0                 : out std_logic_vector(6 downto 0); -- Unidade
        HEX1                 : out std_logic_vector(6 downto 0)  -- Dezena
    );
end entity;

architecture rtl of Projeto_01 is

    -- Declaração do componente Qsys
    component pjt_nios_ii is
        port (
            clk_clk                 : in  std_logic;							
            reset_reset_n           : in  std_logic;							
            leds_export             : out std_logic_vector(9 downto 0);
            chaves_export           : in  std_logic_vector(1 downto 0); 
            botao_start_stop_export : in  std_logic;
            display_7seg_export     : out std_logic_vector(13 downto 0)
        );
    end component pjt_nios_ii;

    -- Sinal intermediário antes do begin da arquitetura
    signal barramento_displays : std_logic_vector(13 downto 0);

begin

    -- Instanciação do bloco Nios II
    u0 : component pjt_nios_ii
        port map (
            clk_clk                 => CICLONE2_CLK1_50,  
            reset_reset_n           => KEY(0),            
            leds_export             => LEDS,              
            chaves_export           => SW,                
            botao_start_stop_export => KEY(1),            
            display_7seg_export     => barramento_displays
        );

    -- Separação das vias para cada display físico externo
    HEX1 <= barramento_displays(13 downto 7); -- Bits de 13 a 7 vão para a Dezena
    HEX0 <= barramento_displays(6 downto 0);  -- Bits de 6 a 0 vão para a Unidade

end architecture;