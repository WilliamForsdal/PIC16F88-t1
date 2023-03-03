
; does not destroy W
fcs16_init MACRO
    CLRF       FCS_1
    CLRF       FCS_2
    INCF       FCS_1, F
    INCF       FCS_2, F
    ENDM

; destroys W
fcs16_update MACRO
    ADDWF       FCS_1, F
    MOVF        FCS_1, W
    ADDWF       FCS_2, F
    ENDM

; destroys W
fcs16_finalize MACRO
    MOVLW       0xff
    XORWF       FCS_1, F
    XORWF       FCS_2, F
    ENDM

fcs16_finalize_and_tx MACRO
    fcs16_finalize
    MOVF        FCS_1, W
    call        uart_tx
    MOVF        FCS_2, W
    call        uart_tx
    ENDM

dbg_blip MACRO  
    TP_ON()
    TP_OFF()
    ENDM



send_empty_reply MACRO le_cmd
    BANKSEL         PORTA
    movlw           1
    call            uart_tx
    fcs16_update
    movlw           le_cmd
    call            uart_tx
    fcs16_update
    fcs16_finalize_and_tx
    ENDM
