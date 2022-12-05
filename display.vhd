library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ili9341 is

    type array_char_line_t is array (0 to 474) of unsigned (7 downto 0);

    type array_unsigned_7_downto_0_t is
        array (natural range <>) of unsigned (7 downto 0);

    --constant font : array_char_line_t := (
    constant font : array_unsigned_7_downto_0_t := (
        x"00", x"00", x"00", x"00", x"00", -- ' '  32
        x"00", x"00", x"5F", x"00", x"00", -- '!'  33
        x"00", x"03", x"00", x"03", x"00", -- '"'  34
        x"14", x"3E", x"14", x"3E", x"14", -- '#'  35
        x"24", x"2A", x"7F", x"2A", x"12", -- '$'  36
        x"43", x"33", x"08", x"66", x"61", -- '%'  37
        x"36", x"49", x"55", x"22", x"50", -- '&'  38
        x"00", x"05", x"03", x"00", x"00", -- '''  39
        x"00", x"1C", x"22", x"41", x"00", -- '('  40
        x"00", x"41", x"22", x"1C", x"00", -- ')'  41
        x"14", x"08", x"3E", x"08", x"14", -- '*'  42
        x"08", x"08", x"3E", x"08", x"08", -- '+'  43
        x"00", x"50", x"30", x"00", x"00", -- '",'  44
        x"08", x"08", x"08", x"08", x"08", -- '-'  45
        x"00", x"60", x"60", x"00", x"00", -- '.'  46
        x"20", x"10", x"08", x"04", x"02", -- '/'  47
        x"3E", x"51", x"49", x"45", x"3E", -- '0'  48
        x"04", x"02", x"7F", x"00", x"00", -- '1'  49
        x"42", x"61", x"51", x"49", x"46", -- '2'  50
        x"22", x"41", x"49", x"49", x"36", -- '3'  51
        x"18", x"14", x"12", x"7F", x"10", -- '4'  52
        x"27", x"45", x"45", x"45", x"39", -- '5'  53
        x"3E", x"49", x"49", x"49", x"32", -- '6'  54
        x"01", x"01", x"71", x"09", x"07", -- '7'  55
        x"36", x"49", x"49", x"49", x"36", -- '8'  56
        x"26", x"49", x"49", x"49", x"3E", -- '9'  57
        x"00", x"36", x"36", x"00", x"00", -- ':'  58
        x"00", x"56", x"36", x"00", x"00", -- ';'  59
        x"08", x"14", x"22", x"41", x"00", -- '<'  60
        x"14", x"14", x"14", x"14", x"14", -- '='  61
        x"00", x"41", x"22", x"14", x"08", -- '>'  62
        x"02", x"01", x"51", x"09", x"06", -- '?'  63
        x"3E", x"41", x"59", x"55", x"5E", -- '@'  64
        x"7E", x"09", x"09", x"09", x"7E", -- 'A'  65
        x"7F", x"49", x"49", x"49", x"36", -- 'B'  66
        x"3E", x"41", x"41", x"41", x"22", -- 'C'  67
        x"7F", x"41", x"41", x"41", x"3E", -- 'D'  68
        x"7F", x"49", x"49", x"49", x"41", -- 'E'  69
        x"7F", x"09", x"09", x"09", x"01", -- 'F'  70
        x"3E", x"41", x"41", x"49", x"3A", -- 'G'  71
        x"7F", x"08", x"08", x"08", x"7F", -- 'H'  72
        x"00", x"41", x"7F", x"41", x"00", -- 'I'  73
        x"30", x"40", x"40", x"40", x"3F", -- 'J'  74
        x"7F", x"08", x"14", x"22", x"41", -- 'K'  75
        x"7F", x"40", x"40", x"40", x"40", -- 'L'  76
        x"7F", x"02", x"0C", x"02", x"7F", -- 'M'  77
        x"7F", x"02", x"04", x"08", x"7F", -- 'N'  78
        x"3E", x"41", x"41", x"41", x"3E", -- 'O'  79
        x"7F", x"09", x"09", x"09", x"06", -- 'P'  80
        x"1E", x"21", x"21", x"21", x"5E", -- 'Q'  81
        x"7F", x"09", x"09", x"09", x"76", -- 'R'  82
        x"26", x"49", x"49", x"49", x"32", -- 'S'  83
        x"01", x"01", x"7F", x"01", x"01", -- 'T'  84
        x"3F", x"40", x"40", x"40", x"3F", -- 'U'  85
        x"1F", x"20", x"40", x"20", x"1F", -- 'V'  86
        x"7F", x"20", x"10", x"20", x"7F", -- 'W'  87
        x"41", x"22", x"1C", x"22", x"41", -- 'X'  88
        x"07", x"08", x"70", x"08", x"07", -- 'Y'  89
        x"61", x"51", x"49", x"45", x"43", -- 'Z'  90
        x"00", x"7F", x"41", x"00", x"00", -- '['  91
        x"02", x"04", x"08", x"10", x"20", -- '\'  92
        x"00", x"00", x"41", x"7F", x"00", -- ']'  93
        x"04", x"02", x"01", x"02", x"04", -- '^'  94
        x"40", x"40", x"40", x"40", x"40", -- '_'  95
        x"00", x"01", x"02", x"04", x"00", -- '`'  96
        x"20", x"54", x"54", x"54", x"78", -- 'a'  97
        x"7F", x"44", x"44", x"44", x"38", -- 'b'  98
        x"38", x"44", x"44", x"44", x"44", -- 'c'  99
        x"38", x"44", x"44", x"44", x"7F", -- 'd' 100
        x"38", x"54", x"54", x"54", x"18", -- 'e' 101
        x"04", x"04", x"7E", x"05", x"05", -- 'f' 102
        x"08", x"54", x"54", x"54", x"3C", -- 'g' 103
        x"7F", x"08", x"04", x"04", x"78", -- 'h' 104
        x"00", x"44", x"7D", x"40", x"00", -- 'i' 105
        x"20", x"40", x"44", x"3D", x"00", -- 'j' 106
        x"7F", x"10", x"28", x"44", x"00", -- 'k' 107
        x"00", x"41", x"7F", x"40", x"00", -- 'l' 108
        x"7C", x"04", x"78", x"04", x"78", -- 'm' 109
        x"7C", x"08", x"04", x"04", x"78", -- 'n' 110
        x"38", x"44", x"44", x"44", x"38", -- 'o' 111
        x"7C", x"14", x"14", x"14", x"08", -- 'p' 112
        x"08", x"14", x"14", x"14", x"7C", -- 'q' 113
        x"00", x"7C", x"08", x"04", x"04", -- 'r' 114
        x"48", x"54", x"54", x"54", x"20", -- 's' 115
        x"04", x"04", x"3F", x"44", x"44", -- 't' 116
        x"3C", x"40", x"40", x"20", x"7C", -- 'u' 117
        x"1C", x"20", x"40", x"20", x"1C", -- 'v' 118
        x"3C", x"40", x"30", x"40", x"3C", -- 'w' 119
        x"44", x"28", x"10", x"28", x"44", -- 'x' 120
        x"0C", x"50", x"50", x"50", x"3C", -- 'y' 121
        x"44", x"64", x"54", x"4C", x"44", -- 'z' 122
        x"00", x"08", x"36", x"41", x"41", -- '{' 123
        x"00", x"00", x"7F", x"00", x"00", -- '|' 124
        x"41", x"41", x"36", x"08", x"00", -- '}' 125
        x"02", x"01", x"02", x"04", x"02"); -- '~' 126

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

    type array_unsigned_8_downto_0_t is
        array (natural range <>) of unsigned (8 downto 0);

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
        COM & ILI_SLPOUT);

    constant clear_screen : array_unsigned_8_downto_0_t := (
        COM & ILI_CASET, DTA & x"00", DTA & x"00", -- from x:0
                         DTA & x"00", DTA & x"f0", -- until x:240 first msb then lsb
        COM & ILI_PASET, DTA & x"00", DTA & x"00", -- from y:0
                         DTA & x"01", DTA & x"40", -- until y:320
        COM & x"2c");

end ili9341;
