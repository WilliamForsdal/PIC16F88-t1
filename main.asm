processor 16F88

#include <xc.inc>

#include "config.asm"

psect rstVector, delta=2
reset_vector:
    goto main

psect code, delta=2
main:
    call        init
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


#include "init.asm"
#include "uart.asm"

END reset_vector