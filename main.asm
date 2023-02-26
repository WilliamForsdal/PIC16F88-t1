processor 16F88

#include <xc.inc>
#include "config.asm"

#define W_TEMP          0xFF
#define STATUS_TEMP     0xFE
#define PCLATH_TEMP     0xFD

psect rstVector, delta=2
reset_vector:
    goto main


psect code, delta=2
irq_enter:
    goto        irq_handler
irq_handler:
    MOVWF       W_TEMP          ;Copy W to TEMP register
    SWAPF       STATUS, W       ;Swap status to be saved into W
    CLRF        STATUS          ;bank 0, regardless of current bank, Clears IRP,RP1,RP0
    MOVWF       STATUS_TEMP     ;Save status to bank zero STATUS_TEMP register
    MOVF        PCLATH, W       ;Only required if using page 1
    MOVWF       PCLATH_TEMP     ;Save PCLATH into W
    CLRF        PCLATH          ;Page zero, regardless of current page

    ;(Insert user code here)

    MOVF        PCLATH_TEMP, W  ;Restore PCLATH
    MOVWF       PCLATH          ;Move W into PCLATH
    SWAPF       STATUS_TEMP, W  ;Swap STATUS_TEMP register into W (sets bank to original state)
    MOVWF       STATUS          ;Move W into STATUS register
    SWAPF       W_TEMP, F       ;Swap W_TEMP
    SWAPF       W_TEMP, W       ;Swap W_TEMP into W

    ; handle interrupts
    retfie

main:
    call        init
    BANKSEL     PORTA ; select bank of PORTA


main_bl:
    goto        main_bl_loop
main_bl_loop:
    ; rx packet
    ; call        rx_pkt
    ; call        handle_pkt


    call        uart_rx
    MOVWF       0x20
    incf        0x20, W
    call        uart_tx
    goto        main_bl_loop


; Delay proportional to W * W * W
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