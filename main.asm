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
;   CONFIG  CCPMX = RB0           ; CCP1 Pin Selection bit (CCP1 function on RB0)
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
    BANKSEL     PORTA ; select bank of PORTA
    CLRF        PORTA
    BANKSEL     ANSEL 
    MOVLW       0x00 ; Configure all pins
    MOVWF       ANSEL ; as digital inputs
    MOVLW       0x00
    MOVWF       TRISA
    BANKSEL     PORTA ; select bank of PORTA
    goto        main_loop

main_loop:
    bsf         PORTA, 0
    bcf         PORTA, 0
    goto        main_loop
