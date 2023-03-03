
rx_pkt:
    BANKSEL     PORTA
    ; Set FSR to rx new pkt.
    movlw       0x20
    MOVWF       FSR
    fcs16_init

_rx_pkt_preamble:
    call        uart_rx
    XORLW       0xFF
    IF_NOT_ZERO
    goto _rx_pkt_preamble

_rx_pkt_consume_preambles:
    call        uart_rx
    XORLW       0xFF
    IF_ZERO
    goto        _rx_pkt_consume_preambles

    ; Got first byte here (length). Now calc crc and rx next bytes.
    XORLW       0xFF        ; Xor W with FF again to get the original byte back
    MOVWF       INDF        ; Save it in buffer,
    SUBLW       PKT_MAX_LEN ; test if length is OK (not too big)
    ; "For borrow, the polarity is reversed. A subtraction is executed by adding the two’s complement of the second operand."
    IF_NOT_CARRY
    retlw       1               ; Bad length!

    MOVF        INDF, W         ; Store length in W again, sublw destroys it.
    MOVWF       PKT_BYTE_ITER   ; save length here to iterate over
    INCF        FSR, F          ; point to next position in buffer
    fcs16_update                ; update checksum

; Rx all bytes in pkt
_rx_pkt_data:
    call        uart_rx
    MOVWF       INDF
    INCF        FSR, F
    fcs16_update
    DECFSZ      PKT_BYTE_ITER, F
    goto        _rx_pkt_data

_rx_pkt_end:
    ; Finished rxing bytes, finalize checksum
    fcs16_finalize

    ; now rx crc and check
    call        uart_rx
    SUBWF       FCS_1, F
    IF_BIT_CLR STATUS, ZERO
    return      ; BAD CHECKSUM, w != 0 here.
    call        uart_rx
    SUBWF       FCS_2, F
    return ; Caller can check if zero after return


handle_pkt:
    dbg_blip
    BANKSEL     PORTA

    ; Prepare checksum regs for our reply
    fcs16_init

    movlw       0x20
    MOVWF       FSR                 ; Point to start of pkt

    ; PING
    MOVF        0x21, W             ; Load W with received CMD id
    XORLW       CMD_PING            ; XOR with CMD_PING to check if that's the CMD.
    IF_BIT_SET  STATUS, ZERO        ; If 0
    goto        _handle_pkt_ping    ; then we have found the handler.

    ; CMD_READ_GPIO
    MOVF        0x21, W             ; W is changed by XORLW above, so have to set it again.
    XORLW       CMD_READ_GPIO
    IF_BIT_SET  STATUS, ZERO
    goto        _handle_pkt_read_gpio

    ; CMD_WRITE_EEPROM
    MOVF        0x21, W
    XORLW       CMD_WRITE_EEPROM
    IF_BIT_SET  STATUS, ZERO
    goto        _handle_pkt_write_eeprom

    ; CMD_READ_EEPROM
    MOVF        0x21, W 
    XORLW       CMD_READ_EEPROM
    IF_BIT_SET  STATUS, ZERO
    goto        _handle_pkt_read_eeprom

    ; Repeat for other CMD handlers..

    ; UNKNOWN CMD
    MOVLW       CMD_UNKNOWN
    call        uart_tx
    MOVF        INDF, W
    call        uart_tx
    MOVLW       CMD_UNKNOWN
    call        uart_tx
    return


; ----------------------------
; PING
; ----------------------------
_handle_pkt_ping:
    ; store length in PKT_BYTE_ITER:
    MOVF        INDF, W
    MOVWF       PKT_BYTE_ITER
    call        uart_tx
    fcs16_update
    INCF        FSR, F
    ; Handle tx all bytes except CRC here
_handle_pkt_ping_loop:
    MOVF        INDF, W
    call        uart_tx
    fcs16_update
    INCF        FSR, F
    DECFSZ      PKT_BYTE_ITER, F
    goto        _handle_pkt_ping_loop

    fcs16_finalize_and_tx
    return

; ----------------------------
; CMD_READ_GPIO
; ----------------------------
_handle_pkt_read_gpio:
    BANKSEL     PORTA
    MOVLW       3 ; send LEN
    call        uart_tx
    fcs16_update
    ; tx CMD
    movlw       CMD_READ_GPIO
    call        uart_tx
    fcs16_update
    MOVF        PORTA, W
    call        uart_tx 
    fcs16_update
    MOVF        PORTB, W
    call        uart_tx 
    fcs16_update
    fcs16_finalize_and_tx
    return

; ----------------------------
; CMD_WRITE_EEPROM
; ----------------------------
_handle_pkt_write_eeprom:
    ; 0x20 = len    
    ; 0x21 = cmd
    ; 0x22 = EEADR start address
    ; 0x23... EEDATA

    ; if len < 3, we don't have any data.
    movlw       2
    SUBWF       0x20, W
    IF_NOT_CARRY
    goto        _handle_pkt_write_eeprom_end

    ; Store length - 2 in PKT_BYTE_ITER. This is how many bytes to write.
    MOVLW       2
    SUBWF        0x20, W
    MOVWF       PKT_BYTE_ITER

    MOVF        0x22, W
    BANKSEL     EEADR
    MOVWF       EEADR

    ; Point FSR to data to write, ie skip len and cmd
    MOVLW       0x23
    MOVWF       FSR

_handle_pkt_write_eeprom_loop:
        BANKSEL     PORTA
        TP_ON()
        MOVF        INDF, W
        call        eeprom_write
        BANKSEL     PORTA
        TP_OFF()

        BANKSEL     EECON1
_handle_pkt_write_eeprom_loop_wait_for_write_finish:
        BTFSC       EECON1, 1 ; Wait for write to complete
        GOTO        _handle_pkt_write_eeprom_loop_wait_for_write_finish
        INCF        FSR, f
        BANKSEL     EEADR
        INCF        EEADR, F

        BANKSEL     PKT_BYTE_ITER
        DECFSZ      PKT_BYTE_ITER, f
        GOTO        _handle_pkt_write_eeprom_loop

_handle_pkt_write_eeprom_end:
    ; Now tx reply
    send_empty_reply    CMD_WRITE_EEPROM
    return

; ----------------------------
; CMD_READ_EEPROM
; ----------------------------
_handle_pkt_read_eeprom:
    ; 0x20 = len    
    ; 0x21 = cmd
    ; 0x22 = EEADR
    ; 0x23 = len to read
    ; If 0x23 == 0, we will tx all 256 bytes.

    ; Send length
    MOVF        0x23, W
    MOVWF       PKT_BYTE_ITER

    ADDLW       1 ; add 1 for cmd byte
    call        uart_tx
    fcs16_update

    ; send CMD
    MOVLW       CMD_READ_EEPROM
    call        uart_tx
    fcs16_update

    ; Load EEPROM address in EEADR
    MOVF            0x22, W
    BANKSEL         EEADR
    MOVWF           EEADR
    BANKSEL         EECON1
    BCF             EECON1, 7  ; Point to Data memory

    ; now start sending EEPROM data
_handle_pkt_read_eeprom_loop:
        BANKSEL     EECON1
        BSF         EECON1, 0  ; EE Read
        BANKSEL     EEDATA ; Select Bank of EEDATA
        MOVF        EEDATA, W ; W = EEDATA
        call        uart_tx
        fcs16_update
        BANKSEL     EEADR ; uart_tx changes bank
        INCF        EEADR, F
        DECFSZ      PKT_BYTE_ITER, F
        goto        _handle_pkt_read_eeprom_loop

_handle_pkt_read_eeprom_end:
    fcs16_finalize_and_tx
    return
