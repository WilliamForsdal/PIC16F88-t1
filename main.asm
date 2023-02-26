processor 16F88

#include <xc.inc>

#include "config.asm"

psect rstVector, delta=2
reset_vector:
    goto main




psect code, delta=2
irq_enter:
    goto irq_handler
irq_handler:
    ; handle interrupts
    retfie
main:
    call        init
    BANKSEL     PORTA ; select bank of PORTA
    goto        main_loop

main_loop:
    ; btfsc       PORTA, 1
    call        uart_rx
    MOVWF       0x20
    incf        0x20, W
    call        uart_tx
    
    ; BANKSEL     PORTA
    ; MOVLW       100
    ; call        delay
    goto        main_loop


delay:
    MOVWF       0x22
_delay_3:
    MOVWF       0x21
_delay_2:
    MOVWF       0x20
_delay_1:
    DECFSZ      0x20, f
    goto        _delay_1
    DECFSZ      0x21, f
    goto        _delay_2
    DECFSZ      0x22, f
    goto        _delay_3
    retlw       0    

#include "init.asm"
#include "uart.asm"

END reset_vector