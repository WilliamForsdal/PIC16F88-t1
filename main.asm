processor 16F88

#include <xc.inc>
#include "config.asm"
#include "defines.h"

; autogen defines for regs.
#include "regdefs.h"
#include "macros.asm"

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
    fcs16_init

    ; call        test_write_eeprom
    call        ee_print_all

main_bl:
    goto        main_bl_loop

main_bl_loop:
    call        rx_pkt
    IF_NOT_ZERO
    goto        bad_pkt
    call        handle_pkt
    goto        main_bl_loop

bad_pkt:
    call        uart_tx
    movlw       0xff
    call        uart_tx

    goto        main_bl_loop

ee_print_all:

    BANKSEL     EEADR ; Select Bank of EEADR
    CLRF        EEADR ; check 0

_ee_print_all_loop:
    call        eeprom_read
    call        uart_tx
    BANKSEL     EEADR ; Select Bank of EEADR
    INCF        EEADR, F
    IF_NOT_ZERO
    goto        _ee_print_all_loop
    BANKSEL     PORTA
    return

; test_write_eeprom:
;     BANKSEL     EEADR ; Select Bank of EEADR
;     CLRF        EEADR ; check 0
;     call        eeprom_read
;     call        uart_tx
;     ; Write W + 1 back to 0
;     ADDLW       1
;     call        eeprom_write
;     return


; Delay proportional to W * W * W
; delay:
;     MOVWF       0x22
; _delay_3:
;     MOVWF       0x21
; _delay_2:
;     MOVWF       0x20
; _delay_1:
;     DECFSZ      0x20, f
;     goto        _delay_1
;     DECFSZ      0x21, f
;     goto        _delay_2
;     DECFSZ      0x22, f
;     goto        _delay_3
;     retlw       0    

#include "init.asm"
#include "uart.asm"
; #include "crc8.asm"
#include "bootloader.asm"
#include "eeprom.asm"

END reset_vector