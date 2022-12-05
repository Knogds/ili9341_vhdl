library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ili9341.all;

    entity display_00 is port
    (
        clk       : in std_ulogic;
        rst       : in std_ulogic;

        lcd_rd    : out unsigned (0 downto 0);
        lcd_rst   : out unsigned (0 downto 0);
        lcd_cs    : out unsigned (0 downto 0);

        -- lcd_data:
        -- bit 9 = WRX
        -- bit 8 = D/CX = LCD_RS
        -- bit 7-0      = LCD_D0..7
        lcd_data : out unsigned (9 downto 0)
    );
    end display_00;               

architecture behavioural of display_00 is

    constant DIV : unsigned := x"00";
    -- constant DIV : unsigned := x"11";
    signal cnt      : unsigned (19 downto 0);
    signal slow_cnt : unsigned (19 downto 0);
    signal slow_cnt_enable : std_ulogic;
    signal slow_cnt_stop : unsigned (19 downto 0);
    signal wrx      : unsigned (0 downto 0);
    signal switches : unsigned (3 downto 0);
    
    type state_t is (
                     s_clear_screen,
                     s_clear_screen_data,
                     s_init_lcd,
                     s_init_pause,
                     s_pulse_wrx,
                     s_render_font,
                     s_rst_lcd,
                     s_stop,
                     s_wait,
                     s_write_char
                    );

    signal state, next_state : state_t;

begin

    p_div : process (clk)
    begin
        if rising_edge(clk)
        then
            if rst = '0'
            then
                cnt <= (others => '0');
                slow_cnt <= (others => '0');
                slow_cnt_enable  <= '1';
                state <= s_rst_lcd;
                wrx <= "0";
                switches <= "0000";
            elsif cnt = DIV - 1
                then
                if wrx = 0
                then
                    wrx <= "1";
                else
                    wrx <= "0";
                    if slow_cnt = slow_cnt_stop
                    then
                        wrx <= "0";
                        state <= next_state;
                        slow_cnt <= (others => '0');
                    else
                        if slow_cnt_enable = '1' then
                            slow_cnt <= slow_cnt + 1;
                        else null;
                        end if;
                    end if;
                end if;
                cnt <= (others => '0');
            else
                cnt <= cnt + 1;
            end if;
        else null;
        end if;
    end process p_div;

    p_state : process (clk, state, slow_cnt, wrx)

        variable col_R, col_R_tmp : unsigned (4 downto 0) := "00000";
        variable col_G, col_G_tmp : unsigned (5 downto 0) := "000000";
        variable col_B, col_B_tmp : unsigned (4 downto 0) := "00000";

    begin
        case state is
            -------------------------------------------------------------------
            when s_rst_lcd =>
                case slow_cnt is
                    when x"00000" =>
                        lcd_rst <= "0";
                        lcd_rd <= "0";
                        lcd_cs <= "0";
                    when x"00001" =>
                        lcd_rst <= "1";
                        lcd_rd <= "1";
                        lcd_cs <= "1";
                    when others => 
                        lcd_rst <= "1";
                        lcd_rd <= "1";
                        lcd_cs <= "0";
                end case;
                slow_cnt_stop <= x"0000a";
                next_state <= s_init_lcd;

            -------------------------------------------------------------------
            when s_init_lcd =>
                lcd_data <= wrx & init_sequence(to_integer(slow_cnt));
                slow_cnt_stop <= x"00054";
                next_state <= s_init_pause;

            -------------------------------------------------------------------
            when s_init_pause =>
                case slow_cnt is
                    when x"00f10" =>
                        lcd_data <= WRX_LO & COM & ILI_DISPON;
                    when x"00f20" =>
                        lcd_data <= WRX_HI & COM & ILI_DISPON;
                    when others => null;
                end case;
                slow_cnt_stop <= x"00fff";
                next_state <= s_clear_screen;

            -------------------------------------------------------------------
            when s_clear_screen =>
                lcd_data <= wrx & clear_screen(to_integer(slow_cnt));
                slow_cnt_stop <= x"0000a";
                next_state <= s_clear_screen_data;

            -------------------------------------------------------------------
            when s_clear_screen_data =>
                slow_cnt_stop <= x"25a70"; -- 320*241*2
--                lcd_data <= wrx & DTA & slow_cnt(7 downto 0);
                next_state <= s_render_font;
              --------------------------------------------------------------
                case switches(3 downto 0) is
                    when "0000" => lcd_data <= wrx & DTA & slow_cnt(7 downto 0);
                    --when "0000" => lcd_data <= wrx & DTA & font(to_integer(slow_cnt));
                    when "0001" => lcd_data <= wrx & DTA & "00000000";
                    when "0010" => lcd_data <= wrx & DTA & "11111111";
                    when "0011" =>
                        if (slow_cnt mod 2) = 0
                            then lcd_data <= wrx & DTA & "00000000";
                            else lcd_data <= wrx & DTA & "00011111";
                        end if;
                    when "0100" =>
                        if (slow_cnt mod 2) = 0
                            then lcd_data <= wrx & DTA & "00000111";
                            else lcd_data <= wrx & DTA & "11100000";
                        end if;
                    when "0101" =>
                        if (slow_cnt mod 2) = 0
                            then lcd_data <= wrx & DTA & "11111000";
                            else lcd_data <= wrx & DTA & "00000000";
                        end if;
--                    when "0110" =>
--                        if (slow_cnt mod 2) = 0
--                            then lcd_data <= wrx & DTA & col_B & col_G (2 downto 0);
--                            else lcd_data <= wrx & DTA & col_G (5 downto 3) & col_R;
--                        end if;
--                        col_R := col_R_tmp;
--                        col_G := col_G_tmp;
--                        col_B := col_B_tmp;
--                        col_R := col_R_tmp + 1;
--                        if col_R = "11111"
--                            then col_G := col_G_tmp + 1;
--                            else null;
--                        end if;
--                        if col_G = "111111"
--                            then col_B := col_B_tmp + 1;
--                            else null;
--                        end if;
--                    when others => lcd_data <= wrx & DTA & slow_cnt(0 downto 0) & "0000000";
                    when others => lcd_data <= wrx & DTA & slow_cnt(7 downto 0);
                end case;
            when s_render_font =>


          -------------------------------------------------------------------
            when others => null;
        end case;
        if slow_cnt_stop = 0
            then col_R := "00000";
                 col_G := "000000";
                 col_B := "00000";
                 col_R_tmp := "00000";
                 col_G_tmp := "000000";
                 col_B_tmp := "00000";
        end if;
    end process p_state;
end;
