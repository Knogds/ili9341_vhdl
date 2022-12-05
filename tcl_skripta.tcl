
# set filter [list led.blue led.green led.red msp430.port_out5\[7:0\] msp430.intr_num\[7:0\] msp430.intr_gie ]

set signals [list\
    clk_tb\
    rst_tb\
    cnt_out_tb\
    lcd_rd_tb\
    lcd_rst_tb\
    lcd_data_tb]

gtkwave::addSignalsFromList $signals
gtkwave::/Time/Zoom/Zoom_Best_Fit
gtkwave::/View/Show_Filled_High_Value
