processor 16F88

#include <xc.inc>
#include "config.asm"
#include "defines.h"

; autogen defines for regs.
#include "regdefs.h"

psect rstVector, delta=2
reset_vector:
    goto main

psect code, delta=2
irq_enter:
    goto        irq_handler
irq_handler:
    MOVWF       gr_W_TEMP          ;Copy W to TEMP register
    SWAPF       STATUS, W       ;Swap status to be saved into W
    CLRF        STATUS          ;bank 0, regardless of current bank, Clears IRP,RP1,RP0
    MOVWF       gr_STATUS_TEMP     ;Save status to bank zero STATUS_TEMP register
    MOVF        PCLATH, W       ;Only required if using page 1
    MOVWF       gr_PCLATH_TEMP     ;Save PCLATH into W
    CLRF        PCLATH          ;Page zero, regardless of current page

    ;(Insert user code here)

    MOVF        gr_PCLATH_TEMP, W  ;Restore PCLATH
    MOVWF       PCLATH          ;Move W into PCLATH
    SWAPF       gr_STATUS_TEMP, W  ;Swap STATUS_TEMP register into W (sets bank to original state)
    MOVWF       STATUS          ;Move W into STATUS register
    SWAPF       gr_W_TEMP, F       ;Swap gr_W_TEMP
    SWAPF       gr_W_TEMP, W       ;Swap gr_W_TEMP into W

    ; handle interrupts
    retfie

main:
    ; btfss       TRISB, 2
    call        init
    BANKSEL     PORTA ; select bank of PORTA

main_bl:
    goto        main_bl_loop
main_bl_loop:
    call        handle_pkt
    ; call        uart_rx
    ; MOVWF       0x20
    ; incf        0x20, W
    ; call        uart_tx
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
#include "crc8.asm"
#include "bootloader.asm"

END reset_vector