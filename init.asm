
init:
    BANKSEL     PORTA ; select bank of PORTA
    call        sgr_init_osc
    call        sgr_init_gpio
    call        sgr_init_uart
    retlw       0

sgr_init_osc:
    ; Init osc 8MHz
    BANKSEL     OSCCON
    MOVLW       0b01110000
    MOVWF       OSCCON
    retlw       0

sgr_init_gpio:
    
    ; Clear outputs
    BANKSEL     PORTA
    CLRF        PORTA

    ; Configure all pins as digital inputs
    BANKSEL     ANSEL
    MOVLW       0x00
    MOVWF       ANSEL
    MOVLW       0b00000010
    MOVWF       TRISA
    retlw       0


sgr_init_uart:
    
    ; Init SPBRG with baudrate
    BANKSEL     SPBRG
    MOVLW       0b10000000
    MOVLW       SPBRG

    ; Enable the asynchronous serial port by clearing bit SYNC and setting bit SPEN
    BANKSEL     TXSTA
    MOVLW       0b00100100
    MOVWF       TXSTA
    BANKSEL     RCSTA
    MOVLW       0b10010000 ; bit7 = Enable Serial Port, bit4 enable RX
    MOVWF       RCSTA

    retlw       0
    
