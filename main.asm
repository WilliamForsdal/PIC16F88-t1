processor 16F88

#include <xc.inc>

; CONFIG1
CONFIG  FOSC = INTOSCIO       ; Oscillator Selection bits (INTRC oscillator; port I/O function on both RA6/OSC2/CLKO pin and RA7/OSC1/CLKI pin)
CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled)
CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
CONFIG  MCLRE = OFF           ; RA5/MCLR/VPP Pin Function Select bit (RA5/MCLR/VPP pin function is digital I/O, MCLR internally tied to VDD)
CONFIG  BOREN = OFF           ; Brown-out Reset Enable bit (BOR disabled)
CONFIG  LVP = OFF             ; Low-Voltage Programming Enable bit (RB3 is digital I/O, HV on MCLR must be used for programming)
CONFIG  CPD = OFF             ; Data EE Memory Code Protection bit (Code protection off)
CONFIG  WRT = OFF             ; Flash Program Memory Write Enable bits (Write protection off)
;CONFIG  CCPMX = RB0           ; CCP1 Pin Selection bit (CCP1 function on RB0)
CONFIG  CP = OFF              ; Flash Program Memory Code Protection bit (Code protection off)

; CONFIG2
CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal External Switchover mode disabled)

; User guide chapter 4.2: delta means 2 bytes per memory address (14 bit opcodes for PIC12F683)
; this psect just holds the reset vector
psect rstVector, delta=2
reset_vector:
    goto main

psect code, delta=2
main:
    ; call sr_osc_conf
    ; call sr_gpio_conf
    ; BANKSEL     OSCCON
    ; MOVLW       0b01100000
    ; MOVWF       OSCCON
    ; BANKSEL     PORTA ; select bank of PORTA
    ; CLRF        PORTA
    ; BANKSEL     ANSEL 
    ; MOVLW       0x00 ; Configure all pins as digital inputs
    ; MOVWF       ANSEL
    ; MOVLW       0x01
    ; MOVWF       TRISA

    ; BANKSEL     PORTA ; select bank of PORTA
    ; goto        main_loop

    call        sr_init_osc
    call        sr_init_gpio
    call        sr_init_uart
    ; BANKSEL     OSCCON
    ; MOVLW       0b01100000
    ; MOVWF       OSCCON

    ; BANKSEL     PORTA ; select bank of PORTA
    ; CLRF        PORTA
    ; BANKSEL     ANSEL 
    ; MOVLW       0x00 ; Configure all pins
    ; MOVWF       ANSEL ; as digital inputs
    ; MOVLW       0x02
    ; MOVWF       TRISA
    BANKSEL     PORTA ; select bank of PORTA
    goto        main_loop

main_loop:
    ; btfsc       PORTA, 1
    MOVLW       0x41
    call        uart_tx
    MOVLW       0x42
    call        uart_tx
    MOVLW       0x43
    call        uart_tx
    MOVLW       0x44
    call        uart_tx
    MOVLW       0x0D
    call        uart_tx
    MOVLW       0x0A
    call        uart_tx
    
    BANKSEL     PORTA
    MOVLW       200
    MOVWF       0x21
_main_loop_delay_1:
    MOVWF       0x20
_main_loop_delay_2:
    DECFSZ      0x20, f
    goto        _main_loop_delay_2
    DECFSZ      0x21, f
    goto        _main_loop_delay_1

    goto        main_loop


uart_tx:
    BANKSEL     PORTA
    bsf         PORTA, 0
    ; Start tx
    BANKSEL     TXREG
    MOVWF       TXREG ; starts tx
    BANKSEL     TXSTA
    NOP
    NOP
    NOP

    ; Wait tx complete
_uart_tx_wait:
    btfss       TXSTA, 1
    goto        _uart_tx_wait

    bcf         PORTA, 0
    retlw       0

sr_init_osc:
    BANKSEL     OSCCON
    MOVLW       0b01110000
    MOVWF       OSCCON
    retlw       0

sr_init_gpio:
    
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


sr_init_uart:
    
    ; Init SPBRG with baudrate
    BANKSEL     SPBRG
    MOVLW       0b10000000
    MOVLW       SPBRG

    ; Enable the asynchronous serial port by clearing bit SYNC and setting bit SPEN
    BANKSEL     TXSTA
    MOVLW       0b00100100
    MOVWF       TXSTA
    BANKSEL     RCSTA
    MOVLW       0b10000000 ; bit7 = Enable Serial Port
    MOVWF       RCSTA

    retlw       0
    

    


END reset_vector