
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_00_tb is
end display_00_tb;

architecture testbench_display of display_00_tb is

    component display_00 is
        port
        (
            clk      : in std_ulogic;
            rst      : in std_ulogic;
            lcd_rd   : out unsigned (0 downto 0);
            lcd_rst  : out unsigned (0 downto 0);
            lcd_cs   : out unsigned (0 downto 0);
            lcd_data : out unsigned (9 downto 0)
        ); 
    end component display_00;

    signal clk_tb      : std_ulogic := '0';
    signal rst_tb      : std_ulogic;
    signal lcd_rd_tb   : unsigned (0 downto 0);
    signal lcd_rst_tb  : unsigned (0 downto 0);
    signal lcd_cs_tb   : unsigned (0 downto 0);
    signal lcd_data_tb : unsigned (9 downto 0);

    begin

        disp_comp: component display_00 
            port map(
                        clk      => clk_tb,
                        rst      => rst_tb,
                        lcd_rd   => lcd_rd_tb,
                        lcd_rst  => lcd_rst_tb,
                        lcd_cs   => lcd_cs_tb,
                        lcd_data => lcd_data_tb
                    );

        rst_tb <= '1',
                  '0' after 10 ns,
                  '1' after 20 ns;

        clk_proc: process
        begin
            wait for 5 ns;
            clk_tb <= not(clk_tb);
        end process clk_proc;

end testbench_display;
