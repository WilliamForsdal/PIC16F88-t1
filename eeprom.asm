
eeprom_write:
    ; EEADR shall have address
    ; 



; Address is in W
; eeprom_read:
;     BANKSEL EEADR
;     MOVWF   EEADR
;     BANKSEL EECON1
;     BCF EECON1, 7  ; Point to Data memory
;     BSF EECON1, 0  ; EE Read
;     BANKSEL EEDATA ; Select Bank of EEDATA
;     MOVF EEDATA, W ; W = EEDATA

;     ; Switch back to default bank
;     BANKSEL PORTA
;     return