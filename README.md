# Driving ili9341 display on a Lattice iCE40 FPGA device

This is an example code I developed to drive ili9341 display on Lattice ICE, using only free tools. I used a STM32 "Bluepill" to program the SPI flash on the development board (Olimex iCE40HX1K-EVB). An early test version!

Display: ili9341 parallel

BOARD  iCE40HX1K-EVB
 LED1  40
 LED2  51
 BUT1  41
 BUT2  42

                  --------      
        +5V      |  1   2 |      GND
      +3.3V      |  3   4 |      GND 
    PIO3_1A   1  |  5   6 |      EXTCLK
    PIO3_1B   2  |  7   8 |      GND
    PIO3_2A   3  |  9  10 |  40  LED1
    PIO3_2B   4  | 11  12 |  51  LED2
    PIO3_3A   7  | 13  14 |  37  PIO2_9/TxD
    PIO3_3B   8    15  16 |  36  PIO2_8/RxD
    PIO3_5A   9    17  18 |  34  PIO2_7
    PIO3_5B  10    19  20 |  33  PIO2_6
    PIO3_6A  12  | 21  22 |  30  PIO2_5
    PIO3_6B  13  | 23  24 |  29  PIO2_4
    PIO3_7B  16  | 25  26 |  28  PIO2_3
    PIO3_8A  18  | 27  28 |  27  PIO2_2
    PIO3_8B  19  | 29  30 |  26  PIO2_1
   PIO3_10A  20  | 31  32 |  25  PIO3_12B
   PIO3_10B  21  | 33  34 |  24  PIO3_12A
                  -------- 
                   PIN

                        --------      
                       |  1   2 |      
            3.3V       |  3   4 |      GND  
             rst    1  |  5   6 |      
              cs    2  |  7   8 |      
         (rs) d8    3  |  9  10 |  40  
         (wr) d9    4  | 11  12 |  51  
              rd    7  | 13  14 |  37  
              d2    8    15  16 |  36  
              d3    9    17  18 |  34  
              d4   10    19  20 |  33  
              d5   12  | 21  22 |  30  
              d6   13  | 23  24 |  29  
              d7   16  | 25  26 |  28  
              d0   18  | 27  28 |  27  
              d1   19  | 29  30 |  26  
                   20  | 31  32 |  25  
                   21  | 33  34 |  24  
                        -------- 
