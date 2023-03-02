
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

    dbg_blip
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
    dbg_blip
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
    goto        _handle_pkt_read_port

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
_handle_pkt_read_port:
    BANKSEL     PORTA
    MOVLW       4 ; send LEN
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
    return

; ----------------------------
; CMD_READ_EEPROM
; ----------------------------
_handle_pkt_read_eeprom:
    return
