
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

    entity ili_draw_area is port (

        clk_i           : in std_ulogic;
        rst_i           : in std_ulogic;

        -- beginning of the drawing area
        X0_i            : in unsigned (15 downto 0);
        Y0_i            : in unsigned (15 downto 0);

        -- end of the drawing area
        X1_i            : in unsigned (15 downto 0);
        Y1_i            : in unsigned (15 downto 0);

        -- colour that should be written to a single pixel
        col_R_i         : in unsigned (4 downto 0);
        col_G_i         : in unsigned (5 downto 0);
        col_B_i         : in unsigned (4 downto 0);

        busy            : out std_ulogic;

        -- to ili9341
        ili_8bit_bus_o  : out unsigned (15 downto 0);
        ili_cd_o        : out std_ulogic;
        ili_cs          : out std_ulogic;
        ili_rd          : out std_ulogic;
        ili_rst         : out std_ulogic;
        ili_wrx_o       : out std_ulogic;

    );

architecture behavioural of ili_draw_area is

    type array_unsigned_7_downto_0_t is
        array (natural range <>) of unsigned (7 downto 0);

begin

    
end architecture behavioural;
