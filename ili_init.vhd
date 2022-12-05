
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

    entity ili_init is port (

        clk_i           : in std_ulogic;
        rst_i           : in std_ulogic;

        busy_o          : out std_ulogic;

        -- to ili9341
        ili_8bit_bus_o  : out unsigned (15 downto 0);
        ili_CD_o        : out std_ulogic;
        ili_wrx_o       : out std_ulogic;
        ili_rst_o       : out std_ulogic;
        ili_rd_o        : out std_ulogic;
        ili_cs_o        : out std_ulogic;

    );

architecture behavioural of display_00 is

    type state_t is (
                     s_rst_lcd,
                     s_init_lcd,
                     s_init_pause
                    );

    type array_unsigned_8_downto_0_t is
        array (natural range <>) of unsigned (8 downto 0);

    constant ILI_PWCTR1   : unsigned (7 downto 0) := x"c0";
    constant ILI_PWCTR2   : unsigned (7 downto 0) := x"c1";
    constant ILI_VMCTR1   : unsigned (7 downto 0) := x"c5";
    constant ILI_VMCTR2   : unsigned (7 downto 0) := x"c7";
    constant ILI_MADCTL   : unsigned (7 downto 0) := x"36";
    constant ILI_PIXFMT   : unsigned (7 downto 0) := x"3a";
    constant ILI_FRMCTR1  : unsigned (7 downto 0) := x"b1";
    constant ILI_DFUNCTR  : unsigned (7 downto 0) := x"b6";
    constant ILI_GAMMASET : unsigned (7 downto 0) := x"26";
    constant ILI_GMCTRP1  : unsigned (7 downto 0) := x"e0";
    constant ILI_GMCTRN1  : unsigned (7 downto 0) := x"e1";
    constant ILI_SLPOUT   : unsigned (7 downto 0) := x"11";
    constant ILI_DISPON   : unsigned (7 downto 0) := x"29";
    constant ILI_CASET    : unsigned (7 downto 0) := x"2a";
    constant ILI_PASET    : unsigned (7 downto 0) := x"2b";
    constant ILI_RAMWR    : unsigned (7 downto 0) := x"2c";

    constant init_sequence : array_unsigned_8_downto_0_t := (
        COM & x"ef",        DTA & x"03", DTA & x"80", DTA & x"02", 
        COM & x"cf",        DTA & x"00", DTA & x"c1", DTA & x"30",
        COM & x"ed",        DTA & x"64", DTA & x"03", DTA & x"12", DTA & x"81",
        COM & x"e8",        DTA & x"85", DTA & x"00", DTA & x"78",
        COM & x"cb",        DTA & x"39", DTA & x"2c", DTA & x"00", DTA & x"34",
                            DTA & x"02",
        COM & x"f7",        DTA & x"20",
        COM & x"ea",        DTA & x"00", DTA & x"00",
        COM & ILI_PWCTR1,   DTA & x"23",
        COM & ILI_PWCTR2,   DTA & x"10",
        COM & ILI_VMCTR1,   DTA & x"3e", DTA & x"28",
        COM & ILI_VMCTR2,   DTA & x"86",
        COM & ILI_MADCTL,   DTA & x"40",
        COM & ILI_PIXFMT,   DTA & x"55",
        COM & ILI_FRMCTR1,  DTA & x"00", DTA & x"13",
        COM & ILI_DFUNCTR,  DTA & x"08", DTA & x"82", DTA & x"27",
        COM & x"f2",        DTA & x"00",
        COM & ILI_GAMMASET, DTA & x"01",
        COM & ILI_GMCTRP1,  DTA & x"0f", DTA & x"31", DTA & x"2b",
                            DTA & x"0c", DTA & x"0e",
                            DTA & x"08", DTA & x"4e", DTA & x"f1",
                            DTA & x"37", DTA & x"07",
                            DTA & x"10", DTA & x"03", DTA & x"0e",
                            DTA & x"09", DTA & x"00",
        COM & ILI_GMCTRN1,  DTA & x"00", DTA & x"0e", DTA & x"14",
                            DTA & x"03", DTA & x"11",
                            DTA & x"07", DTA & x"31", DTA & x"c1",
                            DTA & x"48", DTA & x"08",
                            DTA & x"0f", DTA & x"0c", DTA & x"31",
                            DTA & x"36", DTA & x"0f",
        COM & ILI_SLPOUT
    );

    signal cnt : unsigned (15 downto 0);

begin

    p_div : process (clk)
    begin
        if rising_edge(clk)
        then
            if rst = '0'
            then
            end if;
        else null;
        end if;
    end process p_div;

    p_state: process (clk)
    begin
    end process p_state;

    
end architecture behavioural;
