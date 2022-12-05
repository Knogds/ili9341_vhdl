-- initialization sequence and constant names starting with ILI_ + constant
-- comments from:
-- https://github.com/abhra0897/stm32f1_ili9341_parallel / MIT licence
-- connection:
-- Nexys4       LCD        in this file in datasheet
-- JA1..4  -> LCD_D0..D3
-- JA7..10 -> LCD_D4..D7
-- JB1     -> LCD_WR     lcd_data[9]  WRX  write command/data on rising edge
-- JB2     -> LCD_RST    lcd_rst      RESX active low
-- JB3     -> LCD_CS     lcd_cs       CSX  active low
-- JB4     -> LCD_RS     lcd_data[8]  D/CX
-- JB5     -> GND
-- JB6     -> 3V3
-- JB7     -> LCD_RD     lcd_rd       RDX 0->1 when sending comm./data
-- page 28 in datasheet
-- send colour information: page 65 datasheet
-- One pixel (3 sub-pixels) display data is sent by 3 bytes transfer when DBI
-- [2:0] bits of 3Ah register are set to "110"
-- 65K, RGB 5-6-5
-- D/CX=0 & D7..D0 all0    0
-- D/CX=1 & "RRRRRGGG"    pixel0      transfer1
-- D/CX=1 & "GGGBBBBB"    pixel0      transfer2
--       ...
-- D/CX=1 & "RRRRRGGG"    pixel239    transfer479
-- D/CX=1 & "GGGBBBBB"    pixel239    transfer480
-- In this project, commands/data are just being sent, reading is not needed in
-- order to show graphics on the display
-- command is sent:
-- D/CX RDX  WRX     D7-Dj0
--  1    1  rising   data
-- data is sent:
-- D/CX RDX  WRX     D7-D0
--  0    1  rising   data

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

    entity display_00 is port
    (
        clk       : in std_ulogic;
        rst       : in std_ulogic;
        but_up    : in std_ulogic;
        but_down  : in std_ulogic;
        but_left  : in std_ulogic;
        but_right : in std_ulogic;
        but_mid   : in std_ulogic;
        switches  : in unsigned (15 downto 0);

        lcd_rd    : out unsigned (0 downto 0);
        lcd_rst   : out unsigned (0 downto 0);
        lcd_cs    : out unsigned (0 downto 0);
        leds      : out unsigned (15 downto 0);
        seg       : out unsigned (7 downto 0);
        ano       : out unsigned (7 downto 0);

        -- lcd_data:
        -- bit 9 = WRX
        -- bit 8 = D/CX = LCD_RS
        -- bit 7-0      = LCD_D0..7
        lcd_data : out unsigned (9 downto 0)
    );
    end display_00;               

architecture behavioural of display_00 is

-- testing:
    -- constant DIV : unsigned := "0";

-- minimum tested safe divisor: 0x10
    constant DIV : unsigned := x"10";

    signal cnt      : unsigned (19 downto 0);
    signal slow_cnt : unsigned (19 downto 0); -- max amount 8bit data to send
                                              -- will be 320 * 240 = 76800 pixels
                                              -- sending 2x8bit data per pixels
                                              -- = 153600x8bit data sent,
                                              -- during time slow_cnt counter and
                                              -- fits into 0xfffff
    signal slow_cnt_stop : unsigned (19 downto 0);
    signal wrx      : unsigned (0 downto 0);
    signal colour_R : unsigned (4 downto 0);
    signal colour_G : unsigned (5 downto 0);
    signal colour_B : unsigned (4 downto 0);
    signal pixel    : unsigned (7 downto 0);
    signal charX0pos, charX1pos : unsigned (15 downto 0);
    signal charY0pos, charY1pos : unsigned (15 downto 0);
    signal charXoffset, charYoffset : unsigned (7 downto 0);
    signal num0, num1, num2, num3,
           num4, num5, num6, num7 : unsigned (3 downto 0);
    signal seg_val : unsigned (0 to 7);
    signal hor_lines : unsigned (15 downto 0);
    signal ver_lines : unsigned (15 downto 0);
    signal draw_multiplier : unsigned (3 downto 0);

    type state_t is (s_wait, s_rst_lcd, s_init_lcd, s_clear_screen, s_write_char,
                     s_pulse_wrx, s_stop, s_clear_screen_data, s_init_pause);

    signal state, next_state : state_t;

    type array_unsigned_8_downto_0_t is
        array (natural range <>) of unsigned (8 downto 0);
    type array_unsigned_7_downto_0_t is
        array (natural range <>) of unsigned (7 downto 0);
    type array_char_line_t is array (0 to 7) of unsigned (7 downto 0);
    type array_2d_t is array (0 to 1) of array_char_line_t;

    constant chars : array_2d_t := (
        ( "00011000",
          "01100110",
          "11000011",
          "11000011",
          "11000011",
          "11000011",
          "01100110",
          "00011100" ),
        ( "00011100",
          "00111100",
          "01101100",        
          "00001100",
          "00001100",
          "00001100",
          "00001100",
          "00111111")
    );

    constant COM, WRX_LO     : unsigned (0 downto 0) := "0";
    constant DTA, WRX_HI     : unsigned (0 downto 0) := "1";
    constant ILI_PWCTR1      : unsigned (7 downto 0) := x"c0"; -- power_control
    constant ILI_PWCTR2      : unsigned (7 downto 0) := x"c1"; -- power_control
    constant ILI_VMCTR1      : unsigned (7 downto 0) := x"c5"; -- VCM control
    constant ILI_VMCTR2      : unsigned (7 downto 0) := x"c7"; -- VCM control 2
    constant ILI_MADCTL      : unsigned (7 downto 0) := x"36"; -- Memory Access Control
    constant ILI_PIXFMT      : unsigned (7 downto 0) := x"3a"; -- Pixel format
    constant ILI_FRMCTR1     : unsigned (7 downto 0) := x"b1";
    constant ILI_DFUNCTR     : unsigned (7 downto 0) := x"b6"; -- Display Function Control
    constant ILI_GAMMASET    : unsigned (7 downto 0) := x"26"; -- Gamma curve selected
    constant ILI_GMCTRP1     : unsigned (7 downto 0) := x"e0"; -- Set Gamma
    constant ILI_GMCTRN1     : unsigned (7 downto 0) := x"e1"; -- Set Gamma
    constant ILI_SLPOUT      : unsigned (7 downto 0) := x"11"; -- Exit Sleep
    constant ILI_DISPON      : unsigned (7 downto 0) := x"29"; -- Display on
    constant ILI_CASET       : unsigned (7 downto 0) := x"2a"; -- Beginning/end X
    constant ILI_PASET       : unsigned (7 downto 0) := x"2b"; -- Beginning/end Y
    constant ILI_RAMWR       : unsigned (7 downto 0) := x"2c"; -- Write image data to ram

    constant init_sequence : array_unsigned_8_downto_0_t := (
        COM & x"ef",        DTA & x"03", DTA & x"80", DTA & x"02", 
        COM & x"cf",        DTA & x"00", DTA & x"c1", DTA & x"30",
        COM & x"ed",        DTA & x"64", DTA & x"03", DTA & x"12", DTA & x"81",
        COM & x"e8",        DTA & x"85", DTA & x"00", DTA & x"78",
        COM & x"cb",        DTA & x"39", DTA & x"2c", DTA & x"00", DTA & x"34", DTA & x"02",
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
        COM & ILI_GMCTRP1,  DTA & x"0f", DTA & x"31", DTA & x"2b", DTA & x"0c", DTA & x"0e",
                            DTA & x"08", DTA & x"4e", DTA & x"f1", DTA & x"37", DTA & x"07",
                            DTA & x"10", DTA & x"03", DTA & x"0e", DTA & x"09", DTA & x"00",
        COM & ILI_GMCTRN1,  DTA & x"00", DTA & x"0e", DTA & x"14", DTA & x"03", DTA & x"11",
                            DTA & x"07", DTA & x"31", DTA & x"c1", DTA & x"48", DTA & x"08",
                            DTA & x"0f", DTA & x"0c", DTA & x"31", DTA & x"36", DTA & x"0f",
        COM & ILI_SLPOUT
-- 8.2.12. Sleep Out (11h) It will be necessary to wait 5msec before sending next command,
-- this is to allow time for the supply voltages and clock circuits stabilize.
-- The display module loads all display supplier's factory default values to the registers during this 
-- 5msec and there cannot be any abnormal visual effect on the display image if factory default and register values are same 
-- when this load is done and when the display module is already Sleep Out mode.
    );

    -- clear screen:
    -- command ILI_CASET
    -- data X0 15..8
    -- data X0 7..0
    -- data X1 15..8
    -- data X1 7..0
    -- command ILI_PASET
    -- data Y0 15..8
    -- data Y0 7..0
    -- data Y1 15..8
    -- data Y1 7..0
    -- command 0x2c
    -- rest of data (pixels) ... amount: (X1 - X0) * (Y1 - Y0) * 2 (2 data per pixel)
    -- because the colour is not going to change, it is enough to just set the colour for
    -- the first pixel and for the rest of the data, just pulse WRX
    -- (the colour information is sent on WRX 0->1)

    constant clear_screen : array_unsigned_8_downto_0_t := (
        COM & ILI_CASET, DTA & x"00", DTA & x"00", -- from x:0
                         DTA & x"00", DTA & x"f0", -- until x:240 first msb then lsb
        COM & ILI_PASET, DTA & x"00", DTA & x"00", -- from y:0
                         DTA & x"01", DTA & x"40", -- until y:320
        COM & x"2c"
    );

begin

    p_div : process (clk)
    begin
        if rising_edge(clk)
            then
            if rst = '0'
                then
                    cnt <= (others => '0');
                    slow_cnt <= (others => '0');
                    state <= s_rst_lcd;
                    wrx <= "0";
                    num0 <= "0000";
                    num1 <= "0000";
                    num2 <= "0000";
                    num3 <= "0000";
                    num4 <= "0000";
                    num5 <= "0000";
                    num6 <= "0000";
                    num7 <= "0000";
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
                                    slow_cnt <= slow_cnt + 1;
                            end if;
                    end if;
                    cnt <= (others => '0');
                else
                    cnt <= cnt + 1;
            end if;
        end if;
    end process p_div;

    p_seg : process (clk)
    begin
        
        
    end process p_seg;

    p_input : process (clk)
    begin
    --    DIV <= switches (15 downto 12);
    end process p_input;

 
    p_state : process (clk, state, slow_cnt, wrx)

        impure function define_area (X0 : unsigned (15 downto 0);
                          X1 : unsigned (15 downto 0);
                          Y0 : unsigned (15 downto 0);
                          Y1 : unsigned (15 downto 0);
                          multiplier : unsigned (3 downto 0)
                          ) return array_unsigned_8_downto_0_t is
            variable area_arr : array_unsigned_8_downto_0_t (0 to 10) := (
            COM & ILI_CASET, DTA & X0(15 downto 8), DTA & X0(7 downto 0),
                             DTA & X1(15 downto 8), DTA & x1(7 downto 0),
            COM & ILI_PASET, DTA & Y0(15 downto 8), DTA & Y0(7 downto 0),
                             DTA & Y1(15 downto 8), DTA & Y1(7 downto 0),
            COM & x"2c"
            );
            begin
            hor_lines <= X1 - X0;
            ver_lines <= Y1 - Y0;
            draw_multiplier <= multiplier;
            return area_arr;
        end function define_area;

        variable col_R, col_R_tmp : unsigned (4 downto 0) := "00000";
        variable col_G, col_G_tmp : unsigned (5 downto 0) := "000000";
        variable col_B, col_B_tmp : unsigned (4 downto 0) := "00000";

    begin
        case state is
            when s_rst_lcd =>
                case slow_cnt is
                    when x"00000" =>
                        lcd_data <= "0000000000";
                        lcd_rst <= "0";
                        lcd_rd <= "0";
                        lcd_cs <= "0";
                    when x"00004" =>
                        lcd_rst <= "1";
                        lcd_rd <= "1";
                        lcd_cs <= "1";
                    when x"00008" =>
                        lcd_cs <= "0";
                    when others => null;
                end case;
                slow_cnt_stop <= x"0000a";
                next_state <= s_init_lcd;

            when s_init_lcd =>
                lcd_data <= wrx & init_sequence(to_integer(slow_cnt));
                slow_cnt_stop <= x"00054";
                next_state <= s_init_pause;

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

            when s_clear_screen =>
                lcd_data <= wrx & clear_screen(to_integer(slow_cnt));
                slow_cnt_stop <= x"0000a";
                next_state <= s_clear_screen_data;

            when s_clear_screen_data =>
                slow_cnt_stop <= x"25a80"; -- 320*241*2
                --------------------------------------------------------------
                case switches(3 downto 0) is
                    when "0000" => lcd_data <= wrx & DTA & slow_cnt(7 downto 0);
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
                    when "0110" =>
                        if (slow_cnt mod 2) = 0
                            then lcd_data <= wrx & DTA & col_B & col_G (2 downto 0);
                            else lcd_data <= wrx & DTA & col_G (5 downto 3) & col_R;
                        end if;
                        col_R := col_R_tmp;
                        col_G := col_G_tmp;
                        col_B := col_B_tmp;
                        col_R := col_R_tmp + 1;
                        if col_R = "11111"
                            then col_G := col_G_tmp + 1;
                            else null;
                        end if;
                        if col_G = "111111"
                            then col_B := col_B_tmp + 1;
                            else null;
                        end if;
                    when others => lcd_data <= wrx & DTA & slow_cnt(0 downto 0) & "0000000";
                end case;
                --------------------------------------------------------------
                next_state <= s_clear_screen;
           when others => null;

        end case;

        if slow_cnt_stop = 0
            then col_R := "00000";
                 col_G := "000000";
                 col_B := "00000";
                 col_R_tmp := "00000";
                 col_G_tmp := "000000";
                 col_B_tmp := "00000";
            else null;
        end if;

    end process p_state;

end;
