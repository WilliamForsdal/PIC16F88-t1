
; EEADR has address, W has value
eeprom_write:
    BANKSEL     EECON1
_eeprom_write_wait:
    BTFSC       EECON1, 1 ; Wait for write to complete
    GOTO        _eeprom_write_wait
    BANKSEL     EEDATA
    MOVWF       EEDATA

    BANKSEL     EECON1
    BCF         EECON1, 7 ; Point to DATA memory
    BSF         EECON1, 2 ; Enable writes
    
    ; write unlock sequence:
    MOVLW       0x55
    MOVWF       EECON2 ; Write 55h
    MOVLW       0xaa
    MOVWF       EECON2 ; Write AAh
    BSF         EECON1, 1 ; Write starts now.

    ; After a write sequence has been initiated, clearing the WREN bit will not affect this write cycle.
    BCF         EECON1, 2
    
    BANKSEL     PORTA
    return      ; all done!

eeprom_waitforwritefinished:
    BANKSEL     EECON1
_eeprom_waitforwritefinished_wait:
    BTFSC       EECON1, 1 ; Wait for write to complete
    GOTO        _eeprom_waitforwritefinished_wait
    BANKSEL     PORTA
    return  

; Address is in W
eeprom_read:
    BANKSEL     EECON1 ; Select Bank of EECON1
    BCF         EECON1, 7; Point to Data memory
    BSF         EECON1, 0 ; EE Read
    BANKSEL     EEDATA ; Select Bank of EEDATA
    MOVF        EEDATA, W ; W = EEDATA
    return
;     BANKSEL     EEADR
;     MOVWF       EEADR
;     BANKSEL     EECON1
;     BCF EECON1, 7  ; Point to Data memory
;     BSF EECON1, 0  ; EE Read
;     BANKSEL EEDATA ; Select Bank of EEDATA
;     MOVF EEDATA, W ; W = EEDATA

;     ; Switch back to default bank
;     BANKSEL PORTA
;     return